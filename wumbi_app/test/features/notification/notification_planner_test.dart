import 'package:flutter_test/flutter_test.dart';
import 'package:wumbi/src/core/design_system/app_ui.dart';
import 'package:wumbi/src/core/money/currency_type.dart';
import 'package:wumbi/src/core/money/money.dart';
import 'package:wumbi/src/core/utils/enums/debt_direction.dart';
import 'package:wumbi/src/core/utils/enums/repeat_frequency.dart';
import 'package:wumbi/src/core/utils/enums/transaction_type.dart';
import 'package:wumbi/src/features/mascot/domain/mascot_message.dart';
import 'package:wumbi/src/features/notification/domain/notification_kind.dart';
import 'package:wumbi/src/features/notification/domain/notification_message.dart';
import 'package:wumbi/src/features/notification/domain/notification_pacer.dart';
import 'package:wumbi/src/features/notification/domain/notification_payload.dart';
import 'package:wumbi/src/features/notification/domain/notification_planner.dart';
import 'package:wumbi/src/features/notification/domain/notification_prefs.dart';
import 'package:wumbi/src/features/notification/domain/notification_snapshot.dart';

const eur = CurrencyType.eur;
Money m(int major) => Money(major * 100, eur);

/// Wednesday 2026-10-21, 10:00.
final now = DateTime(2026, 10, 21, 10);
final today = DateTime(2026, 10, 21);
DateTime day(int offset) => NotificationPlanner.addDays(today, offset);

const onlyPayments = NotificationPrefs(debts: false, habits: false, recaps: false);
const onlyDebts = NotificationPrefs(payments: false, habits: false, recaps: false);
const onlyHabits = NotificationPrefs(payments: false, debts: false, recaps: false);
const onlyRecaps = NotificationPrefs(payments: false, debts: false, habits: false);

NotificationSnapshot snap({
  List<SnapshotWallet> wallets = const [],
  List<PlannedMove> moves = const [],
  List<SnapshotDebt> debts = const [],
  List<SnapshotBudget> budgets = const [],
  List<DateTime> records = const [],
  SnapshotWeek? week,
}) =>
    NotificationSnapshot(
      now: now,
      base: eur,
      wallets: wallets,
      moves: moves,
      debts: debts,
      budgets: budgets,
      recordTimes: records,
      week: week,
    );

PlannedMove expense(String id, DateTime date, int major,
        {PlannedMoveOrigin origin = PlannedMoveOrigin.rule,
        RepeatFrequency? frequency = RepeatFrequency.monthly,
        String wallet = 'w1'}) =>
    PlannedMove(
      id: id,
      origin: origin,
      type: TransactionType.expense,
      name: id,
      date: date,
      amount: m(major),
      walletId: wallet,
      frequency: origin == PlannedMoveOrigin.rule ? frequency : null,
      effects: [WalletEffect(wallet, -major * 100)],
    );

PlannedMove income(String id, DateTime date, int major, {String wallet = 'w1'}) => PlannedMove(
      id: id,
      origin: PlannedMoveOrigin.rule,
      type: TransactionType.income,
      name: id,
      date: date,
      amount: m(major),
      walletId: wallet,
      frequency: RepeatFrequency.monthly,
      effects: [WalletEffect(wallet, major * 100)],
    );

List<T> ofType<T>(List<NotificationDraft> drafts) => drafts.map((d) => d.message).whereType<T>().toList();
DateTime dayOf<T>(List<NotificationDraft> drafts) => drafts.firstWhere((d) => d.message is T).day;

void main() {
  group('payments', () {
    test('a monthly charge is announced the day before; a daily one never', () {
      final drafts = NotificationPlanner.plan(
        snap(moves: [
          expense('netflix', DateTime(2026, 10, 24, 8), 14),
          expense('coffee', DateTime(2026, 10, 24, 8), 3, frequency: RepeatFrequency.daily),
        ]),
        onlyPayments,
      );
      final charges = ofType<ChargeTomorrowMessage>(drafts);
      expect(charges.map((c) => c.ruleId), ['netflix']);
      expect(dayOf<ChargeTomorrowMessage>(drafts), day(2));
    });

    test('recurring income → payday; one-off upcoming row → planned today', () {
      final drafts = NotificationPlanner.plan(
        snap(moves: [
          income('salary', DateTime(2026, 10, 25, 9), 2400),
          expense('rent', DateTime(2026, 10, 23, 12), 800, origin: PlannedMoveOrigin.upcoming),
        ]),
        onlyPayments,
      );
      expect(dayOf<IncomeTodayMessage>(drafts), day(4));
      expect(dayOf<PlannedTodayMessage>(drafts), day(2));
      expect(ofType<PlannedTodayMessage>(drafts).single.mood, WumbiMood.handing);
    });

    test('overdraft: warned two days ahead with the balance it leaves', () {
      final drafts = NotificationPlanner.plan(
        snap(
          wallets: [SnapshotWallet(id: 'w1', name: 'Main', balance: m(100))],
          moves: [expense('rent', DateTime(2026, 10, 27, 9), 150, origin: PlannedMoveOrigin.upcoming)],
        ),
        onlyPayments,
      );
      final o = ofType<OverdraftRiskMessage>(drafts).single;
      expect(o.balanceAfter, m(-50));
      expect(o.moveAmount, m(150));
      expect(o.walletName, 'Main');
      expect(dayOf<OverdraftRiskMessage>(drafts), day(4));
    });

    test('overdraft: an income landing first keeps the wallet afloat', () {
      final drafts = NotificationPlanner.plan(
        snap(
          wallets: [SnapshotWallet(id: 'w1', name: 'Main', balance: m(100))],
          moves: [
            expense('rent', DateTime(2026, 10, 27, 9), 150, origin: PlannedMoveOrigin.upcoming),
            income('salary', DateTime(2026, 10, 26, 9), 2000),
          ],
        ),
        onlyPayments,
      );
      expect(ofType<OverdraftRiskMessage>(drafts), isEmpty);
    });

    test('overdraft: tomorrow → warned today', () {
      final drafts = NotificationPlanner.plan(
        snap(
          wallets: [SnapshotWallet(id: 'w1', name: 'Main', balance: m(10))],
          moves: [expense('gym', DateTime(2026, 10, 22, 9), 40)],
        ),
        onlyPayments,
      );
      expect(dayOf<OverdraftRiskMessage>(drafts), today);
    });
  });

  group('debts', () {
    test('due date: 3 days before, the day, then the late cadence', () {
      final drafts = NotificationPlanner.plan(
        snap(debts: [
          SnapshotDebt(
            id: 'd1',
            personName: 'Sara',
            direction: DebtDirection.borrowed,
            remaining: m(200),
            openedAt: DateTime(2026, 10, 1),
            dueDate: DateTime(2026, 10, 26),
          ),
        ]),
        onlyDebts,
      );
      expect(dayOf<DebtDueSoonMessage>(drafts), day(2));
      expect(dayOf<DebtDueTodayMessage>(drafts), day(5));
      final late = drafts.where((d) => d.message is DebtOverdueMessage).map((d) => d.day).toList();
      // +1, +3, +7 fit in 14 days; +14 and +30 fall later.
      expect(late, [day(6), day(8), day(12)]);
      expect(ofType<DebtDueTodayMessage>(drafts).single.mood, WumbiMood.alert);
    });

    test('owing money outranks being owed', () {
      DebtDueTodayMessage due(DebtDirection d) =>
          DebtDueTodayMessage(debtId: 'x', person: 'p', direction: d, remaining: m(1));
      expect(due(DebtDirection.borrowed).priority, greaterThan(due(DebtDirection.lent).priority));
    });

    test('lent without a due date: asked after 30 days', () {
      final drafts = NotificationPlanner.plan(
        snap(debts: [
          SnapshotDebt(
            id: 'd2',
            personName: 'Ali',
            direction: DebtDirection.lent,
            remaining: m(50),
            openedAt: DateTime(2026, 9, 26, 15),
          ),
        ]),
        onlyDebts,
      );
      final f = ofType<DebtForgottenMessage>(drafts).single;
      expect(f.days, 30);
      expect(dayOf<DebtForgottenMessage>(drafts), day(5));
    });
  });

  group('habits', () {
    test('nothing today, 4-day streak → streak tonight, log tomorrow, win-back at +3 / +7', () {
      final drafts = NotificationPlanner.plan(
        snap(records: [for (var i = 1; i <= 4; i++) day(-i).add(const Duration(hours: 20))]),
        onlyHabits,
      );
      final byDay = {for (final d in drafts) d.day: d.message};
      expect((byDay[today] as StreakReminderMessage).days, 4);
      expect(byDay[day(1)], isA<LogReminderMessage>());
      expect(byDay[day(2)], isNull);
      expect((byDay[day(3)] as WinBackMessage).stage, WinBackStage.missYou);
      expect((byDay[day(7)] as WinBackMessage).stage, WinBackStage.asleep);
      expect(byDay[day(7)]!.mood, WumbiMood.sleep);
    });

    test('logged today → nothing tonight; tomorrow counts today in the streak', () {
      final drafts = NotificationPlanner.plan(
        snap(records: [
          now.subtract(const Duration(hours: 1)),
          day(-1).add(const Duration(hours: 19)),
          day(-2).add(const Duration(hours: 19)),
        ]),
        onlyHabits,
      );
      expect(drafts.where((d) => d.day == today), isEmpty);
      final tomorrow = drafts.firstWhere((d) => d.day == day(1)).message as StreakReminderMessage;
      expect(tomorrow.days, 3);
    });

    test('evening slot follows the user (median + 30 min, quarter hour, 19:00–21:30)', () {
      expect(NotificationPlanner.timesFor(const []).evening, 20 * 60);
      final late = [for (var i = 0; i < 6; i++) day(-i).add(const Duration(hours: 20, minutes: 40))];
      expect(NotificationPlanner.timesFor(late).evening, 21 * 60 + 15);
      final veryLate = [for (var i = 0; i < 6; i++) day(-i).add(const Duration(hours: 22, minutes: 50))];
      expect(NotificationPlanner.timesFor(veryLate).evening, 21 * 60 + 30);
    });

    test('wording is stable for the same day', () {
      final a = NotificationPlanner.plan(snap(), onlyHabits);
      final b = NotificationPlanner.plan(snap(), onlyHabits);
      expect(
        ofType<LogReminderMessage>(a).map((m) => m.variant),
        ofType<LogReminderMessage>(b).map((m) => m.variant),
      );
    });
  });

  group('recap & morning budget', () {
    test('Sunday recap with the trend against last week', () {
      final drafts = NotificationPlanner.plan(
        snap(week: SnapshotWeek(start: DateTime(2026, 10, 19), spent: m(88), previous: m(100), topTag: 'food')),
        onlyRecaps,
      );
      final r = ofType<WeeklyRecapMessage>(drafts).single;
      expect(r.trend, WeekTrend.less);
      expect(r.percent, 12);
      expect(r.mood, WumbiMood.proud);
      expect(dayOf<WeeklyRecapMessage>(drafts), DateTime(2026, 10, 25));
    });

    test('nothing spent → no recap', () {
      final drafts = NotificationPlanner.plan(
        snap(week: SnapshotWeek(start: DateTime(2026, 10, 19), spent: m(0))),
        onlyRecaps,
      );
      expect(drafts, isEmpty);
    });

    test('morning budget: free ÷ days left; empty budget says stop', () {
      const prefs = NotificationPrefs(payments: false, debts: false, habits: false, recaps: false, morningBudget: true);
      final full = NotificationPlanner.plan(
        snap(budgets: [SnapshotBudget(id: 'b', name: 'Food', free: m(100), periodEnd: day(10))]),
        prefs,
      );
      expect(ofType<SafeToSpendMessage>(full).first.perDay, m(10));
      final empty = NotificationPlanner.plan(
        snap(budgets: [SnapshotBudget(id: 'b', name: 'Food', free: m(0), periodEnd: day(10))]),
        prefs,
      );
      expect(ofType<SafeToSpendMessage>(empty).first.mood, WumbiMood.stop);
    });

    test('everything off → nothing planned', () {
      const off = NotificationPrefs(payments: false, debts: false, habits: false, recaps: false);
      expect(NotificationPlanner.plan(snap(records: [now]), off), isEmpty);
    });
  });

  group('pacer', () {
    const times = NotificationTimes.fallback;

    test('one notification per slot; the strongest wins, money extras are counted', () {
      final drafts = [
        NotificationDraft(day(1), ChargeTomorrowMessage(ruleId: 'a', name: 'A', amount: m(5))),
        NotificationDraft(
          day(1),
          DebtOverdueMessage(debtId: 'd', person: 'P', direction: DebtDirection.borrowed, remaining: m(5), days: 3),
        ),
        NotificationDraft(day(1), const LogReminderMessage(variant: 0)),
      ];
      final plan = NotificationPacer.pace(drafts, now: now, times: times);
      expect(plan, hasLength(2));
      final morning = plan.first;
      expect(morning.slot, NotificationSlot.morning);
      expect(morning.message, isA<DebtOverdueMessage>());
      expect(morning.extraCount, 1);
      expect(morning.fireAt, DateTime(2026, 10, 22, 9));
      expect(plan.last.slot, NotificationSlot.evening);
      expect(plan.last.extraCount, 0);
    });

    test('a passed morning is dropped — unless it may move to the evening', () {
      final drafts = [
        NotificationDraft(today, ChargeTomorrowMessage(ruleId: 'a', name: 'A', amount: m(5))),
        NotificationDraft(
          today,
          OverdraftRiskMessage(
            walletId: 'w',
            walletName: 'W',
            moveName: 'x',
            moveAmount: m(1),
            balanceAfter: m(-1),
            date: day(1),
          ),
        ),
      ];
      final plan = NotificationPacer.pace(drafts, now: now, times: times);
      expect(plan.single.message, isA<OverdraftRiskMessage>());
      expect(plan.single.fireAt, DateTime(2026, 10, 21, 20));
    });

    test('ids are stable per day and slot', () {
      final a = NotificationPacer.pace(
        [NotificationDraft(day(2), const LogReminderMessage(variant: 0))],
        now: now,
        times: times,
      );
      final b = NotificationPacer.pace(
        [NotificationDraft(day(2), const StreakReminderMessage(days: 3))],
        now: now,
        times: times,
      );
      expect(a.single.id, b.single.id);
    });
  });

  group('payload & prefs', () {
    test('tap target survives the round trip', () {
      const action = MascotAction(MascotActionKind.openDebt, 'abc|1');
      final back = NotificationPayload.decode(NotificationPayload.encode(action))!;
      expect(back.kind, MascotActionKind.openDebt);
      expect(back.id, 'abc|1');
      expect(NotificationPayload.decode('addTransaction')!.id, isNull);
      expect(NotificationPayload.decode('nope'), isNull);
      expect(NotificationPayload.decode(null), isNull);
    });

    test('prefs JSON: round trip, null and garbage read as defaults', () {
      final p = const NotificationPrefs(habits: false, morningBudget: true).asked(DateTime(2026, 10, 1));
      expect(NotificationPrefs.decode(p.encode()), p);
      expect(NotificationPrefs.decode(null), const NotificationPrefs());
      expect(NotificationPrefs.decode('{oops'), const NotificationPrefs());
      expect(p.withCategory(NotificationCategory.habits, true).habits, isTrue);
    });
  });
}
