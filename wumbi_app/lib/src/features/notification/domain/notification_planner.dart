import 'dart:math' as math;

import '../../../core/money/money.dart';
import '../../../core/utils/enums/debt_direction.dart';
import '../../../core/utils/enums/repeat_frequency.dart';
import '../../../core/utils/enums/transaction_type.dart';
import 'notification_kind.dart';
import 'notification_message.dart';
import 'notification_prefs.dart';
import 'notification_snapshot.dart';

/// One message for one local day; the pacer turns it into a clock time.
class NotificationDraft {
  const NotificationDraft(this.day, this.message);

  /// Local midnight.
  final DateTime day;
  final NotificationMessage message;
}

/// Minutes after midnight of the two delivery slots.
class NotificationTimes {
  const NotificationTimes({required this.morning, required this.evening});

  static const NotificationTimes fallback = NotificationTimes(
    morning: NotificationPlanner.morningMinutes,
    evening: NotificationPlanner.defaultEveningMinutes,
  );

  final int morning;
  final int evening;

  DateTime at(DateTime day, NotificationSlot slot) {
    final m = slot == NotificationSlot.morning ? morning : evening;
    return DateTime(day.year, day.month, day.day, m ~/ 60, m % 60);
  }
}

/// snapshot + prefs → what to say on which day. Pure (unit-tested): no
/// clock, no platform, no l10n.
abstract class NotificationPlanner {
  /// Days planned ahead. Re-planned on every trip to the background, so a
  /// short horizon is enough (and stays far under iOS's 64 pending).
  static const int horizonDays = 14;

  static const int morningMinutes = 9 * 60;
  static const int defaultEveningMinutes = 20 * 60;
  static const int earliestEvening = 19 * 60;
  static const int latestEvening = 21 * 60 + 30;

  static const int dueSoonDays = 3;

  /// Reminders after a missed due date (days late). Then silence.
  static const List<int> overdueCadence = [1, 3, 7, 14, 30];

  /// Lent without a due date: asks after a month, then two.
  static const List<int> forgottenCadence = [30, 60];

  /// Days without opening the app before the hamster says it misses you /
  /// falls asleep. Nothing after the last one.
  static const int missYouAfter = 3;
  static const int asleepAfter = 7;

  static const int streakMin = 3;

  static List<NotificationDraft> plan(NotificationSnapshot s, NotificationPrefs prefs) {
    final today = dayOf(s.now);
    final lastDay = addDays(today, horizonDays);
    bool within(DateTime day) => !day.isBefore(today) && !day.isAfter(lastDay);

    final out = <NotificationDraft>[];
    void add(DateTime day, NotificationMessage m) {
      if (within(day)) out.add(NotificationDraft(day, m));
    }

    if (prefs.payments) _payments(s, today, lastDay, add);
    if (prefs.debts) _debts(s, add);
    if (prefs.habits) _habits(s, today, add);
    if (prefs.recaps) _recap(s, add);
    if (prefs.morningBudget) _morningBudget(s, today, add);
    return out;
  }

  // -------------------------------------------------------------- payments

  static void _payments(
    NotificationSnapshot s,
    DateTime today,
    DateTime lastDay,
    void Function(DateTime, NotificationMessage) add,
  ) {
    for (final m in s.moves) {
      final day = dayOf(m.date);
      switch (m.origin) {
        case PlannedMoveOrigin.rule:
          // A daily rule would ring every single day.
          if (m.frequency == RepeatFrequency.daily) continue;
          if (m.type == TransactionType.expense) {
            final on = addDays(day, -1);
            add(
              on,
              ChargeTomorrowMessage(
                ruleId: m.id,
                name: m.name,
                amount: m.amount,
                walletName: s.wallet(m.walletId)?.name,
                variant: seed('${m.id}@${dayKey(on)}'),
              ),
            );
          } else if (m.type == TransactionType.income) {
            add(day, IncomeTodayMessage(ruleId: m.id, name: m.name, amount: m.amount, walletId: m.walletId));
          }
        case PlannedMoveOrigin.upcoming:
          if (m.type == TransactionType.transfer) continue;
          add(
            day,
            PlannedTodayMessage(
              transactionId: m.id,
              type: m.type,
              name: m.name,
              amount: m.amount,
              walletId: m.walletId,
            ),
          );
      }
    }
    _overdraft(s, today, lastDay, add);
  }

  /// Walks each wallet's planned moves in date order; the first outgoing one
  /// that takes a non-negative balance below zero is worth a warning, two
  /// days ahead (or as soon as possible).
  static void _overdraft(
    NotificationSnapshot s,
    DateTime today,
    DateTime lastDay,
    void Function(DateTime, NotificationMessage) add,
  ) {
    final byWallet = <String, List<({DateTime date, int minor, PlannedMove move})>>{};
    for (final m in s.moves) {
      for (final e in m.effects) {
        byWallet.putIfAbsent(e.walletId, () => []).add((date: m.date, minor: e.minor, move: m));
      }
    }
    for (final w in s.wallets) {
      if (w.balance.isNegative) continue;
      final list = byWallet[w.id];
      if (list == null) continue;
      // Same moment: money in first — the generous reading.
      list.sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        return byDate != 0 ? byDate : b.minor.compareTo(a.minor);
      });
      var running = w.balance.minor;
      for (final e in list) {
        running += e.minor;
        if (running >= 0 || e.minor >= 0) continue;
        final day = dayOf(e.date);
        if (day.isAfter(lastDay)) break;
        final warnOn = addDays(day, -2);
        add(
          warnOn.isBefore(today) ? today : warnOn,
          OverdraftRiskMessage(
            walletId: w.id,
            walletName: w.name,
            moveName: e.move.name,
            moveAmount: Money(-e.minor, w.balance.currency),
            balanceAfter: Money(running, w.balance.currency),
            date: day,
          ),
        );
        break;
      }
    }
  }

  // ----------------------------------------------------------------- debts

  static void _debts(NotificationSnapshot s, void Function(DateTime, NotificationMessage) add) {
    for (final d in s.debts) {
      if (!d.remaining.isPositive) continue;
      final due = d.dueDate;
      if (due != null) {
        final dueDay = dayOf(due);
        add(
          addDays(dueDay, -dueSoonDays),
          DebtDueSoonMessage(
            debtId: d.id,
            person: d.personName,
            direction: d.direction,
            remaining: d.remaining,
            days: dueSoonDays,
          ),
        );
        add(
          dueDay,
          DebtDueTodayMessage(debtId: d.id, person: d.personName, direction: d.direction, remaining: d.remaining),
        );
        for (final late in overdueCadence) {
          add(
            addDays(dueDay, late),
            DebtOverdueMessage(
              debtId: d.id,
              person: d.personName,
              direction: d.direction,
              remaining: d.remaining,
              days: late,
            ),
          );
        }
      } else if (d.direction == DebtDirection.lent) {
        final opened = dayOf(d.openedAt);
        for (final after in forgottenCadence) {
          add(
            addDays(opened, after),
            DebtForgottenMessage(debtId: d.id, person: d.personName, remaining: d.remaining, days: after),
          );
        }
      }
    }
  }

  // ---------------------------------------------------------------- habits

  /// Planned right when the app leaves the screen, so "nothing logged on day
  /// N" is guaranteed for every future day: logging means opening the app,
  /// which plans again. Today, tomorrow, then a quiet day, then the two
  /// win-back messages — and silence.
  static void _habits(NotificationSnapshot s, DateTime today, void Function(DateTime, NotificationMessage) add) {
    final days = {for (final t in s.recordTimes) dayOf(t)};
    final loggedToday = days.contains(today);
    final streakToYesterday = streakEndingOn(days, addDays(today, -1));

    LogReminderMessage log(DateTime day) => LogReminderMessage(variant: seed('log@${dayKey(day)}'));

    if (!loggedToday) {
      add(
        today,
        streakToYesterday >= streakMin ? StreakReminderMessage(days: streakToYesterday) : log(today),
      );
      add(addDays(today, 1), log(addDays(today, 1)));
    } else {
      final streak = streakToYesterday + 1;
      final tomorrow = addDays(today, 1);
      add(tomorrow, streak >= streakMin ? StreakReminderMessage(days: streak) : log(tomorrow));
    }
    add(addDays(today, missYouAfter), const WinBackMessage(stage: WinBackStage.missYou));
    add(addDays(today, asleepAfter), const WinBackMessage(stage: WinBackStage.asleep));
  }

  // ---------------------------------------------------------------- recaps

  static void _recap(NotificationSnapshot s, void Function(DateTime, NotificationMessage) add) {
    final w = s.week;
    if (w == null || !w.spent.isPositive) return;
    final sunday = addDays(w.start, 6);
    final prev = w.previous;
    var trend = WeekTrend.same;
    var percent = 0;
    if (prev != null && prev.isPositive && prev.currency == w.spent.currency) {
      final change = ((w.spent.minor - prev.minor) * 100 / prev.minor).round();
      percent = change.abs();
      if (percent >= 5) trend = change < 0 ? WeekTrend.less : WeekTrend.more;
    }
    add(sunday, WeeklyRecapMessage(spent: w.spent, trend: trend, percent: percent, topTag: w.topTag));
  }

  // ----------------------------------------------------------- morning budget

  /// Today and tomorrow (spending today re-plans tomorrow anyway). One
  /// budget per morning, rotating through the running ones.
  static void _morningBudget(NotificationSnapshot s, DateTime today, void Function(DateTime, NotificationMessage) add) {
    if (s.budgets.isEmpty) return;
    for (final day in [today, addDays(today, 1)]) {
      final b = s.budgets[seed('budget@${dayKey(day)}') % s.budgets.length];
      final left = daysBetween(day, b.periodEnd);
      if (left < 1) continue;
      final perDay = b.free.minor ~/ left;
      add(
        day,
        SafeToSpendMessage(
          budgetId: b.id,
          name: b.name,
          perDay: perDay > 0 ? Money(perDay, b.free.currency) : null,
        ),
      );
    }
  }

  // ------------------------------------------------------------ evening time

  /// The evening slot follows the user: 30 min after their usual evening
  /// logging time (median, 16:00–23:00 entries), rounded to a quarter hour
  /// and kept within 19:00–21:30. 20:00 until there are 5 such entries.
  static NotificationTimes timesFor(List<DateTime> recordTimes) {
    final evening = recordTimes
        .map((t) => t.hour * 60 + t.minute)
        .where((m) => m >= 16 * 60 && m < 23 * 60)
        .toList()
      ..sort();
    var minutes = defaultEveningMinutes;
    if (evening.length >= 5) {
      final median = evening[evening.length ~/ 2] + 30;
      minutes = ((median / 15).round() * 15).clamp(earliestEvening, latestEvening).toInt();
    }
    return NotificationTimes(morning: morningMinutes, evening: minutes);
  }

  // ---------------------------------------------------------------- helpers

  static DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Calendar arithmetic (DST safe).
  static DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

  static int daysBetween(DateTime a, DateTime b) =>
      DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

  static String dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  /// Consecutive days with an entry, ending on [last].
  static int streakEndingOn(Set<DateTime> days, DateTime last) {
    var n = 0;
    var cursor = last;
    while (days.contains(cursor)) {
      n++;
      cursor = addDays(cursor, -1);
    }
    return n;
  }

  /// FNV-1a: a wording choice that is the same on every run and device
  /// (`String.hashCode` is not guaranteed to be).
  static int seed(String s) {
    var h = 0x811c9dc5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return math.max(0, h & 0x7fffffff);
  }
}
