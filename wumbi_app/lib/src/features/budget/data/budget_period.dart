import '../../../core/recurring/recurring_schedule.dart';
import '../../../core/utils/enums/budget_period_type.dart';
import 'models/budget_model.dart';

/// Half-open local range `[start, end)`; both edges are local midnights.
/// [index] 0 is the first period from the budget's anchor (negative = before).
class BudgetPeriod {
  const BudgetPeriod({required this.start, required this.end, required this.index});

  final DateTime start;
  final DateTime end;
  final int index;

  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);

  /// Calendar days in the period (DST-safe).
  int get lengthDays => calendarDaysBetween(start, end);

  @override
  bool operator ==(Object other) =>
      other is BudgetPeriod && other.start == start && other.end == end && other.index == index;

  @override
  int get hashCode => Object.hash(start, end, index);

  @override
  String toString() => 'BudgetPeriod#$index[$start, $end)';
}

/// Whole calendar days from the day of [a] to the day of [b] (local dates,
/// so a 23 h / 25 h DST day still counts as one).
int calendarDaysBetween(DateTime a, DateTime b) =>
    DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

DateTime _midnight(DateTime d) => DateTime(d.year, d.month, d.day);

/// Period [index] of a schedule. Monthly / yearly periods are always derived
/// from the anchor (never chained from the previous period), so a day-31
/// budget runs Jan 31 → Feb 28 → Mar 31 without drifting. Custom budgets
/// have a single period, whatever the index.
BudgetPeriod periodOf(BudgetPeriodType type, DateTime anchorDate, DateTime? endDate, int index) {
  final a = _midnight(anchorDate);
  return switch (type) {
    BudgetPeriodType.weekly => BudgetPeriod(
        start: DateTime(a.year, a.month, a.day + 7 * index),
        end: DateTime(a.year, a.month, a.day + 7 * (index + 1)),
        index: index,
      ),
    BudgetPeriodType.monthly => BudgetPeriod(
        start: addMonthsClamped(a, index),
        end: addMonthsClamped(a, index + 1),
        index: index,
      ),
    BudgetPeriodType.yearly => BudgetPeriod(
        start: addMonthsClamped(a, 12 * index),
        end: addMonthsClamped(a, 12 * (index + 1)),
        index: index,
      ),
    BudgetPeriodType.custom => BudgetPeriod(
        start: a,
        end: _midnight(endDate ?? a.add(const Duration(days: 1))),
        index: 0,
      ),
  };
}

/// Index of the period containing [now] (may be negative before the anchor).
int periodIndexOf(BudgetPeriodType type, DateTime anchorDate, DateTime now) {
  final a = _midnight(anchorDate);
  switch (type) {
    case BudgetPeriodType.custom:
      return 0;
    case BudgetPeriodType.weekly:
      return (calendarDaysBetween(a, now) / 7).floor();
    case BudgetPeriodType.monthly:
    case BudgetPeriodType.yearly:
      final step = type == BudgetPeriodType.monthly ? 1 : 12;
      final months = (now.year - a.year) * 12 + now.month - a.month;
      var k = (months / step).floor();
      // Clamped month ends make the naive guess off by one at the edges.
      while (periodOf(type, a, null, k).start.isAfter(now)) {
        k--;
      }
      while (!periodOf(type, a, null, k + 1).start.isAfter(now)) {
        k++;
      }
      return k;
  }
}

BudgetPeriod periodAt(BudgetModel b, int index) => periodOf(b.period, b.anchorDate, b.endDate, index);

int periodIndexAt(BudgetModel b, DateTime now) => periodIndexOf(b.period, b.anchorDate, now);

/// The running period, or null for a custom budget outside its range.
BudgetPeriod? currentPeriod(BudgetModel b, DateTime now) {
  final p = periodAt(b, periodIndexAt(b, now));
  return p.contains(now) ? p : null;
}

// ----------------------------------------------------------------- anchors

/// Monthly budget starting on day [day] (1–31): the latest date ≤ [today]
/// whose day **is** [day]. Months too short for [day] are skipped so the
/// anchor keeps the real start day (day 31 stays 31 after a February); the
/// clamped edge of the running period then comes from [periodOf].
DateTime monthlyAnchor(int day, DateTime today) {
  final t = _midnight(today);
  for (var i = 0; i < 24; i++) {
    final month = addMonthsClamped(DateTime(t.year, t.month), -i);
    if (day > DateTime(month.year, month.month + 1, 0).day) continue;
    final candidate = DateTime(month.year, month.month, day);
    if (!candidate.isAfter(t)) return candidate;
  }
  return DateTime(t.year, t.month);
}

/// Weekly budget starting on [weekday] (`DateTime.monday` … `sunday`): the
/// latest such day ≤ [today].
DateTime weeklyAnchor(int weekday, DateTime today) {
  final t = _midnight(today);
  final back = (t.weekday - weekday) % 7;
  return DateTime(t.year, t.month, t.day - back);
}

/// Yearly budget starting on [month]/[day]: the latest real occurrence ≤
/// [today] (Feb 29 anchors on the last leap year).
DateTime yearlyAnchor(int month, int day, DateTime today) {
  final t = _midnight(today);
  for (var i = 0; i < 9; i++) {
    final year = t.year - i;
    if (day > DateTime(year, month + 1, 0).day) continue;
    final candidate = DateTime(year, month, day);
    if (!candidate.isAfter(t)) return candidate;
  }
  return DateTime(t.year);
}
