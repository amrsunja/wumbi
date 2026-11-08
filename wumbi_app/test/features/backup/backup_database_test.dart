import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wumbi/src/core/errors/exceptions/domain/domain_exceptions.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_schema.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:wumbi/src/features/backup/data/backup_codec.dart';
import 'package:wumbi/src/features/backup/data/backup_database.dart';

import '../../helpers/test_db.dart';
import 'backup_fixtures.dart';

Matcher _fails(BackupErrorReason reason) =>
    throwsA(isA<BackupException>().having((e) => e.reason, 'reason', reason));

/// A real database at an old schema version, from the frozen DDL.
Future<Database> _openAtVersion(int version) => databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: version,
        singleInstance: false,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) async {
          final batch = db.batch();
          for (final s in SQLiteSchema.forVersion(version)!) {
            batch.execute(s);
          }
          await batch.commit(noResult: true);
        },
      ),
    );

void main() {
  setUpAll(sqfliteFfiInit);

  late SQLiteServicesImpl source;
  late SQLiteServicesImpl target;
  final backup = ffiBackupDatabase();

  setUp(() async {
    source = ffiSqlite(inMemoryDatabasePath);
    await source.initDatabase();
    // A second, separate in-memory database for the restoring device.
    target = SQLiteServicesImpl(
      secureStorage: FakeSecureStorage(),
      overridePath: inMemoryDatabasePath,
      opener: ({required path, required password, required version, required onConfigure, required onCreate, required onUpgrade}) =>
          databaseFactoryFfi.openDatabase(
            path,
            options: OpenDatabaseOptions(
              version: version,
              singleInstance: false,
              onConfigure: onConfigure,
              onCreate: onCreate,
              onUpgrade: onUpgrade,
            ),
          ),
    );
    await target.initDatabase();
  });
  tearDown(() async {
    await source.close();
    await target.close();
  });

  test('tableOrder covers every table of the latest schema', () async {
    final tables = await source.db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
    );
    final names = tables.map((r) => r['name']! as String).toSet();
    expect(names, {...BackupDatabase.tableOrder, ...BackupDatabase.excludedTables});
  });

  test('snapshot → stage → replace reproduces the database exactly', () async {
    await seedEverything(source.db);
    await seedOtherDevice(target.db);

    final snapshot = await backup.snapshot(source.db);
    expect(snapshot.containsKey(SQLiteConfig.exchangeRatesTable), isFalse, reason: 'cache is not backed up');
    expect(snapshot['wallets'], hasLength(3), reason: 'soft-deleted rows travel too');

    final staged = await backup.stage(snapshot, SQLiteConfig.dbVersion);
    await backup.replace(target.db, staged);

    expect(await backup.snapshot(target.db), snapshot);
    expect(await target.db.query('transactions', where: "id = 't-local'"), isEmpty, reason: 'old data replaced');
    expect(staged.liveCount('wallets'), 2);
    expect(staged.liveCount('transactions'), 7);
  });

  test('settings overrides are applied in the same transaction', () async {
    await seedEverything(source.db);
    final staged = await backup.stage(await backup.snapshot(source.db), SQLiteConfig.dbVersion);
    await backup.replace(target.db, staged, settingsOverrides: {'notifications_enabled': 0, 'show_onboarding': 0});

    final settings = (await target.db.query('settings')).single;
    expect(settings['notifications_enabled'], 0);
    expect(settings['language_code'], 'ru');
    expect(settings['base_currency'], 'EUR');
    expect(settings['notification_prefs'], '{"recaps":false}');
  });

  test('a v1 backup is upgraded with the regular migrations', () async {
    final v1 = await _openAtVersion(1);
    addTearDown(v1.close);
    await v1.update('settings', {'base_currency': 'GBP', 'theme_mode': 'dark'});
    await v1.insert('wallets', {
      'id': 'w-1',
      'name': 'Old wallet',
      'currency': 'GBP',
      'initial_balance_minor': 5000,
      'color': 'amber',
      'is_primary': 1,
      'sort_order': 0,
      'created_at': t0,
      'updated_at': t0,
    });
    await v1.insert('tags', {'id': 'g-1', 'normalized_name': 'tea', 'display_name': 'Tea', 'created_at': t0, 'updated_at': t0});
    await v1.insert('transactions', {
      'id': 't-1',
      'type': 'expense',
      'wallet_id': 'w-1',
      'amount_minor': 250,
      'currency': 'GBP',
      'description': 'Tea',
      'transaction_date': t0,
      'created_at': t0,
      'updated_at': t0,
    });
    await v1.insert('transaction_tags', {'transaction_id': 't-1', 'tag_id': 'g-1', 'created_at': t0});

    // What a v1 app would have written.
    final v1Tables = <String, List<BackupRow>>{};
    for (final t in ['settings', 'wallets', 'tags', 'recurring_rules', 'transactions', 'transaction_tags', 'recurring_rule_tags']) {
      v1Tables[t] = [for (final r in await v1.query(t)) Map.of(r)];
    }

    final staged = await backup.stage(v1Tables, 1);
    await backup.replace(target.db, staged);

    final tx = (await target.db.query('transactions')).single;
    expect(tx['status'], 'posted', reason: 'v2 column default');
    expect(tx['debt_role'], isNull, reason: 'v4 column');
    final wallet = (await target.db.query('wallets')).single;
    expect(wallet['include_in_total'], 1, reason: 'v5 column default');
    final settings = (await target.db.query('settings')).single;
    expect(settings['base_currency'], 'GBP');
    expect(settings['mascot_talks'], 1, reason: 'v6 column default');
    expect(await target.db.query('transaction_tags'), hasLength(1));
    // Balance view works on the restored data.
    final balance = (await target.db.query(SQLiteConfig.walletBalancesView)).single;
    expect(balance[SQLiteConfig.balanceMinor], 5000 - 250);
  });

  test('every older schema version stages', () async {
    for (var v = 1; v <= SQLiteConfig.dbVersion; v++) {
      final db = await _openAtVersion(v);
      final tables = <String, List<BackupRow>>{
        'settings': [for (final r in await db.query('settings')) Map.of(r)],
      };
      await db.close();
      final staged = await backup.stage(tables, v);
      expect(staged.tables['settings'], hasLength(1), reason: 'v$v');
    }
  });

  test('a broken link is refused and the target is untouched', () async {
    await seedOtherDevice(target.db);
    final before = await backup.snapshot(target.db);

    final tables = await backup.snapshot(source.db)
      ..['transactions'] = [
        {
          'id': 't-x',
          'type': 'expense',
          'wallet_id': 'no-such-wallet',
          'amount_minor': 1,
          'currency': 'EUR',
          'transaction_date': t0,
          'created_at': t0,
          'updated_at': t0,
        },
      ];
    await expectLater(backup.stage(tables, SQLiteConfig.dbVersion), _fails(BackupErrorReason.invalidData));
    expect(await backup.snapshot(target.db), before);
  });

  test('CHECK constraints reject invalid values', () async {
    final tables = await backup.snapshot(source.db)
      ..['budgets'] = [
        {
          'id': 'b',
          'name': 'x',
          'limit_minor': -5,
          'currency': 'EUR',
          'period': 'monthly',
          'anchor_date': t0,
          'created_at': t0,
          'updated_at': t0,
        },
      ];
    await expectLater(backup.stage(tables, SQLiteConfig.dbVersion), _fails(BackupErrorReason.invalidData));
  });

  test('unknown tables and columns are refused', () async {
    final unknownTable = await backup.snapshot(source.db)..['passwords'] = [];
    await expectLater(backup.stage(unknownTable, SQLiteConfig.dbVersion), _fails(BackupErrorReason.invalidData));

    final unknownColumn = await backup.snapshot(source.db);
    unknownColumn['settings']!.first['evil'] = 1;
    await expectLater(backup.stage(unknownColumn, SQLiteConfig.dbVersion), _fails(BackupErrorReason.invalidData));

    // A table that only exists in a later schema, in an older backup.
    final tooEarly = <String, List<BackupRow>>{'budgets': []};
    await expectLater(backup.stage(tooEarly, 3), _fails(BackupErrorReason.invalidData));
  });

  test('replace rolls back completely when it fails half way', () async {
    await seedEverything(source.db);
    await seedOtherDevice(target.db);
    final before = await backup.snapshot(target.db);

    final staged = await backup.stage(await backup.snapshot(source.db), SQLiteConfig.dbVersion);
    // Sabotage after staging: a duplicate primary key in the last table.
    staged.tables['mascot_memory']!.add(Map.of(staged.tables['mascot_memory']!.first));

    await expectLater(backup.replace(target.db, staged), _fails(BackupErrorReason.invalidData));
    expect(await backup.snapshot(target.db), before);
  });
}
