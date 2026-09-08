import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../core/utils/enums/transaction_status.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import 'models/progress_stats.dart';

/// One grouped query per progress refresh. Buckets are resolved in SQL by a
/// `CASE` built from local period edges (never `strftime`, which would bucket
/// in UTC and misplace rows around midnight / DST).
class ProgressLocalDatasource {
  const ProgressLocalDatasource();

  static const _t = SQLiteConfig.transactionsTable;
  static const _tt = SQLiteConfig.transactionTagsTable;
  static const _tags = SQLiteConfig.tagsTable;

  /// Sums of posted income / expense rows per bucket × currency × type.
  /// Transfers move money inside the user's own wallets, so they are excluded
  /// (same rule as the tags hub).
  ///
  /// [boundaries] holds `bucketCount + 1` local period edges, oldest first.
  /// [walletId] narrows to a single wallet; null aggregates every wallet.
  Future<List<PeriodCurrencySum>> sumsByPeriod(
    DatabaseExecutor db, {
    required List<DateTime> boundaries,
    String? walletId,
  }) async {
    final edges = boundaries.map((d) => d.epochMs).toList();
    final buckets = edges.length - 1;
    if (buckets < 1) return const [];

    // `CASE WHEN date < edge1 THEN 0 ... ELSE last END` — the edges are
    // ascending, so the first matching WHEN is the right bucket.
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
      edges.first,
      edges.last,
      if (walletId != null) walletId,
    ];

    final rows = await db.rawQuery('''
      SELECT $bucketExpr AS bucket,
             t.${SQLiteConfig.txCurrency} AS currency,
             t.${SQLiteConfig.txType} AS type,
             SUM(t.${SQLiteConfig.txAmountMinor}) AS total,
             COUNT(*) AS n
      FROM $_t t
      WHERE t.${SQLiteConfig.deletedAt} IS NULL
        AND t.${SQLiteConfig.txStatus} = '${TransactionStatus.posted.dbValue}'
        AND t.${SQLiteConfig.txType} IN ('income','expense')
        AND t.${SQLiteConfig.txDate} >= ?
        AND t.${SQLiteConfig.txDate} < ?
        ${walletId == null ? '' : 'AND t.${SQLiteConfig.txWalletId} = ?'}
      GROUP BY bucket, currency, type
    ''', args);

    return rows
        .map(
          (r) => PeriodCurrencySum(
            bucket: (r['bucket'] as int?) ?? 0,
            currencyCode: r['currency'] as String,
            type: r['type'] as String,
            totalMinor: (r['total'] as int?) ?? 0,
            count: (r['n'] as int?) ?? 0,
          ),
        )
        .toList();
  }

  /// Per tag × currency expense sums inside `[start, end)` — the pie.
  /// A `LEFT JOIN` is what produces the untagged bucket (null `tag_id`);
  /// soft-deleting a tag also drops its links, so a live link can never point
  /// at a dead tag and the join needs no extra guard.
  ///
  /// A transaction with two tags is counted under both, so the caller must
  /// treat the sum of the slices — not the period's expense — as the whole.
  Future<List<PeriodTagSum>> expenseByTag(
    DatabaseExecutor db, {
    required DateTime start,
    required DateTime end,
    String? walletId,
  }) async {
    final rows = await db.rawQuery('''
      SELECT g.${SQLiteConfig.id} AS tag_id,
             g.${SQLiteConfig.tagDisplayName} AS display_name,
             g.${SQLiteConfig.tagNormalizedName} AS normalized_name,
             t.${SQLiteConfig.txCurrency} AS currency,
             SUM(t.${SQLiteConfig.txAmountMinor}) AS total,
             COUNT(*) AS n
      FROM $_t t
      LEFT JOIN $_tt tt ON tt.${SQLiteConfig.ttTransactionId} = t.${SQLiteConfig.id}
      LEFT JOIN $_tags g ON g.${SQLiteConfig.id} = tt.${SQLiteConfig.ttTagId}
                        AND g.${SQLiteConfig.deletedAt} IS NULL
      WHERE t.${SQLiteConfig.deletedAt} IS NULL
        AND t.${SQLiteConfig.txStatus} = '${TransactionStatus.posted.dbValue}'
        AND t.${SQLiteConfig.txType} = 'expense'
        AND t.${SQLiteConfig.txDate} >= ?
        AND t.${SQLiteConfig.txDate} < ?
        ${walletId == null ? '' : 'AND t.${SQLiteConfig.txWalletId} = ?'}
      GROUP BY tag_id, currency
    ''', [
      start.epochMs,
      end.epochMs,
      if (walletId != null) walletId,
    ]);

    return rows
        .map(
          (r) => PeriodTagSum(
            tagId: r['tag_id'] as String?,
            displayName: r['display_name'] as String?,
            normalizedName: r['normalized_name'] as String?,
            currencyCode: r['currency'] as String,
            totalMinor: (r['total'] as int?) ?? 0,
            count: (r['n'] as int?) ?? 0,
          ),
        )
        .toList();
  }
}
