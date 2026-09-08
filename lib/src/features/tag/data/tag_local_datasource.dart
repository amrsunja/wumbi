import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../core/utils/enums/transaction_status.dart';
import '../../../core/utils/id_generator.dart';
import 'models/tag_model.dart';
import 'models/tag_stats.dart';
import 'tag_normalizer.dart';

/// Raw queries for tags and the two link tables.
class TagLocalDatasource {
  const TagLocalDatasource();

  static const _tags = SQLiteConfig.tagsTable;
  static const _tt = SQLiteConfig.transactionTagsTable;
  static const _rrt = SQLiteConfig.recurringRuleTagsTable;
  static const _tx = SQLiteConfig.transactionsTable;
  static const _w = SQLiteConfig.walletsTable;

  Future<TagModel?> byId(DatabaseExecutor db, String id) async {
    final rows = await db.query(_tags, where: '${SQLiteConfig.id} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return TagModel.fromRow(rows.first);
  }

  Future<TagModel?> byNormalizedName(DatabaseExecutor db, String normalized) async {
    final rows = await db.query(
      _tags,
      where: '${SQLiteConfig.tagNormalizedName} = ? AND ${SQLiteConfig.deletedAt} IS NULL',
      whereArgs: [normalized],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return TagModel.fromRow(rows.first);
  }

  /// Every live tag, most used first (tags hub list).
  Future<List<TagModel>> listAll(DatabaseExecutor db) async {
    final rows = await db.query(
      _tags,
      where: '${SQLiteConfig.deletedAt} IS NULL',
      orderBy: '${SQLiteConfig.tagUsageCount} DESC, ${SQLiteConfig.tagLastUsedAt} DESC, ${SQLiteConfig.tagDisplayName}',
    );
    return rows.map(TagModel.fromRow).toList();
  }

  // ------------------------------------------------------------------ stats

  /// Per tag × currency × type sums over posted, non-deleted income/expense
  /// transactions (transfers are wallet-internal and excluded). Currency
  /// conversion into the base currency happens in the repository.
  Future<List<TagCurrencySum>> sumsByTag(DatabaseExecutor db, {String? tagId}) async {
    final rows = await db.rawQuery('''
      SELECT tt.${SQLiteConfig.ttTagId} AS tag_id,
             t.${SQLiteConfig.txCurrency} AS currency,
             t.${SQLiteConfig.txType} AS type,
             SUM(t.${SQLiteConfig.txAmountMinor}) AS total,
             COUNT(*) AS n
      FROM $_tt tt
      JOIN $_tx t ON t.${SQLiteConfig.id} = tt.${SQLiteConfig.ttTransactionId}
      JOIN $_tags g ON g.${SQLiteConfig.id} = tt.${SQLiteConfig.ttTagId} AND g.${SQLiteConfig.deletedAt} IS NULL
      WHERE t.${SQLiteConfig.deletedAt} IS NULL
        AND t.${SQLiteConfig.txStatus} = '${TransactionStatus.posted.dbValue}'
        AND t.${SQLiteConfig.txType} IN ('income','expense')
        ${tagId == null ? '' : 'AND tt.${SQLiteConfig.ttTagId} = ?'}
      GROUP BY tt.${SQLiteConfig.ttTagId}, t.${SQLiteConfig.txCurrency}, t.${SQLiteConfig.txType}
    ''', tagId == null ? const [] : [tagId]);
    return rows
        .map(
          (r) => TagCurrencySum(
            tagId: r['tag_id'] as String,
            currencyCode: r['currency'] as String,
            type: r['type'] as String,
            totalMinor: (r['total'] as int?) ?? 0,
            count: (r['n'] as int?) ?? 0,
          ),
        )
        .toList();
  }

  /// Wallets touched by a tag with per-wallet sums in the wallet's own
  /// currency (tag detail page). Transfers count on both sides.
  Future<List<TagWalletSum>> walletsOfTag(DatabaseExecutor db, String tagId) async {
    final rows = await db.rawQuery('''
      SELECT w.${SQLiteConfig.id} AS wallet_id,
             w.${SQLiteConfig.walletName} AS name,
             w.${SQLiteConfig.walletCurrency} AS currency,
             w.${SQLiteConfig.walletColor} AS color,
             w.${SQLiteConfig.deletedAt} AS wallet_deleted,
             SUM(CASE WHEN t.${SQLiteConfig.txType} = 'income' AND t.${SQLiteConfig.txWalletId} = w.${SQLiteConfig.id} THEN t.${SQLiteConfig.txAmountMinor}
                      WHEN t.${SQLiteConfig.txType} = 'transfer' AND t.${SQLiteConfig.txToWalletId} = w.${SQLiteConfig.id} THEN t.${SQLiteConfig.txToAmountMinor}
                      ELSE 0 END) AS in_minor,
             SUM(CASE WHEN t.${SQLiteConfig.txType} = 'expense' AND t.${SQLiteConfig.txWalletId} = w.${SQLiteConfig.id} THEN t.${SQLiteConfig.txAmountMinor}
                      WHEN t.${SQLiteConfig.txType} = 'transfer' AND t.${SQLiteConfig.txFromWalletId} = w.${SQLiteConfig.id} THEN t.${SQLiteConfig.txFromAmountMinor}
                      ELSE 0 END) AS out_minor,
             COUNT(*) AS n
      FROM $_tt tt
      JOIN $_tx t ON t.${SQLiteConfig.id} = tt.${SQLiteConfig.ttTransactionId}
      JOIN $_w w ON w.${SQLiteConfig.id} IN (t.${SQLiteConfig.txWalletId}, t.${SQLiteConfig.txFromWalletId}, t.${SQLiteConfig.txToWalletId})
      WHERE tt.${SQLiteConfig.ttTagId} = ?
        AND t.${SQLiteConfig.deletedAt} IS NULL
        AND t.${SQLiteConfig.txStatus} = '${TransactionStatus.posted.dbValue}'
      GROUP BY w.${SQLiteConfig.id}
      ORDER BY n DESC
    ''', [tagId]);
    return rows
        .map(
          (r) => TagWalletSum(
            walletId: r['wallet_id'] as String,
            name: r['name'] as String,
            currencyCode: r['currency'] as String,
            colorKey: r['color'] as String?,
            walletDeleted: r['wallet_deleted'] != null,
            inMinor: (r['in_minor'] as int?) ?? 0,
            outMinor: (r['out_minor'] as int?) ?? 0,
            count: (r['n'] as int?) ?? 0,
          ),
        )
        .toList();
  }

  /// Tag pairs that co-occur on the same transaction, with counts (graph
  /// edges). `a < b` so each pair appears once.
  Future<List<TagLink>> coOccurrences(DatabaseExecutor db) async {
    final rows = await db.rawQuery('''
      SELECT a.${SQLiteConfig.ttTagId} AS a, b.${SQLiteConfig.ttTagId} AS b, COUNT(*) AS n
      FROM $_tt a
      JOIN $_tt b ON b.${SQLiteConfig.ttTransactionId} = a.${SQLiteConfig.ttTransactionId}
                 AND a.${SQLiteConfig.ttTagId} < b.${SQLiteConfig.ttTagId}
      JOIN $_tx t ON t.${SQLiteConfig.id} = a.${SQLiteConfig.ttTransactionId} AND t.${SQLiteConfig.deletedAt} IS NULL
      JOIN $_tags ga ON ga.${SQLiteConfig.id} = a.${SQLiteConfig.ttTagId} AND ga.${SQLiteConfig.deletedAt} IS NULL
      JOIN $_tags gb ON gb.${SQLiteConfig.id} = b.${SQLiteConfig.ttTagId} AND gb.${SQLiteConfig.deletedAt} IS NULL
      GROUP BY a.${SQLiteConfig.ttTagId}, b.${SQLiteConfig.ttTagId}
    ''');
    return rows
        .map((r) => TagLink(a: r['a'] as String, b: r['b'] as String, count: (r['n'] as int?) ?? 0))
        .toList();
  }

  // -------------------------------------------------------------- mutations

  Future<void> rename(DatabaseExecutor db, String id, String displayName, String normalized, int now) => db.update(
        _tags,
        {
          SQLiteConfig.tagDisplayName: displayName,
          SQLiteConfig.tagNormalizedName: normalized,
          SQLiteConfig.updatedAt: now,
        },
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [id],
      );

  /// Move every link from [fromId] to [intoId] (skipping rows that would
  /// duplicate), then soft-delete [fromId]. Returns links moved.
  Future<int> mergeInto(DatabaseExecutor db, String fromId, String intoId, int now) async {
    final movedTx = await db.rawUpdate(
      'UPDATE OR IGNORE $_tt SET ${SQLiteConfig.ttTagId} = ? WHERE ${SQLiteConfig.ttTagId} = ?',
      [intoId, fromId],
    );
    await db.delete(_tt, where: '${SQLiteConfig.ttTagId} = ?', whereArgs: [fromId]);
    await db.rawUpdate(
      'UPDATE OR IGNORE $_rrt SET ${SQLiteConfig.rrtTagId} = ? WHERE ${SQLiteConfig.rrtTagId} = ?',
      [intoId, fromId],
    );
    await db.delete(_rrt, where: '${SQLiteConfig.rrtTagId} = ?', whereArgs: [fromId]);
    await recountUsage(db, intoId, now);
    await softDelete(db, fromId, now);
    return movedTx;
  }

  /// Soft delete a tag and drop every link to it.
  Future<void> softDelete(DatabaseExecutor db, String id, int now) async {
    await db.delete(_tt, where: '${SQLiteConfig.ttTagId} = ?', whereArgs: [id]);
    await db.delete(_rrt, where: '${SQLiteConfig.rrtTagId} = ?', whereArgs: [id]);
    await db.update(
      _tags,
      {SQLiteConfig.deletedAt: now, SQLiteConfig.tagUsageCount: 0, SQLiteConfig.updatedAt: now},
      where: '${SQLiteConfig.id} = ?',
      whereArgs: [id],
    );
  }

  /// `usage_count` = number of live transaction links.
  Future<void> recountUsage(DatabaseExecutor db, String id, int now) => db.rawUpdate('''
      UPDATE $_tags SET
        ${SQLiteConfig.tagUsageCount} = (
          SELECT COUNT(*) FROM $_tt tt JOIN $_tx t ON t.${SQLiteConfig.id} = tt.${SQLiteConfig.ttTransactionId}
          WHERE tt.${SQLiteConfig.ttTagId} = ?1 AND t.${SQLiteConfig.deletedAt} IS NULL
        ),
        ${SQLiteConfig.updatedAt} = ?2
      WHERE ${SQLiteConfig.id} = ?1
    ''', [id, now]);

  /// B9 — find-or-create by normalized name.
  Future<TagModel> findOrCreate(DatabaseExecutor db, String rawName, int now) async {
    final normalized = TagNormalizer.normalize(rawName);
    final rows = await db.query(
      _tags,
      where: '${SQLiteConfig.tagNormalizedName} = ? AND ${SQLiteConfig.deletedAt} IS NULL',
      whereArgs: [normalized],
      limit: 1,
    );
    if (rows.isNotEmpty) return TagModel.fromRow(rows.first);

    final tag = TagModel(
      id: newId(),
      normalizedName: normalized,
      displayName: TagNormalizer.display(rawName),
      usageCount: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true).toLocal(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true).toLocal(),
    );
    await db.insert(_tags, tag.toRow());
    return tag;
  }

  Future<void> bumpUsage(DatabaseExecutor db, String tagId, int delta, int now) => db.rawUpdate(
        '''
        UPDATE $_tags
        SET ${SQLiteConfig.tagUsageCount} = MAX(0, ${SQLiteConfig.tagUsageCount} + ?),
            ${SQLiteConfig.tagLastUsedAt} = CASE WHEN ? > 0 THEN ? ELSE ${SQLiteConfig.tagLastUsedAt} END,
            ${SQLiteConfig.updatedAt} = ?
        WHERE ${SQLiteConfig.id} = ?
        ''',
        [delta, delta, now, now, tagId],
      );

  // ------------------------------------------------------------ transaction_tags

  Future<void> linkTransaction(DatabaseExecutor db, String transactionId, String tagId, int now) =>
      db.insert(
        _tt,
        {SQLiteConfig.ttTransactionId: transactionId, SQLiteConfig.ttTagId: tagId, SQLiteConfig.createdAt: now},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

  Future<void> unlinkTransaction(DatabaseExecutor db, String transactionId, String tagId) => db.delete(
        _tt,
        where: '${SQLiteConfig.ttTransactionId} = ? AND ${SQLiteConfig.ttTagId} = ?',
        whereArgs: [transactionId, tagId],
      );

  /// B7 — tags of a transaction.
  Future<List<TagModel>> tagsOfTransaction(DatabaseExecutor db, String transactionId) async {
    final rows = await db.rawQuery('''
      SELECT g.* FROM $_tags g JOIN $_tt tt ON tt.${SQLiteConfig.ttTagId} = g.${SQLiteConfig.id}
      WHERE tt.${SQLiteConfig.ttTransactionId} = ? AND g.${SQLiteConfig.deletedAt} IS NULL
      ORDER BY tt.${SQLiteConfig.createdAt}
    ''', [transactionId]);
    return rows.map(TagModel.fromRow).toList();
  }

  /// Tags for a set of transactions: `transactionId → display names`.
  Future<Map<String, List<String>>> tagsOfTransactions(DatabaseExecutor db, List<String> ids) async {
    if (ids.isEmpty) return const {};
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await db.rawQuery('''
      SELECT tt.${SQLiteConfig.ttTransactionId} AS tx, g.${SQLiteConfig.tagDisplayName} AS name
      FROM $_tt tt JOIN $_tags g ON g.${SQLiteConfig.id} = tt.${SQLiteConfig.ttTagId}
      WHERE tt.${SQLiteConfig.ttTransactionId} IN ($placeholders) AND g.${SQLiteConfig.deletedAt} IS NULL
      ORDER BY tt.${SQLiteConfig.createdAt}
    ''', ids);
    final out = <String, List<String>>{};
    for (final r in rows) {
      out.putIfAbsent(r['tx'] as String, () => []).add(r['name'] as String);
    }
    return out;
  }

  // ------------------------------------------------------------ recurring_rule_tags

  Future<void> linkRule(DatabaseExecutor db, String ruleId, String tagId, int now) => db.insert(
        _rrt,
        {SQLiteConfig.rrtRuleId: ruleId, SQLiteConfig.rrtTagId: tagId, SQLiteConfig.createdAt: now},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

  Future<void> unlinkRule(DatabaseExecutor db, String ruleId, String tagId) => db.delete(
        _rrt,
        where: '${SQLiteConfig.rrtRuleId} = ? AND ${SQLiteConfig.rrtTagId} = ?',
        whereArgs: [ruleId, tagId],
      );

  Future<List<TagModel>> tagsOfRule(DatabaseExecutor db, String ruleId) async {
    final rows = await db.rawQuery('''
      SELECT g.* FROM $_tags g JOIN $_rrt rt ON rt.${SQLiteConfig.rrtTagId} = g.${SQLiteConfig.id}
      WHERE rt.${SQLiteConfig.rrtRuleId} = ? AND g.${SQLiteConfig.deletedAt} IS NULL
      ORDER BY rt.${SQLiteConfig.createdAt}
    ''', [ruleId]);
    return rows.map(TagModel.fromRow).toList();
  }

  Future<List<String>> tagIdsOfRule(DatabaseExecutor db, String ruleId) async {
    final rows = await db.query(
      _rrt,
      columns: [SQLiteConfig.rrtTagId],
      where: '${SQLiteConfig.rrtRuleId} = ?',
      whereArgs: [ruleId],
    );
    return rows.map((r) => r[SQLiteConfig.rrtTagId] as String).toList();
  }

  /// B8 — autocomplete. Empty [query] → the most used / most recent tags.
  /// Otherwise prefix matches first, then "contains" matches, each ranked by
  /// usage then recency.
  Future<List<TagModel>> suggest(DatabaseExecutor db, String query, {int limit = 6}) async {
    final normalized = TagNormalizer.normalize(query);
    final alive = '${SQLiteConfig.deletedAt} IS NULL AND ${SQLiteConfig.tagUsageCount} > 0';
    final rank = '${SQLiteConfig.tagUsageCount} DESC, ${SQLiteConfig.tagLastUsedAt} DESC';
    if (normalized.isEmpty) {
      final rows = await db.query(_tags, where: alive, orderBy: rank, limit: limit);
      return rows.map(TagModel.fromRow).toList();
    }
    final like = _escapeLike(normalized);
    final rows = await db.rawQuery(
      'SELECT * FROM $_tags '
      "WHERE $alive AND ${SQLiteConfig.tagNormalizedName} LIKE ? ESCAPE '\\' "
      "ORDER BY CASE WHEN ${SQLiteConfig.tagNormalizedName} LIKE ? ESCAPE '\\' THEN 0 ELSE 1 END, $rank "
      'LIMIT ?',
      ['%$like%', '$like%', limit],
    );
    return rows.map(TagModel.fromRow).toList();
  }

  static String _escapeLike(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
}
