import 'package:flutter/foundation.dart';

import '../money/currency_type.dart';

export '../errors/exceptions/domain/domain_exceptions.dart' show FxUnavailableException;

/// A cached or freshly fetched rate: `quote per 1 unit of base`.
@immutable
class FxRate {
  const FxRate({
    required this.from,
    required this.to,
    required this.rate,
    required this.fetchedAt,
    required this.isStale,
  });

  factory FxRate.identity(CurrencyType c) => FxRate(
        from: c,
        to: c,
        rate: 1.0,
        fetchedAt: DateTime.now(),
        isStale: false,
      );

  final CurrencyType from;
  final CurrencyType to;
  final double rate;
  final DateTime fetchedAt;

  /// Older than the requested `maxAge` and could not be refreshed (offline).
  final bool isStale;

  FxRate copyWith({bool? isStale}) => FxRate(
        from: from,
        to: to,
        rate: rate,
        fetchedAt: fetchedAt,
        isStale: isStale ?? this.isStale,
      );

  @override
  String toString() => 'FxRate(1 ${from.code} = $rate ${to.code}, stale: $isStale)';
}

abstract class FxService {
  /// Returns the cached rate if fresher than [maxAge] (default 12h), otherwise
  /// fetches and caches. Falls back to the stale cached rate when offline.
  /// Throws [FxUnavailableException] when nothing is cached and fetching fails.
  Future<FxRate> rate(
    CurrencyType from,
    CurrencyType to, {
    Duration maxAge = const Duration(hours: 12),
  });

  /// Cached rate only — never touches the network. `null` when not cached.
  Future<FxRate?> cachedRate(CurrencyType from, CurrencyType to);

  /// Best effort refresh of every `currency → base` pair. Never throws.
  Future<void> warmUp(Set<CurrencyType> currencies, CurrencyType base);
}
