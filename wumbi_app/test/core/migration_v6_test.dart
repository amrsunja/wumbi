import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' show Sqflite;
import 'package:wumbi/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_schema.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:wumbi/src/features/settings/data/models/app_settings.dart';

import '../helpers/test_db.dart';

/// A real v5 file, created from the frozen v5 DDL.
Future<Database> _createV5(String path) => databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 5,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) async {
          final batch = db.batch();
          for (final statement in SQLiteSchema.v5) {
            batch.execute(statement);
          }
          await batch.commit(noResult: true);
        },
      ),
    );

void main() {
  late Directory dir;
  late String path;

  setUpAll(sqfliteFfiInit);
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('wumbi_migration_v6');
    path = '${dir.path}/wumbi.db';
  });
  tearDown(() async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  test('v5 → v6 adds settings.mascot_talks (on) and the mascot_memory table', () async {
    final v5 = await _createV5(path);
    await v5.update('settings', {'show_mascot': 0}, where: 'id = 1');
    await v5.close();

    final service = ffiSqlite(path);
    await service.initDatabase();
    addTearDown(service.close);

    expect(Sqflite.firstIntValue(await service.db.rawQuery('PRAGMA user_version')), SQLiteConfig.dbVersion);
    final settings = AppSettingsModel.fromJson((await service.db.query('settings')).single);
    expect(settings.mascotTalks, isTrue);
    expect(settings.showMascot, isFalse);

    await service.db.insert(SQLiteConfig.mascotMemoryTable, {
      SQLiteConfig.mascotKey: 'memory',
      SQLiteConfig.mascotValue: '{}',
      SQLiteConfig.updatedAt: 1,
    });
    expect(await service.db.query(SQLiteConfig.mascotMemoryTable), hasLength(1));
  });

  test('a fresh v6 install has the same settings / mascot_memory columns as a migrated v5 one', () async {
    final fresh = ffiSqlite('${dir.path}/fresh.db');
    await fresh.initDatabase();
    addTearDown(fresh.close);

    final v5 = await _createV5(path);
    await v5.close();
    final migrated = ffiSqlite(path);
    await migrated.initDatabase();
    addTearDown(migrated.close);

    Future<List<String>> columns(SQLiteServicesImpl s, String table) async {
      final rows = await s.db.rawQuery('PRAGMA table_info($table)');
      return rows.map((r) => '${r['name']}|${r['type']}|${r['notnull']}|${r['dflt_value']}|${r['pk']}').toList()
        ..sort();
    }

    for (final table in ['settings', SQLiteConfig.mascotMemoryTable]) {
      expect(await columns(migrated, table), await columns(fresh, table), reason: table);
    }
  });
}
