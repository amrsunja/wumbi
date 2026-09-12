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

DateTime addMonthsClamped(DateTime d, int months) {
  final y = d.year + (d.month - 1 + months) ~/ 12;
  final m = (d.month - 1 + months) % 12 + 1;
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
