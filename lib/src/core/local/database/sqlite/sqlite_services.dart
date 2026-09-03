import 'dart:convert';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../errors/exceptions/database/database_exception.dart' as ex;
import '../../../utils/debug_print.dart';
import '../secure_storage/secure_storage_config.dart';
import '../secure_storage/secure_storage_services.dart';
import 'sqlite_config.dart';
import 'sqlite_migrations.dart';
import 'sqlite_schema.dart';

/// Opens the encrypted database. Abstracted so tests can inject an
/// in-memory `sqflite_common_ffi` database without SQLCipher.
typedef DatabaseOpener = Future<Database> Function({
  required String path,
  required String password,
  required int version,
  required OnDatabaseConfigureFn onConfigure,
  required OnDatabaseCreateFn onCreate,
  required OnDatabaseVersionChangeFn onUpgrade,
});

abstract class SQLiteServices {
  Database get db;
  bool get isOpen;

  /// Opens the DB (key from secure storage, `PRAGMA foreign_keys = ON`,
  /// migrations). Idempotent.
  Future<void> initDatabase();

  Future<void> close();

  /// Reset All Data: close, delete the file, drop the SQLCipher key, re-open
  /// with a fresh schema and default settings (`show_onboarding = 1`).
  Future<void> resetAllData();
}

class SQLiteServicesImpl implements SQLiteServices {
  SQLiteServicesImpl({
    required this.secureStorage,
    DatabaseOpener? opener,
    String? overridePath,
  })  : _opener = opener ?? _defaultOpener,
        _overridePath = overridePath;

  final SecureStorageServices secureStorage;
  final DatabaseOpener _opener;
  final String? _overridePath;

  Database? _database;

  static Future<Database> _defaultOpener({
    required String path,
    required String password,
    required int version,
    required OnDatabaseConfigureFn onConfigure,
    required OnDatabaseCreateFn onCreate,
    required OnDatabaseVersionChangeFn onUpgrade,
  }) =>
      openDatabase(
        path,
        password: password,
        version: version,
        onConfigure: onConfigure,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
      );

  @override
  bool get isOpen => _database?.isOpen ?? false;

  @override
  Database get db {
    final database = _database;
    if (database == null || !database.isOpen) {
      throw const ex.DatabaseException(
        type: ex.DatabaseExceptionType.read,
        message: 'The database is not initialized',
      );
    }
    return database;
  }

  Future<String> _dbPath() async =>
      _overridePath ?? p.join(await getDatabasesPath(), SQLiteConfig.dbFileName);

  @override
  Future<void> initDatabase() async {
    if (isOpen) return;

    final password = await _getOrCreateDbPassword();
    final path = await _dbPath();

    try {
      _database = await _opener(
        path: path,
        password: password,
        version: SQLiteConfig.dbVersion,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) async {
          final batch = db.batch();
          for (final statement in SQLiteSchema.v1) {
            batch.execute(statement);
          }
          await batch.commit(noResult: true);
          debugPrint('Created Wumbi database schema v$version');
        },
        onUpgrade: SQLiteMigrations.upgrade,
      );
      debugPrint('Opened Wumbi database');
    } catch (e) {
      debugPrint('Failed to open database: $e');
      throw ex.DatabaseException(
        message: 'Error when trying to open the database',
        type: ex.DatabaseExceptionType.read,
        data: e,
      );
    }
  }

  @override
  Future<void> close() async {
    final database = _database;
    _database = null;
    if (database != null && database.isOpen) {
      await database.close();
    }
  }

  @override
  Future<void> resetAllData() async {
    await close();
    final path = await _dbPath();
    try {
      await deleteDatabase(path);
    } catch (e) {
      throw ex.DatabaseException(
        message: 'Could not delete the database file',
        type: ex.DatabaseExceptionType.delete,
        data: e,
      );
    }
    await secureStorage.deleteData(SecureStorageConfig.sqfliteDbPasswordKey);
    await initDatabase();
  }

  Future<String> _getOrCreateDbPassword() async {
    const keyName = SecureStorageConfig.sqfliteDbPasswordKey;
    final existingKey = await secureStorage.readData(keyName);
    if (existingKey != null && existingKey.isNotEmpty) return existingKey;

    final password = _generateDbKey();
    await secureStorage.writeData(keyName, password);
    debugPrint('Generated and stored a new database key');
    return password;
  }

  /// 32 random bytes → AES-256 key material, base64url encoded.
  String _generateDbKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }
}

/// Current time as UTC epoch milliseconds — the storage format for timestamps.
int nowMs() => DateTime.now().toUtc().millisecondsSinceEpoch;
