import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wumbi/src/core/errors/exceptions/domain/domain_exceptions.dart';
import 'package:wumbi/src/core/errors/failures/failures.dart';
import 'package:wumbi/src/core/local/database/secure_storage/secure_storage_config.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:wumbi/src/features/backup/data/backup_codec.dart';
import 'package:wumbi/src/features/backup/data/backup_repository.dart';

import '../../helpers/test_db.dart';
import 'backup_fixtures.dart';

SQLiteServicesImpl _device() => SQLiteServicesImpl(
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

T _ok<T>(Result<T, Failure> r) => r.when((s) => s, (e) => fail('Expected success, got $e'));

BackupErrorReason? _reason<T>(Result<T, Failure> r) =>
    r.when((_) => null, (e) => e is BackupFailure ? e.reason : fail('Expected BackupFailure, got $e'));

void main() {
  setUpAll(sqfliteFfiInit);

  late Directory dir;
  late SQLiteServicesImpl phoneA;
  late SQLiteServicesImpl phoneB;
  late FakeSecureStorage storageB;
  late BackupRepository repoA;
  late BackupRepository repoB;

  BackupRepository repo(SQLiteServicesImpl services, FakeSecureStorage storage, String name) => BackupRepository(
        services: services,
        secureStorage: storage,
        database: ffiBackupDatabase(),
        appVersion: () async => '1.2.3+45',
        supportDirectory: () async => Directory('${dir.path}/$name')..createSync(recursive: true),
        clock: () => DateTime(2026, 11, 8, 9, 30),
        kdf: const BackupKdfParams(memoryKiB: 64, iterations: 1),
      );

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('wumbi_backup');
    phoneA = _device();
    phoneB = _device();
    await phoneA.initDatabase();
    await phoneB.initDatabase();
    await seedEverything(phoneA.db);
    await seedOtherDevice(phoneB.db);
    storageB = FakeSecureStorage();
    repoA = repo(phoneA, FakeSecureStorage(), 'a');
    repoB = repo(phoneB, storageB, 'b');
  });
  tearDown(() async {
    await phoneA.close();
    await phoneB.close();
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  Future<List<Map<String, Object?>>> rows(SQLiteServicesImpl s, String table) => s.db.query(table, orderBy: 'rowid');

  test('phone A → .wumbi file → phone B: every table and setting arrives', () async {
    final file = _ok(await repoA.createBackup());
    expect(file.fileName, 'wumbi-backup-2026-11-08.wumbi');

    final envelope = _ok(await repoB.readBackup(file.bytes, fileName: file.fileName));
    expect(envelope.needsPassword, isFalse);
    expect(envelope.appVersion, '1.2.3+45');

    final preview = _ok(await repoB.openBackup(envelope));
    expect(preview.wallets, 2);
    expect(preview.transactions, 7);
    expect(preview.tags, 2);
    expect(preview.budgets, 1);
    expect(preview.debts, 1);
    expect(preview.subscriptions, 1);

    _ok(await repoB.restore(preview));

    for (final table in ['wallets', 'tags', 'people', 'recurring_rules', 'transactions', 'transaction_tags',
        'recurring_rule_tags', 'budgets', 'budget_wallets', 'budget_tags', 'debts', 'debt_payments', 'mascot_memory']) {
      expect(await rows(phoneB, table), await rows(phoneA, table), reason: table);
    }
    final settings = (await rows(phoneB, 'settings')).single;
    expect(settings['language_code'], 'ru');
    expect(settings['theme_mode'], 'dark');
    expect(settings['base_currency'], 'EUR');
    expect(settings['mascot_talks'], 0);
    expect(settings['last_recurring_run_at'], t0 + 40 * day);
    expect(settings['show_onboarding'], 0);
    expect(settings['notifications_enabled'], 0, reason: 'phone B never granted notifications');
  });

  test('password-protected backup: wrong password changes nothing, right one restores', () async {
    final file = _ok(await repoA.createBackup(password: 'hamster-2026'));
    expect(utf8.decode(file.bytes, allowMalformed: true), isNot(contains('Salary')));

    final envelope = _ok(await repoB.readBackup(file.bytes));
    expect(envelope.needsPassword, isTrue);
    expect(_reason(await repoB.openBackup(envelope)), BackupErrorReason.passwordRequired);
    expect(_reason(await repoB.openBackup(envelope, password: 'hamster-2025')), BackupErrorReason.wrongPassword);
    expect(await rows(phoneB, 'transactions'), hasLength(1));

    final preview = _ok(await repoB.openBackup(envelope, password: 'hamster-2026'));
    expect(preview.encrypted, isTrue);
    _ok(await repoB.restore(preview));
    expect(await rows(phoneB, 'transactions'), await rows(phoneA, 'transactions'));
  });

  test('restore keeps an encrypted undo point; undo brings the old data back', () async {
    final before = await rows(phoneB, 'transactions');
    expect(await repoB.safetySnapshotDate(), isNull);

    final preview = _ok(await repoB.openBackup(_ok(await repoB.readBackup(_ok(await repoA.createBackup()).bytes))));
    _ok(await repoB.restore(preview));

    expect(await repoB.safetySnapshotDate(), isNotNull);
    final snapshotFile = File('${dir.path}/b/backups/before-restore.wumbi');
    expect(snapshotFile.existsSync(), isTrue);
    expect(File('${snapshotFile.path}.tmp').existsSync(), isFalse);
    // Encrypted at rest with the device key.
    expect(utf8.decode(snapshotFile.readAsBytesSync()), isNot(contains('Coffee')));
    expect(await storageB.readData(SecureStorageConfig.backupSnapshotKey), isNotNull);

    final undo = _ok(await repoB.openSafetySnapshot());
    expect(undo.isSafetySnapshot, isTrue);
    expect(undo.transactions, 1);
    _ok(await repoB.restore(undo));

    expect(await rows(phoneB, 'transactions'), before);
    expect(await repoB.safetySnapshotDate(), isNull, reason: 'undo is one-shot');
    expect(await storageB.readData(SecureStorageConfig.backupSnapshotKey), isNull);
  });

  test('a failed restore keeps the data and the previous undo point', () async {
    final good = _ok(await repoB.openBackup(_ok(await repoB.readBackup(_ok(await repoA.createBackup()).bytes))));
    _ok(await repoB.restore(good));
    final undoDate = await repoB.safetySnapshotDate();
    final current = await rows(phoneB, 'transactions');

    final bad = _ok(await repoB.openBackup(_ok(await repoB.readBackup(_ok(await repoA.createBackup()).bytes))));
    bad.staged.tables['mascot_memory']!.add(Map.of(bad.staged.tables['mascot_memory']!.first));
    expect(_reason(await repoB.restore(bad)), BackupErrorReason.invalidData);

    expect(await rows(phoneB, 'transactions'), current);
    expect(await repoB.safetySnapshotDate(), undoDate);
    expect(_ok(await repoB.openSafetySnapshot()).transactions, 1, reason: 'still the pre-first-restore data');
  });

  test('deleteSafetySnapshot removes the file and the key', () async {
    final preview = _ok(await repoB.openBackup(_ok(await repoB.readBackup(_ok(await repoA.createBackup()).bytes))));
    _ok(await repoB.restore(preview));
    await repoB.deleteSafetySnapshot();
    expect(await repoB.safetySnapshotDate(), isNull);
    expect(Directory('${dir.path}/b/backups').existsSync(), isFalse);
    expect(await storageB.readData(SecureStorageConfig.backupSnapshotKey), isNull);
  });

  test('the CSV export is refused as a backup', () async {
    final csv = _ok(await repoA.createCsv());
    expect(csv.fileName, 'wumbi-transactions-2026-11-08.csv');
    expect(_reason(await repoB.readBackup(csv.bytes, fileName: csv.fileName)), BackupErrorReason.csvNotRestorable);
    expect(_reason(await repoB.readBackup(csv.bytes, fileName: 'renamed.wumbi')), BackupErrorReason.csvNotRestorable);
  });

  test('a device snapshot file cannot be imported as a backup', () async {
    final preview = _ok(await repoB.openBackup(_ok(await repoB.readBackup(_ok(await repoA.createBackup()).bytes))));
    _ok(await repoB.restore(preview));
    final bytes = File('${dir.path}/b/backups/before-restore.wumbi').readAsBytesSync();
    final envelope = _ok(await repoA.readBackup(bytes));
    expect(_reason(await repoA.openBackup(envelope, password: 'anything')), BackupErrorReason.notABackup);
  });
}
