import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' show Sqflite;
import 'package:wumbi/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_schema.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_services.dart';

import '../helpers/test_db.dart';

/// A real v3 file, created from the frozen v3 DDL.
Future<Database> _createV3(String path) => databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 3,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) async {
          final batch = db.batch();
          for (final statement in SQLiteSchema.v3) {
            batch.execute(statement);
          }
          await batch.commit(noResult: true);
        },
      ),
    );

const _viewSql = "SELECT sql FROM sqlite_master WHERE type = 'view' AND name = 'wallet_balances'";

void main() {
  late Directory dir;
  late String path;

  setUpAll(sqfliteFfiInit);
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('wumbi_migration_v4');
    path = '${dir.path}/wumbi.db';
  });
  tearDown(() async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  /// Seeds a v3 database and returns the balance view's SQL as v3 had it.
  Future<String> seedV3() async {
    final db = await _createV3(path);
    final now = DateTime.utc(2026, 9, 1).millisecondsSinceEpoch;
    await db.insert('wallets', {
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
    for (final (id, type, amount) in [('t1', 'income', 5000), ('t2', 'expense', 1200)]) {
      await db.insert('transactions', {
        'id': id,
        'type': type,
        'wallet_id': 'w1',
        'amount_minor': amount,
        'currency': 'EUR',
        'description': '',
        'transaction_date': now,
        'created_at': now,
        'updated_at': now,
      });
    }
    await db.insert('tags', {
      'id': 'g1',
      'normalized_name': 'food',
      'display_name': 'Food',
      'usage_count': 1,
      'created_at': now,
      'updated_at': now,
    });
    await db.insert('transaction_tags', {'transaction_id': 't2', 'tag_id': 'g1', 'created_at': now});
    final view = (await db.rawQuery(_viewSql)).single['sql']! as String;
    await db.close();
    return view;
  }

  Future<int> count(SQLiteServicesImpl s, String sql) async => Sqflite.firstIntValue(await s.db.rawQuery(sql)) ?? 0;

  test('v3 → v4 keeps rows, links, balances and the balance view', () async {
    final viewBefore = await seedV3();
    final service = ffiSqlite(path);
    await service.initDatabase();
    addTearDown(service.close);

    expect(await count(service, 'PRAGMA user_version'), SQLiteConfig.dbVersion);
    expect(SQLiteConfig.dbVersion, greaterThanOrEqualTo(4));
    expect(
      await count(service, "SELECT balance_minor FROM wallet_balances WHERE wallet_id = 'w1'"),
      13800,
    );
    expect(await count(service, 'SELECT COUNT(*) FROM transaction_tags'), 1);
    expect((await service.db.rawQuery(_viewSql)).single['sql'], viewBefore, reason: 'debt money is real money');

    final tx = (await service.db.query('transactions', where: "id = 't1'")).single;
    expect(tx.containsKey('debt_role'), isTrue);
    expect(tx['debt_role'], isNull);

    for (final table in ['budgets', 'budget_wallets', 'budget_tags', 'people', 'debts', 'debt_payments']) {
      expect(await count(service, 'SELECT COUNT(*) FROM $table'), 0, reason: table);
    }
    expect(await count(service, 'PRAGMA foreign_keys'), 1);
  });

  test('debt_role only accepts principal / repayment', () async {
    await seedV3();
    final service = ffiSqlite(path);
    await service.initDatabase();
    addTearDown(service.close);

    await service.db.update('transactions', {'debt_role': 'principal'}, where: "id = 't1'");
    await expectLater(
      service.db.update('transactions', {'debt_role': 'gift'}, where: "id = 't1'"),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('a fresh v4 install has the same shape as a migrated v3 one', () async {
    final fresh = ffiSqlite('${dir.path}/fresh.db');
    await fresh.initDatabase();
    addTearDown(fresh.close);

    await seedV3();
    final migrated = ffiSqlite(path);
    await migrated.initDatabase();
    addTearDown(migrated.close);

    Future<List<String>> objects(SQLiteServicesImpl s) async {
      final rows = await s.db.rawQuery(
        "SELECT type, name FROM sqlite_master WHERE name NOT LIKE 'sqlite_%' ORDER BY type, name",
      );
      return rows.map((r) => '${r['type']}:${r['name']}').toList();
    }

    final freshObjects = await objects(fresh);
    expect(await objects(migrated), freshObjects);

    // Raw `sql` text is not compared: ALTER TABLE rewrites it differently from
    // a fresh CREATE. Column order is not compared either (ADD COLUMN appends).
    Future<List<String>> columns(SQLiteServicesImpl s, String table) async {
      final rows = await s.db.rawQuery('PRAGMA table_info($table)');
      return rows
          .map((r) => '${r['name']}|${r['type']}|${r['notnull']}|${r['dflt_value']}|${r['pk']}')
          .toList()
        ..sort();
    }

    final tables = freshObjects.where((o) => o.startsWith('table:')).map((o) => o.substring(6));
    expect(tables, containsAll(['budgets', 'debts', 'debt_payments', 'people', 'budget_wallets', 'budget_tags']));
    for (final table in tables) {
      expect(await columns(migrated, table), await columns(fresh, table), reason: table);
    }
  });
}
