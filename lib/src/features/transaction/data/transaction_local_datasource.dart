import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../core/utils/enums/transaction_status.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import 'models/transaction_filter.dart';
import 'models/transaction_model.dart';

/// Raw `sqflite` queries and row ↔ model mapping for transactions.
class TransactionLocalDatasource {
  const TransactionLocalDatasource();

  static const _t = SQLiteConfig.transactionsTable;
  static const _w = SQLiteConfig.walletsTable;
  static const _tt = SQLiteConfig.transactionTagsTable;

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

  // ------------------------------------------------------------- upcoming

  /// Promote every `upcoming` row whose date has arrived. Returns the number
  /// of rows posted.
  Future<int> postDue(DatabaseExecutor db, int nowMs) => db.update(
        _t,
        {SQLiteConfig.txStatus: TransactionStatus.posted.dbValue, SQLiteConfig.updatedAt: nowMs},
        where: '${SQLiteConfig.txStatus} = ? AND ${SQLiteConfig.txDate} <= ? AND ${SQLiteConfig.deletedAt} IS NULL',
        whereArgs: [TransactionStatus.upcoming.dbValue, nowMs],
      );

  /// Earliest pending `upcoming` date (to schedule the next check), or null.
  Future<DateTime?> nextUpcomingDate(DatabaseExecutor db) async {
    final rows = await db.rawQuery(
      'SELECT MIN(${SQLiteConfig.txDate}) AS d FROM $_t '
      'WHERE ${SQLiteConfig.txStatus} = ? AND ${SQLiteConfig.deletedAt} IS NULL',
      [TransactionStatus.upcoming.dbValue],
    );
    final ms = Sqflite.firstIntValue(rows);
    return ms == null ? null : DateTimeExtension.fromEpochMs(ms);
  }

  Future<int> countUpcomingForWallet(DatabaseExecutor db, String walletId) async {
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM $_t '
      'WHERE ${SQLiteConfig.txStatus} = ?1 AND ${SQLiteConfig.deletedAt} IS NULL '
      'AND (${SQLiteConfig.txWalletId} = ?2 OR ${SQLiteConfig.txFromWalletId} = ?2 OR ${SQLiteConfig.txToWalletId} = ?2)',
      [TransactionStatus.upcoming.dbValue, walletId],
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  // ------------------------------------------------------------- wallet page

  /// B6 — one page of a wallet's transactions with counterpart wallet names
  /// (no `deleted_at` filter on the joins: names of deleted wallets still
  /// resolve). Upcoming rows always sort first; then [sort].
  Future<List<TransactionRow>> pageForWallet(
    DatabaseExecutor db,
    String walletId, {
    required int limit,
    required int offset,
    TransactionFilter filter = TransactionFilter.none,
    TransactionSort sort = TransactionSort.dateDesc,
  }) async {
    final where = StringBuffer(
      't.${SQLiteConfig.deletedAt} IS NULL '
      'AND (t.${SQLiteConfig.txWalletId} = ?1 OR t.${SQLiteConfig.txFromWalletId} = ?1 OR t.${SQLiteConfig.txToWalletId} = ?1)',
    );
    final args = <Object?>[walletId];
    _applyFilter(where, args, filter);

    // Signed magnitude from the viewed wallet's point of view (transfers use
    // the side that touches this wallet).
    final amountExpr = 'COALESCE(t.${SQLiteConfig.txAmountMinor}, '
        'CASE WHEN t.${SQLiteConfig.txFromWalletId} = ?1 THEN t.${SQLiteConfig.txFromAmountMinor} '
        'ELSE t.${SQLiteConfig.txToAmountMinor} END)';
    final order = switch (sort) {
      TransactionSort.dateDesc => 't.${SQLiteConfig.txDate} DESC, t.${SQLiteConfig.createdAt} DESC',
      TransactionSort.dateAsc => 't.${SQLiteConfig.txDate} ASC, t.${SQLiteConfig.createdAt} ASC',
      TransactionSort.amountDesc => '$amountExpr DESC, t.${SQLiteConfig.txDate} DESC',
      TransactionSort.amountAsc => '$amountExpr ASC, t.${SQLiteConfig.txDate} DESC',
    };
    args.addAll([limit, offset]);
    final limitIdx = args.length - 1;
    final offsetIdx = args.length;

    final rows = await db.rawQuery('''
      SELECT t.*,
             fw.${SQLiteConfig.walletName} AS from_wallet_name, fw.${SQLiteConfig.deletedAt} AS from_wallet_deleted,
             tw.${SQLiteConfig.walletName} AS to_wallet_name,   tw.${SQLiteConfig.deletedAt} AS to_wallet_deleted
      FROM $_t t
      LEFT JOIN $_w fw ON fw.${SQLiteConfig.id} = t.${SQLiteConfig.txFromWalletId}
      LEFT JOIN $_w tw ON tw.${SQLiteConfig.id} = t.${SQLiteConfig.txToWalletId}
      WHERE $where
      ORDER BY (t.${SQLiteConfig.txStatus} = '${TransactionStatus.upcoming.dbValue}') DESC, $order
      LIMIT ?$limitIdx OFFSET ?$offsetIdx
    ''', args);

    return rows.map(_rowFromMap).toList();
  }

  // ----------------------------------------------------------------- by tag

  /// Every non-deleted transaction carrying [tagId], newest first, with both
  /// counterpart names and the owning wallet's name (for the tag page).
  Future<List<TransactionRow>> pageForTag(
    DatabaseExecutor db,
    String tagId, {
    required int limit,
    required int offset,
  }) async {
    final rows = await db.rawQuery('''
      SELECT t.*,
             ow.${SQLiteConfig.walletName} AS wallet_name,
             fw.${SQLiteConfig.walletName} AS from_wallet_name, fw.${SQLiteConfig.deletedAt} AS from_wallet_deleted,
             tw.${SQLiteConfig.walletName} AS to_wallet_name,   tw.${SQLiteConfig.deletedAt} AS to_wallet_deleted
      FROM $_tt tt
      JOIN $_t t ON t.${SQLiteConfig.id} = tt.${SQLiteConfig.ttTransactionId}
      LEFT JOIN $_w ow ON ow.${SQLiteConfig.id} = t.${SQLiteConfig.txWalletId}
      LEFT JOIN $_w fw ON fw.${SQLiteConfig.id} = t.${SQLiteConfig.txFromWalletId}
      LEFT JOIN $_w tw ON tw.${SQLiteConfig.id} = t.${SQLiteConfig.txToWalletId}
      WHERE tt.${SQLiteConfig.ttTagId} = ?1 AND t.${SQLiteConfig.deletedAt} IS NULL
      ORDER BY t.${SQLiteConfig.txDate} DESC, t.${SQLiteConfig.createdAt} DESC
      LIMIT ?2 OFFSET ?3
    ''', [tagId, limit, offset]);
    return rows.map(_rowFromMap).toList();
  }

  // ---------------------------------------------------------------- helpers

  void _applyFilter(StringBuffer where, List<Object?> args, TransactionFilter filter) {
    if (filter.types.isNotEmpty) {
      final ph = filter.types.map((t) {
        args.add(t.dbValue);
        return '?${args.length}';
      }).join(',');
      where.write(' AND t.${SQLiteConfig.txType} IN ($ph)');
    }
    if (filter.from != null) {
      args.add(filter.from!.onlyDate().epochMs);
      where.write(' AND t.${SQLiteConfig.txDate} >= ?${args.length}');
    }
    if (filter.to != null) {
      final endExclusive = filter.to!.onlyDate().add(const Duration(days: 1));
      args.add(endExclusive.epochMs);
      where.write(' AND t.${SQLiteConfig.txDate} < ?${args.length}');
    }
    if (filter.tagIds.isNotEmpty) {
      final ph = filter.tagIds.map((id) {
        args.add(id);
        return '?${args.length}';
      }).join(',');
      where.write(
        ' AND EXISTS (SELECT 1 FROM $_tt x WHERE x.${SQLiteConfig.ttTransactionId} = t.${SQLiteConfig.id} '
        'AND x.${SQLiteConfig.ttTagId} IN ($ph))',
      );
    }
    if (filter.upcomingOnly) {
      args.add(TransactionStatus.upcoming.dbValue);
      where.write(' AND t.${SQLiteConfig.txStatus} = ?${args.length}');
    }
  }

  static TransactionRow _rowFromMap(Map<String, Object?> r) => TransactionRow(
        transaction: TransactionModel.fromRow(r),
        walletName: r['wallet_name'] as String?,
        fromWalletName: r['from_wallet_name'] as String?,
        fromWalletDeleted: r['from_wallet_deleted'] != null,
        toWalletName: r['to_wallet_name'] as String?,
        toWalletDeleted: r['to_wallet_deleted'] != null,
      );
}
