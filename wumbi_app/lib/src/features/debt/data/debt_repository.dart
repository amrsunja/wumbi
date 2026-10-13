import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' show DatabaseExecutor;

import '../../../core/errors/exceptions/domain/domain_exceptions.dart';
import '../../../core/errors/failures/failures.dart';
import '../../../core/fx/fx_service.dart';
import '../../../core/local/database/sqlite/sqlite_services.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/providers/data/db_revision_provider.dart';
import '../../../core/providers/data/fx_provider.dart';
import '../../../core/providers/local/sqlite_database_provider.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/debt_close_reason.dart';
import '../../../core/utils/enums/debt_direction.dart';
import '../../../core/utils/enums/debt_role.dart';
import '../../../core/utils/enums/payment_kind.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/typedefs.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../../transaction/data/transaction_local_datasource.dart';
import 'debt_local_datasource.dart';
import 'debt_resolution.dart';
import 'models/debt_intent.dart';
import 'models/debt_model.dart';
import 'models/person_model.dart';
import 'person_local_datasource.dart';
import 'person_name.dart';

final debtRepositoryProvider = Provider<DebtRepository>(
  (ref) => DebtRepository(
    sqlite: ref.read(sqliteDataBaseProvider),
    fx: ref.read(fxServiceProvider),
    onWrite: ref.read(dbRevisionBumperProvider),
  ),
);

/// Exchange rates fetched **before** a debt-linked write opens its SQLite
/// transaction. The FX cache lives in the same database, so calling
/// `FxService` inside `db.transaction` would deadlock; the write reads rates
/// from this snapshot instead.
class DebtRates {
  const DebtRates([this._rates = const {}]);

  final Map<(CurrencyType, CurrencyType), double> _rates;

  /// `to per 1 from`. Throws [FxUnavailableException] when the pair was not
  /// prefetched (offline with nothing cached) — the write is then refused.
  double call(CurrencyType from, CurrencyType to) {
    if (from == to) return 1.0;
    return _rates[(from, to)] ?? (throw FxUnavailableException('No rate for ${from.code}→${to.code}'));
  }
}

/// Personal debts (spec B&D §7). Owns every invariant of `people`, `debts`
/// and `debt_payments`:
/// * remaining amounts are derived from live payments; only
///   `closed_at` / `close_reason` are cached and recomputed in the same
///   transaction as any write that can change them ([recomputeStatus]);
/// * cascades share one `now`, so undo restores exactly the rows deleted
///   together;
/// * money movement goes through `TransactionRepository.create` with a
///   [DebtIntent]; this repository only contributes txn-scoped helpers to
///   that write ([prepareRates], [applyIntent], [onTransactionDeleted],
///   [onTransactionRestored]) and never depends on `TransactionRepository`
///   (no cycle: TransactionRepository → DebtRepository → datasources).
class DebtRepository {
  DebtRepository({
    required this.sqlite,
    this.fx,
    this.onWrite,
    this.datasource = const DebtLocalDatasource(),
    this.people = const PersonLocalDatasource(),
    this.transactions = const TransactionLocalDatasource(),
  });

  final SQLiteServices sqlite;

  /// Null in unit tests → cross-currency writes fail with FX unavailable and
  /// base totals only include amounts already in the base currency.
  final FxService? fx;
  final void Function()? onWrite;
  final DebtLocalDatasource datasource;
  final PersonLocalDatasource people;
  final TransactionLocalDatasource transactions;

  // ======================================================= txn-scoped helpers

  /// Outside any transaction: fetch the rates a debt-linked draft may need
  /// (debt currency ↔ wallet currency for every debt it could repay). Network
  /// is allowed (write path). Missing pairs are left out; the write fails
  /// only if it actually needs one.
  Future<DebtRates> prepareRates(DebtIntent intent, {required CurrencyType walletCurrency, required DebtFlow flow}) async {
    final fx = this.fx;
    if (fx == null) return const DebtRates();
    final db = sqlite.db;
    final currencies = <CurrencyType>{};
    switch (intent) {
      case AutoDebtIntent(:final person):
        final personId = await _existingPersonId(db, person);
        if (personId != null) {
          final open = await datasource.live(db, personId: personId, direction: flow.repaysDirection, openOnly: true);
          currencies.addAll(open.map((d) => d.debt.currency));
        }
      case RepayDebtIntent(:final debtId):
        final d = await datasource.byId(db, debtId);
        if (d != null) currencies.add(d.debt.currency);
      case OpenDebtIntent():
        break;
    }
    final rates = <(CurrencyType, CurrencyType), double>{};
    for (final c in currencies.where((c) => c != walletCurrency)) {
      try {
        rates[(c, walletCurrency)] = (await fx.rate(c, walletCurrency)).rate;
        rates[(walletCurrency, c)] = (await fx.rate(walletCurrency, c)).rate;
      } on FxUnavailableException {
        // Needed only for a cross-currency repayment; refused there.
      }
    }
    return DebtRates(rates);
  }

  /// Inside `TransactionRepository.create`'s transaction, after the wallet row
  /// [tx] was inserted: open a debt or record repayments for it (spec B&D
  /// §7.3) and return the role the row must carry. Throws (rolling the whole
  /// write back) on over-repayment, stale / mismatched debts or missing FX.
  Future<DebtRole> applyIntent(
    DatabaseExecutor txn, {
    required TransactionModel tx,
    required DebtIntent intent,
    required DebtRates rates,
    required int now,
  }) async {
    final flow = tx.type == TransactionType.income ? DebtFlow.incoming : DebtFlow.outgoing;
    switch (intent) {
      case AutoDebtIntent(:final person, :final description, :final dueDate):
        final p = await _resolvePerson(txn, person, now);
        final open = await datasource.live(txn, personId: p.id, openOnly: true);
        return switch (resolveDebtFlow(_balanceOf(p.id, open), flow)) {
          OpensDebt(:final direction) => _openFor(txn, tx, p, direction, description, dueDate, now),
          RepaysDebts(:final direction) =>
            _repay(txn, tx, p, direction, open.where((d) => d.debt.direction == direction).toList(), rates, now),
        };
      case RepayDebtIntent(:final debtId):
        final target = await datasource.byId(txn, debtId);
        if (target == null || target.debt.deletedAt != null) throw const NotFoundException('debt');
        if (target.remaining <= 0) throw const DebtClosedException();
        if (!flow.canRepay(target.debt.direction)) throw const ValidationException('debt');
        final owner = await people.byId(txn, target.debt.personId);
        if (owner == null) throw const NotFoundException('person');
        return _repay(txn, tx, owner, target.debt.direction, [target], rates, now);
      case OpenDebtIntent(:final person, :final direction, :final description, :final dueDate):
        if (!flow.canOpen(direction)) throw const ValidationException('direction');
        final lender = await _resolvePerson(txn, person, now);
        return _openFor(txn, tx, lender, direction, description, dueDate, now);
    }
  }

  /// Swipe-delete of a debt-linked wallet row (already soft-deleted with
  /// [now] by the caller, same transaction):
  /// * principal → the debt, its payments and their return transactions go
  ///   too; a return that also paid other debts (FIFO) loses those payments
  ///   as well, so no transaction is left partially allocated;
  /// * repayment → its payments go and the debts may reopen.
  /// Returns how many **other** wallet transactions the cascade deleted.
  Future<int> onTransactionDeleted(DatabaseExecutor txn, TransactionModel tx, int now) async {
    switch (tx.debtRole) {
      case null:
        return 0;
      case DebtRole.principal:
        final debt = await datasource.byPrincipalTransaction(txn, tx.id);
        if (debt == null || debt.deletedAt != null) return 0;
        return _cascadeDelete(txn, debt, now);
      case DebtRole.repayment:
        final payments = await datasource.paymentsOfTransactions(txn, [tx.id]);
        await datasource.softDeletePayments(txn, payments.map((p) => p.id), now);
        for (final debtId in payments.map((p) => p.debtId).toSet()) {
          await recomputeStatus(txn, debtId, now);
        }
        return 0;
    }
  }

  /// Undo of [onTransactionDeleted]: restores every row stamped [deletedAt]
  /// (read **before** the wallet row itself was restored).
  Future<void> onTransactionRestored(DatabaseExecutor txn, TransactionModel tx, int deletedAt, int now) async {
    switch (tx.debtRole) {
      case null:
        return;
      case DebtRole.principal:
        final debt = await datasource.byPrincipalTransaction(txn, tx.id);
        if (debt == null || debt.deletedAt?.epochMs != deletedAt) return;
        await _cascadeRestore(txn, debt.id, deletedAt, now);
      case DebtRole.repayment:
        final restored = await datasource.paymentsOfTransactions(txn, [tx.id], deletedAt: deletedAt);
        await datasource.restorePayments(txn, restored.map((p) => p.id), deletedAt, now);
        for (final debtId in restored.map((p) => p.debtId).toSet()) {
          await recomputeStatus(txn, debtId, now);
        }
    }
  }

  /// Re-derives the cached status (spec B&D §7.4): remaining ≤ 0 → closed at
  /// the last live payment, `forgiven` if any live payment is a forgiveness,
  /// else `repaid`; otherwise open.
  Future<void> recomputeStatus(DatabaseExecutor txn, String debtId, int now) async {
    final d = await datasource.byId(txn, debtId);
    if (d == null) return;
    final totals = await datasource.paymentTotals(txn, debtId);
    final remaining = d.debt.principalMinor - totals.paid;
    if (remaining <= 0) {
      await datasource.setStatus(
        txn,
        debtId,
        closedAt: totals.lastPaidAt ?? now,
        reason: totals.hasForgiveness ? DebtCloseReason.forgiven : DebtCloseReason.repaid,
        now: now,
      );
    } else {
      await datasource.setStatus(txn, debtId, closedAt: null, reason: null, now: now);
    }
  }

  // ================================================================= writes

  /// A debt with no wallet movement ("Sara paid my dinner").
  Future<SuccessOrError<DebtModel>> createWithoutMoney(DebtDraft draft) => Failure.exceptionsCatcher(() async {
        if (draft.principal.minor <= 0) throw const ValidationException('amount', 'Enter an amount');
        final description = _description(draft.description);
        final now = nowMs();
        final nowDate = DateTime.now();
        late DebtModel debt;
        await sqlite.db.transaction((txn) async {
          final p = await _resolvePerson(txn, draft.person, now);
          debt = DebtModel(
            id: newId(),
            personId: p.id,
            direction: draft.direction,
            principalMinor: draft.principal.minor,
            currency: draft.principal.currency,
            description: description,
            openedAt: draft.openedAt ?? nowDate,
            dueDate: _day(draft.dueDate),
            createdAt: nowDate,
            updatedAt: nowDate,
          );
          await datasource.insertDebt(txn, debt);
        });
        onWrite?.call();
        return debt;
      });

  /// A settlement outside Wumbi's wallets, or a forgiveness (the UI passes
  /// the full remaining for "Forgive"). Never moves money.
  Future<SuccessOrError<void>> addPayment(
    String debtId, {
    required int amountMinor,
    required PaymentKind kind,
    DateTime? paidAt,
  }) =>
      Failure.exceptionsCatcher(() async {
        if (amountMinor <= 0) throw const ValidationException('amount', 'Enter an amount');
        final now = nowMs();
        final nowDate = DateTime.now();
        await sqlite.db.transaction((txn) async {
          final d = await datasource.byId(txn, debtId);
          if (d == null || d.debt.deletedAt != null) throw const NotFoundException('debt');
          if (d.remaining <= 0) throw const DebtClosedException();
          if (amountMinor > d.remaining) {
            final p = await people.byId(txn, d.debt.personId);
            throw DebtOverpaymentException(
              personName: p?.name ?? '',
              direction: d.debt.direction,
              maxRemaining: Money(d.remaining, d.debt.currency),
            );
          }
          await datasource.insertPayment(
            txn,
            DebtPaymentModel(
              id: newId(),
              debtId: debtId,
              kind: kind,
              amountMinor: amountMinor,
              paidAt: paidAt ?? nowDate,
              createdAt: nowDate,
              updatedAt: nowDate,
            ),
          );
          await recomputeStatus(txn, debtId, now);
        });
        onWrite?.call();
      });

  /// Description / due date only: principal, currency and direction are
  /// immutable ([A8] — mistakes are delete + re-enter).
  Future<SuccessOrError<DebtModel>> update(
    String debtId, {
    String? description,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) =>
      Failure.exceptionsCatcher(() async {
        late DebtModel updated;
        await sqlite.db.transaction((txn) async {
          final d = await datasource.byId(txn, debtId);
          if (d == null || d.debt.deletedAt != null) throw const NotFoundException('debt');
          updated = d.debt.copyWith(
            description: description == null ? d.debt.description : _description(description),
            dueDate: clearDueDate ? null : (_day(dueDate) ?? d.debt.dueDate),
            updatedAt: DateTime.now(),
          );
          await datasource.updateDebt(txn, updated);
        });
        onWrite?.call();
        return updated;
      });

  /// Debt sheet "Delete debt": same cascade as deleting its principal row.
  Future<SuccessOrError<DebtDeleteOutcome>> delete(String debtId) => Failure.exceptionsCatcher(() async {
        final now = nowMs();
        var deleted = 0;
        await sqlite.db.transaction((txn) async {
          final d = await datasource.byId(txn, debtId);
          if (d == null || d.debt.deletedAt != null) throw const NotFoundException('debt');
          deleted = await _cascadeDelete(txn, d.debt, now);
        });
        onWrite?.call();
        return DebtDeleteOutcome(deletedAtMs: now, transactionsDeleted: deleted);
      });

  Future<SuccessOrError<void>> restore(String debtId, int deletedAtMs) => Failure.exceptionsCatcher(() async {
        await sqlite.db.transaction((txn) => _cascadeRestore(txn, debtId, deletedAtMs, nowMs()));
        onWrite?.call();
      });

  /// History row delete: the payment, plus its wallet transaction when no
  /// other live payment references it. Returns the `deleted_at` for undo.
  Future<SuccessOrError<int>> deletePayment(String paymentId) => Failure.exceptionsCatcher(() async {
        final now = nowMs();
        await sqlite.db.transaction((txn) async {
          final p = await datasource.paymentById(txn, paymentId);
          if (p == null || p.deletedAt != null) throw const NotFoundException('payment');
          await datasource.softDeletePayments(txn, [p.id], now);
          final txId = p.transactionId;
          if (txId != null) {
            final others = await datasource.paymentsOfTransactions(txn, [txId]);
            if (others.isEmpty) await transactions.softDeleteMany(txn, [txId], now);
          }
          await recomputeStatus(txn, p.debtId, now);
        });
        onWrite?.call();
        return now;
      });

  Future<SuccessOrError<void>> restorePayment(String paymentId, int deletedAtMs) =>
      Failure.exceptionsCatcher(() async {
        final now = nowMs();
        await sqlite.db.transaction((txn) async {
          final p = await datasource.paymentById(txn, paymentId);
          if (p == null) throw const NotFoundException('payment');
          await datasource.restorePayments(txn, [p.id], deletedAtMs, now);
          if (p.transactionId != null) {
            await transactions.restoreWhereDeletedAt(txn, [p.transactionId!], deletedAtMs, now);
          }
          await recomputeStatus(txn, p.debtId, now);
        });
        onWrite?.call();
      });

  /// Rename; when the new name already belongs to another live person the
  /// two are merged into that person (debts move, this one is soft-deleted),
  /// like tag rename / merge. Returns the surviving person.
  Future<SuccessOrError<PersonModel>> renamePerson(String personId, String name) =>
      Failure.exceptionsCatcher(() async {
        final display = PersonName.display(name);
        final normalized = PersonName.normalize(name);
        if (display.isEmpty || display.length > kMaxPersonNameLength) throw const ValidationException('name');
        final now = nowMs();
        late PersonModel result;
        await sqlite.db.transaction((txn) async {
          final p = await people.byId(txn, personId);
          if (p == null || p.deletedAt != null) throw const NotFoundException('person');
          final clash = await people.byNormalizedName(txn, normalized);
          if (clash != null && clash.id != personId) {
            await datasource.moveToPerson(txn, personId, clash.id, now);
            await people.softDelete(txn, personId, now);
            result = clash;
            return;
          }
          await people.rename(txn, personId, display, normalized, now);
          result = p.copyWith(name: display, normalizedName: normalized);
        });
        onWrite?.call();
        return result;
      });

  /// Only a person with no live debts can go (picker swipe-to-delete).
  Future<SuccessOrError<void>> deletePerson(String personId) => Failure.exceptionsCatcher(() async {
        await sqlite.db.transaction((txn) async {
          if (await datasource.countLiveOfPerson(txn, personId) > 0) throw const PersonHasDebtsException();
          await people.softDelete(txn, personId, nowMs());
        });
        onWrite?.call();
      });

  // ================================================================== reads

  /// Debts page: open / settled per side, base totals, overdue count.
  Future<SuccessOrError<DebtsOverview>> overview({required CurrencyType base, DateTime? now}) =>
      Failure.exceptionsCatcher(() async {
        final at = now ?? DateTime.now();
        final db = sqlite.db;
        final all = await _summaries(db, await datasource.live(db), at);
        final open = all.where((s) => s.isOpen).toList()..sort(_openOrder);
        final settled = all.where((s) => !s.isOpen).toList()
          ..sort((a, b) => (b.debt.closedAt ?? b.debt.updatedAt).compareTo(a.debt.closedAt ?? a.debt.updatedAt));

        final rates = _CachedRates(fx);
        var owed = 0;
        var owe = 0;
        var incomplete = false;
        for (final s in open) {
          final v = await rates.tryConvert(s.remaining, base);
          if (v == null) {
            incomplete = true;
          } else if (s.debt.direction == DebtDirection.lent) {
            owed += v;
          } else {
            owe += v;
          }
        }
        return DebtsOverview(
          openLent: open.where((s) => s.debt.direction == DebtDirection.lent).toList(),
          openBorrowed: open.where((s) => s.debt.direction == DebtDirection.borrowed).toList(),
          settledLent: settled.where((s) => s.debt.direction == DebtDirection.lent).toList(),
          settledBorrowed: settled.where((s) => s.debt.direction == DebtDirection.borrowed).toList(),
          owedToMeBase: Money(owed, base),
          iOweBase: Money(owe, base),
          incomplete: incomplete,
          overdueCount: open.where((s) => s.overdue).length,
        );
      });

  /// Debt sheet: the debt (closed ones too), its history and the person's
  /// overall balance.
  Future<SuccessOrError<DebtDetails>> byId(String debtId, {required CurrencyType base, DateTime? now}) =>
      Failure.exceptionsCatcher(() async {
        final db = sqlite.db;
        final d = await datasource.byId(db, debtId);
        if (d == null || d.debt.deletedAt != null) throw const NotFoundException('debt');
        final summary = (await _summaries(db, [d], now ?? DateTime.now())).single;
        final wallet = d.debt.principalTransactionId == null
            ? null
            : await datasource.walletOfTransaction(db, d.debt.principalTransactionId!);
        return DebtDetails(
          summary: summary,
          history: await datasource.history(db, debtId),
          personBalance: await _personBalance(db, d.debt.personId, base),
          principalWalletId: wallet?.id,
          principalWalletName: wallet?.name,
          principalWalletDeleted: wallet?.deleted ?? false,
        );
      });

  /// Person picker: live people matching [query] with their open balance,
  /// people with open debts first, then most recently used.
  Future<SuccessOrError<List<PersonSummary>>> searchPeople(String query, {required CurrencyType base}) =>
      Failure.exceptionsCatcher(() async {
        final db = sqlite.db;
        final found = await people.search(db, PersonName.normalize(query));
        return [
          for (final p in found) PersonSummary(person: p, balance: await _personBalance(db, p.id, base)),
        ];
      });

  Future<SuccessOrError<PersonBalance>> personBalance(String personId, {required CurrencyType base}) =>
      Failure.exceptionsCatcher(() => _personBalance(sqlite.db, personId, base));

  /// What a debt-linked commit did (spec B&D §7.7), for the toast.
  Future<SuccessOrError<DebtCommitSummary>> commitSummary(String transactionId) =>
      Failure.exceptionsCatcher(() async {
        final db = sqlite.db;
        final tx = await transactions.byId(db, transactionId);
        if (tx == null || tx.debtRole == null) throw const NotFoundException('debt');
        final amount = Money(tx.amountMinor ?? 0, tx.currency);
        switch (tx.debtRole!) {
          case DebtRole.principal:
            final debt = await datasource.byPrincipalTransaction(db, tx.id);
            if (debt == null) throw const NotFoundException('debt');
            final p = await people.byId(db, debt.personId);
            return DebtCommitSummary(
              kind: debt.direction == DebtDirection.lent ? DebtCommitKind.openedLent : DebtCommitKind.openedBorrowed,
              personName: p?.name ?? '',
              amount: amount,
              leftAfter: debt.principal,
            );
          case DebtRole.repayment:
            final payments = await datasource.paymentsOfTransactions(db, [tx.id]);
            if (payments.isEmpty) throw const NotFoundException('debt');
            final first = (await datasource.byId(db, payments.first.debtId))!.debt;
            final payer = await people.byId(db, first.personId);
            final open = await datasource.live(db, personId: first.personId, direction: first.direction, openOnly: true);
            Money? left;
            if (open.isNotEmpty) {
              final currencies = open.map((d) => d.debt.currency).toSet();
              if (currencies.length == 1) {
                left = Money(open.fold(0, (s, d) => s + d.remaining), currencies.single);
              } else {
                final rates = _CachedRates(fx);
                var total = 0;
                for (final d in open) {
                  total += await rates.tryConvert(Money(d.remaining, d.debt.currency), tx.currency) ?? 0;
                }
                left = Money(total, tx.currency);
              }
            }
            return DebtCommitSummary(
              kind: first.direction == DebtDirection.lent ? DebtCommitKind.repaidIn : DebtCommitKind.repaidOut,
              personName: payer?.name ?? '',
              amount: amount,
              leftAfter: left,
            );
        }
      });

  // ================================================================ helpers

  Future<DebtRole> _openFor(
    DatabaseExecutor txn,
    TransactionModel tx,
    PersonModel person,
    DebtDirection direction,
    String? description,
    DateTime? dueDate,
    int now,
  ) async {
    // [A7]: the debt is in the currency the user typed.
    final principal = tx.original ?? Money(tx.amountMinor ?? 0, tx.currency);
    if (principal.minor <= 0) throw const ValidationException('amount', 'Enter an amount');
    final nowDate = DateTime.now();
    await datasource.insertDebt(
      txn,
      DebtModel(
        id: newId(),
        personId: person.id,
        direction: direction,
        principalMinor: principal.minor,
        currency: principal.currency,
        description: _description(description ?? tx.description),
        openedAt: tx.transactionDate,
        dueDate: _day(dueDate),
        principalTransactionId: tx.id,
        createdAt: nowDate,
        updatedAt: nowDate,
      ),
    );
    return DebtRole.principal;
  }

  Future<DebtRole> _repay(
    DatabaseExecutor txn,
    TransactionModel tx,
    PersonModel person,
    DebtDirection direction,
    List<DebtWithRemaining> targets,
    DebtRates rates,
    int now,
  ) async {
    final List<RepaymentShare> shares;
    try {
      shares = allocateRepayment(
        walletAmount: Money(tx.amountMinor ?? 0, tx.currency),
        original: tx.original,
        targets: [
          for (final t in targets) RepaymentTarget(debtId: t.debt.id, remaining: Money(t.remaining, t.debt.currency)),
        ],
        rate: rates.call,
      );
    } on OverRepayment catch (e) {
      throw DebtOverpaymentException(personName: person.name, direction: direction, maxRemaining: e.maxRemaining);
    }
    final nowDate = DateTime.now();
    for (final share in shares) {
      await datasource.insertPayment(
        txn,
        DebtPaymentModel(
          id: newId(),
          debtId: share.debtId,
          transactionId: tx.id,
          kind: PaymentKind.repayment,
          amountMinor: share.amount.minor,
          paidAt: tx.transactionDate,
          createdAt: nowDate,
          updatedAt: nowDate,
        ),
      );
      await recomputeStatus(txn, share.debtId, now);
    }
    return DebtRole.repayment;
  }

  Future<int> _cascadeDelete(DatabaseExecutor txn, DebtModel debt, int now) async {
    final own = await datasource.paymentsOfDebt(txn, debt.id);
    final returnTxIds = own.map((p) => p.transactionId).nonNulls.toSet().toList();
    final others = (await datasource.paymentsOfTransactions(txn, returnTxIds)).where((p) => p.debtId != debt.id).toList();
    await datasource.softDeletePayments(txn, [...own, ...others].map((p) => p.id), now);
    await datasource.softDeleteDebt(txn, debt.id, now);
    final principalTx = debt.principalTransactionId;
    final deleted = await transactions.softDeleteMany(
      txn,
      [if (principalTx != null) principalTx, ...returnTxIds],
      now,
    );
    for (final debtId in others.map((p) => p.debtId).toSet()) {
      await recomputeStatus(txn, debtId, now);
    }
    return deleted;
  }

  Future<void> _cascadeRestore(DatabaseExecutor txn, String debtId, int deletedAt, int now) async {
    if (await datasource.restoreDebt(txn, debtId, deletedAt, now) == 0) return;
    final own = await datasource.paymentsOfDebt(txn, debtId, deletedAt: deletedAt);
    final returnTxIds = own.map((p) => p.transactionId).nonNulls.toSet().toList();
    final others = (await datasource.paymentsOfTransactions(txn, returnTxIds, deletedAt: deletedAt))
        .where((p) => p.debtId != debtId)
        .toList();
    await datasource.restorePayments(txn, [...own, ...others].map((p) => p.id), deletedAt, now);
    final principalTx = (await datasource.byId(txn, debtId))!.debt.principalTransactionId;
    await transactions.restoreWhereDeletedAt(
      txn,
      [if (principalTx != null) principalTx, ...returnTxIds],
      deletedAt,
      now,
    );
    await recomputeStatus(txn, debtId, now);
    for (final id in others.map((p) => p.debtId).toSet()) {
      await recomputeStatus(txn, id, now);
    }
  }

  /// Find-or-create by normalized name (like tags); bumps `last_used_at`.
  Future<PersonModel> _resolvePerson(DatabaseExecutor txn, PersonRef ref, int now) async {
    switch (ref) {
      case ExistingPersonRef(:final id):
        final p = await people.byId(txn, id);
        if (p == null || p.deletedAt != null) throw const NotFoundException('person');
        await people.touch(txn, p.id, now);
        return p;
      case NewPersonRef(:final name):
        final display = PersonName.display(name);
        if (display.isEmpty || display.length > kMaxPersonNameLength) throw const ValidationException('person');
        final existing = await people.byNormalizedName(txn, PersonName.normalize(name));
        if (existing != null) {
          await people.touch(txn, existing.id, now);
          return existing;
        }
        final at = DateTimeExtension.fromEpochMs(now);
        final created = PersonModel(
          id: newId(),
          name: display,
          normalizedName: PersonName.normalize(name),
          lastUsedAt: at,
          createdAt: at,
          updatedAt: at,
        );
        await people.insert(txn, created);
        return created;
    }
  }

  Future<String?> _existingPersonId(DatabaseExecutor db, PersonRef ref) async => switch (ref) {
        ExistingPersonRef(:final id) => id,
        NewPersonRef(:final name) => (await people.byNormalizedName(db, PersonName.normalize(name)))?.id,
      };

  /// Per-currency open balance (no FX: usable inside a transaction).
  static PersonBalance _balanceOf(String personId, List<DebtWithRemaining> open) {
    final owedToMe = <CurrencyType, int>{};
    final iOwe = <CurrencyType, int>{};
    for (final d in open) {
      if (d.remaining <= 0) continue;
      final side = d.debt.direction == DebtDirection.lent ? owedToMe : iOwe;
      side.update(d.debt.currency, (v) => v + d.remaining, ifAbsent: () => d.remaining);
    }
    return PersonBalance(personId: personId, owedToMe: owedToMe, iOwe: iOwe);
  }

  /// [_balanceOf] plus base totals with cached rates (read path).
  Future<PersonBalance> _personBalance(DatabaseExecutor db, String personId, CurrencyType base) async {
    final balance = _balanceOf(personId, await datasource.live(db, personId: personId, openOnly: true));
    final rates = _CachedRates(fx);
    var incomplete = false;
    Future<Money?> total(Map<CurrencyType, int> side) async {
      if (side.isEmpty) return null;
      var sum = 0;
      for (final e in side.entries) {
        final v = await rates.tryConvert(Money(e.value, e.key), base);
        if (v == null) {
          incomplete = true;
        } else {
          sum += v;
        }
      }
      return Money(sum, base);
    }

    final owed = await total(balance.owedToMe);
    final owe = await total(balance.iOwe);
    return balance.copyWith(owedToMeBase: owed, iOweBase: owe, incomplete: incomplete);
  }

  Future<List<DebtSummary>> _summaries(DatabaseExecutor db, List<DebtWithRemaining> rows, DateTime now) async {
    final today = DateTime(now.year, now.month, now.day);
    final cache = <String, PersonModel?>{};
    final out = <DebtSummary>[];
    for (final r in rows) {
      final person = cache.containsKey(r.debt.personId)
          ? cache[r.debt.personId]
          : cache[r.debt.personId] = await people.byId(db, r.debt.personId);
      if (person == null) continue;
      final open = r.remaining > 0;
      out.add(
        DebtSummary(
          debt: r.debt,
          person: person,
          principal: r.debt.principal,
          paid: Money(r.debt.principalMinor - r.remaining, r.debt.currency),
          remaining: Money(r.remaining, r.debt.currency),
          overdue: open && r.debt.dueDate != null && r.debt.dueDate!.isBefore(today),
        ),
      );
    }
    return out;
  }

  /// Overdue first, then due soonest, then newest.
  static int _openOrder(DebtSummary a, DebtSummary b) {
    if (a.overdue != b.overdue) return a.overdue ? -1 : 1;
    final ad = a.debt.dueDate;
    final bd = b.debt.dueDate;
    if (ad != null && bd != null && ad != bd) return ad.compareTo(bd);
    if ((ad == null) != (bd == null)) return ad != null ? -1 : 1;
    return b.debt.openedAt.compareTo(a.debt.openedAt);
  }

  static String _description(String raw) {
    final d = raw.trim();
    if (d.length > kMaxDebtDescriptionLength) throw const ValidationException('description');
    return d;
  }

  static DateTime? _day(DateTime? d) => d == null ? null : DateTime(d.year, d.month, d.day);
}

/// Cached-rate conversion with a per-call memo (read path only).
class _CachedRates {
  _CachedRates(this.fx);

  final FxService? fx;
  final Map<(CurrencyType, CurrencyType), double?> _rates = {};

  Future<int?> tryConvert(Money money, CurrencyType to) async {
    if (money.currency == to) return money.minor;
    final key = (money.currency, to);
    final rate = _rates.containsKey(key) ? _rates[key] : _rates[key] = (await fx?.cachedRate(money.currency, to))?.rate;
    if (rate == null) return null;
    return convertMinor(money.minor, money.currency, to, rate);
  }
}
