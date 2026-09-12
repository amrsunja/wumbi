import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' show DatabaseExecutor;

import '../../../core/errors/exceptions/domain/domain_exceptions.dart';
import '../../../core/errors/failures/failures.dart';
import '../../../core/local/database/sqlite/sqlite_services.dart';
import '../../../core/providers/data/db_revision_provider.dart';
import '../../../core/providers/local/sqlite_database_provider.dart';
import '../../../core/recurring/recurring_schedule.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/repeat_frequency.dart';
import '../../../core/utils/enums/transaction_status.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/typedefs.dart';
import '../../tag/data/tag_repository.dart';
import 'models/recurring_rule_model.dart';
import 'models/transaction_filter.dart';
import 'models/transaction_model.dart';
import 'recurring_rule_local_datasource.dart';
import 'transaction_local_datasource.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(
    sqlite: ref.read(sqliteDataBaseProvider),
    tags: ref.read(tagRepositoryProvider),
    onWrite: ref.read(dbRevisionBumperProvider),
  ),
);

/// Transaction write, tag links and (optionally) rule creation happen in one
/// SQLite transaction (spec 5.10).
class TransactionRepository {
  TransactionRepository({
    required this.sqlite,
    required this.tags,
    required this.onWrite,
    this.datasource = const TransactionLocalDatasource(),
    this.rules = const RecurringRuleLocalDatasource(),
  });

  final SQLiteServices sqlite;
  final TagRepository tags;
  final TransactionLocalDatasource datasource;
  final RecurringRuleLocalDatasource rules;
  final void Function() onWrite;

  // ----------------------------------------------------------------- reads

  /// One page of rows with their tags resolved (one extra query per page).
  Future<SuccessOrError<List<TransactionRow>>> pageForWallet(
    String walletId, {
    int limit = kTransactionsPageSize,
    int offset = 0,
    TransactionFilter filter = TransactionFilter.none,
    TransactionSort sort = TransactionSort.dateDesc,
  }) =>
      Failure.exceptionsCatcher(() async {
        final db = sqlite.db;
        final rows = await datasource.pageForWallet(
          db,
          walletId,
          limit: limit,
          offset: offset,
          filter: filter,
          sort: sort,
        );
        return _withTags(db, rows);
      });

  /// Every transaction carrying a tag (tag detail page), newest first.
  Future<SuccessOrError<List<TransactionRow>>> pageForTag(
    String tagId, {
    int limit = kTransactionsPageSize,
    int offset = 0,
  }) =>
      Failure.exceptionsCatcher(() async {
        final db = sqlite.db;
        final rows = await datasource.pageForTag(db, tagId, limit: limit, offset: offset);
        return _withTags(db, rows);
      });

  /// Global search (`/search`) across every wallet. Blank queries return
  /// nothing rather than the whole ledger.
  Future<SuccessOrError<List<TransactionRow>>> search(
    String query, {
    int limit = kTransactionsPageSize,
    int offset = 0,
  }) =>
      Failure.exceptionsCatcher(() async {
        final trimmed = query.trim();
        if (trimmed.isEmpty) return const <TransactionRow>[];
        final db = sqlite.db;
        final rows = await datasource.search(db, trimmed, limit: limit, offset: offset);
        return _withTags(db, rows);
      });

  Future<List<TransactionRow>> _withTags(DatabaseExecutor db, List<TransactionRow> rows) async {
    if (rows.isEmpty) return rows;
    final tagsByTx = await tags.datasource.tagsOfTransactions(db, rows.map((r) => r.id).toList());
    return rows.map((r) => r.copyWith(tags: tagsByTx[r.id] ?? const [])).toList();
  }

  Future<SuccessOrError<TransactionWithTags>> byId(String id) =>
      Failure.exceptionsCatcher(() async {
        final db = sqlite.db;
        final tx = await datasource.byId(db, id);
        if (tx == null || tx.deletedAt != null) throw const NotFoundException('transaction');
        final tagModels = await tags.datasource.tagsOfTransaction(db, id);
        RepeatFrequency? frequency;
        if (tx.recurringRuleId != null) {
          frequency = (await rules.byId(db, tx.recurringRuleId!))?.frequency;
        }
        return TransactionWithTags(
          transaction: tx,
          tags: tagModels.map((t) => t.displayName).toList(),
          ruleFrequency: frequency,
        );
      });

  Future<SuccessOrError<List<RecurringRuleModel>>> rulesForWallet(String walletId) =>
      Failure.exceptionsCatcher(() => rules.forWallet(sqlite.db, walletId));

  /// Every non-deleted rule (subscriptions page), active first.
  Future<SuccessOrError<List<RecurringRuleModel>>> allRules() =>
      Failure.exceptionsCatcher(() => rules.all(sqlite.db));

  Future<SuccessOrError<RecurringRuleWithTags>> ruleById(String id) => Failure.exceptionsCatcher(() async {
        final db = sqlite.db;
        final rule = await rules.byId(db, id);
        if (rule == null || rule.deletedAt != null) throw const NotFoundException('rule');
        final tagModels = await tags.datasource.tagsOfRule(db, id);
        return RecurringRuleWithTags(rule: rule, tags: tagModels.map((t) => t.displayName).toList());
      });

  // -------------------------------------------------------------- upcoming

  /// Promote `upcoming` rows whose date has arrived. Returns how many posted.
  Future<int> postDueUpcoming({DateTime? now}) async {
    try {
      final posted = await datasource.postDue(sqlite.db, (now ?? DateTime.now()).epochMs);
      if (posted > 0) onWrite();
      return posted;
    } catch (_) {
      return 0;
    }
  }

  /// Earliest pending upcoming date, for scheduling the next promotion.
  Future<DateTime?> nextUpcomingDate() async {
    try {
      return await datasource.nextUpcomingDate(sqlite.db);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------- writes

  Future<SuccessOrError<TransactionModel>> create(TransactionDraft draft) =>
      Failure.exceptionsCatcher(() async {
        _validate(draft);
        final now = DateTime.now();
        final nowMillis = nowMs();

        final ruleId = draft.repeat.isNever ? null : newId();
        final tx = _toModel(
          draft,
          id: newId(),
          now: now,
          recurringRuleId: ruleId,
          status: TransactionStatus.forDate(draft.date, now: now),
        );

        await sqlite.db.transaction((txn) async {
          if (ruleId != null) {
            await rules.insert(txn, _toRule(draft, tx, ruleId, now));
          }
          await datasource.insert(txn, tx);
          final tagIds = await tags.attachToTransaction(txn, tx.id, draft.tags, nowMillis);
          if (ruleId != null) {
            await tags.attachToRule(txn, ruleId, tagIds, nowMillis);
          }
        });
        onWrite();
        return tx;
      });

  /// Edit mode: income ↔ expense may be switched; a transfer stays a transfer
  /// (and vice versa). The rule, if any, is not edited.
  Future<SuccessOrError<TransactionModel>> update(String id, TransactionDraft draft) =>
      Failure.exceptionsCatcher(() async {
        _validate(draft);
        final now = DateTime.now();
        late TransactionModel updated;
        await sqlite.db.transaction((txn) async {
          final existing = await datasource.byId(txn, id);
          if (existing == null || existing.deletedAt != null) {
            throw const NotFoundException('transaction');
          }
          if (existing.isTransfer != (draft.type == TransactionType.transfer)) {
            throw const ValidationException('type', 'Transfer type cannot be changed');
          }
          // Status follows the (possibly new) date, except that rule-generated
          // occurrences always stay posted.
          updated = _toModel(
            draft,
            id: id,
            now: now,
            createdAt: existing.createdAt,
            recurringRuleId: existing.recurringRuleId,
            status: existing.recurringRuleId != null
                ? TransactionStatus.posted
                : TransactionStatus.forDate(draft.date, now: now),
          );
          await datasource.update(txn, updated);
          await tags.syncTransactionTags(txn, id, draft.tags, nowMs());
        });
        onWrite();
        return updated;
      });

  /// Swipe-delete / edit-mode delete. `stopRule` also deactivates the rule
  /// that generated the transaction ("Delete and stop repeating").
  Future<SuccessOrError<void>> softDelete(String id, {bool stopRule = false}) =>
      Failure.exceptionsCatcher(() async {
        final now = nowMs();
        await sqlite.db.transaction((txn) async {
          final existing = await datasource.byId(txn, id);
          if (existing == null) throw const NotFoundException('transaction');
          await datasource.softDelete(txn, id, now);
          if (stopRule && existing.recurringRuleId != null) {
            await rules.setActive(txn, existing.recurringRuleId!, false, now);
          }
        });
        onWrite();
      });

  /// Undo: links in `transaction_tags` were never removed, so nothing else to restore.
  Future<SuccessOrError<void>> restore(String id) => Failure.exceptionsCatcher(() async {
        await datasource.restore(sqlite.db, id, nowMs());
        onWrite();
      });

  Future<SuccessOrError<void>> setRuleActive(String ruleId, bool active) =>
      Failure.exceptionsCatcher(() async {
        await rules.setActive(sqlite.db, ruleId, active, nowMs());
        onWrite();
      });

  /// Soft delete a rule; existing occurrences stay.
  Future<SuccessOrError<void>> deleteRule(String ruleId) => Failure.exceptionsCatcher(() async {
        await rules.softDelete(sqlite.db, ruleId, nowMs());
        onWrite();
      });

  /// Subscriptions page: edit a rule in place. Amount / description /
  /// frequency / wallet / tags change; the type is fixed. `next_occurrence`
  /// is re-derived from `start_date` when the frequency changes. Existing
  /// occurrences are untouched.
  Future<SuccessOrError<RecurringRuleModel>> updateRule(String ruleId, RecurringRuleDraft draft) =>
      Failure.exceptionsCatcher(() async {
        if (draft.description.length > kMaxDescriptionLength) {
          throw const ValidationException('description');
        }
        if ((draft.tags?.length ?? 0) > kMaxTagsPerTransaction) {
          throw const ValidationException('tags', 'Up to $kMaxTagsPerTransaction tags');
        }
        final now = DateTime.now();
        late RecurringRuleModel updated;
        await sqlite.db.transaction((txn) async {
          final existing = await rules.byId(txn, ruleId);
          if (existing == null || existing.deletedAt != null) throw const NotFoundException('rule');

          var next = existing.copyWith(description: draft.description.trim(), updatedAt: now);
          if (existing.isTransfer) {
            final from = draft.fromWalletId ?? existing.fromWalletId;
            final to = draft.toWalletId ?? existing.toWalletId;
            if (from == to) throw const ValidationException('toWalletId');
            final sent = draft.amountMinor ?? existing.fromAmountMinor ?? 0;
            final received = draft.receivedAmountMinor ?? existing.toAmountMinor ?? sent;
            if (sent <= 0 || received < 0) throw const ValidationException('amount', 'Enter an amount');
            next = next.copyWith(
              fromWalletId: from,
              toWalletId: to,
              fromAmountMinor: sent,
              toAmountMinor: received,
              exchangeRate: draft.exchangeRate ?? existing.exchangeRate,
            );
          } else {
            final amount = draft.amountMinor ?? existing.amountMinor ?? 0;
            if (amount <= 0) throw const ValidationException('amount', 'Enter an amount');
            next = next.copyWith(walletId: draft.walletId ?? existing.walletId, amountMinor: amount);
          }
          if (draft.frequency != null && draft.frequency != existing.frequency) {
            // Keep the anchor day, re-derive the next due date after today.
            final f = draft.frequency!;
            var count = 1;
            var candidate = advance(existing.startDate, f, count);
            while (!candidate.isAfter(now) && count < 5000) {
              candidate = advance(existing.startDate, f, ++count);
            }
            next = next.copyWith(frequency: f, occurrenceCount: count, nextOccurrence: candidate);
          }
          await rules.update(txn, next);
          if (draft.tags != null) {
            await tags.syncRuleTags(txn, ruleId, draft.tags!, nowMs());
          }
          updated = next;
        });
        onWrite();
        return updated;
      });

  // --------------------------------------------------------------- helpers

  void _validate(TransactionDraft draft) {
    if (draft.description.length > kMaxDescriptionLength) {
      throw const ValidationException('description');
    }
    if (draft.tags.length > kMaxTagsPerTransaction) {
      throw const ValidationException('tags', 'Up to $kMaxTagsPerTransaction tags');
    }
    switch (draft) {
      case IncomeDraft(:final amount):
      case ExpenseDraft(:final amount):
        if (amount.minor <= 0) throw const ValidationException('amount', 'Enter an amount');
      case TransferDraft(:final sent, :final received, :final fromWalletId, :final toWalletId):
        if (sent.minor <= 0 || received.minor < 0) {
          throw const ValidationException('amount', 'Enter an amount');
        }
        if (fromWalletId == toWalletId) throw const ValidationException('toWalletId');
    }
  }

  TransactionModel _toModel(
    TransactionDraft draft, {
    required String id,
    required DateTime now,
    DateTime? createdAt,
    String? recurringRuleId,
    TransactionStatus status = TransactionStatus.posted,
  }) {
    final original = draft.original;
    final base = TransactionModel(
      id: id,
      status: status,
      type: draft.type,
      currency: switch (draft) {
        IncomeDraft(:final amount) => amount.currency,
        ExpenseDraft(:final amount) => amount.currency,
        TransferDraft(:final sent) => sent.currency,
      },
      originalAmountMinor: original?.minor,
      originalCurrency: original?.currency,
      exchangeRate: draft.rate,
      description: draft.description.trim(),
      transactionDate: draft.date,
      recurringRuleId: recurringRuleId,
      createdAt: createdAt ?? now,
      updatedAt: now,
    );
    return switch (draft) {
      IncomeDraft(:final walletId, :final amount) => base.copyWith(walletId: walletId, amountMinor: amount.minor),
      ExpenseDraft(:final walletId, :final amount) => base.copyWith(walletId: walletId, amountMinor: amount.minor),
      TransferDraft(:final fromWalletId, :final toWalletId, :final sent, :final received) => base.copyWith(
          fromWalletId: fromWalletId,
          toWalletId: toWalletId,
          fromAmountMinor: sent.minor,
          toAmountMinor: received.minor,
        ),
    };
  }

  RecurringRuleModel _toRule(TransactionDraft draft, TransactionModel first, String ruleId, DateTime now) =>
      RecurringRuleModel(
        id: ruleId,
        type: first.type,
        walletId: first.walletId,
        amountMinor: first.amountMinor,
        currency: first.currency,
        fromWalletId: first.fromWalletId,
        toWalletId: first.toWalletId,
        fromAmountMinor: first.fromAmountMinor,
        toAmountMinor: first.toAmountMinor,
        exchangeRate: first.isTransfer ? first.exchangeRate : null,
        description: first.description,
        frequency: draft.repeat,
        startDate: first.transactionDate,
        nextOccurrence: advance(first.transactionDate, draft.repeat, 1),
        occurrenceCount: 1,
        createdAt: now,
        updatedAt: now,
      );
}
