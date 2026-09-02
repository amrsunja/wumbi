import 'package:currency_converter/currency.dart';
import 'package:currency_converter/currency_converter.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' show ConflictAlgorithm;

import '../errors/exceptions/domain/domain_exceptions.dart';
import '../local/database/sqlite/sqlite_config.dart';
import '../local/database/sqlite/sqlite_services.dart';
import '../money/currency_type.dart';
import '../utils/debug_print.dart';
import 'fx_service.dart';

/// Fetches a single rate (`to` per 1 `from`). Returns null when unavailable.
typedef RateFetcher = Future<double?> Function(CurrencyType from, CurrencyType to);

/// [FxService] backed by `currency_converter` (fawazahmed0/currency-api) with
/// the `exchange_rates` table as a local cache.
class FxServiceImpl implements FxService {
  FxServiceImpl({
    required this.sqlite,
    RateFetcher? fetcher,
    this.staleAfter = const Duration(hours: 24),
  }) : _fetcher = fetcher ?? _fetchWithPackage;

  final SQLiteServices sqlite;
  final RateFetcher _fetcher;

  /// Rates older than this are reported as `isStale` (dashboard caption).
  final Duration staleAfter;

  /// In-flight fetches so a burst of callers for the same pair share one request.
  final Map<String, Future<double?>> _inFlight = {};

  static Future<double?> _fetchWithPackage(CurrencyType from, CurrencyType to) async {
    try {
      final value = await CurrencyConverter.convert(
        from: _toPackageCurrency(from),
        to: _toPackageCurrency(to),
        amount: 1,
        withoutRounding: true,
      );
      if (value == null || value <= 0 || !value.isFinite) return null;
      return value;
    } catch (e) {
      debugPrint('FX fetch failed for ${from.code}→${to.code}: $e');
      return null;
    }
  }

  static Currency _toPackageCurrency(CurrencyType c) {
    if (c == CurrencyType.tryLira) return Currency.turkisL;
    return Currency.values.byName(c.code.toLowerCase());
  }

  /// Device locale currency mapped to [CurrencyType]; USD when unsupported.
  static Future<CurrencyType> deviceCurrency() async {
    try {
      final c = await CurrencyConverter.getMyCurrency();
      if (c == Currency.turkisL) return CurrencyType.tryLira;
      return CurrencyType.tryFromCode(c.name) ?? CurrencyType.usd;
    } catch (_) {
      return CurrencyType.usd;
    }
  }

  @override
  Future<FxRate?> cachedRate(CurrencyType from, CurrencyType to) async {
    if (from == to) return FxRate.identity(from);
    final rows = await sqlite.db.query(
      SQLiteConfig.exchangeRatesTable,
      columns: [SQLiteConfig.fxRate, SQLiteConfig.fxFetchedAt],
      where: '${SQLiteConfig.fxBase} = ? AND ${SQLiteConfig.fxQuote} = ?',
      whereArgs: [from.code, to.code],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final fetchedAt = DateTime.fromMillisecondsSinceEpoch(
      row[SQLiteConfig.fxFetchedAt] as int,
      isUtc: true,
    ).toLocal();
    return FxRate(
      from: from,
      to: to,
      rate: (row[SQLiteConfig.fxRate] as num).toDouble(),
      fetchedAt: fetchedAt,
      isStale: DateTime.now().difference(fetchedAt) > staleAfter,
    );
  }

  @override
  Future<FxRate> rate(
    CurrencyType from,
    CurrencyType to, {
    Duration maxAge = const Duration(hours: 12),
  }) async {
    if (from == to) return FxRate.identity(from);

    final cached = await cachedRate(from, to);
    if (cached != null && DateTime.now().difference(cached.fetchedAt) <= maxAge) {
      return cached.copyWith(isStale: false);
    }

    final fresh = await _fetchAndCache(from, to);
    if (fresh != null) return fresh;

    if (cached != null) return cached.copyWith(isStale: true);
    throw FxUnavailableException('No rate for ${from.code}→${to.code}');
  }

  @override
  Future<void> warmUp(Set<CurrencyType> currencies, CurrencyType base) async {
    final pairs = currencies.where((c) => c != base).toList();
    await Future.wait(
      pairs.map((c) async {
        try {
          await rate(c, base);
        } catch (e) {
          debugPrint('warmUp: ${c.code}→${base.code} unavailable ($e)');
        }
      }),
    );
  }

  Future<FxRate?> _fetchAndCache(CurrencyType from, CurrencyType to) async {
    final key = '${from.code}:${to.code}';
    final future = _inFlight.putIfAbsent(key, () => _fetcher(from, to));
    double? value;
    try {
      value = await future;
    } finally {
      _inFlight.remove(key);
    }
    if (value == null) return null;

    final now = nowMs();
    await sqlite.db.insert(
      SQLiteConfig.exchangeRatesTable,
      {
        SQLiteConfig.fxBase: from.code,
        SQLiteConfig.fxQuote: to.code,
        SQLiteConfig.fxRate: value,
        SQLiteConfig.fxFetchedAt: now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Cache the inverse as well: it is exact enough for display/conversion and
    // saves a network round-trip for the opposite direction.
    await sqlite.db.insert(
      SQLiteConfig.exchangeRatesTable,
      {
        SQLiteConfig.fxBase: to.code,
        SQLiteConfig.fxQuote: from.code,
        SQLiteConfig.fxRate: 1 / value,
        SQLiteConfig.fxFetchedAt: now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return FxRate(
      from: from,
      to: to,
      rate: value,
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true).toLocal(),
      isStale: false,
    );
  }
}
