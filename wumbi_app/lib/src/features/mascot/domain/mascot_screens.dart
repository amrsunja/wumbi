import 'dart:math' as math;

import '../../../core/design_system/app_ui.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/enums/debt_close_reason.dart';
import '../../../core/utils/enums/debt_direction.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../budget/data/budget_metrics.dart';
import '../../budget/data/models/budget_model.dart';
import '../../debt/data/models/debt_model.dart';
import '../../progress/data/models/progress_stats.dart';
import '../../transaction/data/models/recurring_rule_model.dart';
import 'mascot_message.dart';
import 'mascot_signals.dart';

/// What a screen's hamster shows: its emotion, an optional line, the one
/// action it offers and whether the line is important enough to flag
/// ([auto]: a dot on the peeking head).
class MascotCornerState {
  const MascotCornerState(this.mood, {this.line, this.auto = false, this.action, this.steps = const [], this.afterMood});

  /// The dashboard's current thought as a screen state.
  factory MascotCornerState.of(MascotMessage m) => MascotCornerState(
        m.mood,
        line: m.line,
        action: m.action,
        steps: m.steps,
        afterMood: m.afterMood,
        auto: m.tier == MascotTier.warning || m.tier == MascotTier.event || m.steps.isNotEmpty,
      );

  final WumbiMood mood;
  final MascotLine? line;
  final bool auto;
  final MascotAction? action;

  /// Further beats, each with its own emotion (a little story).
  final List<MascotStep> steps;

  /// The face it settles into after the line (and its beats).
  final WumbiMood? afterMood;

  /// Every face of the line in order: its own, each beat's, the settle one.
  List<WumbiMood> get moods => [mood, for (final s in steps) s.mood, ?afterMood];

  /// Identity of what is shown (keys, "has it changed?").
  String get signature =>
      '${mood.name}|${line?.signature}|${steps.map((s) => s.line.signature).join(',')}|${afterMood?.name}';

  static const MascotCornerState idle = MascotCornerState(WumbiMood.idle);
}

/// Per-screen emotions (spec §4.7–4.16) and the Progress verdict (§4.14).
/// Pure: every input is already loaded by the page.
abstract class MascotScreens {
  // ------------------------------------------------------ per-visit pools

  /// The page's state first; when it is not important, a few useful tips
  /// the hamster alternates with it from one visit to the next.
  static List<MascotCornerState> withTips(MascotCornerState state, List<MascotCornerState> tips) =>
      state.auto ? [state] : [state, ...tips];

  static MascotCornerState _tip(WumbiMood mood, MascotPhrase phrase) => MascotCornerState(mood, line: MascotLine(phrase));

  static List<MascotCornerState> walletTips({required bool manyWallets}) => [
        _tip(WumbiMood.sorting, MascotPhrase.screenWalletFilter),
        _tip(WumbiMood.kindly, MascotPhrase.screenWalletLimit),
        if (manyWallets) _tip(WumbiMood.wave, MascotPhrase.screenWalletSwitch),
      ];

  static List<MascotCornerState> budgetsTips() => [
        _tip(WumbiMood.thinking, MascotPhrase.screenBudgetsRollover),
        _tip(WumbiMood.sorting, MascotPhrase.screenBudgetsTags),
      ];

  static List<MascotCornerState> budgetDetailsTips() => [
        _tip(WumbiMood.calendar, MascotPhrase.screenBudgetPeriods),
      ];

  static List<MascotCornerState> debtsTips() => [
        _tip(WumbiMood.calendar, MascotPhrase.screenDebtsDue),
        _tip(WumbiMood.handing, MascotPhrase.screenDebtsQuick),
      ];

  static List<MascotCornerState> debtDetailsTips(DebtSummary s) => [
        if (s.isOpen && s.debt.dueDate == null) _tip(WumbiMood.calendar, MascotPhrase.screenDebtsDue),
      ];

  static List<MascotCornerState> subscriptionsTips({Money? monthly}) => [
        _tip(WumbiMood.calm, MascotPhrase.screenSubsPause),
        if (monthly != null && monthly.isPositive)
          MascotCornerState(
            WumbiMood.calendar,
            line: MascotLine(MascotPhrase.tipSubsYearly, amount: Money(monthly.minor * 12, monthly.currency)),
          ),
      ];

  static List<MascotCornerState> tagsTips() => [
        _tip(WumbiMood.sorting, MascotPhrase.screenTagsNest),
        _tip(WumbiMood.thinking, MascotPhrase.screenTagsMap),
      ];

  static List<MascotCornerState> tagDetailsTips() => [
        _tip(WumbiMood.sorting, MascotPhrase.screenTagRename),
      ];

  static List<MascotCornerState> progressTips() => [
        _tip(WumbiMood.counting, MascotPhrase.screenProgressBaseline),
      ];

  // ------------------------------------------------------- wallet details

  /// [monthNet]: the wallet's change since the 1st (its currency);
  /// [lastActivityAt]: newest posted row.
  static MascotCornerState wallet({
    required Money balance,
    required int? monthNet,
    required DateTime? lastActivityAt,
    required DateTime now,
  }) {
    if (balance.isNegative) {
      return const MascotCornerState(WumbiMood.nervous, line: MascotLine(MascotPhrase.walletNegative), auto: true);
    }
    final net = monthNet;
    if (net != null) {
      final start = balance.minor - net;
      if (net < 0 && start > 0 && -net * 10 >= start * 3) {
        return MascotCornerState(
          WumbiMood.sigh,
          line: MascotLine(MascotPhrase.walletDown, count: (-net * 100 / start).round()),
        );
      }
      if (net > 0 && start > 0) {
        return MascotCornerState(
          WumbiMood.reserveFull,
          line: MascotLine(MascotPhrase.walletUp, amount: Money(net, balance.currency)),
          auto: true,
        );
      }
    }
    final last = lastActivityAt;
    if (last != null && MascotSignals.calendarDays(last, now) >= 30) {
      return const MascotCornerState(WumbiMood.sleep, line: MascotLine(MascotPhrase.walletSleeping));
    }
    return const MascotCornerState(WumbiMood.idle, line: MascotLine(MascotPhrase.walletCalm));
  }

  // ------------------------------------------------------------- budgets

  /// Running budgets only.
  static MascotCornerState budgets(List<BudgetProgress> running) {
    final over = running.where((p) => p.status == BudgetStatus.over).toList();
    if (over.isNotEmpty) {
      return MascotCornerState(
        WumbiMood.stop,
        line: MascotLine(MascotPhrase.budgetsOver, count: over.length),
        auto: true,
      );
    }
    final near = running.where(isNearLimit).toList()..sort((a, b) => b.spentRatio.compareTo(a.spentRatio));
    if (near.isNotEmpty) {
      return MascotCornerState(
        WumbiMood.nervous,
        line: MascotLine(MascotPhrase.budgetsNear, name: near.first.budget.name),
        auto: true,
      );
    }
    return const MascotCornerState(WumbiMood.calm, line: MascotLine(MascotPhrase.budgetsCalm));
  }

  /// ≥ 80 % spent while < 80 % of the period has passed (spec §3.1), or the
  /// app's own "at risk" (≥ 90 % spent or committed).
  static bool isNearLimit(BudgetProgress p) =>
      p.status == BudgetStatus.atRisk ||
      (p.status == BudgetStatus.ok && p.spentRatio >= 0.8 && p.timeRatio < 0.8);

  /// Viewed period of one budget.
  static MascotCornerState budgetDetails(BudgetProgress p, {required DateTime now}) {
    if (p.status == BudgetStatus.notStarted) return MascotCornerState.idle;
    if (p.remaining.isNegative) {
      return MascotCornerState(
        WumbiMood.stop,
        line: MascotLine(MascotPhrase.budgetDetailOver, amount: p.remaining.abs()),
        auto: p.isCurrent,
      );
    }
    if (!p.isCurrent) {
      if (p.spent.isZero) return MascotCornerState.idle;
      return const MascotCornerState(WumbiMood.proud, line: MascotLine(MascotPhrase.budgetDetailWithin), auto: true);
    }
    final runsOut = limitRunsOutOn(p, now: now);
    if (runsOut != null) {
      return MascotCornerState(
        WumbiMood.nervous,
        line: MascotLine(MascotPhrase.budgetDetailPace, date: runsOut),
        auto: true,
      );
    }
    return const MascotCornerState(WumbiMood.calm, line: MascotLine(MascotPhrase.budgetDetailCalm));
  }

  /// The day the limit is reached at the current daily pace, when that is
  /// before the period ends (needs ≥ 3 days of data).
  static DateTime? limitRunsOutOn(BudgetProgress p, {required DateTime now}) {
    final start = p.period.start;
    final today = DateTime(now.year, now.month, now.day);
    final elapsed = MascotSignals.calendarDays(start, today) + 1;
    if (elapsed < 3 || p.spent.minor <= 0 || p.limit.minor <= 0) return null;
    final perDay = p.spent.minor / elapsed;
    final daysToLimit = (p.limit.minor / perDay).ceil();
    final day = DateTime(start.year, start.month, start.day + daysToLimit - 1);
    final lastDay = DateTime(p.period.end.year, p.period.end.month, p.period.end.day - 1);
    if (day.isAfter(lastDay) || day.isBefore(today)) return null;
    return day;
  }

  // --------------------------------------------------------------- debts

  static MascotCornerState debts(DebtsOverview o, {required DateTime now}) {
    final open = [...o.openLent, ...o.openBorrowed];
    if (o.overdueCount > 0) {
      return MascotCornerState(
        WumbiMood.alert,
        line: MascotLine(MascotPhrase.debtsOverdue, count: o.overdueCount),
        auto: true,
      );
    }
    final soon = <(DebtSummary, int)>[
      for (final d in open)
        if (daysUntilDue(d, now) case final days? when days <= 3) (d, days),
    ]..sort((a, b) => a.$2.compareTo(b.$2));
    if (soon.isNotEmpty) {
      final (d, days) = soon.first;
      return MascotCornerState(WumbiMood.calendar, line: debtDueLine(d.person.name, days), auto: true);
    }
    if (open.isEmpty && (o.settledLent.isNotEmpty || o.settledBorrowed.isNotEmpty)) {
      return const MascotCornerState(WumbiMood.dusting, line: MascotLine(MascotPhrase.debtsAllClosed), auto: true);
    }
    return const MascotCornerState(WumbiMood.idle, line: MascotLine(MascotPhrase.debtsTracking));
  }

  static MascotCornerState debtDetails(DebtSummary s, {required DateTime now}) {
    final debt = s.debt;
    if (!s.isOpen) {
      return debt.closeReason == DebtCloseReason.forgiven
          ? const MascotCornerState(WumbiMood.love, line: MascotLine(MascotPhrase.reactionForgiven))
          : const MascotCornerState(WumbiMood.dusting, line: MascotLine(MascotPhrase.reactionDebtClosed));
    }
    if (s.overdue) {
      final days = math.max(1, -(daysUntilDue(s, now) ?? -1));
      return MascotCornerState(
        WumbiMood.alert,
        line: MascotLine(MascotPhrase.debtDetailOverdue, count: days),
        auto: true,
      );
    }
    if (debt.direction == DebtDirection.borrowed && debt.dueDate != null) {
      return MascotCornerState(WumbiMood.calendar, line: MascotLine(MascotPhrase.debtDetailDue, date: debt.dueDate));
    }
    if (debt.direction == DebtDirection.lent) {
      return const MascotCornerState(WumbiMood.handing, line: MascotLine(MascotPhrase.debtDetailLent));
    }
    return MascotCornerState.idle;
  }

  /// Calendar days until the due date (negative once past); null without one.
  static int? daysUntilDue(DebtSummary s, DateTime now) {
    final due = s.debt.dueDate;
    if (due == null) return null;
    return MascotSignals.calendarDays(now, due);
  }

  static MascotLine debtDueLine(String name, int days) => switch (days) {
        <= 0 => MascotLine(MascotPhrase.debtDueToday, name: name),
        1 => MascotLine(MascotPhrase.debtDueTomorrow, name: name),
        _ => MascotLine(MascotPhrase.debtDueSoon, name: name, count: days),
      };

  // -------------------------------------------------------- subscriptions

  /// Active expense rule charging within 3 days, soonest first.
  static (RecurringRuleModel, int)? nextCharge(Iterable<RecurringRuleModel> rules, DateTime now) {
    (RecurringRuleModel, int)? best;
    for (final r in rules) {
      if (!r.isActive || r.deletedAt != null || r.type != TransactionType.expense) continue;
      final days = MascotSignals.calendarDays(now, r.nextOccurrence);
      if (days < 0 || days > 3) continue;
      if (best == null || days < best.$2) best = (r, days);
    }
    return best;
  }

  static MascotLine chargeLine(RecurringRuleModel r, int days) => MascotLine(
        switch (days) {
          0 => MascotPhrase.chargeToday,
          1 => MascotPhrase.chargeTomorrow,
          _ => MascotPhrase.chargeSoon,
        },
        name: r.description.trim(),
        amount: Money(r.amountMinor ?? 0, r.currency),
      );

  static MascotCornerState subscriptions(List<RecurringRuleModel> rules, {required DateTime now}) {
    final charge = nextCharge(rules, now);
    if (charge != null) {
      return MascotCornerState(WumbiMood.calendar, line: chargeLine(charge.$1, charge.$2), auto: true);
    }
    final active = rules.where((r) => r.isActive && r.deletedAt == null).length;
    if (active == 0) return MascotCornerState.idle;
    return MascotCornerState(WumbiMood.calendar, line: MascotLine(MascotPhrase.subsSpinning, count: active));
  }

  // ---------------------------------------------------------------- tags

  /// From the current month's report (untagged count, top family).
  static MascotCornerState tags(ProgressReport? month) {
    if (month == null) return const MascotCornerState(WumbiMood.sorting);
    final untagged = month.spending.untaggedCount;
    if (untagged >= 5) {
      return MascotCornerState(
        WumbiMood.sorting,
        line: MascotLine(MascotPhrase.insightUntagged, count: untagged),
        auto: true,
      );
    }
    final roots = [...month.spending.roots]..sort((a, b) => b.amount.minor.compareTo(a.amount.minor));
    if (roots.isEmpty || !roots.first.amount.isPositive) return const MascotCornerState(WumbiMood.sorting);
    return MascotCornerState(WumbiMood.sorting, line: MascotLine(MascotPhrase.tagsTop, name: roots.first.displayName));
  }

  /// This month vs last month to date, for one tag (nested ones included).
  static MascotCornerState tagDetails(ProgressReport? month, String tagId) {
    final node = month == null ? null : findTag(month.spending.roots, tagId);
    final base = node?.baseline;
    if (node == null || base == null || !base.isPositive) return MascotCornerState.idle;
    final percent = ((node.amount.minor - base.minor) * 100 / base.minor).round();
    if (percent >= 20) {
      return MascotCornerState(WumbiMood.thinking, line: MascotLine(MascotPhrase.tagUp, count: percent));
    }
    if (percent <= -20) {
      return MascotCornerState(WumbiMood.thumbsUp, line: MascotLine(MascotPhrase.tagDown, count: -percent));
    }
    return MascotCornerState.idle;
  }

  static ProgressTagNode? findTag(List<ProgressTagNode> nodes, String tagId) {
    for (final n in nodes) {
      if (n.tagId == tagId) return n;
      final inner = findTag(n.children, tagId);
      if (inner != null) return inner;
    }
    return null;
  }

  // ------------------------------------------------------------ progress

  /// One-sentence verdict of the viewed period (spec §4.14). [weekdayName]
  /// names a weekday index (0 = Monday).
  static MascotMessage progressVerdict(ProgressReport r, {required String Function(int) weekdayName}) {
    MascotMessage msg(WumbiMood mood, MascotLine line) =>
        MascotMessage(id: 'progress', tier: MascotTier.summary, mood: mood, line: line);
    final net = r.current.net;
    final month = r.granularity == ProgressGranularity.month;

    if (!r.isCurrent) {
      if (month && net.isPositive && isBestOfHalfYear(r)) {
        return msg(WumbiMood.proud, MascotLine(MascotPhrase.eventBestMonth, amount: net));
      }
      if (net.isNegative) return msg(WumbiMood.sigh, overspentLine(r));
      if (net.isPositive) return msg(WumbiMood.happy, MascotLine(MascotPhrase.progressSaved, amount: net));
      return msg(WumbiMood.calm, const MascotLine(MascotPhrase.allCalm));
    }

    final peak = month && r.elapsedSlots >= 14 ? strongPeakWeekday(r.habits) : null;
    if (peak != null) {
      return msg(WumbiMood.thinking, MascotLine(MascotPhrase.insightPeakDay, name: weekdayName(peak)));
    }
    final forecast = r.forecast;
    if (forecast != null) {
      return msg(WumbiMood.counting, MascotLine(MascotPhrase.progressForecast, amount: forecast));
    }
    if (net.isNegative) return msg(WumbiMood.sigh, overspentLine(r));
    if (net.isPositive) return msg(WumbiMood.happy, MascotLine(MascotPhrase.progressSaved, amount: net));
    return msg(WumbiMood.counting, const MascotLine(MascotPhrase.progressCounting));
  }

  static MascotLine overspentLine(ProgressReport r) {
    final amount = r.current.net.abs();
    final movers = r.movers(limit: 1);
    final top = movers.isEmpty || !(movers.first.delta?.isPositive ?? false) ? null : movers.first;
    return top == null
        ? MascotLine(MascotPhrase.progressOver, amount: amount)
        : MascotLine(MascotPhrase.progressOverTag, amount: amount, name: top.displayName);
  }

  /// The viewed (past) month saved more than each of the 5 before it, with
  /// at least 3 of them holding data.
  static bool isBestOfHalfYear(ProgressReport r) {
    final viewed = r.viewed;
    final g = r.granularity;
    final before = r.history.where((p) {
      final back = g.between(p.start, viewed);
      return back >= 1 && back <= 5 && !p.isEmpty;
    }).toList();
    if (before.length < 3) return false;
    return before.every((p) => p.net.minor < r.current.net.minor);
  }

  /// Weekday (0 = Monday) whose average spend is at least twice the mean of
  /// the other days. Callers ask only after ≥ 14 days of data.
  static int? strongPeakWeekday(ProgressHabits h) {
    final peak = h.peakWeekday;
    final avgs = h.weekdayAverages;
    if (peak == null || avgs.length != 7) return null;
    final others = [for (var i = 0; i < 7; i++) if (i != peak) avgs[i]];
    final mean = others.fold<int>(0, (a, b) => a + b) / others.length;
    if (mean <= 0) return null;
    return avgs[peak] >= mean * 2 ? peak : null;
  }
}
