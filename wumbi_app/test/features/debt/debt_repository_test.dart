import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' show Sqflite;
import 'package:wumbi/src/core/errors/failures/failures.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:wumbi/src/core/money/currency_type.dart';
import 'package:wumbi/src/core/money/money.dart';
import 'package:wumbi/src/core/utils/enums/debt_close_reason.dart';
import 'package:wumbi/src/core/utils/enums/debt_direction.dart';
import 'package:wumbi/src/core/utils/enums/debt_role.dart';
import 'package:wumbi/src/core/utils/enums/payment_kind.dart';
import 'package:wumbi/src/core/utils/enums/repeat_frequency.dart';
import 'package:wumbi/src/core/utils/enums/wallet_color.dart';
import 'package:wumbi/src/core/utils/typedefs.dart';
import 'package:wumbi/src/features/debt/data/debt_repository.dart';
import 'package:wumbi/src/features/debt/data/models/debt_intent.dart';
import 'package:wumbi/src/features/debt/data/models/debt_model.dart';
import 'package:wumbi/src/features/progress/data/models/progress_stats.dart';
import 'package:wumbi/src/features/progress/data/progress_repository.dart';
import 'package:wumbi/src/features/tag/data/tag_repository.dart';
import 'package:wumbi/src/features/transaction/data/models/transaction_model.dart';
import 'package:wumbi/src/features/transaction/data/transaction_repository.dart';
import 'package:wumbi/src/features/wallet/data/models/wallet_model.dart';
import 'package:wumbi/src/features/wallet/data/wallet_repository.dart';

import '../../helpers/test_db.dart';

late SQLiteServicesImpl sqlite;
late FakeFx fx;
late WalletRepository wallets;
late TagRepository tags;
late DebtRepository debts;
late TransactionRepository transactions;

const _usd = CurrencyType.usd;
const _eur = CurrencyType.eur;
const _ahmed = PersonRef.create('Ahmed');

Future<WalletModel> _wallet(String name, [CurrencyType c = _usd, int initial = 100000]) async => (await wallets.create(
      WalletDraft(name: name, currency: c, initialBalanceMinor: initial, color: WalletColor.blue, isPrimary: false),
    ))
        .getOrThrow();

/// GAVE (expense) with a person.
Future<SuccessOrError<TransactionModel>> _gave(
  WalletModel w,
  int minor, {
  PersonRef person = _ahmed,
  int day = 1,
  List<String> tags = const [],
  RepeatFrequency repeat = RepeatFrequency.never,
  DateTime? date,
}) =>
    transactions.create(
      TransactionDraft.expense(
        walletId: w.id,
        amount: Money(minor, w.currency),
        description: 'Dinner',
        tags: tags,
        date: date ?? DateTime(2026, 3, day, 12),
        repeat: repeat,
        debt: DebtIntent.auto(person: person),
      ),
    );

/// GOT (income) with a person, or with an explicit intent.
Future<SuccessOrError<TransactionModel>> _got(
  WalletModel w,
  int minor, {
  PersonRef person = _ahmed,
  DebtIntent? intent,
  int day = 10,
  Money? original,
}) =>
    transactions.create(
      TransactionDraft.income(
        walletId: w.id,
        amount: Money(minor, w.currency),
        original: original,
        description: '',
        tags: const [],
        date: DateTime(2026, 3, day, 12),
        repeat: RepeatFrequency.never,
        debt: intent ?? DebtIntent.auto(person: person),
      ),
    );

Future<Money> _balance(WalletModel w) async => (await wallets.byId(w.id)).getOrThrow().balance;

Future<int> _count(String sql) async => Sqflite.firstIntValue(await sqlite.db.rawQuery(sql)) ?? 0;

Future<DebtModel> _debtOf(String principalTxId) async => DebtModel.fromRow(
      (await sqlite.db.query('debts', where: 'principal_transaction_id = ?', whereArgs: [principalTxId])).single,
    );

Future<DebtSummary> _summary(String debtId) async =>
    (await debts.byId(debtId, base: _usd, now: DateTime(2026, 3, 15))).getOrThrow().summary;

void main() {
  setUpAll(sqfliteFfiInit);
  setUp(() async {
    sqlite = ffiSqlite(inMemoryDatabasePath);
    await sqlite.initDatabase();
    fx = FakeFx();
    void noop() {}
    wallets = WalletRepository(sqlite: sqlite, onWrite: noop);
    tags = TagRepository(sqlite: sqlite, fx: fx);
    debts = DebtRepository(sqlite: sqlite, fx: fx, onWrite: noop);
    transactions = TransactionRepository(sqlite: sqlite, tags: tags, debts: debts, onWrite: noop);
  });
  tearDown(() => sqlite.close());

  group('GAVE / GOT', () {
    test('GAVE to a new person lends: lent debt + principal row, balance down', () async {
      final card = await _wallet('Card');
      final tx = (await _gave(card, 15000)).getOrThrow();

      expect(tx.debtRole, DebtRole.principal);
      expect(await _balance(card), const Money(85000, _usd), reason: 'debt money is real money');
      final debt = await _debtOf(tx.id);
      expect(debt.direction, DebtDirection.lent);
      expect(debt.principal, const Money(15000, _usd));
      expect(debt.description, 'Dinner');
      expect(debt.openedAt, DateTime(2026, 3, 1, 12));
      expect(debt.isClosed, isFalse);
      expect(await _count("SELECT COUNT(*) FROM people WHERE normalized_name = 'ahmed'"), 1);
      expect(fx.networkCalls, 0, reason: 'same currency never touches FX');

      final summary = (await debts.commitSummary(tx.id)).getOrThrow();
      expect(summary.kind, DebtCommitKind.openedLent);
      expect(summary.personName, 'Ahmed');
    });

    test('names are find-or-create by normalized form', () async {
      final card = await _wallet('Card');
      await _gave(card, 100);
      await _gave(card, 100, person: const PersonRef.create('  ahmed '));
      expect(await _count('SELECT COUNT(*) FROM people'), 1);
      expect(await _count('SELECT COUNT(*) FROM debts'), 2, reason: '[A2] each loan is its own debt');
    });

    test('GOT from someone who owes me repays FIFO across debts', () async {
      final card = await _wallet('Card');
      final first = (await _gave(card, 5000, day: 1)).getOrThrow();
      final second = (await _gave(card, 4000, day: 2)).getOrThrow();

      final ret = (await _got(card, 7000)).getOrThrow();
      expect(ret.debtRole, DebtRole.repayment);
      expect(await _balance(card), const Money(100000 - 9000 + 7000, _usd));

      final d1 = await _summary((await _debtOf(first.id)).id);
      final d2 = await _summary((await _debtOf(second.id)).id);
      expect(d1.isOpen, isFalse);
      expect(d1.debt.closeReason, DebtCloseReason.repaid);
      expect(d1.debt.closedAt, DateTime(2026, 3, 10, 12));
      expect(d2.remaining, const Money(2000, _usd));
      expect(await _count("SELECT COUNT(*) FROM debt_payments WHERE transaction_id = '${ret.id}'"), 2);

      final summary = (await debts.commitSummary(ret.id)).getOrThrow();
      expect(summary.kind, DebtCommitKind.repaidIn);
      expect(summary.leftAfter, const Money(2000, _usd));
    });

    test('over-repayment is refused inline and writes nothing', () async {
      final card = await _wallet('Card');
      await _gave(card, 5000, day: 1);
      await _gave(card, 4000, day: 2);
      final rowsBefore = await _count('SELECT COUNT(*) FROM transactions');

      final error = (await _got(card, 9001)).tryGetError();
      expect(error, isA<ValidationFailure>());
      expect(error, isA<DebtOverpaymentFailure>());
      final failure = error! as DebtOverpaymentFailure;
      expect(failure.personName, 'Ahmed');
      expect(failure.direction, DebtDirection.lent);
      expect(failure.maxRemaining, const Money(9000, _usd));

      expect(await _count('SELECT COUNT(*) FROM transactions'), rowsBefore);
      expect(await _count('SELECT COUNT(*) FROM debt_payments'), 0);
      expect(await _balance(card), const Money(91000, _usd));
    });

    test('GOT from a new person borrows; GAVE back pays it', () async {
      final card = await _wallet('Card');
      const sara = PersonRef.create('Sara');
      final borrowed = (await _got(card, 20000, person: sara, day: 1)).getOrThrow();
      final debt = await _debtOf(borrowed.id);
      expect(debt.direction, DebtDirection.borrowed);

      final back = (await _gave(card, 20000, person: sara, day: 5)).getOrThrow();
      expect(back.debtRole, DebtRole.repayment);
      expect((await _summary(debt.id)).isOpen, isFalse);
      expect((await debts.commitSummary(back.id)).getOrThrow().leftAfter, isNull, reason: 'all settled');
    });

    test('cross-currency return closes the debt within one minor unit', () async {
      final card = await _wallet('Card');
      final euros = await _wallet('Euros', _eur);
      final lent = (await _gave(card, 10000)).getOrThrow();
      final debtId = (await _debtOf(lent.id)).id;

      expect((await _got(euros, 8999)).tryGetError(), isA<FxUnavailableFailure>(), reason: 'offline, nothing cached');
      expect(await _count('SELECT COUNT(*) FROM transactions'), 1);

      fx.rates[(_usd, _eur)] = 0.9;
      fx.rates[(_eur, _usd)] = 1.1111;
      final ret = (await _got(euros, 8999)).getOrThrow();
      expect(ret.debtRole, DebtRole.repayment);
      final s = await _summary(debtId);
      expect(s.isOpen, isFalse);
      expect(s.paid, const Money(10000, _usd), reason: '9999 + 1 residue');
    });

    test('Debt sheet repay targets that debt only, and checks direction / status', () async {
      final card = await _wallet('Card');
      final first = await _debtOf((await _gave(card, 5000, day: 1)).getOrThrow().id);
      final second = await _debtOf((await _gave(card, 4000, day: 2)).getOrThrow().id);

      final paid = await _got(card, 4000, intent: DebtIntent.repay(debtId: second.id));
      expect(paid.isSuccess(), isTrue);
      expect((await _summary(first.id)).remaining.minor, 5000, reason: 'no FIFO from the sheet');
      expect((await _summary(second.id)).isOpen, isFalse);

      expect(
        (await _got(card, 100, intent: DebtIntent.repay(debtId: second.id))).tryGetError(),
        isA<DebtClosedFailure>(),
      );
      final wrongWay = await transactions.create(
        TransactionDraft.expense(
          walletId: card.id,
          amount: const Money(100, _usd),
          description: '',
          tags: const [],
          date: DateTime(2026, 3, 12, 12),
          repeat: RepeatFrequency.never,
          debt: DebtIntent.repay(debtId: first.id),
        ),
      );
      expect(wrongWay.tryGetError(), isA<ValidationFailure>(), reason: 'a lent debt is repaid by GOT');
    });

    test('[A4] no recurring or upcoming debts; [A8] debt rows are not editable', () async {
      final card = await _wallet('Card');
      expect((await _gave(card, 100, repeat: RepeatFrequency.monthly)).tryGetError(), isA<ValidationFailure>());
      expect(
        (await _gave(card, 100, date: DateTime.now().add(const Duration(days: 3)))).tryGetError(),
        isA<ValidationFailure>(),
      );
      expect(await _count('SELECT COUNT(*) FROM debts'), 0);

      final tx = (await _gave(card, 100)).getOrThrow();
      final edit = await transactions.update(
        tx.id,
        TransactionDraft.expense(
          walletId: card.id,
          amount: const Money(200, _usd),
          description: '',
          tags: const [],
          date: DateTime(2026, 3, 1, 12),
          repeat: RepeatFrequency.never,
        ),
      );
      expect(edit.tryGetError(), isA<ValidationFailure>());
    });
  });

  group('without money', () {
    test('forgiveness closes with reason forgiven; a closed debt refuses more', () async {
      final debt = (await debts.createWithoutMoney(
        const DebtDraft(person: _ahmed, direction: DebtDirection.lent, principal: Money(3000, _usd)),
      ))
          .getOrThrow();
      expect(await _count('SELECT COUNT(*) FROM transactions'), 0);

      await debts.addPayment(debt.id, amountMinor: 1000, kind: PaymentKind.repayment);
      expect((await _summary(debt.id)).remaining.minor, 2000);
      expect(
        (await debts.addPayment(debt.id, amountMinor: 2001, kind: PaymentKind.repayment)).tryGetError(),
        isA<DebtOverpaymentFailure>(),
      );

      await debts.addPayment(debt.id, amountMinor: 2000, kind: PaymentKind.forgiveness);
      final s = await _summary(debt.id);
      expect(s.isOpen, isFalse);
      expect(s.debt.closeReason, DebtCloseReason.forgiven);
      expect(
        (await debts.addPayment(debt.id, amountMinor: 1, kind: PaymentKind.repayment)).tryGetError(),
        isA<DebtClosedFailure>(),
      );
    });

    test('deleting a payment reopens; undo closes again', () async {
      final card = await _wallet('Card');
      final debtId = (await _debtOf((await _gave(card, 5000)).getOrThrow().id)).id;
      await _got(card, 5000);
      final payment = (await debts.byId(debtId, base: _usd)).getOrThrow().history.single;
      expect(payment.walletName, 'Card');

      final deletedAt = (await debts.deletePayment(payment.payment.id)).getOrThrow();
      expect((await _summary(debtId)).remaining.minor, 5000);
      expect(await _balance(card), const Money(95000, _usd), reason: 'its return transaction went too');

      await debts.restorePayment(payment.payment.id, deletedAt);
      expect((await _summary(debtId)).isOpen, isFalse);
      expect(await _balance(card), const Money(100000, _usd));
    });
  });

  group('cascades', () {
    test('principal swipe-delete takes the debt, its returns and their other payments; undo restores all', () async {
      final card = await _wallet('Card');
      final firstTx = (await _gave(card, 5000, day: 1)).getOrThrow();
      final secondTx = (await _gave(card, 4000, day: 2)).getOrThrow();
      final first = await _debtOf(firstTx.id);
      final second = await _debtOf(secondTx.id);
      final ret = (await _got(card, 7000)).getOrThrow(); // 5000 → first, 2000 → second

      await transactions.softDelete(firstTx.id);
      expect(await _count('SELECT COUNT(*) FROM debts WHERE deleted_at IS NULL'), 1);
      expect(await _count("SELECT COUNT(*) FROM transactions WHERE id = '${ret.id}' AND deleted_at IS NULL"), 0);
      expect(await _count('SELECT COUNT(*) FROM debt_payments WHERE deleted_at IS NULL'), 0,
          reason: 'the return is never left partially allocated');
      expect((await _summary(second.id)).remaining.minor, 4000);
      expect(await _balance(card), const Money(96000, _usd));

      await transactions.restore(firstTx.id);
      expect((await _summary(first.id)).isOpen, isFalse);
      expect((await _summary(second.id)).remaining.minor, 2000);
      expect(await _count("SELECT COUNT(*) FROM transactions WHERE id = '${ret.id}' AND deleted_at IS NULL"), 1);
      expect(await _count('SELECT COUNT(*) FROM debt_payments WHERE deleted_at IS NULL'), 2);
      expect(await _balance(card), const Money(98000, _usd));
    });

    test('deleting a return reopens the debt; undo closes it', () async {
      final card = await _wallet('Card');
      final debt = await _debtOf((await _gave(card, 5000)).getOrThrow().id);
      final ret = (await _got(card, 5000)).getOrThrow();
      expect((await _summary(debt.id)).isOpen, isFalse);

      await transactions.softDelete(ret.id);
      final reopened = await _summary(debt.id);
      expect(reopened.isOpen, isTrue);
      expect(reopened.debt.closedAt, isNull);
      expect(reopened.debt.closeReason, isNull);

      await transactions.restore(ret.id);
      expect((await _summary(debt.id)).isOpen, isFalse);
    });

    test('Debt sheet delete = principal cascade, with undo', () async {
      final card = await _wallet('Card');
      final debt = await _debtOf((await _gave(card, 5000)).getOrThrow().id);
      await _got(card, 1000);

      final outcome = (await debts.delete(debt.id)).getOrThrow();
      expect(outcome.transactionsDeleted, 2);
      expect(await _balance(card), const Money(100000, _usd));

      await debts.restore(debt.id, outcome.deletedAtMs);
      expect((await _summary(debt.id)).remaining.minor, 4000);
      expect(await _balance(card), const Money(96000, _usd));
    });

    test('wallet delete keeps the debt and its payments', () async {
      final card = await _wallet('Card');
      final cash = await _wallet('Cash');
      final debt = await _debtOf((await _gave(card, 5000)).getOrThrow().id);
      await _got(cash, 2000);

      await wallets.softDelete(card.id);
      final s = await _summary(debt.id);
      expect(s.remaining.minor, 3000, reason: 'the person still owes it');
      expect(await _count('SELECT COUNT(*) FROM debt_payments WHERE deleted_at IS NULL'), 1);
      final details = (await debts.byId(debt.id, base: _usd)).getOrThrow();
      expect(details.principalWalletDeleted, isTrue);
      final overview = (await debts.overview(base: _usd, now: DateTime(2026, 3, 15))).getOrThrow();
      expect(overview.openLent.single.debt.id, debt.id);
    });
  });

  group('analytics exclusions', () {
    test('Progress and tag sums ignore debt money', () async {
      final card = await _wallet('Card');
      await transactions.create(
        TransactionDraft.expense(
          walletId: card.id,
          amount: const Money(1000, _usd),
          description: '',
          tags: const ['food'],
          date: DateTime(2026, 3, 2, 12),
          repeat: RepeatFrequency.never,
        ),
      );
      await _gave(card, 5000, day: 3, tags: ['food']);
      await _got(card, 5000, day: 4);

      final progress = (await ProgressRepository(sqlite: sqlite).load(
        granularity: ProgressGranularity.month,
        target: _usd,
        now: DateTime(2026, 3, 15),
      ))
          .getOrThrow();
      expect(progress.current.expense.minor, 1000);
      expect(progress.current.income.minor, 0);
      expect(progress.expenseByTag.single.amount.minor, 1000);

      final food = (await sqlite.db.query('tags', where: "normalized_name = 'food'")).single['id']! as String;
      final stats = (await tags.statsOf(food, _usd)).getOrThrow();
      expect(stats.expense.minor, 1000);
      final perWallet = (await tags.walletsOfTag(food)).getOrThrow();
      expect(perWallet.single.outMinor, 1000);
    });
  });

  group('people and overview', () {
    test('overview: sides, overdue first, base totals with cached rates', () async {
      final now = DateTime(2026, 3, 15);
      await debts.createWithoutMoney(DebtDraft(
        person: const PersonRef.create('Sara'),
        direction: DebtDirection.borrowed,
        principal: const Money(2000, _eur),
        openedAt: DateTime(2026, 3, 1),
      ));
      final later = (await debts.createWithoutMoney(DebtDraft(
        person: _ahmed,
        direction: DebtDirection.lent,
        principal: const Money(5000, _usd),
        openedAt: DateTime(2026, 3, 2),
        dueDate: DateTime(2026, 4, 1),
      )))
          .getOrThrow();
      final overdue = (await debts.createWithoutMoney(DebtDraft(
        person: _ahmed,
        direction: DebtDirection.lent,
        principal: const Money(1000, _usd),
        openedAt: DateTime(2026, 3, 1),
        dueDate: DateTime(2026, 3, 14),
      )))
          .getOrThrow();

      var o = (await debts.overview(base: _usd, now: now)).getOrThrow();
      expect(o.openLent.map((s) => s.debt.id), [overdue.id, later.id]);
      expect(o.overdueCount, 1);
      expect(o.owedToMeBase, const Money(6000, _usd));
      expect(o.iOweBase, const Money(0, _usd));
      expect(o.incomplete, isTrue, reason: 'EUR has no cached rate');

      fx.rates[(_eur, _usd)] = 1.1;
      o = (await debts.overview(base: _usd, now: now)).getOrThrow();
      expect(o.iOweBase, const Money(2200, _usd));
      expect(o.incomplete, isFalse);

      final people = (await debts.searchPeople('', base: _usd)).getOrThrow();
      expect(people.map((p) => p.person.name), containsAll(['Ahmed', 'Sara']));
      final ahmed = people.firstWhere((p) => p.person.name == 'Ahmed');
      expect(ahmed.balance.owedToMe, {_usd: 6000});
    });

    test('rename into an existing name merges; people with debts cannot be deleted', () async {
      final card = await _wallet('Card');
      await _gave(card, 100);
      await _gave(card, 200, person: const PersonRef.create('Sara'));
      final sara = (await debts.searchPeople('sara', base: _usd)).getOrThrow().single.person;

      final survivor = (await debts.renamePerson(sara.id, 'AHMED')).getOrThrow();
      expect(survivor.name, 'Ahmed');
      expect(await _count('SELECT COUNT(*) FROM people WHERE deleted_at IS NULL'), 1);
      expect(await _count('SELECT COUNT(DISTINCT person_id) FROM debts'), 1);

      expect((await debts.deletePerson(survivor.id)).tryGetError(), isA<PersonHasDebtsFailure>());
    });
  });
}
