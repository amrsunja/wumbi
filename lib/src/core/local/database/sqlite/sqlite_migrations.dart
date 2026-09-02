import 'package:sqflite_sqlcipher/sqflite.dart';

typedef Migration = Future<void> Function(DatabaseExecutor db);

/// Ordered list of migrations. `migrations[i]` upgrades the schema from
/// version `i + 1` to `i + 2`. `onUpgrade(db, old, new)` runs
/// `migrations[old - 1 .. new - 2]` inside one transaction.
///
/// v1 is created in full by `onCreate` (see [SQLiteSchema.v1]); the list is
/// empty until v2 ships.
abstract class SQLiteMigrations {
  static const List<Migration> migrations = [];

  static Future<void> upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion >= newVersion) return;
    await db.transaction((txn) async {
      for (var v = oldVersion; v < newVersion; v++) {
        final index = v - 1;
        if (index < 0 || index >= migrations.length) continue;
        await migrations[index](txn);
      }
    });
  }
}
