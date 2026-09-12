import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../core/money/money.dart';
import 'models/wallet_model.dart';

/// Raw `sqflite` queries and row ↔ model mapping for wallets. No business rules.
class WalletLocalDatasource {
  const WalletLocalDatasource();

  static const _t = SQLiteConfig.walletsTable;
  static const _v = SQLiteConfig.walletBalancesView;

  /// B1 — active wallets with balances, creation order.
  Future<List<WalletSummary>> listActive(DatabaseExecutor db) async {
    final rows = await db.rawQuery('''
      SELECT w.*, b.${SQLiteConfig.balanceMinor}
      FROM $_t w JOIN $_v b ON b.${SQLiteConfig.balanceWalletId} = w.${SQLiteConfig.id}
      WHERE w.${SQLiteConfig.deletedAt} IS NULL
      ORDER BY w.${SQLiteConfig.walletSortOrder}, w.${SQLiteConfig.createdAt}
    ''');
    return rows.map(_summaryFromRow).toList();
  }

  Future<WalletSummary?> byId(DatabaseExecutor db, String id) async {
    final rows = await db.rawQuery('''
      SELECT w.*, b.${SQLiteConfig.balanceMinor}
      FROM $_t w JOIN $_v b ON b.${SQLiteConfig.balanceWalletId} = w.${SQLiteConfig.id}
      WHERE w.${SQLiteConfig.id} = ? AND w.${SQLiteConfig.deletedAt} IS NULL
      LIMIT 1
    ''', [id]);
    if (rows.isEmpty) return null;
    return _summaryFromRow(rows.first);
  }

  /// Also resolves soft-deleted wallets (names in transfer titles).
  Future<WalletModel?> rawById(DatabaseExecutor db, String id) async {
    final rows = await db.query(_t, where: '${SQLiteConfig.id} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return WalletModel.fromRow(rows.first);
  }

  /// B2
  Future<WalletModel?> primary(DatabaseExecutor db) async {
    final rows = await db.query(
      _t,
      where: '${SQLiteConfig.walletIsPrimary} = 1 AND ${SQLiteConfig.deletedAt} IS NULL',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WalletModel.fromRow(rows.first);
  }

  Future<int> countActive(DatabaseExecutor db) async {
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM $_t WHERE ${SQLiteConfig.deletedAt} IS NULL',
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<int> nextSortOrder(DatabaseExecutor db) async {
    final rows = await db.rawQuery(
      'SELECT COALESCE(MAX(${SQLiteConfig.walletSortOrder}), -1) + 1 AS n FROM $_t',
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<void> insert(DatabaseExecutor db, WalletModel wallet) =>
      db.insert(_t, wallet.toRow());

  Future<void> update(DatabaseExecutor db, WalletModel wallet) => db.update(
        _t,
        wallet.toRow(),
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [wallet.id],
      );

  /// B3 — clear all primaries.
  Future<void> clearPrimary(DatabaseExecutor db, int now) => db.update(
        _t,
        {SQLiteConfig.walletIsPrimary: 0, SQLiteConfig.updatedAt: now},
        where: '${SQLiteConfig.walletIsPrimary} = 1 AND ${SQLiteConfig.deletedAt} IS NULL',
      );

  Future<void> setSortOrder(DatabaseExecutor db, String id, int order, int now) => db.update(
        _t,
        {SQLiteConfig.walletSortOrder: order, SQLiteConfig.updatedAt: now},
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [id],
      );

  Future<void> setPrimary(DatabaseExecutor db, String id, int now) => db.update(
        _t,
        {SQLiteConfig.walletIsPrimary: 1, SQLiteConfig.updatedAt: now},
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [id],
      );

  /// B4 — currency lock check.
  Future<bool> hasTransactions(DatabaseExecutor db, String id) async {
    final rows = await db.rawQuery('''
      SELECT EXISTS(
        SELECT 1 FROM ${SQLiteConfig.transactionsTable}
        WHERE ${SQLiteConfig.deletedAt} IS NULL
          AND (${SQLiteConfig.txWalletId} = ?1 OR ${SQLiteConfig.txFromWalletId} = ?1 OR ${SQLiteConfig.txToWalletId} = ?1)
      ) AS e
    ''', [id]);
    return (Sqflite.firstIntValue(rows) ?? 0) == 1;
  }

  /// B5 — soft delete wallet + its income/expense transactions, deactivate rules.
  /// Returns the number of rules paused.
  Future<int> softDelete(DatabaseExecutor db, String id, int now) async {
    await db.update(
      _t,
      {SQLiteConfig.deletedAt: now, SQLiteConfig.updatedAt: now, SQLiteConfig.walletIsPrimary: 0},
      where: '${SQLiteConfig.id} = ?',
      whereArgs: [id],
    );
    await db.update(
      SQLiteConfig.transactionsTable,
      {SQLiteConfig.deletedAt: now, SQLiteConfig.updatedAt: now},
      where: '${SQLiteConfig.txWalletId} = ? AND ${SQLiteConfig.deletedAt} IS NULL',
      whereArgs: [id],
    );
    return db.update(
      SQLiteConfig.recurringRulesTable,
      {SQLiteConfig.ruleIsActive: 0, SQLiteConfig.updatedAt: now},
      where:
          '(${SQLiteConfig.txWalletId} = ?1 OR ${SQLiteConfig.txFromWalletId} = ?1 OR ${SQLiteConfig.txToWalletId} = ?1) '
          'AND ${SQLiteConfig.deletedAt} IS NULL AND ${SQLiteConfig.ruleIsActive} = 1',
      whereArgs: [id],
    );
  }

  /// Promote the lowest `sort_order` wallet when no primary is left.
  Future<void> promotePrimaryIfNeeded(DatabaseExecutor db, int now) => db.rawUpdate('''
      UPDATE $_t SET ${SQLiteConfig.walletIsPrimary} = 1, ${SQLiteConfig.updatedAt} = ?
      WHERE ${SQLiteConfig.id} = (
        SELECT ${SQLiteConfig.id} FROM $_t WHERE ${SQLiteConfig.deletedAt} IS NULL
        ORDER BY ${SQLiteConfig.walletSortOrder}, ${SQLiteConfig.createdAt} LIMIT 1
      )
      AND NOT EXISTS (
        SELECT 1 FROM $_t WHERE ${SQLiteConfig.walletIsPrimary} = 1 AND ${SQLiteConfig.deletedAt} IS NULL
      )
    ''', [now]);

  WalletSummary _summaryFromRow(Map<String, Object?> row) {
    final wallet = WalletModel.fromRow(row);
    return WalletSummary(
      wallet: wallet,
      balance: Money((row[SQLiteConfig.balanceMinor] as int?) ?? 0, wallet.currency),
    );
  }
}
