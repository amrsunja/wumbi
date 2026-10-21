import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/money/money.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../../core/utils/typedefs.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../tag/ui/widgets/tag_visuals.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../data/models/progress_stats.dart';
import 'progress_labels.dart';
import 'progress_notifier.dart';
import 'widgets/progress_baseline_sheet.dart';
import 'widgets/progress_calendar.dart';
import 'widgets/progress_column_chart.dart';
import 'widgets/progress_donut.dart';
import 'widgets/progress_history_chart.dart';
import 'widgets/progress_pace_chart.dart';
import 'widgets/progress_scope_sheet.dart';

/// `/progress` — one period at a time against a baseline the user picks.
///
/// Reads top → bottom, each fact shown once, every block its own card:
/// 1. header — scope · Month | Year · period navigator (as Budget Details)
///    with the "vs …" picker;
/// 2. result — saved / overspent, then income and spent as two bars with
///    their change against the baseline (the only place deltas of totals
///    appear);
/// 3. pace — cumulative curve vs the baseline + forecast;
/// 4. day by day (month by month) — spending calendar, tap a day / month;
/// 5. by tag — donut + rows (amount, share, count);
/// 6. what changed — biggest moves, was → now bars;
/// 7. habits — figures, then the weekday chart;
/// 8. history — 12 months / 5 years, tap a bar to open that period.
///
/// Colours: expense = black / white, income = blue, red only for "worse".
@RoutePage()
class ProgressPage extends HookConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final state = ref.watch(progressProvider);
    final notifier = ref.read(progressProvider.notifier);
    final wallets = ref.watch(walletsProvider).value ?? const <WalletSummary>[];
    final base = ref.watch(baseCurrencyProvider);

    WalletSummary? selected;
    for (final wallet in wallets) {
      if (wallet.id == state.walletId) selected = wallet;
    }

    final g = state.granularity;
    final viewed = state.viewed();
    final baselineName = ProgressLabels.baseline(l10n, g, state.baseline, state.baseline.periodsFor(g, viewed));

    Future<void> pickScope() async {
      final scope = await ProgressScopeSheet.show(context, wallets: wallets, selectedId: state.walletId);
      if (scope == null) return;
      notifier.setWallet(scope.walletId);
    }

    Future<void> pickBaseline() async {
      final picked = await ProgressBaselineSheet.show(
        context,
        granularity: g,
        viewed: viewed,
        selected: state.baseline,
      );
      if (picked != null) notifier.setBaseline(picked);
    }

    void browse(int delta) {
      AppVibrations.selection();
      notifier.browse(delta);
    }

    return Scaffold(
      appBar: UIAppbar(title: l10n.progress_title, backTap: () => context.router.maybePop()),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(kListHorzPadding, 4, kListHorzPadding, 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Report currency (follows the scope) | wallet scope.
            Center(
              child: UiWalletInfoMenu(
                name: selected?.name ?? l10n.progress_all_wallets,
                color: selected?.color.color ?? colors.secondContentColor,
                currencyType: selected?.currency ?? base,
                onSelectWallet: wallets.isEmpty ? null : pickScope,
              ),
            ),
            const UISpace.vert(12),
            UiSegmentedToggle(
              expanded: true,
              labels: [l10n.progress_month, l10n.progress_year],
              selectedIndex: g.index,
              onChanged: (i) {
                AppVibrations.selection();
                notifier.setGranularity(ProgressGranularity.values[i]);
              },
            ),
            const UISpace.vert(16),
            UiPeriodNavigator(
              label: ProgressLabels.period(g, viewed),
              position: state.offset,
              caption: l10n.progress_vs(baselineName),
              onCaptionTap: pickBaseline,
              onPrevious: () => browse(-1),
              onNext: state.offset < 0 ? () => browse(1) : null,
              backLabel: state.offset == 0 ? null : l10n.budget_back_to_current,
              onBackToCurrent: () => browse(-state.offset),
            ),
            const UISpace.vert(16),
            // Previous numbers stay on screen (dimmed) while the next load.
            AnimatedOpacity(
              duration: UIAnim.fast,
              opacity: state.loading && state.report != null ? 0.45 : 1,
              child: _Body(state: state, baselineName: baselineName, onOpenPeriod: notifier.goTo),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------- body

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.baselineName, required this.onOpenPeriod});

  final ProgressState state;
  final String baselineName;
  final ValueChanged<DateTime> onOpenPeriod;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = state.report;

    if (r == null) {
      if (state.error != null) {
        return Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text(l10n.error_unknown, textAlign: TextAlign.center, style: context.typo.inter.caption),
        );
      }
      return const UiSkeletonList(rows: 5);
    }

    if (r.isLedgerEmpty) {
      return UiEmptyState(
        image: AppAssets.images.wumbiOo.path,
        title: l10n.progress_empty_title,
        subtitle: l10n.progress_empty_subtitle,
      );
    }

    final spent = r.current.expense.isPositive;
    final movers = r.movers();
    final month = r.granularity == ProgressGranularity.month;
    var i = 0;
    Duration delay() => Duration(milliseconds: 60 * i++);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Result(report: r, baselineName: baselineName).uiFadeSlideIn(delay: delay(), offset: 0.1),
        if (!r.current.isEmpty) ...[
          if (spent) ...[
            _Section(
              label: l10n.progress_pace_title,
              child: _Card(child: _Pace(report: r, baselineName: baselineName)),
            ).uiFadeSlideIn(delay: delay(), offset: 0.1),
            _Section(
              label: month ? l10n.progress_by_day : l10n.progress_by_month,
              child: _Card(child: ProgressCalendar(report: r)),
            ).uiFadeSlideIn(delay: delay(), offset: 0.1),
          ],
          _Breakdown(report: r).uiFadeSlideIn(delay: delay(), offset: 0.1),
          if (movers.isNotEmpty)
            _Section(
              label: l10n.progress_changes_title,
              child: _Movers(movers: movers),
            ).uiFadeSlideIn(delay: delay(), offset: 0.1),
          if (spent)
            _Section(
              label: l10n.progress_habits_title,
              child: _Habits(report: r),
            ).uiFadeSlideIn(delay: delay(), offset: 0.1),
        ],
        _History(report: r, onOpenPeriod: onOpenPeriod).uiFadeSlideIn(delay: delay(), offset: 0.1),
        if (r.unconvertible.isNotEmpty) ...[
          const UISpace.vert(20),
          Text(
            l10n.progress_not_included(r.unconvertible.map((c) => c.code).join(', ')),
            textAlign: TextAlign.center,
            style: context.typo.inter.caption,
          ),
        ],
      ],
    );
  }
}

/// Uppercase label (+ optional control on the right) over its card.
class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child, this.trailing});

  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 32),
            child: Row(
              children: [
                Expanded(child: UiSectionLabel(text: label, padding: const EdgeInsets.symmetric(horizontal: 4))),
                ?trailing,
              ],
            ),
          ),
          const UISpace.vert(8),
          child,
        ],
      ),
    );
  }
}

/// Tinted rounded surface — the [UiGroupCard] look for charts and mixed
/// content. Row lists use [UiGroupCard] itself.
class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.colors.secondContentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

// ------------------------------------------------------------------ result

/// ```
///            OVERSPENT
///            $1,976.92
///
/// Income  ↘ 92%              $623.60
/// ▬▬▬▬░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
/// Spent   ↘ 3%             $2,600.52
/// ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
///  Compared with the same days of September
/// ```
/// The net in words only when it adds something (share kept).
class _Result extends StatelessWidget {
  const _Result({required this.report, required this.baselineName});

  final ProgressReport report;
  final String baselineName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    final r = report;
    final c = r.current;
    final net = c.net;
    final over = net.isNegative;
    final scale = c.income.minor > c.expense.minor ? c.income.minor : c.expense.minor;

    final String? sentence = c.isEmpty
        ? l10n.progress_nothing_in(ProgressLabels.period(r.granularity, r.viewed))
        : (!over && c.savingsRate != null ? l10n.progress_kept_share((c.savingsRate! * 100).round()) : null);

    return _Card(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            (over ? l10n.progress_overspent : l10n.progress_saved).toUpperCase(),
            textAlign: TextAlign.center,
            style: typo.sectionLabel,
          ),
          const UISpace.vert(4),
          UiTotalAmount(
            money: net.abs(),
            animated: true,
            fontSize: 40,
            color: c.isEmpty ? colors.secondContentColor : (over ? UIColorToken.neg500 : UIColorToken.blue),
          ),
          if (sentence != null) ...[
            const UISpace.vert(2),
            Text(sentence, textAlign: TextAlign.center, style: typo.caption),
          ],
          const UISpace.vert(20),
          _FlowRow(
            label: l10n.progress_income,
            money: c.income,
            ratio: scale == 0 ? 0 : c.income.minor / scale,
            delta: r.incomeDelta,
            risingIsGood: true,
            color: UIColorToken.blue,
          ),
          const UISpace.vert(14),
          _FlowRow(
            label: l10n.progress_spent,
            money: c.expense,
            ratio: scale == 0 ? 0 : c.expense.minor / scale,
            delta: r.expenseDelta,
            risingIsGood: false,
            color: colors.expenseColor,
          ),
          // The header already says "vs …"; only the same-days cut needs words.
          if (r.comparison != null && r.comparisonIsToDate) ...[
            const UISpace.vert(14),
            Text(
              l10n.progress_to_date_hint(baselineName),
              textAlign: TextAlign.center,
              style: typo.caption,
            ),
          ],
        ],
      ),
    );
  }
}

/// `Income  ↘ 92%            $623.60` over a bar scaled to the bigger side.
class _FlowRow extends StatelessWidget {
  const _FlowRow({
    required this.label,
    required this.money,
    required this.ratio,
    required this.delta,
    required this.risingIsGood,
    required this.color,
  });

  final String label;
  final Money money;
  final double ratio;
  final double? delta;
  final bool risingIsGood;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label, style: typo.body),
            const UISpace.horz(8),
            _DeltaChip(ratio: delta, risingIsGood: risingIsGood),
            const Spacer(),
            Text(
              money.format(),
              style: typo.rowTitle.copyWith(
                fontSize: 17,
                color: money.isZero ? context.colors.secondContentColor : color,
              ),
            ),
          ],
        ),
        const UISpace.vert(6),
        UiBudgetBar(spentRatio: ratio, color: color, height: 8),
      ],
    );
  }
}

/// `↗ 12%` — blue when the move is the good direction, red when not;
/// nothing without a comparison.
class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.ratio, required this.risingIsGood});

  final double? ratio;
  final bool risingIsGood;

  @override
  Widget build(BuildContext context) {
    final r = ratio;
    if (r == null || (r * 100).round() == 0) return const SizedBox.shrink();
    final rising = r > 0;
    final color = rising == risingIsGood ? UIColorToken.blue : UIColorToken.neg500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 3,
        children: [
          UIIcon(
            rising ? UIIconToken.icons.charts.trendUp01 : UIIconToken.icons.charts.trendDown01,
            size: 12,
            color: color,
          ),
          Text(ProgressLabels.percent(r), style: context.typo.inter.captionBold.copyWith(color: color)),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------- pace

/// The cumulative curve against the baseline (its legend inside) and, while
/// the period runs, where it is heading.
class _Pace extends StatelessWidget {
  const _Pace({required this.report, required this.baselineName});

  final ProgressReport report;
  final String baselineName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = report;
    final forecast = r.forecast;
    // A forecast equal to what is already spent says nothing.
    final showForecast = forecast != null && r.paceCurrent.isNotEmpty && forecast.minor != r.paceCurrent.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProgressPaceChart(report: r, baselineLabel: baselineName),
        if (showForecast) ...[
          const UISpace.vert(14),
          const UIDivider(),
          const UISpace.vert(12),
          Row(
            spacing: 8,
            children: [
              UIIcon(UIIconToken.icons.time.clockFastForward, size: 16, color: context.colors.secondContentColor),
              Expanded(
                child: Text(
                  r.granularity == ProgressGranularity.month
                      ? l10n.progress_forecast_month(forecast.format())
                      : l10n.progress_forecast_year(forecast.format()),
                  style: context.typo.inter.caption,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// --------------------------------------------------------------- breakdown

/// Spending | Income by tag family: donut (top 5 + Other + Untagged) and the
/// rows under it with the matching colour dot. A family includes every
/// nested tag (counted once); the chevron reveals children, a tap opens the
/// tag. Changes against the baseline live in "What changed", not here.
class _Breakdown extends HookWidget {
  const _Breakdown({required this.report});

  final ProgressReport report;

  static const int _collapsedRoots = 6;
  static const int _slices = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    final r = report;
    final income = useState(false);
    final expanded = useState<Set<String>>(const {});
    final showAll = useState(false);

    final b = income.value ? r.earning : r.spending;
    final total = income.value ? r.current.income : r.current.expense;
    final base = income.value ? UIColorToken.blue : colors.expenseColor;
    final shades = ProgressDonut.shades(base);
    final otherColor = ProgressDonut.otherColor(base);
    final untaggedColor = ProgressDonut.untaggedColor(colors);

    double share(Money m) => total.isPositive ? (m.minor / total.minor).clamp(0.0, 1.0) : 0;
    Color rootColor(int i) => i < _slices ? shades[i] : otherColor;

    // Donut: top families, the rest as "Other", then untagged.
    final slices = <ProgressSlice>[
      for (var i = 0; i < b.roots.length && i < _slices; i++)
        ProgressSlice(
          label: '#${b.roots[i].displayName}',
          minor: b.roots[i].amount.minor,
          share: share(b.roots[i].amount),
          color: shades[i],
        ),
      if (b.roots.length > _slices)
        () {
          final rest = b.roots.skip(_slices).fold<int>(0, (s, n) => s + n.amount.minor);
          return ProgressSlice(
            label: l10n.progress_other,
            minor: rest,
            share: share(Money(rest, total.currency)),
            color: otherColor,
          );
        }(),
      if (b.untagged.isPositive)
        ProgressSlice(
          label: l10n.progress_untagged,
          minor: b.untagged.minor,
          share: share(b.untagged),
          color: untaggedColor,
        ),
    ];

    void toggle(String id) {
      final next = Set<String>.of(expanded.value);
      if (!next.remove(id)) next.add(id);
      expanded.value = next;
    }

    final rows = <Widget>[];
    void add(ProgressTagNode n, int depth, Color? dot) {
      final open = expanded.value.contains(n.tagId);
      rows.add(
        _TagRow(
          key: ValueKey('progress-tag-${n.tagId}'),
          label: TagPathText(
            path: n.displayName,
            showParents: false,
            style: depth == 0 ? typo.listTitle : typo.labelMedium,
          ),
          amount: n.amount,
          count: n.count,
          share: share(n.amount),
          dot: dot,
          depth: depth,
          expanded: n.children.isEmpty ? null : open,
          onToggle: n.children.isEmpty ? null : () => toggle(n.tagId),
          onTap: () => context.router.push(TagDetailsRoute(tagId: n.tagId)),
        ),
      );
      if (open) {
        for (final child in n.children) {
          add(child, depth + 1, null);
        }
      }
    }

    final roots = showAll.value ? b.roots : b.roots.take(_collapsedRoots).toList();
    for (var i = 0; i < roots.length; i++) {
      add(roots[i], 0, rootColor(i));
    }
    if (b.untagged.isPositive) {
      rows.add(
        _TagRow(
          key: const ValueKey('progress-tag-untagged'),
          label: Text(l10n.progress_untagged, style: typo.listTitle.copyWith(color: colors.secondContentColor)),
          amount: b.untagged,
          count: b.untaggedCount,
          share: share(b.untagged),
          dot: untaggedColor,
          depth: 0,
        ),
      );
    }

    // Families overlap when a row carries tags from two of them (0.5 %
    // slack: FX rounding differs between per-row and per-tag conversion).
    final listed = b.roots.fold<int>(0, (s, n) => s + n.amount.minor) + b.untagged.minor;
    final overlaps = listed > total.minor * 1.005;

    return _Section(
      label: l10n.progress_breakdown_title,
      trailing: UiSegmentedToggle(
        labels: [l10n.progress_spending, l10n.progress_income],
        selectedIndex: income.value ? 1 : 0,
        onChanged: (i) {
          AppVibrations.selection();
          income.value = i == 1;
          showAll.value = false;
        },
      ),
      child: AnimatedSize(
        duration: UIAnim.fast,
        curve: UIAnim.easeOut,
        alignment: Alignment.topCenter,
        child: b.isEmpty
            ? _Card(
                child: Text(
                  income.value ? l10n.progress_no_income : l10n.progress_no_expenses,
                  textAlign: TextAlign.center,
                  style: typo.hint,
                ),
              )
            : _Card(
                padding: const EdgeInsets.fromLTRB(14, 20, 14, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProgressDonut(key: ValueKey(income.value), slices: slices),
                    const UISpace.vert(12),
                    for (var i = 0; i < rows.length; i++) ...[
                      if (i > 0) const UIDivider(),
                      rows[i],
                    ],
                    if (b.roots.length > _collapsedRoots) ...[
                      const UIDivider(),
                      UITap(
                        onTap: () => showAll.value = !showAll.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            showAll.value ? l10n.progress_show_less : l10n.progress_show_all(b.roots.length),
                            textAlign: TextAlign.center,
                            style: typo.captionBold.copyWith(color: UIColorToken.blue),
                          ),
                        ),
                      ),
                    ],
                    if (overlaps)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 12),
                        child: Text(l10n.progress_overlap_hint, style: typo.caption),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// `● #food ···················· €420  ⌄`
/// `  32% · 14 transactions`
class _TagRow extends StatelessWidget {
  const _TagRow({
    super.key,
    required this.label,
    required this.amount,
    required this.count,
    required this.share,
    required this.depth,
    this.dot,
    this.expanded,
    this.onToggle,
    this.onTap,
  });

  final Widget label;
  final Money amount;
  final int count;
  final double share;
  final int depth;

  /// Donut colour (top-level rows only).
  final Color? dot;

  /// Null = no nested tags (no chevron).
  final bool? expanded;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    final d = dot;
    // Text starts at the same x with or without a dot.
    final indent = depth * 18.0 + 20;

    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: indent,
              child: d == null
                  ? null
                  : Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(width: 10, height: 10, decoration: BoxDecoration(color: d, shape: BoxShape.circle)),
                    ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  label,
                  Text(
                    '${ProgressLabels.percent(share)} · ${l10n.tags_usage(count)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typo.caption,
                  ),
                ],
              ),
            ),
            const UISpace.horz(12),
            Text(amount.format(), style: depth == 0 ? typo.listTitle : typo.label),
            if (expanded != null)
              UITap(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: AnimatedRotation(
                    turns: expanded! ? 0 : -0.25,
                    duration: const Duration(milliseconds: 180),
                    child: UIIcon(UIIconToken.icons.arrows.chevronDown, size: 18, color: colors.secondContentColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ what changed

/// The spending families that moved the most: name, delta, and two thin
/// bars — now (solid) over before (muted) — on one shared scale.
class _Movers extends StatelessWidget {
  const _Movers({required this.movers});

  final List<ProgressTagNode> movers;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    final scale = movers.fold<int>(1, (m, n) {
      final was = n.baseline?.minor ?? 0;
      return [m, n.amount.minor, was].reduce((a, b) => a > b ? a : b);
    });

    return UiGroupCard(
      children: [
        for (final n in movers)
          () {
            final delta = n.delta!;
            final base = n.baseline!;
            final up = delta.isPositive;
            final color = up ? UIColorToken.neg500 : UIColorToken.blue;
            return UITap(
              onTap: () => context.router.push(TagDetailsRoute(tagId: n.tagId)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: TagPathText(path: n.displayName, style: typo.listTitle)),
                        const UISpace.horz(12),
                        Text(delta.format(signed: true, positiveSign: true), style: typo.listTitle.copyWith(color: color)),
                      ],
                    ),
                    const UISpace.vert(2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.progress_now_was(n.amount.format(), base.format()),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typo.caption,
                          ),
                        ),
                        Text(
                          base.isZero ? l10n.progress_new : ProgressLabels.percent(delta.minor / base.minor),
                          style: typo.caption.copyWith(color: base.isZero ? colors.secondContentColor : color),
                        ),
                      ],
                    ),
                    const UISpace.vert(10),
                    UiBudgetBar(spentRatio: n.amount.minor / scale, color: colors.expenseColor, height: 4),
                    const UISpace.vert(4),
                    UiBudgetBar(
                      spentRatio: base.minor / scale,
                      color: colors.secondContentColor.withValues(alpha: 0.5),
                      height: 4,
                    ),
                  ],
                ),
              ),
            );
          }(),
      ],
    );
  }
}

// ------------------------------------------------------------------ habits

/// Figures as a grouped list (Budget Details look), then the weekday chart.
class _Habits extends StatelessWidget {
  const _Habits({required this.report});

  final ProgressReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final r = report;
    final h = r.habits;
    final top = h.topExpense;
    final spent = r.current.expense;
    final peak = h.peakWeekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiGroupCard(
          children: [
            _StatRow(
              icon: UIIconToken.icons.time.calendar,
              label: l10n.progress_daily_average,
              value: h.dailyAverage.format(),
              caption: h.baselineDailyAverage == null ? null : l10n.progress_vs(h.baselineDailyAverage!.format()),
            ),
            if (top != null)
              _StatRow(
                icon: UIIconToken.icons.financeEcommerce.receipt,
                label: l10n.progress_biggest_expense,
                value: top.amount.format(),
                caption: '${top.description.isEmpty ? l10n.common_expense : top.description} · ${top.date.formatShortDate()}',
                onTap: () => context.router.push(TransactionRoute(transactionId: top.id, walletId: top.walletId)),
              ),
            if (h.recurring.isPositive)
              _StatRow(
                icon: UIIconToken.icons.mediaDevices.repeat01,
                label: l10n.progress_recurring,
                value: h.recurring.format(),
                caption: l10n.progress_recurring_share((h.recurring.minor / spent.minor * 100).round()),
                onTap: () => context.router.push(SubscriptionsRoute()),
              ),
            if (h.averageExpense != null)
              _StatRow(
                icon: UIIconToken.icons.financeEcommerce.coinsStacked01,
                label: l10n.progress_average_expense,
                value: h.averageExpense!.format(),
                caption: l10n.tags_usage(r.current.expenseCount),
              ),
          ],
        ),
        if (peak != null) ...[
          const UISpace.vert(12),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.progress_peak_weekday(ProgressLabels.weekday(peak)), style: typo.bodyMedium),
                const UISpace.vert(2),
                Text(l10n.progress_weekday_hint, style: typo.caption),
                const UISpace.vert(12),
                Builder(
                  builder: (context) {
                    // MaterialLocalizations: 0 = Sunday. Ours: 0 = Monday.
                    final first = (MaterialLocalizations.of(context).firstDayOfWeekIndex + 6) % 7;
                    final order = [for (var i = 0; i < 7; i++) (first + i) % 7];
                    return ProgressColumnChart(
                      values: [for (final d in order) h.weekdayAverages[d]],
                      currency: r.currency,
                      label: (i) => ProgressLabels.weekday(order[i], short: true),
                      tooltip: (i) => ProgressLabels.weekday(order[i]),
                      height: 72,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Icon · label (+ caption) · value — read-only unless [onTap] is set.
class _StatRow extends StatelessWidget {
  const _StatRow({required this.icon, required this.label, required this.value, this.caption, this.onTap});

  final String icon;
  final String label;
  final String value;
  final String? caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            UIIcon(icon, size: 18, color: colors.secondContentColor),
            const UISpace.horz(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.body),
                  if (caption != null)
                    Text(caption!, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.caption),
                ],
              ),
            ),
            const UISpace.horz(12),
            Text(value, style: typo.rowTitle),
            if (onTap != null) ...[
              const UISpace.horz(4),
              UIIcon(UIIconToken.icons.arrows.chevronRight, size: 16, color: colors.secondContentColor),
            ],
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- history

class _History extends HookWidget {
  const _History({required this.report, required this.onOpenPeriod});

  final ProgressReport report;
  final ValueChanged<DateTime> onOpenPeriod;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final r = report;
    final series = useState(ProgressHistorySeries.saved);
    final month = r.granularity == ProgressGranularity.month;
    final avg = r.historyAverage();

    final Money? avgValue = avg == null
        ? null
        : switch (series.value) {
            ProgressHistorySeries.saved => avg.net,
            ProgressHistorySeries.income => avg.income,
            ProgressHistorySeries.spent => avg.expense,
          };

    return _Section(
      label: month
          ? l10n.progress_history_months(r.granularity.historyLength)
          : l10n.progress_history_years(r.granularity.historyLength),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiSegmentedToggle(
              expanded: true,
              labels: [l10n.progress_saved, l10n.progress_income, l10n.progress_spent],
              selectedIndex: series.value.index,
              onChanged: (i) {
                AppVibrations.selection();
                series.value = ProgressHistorySeries.values[i];
              },
            ),
            const UISpace.vert(16),
            ProgressHistoryChart(report: r, series: series.value, onSelect: onOpenPeriod),
            if (avgValue != null) ...[
              const UISpace.vert(10),
              Text(
                month
                    ? l10n.progress_average_per_month(avgValue.format(signed: true))
                    : l10n.progress_average_per_year(avgValue.format(signed: true)),
                textAlign: TextAlign.center,
                style: typo.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
