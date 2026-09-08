import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' show Sqflite;
import 'package:wumbi/src/core/local/database/secure_storage/secure_storage_services.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_schema.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_services.dart';

class _FakeSecureStorage implements SecureStorageServices {
  final Map<String, String> _data = {};

  @override
  Future<String?> readData(String key) async => _data[key];

  @override
  Future<void> writeData(String key, String? value) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> deleteData(String key) async => _data.remove(key);
}

/// Opens [path] through `SQLiteServicesImpl` (so `onConfigure` / `onUpgrade`
/// are exactly the production ones) but on the ffi factory, without SQLCipher.
SQLiteServicesImpl _service(String path) => SQLiteServicesImpl(
      secureStorage: _FakeSecureStorage(),
      overridePath: path,
      opener: ({
        required path,
        required password,
        required version,
        required onConfigure,
        required onCreate,
        required onUpgrade,
      }) =>
          databaseFactoryFfi.openDatabase(
            path,
            options: OpenDatabaseOptions(
              version: version,
              onConfigure: onConfigure,
              onCreate: onCreate,
              onUpgrade: onUpgrade,
            ),
          ),
    );

Future<Database> _createV1(String path) => databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) async {
          final batch = db.batch();
          for (final statement in SQLiteSchema.v1) {
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
    dir = await Directory.systemTemp.createTemp('wumbi_migration');
    path = '${dir.path}/wumbi.db';
  });
  tearDown(() async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  Future<void> seedV1() async {
    final db = await _createV1(path);
    final now = DateTime.utc(2026, 1, 1).millisecondsSinceEpoch;
    await db.insert('wallets', {
      'id': 'w1',
      'name': 'Checking',
      'currency': 'USD',
      'initial_balance_minor': 10000,
      'color': 'blue',
      'is_primary': 1,
      'sort_order': 0,
      'created_at': now,
      'updated_at': now,
    });
    await db.insert('transactions', {
      'id': 't1',
      'type': 'income',
      'wallet_id': 'w1',
      'amount_minor': 5000,
      'currency': 'USD',
      'description': 'Salary',
      'transaction_date': now,
      'created_at': now,
      'updated_at': now,
    });
    await db.insert('tags', {
      'id': 'g1',
      'normalized_name': 'rent',
      'display_name': 'Rent',
      'usage_count': 1,
      'created_at': now,
      'updated_at': now,
    });
    await db.insert('transaction_tags', {'transaction_id': 't1', 'tag_id': 'g1', 'created_at': now});
    await db.close();
  }

  Future<int> balance(SQLiteServicesImpl service) async => Sqflite.firstIntValue(
        await service.db.rawQuery('SELECT balance_minor FROM wallet_balances WHERE wallet_id = ?', ['w1']),
      )!;

  test('v1 → v2 keeps rows, links and balances', () async {
    await seedV1();
    final service = _service(path);
    await service.initDatabase();
    addTearDown(service.close);

    expect(await balance(service), 15000);
    expect(
      Sqflite.firstIntValue(await service.db.rawQuery('SELECT COUNT(*) FROM transaction_tags')),
      1,
      reason: 'links to the rebuilt wallets table survive',
    );
    final wallet = (await service.db.query('wallets')).single;
    expect(wallet['name'], 'Checking');
    expect(wallet['is_primary'], 1);

    // Foreign keys are enforced again once the upgrade is done.
    expect(
      Sqflite.firstIntValue(await service.db.rawQuery('PRAGMA foreign_keys')),
      1,
    );
  });

  test('v2 accepts the new wallet colours and defaults status to posted', () async {
    await seedV1();
    final service = _service(path);
    await service.initDatabase();
    addTearDown(service.close);

    // v1 had CHECK (color IN ('blue','amber','red','green','violet')).
    await service.db.update('wallets', {'color': 'fuchsia'}, where: 'id = ?', whereArgs: ['w1']);
    expect((await service.db.query('wallets')).single['color'], 'fuchsia');

    final row = (await service.db.query('transactions')).single;
    expect(row['status'], 'posted');
  });

  test('upcoming rows are excluded from the balance until they post', () async {
    await seedV1();
    final service = _service(path);
    await service.initDatabase();
    addTearDown(service.close);

    final future = DateTime.utc(2027, 1, 1).millisecondsSinceEpoch;
    await service.db.insert('transactions', {
      'id': 't2',
      'type': 'expense',
      'wallet_id': 'w1',
      'amount_minor': 2500,
      'currency': 'USD',
      'description': 'Rent',
      'transaction_date': future,
      'status': 'upcoming',
      'created_at': future,
      'updated_at': future,
    });
    expect(await balance(service), 15000, reason: 'not counted while upcoming');

    await service.db.update('transactions', {'status': 'posted'}, where: 'id = ?', whereArgs: ['t2']);
    expect(await balance(service), 12500);
  });

  test('v3 adds show_mascot, visible by default', () async {
    await seedV1();
    final service = _service(path);
    await service.initDatabase();
    addTearDown(service.close);

    final settings = (await service.db.query('settings')).single;
    expect(settings['show_mascot'], 1);

    await service.db.update('settings', {'show_mascot': 0}, where: 'id = ?', whereArgs: [1]);
    expect((await service.db.query('settings')).single['show_mascot'], 0);
  });

  test('a fresh v2 install has the same shape as a migrated one', () async {
    final fresh = _service('${dir.path}/fresh.db');
    await fresh.initDatabase();
    addTearDown(fresh.close);

    await seedV1();
    final migrated = _service(path);
    await migrated.initDatabase();
    addTearDown(migrated.close);

    Future<List<String>> shape(SQLiteServicesImpl s) async {
      final rows = await s.db.rawQuery(
        "SELECT type, name, sql FROM sqlite_master WHERE name NOT LIKE 'sqlite_%' ORDER BY type, name",
      );
      return rows.map((r) => '${r['type']}:${r['name']}').toList();
    }

    expect(await shape(migrated), await shape(fresh));

    // Sorted: `ALTER TABLE ... ADD COLUMN` appends `status` at the end, while
    // the fresh DDL declares it mid-table. Only the set matters.
    Future<List<String>> columns(SQLiteServicesImpl s, String table) async {
      final rows = await s.db.rawQuery('PRAGMA table_info($table)');
      return rows.map((r) => r['name'] as String).toList()..sort();
    }

    for (final table in ['settings', 'wallets', 'transactions', 'tags', 'recurring_rules']) {
      expect(await columns(migrated, table), await columns(fresh, table), reason: table);
    }
  });
}
