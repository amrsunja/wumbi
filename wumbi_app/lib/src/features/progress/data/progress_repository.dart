import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/failures/failures.dart';
import '../../../core/fx/fx_service.dart';
import '../../../core/local/database/sqlite/sqlite_services.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/providers/data/fx_provider.dart';
import '../../../core/providers/local/sqlite_database_provider.dart';
import '../../../core/utils/typedefs.dart';
import 'models/progress_stats.dart';
import 'progress_local_datasource.dart';

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(
    sqlite: ref.read(sqliteDataBaseProvider),
    fx: ref.read(fxServiceProvider),
  ),
);

/// Read-only aggregate for the progress page. Conversion uses the local FX
/// cache only (never the network): currencies with no cached rate are dropped
/// and reported in [ProgressStats.unconvertible], exactly like the tags hub.
class ProgressRepository {
  ProgressRepository({
    required this.sqlite,
    this.fx,
    this.datasource = const ProgressLocalDatasource(),
  });

  final SQLiteServices sqlite;

  /// Null in unit tests → only rows already in [target] are counted.
  final FxService? fx;
  final ProgressLocalDatasource datasource;

  /// How many real tag slices the pie keeps before folding the tail into
  /// [TagSliceKind.other].
  static const int maxTagSlices = 5;

  /// [target] is the base currency, or the filtered wallet's own currency
  /// (in which case no conversion happens at all).
  Future<SuccessOrError<ProgressStats>> load({
    required ProgressGranularity granularity,
    required CurrencyType target,
    String? walletId,
    DateTime? now,
  }) =>
      Failure.exceptionsCatcher(() async {
        final edges = ProgressStats.boundaries(granularity, now ?? DateTime.now());
        final sums = await datasource.sumsByPeriod(sqlite.db, boundaries: edges, walletId: walletId);

        final count = granularity.buckets;
        final income = List<int>.filled(count, 0);
        final expense = List<int>.filled(count, 0);
        final rowCount = List<int>.filled(count, 0);
        final rates = <CurrencyType, FxRate?>{};
        final unconvertible = <CurrencyType>{};

        for (final sum in sums) {
          if (sum.bucket < 0 || sum.bucket >= count) continue;
          final converted = await _convert(sum.totalMinor, sum.currencyCode, target, rates, unconvertible);
          if (converted == null) continue;
          rowCount[sum.bucket] += sum.count;
          if (sum.type == 'income') {
            income[sum.bucket] += converted;
          } else {
            expense[sum.bucket] += converted;
          }
        }

        // The pie covers the running period only — the last bucket.
        final tagRows = await datasource.expenseByTag(
          sqlite.db,
          start: edges[count - 1],
          end: edges[count],
          walletId: walletId,
        );

        return ProgressStats(
          granularity: granularity,
          currency: target,
          walletId: walletId,
          expenseByTag: await _slices(tagRows, target, rates, unconvertible),
          unconvertible: unconvertible.toList(),
          periods: [
            for (var i = 0; i < count; i++)
              ProgressPeriod(
                start: edges[i],
                income: Money(income[i], target),
                expense: Money(expense[i], target),
                count: rowCount[i],
              ),
          ],
        );
      });

  /// Converts the raw tag rows, merges the per-currency rows of one tag,
  /// ranks them (untagged included) and folds everything past
  /// [maxTagSlices] into a single "other" section.
  Future<List<TagSlice>> _slices(
    List<PeriodTagSum> rows,
    CurrencyType target,
    Map<CurrencyType, FxRate?> rates,
    Set<CurrencyType> unconvertible,
  ) async {
    final byTag = <String, TagSlice>{};

    for (final row in rows) {
      final converted = await _convert(row.totalMinor, row.currencyCode, target, rates, unconvertible);
      if (converted == null) continue;

      // Untagged rows share one bucket; '' is not a valid tag id.
      final key = row.tagId ?? '';
      final existing = byTag[key];
      byTag[key] = TagSlice(
        kind: row.tagId == null ? TagSliceKind.untagged : TagSliceKind.tag,
        tagId: row.tagId,
        label: row.displayName ?? '',
        normalizedName: row.normalizedName ?? '',
        amount: Money((existing?.amount.minor ?? 0) + converted, target),
        count: (existing?.count ?? 0) + row.count,
      );
    }

    final ranked = byTag.values.where((s) => s.amount.minor > 0).toList()
      ..sort((a, b) => b.amount.minor.compareTo(a.amount.minor));
    if (ranked.length <= maxTagSlices + 1) return ranked;

    final kept = ranked.take(maxTagSlices).toList();
    final tail = ranked.skip(maxTagSlices);
    return [
      ...kept,
      TagSlice(
        kind: TagSliceKind.other,
        amount: Money(tail.fold(0, (sum, s) => sum + s.amount.minor), target),
        count: tail.fold(0, (sum, s) => sum + s.count),
      ),
    ];
  }

  /// Null when the currency has no cached rate — the caller drops the row and
  /// the code is surfaced in the "not included" caption.
  Future<int?> _convert(
    int minor,
    String currencyCode,
    CurrencyType target,
    Map<CurrencyType, FxRate?> rates,
    Set<CurrencyType> unconvertible,
  ) async {
    final currency = CurrencyType.fromCode(currencyCode);
    if (currency == target) return minor;
    final rate = rates.containsKey(currency)
        ? rates[currency]
        : rates[currency] = await fx?.cachedRate(currency, target);
    if (rate == null) {
      unconvertible.add(currency);
      return null;
    }
    return convertMinor(minor, currency, target, rate.rate);
  }
}
