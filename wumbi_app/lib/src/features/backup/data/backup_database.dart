import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/errors/exceptions/domain/domain_exceptions.dart';
import '../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../core/local/database/sqlite/sqlite_migrations.dart';
import '../../../core/local/database/sqlite/sqlite_schema.dart';
import 'backup_codec.dart';

/// Opens an empty scratch database for staging an import.
typedef StagingOpener = Future<Database> Function();

/// In-memory, never written to disk (the decrypted data must not land in a
/// plain file next to the encrypted database).
Future<Database> openInMemoryStaging() => openDatabase(inMemoryDatabasePath, singleInstance: false);

/// Backup data checked against the current schema, ready to replace the
/// database in one transaction.
class StagedBackup {
  const StagedBackup(this.tables);

  final BackupTables tables;

  /// Live (not soft-deleted) rows of [table].
  int liveCount(String table) => (tables[table] ?? const []).where((r) => r[SQLiteConfig.deletedAt] == null).length;
}

/// Moves whole databases in and out of [BackupTables].
///
/// Import never writes unchecked data into the user's database:
///
/// 1. **Stage** — a scratch database is built with the DDL of the *backup's*
///    schema version and filled with its rows (so SQLite's own CHECK, NOT
///    NULL and UNIQUE rules validate every value), then upgraded with the
///    app's regular `SQLiteMigrations`. An old backup goes through exactly
///    the code path an old install does. `PRAGMA foreign_key_check` and
///    `integrity_check` must come back clean.
/// 2. **Replace** — one transaction on the real database: delete every
///    table, insert the staged rows, check foreign keys. Any failure rolls
///    back and the user's data is untouched.
class BackupDatabase {
  BackupDatabase({StagingOpener? openStaging}) : _openStaging = openStaging ?? openInMemoryStaging;

  final StagingOpener _openStaging;

  /// Every table a backup carries, parents before children (insert order;
  /// deletes run in reverse). A new table must be added here — a test
  /// fails otherwise.
  static const List<String> tableOrder = [
    SQLiteConfig.settingsTable,
    SQLiteConfig.walletsTable,
    SQLiteConfig.tagsTable,
    SQLiteConfig.peopleTable,
    SQLiteConfig.recurringRulesTable,
    SQLiteConfig.transactionsTable,
    SQLiteConfig.transactionTagsTable,
    SQLiteConfig.recurringRuleTagsTable,
    SQLiteConfig.budgetsTable,
    SQLiteConfig.budgetWalletsTable,
    SQLiteConfig.budgetTagsTable,
    SQLiteConfig.debtsTable,
    SQLiteConfig.debtPaymentsTable,
    SQLiteConfig.mascotMemoryTable,
  ];

  /// Not backed up: a cache that is fetched again.
  static const Set<String> excludedTables = {SQLiteConfig.exchangeRatesTable};

  /// Everything in [db] (current schema), read in one transaction so the
  /// copy is consistent.
  Future<BackupTables> snapshot(Database db) => db.transaction(_read);

  /// Builds the staging database for [tables] made at [schemaVersion] and
  /// returns the validated rows in the current schema.
  Future<StagedBackup> stage(BackupTables tables, int schemaVersion) async {
    final ddl = SQLiteSchema.forVersion(schemaVersion);
    if (ddl == null) {
      throw BackupException(
        schemaVersion > SQLiteConfig.dbVersion ? BackupErrorReason.newerVersion : BackupErrorReason.notABackup,
      );
    }

    final staging = await _openStaging();
    try {
      // Off while loading and migrating (table rebuilds); checked explicitly
      // afterwards.
      await staging.execute('PRAGMA foreign_keys = OFF');
      final create = staging.batch();
      for (final statement in ddl) {
        create.execute(statement);
      }
      await create.commit(noResult: true);

      final columns = await _columns(staging);
      for (final name in tables.keys) {
        if (excludedTables.contains(name)) continue;
        if (!columns.containsKey(name) || !tableOrder.contains(name)) {
          throw BackupException(BackupErrorReason.invalidData, 'unknown table "$name"');
        }
      }

      try {
        await staging.transaction((txn) async {
          // The DDL seeds the settings row; the backup's replaces it.
          if ((tables[SQLiteConfig.settingsTable] ?? const []).isNotEmpty) {
            await txn.delete(SQLiteConfig.settingsTable);
          }
          await _insertAll(txn, tables, columns);
        });
      } on DatabaseException catch (e) {
        throw BackupException(BackupErrorReason.invalidData, e);
      }

      try {
        await SQLiteMigrations.upgrade(staging, schemaVersion, SQLiteConfig.dbVersion);
      } on DatabaseException catch (e) {
        throw BackupException(BackupErrorReason.invalidData, e);
      }

      await _verify(staging);
      return StagedBackup(await staging.transaction(_read));
    } finally {
      await staging.close();
    }
  }

  /// Replaces every backed-up table of [db] with [staged]. [settingsOverrides]
  /// is applied to the restored settings row in the same transaction.
  /// All or nothing.
  Future<void> replace(Database db, StagedBackup staged, {Map<String, Object?> settingsOverrides = const {}}) async {
    try {
      await db.transaction((txn) async {
        // Parents and children are deleted / inserted in bulk; the foreign
        // keys are checked once, at the end.
        await txn.execute('PRAGMA defer_foreign_keys = ON');
        final columns = await _columns(txn);
        for (final table in tableOrder.reversed) {
          if (columns.containsKey(table)) await txn.delete(table);
        }
        await _insertAll(txn, staged.tables, columns);
        if (settingsOverrides.isNotEmpty) {
          await txn.update(SQLiteConfig.settingsTable, settingsOverrides);
        }
        final violations = await txn.rawQuery('PRAGMA foreign_key_check');
        if (violations.isNotEmpty) {
          throw BackupException(BackupErrorReason.invalidData, 'foreign keys: ${violations.take(3).toList()}');
        }
      });
    } on DatabaseException catch (e) {
      throw BackupException(BackupErrorReason.invalidData, e);
    }
  }

  // --------------------------------------------------------------- internal

  Future<BackupTables> _read(DatabaseExecutor db) async {
    final columns = await _columns(db);
    final unknown = columns.keys.where((t) => !tableOrder.contains(t) && !excludedTables.contains(t));
    if (unknown.isNotEmpty) {
      // A table was added to the schema but not to [tableOrder]: refuse to
      // write a backup that would silently miss it.
      throw StateError('Tables missing from BackupDatabase.tableOrder: ${unknown.join(', ')}');
    }
    final out = <String, List<BackupRow>>{};
    for (final table in tableOrder) {
      if (!columns.containsKey(table)) continue;
      final rows = await db.query(table, orderBy: 'rowid');
      out[table] = [for (final r in rows) Map<String, Object?>.of(r)];
    }
    return out;
  }

  /// Inserts [tables] in [tableOrder]. Only known tables and columns reach
  /// the SQL (identifiers are never taken from the file unchecked).
  Future<void> _insertAll(Transaction txn, BackupTables tables, Map<String, Set<String>> columns) async {
    for (final table in tableOrder) {
      final rows = tables[table];
      final known = columns[table];
      if (rows == null || rows.isEmpty) continue;
      if (known == null) throw BackupException(BackupErrorReason.invalidData, 'unknown table "$table"');
      final batch = txn.batch();
      for (final row in rows) {
        for (final column in row.keys) {
          if (!known.contains(column)) {
            throw BackupException(BackupErrorReason.invalidData, 'unknown column "$table.$column"');
          }
        }
        batch.insert(table, row, conflictAlgorithm: ConflictAlgorithm.abort);
      }
      await batch.commit(noResult: true);
    }
  }

  Future<void> _verify(Database staging) async {
    final violations = await staging.rawQuery('PRAGMA foreign_key_check');
    if (violations.isNotEmpty) {
      throw BackupException(BackupErrorReason.invalidData, 'foreign keys: ${violations.take(3).toList()}');
    }
    final integrity = await staging.rawQuery('PRAGMA integrity_check');
    if (integrity.length != 1 || integrity.single.values.first != 'ok') {
      throw BackupException(BackupErrorReason.invalidData, 'integrity: $integrity');
    }
    final settings = Sqflite.firstIntValue(
      await staging.rawQuery('SELECT COUNT(*) FROM ${SQLiteConfig.settingsTable}'),
    );
    if (settings != 1) {
      throw BackupException(BackupErrorReason.invalidData, 'settings rows: $settings');
    }
  }

  /// User tables of [db] → their column names.
  static Future<Map<String, Set<String>>> _columns(DatabaseExecutor db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' AND name <> 'android_metadata'",
    );
    final out = <String, Set<String>>{};
    for (final t in tables) {
      final name = t['name']! as String;
      final info = await db.rawQuery('PRAGMA table_info("$name")');
      out[name] = {for (final c in info) c['name']! as String};
    }
    return out;
  }
}
