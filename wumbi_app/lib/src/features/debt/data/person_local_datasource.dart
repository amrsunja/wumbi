import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/local/database/sqlite/sqlite_config.dart';
import 'models/person_model.dart';

/// Raw queries for `people`. No business rules.
class PersonLocalDatasource {
  const PersonLocalDatasource();

  static const _p = SQLiteConfig.peopleTable;
  static const _d = SQLiteConfig.debtsTable;

  Future<PersonModel?> byId(DatabaseExecutor db, String id) async {
    final rows = await db.query(_p, where: '${SQLiteConfig.id} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return PersonModel.fromRow(rows.first);
  }

  /// Live person with this normalized name (unique among live rows).
  Future<PersonModel?> byNormalizedName(DatabaseExecutor db, String normalized) async {
    final rows = await db.query(
      _p,
      where: '${SQLiteConfig.personNormalizedName} = ? AND ${SQLiteConfig.deletedAt} IS NULL',
      whereArgs: [normalized],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PersonModel.fromRow(rows.first);
  }

  Future<void> insert(DatabaseExecutor db, PersonModel person) => db.insert(_p, person.toRow());

  /// Picker ordering: `last_used_at = now`.
  Future<void> touch(DatabaseExecutor db, String id, int now) => db.update(
        _p,
        {SQLiteConfig.personLastUsedAt: now, SQLiteConfig.updatedAt: now},
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [id],
      );

  Future<void> rename(DatabaseExecutor db, String id, String name, String normalized, int now) => db.update(
        _p,
        {
          SQLiteConfig.personName: name,
          SQLiteConfig.personNormalizedName: normalized,
          SQLiteConfig.updatedAt: now,
        },
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [id],
      );

  Future<void> softDelete(DatabaseExecutor db, String id, int now) => db.update(
        _p,
        {SQLiteConfig.deletedAt: now, SQLiteConfig.updatedAt: now},
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [id],
      );

  /// Live people matching [normalizedQuery] (substring; empty = everyone):
  /// people with open debts first, then most recently used.
  Future<List<PersonModel>> search(DatabaseExecutor db, String normalizedQuery, {int limit = 50}) async {
    final like = _escapeLike(normalizedQuery);
    final rows = await db.rawQuery('''
      SELECT p.*,
             EXISTS (SELECT 1 FROM $_d d
                     WHERE d.${SQLiteConfig.debtPersonId} = p.${SQLiteConfig.id}
                       AND d.${SQLiteConfig.deletedAt} IS NULL
                       AND d.${SQLiteConfig.debtClosedAt} IS NULL) AS has_open
      FROM $_p p
      WHERE p.${SQLiteConfig.deletedAt} IS NULL
        ${like.isEmpty ? '' : "AND p.${SQLiteConfig.personNormalizedName} LIKE ? ESCAPE '\\'"}
      ORDER BY has_open DESC, p.${SQLiteConfig.personLastUsedAt} DESC, p.${SQLiteConfig.personName}
      LIMIT ?
    ''', [if (like.isNotEmpty) '%$like%', limit]);
    return rows.map(PersonModel.fromRow).toList();
  }

  static String _escapeLike(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
}
