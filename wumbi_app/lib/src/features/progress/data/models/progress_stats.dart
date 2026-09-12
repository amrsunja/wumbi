import 'dart:math' as math;

import '../../../../core/money/currency_type.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';

/// Bucket size of the progress page. [buckets] columns are shown, the last
/// one being the running period and the one before it the comparison
/// baseline.
enum ProgressGranularity {
  month(buckets: 6),
  year(buckets: 5);

  const ProgressGranularity({required this.buckets});

  final int buckets;
}

/// Raw SQL aggregate: one row per bucket × currency × type.
class PeriodCurrencySum {
  const PeriodCurrencySum({
    required this.bucket,
    required this.currencyCode,
    required this.type,
    required this.totalMinor,
    required this.count,
  });

  final int bucket;
  final String currencyCode;

  /// 'income' | 'expense'
  final String type;
  final int totalMinor;
  final int count;
}

/// Raw SQL aggregate for the pie: one row per tag × currency inside a single
/// period. A null [tagId] is the untagged bucket.
class PeriodTagSum {
  const PeriodTagSum({
    required this.tagId,
    required this.displayName,
    required this.normalizedName,
    required this.currencyCode,
    required this.totalMinor,
    required this.count,
  });

  final String? tagId;
  final String? displayName;
  final String? normalizedName;
  final String currencyCode;
  final int totalMinor;
  final int count;
}

enum TagSliceKind { tag, untagged, other }

/// One pie section. A transaction carrying two tags counts in both, so the
/// slices are ranked and shown as a share of the pie's own total rather than
/// of the period's expense — the same rule the tags hub already uses.
class TagSlice {
  const TagSlice({
    required this.kind,
    required this.amount,
    required this.count,
    this.tagId,
    this.label = '',
    this.normalizedName = '',
  });

  final TagSliceKind kind;

  /// Positive magnitude in the display currency.
  final Money amount;

  /// Transactions behind the slice (summed across folded tags for `other`).
  final int count;

  /// Set only for [TagSliceKind.tag] — what a tap opens.
  final String? tagId;

  /// Display name for [TagSliceKind.tag]; the UI localises the other kinds.
  final String label;

  /// Drives the palette lookup, so a tag keeps its colour across screens.
  final String normalizedName;
}

/// One chart column, already converted into the display currency.
class ProgressPeriod {
  const ProgressPeriod({
    required this.start,
    required this.income,
    required this.expense,
    required this.count,
  });

  /// First instant of the period (local).
  final DateTime start;

  /// Positive magnitudes in the display currency.
  final Money income;
  final Money expense;
  final int count;

  Money get net => Money(income.minor - expense.minor, income.currency);
  bool get isEmpty => income.isZero && expense.isZero;

  /// Tallest rod of this column — drives the chart's Y scale.
  int get peakMinor => math.max(income.minor, expense.minor);
}

/// Everything the progress page draws: N periods in one currency, plus the
/// currencies that had no cached rate.
class ProgressStats {
  const ProgressStats({
    required this.granularity,
    required this.currency,
    required this.periods,
    this.walletId,
    this.expenseByTag = const [],
    this.unconvertible = const [],
  });

  final ProgressGranularity granularity;

  /// Base currency, or the filtered wallet's own currency.
  final CurrencyType currency;

  /// Oldest → newest; never empty. The last entry is the running period.
  final List<ProgressPeriod> periods;

  /// Null = every wallet.
  final String? walletId;

  /// Pie sections for the running period only, biggest first.
  final List<TagSlice> expenseByTag;
  final List<CurrencyType> unconvertible;

  /// Denominator for the pie's percentages (see [TagSlice]).
  int get taggedExpenseMinor => expenseByTag.fold(0, (sum, s) => sum + s.amount.minor);

  ProgressPeriod get current => periods.last;

  /// The period the current one is compared against.
  ProgressPeriod? get baseline => periods.length < 2 ? null : periods[periods.length - 2];

  /// Signed relative change, `0.12` = +12 %. Null when the baseline is zero
  /// (nothing to grow from) or missing.
  double? get incomeDelta => _delta(current.income.minor, baseline?.income.minor);
  double? get expenseDelta => _delta(current.expense.minor, baseline?.expense.minor);
  double? get netDelta => _delta(current.net.minor, baseline?.net.minor);

  bool get isEmpty => periods.every((p) => p.isEmpty);

  /// Tallest rod across every column (0 when there is no data).
  int get peakMinor => periods.fold(0, (max, p) => math.max(max, p.peakMinor));

  /// Axis label: `Nov` / `2026`.
  String labelOf(ProgressPeriod period) => switch (granularity) {
        ProgressGranularity.month => period.start.formatMonthShort(),
        ProgressGranularity.year => '${period.start.year}',
      };

  static double? _delta(int current, int? baseline) {
    if (baseline == null || baseline == 0) return null;
    return (current - baseline) / baseline.abs();
  }

  /// Local period edges, oldest first; length = `granularity.buckets + 1`.
  /// `DateTime` normalises out-of-range months, so month − 5 rolls the year.
  static List<DateTime> boundaries(ProgressGranularity granularity, DateTime now) {
    final n = granularity.buckets;
    return [
      for (var i = 0; i <= n; i++)
        switch (granularity) {
          ProgressGranularity.month => DateTime(now.year, now.month - (n - 1) + i),
          ProgressGranularity.year => DateTime(now.year - (n - 1) + i),
        },
    ];
  }
}
