import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../core/utils/id_generator.dart';
import 'models/tag_model.dart';
import 'tag_normalizer.dart';

/// Raw queries for tags and the two link tables.
class TagLocalDatasource {
  const TagLocalDatasource();

  static const _tags = SQLiteConfig.tagsTable;
  static const _tt = SQLiteConfig.transactionTagsTable;
  static const _rrt = SQLiteConfig.recurringRuleTagsTable;

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
