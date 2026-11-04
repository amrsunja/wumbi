import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' show Sqflite;
import 'package:wumbi/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_schema.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:wumbi/src/features/notification/domain/notification_prefs.dart';
import 'package:wumbi/src/features/settings/data/models/app_settings.dart';

import '../helpers/test_db.dart';

/// A real v6 file, created from the frozen v6 DDL.
Future<Database> _createV6(String path) => databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 6,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) async {
          final batch = db.batch();
          for (final statement in SQLiteSchema.v6) {
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
    dir = await Directory.systemTemp.createTemp('wumbi_migration_v7');
    path = '${dir.path}/wumbi.db';
  });
  tearDown(() async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  test('v6 → v7 adds settings.notification_prefs (NULL = defaults), keeps the master switch', () async {
    final v6 = await _createV6(path);
    await v6.update('settings', {'notifications_enabled': 1}, where: 'id = 1');
    await v6.close();

    final service = ffiSqlite(path);
    await service.initDatabase();
    addTearDown(service.close);

    expect(Sqflite.firstIntValue(await service.db.rawQuery('PRAGMA user_version')), SQLiteConfig.dbVersion);
    final settings = AppSettingsModel.fromJson((await service.db.query('settings')).single);
    expect(settings.notificationsEnabled, isTrue);
    expect(settings.notificationPrefs, const NotificationPrefs());

    const prefs = NotificationPrefs(recaps: false, morningBudget: true);
    await service.db.update('settings', {SQLiteConfig.notificationPrefs: prefs.encode()}, where: 'id = 1');
    final reread = AppSettingsModel.fromJson((await service.db.query('settings')).single);
    expect(reread.notificationPrefs, prefs);
  });

  test('a fresh v7 install has the same settings columns as a migrated v6 one', () async {
    final fresh = ffiSqlite('${dir.path}/fresh.db');
    await fresh.initDatabase();
    addTearDown(fresh.close);

    final v6 = await _createV6(path);
    await v6.close();
    final migrated = ffiSqlite(path);
    await migrated.initDatabase();
    addTearDown(migrated.close);

    Future<List<String>> columns(SQLiteServicesImpl s, String table) async {
      final rows = await s.db.rawQuery('PRAGMA table_info($table)');
      return rows.map((r) => '${r['name']}|${r['type']}|${r['notnull']}|${r['dflt_value']}|${r['pk']}').toList()
        ..sort();
    }

    expect(await columns(migrated, 'settings'), await columns(fresh, 'settings'));
  });
}
