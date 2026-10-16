import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../core/utils/enums/transaction_status.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../tag/data/tag_sql.dart';
import 'models/progress_stats.dart';

/// Read-only queries behind the Progress page. Every query shares one
/// filter: posted, live income / expense rows inside a local `[start, end)`
/// range, optionally one wallet. Transfers move money inside the user's own
/// wallets and debt money (`debt_role`) is neither spending nor income, so
/// both stay out — same rule as the tags hub.
///
/// Bucketing by period is a `CASE` over local period edges (never
/// `strftime`, which would bucket in UTC and misplace rows around midnight /
/// DST); day / weekday bucketing happens in Dart on [rows].
class ProgressLocalDatasource {
  const ProgressLocalDatasource();

  static const _t = SQLiteConfig.transactionsTable;
  static const _tt = SQLiteConfig.transactionTagsTable;
  static const _tags = SQLiteConfig.tagsTable;

  static String _filter(String? walletId) => '''
        t.${SQLiteConfig.deletedAt} IS NULL
        AND t.${SQLiteConfig.txStatus} = '${TransactionStatus.posted.dbValue}'
        AND t.${SQLiteConfig.txDebtRole} IS NULL
        AND t.${SQLiteConfig.txType} IN ('income','expense')
        AND t.${SQLiteConfig.txDate} >= ?
        AND t.${SQLiteConfig.txDate} < ?
        ${walletId == null ? '' : 'AND t.${SQLiteConfig.txWalletId} = ?'}''';

  static List<Object?> _args(DateTime start, DateTime end, String? walletId) => [
        start.epochMs,
        end.epochMs,
        if (walletId != null) walletId,
      ];

  /// Sums per bucket × currency × type (history bars). [boundaries] holds
  /// `buckets + 1` ascending local edges.
  Future<List<PeriodCurrencySum>> sumsByPeriod(
    DatabaseExecutor db, {
    required List<DateTime> boundaries,
    String? walletId,
  }) async {
    final edges = boundaries.map((d) => d.epochMs).toList();
    final buckets = edges.length - 1;
    if (buckets < 1) return const [];

    // `CASE WHEN date < edge1 THEN 0 ... ELSE last END` — the edges ascend,
    // so the first matching WHEN is the right bucket.
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
    final rows = await db.rawQuery('''
      SELECT $bucketExpr AS bucket,
             t.${SQLiteConfig.txCurrency} AS currency,
             t.${SQLiteConfig.txType} AS type,
             SUM(t.${SQLiteConfig.txAmountMinor}) AS total,
             COUNT(*) AS n
      FROM $_t t
      WHERE ${_filter(walletId)}
      GROUP BY bucket, currency, type
    ''', [
      for (var i = 1; i < buckets; i++) edges[i],
      ..._args(boundaries.first, boundaries.last, walletId),
    ]);

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

  /// Every counted row of `[start, end)` — the pace curve, weekdays, the
  /// largest expense and the recurring share are all derived from these.
  Future<List<ProgressTxRow>> rows(
    DatabaseExecutor db, {
    required DateTime start,
    required DateTime end,
    String? walletId,
  }) async {
    final rows = await db.rawQuery('''
      SELECT t.${SQLiteConfig.id} AS id,
             t.${SQLiteConfig.txWalletId} AS wallet_id,
             t.${SQLiteConfig.txType} AS type,
             t.${SQLiteConfig.txAmountMinor} AS amount,
             t.${SQLiteConfig.txCurrency} AS currency,
             t.${SQLiteConfig.txDate} AS date,
             t.${SQLiteConfig.txDescription} AS description,
             t.${SQLiteConfig.txRecurringRuleId} AS rule_id
      FROM $_t t
      WHERE ${_filter(walletId)}
    ''', _args(start, end, walletId));

    return rows
        .map(
          (r) => ProgressTxRow(
            id: r['id'] as String,
            walletId: r['wallet_id'] as String?,
            isIncome: r['type'] == 'income',
            amountMinor: (r['amount'] as int?) ?? 0,
            currencyCode: r['currency'] as String,
            date: DateTimeExtension.fromEpochMs(r['date'] as int),
            description: (r['description'] as String?) ?? '',
            recurring: r['rule_id'] != null,
          ),
        )
        .toList();
  }

  /// Per tag × currency × type sums of `[start, end)` with nested tags rolled
  /// into every ancestor (Obsidian semantics): `food` counts a row tagged
  /// `food/coffee`, and a row tagged both `food` and `food/coffee` once.
  /// Untagged rows come back with a null [TagRangeSum.tagId].
  Future<List<TagRangeSum>> sumsByTag(
    DatabaseExecutor db, {
    required DateTime start,
    required DateTime end,
    String? walletId,
  }) async {
    final args = _args(start, end, walletId);
    final tagged = await db.rawQuery('''
      SELECT p.${SQLiteConfig.id} AS tag_id,
             p.${SQLiteConfig.tagDisplayName} AS display_name,
             p.${SQLiteConfig.tagNormalizedName} AS normalized_name,
             t.${SQLiteConfig.txCurrency} AS currency,
             t.${SQLiteConfig.txType} AS type,
             SUM(t.${SQLiteConfig.txAmountMinor}) AS total,
             COUNT(*) AS n
      FROM (
        SELECT DISTINCT p.${SQLiteConfig.id} AS pid, t.${SQLiteConfig.id} AS txid
        FROM $_t t
        JOIN $_tt tt ON tt.${SQLiteConfig.ttTransactionId} = t.${SQLiteConfig.id}
        JOIN $_tags c ON c.${SQLiteConfig.id} = tt.${SQLiteConfig.ttTagId} AND c.${SQLiteConfig.deletedAt} IS NULL
        JOIN $_tags p ON p.${SQLiteConfig.deletedAt} IS NULL AND ${TagSql.selfOrDescendant('c', 'p')}
        WHERE ${_filter(walletId)}
      ) x
      JOIN $_tags p ON p.${SQLiteConfig.id} = x.pid
      JOIN $_t t ON t.${SQLiteConfig.id} = x.txid
      GROUP BY p.${SQLiteConfig.id}, t.${SQLiteConfig.txCurrency}, t.${SQLiteConfig.txType}
    ''', args);

    final untagged = await db.rawQuery('''
      SELECT t.${SQLiteConfig.txCurrency} AS currency,
             t.${SQLiteConfig.txType} AS type,
             SUM(t.${SQLiteConfig.txAmountMinor}) AS total,
             COUNT(*) AS n
      FROM $_t t
      WHERE ${_filter(walletId)}
        AND NOT EXISTS (
          SELECT 1 FROM $_tt tt
          JOIN $_tags g ON g.${SQLiteConfig.id} = tt.${SQLiteConfig.ttTagId} AND g.${SQLiteConfig.deletedAt} IS NULL
          WHERE tt.${SQLiteConfig.ttTransactionId} = t.${SQLiteConfig.id}
        )
      GROUP BY currency, type
    ''', args);

    return [
      for (final r in tagged)
        TagRangeSum(
          tagId: r['tag_id'] as String,
          displayName: (r['display_name'] as String?) ?? '',
          normalizedName: (r['normalized_name'] as String?) ?? '',
          currencyCode: r['currency'] as String,
          type: r['type'] as String,
          totalMinor: (r['total'] as int?) ?? 0,
          count: (r['n'] as int?) ?? 0,
        ),
      for (final r in untagged)
        TagRangeSum(
          tagId: null,
          displayName: '',
          normalizedName: '',
          currencyCode: r['currency'] as String,
          type: r['type'] as String,
          totalMinor: (r['total'] as int?) ?? 0,
          count: (r['n'] as int?) ?? 0,
        ),
    ];
  }
}
