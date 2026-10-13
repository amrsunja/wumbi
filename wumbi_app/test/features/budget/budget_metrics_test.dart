import 'package:flutter_test/flutter_test.dart';
import 'package:wumbi/src/core/money/currency_type.dart';
import 'package:wumbi/src/core/utils/enums/rollover_mode.dart';
import 'package:wumbi/src/features/budget/data/budget_metrics.dart';
import 'package:wumbi/src/features/budget/data/budget_period.dart';

// June: no DST transition in either hemisphere, so ms ratios are exact.
final _june = BudgetPeriod(start: DateTime(2026, 6, 1), end: DateTime(2026, 7, 1), index: 0);
final _tenDays = BudgetPeriod(start: DateTime(2026, 6, 1), end: DateTime(2026, 6, 11), index: 0);

BudgetMetrics _m({
  required int limit,
  required int spent,
  int planned = 0,
  BudgetPeriod? period,
  bool custom = false,
  required DateTime now,
}) =>
    computeBudgetMetrics(
      limit: limit,
      spent: spent,
      planned: planned,
      period: period ?? _june,
      isCustom: custom,
      now: now,
    );

void main() {
  group('per day', () {
    test('free / days left, rounded down', () {
      final m = _m(limit: 40000, spent: 17000, planned: 6000, now: DateTime(2026, 6, 19, 10));
      expect(m.daysLeft, 12, reason: 'June 19 … 30, today included');
      expect(m.free, 17000);
      expect(m.perDay, 1416, reason: '17000 ~/ 12');
      expect(m.remaining, 23000);
    });

    test('the last day counts as one day left', () {
      final m = _m(limit: 1000, spent: 100, now: DateTime(2026, 6, 30, 23));
      expect(m.daysLeft, 1);
      expect(m.perDay, 900);
    });

    test('free never goes negative', () {
      final m = _m(limit: 1000, spent: 800, planned: 500, now: DateTime(2026, 6, 10));
      expect(m.free, 0);
      expect(m.perDay, 0);
      expect(m.status, BudgetStatus.atRisk, reason: 'spent + planned ≥ 90 % of the limit');
    });

    test('no per-day outside the running period', () {
      expect(_m(limit: 1000, spent: 0, now: DateTime(2026, 7, 2)).perDay, isNull);
      expect(_m(limit: 1000, spent: 0, now: DateTime(2026, 7, 2)).daysLeft, 0);
    });
  });

  group('status', () {
    test('over beats everything', () {
      expect(_m(limit: 1000, spent: 1001, now: DateTime(2026, 6, 29)).status, BudgetStatus.over);
      expect(_m(limit: 1000, spent: 1000, now: DateTime(2026, 6, 29)).status, BudgetStatus.atRisk,
          reason: 'exactly at the limit is not over yet');
    });

    test('at risk from 90 % of the limit, whatever the pace', () {
      final early = DateTime(2026, 6, 1); // timeRatio 0
      expect(_m(limit: 1000, spent: 899, period: _tenDays, now: early).status, BudgetStatus.ok);
      expect(_m(limit: 1000, spent: 900, period: _tenDays, now: early).status, BudgetStatus.atRisk);
    });

    test('planned counts towards the 90 %', () {
      final now = DateTime(2026, 6, 10);
      expect(_m(limit: 1000, spent: 500, planned: 399, now: now).status, BudgetStatus.ok);
      expect(_m(limit: 1000, spent: 500, planned: 400, now: now).status, BudgetStatus.atRisk);
    });

    test('effective limit ≤ 0 (rollover both) is over, without per-day', () {
      final m = _m(limit: -500, spent: 0, now: DateTime(2026, 6, 10));
      expect(m.status, BudgetStatus.over);
      expect(m.perDay, isNull);
      expect(m.spentRatio, double.infinity);
      expect(m.remaining, -500);
    });

    test('custom: not started / finished', () {
      final p = BudgetPeriod(start: DateTime(2026, 6, 10), end: DateTime(2026, 6, 20), index: 0);
      final before = _m(limit: 1000, spent: 0, period: p, custom: true, now: DateTime(2026, 6, 1));
      expect(before.status, BudgetStatus.notStarted);
      expect(before.daysLeft, 10);
      expect(_m(limit: 1000, spent: 5000, period: p, custom: true, now: DateTime(2026, 6, 20)).status,
          BudgetStatus.finished);
    });
  });

  test('forecast only from the third day', () {
    expect(_m(limit: 100000, spent: 3000, now: DateTime(2026, 6, 2, 12)).forecast, isNull);
    expect(_m(limit: 100000, spent: 3000, now: DateTime(2026, 6, 3, 8)).forecast, 30000, reason: '3000 / 3 × 30');
  });

  test('pace delta: positive when under pace', () {
    final m = _m(limit: 1000, spent: 100, period: _tenDays, now: DateTime(2026, 6, 6));
    expect(m.paceDelta, 400, reason: '1000 × 0.5 − 100');
  });

  group('rollover', () {
    test('surplus never carries overspend', () {
      expect(rolloverCarry(limit: 100, spentPerPeriod: [80, 130, 50], mode: RolloverMode.surplus), 50);
    });

    test('both carries overspend', () {
      // 20 → 120−130 = −10 → 90−50 = 40
      expect(rolloverCarry(limit: 100, spentPerPeriod: [80, 130, 50], mode: RolloverMode.both), 40);
      expect(rolloverCarry(limit: 100, spentPerPeriod: [300], mode: RolloverMode.both), -200);
    });

    test('none', () {
      expect(rolloverCarry(limit: 100, spentPerPeriod: [0, 0], mode: RolloverMode.none), 0);
    });
  });

  group('limit suggestion rounding', () {
    test('5 / 10 / 50 steps in major units, always up', () {
      expect(niceLimitCeil(400, CurrencyType.eur), 500);
      expect(niceLimitCeil(38240, CurrencyType.eur), 39000);
      expect(niceLimitCeil(123000, CurrencyType.eur), 125000);
      expect(niceLimitCeil(9500, CurrencyType.eur), 9500, reason: 'already nice');
      expect(niceLimitCeil(382, CurrencyType.jpy), 390);
    });

    test('nothing to suggest', () {
      expect(niceLimitCeil(0, CurrencyType.eur), isNull);
    });
  });
}
