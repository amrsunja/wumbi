import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/local/database/sqlite/sqlite_config.dart';
import 'models/transaction_model.dart';

/// Raw `sqflite` queries and row ↔ model mapping for transactions.
class TransactionLocalDatasource {
  const TransactionLocalDatasource();

  static const _t = SQLiteConfig.transactionsTable;
  static const _w = SQLiteConfig.walletsTable;

  Future<void> insert(DatabaseExecutor db, TransactionModel tx) => db.insert(_t, tx.toRow());

  /// `INSERT OR IGNORE` — idempotent occurrence generation (idx_tx_rule_date).
  Future<bool> insertIgnore(DatabaseExecutor db, TransactionModel tx) async {
    final rowId = await db.insert(_t, tx.toRow(), conflictAlgorithm: ConflictAlgorithm.ignore);
    return rowId != 0;
  }

  Future<void> update(DatabaseExecutor db, TransactionModel tx) => db.update(
        _t,
        tx.toRow(),
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [tx.id],
      );

  Future<TransactionModel?> byId(DatabaseExecutor db, String id) async {
    final rows = await db.query(_t, where: '${SQLiteConfig.id} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return TransactionModel.fromRow(rows.first);
  }

  Future<void> softDelete(DatabaseExecutor db, String id, int now) => db.update(
        _t,
        {SQLiteConfig.deletedAt: now, SQLiteConfig.updatedAt: now},
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [id],
      );

  Future<void> restore(DatabaseExecutor db, String id, int now) => db.update(
        _t,
        {SQLiteConfig.deletedAt: null, SQLiteConfig.updatedAt: now},
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [id],
      );

  /// B6 — one page of a wallet's transactions, newest first, with counterpart
  /// wallet names (no `deleted_at` filter on the joins: names of deleted
  /// wallets still resolve).
  Future<List<TransactionRow>> pageForWallet(
    DatabaseExecutor db,
    String walletId, {
    required int limit,
    required int offset,
  }) async {
    final rows = await db.rawQuery('''
      SELECT t.*,
             fw.${SQLiteConfig.walletName} AS from_wallet_name, fw.${SQLiteConfig.deletedAt} AS from_wallet_deleted,
             tw.${SQLiteConfig.walletName} AS to_wallet_name,   tw.${SQLiteConfig.deletedAt} AS to_wallet_deleted
      FROM $_t t
      LEFT JOIN $_w fw ON fw.${SQLiteConfig.id} = t.${SQLiteConfig.txFromWalletId}
      LEFT JOIN $_w tw ON tw.${SQLiteConfig.id} = t.${SQLiteConfig.txToWalletId}
      WHERE t.${SQLiteConfig.deletedAt} IS NULL
        AND (t.${SQLiteConfig.txWalletId} = ?1 OR t.${SQLiteConfig.txFromWalletId} = ?1 OR t.${SQLiteConfig.txToWalletId} = ?1)
      ORDER BY t.${SQLiteConfig.txDate} DESC, t.${SQLiteConfig.createdAt} DESC
      LIMIT ?2 OFFSET ?3
    ''', [walletId, limit, offset]);

    return rows
        .map(
          (r) => TransactionRow(
            transaction: TransactionModel.fromRow(r),
            fromWalletName: r['from_wallet_name'] as String?,
            fromWalletDeleted: r['from_wallet_deleted'] != null,
            toWalletName: r['to_wallet_name'] as String?,
            toWalletDeleted: r['to_wallet_deleted'] != null,
          ),
        )
        .toList();
  }
}
