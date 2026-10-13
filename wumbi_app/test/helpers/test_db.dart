import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wumbi/src/core/fx/fx_service.dart';
import 'package:wumbi/src/core/local/database/secure_storage/secure_storage_services.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:wumbi/src/core/money/currency_type.dart';

/// In-memory secure storage for `SQLiteServicesImpl`.
class FakeSecureStorage implements SecureStorageServices {
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

/// Production `onConfigure` / `onCreate` / `onUpgrade` on the ffi factory
/// (no SQLCipher). [path] may be `inMemoryDatabasePath`.
SQLiteServicesImpl ffiSqlite(String path) => SQLiteServicesImpl(
      secureStorage: FakeSecureStorage(),
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

/// Deterministic FX: [rates] are both the "cached" and the "network" rates;
/// a missing pair is unavailable everywhere. Records `rate` calls so tests
/// can assert same-currency paths never touch FX.
class FakeFx implements FxService {
  FakeFx([Map<(CurrencyType, CurrencyType), double>? rates]) : rates = {...?rates};

  final Map<(CurrencyType, CurrencyType), double> rates;
  int networkCalls = 0;

  FxRate? _lookup(CurrencyType from, CurrencyType to) {
    if (from == to) return FxRate.identity(from);
    final r = rates[(from, to)];
    if (r == null) return null;
    return FxRate(from: from, to: to, rate: r, fetchedAt: DateTime.now(), isStale: false);
  }

  @override
  Future<FxRate?> cachedRate(CurrencyType from, CurrencyType to) async => _lookup(from, to);

  @override
  Future<FxRate> rate(CurrencyType from, CurrencyType to, {Duration maxAge = const Duration(hours: 12)}) async {
    if (from != to) networkCalls++;
    return _lookup(from, to) ?? (throw FxUnavailableException('No rate for ${from.code}→${to.code}'));
  }

  @override
  Future<void> warmUp(Set<CurrencyType> currencies, CurrencyType base) async {}
}
