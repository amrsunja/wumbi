import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../core/utils/enums/transaction_status.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../transaction/data/models/recurring_rule_model.dart';
import '../../tag/data/tag_sql.dart';
import 'models/budget_model.dart';

/// Per-currency sum of one bucket (rollover / suggestion history).
typedef BudgetBucketSum = ({int bucket, String currencyCode, int totalMinor});

/// Raw queries for budgets, their scope links and the scope aggregates
/// (spec B&D Appendix A.2). No business rules, no FX.
///
/// Scope filters take explicit wallet / tag id sets rather than a budget id,
/// so the same SQL serves saved budgets and the unsaved scope of the budget
/// form (limit suggestion). Empty set = no filter on that axis; tags match
/// with ANY via `EXISTS`, so a row with two matching tags counts once. A
/// parent tag also matches its nested tags (`food` covers `food/coffee`).
class BudgetLocalDatasource {
  const BudgetLocalDatasource();

  static const _b = SQLiteConfig.budgetsTable;
  static const _bw = SQLiteConfig.budgetWalletsTable;
  static const _bt = SQLiteConfig.budgetTagsTable;
  static const _t = SQLiteConfig.transactionsTable;
  static const _tt = SQLiteConfig.transactionTagsTable;
  static const _r = SQLiteConfig.recurringRulesTable;
  static const _rrt = SQLiteConfig.recurringRuleTagsTable;

  // ---------------------------------------------------------------- budgets

  Future<void> insert(DatabaseExecutor db, BudgetModel budget) => db.insert(_b, budget.toRow());

  Future<void> update(DatabaseExecutor db, BudgetModel budget) => db.update(
        _b,
        budget.toRow(),
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [budget.id],
      );

  Future<int> nextSortOrder(DatabaseExecutor db) async {
    final rows = await db.rawQuery('SELECT COALESCE(MAX(${SQLiteConfig.budgetSortOrder}), -1) + 1 FROM $_b');
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  /// Any budget (deleted or not) with its scope links.
  Future<BudgetModel?> byId(DatabaseExecutor db, String id) async {
    final rows = await db.query(_b, where: '${SQLiteConfig.id} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return (await _withLinks(db, [BudgetModel.fromRow(rows.first)])).single;
  }

  /// Live budgets with their scope links, creation order.
  Future<List<BudgetModel>> listLive(DatabaseExecutor db) async {
    final rows = await db.query(
      _b,
      where: '${SQLiteConfig.deletedAt} IS NULL',
      orderBy: '${SQLiteConfig.budgetSortOrder}, ${SQLiteConfig.createdAt}',
    );
    return _withLinks(db, rows.map(BudgetModel.fromRow).toList());
  }

  /// B4 — live budgets whose scope contains transaction [transactionId]
  /// (wallet scope empty or containing its wallet; tag scope empty or
  /// intersecting its tags).
  Future<List<BudgetModel>> matchingTransaction(DatabaseExecutor db, String transactionId) async {
    final rows = await db.rawQuery('''
      SELECT b.* FROM $_b b, $_t t
      WHERE t.${SQLiteConfig.id} = ?1 AND b.${SQLiteConfig.deletedAt} IS NULL
        AND (NOT EXISTS (SELECT 1 FROM $_bw bw WHERE bw.${SQLiteConfig.bwBudgetId} = b.${SQLiteConfig.id})
             OR EXISTS (SELECT 1 FROM $_bw bw WHERE bw.${SQLiteConfig.bwBudgetId} = b.${SQLiteConfig.id}
                                              AND bw.${SQLiteConfig.bwWalletId} = t.${SQLiteConfig.txWalletId}))
        AND (NOT EXISTS (SELECT 1 FROM $_bt bt WHERE bt.${SQLiteConfig.btBudgetId} = b.${SQLiteConfig.id})
             OR EXISTS (SELECT 1 FROM $_bt bt
                        JOIN ${SQLiteConfig.tagsTable} tp ON tp.${SQLiteConfig.id} = bt.${SQLiteConfig.btTagId}
                        JOIN ${SQLiteConfig.tagsTable} tc ON tc.${SQLiteConfig.deletedAt} IS NULL AND ${TagSql.selfOrDescendant('tc', 'tp')}
                        JOIN $_tt tt ON tt.${SQLiteConfig.ttTagId} = tc.${SQLiteConfig.id}
                        WHERE bt.${SQLiteConfig.btBudgetId} = b.${SQLiteConfig.id}
                          AND tt.${SQLiteConfig.ttTransactionId} = t.${SQLiteConfig.id}))
      ORDER BY b.${SQLiteConfig.budgetSortOrder}, b.${SQLiteConfig.createdAt}
    ''', [transactionId]);
    return _withLinks(db, rows.map(BudgetModel.fromRow).toList());
  }

  Future<void> softDelete(DatabaseExecutor db, String id, int now) => db.update(
        _b,
        {SQLiteConfig.deletedAt: now, SQLiteConfig.updatedAt: now},
        where: '${SQLiteConfig.id} = ? AND ${SQLiteConfig.deletedAt} IS NULL',
        whereArgs: [id],
      );

  /// Undo of a delete stamped [deletedAt]. Links were never removed.
  Future<int> restore(DatabaseExecutor db, String id, int deletedAt, int now) => db.update(
        _b,
        {SQLiteConfig.deletedAt: null, SQLiteConfig.updatedAt: now},
        where: '${SQLiteConfig.id} = ? AND ${SQLiteConfig.deletedAt} = ?',
        whereArgs: [id, deletedAt],
      );

  // ------------------------------------------------------------ scope links

  /// Replace the wallet scope of [budgetId] with [walletIds].
  Future<void> setWallets(DatabaseExecutor db, String budgetId, Set<String> walletIds, int now) async {
    await db.delete(_bw, where: '${SQLiteConfig.bwBudgetId} = ?', whereArgs: [budgetId]);
    for (final id in walletIds) {
      await db.insert(_bw, {
        SQLiteConfig.bwBudgetId: budgetId,
        SQLiteConfig.bwWalletId: id,
        SQLiteConfig.createdAt: now,
      });
    }
  }

  /// Replace the tag scope of [budgetId] with [tagIds].
  Future<void> setTags(DatabaseExecutor db, String budgetId, Set<String> tagIds, int now) async {
    await db.delete(_bt, where: '${SQLiteConfig.btBudgetId} = ?', whereArgs: [budgetId]);
    for (final id in tagIds) {
      await db.insert(_bt, {
        SQLiteConfig.btBudgetId: budgetId,
        SQLiteConfig.btTagId: id,
        SQLiteConfig.createdAt: now,
      });
    }
  }

  /// Drops every link to [walletId]; returns the budgets that had one.
  Future<List<String>> unlinkWallet(DatabaseExecutor db, String walletId) async {
    final rows = await db.query(
      _bw,
      columns: [SQLiteConfig.bwBudgetId],
      where: '${SQLiteConfig.bwWalletId} = ?',
      whereArgs: [walletId],
    );
    await db.delete(_bw, where: '${SQLiteConfig.bwWalletId} = ?', whereArgs: [walletId]);
    return rows.map((r) => r[SQLiteConfig.bwBudgetId] as String).toList();
  }

  /// Budgets linked to [tagId] (read before a tag delete drops the links).
  Future<List<String>> budgetIdsWithTag(DatabaseExecutor db, String tagId) async {
    final rows = await db.query(
      _bt,
      columns: [SQLiteConfig.btBudgetId],
      where: '${SQLiteConfig.btTagId} = ?',
      whereArgs: [tagId],
    );
    return rows.map((r) => r[SQLiteConfig.btBudgetId] as String).toList();
  }

  /// Soft-deletes those of [budgetIds] left with no wallet link — a budget
  /// must never silently widen to "all wallets". Returns how many.
  Future<int> softDeleteWithoutWallets(DatabaseExecutor db, List<String> budgetIds, int now) =>
      _softDeleteWithoutLinks(db, budgetIds, _bw, SQLiteConfig.bwBudgetId, now);

  /// Same for tags: never widen to "any tag".
  Future<int> softDeleteWithoutTags(DatabaseExecutor db, List<String> budgetIds, int now) =>
      _softDeleteWithoutLinks(db, budgetIds, _bt, SQLiteConfig.btBudgetId, now);

  Future<int> _softDeleteWithoutLinks(
    DatabaseExecutor db,
    List<String> budgetIds,
    String linkTable,
    String linkBudgetCol,
    int now,
  ) async {
    final ids = budgetIds.toSet().toList();
    if (ids.isEmpty) return 0;
    final ph = List.filled(ids.length, '?').join(',');
    return db.rawUpdate('''
      UPDATE $_b SET ${SQLiteConfig.deletedAt} = ?, ${SQLiteConfig.updatedAt} = ?
      WHERE ${SQLiteConfig.id} IN ($ph) AND ${SQLiteConfig.deletedAt} IS NULL
        AND NOT EXISTS (SELECT 1 FROM $linkTable l WHERE l.$linkBudgetCol = $_b.${SQLiteConfig.id})
    ''', [now, now, ...ids]);
  }

  // --------------------------------------------------------------- aggregates

  /// B1 — Σ expense amounts per currency in `[start, end)` for a scope.
  /// Posted or upcoming per [status]; transfers and debt money never count.
  Future<Map<String, int>> sumsByCurrency(
    DatabaseExecutor db, {
    required Set<String> walletIds,
    required Set<String> tagIds,
    required DateTime start,
    required DateTime end,
    required TransactionStatus status,
  }) async {
    final args = <Object?>[status.dbValue, start.epochMs, end.epochMs];
    final scope = _txScope(walletIds, tagIds, args);
    final rows = await db.rawQuery('''
      SELECT t.${SQLiteConfig.txCurrency} AS currency, SUM(t.${SQLiteConfig.txAmountMinor}) AS total
      FROM $_t t
      WHERE t.${SQLiteConfig.deletedAt} IS NULL
        AND t.${SQLiteConfig.txStatus} = ?
        AND t.${SQLiteConfig.txType} = '${TransactionType.expense.dbValue}'
        AND t.${SQLiteConfig.txDebtRole} IS NULL
        AND t.${SQLiteConfig.txDate} >= ? AND t.${SQLiteConfig.txDate} < ?
        $scope
      GROUP BY t.${SQLiteConfig.txCurrency}
    ''', args);
    return {for (final r in rows) r['currency'] as String: (r['total'] as int?) ?? 0};
  }

  /// B2 — posted expense sums per bucket × currency over consecutive periods
  /// whose edges are [boundaries] (oldest first, `bucketCount + 1` edges).
  /// Same `CASE` bucketing as `ProgressLocalDatasource.sumsByPeriod`.
  Future<List<BudgetBucketSum>> bucketSums(
    DatabaseExecutor db, {
    required Set<String> walletIds,
    required Set<String> tagIds,
    required List<DateTime> boundaries,
  }) async {
    final edges = boundaries.map((d) => d.epochMs).toList();
    final buckets = edges.length - 1;
    if (buckets < 1) return const [];

    final bucketExpr = StringBuffer();
    if (buckets == 1) {
      bucketExpr.write('0');
    } else {
      bucketExpr.write('CASE');
      for (var i = 1; i < buckets; i++) {
        bucketExpr.write(' WHEN t.${SQLiteConfig.txDate} < ? THEN ${i - 1}');
      }
      bucketExpr.write(' ELSE ${buckets - 1} END');
    }

    // Argument order follows the textual order of the `?` marks.
    final args = <Object?>[
      for (var i = 1; i < buckets; i++) edges[i],
      TransactionStatus.posted.dbValue,
      edges.first,
      edges.last,
    ];
    final scope = _txScope(walletIds, tagIds, args);
    final rows = await db.rawQuery('''
      SELECT $bucketExpr AS bucket,
             t.${SQLiteConfig.txCurrency} AS currency,
             SUM(t.${SQLiteConfig.txAmountMinor}) AS total
      FROM $_t t
      WHERE t.${SQLiteConfig.deletedAt} IS NULL
        AND t.${SQLiteConfig.txStatus} = ?
        AND t.${SQLiteConfig.txType} = '${TransactionType.expense.dbValue}'
        AND t.${SQLiteConfig.txDebtRole} IS NULL
        AND t.${SQLiteConfig.txDate} >= ? AND t.${SQLiteConfig.txDate} < ?
        $scope
      GROUP BY bucket, currency
    ''', args);
    return rows
        .map((r) => (
              bucket: (r['bucket'] as int?) ?? 0,
              currencyCode: r['currency'] as String,
              totalMinor: (r['total'] as int?) ?? 0,
            ))
        .toList();
  }

  /// B3 — active expense subscriptions in scope (occurrences are enumerated
  /// in Dart with the engine's own step).
  Future<List<RecurringRuleModel>> plannedRules(
    DatabaseExecutor db, {
    required Set<String> walletIds,
    required Set<String> tagIds,
  }) async {
    final args = <Object?>[];
    final where = StringBuffer(
      'r.${SQLiteConfig.deletedAt} IS NULL AND r.${SQLiteConfig.ruleIsActive} = 1 '
      "AND r.${SQLiteConfig.txType} = '${TransactionType.expense.dbValue}'",
    );
    if (walletIds.isNotEmpty) {
      args.addAll(walletIds);
      where.write(' AND r.${SQLiteConfig.txWalletId} IN (${_ph(walletIds.length)})');
    }
    if (tagIds.isNotEmpty) {
      args.addAll(tagIds);
      where.write(
        ' AND EXISTS (SELECT 1 FROM $_rrt rt WHERE rt.${SQLiteConfig.rrtRuleId} = r.${SQLiteConfig.id} '
        'AND rt.${SQLiteConfig.rrtTagId} IN (${TagSql.expandIds(_ph(tagIds.length))}))',
      );
    }
    final rows = await db.rawQuery('SELECT r.* FROM $_r r WHERE $where', args);
    return rows.map(RecurringRuleModel.fromRow).toList();
  }

  // ---------------------------------------------------------------- helpers

  /// Scope clauses for transaction alias `t`; appends their args.
  static String _txScope(Set<String> walletIds, Set<String> tagIds, List<Object?> args) {
    final sql = StringBuffer();
    if (walletIds.isNotEmpty) {
      args.addAll(walletIds);
      sql.write('AND t.${SQLiteConfig.txWalletId} IN (${_ph(walletIds.length)}) ');
    }
    if (tagIds.isNotEmpty) {
      args.addAll(tagIds);
      sql.write(
        'AND EXISTS (SELECT 1 FROM $_tt x WHERE x.${SQLiteConfig.ttTransactionId} = t.${SQLiteConfig.id} '
        'AND x.${SQLiteConfig.ttTagId} IN (${TagSql.expandIds(_ph(tagIds.length))}))',
      );
    }
    return sql.toString();
  }

  static String _ph(int n) => List.filled(n, '?').join(',');

  /// Two queries for any number of budgets.
  Future<List<BudgetModel>> _withLinks(DatabaseExecutor db, List<BudgetModel> budgets) async {
    if (budgets.isEmpty) return budgets;
    final ids = budgets.map((b) => b.id).toList();
    final ph = _ph(ids.length);
    final wallets = <String, Set<String>>{};
    for (final r in await db.query(_bw, where: '${SQLiteConfig.bwBudgetId} IN ($ph)', whereArgs: ids)) {
      wallets.putIfAbsent(r[SQLiteConfig.bwBudgetId] as String, () => {}).add(r[SQLiteConfig.bwWalletId] as String);
    }
    final tags = <String, Set<String>>{};
    for (final r in await db.query(_bt, where: '${SQLiteConfig.btBudgetId} IN ($ph)', whereArgs: ids)) {
      tags.putIfAbsent(r[SQLiteConfig.btBudgetId] as String, () => {}).add(r[SQLiteConfig.btTagId] as String);
    }
    return [
      for (final b in budgets) b.copyWith(walletIds: wallets[b.id] ?? const <String>{}, tagIds: tags[b.id] ?? const <String>{}),
    ];
  }
}
