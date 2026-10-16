import 'dart:math' as math;

import '../../../../core/money/currency_type.dart';
import '../../../../core/money/money.dart';

// ------------------------------------------------------------------ periods

/// Size of one viewed period.
enum ProgressGranularity {
  month(historyLength: 12, pickerLength: 24),
  year(historyLength: 5, pickerLength: 10);

  const ProgressGranularity({required this.historyLength, required this.pickerLength});

  /// Bars in the history chart.
  final int historyLength;

  /// Periods offered by the "pick a month / year" baseline list.
  final int pickerLength;

  /// First local instant of the period holding [date].
  DateTime startOf(DateTime date) => switch (this) {
        month => DateTime(date.year, date.month),
        year => DateTime(date.year),
      };

  /// [start] moved by [by] periods (`DateTime` normalises month overflow).
  DateTime shift(DateTime start, int by) => switch (this) {
        month => DateTime(start.year, start.month + by),
        year => DateTime(start.year + by),
      };

  /// Whole periods from [from] to [to] (both period starts); negative when
  /// [to] is earlier.
  int between(DateTime from, DateTime to) => switch (this) {
        month => (to.year - from.year) * 12 + to.month - from.month,
        year => to.year - from.year,
      };

  /// Points on the pace chart: days of the month, or months of the year.
  int slotsIn(DateTime start) => switch (this) {
        month => DateTime(start.year, start.month + 1, 0).day,
        year => 12,
      };

  /// Pace-chart slot of [date] inside the period starting at [start].
  int slotOf(DateTime date) => switch (this) {
        month => date.day - 1,
        year => date.month - 1,
      };

  /// Calendar days in the period starting at [start].
  int daysIn(DateTime start) => switch (this) {
        month => DateTime(start.year, start.month + 1, 0).day,
        year => DateTime(start.year, 3, 0).day == 29 ? 366 : 365,
      };
}

enum ProgressBaselineKind { previous, lastYear, average, custom }

/// What the viewed period is compared against.
class ProgressBaseline {
  const ProgressBaseline._(this.kind, this.start);

  const ProgressBaseline.previous() : this._(ProgressBaselineKind.previous, null);

  /// Same month one year earlier (month granularity only).
  const ProgressBaseline.lastYear() : this._(ProgressBaselineKind.lastYear, null);

  /// Mean of the [averageSpan] periods before the viewed one.
  const ProgressBaseline.average() : this._(ProgressBaselineKind.average, null);

  /// A fixed period the user picked.
  const ProgressBaseline.custom(DateTime start) : this._(ProgressBaselineKind.custom, start);

  static const int averageSpan = 3;

  final ProgressBaselineKind kind;

  /// Period start; set only for [ProgressBaselineKind.custom].
  final DateTime? start;

  bool supports(ProgressGranularity g) => kind != ProgressBaselineKind.lastYear || g == ProgressGranularity.month;

  /// Period starts the baseline covers for [viewed], oldest first. Always
  /// contiguous, so one `[first, shift(last, 1))` range covers them all.
  /// A custom pick equal to the viewed period falls back to the previous one.
  List<DateTime> periodsFor(ProgressGranularity g, DateTime viewed) {
    switch (kind) {
      case ProgressBaselineKind.previous:
        return [g.shift(viewed, -1)];
      case ProgressBaselineKind.lastYear:
        return [g == ProgressGranularity.month ? g.shift(viewed, -12) : g.shift(viewed, -1)];
      case ProgressBaselineKind.average:
        return [for (var i = averageSpan; i >= 1; i--) g.shift(viewed, -i)];
      case ProgressBaselineKind.custom:
        final s = start!;
        return [s == viewed ? g.shift(viewed, -1) : s];
    }
  }

  @override
  bool operator ==(Object other) => other is ProgressBaseline && other.kind == kind && other.start == start;

  @override
  int get hashCode => Object.hash(kind, start);
}

// --------------------------------------------------------------- raw rows

/// Raw SQL aggregate: one row per bucket × currency × type (history bars).
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

/// One posted income / expense row of a range (pace, habits).
class ProgressTxRow {
  const ProgressTxRow({
    required this.id,
    required this.walletId,
    required this.isIncome,
    required this.amountMinor,
    required this.currencyCode,
    required this.date,
    required this.description,
    required this.recurring,
  });

  final String id;
  final String? walletId;
  final bool isIncome;

  /// Positive magnitude in [currencyCode].
  final int amountMinor;
  final String currencyCode;

  /// Local.
  final DateTime date;
  final String description;

  /// Generated by a recurring rule (a subscription).
  final bool recurring;
}

/// Raw SQL aggregate: per tag × currency × type over a range, nested tags
/// rolled into their parents (each transaction once per tag).
class TagRangeSum {
  const TagRangeSum({
    required this.tagId,
    required this.displayName,
    required this.normalizedName,
    required this.currencyCode,
    required this.type,
    required this.totalMinor,
    required this.count,
  });

  /// Null = the untagged bucket.
  final String? tagId;
  final String displayName;
  final String normalizedName;
  final String currencyCode;
  final String type;
  final int totalMinor;
  final int count;
}

// ------------------------------------------------------------------ report

/// Income / expense of one period (or the mean of several), already in the
/// report currency.
class ProgressTotals {
  const ProgressTotals({required this.income, required this.expense, this.incomeCount = 0, this.expenseCount = 0});

  ProgressTotals.zero(CurrencyType c)
      : income = Money.zero(c),
        expense = Money.zero(c),
        incomeCount = 0,
        expenseCount = 0;

  /// Positive magnitudes.
  final Money income;
  final Money expense;
  final int incomeCount;
  final int expenseCount;

  Money get net => income - expense;
  bool get isEmpty => income.isZero && expense.isZero;

  /// Share of income kept, `0.32` = 32 %. Null without income.
  double? get savingsRate => income.isPositive ? net.minor / income.minor : null;
}

/// One history bar.
class ProgressPeriod {
  const ProgressPeriod({required this.start, required this.totals});

  final DateTime start;
  final ProgressTotals totals;

  Money get income => totals.income;
  Money get expense => totals.expense;
  Money get net => totals.net;
  bool get isEmpty => totals.isEmpty;
}

/// A tag family node: amounts include every nested tag (counted once).
class ProgressTagNode {
  const ProgressTagNode({
    required this.tagId,
    required this.displayName,
    required this.normalizedName,
    required this.amount,
    required this.count,
    required this.baseline,
    this.children = const [],
  });

  final String tagId;

  /// Full path as typed (`Food/Coffee`).
  final String displayName;
  final String normalizedName;
  final Money amount;
  final int count;

  /// Comparison amount (mean for an averaged baseline); null when there is
  /// nothing to compare against.
  final Money? baseline;

  /// Direct children, biggest first.
  final List<ProgressTagNode> children;

  Money? get delta => baseline == null ? null : amount - baseline!;
}

/// The tag tree of one type (spending or income) for the viewed period.
class ProgressBreakdown {
  const ProgressBreakdown({
    required this.roots,
    required this.untagged,
    required this.untaggedCount,
    this.untaggedBaseline,
    this.vanished = const [],
  });

  /// Top-level families, biggest first (zero-amount families left out).
  final List<ProgressTagNode> roots;

  /// Families present only in the comparison (amount 0): no breakdown row,
  /// but they matter to "what changed".
  final List<ProgressTagNode> vanished;
  final Money untagged;
  final int untaggedCount;
  final Money? untaggedBaseline;

  bool get isEmpty => roots.isEmpty && untagged.isZero;
}

/// The largest single expense of the period.
class ProgressTopExpense {
  const ProgressTopExpense({
    required this.id,
    required this.walletId,
    required this.description,
    required this.amount,
    required this.date,
  });

  final String id;
  final String? walletId;
  final String description;
  final Money amount;
  final DateTime date;
}

class ProgressHabits {
  const ProgressHabits({
    required this.dailyAverage,
    required this.baselineDailyAverage,
    required this.topExpense,
    required this.recurring,
    required this.recurringCount,
    required this.averageExpense,
    required this.weekdayAverages,
  });

  /// Spending per elapsed day.
  final Money dailyAverage;
  final Money? baselineDailyAverage;
  final ProgressTopExpense? topExpense;

  /// Spending generated by recurring rules.
  final Money recurring;
  final int recurringCount;

  /// Mean expense transaction.
  final Money? averageExpense;

  /// Mean spending per weekday occurrence, index 0 = Monday … 6 = Sunday
  /// (minor units in the report currency).
  final List<int> weekdayAverages;

  /// 0 – 6 (Monday-based) of the priciest weekday; null without spending.
  int? get peakWeekday {
    var best = -1;
    var bestValue = 0;
    for (var i = 0; i < weekdayAverages.length; i++) {
      if (weekdayAverages[i] > bestValue) {
        best = i;
        bestValue = weekdayAverages[i];
      }
    }
    return best < 0 ? null : best;
  }
}

/// Everything the Progress page draws for one viewed period.
class ProgressReport {
  const ProgressReport({
    required this.granularity,
    required this.currency,
    required this.viewed,
    required this.now,
    required this.baseline,
    required this.baselineStarts,
    required this.current,
    required this.comparison,
    this.comparisonIsToDate = false,
    required this.paceCurrent,
    required this.paceBaseline,
    required this.history,
    required this.spending,
    required this.earning,
    required this.habits,
    this.walletId,
    this.unconvertible = const [],
  });

  final ProgressGranularity granularity;

  /// Base currency, or the filtered wallet's own currency.
  final CurrencyType currency;
  final String? walletId;

  /// Start of the viewed period.
  final DateTime viewed;

  /// Clock the report was computed with.
  final DateTime now;

  final ProgressBaseline baseline;

  /// Periods the comparison is built from, oldest first.
  final List<DateTime> baselineStarts;

  final ProgressTotals current;

  /// Mean of the [baselineStarts] holding data; null when none has any.
  /// While the viewed period runs it covers only the same stretch of each
  /// baseline period (day 1 → today's day), see [comparisonIsToDate].
  final ProgressTotals? comparison;

  /// [comparison] (and every tag baseline) is cut at today's day.
  final bool comparisonIsToDate;

  /// Cumulative spending (minor) per slot, up to and including today for
  /// the running period, every slot for a past one.
  final List<int> paceCurrent;

  /// Cumulative spending of the comparison over every slot of the viewed
  /// period; null without a comparison.
  final List<int>? paceBaseline;

  /// Oldest → newest; contains [viewed].
  final List<ProgressPeriod> history;

  final ProgressBreakdown spending;
  final ProgressBreakdown earning;
  final ProgressHabits habits;
  final List<CurrencyType> unconvertible;

  bool get isCurrent => granularity.startOf(now) == viewed;
  int get totalSlots => granularity.slotsIn(viewed);

  /// Slots of the viewed period that have happened.
  int get elapsedSlots => paceCurrent.length;

  /// Nothing to show for this scope at all.
  bool get isLedgerEmpty => current.isEmpty && comparison == null && history.every((p) => p.isEmpty);

  /// Signed relative change against the comparison, `0.12` = +12 %.
  double? get incomeDelta => _delta(current.income.minor, comparison?.income.minor);
  double? get expenseDelta => _delta(current.expense.minor, comparison?.expense.minor);

  /// Running period: comparison spending by the same slot; past period:
  /// its whole spending. Null without a comparison.
  Money? get paceDelta {
    final base = paceBaseline;
    if (base == null || paceCurrent.isEmpty) return null;
    final i = math.min(paceCurrent.length, base.length) - 1;
    if (i < 0) return null;
    return Money(paceCurrent[i] - base[i], currency);
  }

  /// Expected spending at the end of the running period: what is spent so
  /// far plus what the comparison still spent after the same slot (its
  /// rhythm), or a linear projection without one. Null for a past period or
  /// before 3 days (month) / 1 month (year) of data.
  Money? get forecast {
    if (!isCurrent || paceCurrent.isEmpty) return null;
    final spent = paceCurrent.last;
    final minElapsed = granularity == ProgressGranularity.month ? 3 : 1;
    if (paceCurrent.length < minElapsed || paceCurrent.length >= totalSlots || spent <= 0) return null;
    final base = paceBaseline;
    if (base != null && base.last > 0) {
      final rest = math.max(base.last - base[paceCurrent.length - 1], 0);
      return Money(spent + rest, currency);
    }
    return Money((spent / paceCurrent.length * totalSlots).round(), currency);
  }

  /// Movers: top-level spending families whose amount moved the most against
  /// the comparison, biggest move first. Moves under 1 % of the comparison's
  /// spending are noise and left out.
  List<ProgressTagNode> movers({int limit = 3}) {
    final c = comparison;
    if (c == null) return const [];
    final floor = math.max(c.expense.minor ~/ 100, 1);
    final moved = [
      for (final n in [...spending.roots, ...spending.vanished])
        if ((n.delta?.minor.abs() ?? 0) >= floor) n,
    ]..sort((a, b) => b.delta!.minor.abs().compareTo(a.delta!.minor.abs()));
    return moved.take(limit).toList();
  }

  /// Average of the complete, non-empty history periods (the running one is
  /// excluded: it is still filling up).
  ProgressTotals? historyAverage() {
    final done = history.where((p) => !p.isEmpty && p.start != granularity.startOf(now)).toList();
    if (done.isEmpty) return null;
    int avg(int Function(ProgressPeriod) f) => (done.fold<int>(0, (s, p) => s + f(p)) / done.length).round();
    return ProgressTotals(
      income: Money(avg((p) => p.income.minor), currency),
      expense: Money(avg((p) => p.expense.minor), currency),
    );
  }

  static double? _delta(int current, int? baseline) {
    if (baseline == null || baseline == 0) return null;
    return (current - baseline) / baseline.abs();
  }
}
