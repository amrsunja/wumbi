import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' show Sqflite;
import 'package:wumbi/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_schema.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:wumbi/src/features/wallet/data/models/wallet_model.dart';

import '../helpers/test_db.dart';

/// A real v4 file, created from the frozen v4 DDL.
Future<Database> _createV4(String path) => databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 4,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) async {
          final batch = db.batch();
          for (final statement in SQLiteSchema.v4) {
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
    dir = await Directory.systemTemp.createTemp('wumbi_migration_v5');
    path = '${dir.path}/wumbi.db';
  });
  tearDown(() async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  test('v4 → v5 adds wallets.include_in_total, existing wallets keep counting', () async {
    final v4 = await _createV4(path);
    final now = DateTime.utc(2026, 10, 1).millisecondsSinceEpoch;
    await v4.insert('wallets', {
      'id': 'w1',
      'name': 'Card',
      'currency': 'EUR',
      'initial_balance_minor': 10000,
      'color': 'blue',
      'is_primary': 1,
      'sort_order': 0,
      'created_at': now,
      'updated_at': now,
    });
    await v4.close();

    final service = ffiSqlite(path);
    await service.initDatabase();
    addTearDown(service.close);

    expect(Sqflite.firstIntValue(await service.db.rawQuery('PRAGMA user_version')), SQLiteConfig.dbVersion);
    final row = (await service.db.query('wallets', where: "id = 'w1'")).single;
    expect(row[SQLiteConfig.walletIncludeInTotal], 1);
    expect(WalletModel.fromRow(row).includeInTotal, isTrue);

    await service.db.update('wallets', {SQLiteConfig.walletIncludeInTotal: 0}, where: "id = 'w1'");
    final updated = (await service.db.query('wallets', where: "id = 'w1'")).single;
    expect(WalletModel.fromRow(updated).includeInTotal, isFalse);
  });

  test('a fresh v5 install has the same wallets columns as a migrated v4 one', () async {
    final fresh = ffiSqlite('${dir.path}/fresh.db');
    await fresh.initDatabase();
    addTearDown(fresh.close);

    final v4 = await _createV4(path);
    await v4.close();
    final migrated = ffiSqlite(path);
    await migrated.initDatabase();
    addTearDown(migrated.close);

    Future<List<String>> columns(SQLiteServicesImpl s) async {
      final rows = await s.db.rawQuery('PRAGMA table_info(wallets)');
      return rows.map((r) => '${r['name']}|${r['type']}|${r['notnull']}|${r['dflt_value']}|${r['pk']}').toList()
        ..sort();
    }

    expect(await columns(migrated), await columns(fresh));
  });
}
