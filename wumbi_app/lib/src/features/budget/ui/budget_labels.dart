import 'package:flutter/material.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/utils/enums/budget_period_type.dart';
import '../../../core/utils/enums/rollover_mode.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../data/budget_metrics.dart';
import '../data/budget_period.dart';
import '../data/models/budget_model.dart';
import 'budgets_provider.dart';

/// Every user-visible budget string and colour is derived here, once, so the
/// Dashboard, Wallet Details, Budgets and details pages never disagree.
abstract class BudgetLabels {
  /// Bar / accent colour per status (spec B&D §5.5).
  static Color statusColor(BudgetStatus s, UIColorToken colors) => switch (s) {
        BudgetStatus.ok => UIColorToken.blue,
        BudgetStatus.atRisk => UIColorToken.buttercup,
        BudgetStatus.over => UIColorToken.neg500,
        BudgetStatus.notStarted || BudgetStatus.finished => colors.secondContentColor,
      };

  /// Trailing label colour: only at-risk / over stand out.
  static Color? trailingColor(BudgetStatus s) => switch (s) {
        BudgetStatus.atRisk => UIColorToken.buttercup,
        BudgetStatus.over => UIColorToken.neg500,
        _ => null,
      };

  /// "€230 left" / "€12 over" / "Starts Nov 1" / "Ended".
  static String trailing(AppLocale l10n, BudgetProgress p) => switch (p.status) {
        BudgetStatus.notStarted => l10n.budget_starts(p.period.start.formatShortDate()),
        BudgetStatus.finished => l10n.budget_ended,
        _ => p.remaining.isNegative
            ? l10n.budget_over(p.remaining.abs().format())
            : l10n.budget_left(p.remaining.format()),
      };

  /// `October`, `This week`, `2026`, `Oct 1 – 15`.
  static String period(AppLocale l10n, BudgetModel b, BudgetPeriod p, {required bool isCurrent}) {
    final start = p.start;
    switch (b.period) {
      case BudgetPeriodType.monthly when start.day == 1:
        return start.formatMonthYear();
      case BudgetPeriodType.yearly when start.month == 1 && start.day == 1:
        return '${start.year}';
      case BudgetPeriodType.weekly when isCurrent:
        return l10n.budget_this_week;
      default:
        return range(p);
    }
  }

  /// `Oct 25 – Nov 24` (inclusive last day).
  static String range(BudgetPeriod p) {
    final last = DateTime(p.end.year, p.end.month, p.end.day - 1);
    if (last.year == p.start.year && last.month == p.start.month) {
      return '${p.start.formatShortDate()} – ${last.day}';
    }
    return '${p.start.formatShortDate()} – ${last.formatShortDate()}';
  }

  /// Row caption: period · per day · ≈ (incomplete conversion). With
  /// [spentOf] (Wallet Details) it starts with "Spent X of Y" so the number
  /// is never mistaken for the wallet balance.
  static String caption(AppLocale l10n, BudgetProgress p, {bool spentOf = false}) {
    final perDay = p.perDay;
    return [
      if (spentOf) l10n.budget_spent_of(p.spent.format(), p.limit.format()),
      period(l10n, p.budget, p.period, isCurrent: p.isCurrent),
      if (perDay != null) l10n.budget_per_day(perDay.format()),
      if (p.incomplete) '≈',
    ].join(' · ');
  }

  static String periodType(AppLocale l10n, BudgetPeriodType t) => switch (t) {
        BudgetPeriodType.weekly => l10n.budget_period_weekly,
        BudgetPeriodType.monthly => l10n.budget_period_monthly,
        BudgetPeriodType.yearly => l10n.budget_period_yearly,
        BudgetPeriodType.custom => l10n.budget_period_custom,
      };

  static String rollover(AppLocale l10n, RolloverMode m) => switch (m) {
        RolloverMode.none => l10n.budget_rollover_none,
        RolloverMode.surplus => l10n.budget_rollover_surplus,
        RolloverMode.both => l10n.budget_rollover_both,
      };

  /// One-sentence explanation under each option of the Carry over sheet.
  static String rolloverDescription(AppLocale l10n, RolloverMode m) => switch (m) {
        RolloverMode.none => l10n.budget_rollover_none_desc,
        RolloverMode.surplus => l10n.budget_rollover_surplus_desc,
        RolloverMode.both => l10n.budget_rollover_both_desc,
      };

  /// Chip / sheet label for whether planned payments count against the limit.
  static String countPlanned(AppLocale l10n, bool include) =>
      include ? l10n.budget_count_planned : l10n.budget_planned_exclude;

  /// One-sentence explanation under each option of the Planned payments sheet.
  static String countPlannedDescription(AppLocale l10n, bool include) =>
      include ? l10n.budget_count_planned_desc : l10n.budget_planned_exclude_desc;

  /// One sentence on how the running budgets in [budgets] are doing, and its
  /// colour: over (red) beats close to the limit (orange) beats within
  /// (default). Null when none is running.
  static (String, Color?)? summary(AppLocale l10n, Iterable<BudgetProgress> budgets) {
    final running = budgets.where(isRunningBudget).toList();
    if (running.isEmpty) return null;
    final over = running.where((p) => p.status == BudgetStatus.over).length;
    if (over > 0) return (l10n.budgets_summary_over(over), UIColorToken.neg500);
    final close = running.where((p) => p.status == BudgetStatus.atRisk).length;
    if (close > 0) return (l10n.budgets_summary_close(close), UIColorToken.buttercup);
    return (l10n.budgets_summary_ok(running.length), null);
  }

  /// What a budget counts, in words: "Counts expenses from Card, Cash tagged
  /// #food or #coffee." [tagNames] without the `#`.
  static String scopeSentence(AppLocale l10n, {required List<String> walletNames, required List<String> tagNames}) {
    final wallets = walletNames.join(', ');
    final tags = tagNames.map((t) => '#$t').toList();
    final tagText = tags.length <= 1
        ? tags.join()
        : '${tags.sublist(0, tags.length - 1).join(', ')} ${l10n.budget_scope_or} ${tags.last}';
    if (walletNames.isEmpty && tags.isEmpty) return l10n.budget_scope_all;
    if (tags.isEmpty) return l10n.budget_scope_wallets(wallets);
    if (walletNames.isEmpty) return l10n.budget_scope_tags(tagText);
    return l10n.budget_scope_both(wallets, tagText);
  }
}
