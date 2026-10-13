import 'dart:math' as math;

import '../utils/enums/repeat_frequency.dart';

/// `advance(start, f, n)` = the n-th occurrence after `start`, computed from
/// `start` (not from the previous occurrence) so month-end clamping never
/// drifts: Jan 31 → Feb 28 → Mar 31. Local calendar time; time-of-day is the
/// time part of `start`.
DateTime advance(DateTime start, RepeatFrequency f, int n) => switch (f) {
      RepeatFrequency.daily => _addDays(start, n),
      RepeatFrequency.weekly => _addDays(start, 7 * n),
      RepeatFrequency.monthly => addMonthsClamped(start, n),
      RepeatFrequency.yearly => addMonthsClamped(start, 12 * n),
      RepeatFrequency.never => throw StateError('never'),
    };

/// Calendar-day arithmetic (DST safe — does not add a `Duration`).
DateTime _addDays(DateTime d, int days) => DateTime(
      d.year,
      d.month,
      d.day + days,
      d.hour,
      d.minute,
      d.second,
      d.millisecond,
    );

/// Adds [months] (may be negative) and clamps the day to the target month's
/// length. Floor division keeps negative offsets in the right year
/// (Jan − 1 month = Dec of the previous year); budgets walk back periods for
/// rollover and limit suggestions.
DateTime addMonthsClamped(DateTime d, int months) {
  final total = d.month - 1 + months;
  final y = d.year + (total / 12).floor();
  final m = total % 12 + 1;
  final lastDay = DateTime(y, m + 1, 0).day;
  return DateTime(
    y,
    m,
    math.min(d.day, lastDay),
    d.hour,
    d.minute,
    d.second,
    d.millisecond,
  );
}

/// One step of a rule's schedule — the single source of truth shared by
/// `RecurringEngine.catchUp` and budget "planned" projections, so both walk
/// exactly the same dates. A rule in state ([occurrenceCount], whose next due
/// date is `advance(startDate, f, occurrenceCount)`) moves to
/// `occurrenceCount + 1`. `updateRule` re-anchors `startDate` and resets the
/// count, which is why the step is derived from the stored anchor rather than
/// from `start_date + n` of the original series.
({DateTime date, int count}) nextOccurrenceStep(DateTime startDate, RepeatFrequency f, int occurrenceCount) {
  final count = occurrenceCount + 1;
  return (date: advance(startDate, f, count), count: count);
}

/// Due dates a rule will generate from its current state, in order, starting
/// with [nextOccurrence] itself. Lazy — callers bound it (`takeWhile`, cap).
Iterable<DateTime> occurrencesFrom({
  required DateTime startDate,
  required RepeatFrequency frequency,
  required DateTime nextOccurrence,
  required int occurrenceCount,
}) sync* {
  var date = nextOccurrence;
  var count = occurrenceCount;
  while (true) {
    yield date;
    final step = nextOccurrenceStep(startDate, frequency, count);
    date = step.date;
    count = step.count;
  }
}
