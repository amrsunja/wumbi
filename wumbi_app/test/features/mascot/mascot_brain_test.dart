import 'package:flutter_test/flutter_test.dart';
import 'package:wumbi/src/core/design_system/app_ui.dart';
import 'package:wumbi/src/core/money/currency_type.dart';
import 'package:wumbi/src/core/money/money.dart';
import 'package:wumbi/src/features/mascot/data/mascot_memory.dart';
import 'package:wumbi/src/features/mascot/domain/mascot_brain.dart';
import 'package:wumbi/src/features/mascot/domain/mascot_message.dart';
import 'package:wumbi/src/features/mascot/domain/mascot_reaction.dart';
import 'package:wumbi/src/features/mascot/domain/mascot_screens.dart';
import 'package:wumbi/src/features/mascot/domain/mascot_signals.dart';

const eur = CurrencyType.eur;
Money m(int major) => Money(major * 100, eur);
final now = DateTime(2026, 10, 20, 10);

MascotSignals signals({
  int income = 0,
  int expense = 0,
  double? reserve,
  MascotDebtSignal? overdue,
  MascotBudgetSignal? over,
  MascotBudgetSignal? near,
  int? idleDays,
  DateTime? prevVisit,
  int records = 10,
  int budgetCount = 1,
  int expenseCount = 0,
  int? daysWithWumbi,
  int untagged = 0,
}) =>
    MascotSignals(
      now: now,
      base: eur,
      monthIncome: m(income),
      monthExpense: m(expense),
      monthExpenseCount: expenseCount,
      reserveMonths: reserve,
      overdueDebt: overdue,
      overBudget: over,
      nearBudget: near,
      daysSinceLastRecord: idleDays,
      prevVisitAt: prevVisit ?? now.subtract(const Duration(hours: 3)),
      recordCount: records,
      budgetCount: budgetCount,
      activeSubscriptions: 1,
      daysWithWumbi: daysWithWumbi,
      untaggedCount: untagged,
    );

void main() {
  group('dashboard state table (spec §4.3)', () {
    test('an overdue debt beats everything', () {
      final list = MascotBrain.dashboard(signals(
        overdue: const MascotDebtSignal(id: 'd1', name: 'Ahmed', days: 3),
        over: MascotBudgetSignal(id: 'b1', name: 'Food', amount: m(40), percent: 110),
        idleDays: 9,
      ));
      expect(list.first.id, 'warn.debtOverdue');
      expect(list.first.mood, WumbiMood.alert);
      expect(list.first.action?.kind, MascotActionKind.openDebt);
      expect(list.last.tier, MascotTier.summary);
    });

    test('month in the red with a thin reserve sighs; with a cushion it stays calm', () {
      final thin = MascotBrain.dashboard(signals(income: 100, expense: 300, reserve: 0.3));
      expect(thin.first.mood, WumbiMood.sigh);
      final cushion = MascotBrain.dashboard(signals(income: 100, expense: 300, reserve: 2));
      expect(cushion.any((c) => c.id == 'warn.sigh'), isFalse);
      expect(MascotBrain.summaryOf(signals(income: 100, expense: 300, reserve: 2)).mood, WumbiMood.calm);
    });

    test('summary: full cheeks ≥ 3 months, happy when up, calm otherwise', () {
      expect(MascotBrain.summaryOf(signals(income: 100, expense: 50, reserve: 3.4)).mood, WumbiMood.reserveFull);
      expect(MascotBrain.summaryOf(signals(income: 500, expense: 80)).mood, WumbiMood.happy);
      expect(MascotBrain.summaryOf(signals()).line?.phrase, MascotPhrase.allCalm);
    });

    test('back after a week: welcome ranks above "no records" but under money warnings', () {
      final list = MascotBrain.dashboard(signals(
        idleDays: 9,
        prevVisit: now.subtract(const Duration(days: 9)),
        near: MascotBudgetSignal(id: 'b', name: 'Cafe', amount: m(30), percent: 85),
      ));
      final ids = list.map((c) => c.id).toList();
      expect(ids.indexOf('warn.budgetNear'), lessThan(ids.indexOf('visit.welcomeBack')));
      expect(ids.indexOf('visit.welcomeBack'), lessThan(ids.indexOf('warn.sleep')));
    });

    test('warnings reword with the variant, keep their meaning', () {
      final s = signals(overdue: const MascotDebtSignal(id: 'd', name: 'Ali', days: 2));
      final a = MascotBrain.dashboard(s, variant: 0).first;
      final b = MascotBrain.dashboard(s, variant: 1).first;
      expect(a.id, b.id);
      expect(a.line?.phrase, isNot(b.line?.phrase));
    });

    test('first open of the day greets with the summary appended', () {
      final s = signals(income: 500, expense: 80, prevVisit: now.subtract(const Duration(days: 1)));
      final greeting = MascotBrain.dashboard(s).firstWhere((c) => c.tier == MascotTier.greeting);
      expect(greeting.line?.phrase, MascotPhrase.greetingMorning);
      expect(greeting.line?.then?.phrase, MascotPhrase.flowUp);
    });

    test('anniversaries fire within a week of the day only', () {
      expect(MascotBrain.dashboard(signals(daysWithWumbi: 31)).any((c) => c.id == 'event.days.30'), isTrue);
      expect(MascotBrain.dashboard(signals(daysWithWumbi: 45)).any((c) => c.id.startsWith('event.days')), isFalse);
    });
  });

  group('selection & memory (spec §3.3)', () {
    test('each session says the next unsaid thought, the summary when nothing is left', () {
      final s = signals(untagged: 12, budgetCount: 0, expenseCount: 8);
      final candidates = MascotBrain.dashboard(s);
      var memory = const MascotMemory();

      final first = MascotBrain.select(candidates, memory: memory, now: now);
      expect(first.id, 'insight.untagged');
      memory = memory.markShown(first, now);

      final second = MascotBrain.select(candidates, memory: memory, now: now);
      expect(second.id, 'tip.budget');
      memory = memory.markShown(second, now);

      // Then the jokes, one per visit, until only the summary is left.
      final seen = <String>{first.id, second.id};
      var next = MascotBrain.select(candidates, memory: memory, now: now);
      while (next.tier != MascotTier.summary) {
        expect(next.tier, MascotTier.joke);
        expect(seen.add(next.id), isTrue, reason: 'never the same thought twice');
        memory = memory.markShown(next, now);
        next = MascotBrain.select(candidates, memory: memory, now: now);
      }
    });

    test('a whole day away, back in the evening: impatient → sad → asks for today', () {
      final evening = DateTime(2026, 10, 20, 20);
      final s = MascotSignals(
        now: evening,
        base: eur,
        monthIncome: m(0),
        monthExpense: m(0),
        prevVisitAt: evening.subtract(const Duration(days: 1, hours: 2)),
        recordCount: 30,
      );
      final story = MascotBrain.dashboard(s).first;
      expect(story.id, 'story.evening');
      expect(story.mood, WumbiMood.impatient);
      expect(story.steps.first.mood, WumbiMood.sad);
      expect(story.steps.last.mood, anyOf(WumbiMood.alert, WumbiMood.sigh));
      expect(story.steps.last.action?.kind, MascotActionKind.addTransaction);
    });

    test('love only for rare moments', () {
      final s = signals(income: 900, expense: 100, reserve: 2, untagged: 12, daysWithWumbi: 20);
      expect(MascotBrain.dashboard(s).where((c) => c.mood == WumbiMood.love), isEmpty);
    });

    test('an insight comes back after its cooldown or when its data changes', () {
      final s = signals(untagged: 12);
      final insight = MascotBrain.dashboard(s).firstWhere((c) => c.id == 'insight.untagged');
      final memory = const MascotMemory().markShown(insight, now);
      expect(memory.isEligible(insight, now.add(const Duration(days: 2))), isFalse);
      expect(memory.isEligible(insight, now.add(const Duration(days: 8))), isTrue);
      final more = MascotBrain.dashboard(signals(untagged: 25)).firstWhere((c) => c.id == 'insight.untagged');
      expect(memory.isEligible(more, now.add(const Duration(days: 1))), isTrue);
    });

    test('events are celebrated once', () {
      final event = MascotBrain.dashboard(signals(reserve: 3.2)).firstWhere((c) => c.id == 'event.reserve3');
      final memory = const MascotMemory().markShown(event, now);
      expect(memory.isEligible(event, now.add(const Duration(days: 400))), isFalse);
    });

    test('sticky within a session unless a warning shows up above it', () {
      final calm = MascotBrain.dashboard(signals(untagged: 12));
      final memory = const MascotMemory().markShown(calm.first, now);
      expect(MascotBrain.select(calm, memory: memory, now: now, stickyId: 'insight.untagged').id, 'insight.untagged');

      final withWarning = MascotBrain.dashboard(signals(
        untagged: 12,
        over: MascotBudgetSignal(id: 'b', name: 'Food', amount: m(5), percent: 102),
      ));
      expect(MascotBrain.select(withWarning, memory: memory, now: now, stickyId: 'insight.untagged').id, 'warn.budgetOver');
    });

    test('memory survives a JSON round trip', () {
      final msg = MascotBrain.dashboard(signals(untagged: 12)).first;
      final memory = const MascotMemory().visited(now).visited(now).markShown(msg, now).quietToday(now);
      final back = MascotMemory.fromJson(memory.toJson());
      expect(back.prevVisitAt, memory.prevVisitAt);
      expect(back.shown[msg.id]?.hash, msg.hash);
      expect(back.isQuiet(now), isTrue);
      expect(back.isQuiet(now.add(const Duration(days: 1))), isFalse);
    });
  });

  group('reactions', () {
    test('a big income stuffs the cheeks, a regular one is caught, an expense is tossed', () {
      final s = signals();
      final withBase = MascotSignals(now: now, base: eur, monthIncome: m(0), monthExpense: m(0), avgMonthlyIncome: m(2000));
      expect(MascotBrain.reaction(MascotReaction(MascotReactionKind.income, amount: m(2400), at: now), withBase).mood,
          WumbiMood.cheeksStuffed);
      expect(MascotBrain.reaction(MascotReaction(MascotReactionKind.income, amount: m(40), at: now), withBase).mood,
          WumbiMood.catching);
      final expense = MascotBrain.reaction(MascotReaction(MascotReactionKind.expense, at: now), s);
      expect(expense.mood, WumbiMood.tossing);
      expect(expense.line, isNull);
    });
  });

  group('screens', () {
    test('wallet: red balance is nervous, growth smiles with a full pouch, a month of silence sleeps', () {
      expect(MascotScreens.wallet(balance: m(-5), monthNet: 0, lastActivityAt: now, now: now).mood, WumbiMood.nervous);
      expect(MascotScreens.wallet(balance: m(650), monthNet: 150 * 100, lastActivityAt: now, now: now).mood,
          WumbiMood.reserveFull);
      expect(MascotScreens.wallet(balance: m(500), monthNet: -300 * 100, lastActivityAt: now, now: now).mood,
          WumbiMood.sigh);
      expect(
        MascotScreens.wallet(balance: m(500), monthNet: 0, lastActivityAt: now.subtract(const Duration(days: 40)), now: now)
            .mood,
        WumbiMood.sleep,
      );
    });
  });
}
