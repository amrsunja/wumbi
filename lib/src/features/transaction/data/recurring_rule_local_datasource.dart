import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/local/database/sqlite/sqlite_config.dart';
import 'models/recurring_rule_model.dart';

class RecurringRuleLocalDatasource {
  const RecurringRuleLocalDatasource();

  static const _t = SQLiteConfig.recurringRulesTable;

  Future<void> insert(DatabaseExecutor db, RecurringRuleModel rule) => db.insert(_t, rule.toRow());

  Future<void> update(DatabaseExecutor db, RecurringRuleModel rule) => db.update(
        _t,
        rule.toRow(),
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [rule.id],
      );

  Future<RecurringRuleModel?> byId(DatabaseExecutor db, String id) async {
    final rows = await db.query(_t, where: '${SQLiteConfig.id} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return RecurringRuleModel.fromRow(rows.first);
  }

  /// B10 — due rules.
  Future<List<RecurringRuleModel>> due(DatabaseExecutor db, int nowMs) async {
    final rows = await db.query(
      _t,
      where: '${SQLiteConfig.ruleIsActive} = 1 AND ${SQLiteConfig.deletedAt} IS NULL '
          'AND ${SQLiteConfig.ruleNextOccurrence} <= ?',
      whereArgs: [nowMs],
      orderBy: SQLiteConfig.ruleNextOccurrence,
    );
    return rows.map(RecurringRuleModel.fromRow).toList();
  }

  /// Rules touching a wallet (as target, source or destination), not deleted.
  Future<List<RecurringRuleModel>> forWallet(DatabaseExecutor db, String walletId, {bool activeOnly = false}) async {
    final rows = await db.query(
      _t,
      where: '${SQLiteConfig.deletedAt} IS NULL '
          '${activeOnly ? 'AND ${SQLiteConfig.ruleIsActive} = 1 ' : ''}'
          'AND (${SQLiteConfig.txWalletId} = ?1 OR ${SQLiteConfig.txFromWalletId} = ?1 OR ${SQLiteConfig.txToWalletId} = ?1)',
      whereArgs: [walletId],
      orderBy: '${SQLiteConfig.ruleIsActive} DESC, ${SQLiteConfig.ruleNextOccurrence}',
    );
    return rows.map(RecurringRuleModel.fromRow).toList();
  }

  /// Every non-deleted rule, active first then soonest due.
  Future<List<RecurringRuleModel>> all(DatabaseExecutor db) async {
    final rows = await db.query(
      _t,
      where: '${SQLiteConfig.deletedAt} IS NULL',
      orderBy: '${SQLiteConfig.ruleIsActive} DESC, ${SQLiteConfig.ruleNextOccurrence}',
    );
    return rows.map(RecurringRuleModel.fromRow).toList();
  }

  /// Active rules per wallet id (dashboard "N subscriptions" captions).
  Future<Map<String, int>> activeCountByWallet(DatabaseExecutor db) async {
    final rows = await db.rawQuery('''
      SELECT w AS wallet_id, COUNT(*) AS c FROM (
        SELECT ${SQLiteConfig.txWalletId} AS w FROM $_t
          WHERE ${SQLiteConfig.deletedAt} IS NULL AND ${SQLiteConfig.ruleIsActive} = 1 AND ${SQLiteConfig.txWalletId} IS NOT NULL
        UNION ALL
        SELECT ${SQLiteConfig.txFromWalletId} FROM $_t
          WHERE ${SQLiteConfig.deletedAt} IS NULL AND ${SQLiteConfig.ruleIsActive} = 1 AND ${SQLiteConfig.txFromWalletId} IS NOT NULL
        UNION ALL
        SELECT ${SQLiteConfig.txToWalletId} FROM $_t
          WHERE ${SQLiteConfig.deletedAt} IS NULL AND ${SQLiteConfig.ruleIsActive} = 1 AND ${SQLiteConfig.txToWalletId} IS NOT NULL
      ) GROUP BY w
    ''');
    return {for (final r in rows) r['wallet_id'] as String: (r['c'] as int?) ?? 0};
  }

  Future<void> setActive(DatabaseExecutor db, String id, bool active, int now) => db.update(
        _t,
        {SQLiteConfig.ruleIsActive: active ? 1 : 0, SQLiteConfig.updatedAt: now},
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [id],
      );

  Future<void> softDelete(DatabaseExecutor db, String id, int now) => db.update(
        _t,
        {SQLiteConfig.deletedAt: now, SQLiteConfig.ruleIsActive: 0, SQLiteConfig.updatedAt: now},
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [id],
      );
}
