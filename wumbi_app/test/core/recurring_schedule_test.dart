import 'package:wumbi/src/core/recurring/recurring_schedule.dart';
import 'package:wumbi/src/core/utils/enums/repeat_frequency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('advance', () {
    test('daily / weekly', () {
      final start = DateTime(2026, 10, 28, 9, 30);
      expect(advance(start, RepeatFrequency.daily, 1), DateTime(2026, 10, 29, 9, 30));
      expect(advance(start, RepeatFrequency.daily, 5), DateTime(2026, 11, 2, 9, 30));
      expect(advance(start, RepeatFrequency.weekly, 2), DateTime(2026, 11, 11, 9, 30));
    });

    test('monthly clamps to month end and returns to the anchor day', () {
      final start = DateTime(2026, 1, 31, 12);
      expect(advance(start, RepeatFrequency.monthly, 1), DateTime(2026, 2, 28, 12));
      expect(advance(start, RepeatFrequency.monthly, 2), DateTime(2026, 3, 31, 12));
      expect(advance(start, RepeatFrequency.monthly, 3), DateTime(2026, 4, 30, 12));
      expect(advance(start, RepeatFrequency.monthly, 12), DateTime(2027, 1, 31, 12));
    });

    test('monthly across year boundary', () {
      final start = DateTime(2026, 11, 15, 8);
      expect(advance(start, RepeatFrequency.monthly, 2), DateTime(2027, 1, 15, 8));
      expect(advance(start, RepeatFrequency.monthly, 14), DateTime(2028, 1, 15, 8));
    });

    test('yearly: Feb 29 → Feb 28 in non-leap years', () {
      final start = DateTime(2028, 2, 29, 10);
      expect(advance(start, RepeatFrequency.yearly, 1), DateTime(2029, 2, 28, 10));
      expect(advance(start, RepeatFrequency.yearly, 4), DateTime(2032, 2, 29, 10));
    });

    test('keeps the time of day', () {
      final start = DateTime(2026, 3, 10, 23, 59);
      expect(advance(start, RepeatFrequency.monthly, 1).hour, 23);
      expect(advance(start, RepeatFrequency.monthly, 1).minute, 59);
    });

    test('never throws', () {
      expect(() => advance(DateTime(2026), RepeatFrequency.never, 1), throwsStateError);
    });
  });

  group('addMonthsClamped', () {
    test('negative offsets cross the year backwards', () {
      expect(addMonthsClamped(DateTime(2026, 1, 15), -1), DateTime(2025, 12, 15));
      expect(addMonthsClamped(DateTime(2026, 3, 31), -1), DateTime(2026, 2, 28));
      expect(addMonthsClamped(DateTime(2026, 2, 10), -14), DateTime(2024, 12, 10));
      expect(addMonthsClamped(DateTime(2026, 1, 1), -12), DateTime(2025, 1, 1));
    });
  });

  group('occurrencesFrom', () {
    test('walks the same dates as the engine, from the stored anchor', () {
      // A rule re-anchored by `updateRule`: start = next = Jan 31, count 0.
      final dates = occurrencesFrom(
        startDate: DateTime(2026, 1, 31, 12),
        frequency: RepeatFrequency.monthly,
        nextOccurrence: DateTime(2026, 1, 31, 12),
        occurrenceCount: 0,
      ).take(3).toList();
      expect(dates, [DateTime(2026, 1, 31, 12), DateTime(2026, 2, 28, 12), DateTime(2026, 3, 31, 12)]);
    });

    test('mid-series state continues from occurrence_count', () {
      final dates = occurrencesFrom(
        startDate: DateTime(2026, 1, 31, 12),
        frequency: RepeatFrequency.monthly,
        nextOccurrence: DateTime(2026, 3, 31, 12),
        occurrenceCount: 2,
      ).take(2).toList();
      expect(dates, [DateTime(2026, 3, 31, 12), DateTime(2026, 4, 30, 12)]);
    });
  });
}
