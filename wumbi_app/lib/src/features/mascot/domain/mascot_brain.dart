import 'dart:math' as math;

import 'package:collection/collection.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/money/money.dart';
import '../data/mascot_memory.dart';
import 'mascot_message.dart';
import 'mascot_reaction.dart';
import 'mascot_signals.dart';

/// The dashboard "brain" (spec §3): signals → ordered candidate messages →
/// the one to say this session. Pure, so it is unit-tested.
abstract class MascotBrain {
  static const Duration insightCooldown = Duration(days: 7);
  static const Duration tipCooldown = Duration(days: 14);
  static const Duration greetingCooldown = Duration(days: 1);

  /// Taps that advance to the next thought per session.
  static const int maxTapsPerSession = 3;

  /// Anniversaries celebrated once each (within a week of the day).
  static const List<int> anniversaryDays = [7, 30, 100, 365];

  /// Every message valid right now, highest priority first; the last one is
  /// always the summary (always valid). [variant] rotates the wording of
  /// warnings, which hold for as long as the problem lasts. Insights, tips
  /// and jokes are shuffled per day, so each visit brings another one.
  static List<MascotMessage> dashboard(MascotSignals s, {int variant = 0}) {
    final warnTop = <MascotMessage>[];
    final since = <MascotMessage>[];
    final warnLow = <MascotMessage>[];
    final events = <MascotMessage>[];
    final insights = <MascotMessage>[];
    final tips = <MascotMessage>[];
    final jokes = <MascotMessage>[];
    T pick<T>(List<T> options) => options[variant % options.length];
    final month = '${s.now.year}-${s.now.month}';
    final day = MascotMemory.dayKey(s.now);
    final week = '${s.now.year}w${_weekOfYear(s.now)}';

    MascotMessage insight(String id, WumbiMood mood, MascotLine line, String hash, {MascotAction? action}) =>
        MascotMessage(id: id, tier: MascotTier.insight, mood: mood, line: line, hash: hash, action: action, cooldown: insightCooldown);
    MascotMessage tip(String id, WumbiMood mood, MascotLine line, String hash, {MascotAction? action}) =>
        MascotMessage(id: id, tier: MascotTier.tip, mood: mood, line: line, hash: hash, action: action, cooldown: tipCooldown);
    MascotMessage joke(String id, WumbiMood mood, MascotPhrase phrase, String hash, {WumbiMood? then}) => MascotMessage(
        id: id,
        tier: MascotTier.joke,
        mood: mood,
        line: MascotLine(phrase),
        hash: hash,
        cooldown: jokeCooldown,
        afterMood: then);

    // ---- warnings (state table #1–3) -----------------------------------
    final overdue = s.overdueDebt;
    if (overdue != null) {
      warnTop.add(MascotMessage(
        id: 'warn.debtOverdue',
        tier: MascotTier.warning,
        mood: WumbiMood.alert,
        line: pick([
          MascotLine(MascotPhrase.debtOverdue, name: overdue.name, count: overdue.days),
          MascotLine(MascotPhrase.debtOverdueNudge, name: overdue.name),
        ]),
        action: MascotAction(MascotActionKind.openDebt, overdue.id),
      ));
    }
    final over = s.overBudget;
    if (over != null) {
      warnTop.add(MascotMessage(
        id: 'warn.budgetOver',
        tier: MascotTier.warning,
        mood: WumbiMood.stop,
        line: pick([
          MascotLine(MascotPhrase.budgetOver, name: over.name),
          MascotLine(MascotPhrase.budgetOverBy, name: over.name, amount: over.amount),
        ]),
        action: MascotAction(MascotActionKind.openBudget, over.id),
      ));
    }
    final near = s.nearBudget;
    if (near != null) {
      warnTop.add(MascotMessage(
        id: 'warn.budgetNear',
        tier: MascotTier.warning,
        mood: WumbiMood.nervous,
        line: pick([
          MascotLine(MascotPhrase.budgetNearLeft, name: near.name, amount: near.amount),
          MascotLine(MascotPhrase.budgetNearPercent, name: near.name, count: near.percent),
        ]),
        action: MascotAction(MascotActionKind.openBudget, near.id),
      ));
    }

    // ---- since the last visit ---------------------------------------------
    final away = s.daysSincePrevVisit;
    if (away != null && away >= 7) {
      since.add(MascotMessage(
        id: 'visit.welcomeBack',
        tier: MascotTier.sinceVisit,
        mood: WumbiMood.wave,
        line: MascotLine(MascotPhrase.welcomeBack, count: s.recordsSinceVisit),
        hash: MascotMemory.dayKey(s.prevVisitAt!),
      ));
    } else if (away != null && away >= 1 && s.now.hour >= 18 && s.recordsToday == 0) {
      // A whole day away, back in the evening: it waited, it missed you,
      // then it asks for today's spending (alternating the ask).
      final ask = s.now.day.isEven
          ? const MascotStep(WumbiMood.sigh, MascotLine(MascotPhrase.eveningCount),
              action: MascotAction(MascotActionKind.addTransaction))
          : const MascotStep(WumbiMood.alert, MascotLine(MascotPhrase.eveningLog),
              action: MascotAction(MascotActionKind.addTransaction));
      since.add(MascotMessage(
        id: 'story.evening',
        tier: MascotTier.sinceVisit,
        mood: WumbiMood.impatient,
        line: const MascotLine(MascotPhrase.eveningWaited),
        steps: [const MascotStep(WumbiMood.sad, MascotLine(MascotPhrase.eveningMissed)), ask],
        hash: day,
      ));
    }

    // ---- warnings (state table #4–5) -----------------------------------
    final idle = s.daysSinceLastRecord;
    if (idle != null && idle >= 5) {
      warnLow.add(MascotMessage(
        id: 'warn.sleep',
        tier: MascotTier.warning,
        mood: WumbiMood.sleep,
        line: pick([
          MascotLine(MascotPhrase.sleepDays, count: idle),
          const MascotLine(MascotPhrase.sleepQuiet),
        ]),
        action: const MascotAction(MascotActionKind.addTransaction),
      ));
    }
    final reserve = s.reserveMonths;
    if (s.monthFlow.isNegative && reserve != null && reserve < 0.5) {
      warnLow.add(MascotMessage(
        id: 'warn.sigh',
        tier: MascotTier.warning,
        mood: WumbiMood.sigh,
        line: pick(const [MascotLine(MascotPhrase.sighMonth), MascotLine(MascotPhrase.sighAhead)]),
        action: const MascotAction(MascotActionKind.openProgress),
      ));
    }

    // ---- events (once ever) ---------------------------------------------
    if (reserve != null && reserve >= 3) {
      events.add(const MascotMessage(
        id: 'event.reserve3',
        tier: MascotTier.event,
        mood: WumbiMood.victory,
        line: MascotLine(MascotPhrase.eventReserve),
      ));
    }
    final best = s.bestMonthSaved;
    if (best != null) {
      events.add(MascotMessage(
        id: 'event.bestMonth.$month',
        tier: MascotTier.event,
        mood: WumbiMood.proud,
        line: MascotLine(MascotPhrase.eventBestMonth, amount: best),
        action: const MascotAction(MascotActionKind.openProgress),
      ));
    }
    final days = s.daysWithWumbi;
    if (days != null) {
      for (final n in anniversaryDays) {
        if (days >= n && days < n + 7) {
          // `love` is kept for these few moments of connection.
          events.add(MascotMessage(
            id: 'event.days.$n',
            tier: MascotTier.event,
            mood: WumbiMood.love,
            line: MascotLine(MascotPhrase.eventDays, count: n),
          ));
        }
      }
    }
    if (s.recordCount >= 100 && s.recordCount < 130) {
      events.add(const MascotMessage(
        id: 'event.records100',
        tier: MascotTier.event,
        mood: WumbiMood.love,
        line: MascotLine(MascotPhrase.eventRecords),
      ));
    }
    for (final n in streakDays) {
      if (s.streakDays >= n && s.streakDays < n + 3) {
        events.add(MascotMessage(
          id: 'event.streak.$n.$month',
          tier: MascotTier.event,
          mood: n >= 30 ? WumbiMood.victory : WumbiMood.proud,
          line: MascotLine(MascotPhrase.eventStreak, count: n),
        ));
      }
    }

    // ---- insights (7 days per data) --------------------------------------
    final charge = s.chargeSoon;
    if (charge != null) {
      final phrase = switch (charge.days) {
        0 => MascotPhrase.chargeToday,
        1 => MascotPhrase.chargeTomorrow,
        _ => MascotPhrase.chargeSoon,
      };
      insights.add(insight(
        'insight.charge',
        WumbiMood.calendar,
        MascotLine(phrase, name: charge.name, amount: charge.amount),
        '${charge.id}@${MascotMemory.dayKey(s.now.add(Duration(days: charge.days)))}#${charge.days}',
        action: const MascotAction(MascotActionKind.openSubscriptions),
      ));
    }
    final dueSoon = s.dueSoonDebt;
    if (dueSoon != null) {
      insights.add(insight(
        'insight.debtDue',
        WumbiMood.calendar,
        switch (dueSoon.days) {
          0 => MascotLine(MascotPhrase.debtDueToday, name: dueSoon.name),
          1 => MascotLine(MascotPhrase.debtDueTomorrow, name: dueSoon.name),
          _ => MascotLine(MascotPhrase.debtDueSoon, name: dueSoon.name, count: dueSoon.days),
        },
        '${dueSoon.id}#${dueSoon.days}',
        action: MascotAction(MascotActionKind.openDebt, dueSoon.id),
      ));
    }
    final mover = s.mover;
    if (mover != null) {
      insights.add(insight(
        'insight.mover',
        WumbiMood.thinking,
        MascotLine(MascotPhrase.insightMover, name: mover.name, count: mover.percent),
        '${mover.tagId}@$month',
        action: const MascotAction(MascotActionKind.openProgress),
      ));
    }
    if (s.untaggedCount >= 5) {
      insights.add(insight(
        'insight.untagged',
        WumbiMood.sorting,
        MascotLine(MascotPhrase.insightUntagged, count: s.untaggedCount),
        '$month#${s.untaggedCount ~/ 10}',
        action: const MascotAction(MascotActionKind.openProgress),
      ));
    }
    final peak = s.peakWeekday;
    if (peak != null) {
      insights.add(insight(
        'insight.peakDay',
        WumbiMood.thinking,
        MascotLine(MascotPhrase.insightPeakDay, name: peak),
        '$peak@$month',
        action: const MascotAction(MascotActionKind.openProgress),
      ));
    }
    if (reserve != null && reserve >= 1 && reserve < 3) {
      insights.add(insight(
        'insight.reserve',
        WumbiMood.calm,
        MascotLine(MascotPhrase.insightReserve, count: reserve.floor()),
        '${reserve.floor()}',
      ));
    }
    final top = s.topExpense;
    final topAmount = top?.amount;
    if (top != null && topAmount != null) {
      insights.add(insight(
        'insight.topExpense',
        WumbiMood.thinking,
        top.name.isEmpty
            ? MascotLine(MascotPhrase.insightTopExpenseAmount, amount: topAmount)
            : MascotLine(MascotPhrase.insightTopExpense, name: top.name, amount: topAmount),
        top.id,
        action: const MascotAction(MascotActionKind.openProgress),
      ));
    }
    final daily = s.dailyAverage;
    final change = s.dailyChangePercent;
    if (change != null && change <= -15) {
      insights.add(insight('insight.dailyBelow', WumbiMood.proud,
          MascotLine(MascotPhrase.insightDailyBelow, count: -change), '$week#${change ~/ 10}'));
    } else if (change != null && change >= 20) {
      insights.add(insight('insight.dailyAbove', WumbiMood.nervous,
          MascotLine(MascotPhrase.insightDailyAbove, count: change), '$week#${change ~/ 10}',
          action: const MascotAction(MascotActionKind.openProgress)));
    } else if (daily != null && daily.isPositive && s.now.day >= 5) {
      insights.add(insight('insight.dailyAverage', WumbiMood.counting,
          MascotLine(MascotPhrase.insightDailyAverage, amount: daily), week));
    }
    final weekend = s.weekendPercent;
    if (weekend != null && weekend >= 50) {
      insights.add(insight('insight.weekend', WumbiMood.thinking,
          MascotLine(MascotPhrase.insightWeekend, count: weekend), '$month#${weekend ~/ 25}',
          action: const MascotAction(MascotActionKind.openProgress)));
    }
    final frequent = s.frequentTag;
    if (frequent != null && frequent.count >= 8) {
      insights.add(insight('insight.frequentTag', WumbiMood.sorting,
          MascotLine(MascotPhrase.insightFrequentTag, name: frequent.name, count: frequent.count),
          '${frequent.id}@$month#${frequent.count ~/ 5}'));
    }
    final small = s.smallSpends;
    if (small != null) {
      insights.add(insight('insight.smallSpends', WumbiMood.counting,
          MascotLine(MascotPhrase.insightSmallSpends, amount: small), week));
    }
    final rate = s.savingsRatePercent;
    if (rate != null && rate >= 20) {
      insights.add(insight('insight.savingsRate', WumbiMood.reserveFull,
          MascotLine(MascotPhrase.insightSavingsRate, count: rate), '$month#${rate ~/ 10}'));
    }
    if (s.now.day >= 10 && s.monthIncome.isZero && s.recordCount >= 10) {
      insights.add(insight('insight.noIncome', WumbiMood.thinking, const MascotLine(MascotPhrase.insightNoIncome),
          month, action: const MascotAction(MascotActionKind.addTransaction)));
    }
    final forecast = s.forecast;
    final avg = s.avgMonthlyExpense;
    if (forecast != null && avg != null && avg.isPositive && avg.currency == forecast.currency) {
      if (forecast.minor * 100 > avg.minor * 115) {
        insights.add(insight('insight.forecastOver', WumbiMood.nervous,
            MascotLine(MascotPhrase.insightForecastOver, amount: forecast), week,
            action: const MascotAction(MascotActionKind.openProgress)));
      } else if (s.now.day >= 10 && forecast.minor * 100 < avg.minor * 90) {
        insights.add(insight('insight.forecastUnder', WumbiMood.calm,
            MascotLine(MascotPhrase.insightForecastUnder, amount: forecast), week));
      }
    }
    final owed = s.owedToMe;
    final owedAmount = owed?.amount;
    if (owed != null && owedAmount != null && owedAmount.isPositive) {
      insights.add(insight('insight.owedToMe', WumbiMood.alert,
          MascotLine(MascotPhrase.insightOwedToMe, amount: owedAmount), '${owedAmount.minor}',
          action: const MascotAction(MascotActionKind.openDebts)));
    }
    final negative = s.negativeWallet;
    if (negative != null) {
      insights.add(insight('insight.negativeWallet', WumbiMood.nervous,
          MascotLine(MascotPhrase.insightNegativeWallet, name: negative.name), '${negative.id}@$day',
          action: MascotAction(MascotActionKind.openWallet, negative.id)));
    }
    final noRate = s.noRateCodes;
    if (noRate != null && noRate.isNotEmpty) {
      insights.add(insight('insight.noRate', WumbiMood.shrug, MascotLine(MascotPhrase.insightNoRate, name: noRate), '$noRate@$day'));
    }

    final avgIncome = s.avgMonthlyIncome;
    if (avgIncome != null &&
        avgIncome.isPositive &&
        avgIncome.currency == s.monthIncome.currency &&
        s.monthIncome.minor * 100 > avgIncome.minor * 115) {
      final up = ((s.monthIncome.minor - avgIncome.minor) * 100 / avgIncome.minor).round();
      insights.add(insight('insight.incomeUp', WumbiMood.reserveFull,
          MascotLine(MascotPhrase.insightIncomeUp, count: up), '$month#${up ~/ 10}'));
    }
    if (s.topFamilies.isNotEmpty && s.now.day >= 7) {
      final family = s.topFamilies.first;
      final spent = family.amount;
      if (spent != null && spent.isPositive && family.count >= 15) {
        final yearly = Money((spent.minor / s.now.day * 365).round(), spent.currency);
        insights.add(insight('insight.tagYearly', WumbiMood.thinking,
            MascotLine(MascotPhrase.insightTagYearly, name: family.name, amount: yearly), '${family.id}@$month',
            action: const MascotAction(MascotActionKind.openProgress)));
      }
    }
    if (s.noSpendYesterday) {
      insights.add(insight('insight.noSpendYesterday', WumbiMood.proud,
          const MascotLine(MascotPhrase.insightNoSpendYesterday), day));
    }

    // ---- tips (14 days) ---------------------------------------------------
    if (s.walletCount == 1 && s.recordCount >= 15) {
      tips.add(tip('tip.rainyDay', WumbiMood.kindly, const MascotLine(MascotPhrase.tipRainyDay), 'v1'));
    }
    final sinceIncome = s.daysSinceIncome;
    if (sinceIncome != null && sinceIncome <= 1) {
      tips.add(tip('tip.payYourselfFirst', WumbiMood.saving, const MascotLine(MascotPhrase.tipPayYourselfFirst), day,
          action: const MascotAction(MascotActionKind.addTransaction)));
    }
    if (reserve != null && reserve >= 1.5 && s.monthFlow.isPositive) {
      tips.add(tip('tip.treat', WumbiMood.happy, const MascotLine(MascotPhrase.tipTreat), month));
    }
    if (s.recordCount >= 10) {
      final unit = math.pow(10, s.base.scale).toInt();
      tips.add(tip(
        'tip.futureSelf',
        WumbiMood.thinking,
        MascotLine(MascotPhrase.tipFutureSelf, amount: Money(5 * unit, s.base), amount2: Money(5 * unit * 365, s.base)),
        'v1',
      ));
    }
    if (s.budgetCount == 0 && s.monthExpenseCount >= 5) {
      tips.add(tip('tip.budget', WumbiMood.kindly, const MascotLine(MascotPhrase.tipBudget), 'v1',
          action: const MascotAction(MascotActionKind.newBudget)));
    }
    if (s.activeSubscriptions == 0 && s.recordCount >= 20) {
      tips.add(tip('tip.subscriptions', WumbiMood.calendar, const MascotLine(MascotPhrase.tipSubscriptions), 'v1',
          action: const MascotAction(MascotActionKind.openSubscriptions)));
    }
    final subs = s.subsMonthly;
    if (subs != null && subs.isPositive) {
      tips.add(tip('tip.subsYearly', WumbiMood.calendar,
          MascotLine(MascotPhrase.tipSubsYearly, amount: Money(subs.minor * 12, subs.currency)), '${subs.minor}',
          action: const MascotAction(MascotActionKind.openSubscriptions)));
    }
    final recurring = s.recurringPercent;
    if (recurring != null && recurring >= 30) {
      tips.add(tip('tip.recurringShare', WumbiMood.wheel,
          MascotLine(MascotPhrase.tipRecurringShare, count: recurring), '$month#${recurring ~/ 10}',
          action: const MascotAction(MascotActionKind.openSubscriptions)));
    }
    if (s.now.day <= 3) {
      tips.add(tip('tip.newMonth', WumbiMood.kindly, const MascotLine(MascotPhrase.tipNewMonth), month,
          action: MascotAction(s.budgetCount == 0 ? MascotActionKind.newBudget : MascotActionKind.openBudgets)));
    }
    final lastWeek = s.lastWeekExpense;
    if (s.now.weekday == DateTime.monday && lastWeek != null && lastWeek.isPositive) {
      tips.add(tip('tip.mondayRecap', WumbiMood.counting, MascotLine(MascotPhrase.tipMondayRecap, amount: lastWeek), week,
          action: const MascotAction(MascotActionKind.openProgress)));
    }
    final left = s.daysLeftInMonth;
    if (left >= 1 && left <= 3 && s.monthExpenseCount > 0) {
      tips.add(tip('tip.monthEnd', WumbiMood.thumbsUp, MascotLine(MascotPhrase.tipMonthEnd, count: left), month));
    }
    if (s.untaggedPercent >= 50 && s.monthExpenseCount >= 10) {
      tips.add(tip('tip.tags', WumbiMood.sorting, const MascotLine(MascotPhrase.tipTags), month));
    }
    final noDue = s.borrowedNoDue;
    if (noDue != null) {
      tips.add(tip('tip.debtDueDate', WumbiMood.calendar, MascotLine(MascotPhrase.tipDebtDueDate, name: noDue.name),
          noDue.id, action: MascotAction(MascotActionKind.openDebt, noDue.id)));
    }
    final suggestion = s.budgetSuggestion;
    if (suggestion != null) {
      tips.add(tip('tip.budgetFor', WumbiMood.kindly,
          MascotLine(MascotPhrase.tipBudgetFor, name: suggestion.name, count: suggestion.count), '${suggestion.id}@$month',
          action: const MascotAction(MascotActionKind.newBudget)));
    }

    // ---- jokes (now and then) ---------------------------------------------
    if (s.recordCount >= 3) {
      if (s.now.weekday == DateTime.friday && s.now.hour >= 16) {
        jokes.add(joke('joke.friday', WumbiMood.happy, MascotPhrase.jokeFriday, day));
      }
      if (s.now.hour >= 23 || s.now.hour < 5) {
        jokes.add(joke('joke.lateNight', WumbiMood.sleep, MascotPhrase.jokeLateNight, day));
      }
      jokes
        ..add(joke('joke.cheeks', WumbiMood.cheeksStuffed, MascotPhrase.jokeCheeks, 'v1'))
        ..add(joke('joke.trees', WumbiMood.reserveFull, MascotPhrase.jokeTrees, 'v1'))
        // Sorts the seeds, then smiles: it all adds up.
        ..add(joke('joke.twice', WumbiMood.sorting, MascotPhrase.jokeTwice, 'v1', then: WumbiMood.kindly))
        ..add(joke('joke.secret', WumbiMood.hush, MascotPhrase.jokeSecret, 'v1'));
    }

    // Same order all day (sticky picks stay put), another one tomorrow.
    final random = math.Random(s.now.year * 1000 + _dayOfYear(s.now));
    insights.shuffle(random);
    tips.shuffle(random);
    jokes.shuffle(random);

    // ---- greeting (first open of the day) + summary -----------------------
    final summary = summaryOf(s);
    MascotMessage? greeting;
    if (s.firstOpenToday) {
      final hour = s.now.hour;
      final phrase = hour >= 5 && hour < 12
          ? MascotPhrase.greetingMorning
          : (hour >= 12 && hour < 18 ? MascotPhrase.greetingAfternoon : MascotPhrase.greetingEvening);
      greeting = MascotMessage(
        id: 'greeting',
        tier: MascotTier.greeting,
        mood: WumbiMood.wave,
        line: MascotLine(phrase, then: summary.line),
        hash: day,
        cooldown: greetingCooldown,
      );
    }
    return [
      ...warnTop,
      ...since,
      ...warnLow,
      ...events,
      ...insights,
      ...tips,
      ...jokes,
      ?greeting,
      summary,
    ];
  }

  /// Streak milestones (days in a row with a record).
  static const List<int> streakDays = [7, 14, 30];

  static const Duration jokeCooldown = Duration(days: 5);

  static int _dayOfYear(DateTime d) => DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(d.year)).inDays;

  static int _weekOfYear(DateTime d) => (_dayOfYear(d) - d.weekday + 10) ~/ 7;

  /// State table #7–9: always valid.
  static MascotMessage summaryOf(MascotSignals s) {
    final reserve = s.reserveMonths;
    if (reserve != null && reserve >= 3) {
      return MascotMessage(
        id: 'summary',
        tier: MascotTier.summary,
        mood: WumbiMood.reserveFull,
        line: MascotLine(MascotPhrase.reserveFull, count: reserve.floor()),
      );
    }
    final flow = s.monthFlow;
    if (flow.isPositive) {
      return MascotMessage(
        id: 'summary',
        tier: MascotTier.summary,
        mood: WumbiMood.happy,
        line: MascotLine(MascotPhrase.flowUp, amount: flow, date: s.now),
        action: const MascotAction(MascotActionKind.openProgress),
      );
    }
    if (flow.isNegative) {
      return MascotMessage(
        id: 'summary',
        tier: MascotTier.summary,
        mood: WumbiMood.calm,
        line: MascotLine(MascotPhrase.flowDown, amount: flow.abs(), date: s.now),
        action: const MascotAction(MascotActionKind.openProgress),
      );
    }
    return const MascotMessage(
      id: 'summary',
      tier: MascotTier.summary,
      mood: WumbiMood.calm,
      line: MascotLine(MascotPhrase.allCalm),
    );
  }

  /// "That's all I know for now" — after [maxTapsPerSession] taps.
  static const MascotMessage allForNow = MascotMessage(
    id: 'ui.allForNow',
    tier: MascotTier.summary,
    mood: WumbiMood.happy,
    line: MascotLine(MascotPhrase.allForNow),
  );

  /// Long-press: "OK, I'll keep quiet today".
  static const MascotMessage quietToday = MascotMessage(
    id: 'ui.quiet',
    tier: MascotTier.summary,
    mood: WumbiMood.hush,
    line: MascotLine(MascotPhrase.quietToday),
  );

  /// The message to say (spec §3.3): the first candidate that is a warning
  /// or not said recently on the same data. Within a session the [stickyId]
  /// keeps its place unless a warning ranks above it; [skipped] are the
  /// thoughts already tapped past.
  static MascotMessage select(
    List<MascotMessage> candidates, {
    required MascotMemory memory,
    required DateTime now,
    String? stickyId,
    Set<String> skipped = const {},
  }) {
    if (stickyId != null) {
      final i = candidates.indexWhere((c) => c.id == stickyId);
      if (i >= 0) {
        final warningAbove = candidates.take(i).any((c) => c.tier == MascotTier.warning && !skipped.contains(c.id));
        if (!warningAbove) return candidates[i];
      }
    }
    for (final c in candidates) {
      if (skipped.contains(c.id)) continue;
      if (c.tier == MascotTier.warning || memory.isEligible(c, now)) return c;
    }
    return candidates.last;
  }

  /// The 2.5 s reaction to [r]; [s] (when loaded) decides a "big" income.
  static MascotMessage reaction(MascotReaction r, MascotSignals? s) {
    MascotMessage msg(WumbiMood mood, [MascotLine? line]) =>
        MascotMessage(id: 'reaction.${r.kind.name}', tier: MascotTier.reaction, mood: mood, line: line);
    final amount = r.amount;
    switch (r.kind) {
      case MascotReactionKind.income:
        final avg = s?.avgMonthlyIncome;
        final big = amount != null &&
            avg != null &&
            avg.isPositive &&
            amount.currency == avg.currency &&
            amount.minor >= avg.minor;
        return big
            ? msg(WumbiMood.cheeksStuffed, MascotLine(MascotPhrase.reactionBigIncome, amount: amount))
            : msg(WumbiMood.catching, amount == null ? null : MascotLine(MascotPhrase.reactionIncome, amount: amount));
      case MascotReactionKind.expense:
        return msg(WumbiMood.tossing);
      case MascotReactionKind.transfer:
        return msg(WumbiMood.handing, amount == null ? null : MascotLine(MascotPhrase.reactionTransfer, amount: amount));
      case MascotReactionKind.lent:
        return msg(WumbiMood.handing, amount == null ? null : MascotLine(MascotPhrase.reactionLent, amount: amount));
      case MascotReactionKind.debtClosed:
        return msg(WumbiMood.dusting, const MascotLine(MascotPhrase.reactionDebtClosed));
      case MascotReactionKind.debtForgiven:
        return msg(WumbiMood.love, const MascotLine(MascotPhrase.reactionForgiven));
      case MascotReactionKind.firstWallet:
        return msg(WumbiMood.celebrate, const MascotLine(MascotPhrase.reactionFirstWallet));
      case MascotReactionKind.budgetCreated:
        return msg(WumbiMood.thumbsUp, const MascotLine(MascotPhrase.reactionBudget));
    }
  }

  /// Mean of the newest [take] values (null when empty).
  static Money? meanOf(Iterable<Money> values, {int take = 3}) {
    final list = values.toList();
    if (list.isEmpty) return null;
    final used = list.sublist(list.length - (take < list.length ? take : list.length));
    return Money((used.map((m) => m.minor).sum / used.length).round(), used.first.currency);
  }
}
