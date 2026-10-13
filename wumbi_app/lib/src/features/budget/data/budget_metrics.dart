import 'dart:math' as math;

import '../../../core/money/currency_type.dart';
import '../../../core/utils/enums/rollover_mode.dart';
import 'budget_period.dart';

/// Budget health (spec B&D §5.5), first match wins in [computeBudgetMetrics].
enum BudgetStatus {
  over(0),
  atRisk(1),
  ok(2),
  notStarted(3),
  finished(4);

  const BudgetStatus(this.severity);

  /// Lower = more urgent (dashboard ordering).
  final int severity;
}

/// Derived numbers of one budget period, all in budget-currency minor units.
class BudgetMetrics {
  const BudgetMetrics({
    required this.isCurrent,
    required this.remaining,
    required this.free,
    required this.daysLeft,
    required this.perDay,
    required this.timeRatio,
    required this.spentRatio,
    required this.forecast,
    required this.paceDelta,
    required this.status,
  });

  final bool isCurrent;
  final int remaining;
  final int free;
  final int daysLeft;
  final int? perDay;
  final double timeRatio;

  /// `spent / limit`; infinite when the effective limit is ≤ 0.
  final double spentRatio;
  final int? forecast;
  final int paceDelta;
  final BudgetStatus status;
}

/// Pace rule tolerance so `0.45 − 0.35` (= 0.10000000000000003) is not "over".
const double _epsilon = 1e-9;

/// Pure metrics of one period (spec B&D §5.5). [limit] is the effective
/// limit (rollover included); [planned] is 0 outside the running period.
BudgetMetrics computeBudgetMetrics({
  required int limit,
  required int spent,
  required int planned,
  required BudgetPeriod period,
  required bool isCustom,
  required DateTime now,
}) {
  final isCurrent = period.contains(now);
  final notYet = now.isBefore(period.start);
  final today = DateTime(now.year, now.month, now.day);
  final totalDays = period.lengthDays;

  final daysLeft = isCurrent ? calendarDaysBetween(today, period.end) : (notYet ? totalDays : 0);

  final lengthMs = period.end.difference(period.start).inMilliseconds;
  final elapsedMs = now.difference(period.start).inMilliseconds;
  final timeRatio = lengthMs <= 0 ? 1.0 : (elapsedMs / lengthMs).clamp(0.0, 1.0);
  final spentRatio = limit <= 0 ? double.infinity : spent / limit;

  final remaining = limit - spent;
  final free = math.max(0, limit - spent - planned);
  final perDay = isCurrent && daysLeft >= 1 && limit > 0 ? free ~/ daysLeft : null;

  final elapsedDays = calendarDaysBetween(period.start, today) + 1;
  final forecast = isCurrent && elapsedDays >= 3 ? spent * totalDays ~/ elapsedDays : null;

  final BudgetStatus status;
  if (isCustom && notYet) {
    status = BudgetStatus.notStarted;
  } else if (isCustom && !now.isBefore(period.end)) {
    status = BudgetStatus.finished;
  } else if (limit <= 0 || spent > limit) {
    status = BudgetStatus.over;
  } else if (spent + planned > limit || (spentRatio - timeRatio > 0.10 + _epsilon && spentRatio >= 0.25)) {
    status = BudgetStatus.atRisk;
  } else {
    status = BudgetStatus.ok;
  }

  return BudgetMetrics(
    isCurrent: isCurrent,
    remaining: remaining,
    free: free,
    daysLeft: daysLeft,
    perDay: perDay,
    timeRatio: timeRatio,
    spentRatio: spentRatio,
    forecast: forecast,
    paceDelta: (limit * timeRatio).round() - spent,
    status: status,
  );
}

/// Carry into the next period after [spentPerPeriod] (oldest first), each
/// period starting from `limit + carry` (spec B&D §5.4). `surplus` never
/// carries debt forward; `both` may go negative.
int rolloverCarry({
  required int limit,
  required List<int> spentPerPeriod,
  required RolloverMode mode,
}) {
  if (mode.isNone) return 0;
  var carry = 0;
  for (final spent in spentPerPeriod) {
    final leftover = limit + carry - spent;
    carry = mode == RolloverMode.surplus ? math.max(0, leftover) : leftover;
  }
  return carry;
}

/// Rounds an average up to a "nice" limit in major units (spec B&D §5.6):
/// < 100 → next 5, < 1,000 → next 10, else next 50. Averages below one major
/// unit (crypto) are returned as is. Null when there is nothing to suggest.
int? niceLimitCeil(int averageMinor, CurrencyType currency) {
  if (averageMinor <= 0) return null;
  final unit = math.pow(10, currency.scale).toInt();
  if (averageMinor < unit) return averageMinor;
  final major = (averageMinor + unit - 1) ~/ unit;
  final step = major < 100 ? 5 : (major < 1000 ? 10 : 50);
  return ((major + step - 1) ~/ step) * step * unit;
}
