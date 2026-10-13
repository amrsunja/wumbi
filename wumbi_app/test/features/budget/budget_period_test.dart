import 'package:flutter_test/flutter_test.dart';
import 'package:wumbi/src/core/money/currency_type.dart';
import 'package:wumbi/src/core/utils/enums/budget_period_type.dart';
import 'package:wumbi/src/features/budget/data/budget_period.dart';
import 'package:wumbi/src/features/budget/data/models/budget_model.dart';

BudgetModel _budget(BudgetPeriodType period, DateTime anchor, {DateTime? end}) => BudgetModel(
      id: 'b',
      name: 'B',
      limitMinor: 1000,
      currency: CurrencyType.eur,
      period: period,
      anchorDate: anchor,
      endDate: end,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  group('monthly', () {
    test('start day 31 is anchored, never chained (no drift)', () {
      final b = _budget(BudgetPeriodType.monthly, DateTime(2026, 1, 31));
      expect(periodAt(b, 0), BudgetPeriod(start: DateTime(2026, 1, 31), end: DateTime(2026, 2, 28), index: 0));
      expect(periodAt(b, 1), BudgetPeriod(start: DateTime(2026, 2, 28), end: DateTime(2026, 3, 31), index: 1));
      expect(periodAt(b, 2).start, DateTime(2026, 3, 31));
      expect(periodAt(b, 3).start, DateTime(2026, 4, 30));
      expect(periodAt(b, 4).start, DateTime(2026, 5, 31), reason: 'back to 31 after a 30-day month');
      expect(currentPeriod(b, DateTime(2026, 3, 5, 9))!.index, 1);
      expect(currentPeriod(b, DateTime(2026, 3, 31))!.index, 2, reason: 'start edge is inclusive');
    });

    test('the anchor keeps day 31 across a short month', () {
      expect(monthlyAnchor(31, DateTime(2026, 3, 5)), DateTime(2026, 1, 31));
      final b = _budget(BudgetPeriodType.monthly, monthlyAnchor(31, DateTime(2026, 3, 5)));
      final p = currentPeriod(b, DateTime(2026, 3, 5))!;
      expect([p.start, p.end], [DateTime(2026, 2, 28), DateTime(2026, 3, 31)]);
    });

    test('start day 25 when today is the 10th → previous month 25th', () {
      final anchor = monthlyAnchor(25, DateTime(2026, 10, 10, 15));
      expect(anchor, DateTime(2026, 9, 25));
      final p = currentPeriod(_budget(BudgetPeriodType.monthly, anchor), DateTime(2026, 10, 10, 15))!;
      expect([p.start, p.end], [DateTime(2026, 9, 25), DateTime(2026, 10, 25)]);
      expect(monthlyAnchor(25, DateTime(2026, 10, 25)), DateTime(2026, 10, 25), reason: 'today counts');
    });

    test('negative indexes walk back across the year', () {
      final b = _budget(BudgetPeriodType.monthly, DateTime(2026, 1, 15));
      expect(periodAt(b, -1).start, DateTime(2025, 12, 15));
      expect(periodIndexAt(b, DateTime(2025, 11, 20)), -2);
    });
  });

  group('weekly', () {
    test('Monday and Sunday starts', () {
      final wednesday = DateTime(2026, 10, 7, 18);
      expect(weeklyAnchor(DateTime.monday, wednesday), DateTime(2026, 10, 5));
      expect(weeklyAnchor(DateTime.sunday, wednesday), DateTime(2026, 10, 4));
      expect(weeklyAnchor(DateTime.wednesday, wednesday), DateTime(2026, 10, 7));

      final b = _budget(BudgetPeriodType.weekly, DateTime(2026, 10, 5));
      final p = currentPeriod(b, DateTime(2026, 10, 18, 23, 59))!;
      expect([p.start, p.end, p.index], [DateTime(2026, 10, 12), DateTime(2026, 10, 19), 1]);
    });

    test('a DST week is 7 calendar days, both edges at local midnight', () {
      // Spans the EU switch (Mar 29, 2026); holds in any time zone.
      final b = _budget(BudgetPeriodType.weekly, DateTime(2026, 3, 23));
      final p = periodAt(b, 0);
      expect(p.end, DateTime(2026, 3, 30));
      expect(p.end.hour, 0);
      expect(p.lengthDays, 7);
      expect(periodAt(b, 1).start, p.end);
      expect(currentPeriod(b, DateTime(2026, 3, 29, 23, 30))!.index, 0);
    });
  });

  group('yearly', () {
    test('Feb 29 anchors on the last leap year and clamps in between', () {
      final anchor = yearlyAnchor(2, 29, DateTime(2027, 6, 1));
      expect(anchor, DateTime(2024, 2, 29));
      final b = _budget(BudgetPeriodType.yearly, anchor);
      expect(periodAt(b, 1).start, DateTime(2025, 2, 28));
      expect(periodAt(b, 4).start, DateTime(2028, 2, 29));
      final p = currentPeriod(b, DateTime(2027, 6, 1))!;
      expect([p.start, p.end, p.index], [DateTime(2027, 2, 28), DateTime(2028, 2, 29), 3]);
    });

    test('Jan 1 default', () {
      expect(yearlyAnchor(1, 1, DateTime(2026, 10, 7)), DateTime(2026, 1, 1));
    });
  });

  group('custom', () {
    final b = _budget(BudgetPeriodType.custom, DateTime(2026, 10, 1), end: DateTime(2026, 10, 16));

    test('before / within / after', () {
      expect(currentPeriod(b, DateTime(2026, 9, 30, 23)), isNull);
      expect(currentPeriod(b, DateTime(2026, 10, 1)), isNotNull);
      expect(currentPeriod(b, DateTime(2026, 10, 15, 23, 59)), isNotNull);
      expect(currentPeriod(b, DateTime(2026, 10, 16)), isNull, reason: 'end is exclusive');
    });

    test('one period, whatever the index', () {
      expect(periodAt(b, 5), periodAt(b, 0));
      expect(periodAt(b, 0).lengthDays, 15);
    });
  });
}
