import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/failures/failures.dart';
import '../../../core/local/database/secure_storage/secure_storage_config.dart';
import '../../../core/local/database/secure_storage/secure_storage_services.dart';
import '../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../core/local/database/sqlite/sqlite_services.dart';
import '../../../core/providers/local/secure_storage_provider.dart';
import '../../../core/providers/local/sqlite_database_provider.dart';
import '../../../core/utils/typedefs.dart';
import 'backup_codec.dart';
import 'backup_database.dart';
import 'csv_exporter.dart';

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => BackupRepository(
    services: ref.read(sqliteDataBaseProvider),
    secureStorage: ref.read(secureStorageServicesProvider),
  ),
);

/// A generated file, ready to be saved or shared.
class ExportedFile {
  const ExportedFile({required this.fileName, required this.bytes, required this.mimeType});

  final String fileName;
  final Uint8List bytes;
  final String mimeType;
}

/// A backup that was read, unlocked and validated — what the user confirms
/// before anything is replaced.
class BackupPreview {
  const BackupPreview({
    required this.createdAt,
    required this.appVersion,
    required this.encrypted,
    required this.staged,
    this.isSafetySnapshot = false,
  });

  final DateTime createdAt;
  final String appVersion;
  final bool encrypted;
  final StagedBackup staged;

  /// The automatic copy taken before the last restore ("Undo").
  final bool isSafetySnapshot;

  int get wallets => staged.liveCount(SQLiteConfig.walletsTable);
  int get transactions => staged.liveCount(SQLiteConfig.transactionsTable);
  int get tags => staged.liveCount(SQLiteConfig.tagsTable);
  int get budgets => staged.liveCount(SQLiteConfig.budgetsTable);
  int get debts => staged.liveCount(SQLiteConfig.debtsTable);
  int get subscriptions => staged.liveCount(SQLiteConfig.recurringRulesTable);
}

/// Export, inspect and restore `.wumbi` backups; export CSV.
///
/// Heavy work (JSON, gzip, Argon2id, AES-GCM) runs in a background isolate
/// so the UI keeps animating. Restoring always goes through
/// [BackupDatabase.stage] and replaces the data in a single transaction.
/// Before a restore, the current data is saved as an encrypted safety
/// snapshot (key in secure storage) so the user can undo it.
class BackupRepository {
  BackupRepository({
    required this.services,
    required this.secureStorage,
    BackupDatabase? database,
    Future<String> Function()? appVersion,
    Future<Directory> Function()? supportDirectory,
    DateTime Function()? clock,
    this.kdf = const BackupKdfParams(),
  }) : _database = database ?? BackupDatabase(),
       _appVersion = appVersion ?? _platformVersion,
       _supportDirectory = supportDirectory ?? getApplicationSupportDirectory,
       _clock = clock ?? DateTime.now;

  final SQLiteServices services;
  final SecureStorageServices secureStorage;
  final BackupKdfParams kdf;
  final BackupDatabase _database;
  final Future<String> Function() _appVersion;
  final Future<Directory> Function() _supportDirectory;
  final DateTime Function() _clock;

  static Future<String> _platformVersion() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  // ----------------------------------------------------------------- export

  /// Everything in the database as a `.wumbi` file; encrypted when a
  /// [password] is given.
  Future<SuccessOrError<ExportedFile>> createBackup({String? password}) => Failure.exceptionsCatcher(() async {
    final now = _clock();
    final bytes = await _encodeCurrent(createdAt: now, key: password == null ? null : BackupPassword(password));
    return ExportedFile(
      fileName: 'wumbi-backup-${_fileDate(now)}.${BackupFormat.fileExtension}',
      bytes: bytes,
      mimeType: BackupFormat.mimeType,
    );
  });

  /// Transactions for spreadsheets — not a backup (see [CsvExporter]).
  Future<SuccessOrError<ExportedFile>> createCsv() => Failure.exceptionsCatcher(() async {
    final bytes = await const CsvExporter().export(services.db);
    return ExportedFile(
      fileName: 'wumbi-transactions-${_fileDate(_clock())}.csv',
      bytes: bytes,
      mimeType: CsvExporter.mimeType,
    );
  });

  // ----------------------------------------------------------------- import

  /// Step 1: recognise the file. Tells whether a password is needed.
  Future<SuccessOrError<BackupEnvelope>> readBackup(Uint8List bytes, {String? fileName}) =>
      Failure.exceptionsCatcher(() => _parseInBackground(bytes, fileName));

  /// Step 2: unlock (if encrypted), decompress and validate. Nothing is
  /// written to the user's database yet.
  Future<SuccessOrError<BackupPreview>> openBackup(BackupEnvelope envelope, {String? password}) =>
      Failure.exceptionsCatcher(() => _open(envelope, password == null ? null : BackupPassword(password)));

  /// Step 3: replace all data with [preview]. A snapshot of the current
  /// data is kept first (unless this *is* the snapshot being restored).
  Future<SuccessOrError<void>> restore(BackupPreview preview) => Failure.exceptionsCatcher(() async {
    final db = services.db;
    final current = await db.query(SQLiteConfig.settingsTable, limit: 1);
    // The master switch follows this device's OS permission, not the
    // device the backup came from; onboarding is done either way.
    final overrides = <String, Object?>{
      SQLiteConfig.showOnboarding: 0,
      SQLiteConfig.notificationsEnabled: current.isEmpty ? 0 : current.first[SQLiteConfig.notificationsEnabled],
    };

    if (preview.isSafetySnapshot) {
      await _database.replace(db, preview.staged, settingsOverrides: overrides);
      await deleteSafetySnapshot();
      return;
    }

    final pending = await _snapshotFile(pending: true, create: true);
    try {
      await pending.writeAsBytes(
        await _encodeCurrent(createdAt: _clock(), key: BackupDeviceKey(await _snapshotKey())),
        flush: true,
      );
      await _database.replace(db, preview.staged, settingsOverrides: overrides);
      // Only a successful restore replaces the previous undo point.
      await pending.rename((await _snapshotFile()).path);
    } finally {
      if (await pending.exists()) await pending.delete();
    }
  });

  // ------------------------------------------------------- safety snapshot

  /// When the undo point was taken, or null when there is none.
  Future<DateTime?> safetySnapshotDate() async {
    try {
      final file = await _snapshotFile();
      return await file.exists() ? await file.lastModified() : null;
    } catch (_) {
      return null;
    }
  }

  Future<SuccessOrError<BackupPreview>> openSafetySnapshot() => Failure.exceptionsCatcher(() async {
    final bytes = await (await _snapshotFile()).readAsBytes();
    final envelope = await _parseInBackground(bytes, null);
    final preview = await _open(envelope, BackupDeviceKey(await _snapshotKey()));
    return BackupPreview(
      createdAt: preview.createdAt,
      appVersion: preview.appVersion,
      encrypted: true,
      staged: preview.staged,
      isSafetySnapshot: true,
    );
  });

  /// Removes the undo point and its key (Reset All Data, or after undo).
  Future<void> deleteSafetySnapshot() async {
    try {
      final dir = Directory('${(await _supportDirectory()).path}${Platform.pathSeparator}$_snapshotDir');
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {}
    await secureStorage.deleteData(SecureStorageConfig.backupSnapshotKey);
  }

  // --------------------------------------------------------------- internal

  static const _snapshotDir = 'backups';
  static const _snapshotName = 'before-restore.${BackupFormat.fileExtension}';

  Future<Uint8List> _encodeCurrent({required DateTime createdAt, BackupKey? key}) async {
    final tables = await _database.snapshot(services.db);
    return _encodeInBackground(tables, createdAt, await _appVersion(), key, kdf);
  }

  Future<BackupPreview> _open(BackupEnvelope envelope, BackupKey? key) async {
    final tables = await _openInBackground(envelope, key);
    final staged = await _database.stage(tables, envelope.schemaVersion);
    return BackupPreview(
      createdAt: envelope.createdAt,
      appVersion: envelope.appVersion,
      encrypted: envelope.isEncrypted,
      staged: staged,
    );
  }

  Future<File> _snapshotFile({bool pending = false, bool create = false}) async {
    final dir = Directory('${(await _supportDirectory()).path}${Platform.pathSeparator}$_snapshotDir');
    if (create) await dir.create(recursive: true);
    return File('${dir.path}${Platform.pathSeparator}${pending ? '$_snapshotName.tmp' : _snapshotName}');
  }

  Future<List<int>> _snapshotKey() async {
    const name = SecureStorageConfig.backupSnapshotKey;
    final existing = await secureStorage.readData(name);
    if (existing != null && existing.isNotEmpty) return base64Decode(existing);
    final random = Random.secure();
    final key = List<int>.generate(32, (_) => random.nextInt(256));
    await secureStorage.writeData(name, base64Encode(key));
    return key;
  }

  static String _fileDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// Isolate entry points are top-level so their closures capture only the
// plain data passed in (never the repository or the database handle).

Future<BackupEnvelope> _parseInBackground(Uint8List bytes, String? fileName) =>
    Isolate.run(() => BackupCodec.parse(bytes, fileName: fileName));

Future<BackupTables> _openInBackground(BackupEnvelope envelope, BackupKey? key) =>
    Isolate.run(() => BackupCodec.open(envelope, key: key));

Future<Uint8List> _encodeInBackground(
  BackupTables tables,
  DateTime createdAt,
  String appVersion,
  BackupKey? key,
  BackupKdfParams kdf,
) => Isolate.run(
  () => BackupCodec.encode(
    tables: tables,
    createdAt: createdAt,
    appVersion: appVersion,
    schemaVersion: SQLiteConfig.dbVersion,
    key: key,
    kdf: kdf,
  ),
);
