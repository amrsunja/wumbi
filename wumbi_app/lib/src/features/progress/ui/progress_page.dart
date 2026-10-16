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
import 'widgets/progress_history_chart.dart';
import 'widgets/progress_pace_chart.dart';
import 'widgets/progress_scope_sheet.dart';
import 'widgets/progress_weekday_bars.dart';

/// `/progress` — one period at a time, always against a baseline the user
/// picks (previous, same month last year, a 3-period average or any period).
///
/// Flat sections, no cards, same anatomy as the budgets / tags lists:
/// header (scope · Month|Year · ‹ period › · vs baseline) → saved hero with
/// income / spent deltas → spending pace → what changed → by tag → habits →
/// history (tap a bar to open that period).
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
            const UISpace.vert(10),
            UiSegmentedToggle(
              labels: [l10n.progress_month, l10n.progress_year],
              selectedIndex: g.index,
              onChanged: (i) => notifier.setGranularity(ProgressGranularity.values[i]),
            ),
            const UISpace.vert(14),
            _PeriodHeader(
              label: ProgressLabels.period(g, viewed),
              baseline: l10n.progress_vs(baselineName),
              offset: state.offset,
              onPrevious: () => browse(-1),
              onNext: state.offset < 0 ? () => browse(1) : null,
              onBackToCurrent: () => browse(-state.offset),
              onCompare: pickBaseline,
            ),
            const UISpace.vert(28),
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

// ------------------------------------------------------------------ header

/// ```
/// (‹)      October 2026      (›)
///        vs September 2026 ⌄
///           Back to today
/// ```
/// The label slides in the browsing direction (same motion as the budget
/// period navigator); there is no going past the running period.
class _PeriodHeader extends HookWidget {
  const _PeriodHeader({
    required this.label,
    required this.baseline,
    required this.offset,
    required this.onPrevious,
    required this.onNext,
    required this.onBackToCurrent,
    required this.onCompare,
  });

  final String label;
  final String baseline;
  final int offset;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onBackToCurrent;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo.inter;

    final direction = useRef(1);
    final lastOffset = useRef(offset);
    if (offset != lastOffset.value) {
      direction.value = offset > lastOffset.value ? 1 : -1;
      lastOffset.value = offset;
    }

    return Column(
      children: [
        Row(
          children: [
            _NavArrow(icon: UIIconToken.icons.arrows.chevronLeft, onTap: onPrevious),
            Expanded(
              child: AnimatedSwitcher(
                duration: UIAnim.fast,
                switchInCurve: UIAnim.easeOut,
                switchOutCurve: UIAnim.easeOut,
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.center,
                  children: [...previous, ?current],
                ),
                transitionBuilder: (child, animation) {
                  final incoming = child.key == ValueKey(label);
                  final dx = (incoming ? 0.25 : -0.25) * direction.value;
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: Offset(dx, 0), end: Offset.zero).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  label,
                  key: ValueKey(label),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: typo.headline,
                ),
              ),
            ),
            _NavArrow(icon: UIIconToken.icons.arrows.chevronRight, onTap: onNext),
          ],
        ),
        UiSelectButton(title: baseline, style: typo.label, onTap: onCompare),
        AnimatedSize(
          duration: UIAnim.fast,
          curve: UIAnim.easeOut,
          child: offset == 0
              ? const SizedBox(width: double.infinity)
              : UITap(
                  onTap: onBackToCurrent,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(l10n.budget_back_to_current, style: typo.caption),
                  ),
                ),
        ),
      ],
    );
  }
}

/// Bare 40 px chevron; dimmed when there is nowhere to go.
class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: UIAnim.fast,
      opacity: onTap == null ? 0.25 : 1,
      child: UITap(
        onTap: onTap,
        child: SizedBox(width: 40, height: 40, child: Center(child: UIIcon(icon, size: 22))),
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

    final hasData = !r.current.isEmpty;
    final movers = r.movers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Hero(report: r, baselineName: baselineName).uiFadeSlideIn(offset: 0.1),
        if (hasData) ...[
          if (r.current.expense.isPositive)
            _Section(
              label: l10n.progress_pace_title,
              child: _Pace(report: r, baselineName: baselineName),
            ).uiFadeSlideIn(delay: const Duration(milliseconds: 80), offset: 0.1),
          if (movers.isNotEmpty)
            _Section(
              label: l10n.progress_changes_title,
              child: _Movers(movers: movers, granularity: r.granularity),
            ).uiFadeSlideIn(delay: const Duration(milliseconds: 140), offset: 0.1),
          _Breakdown(report: r).uiFadeSlideIn(delay: const Duration(milliseconds: 200), offset: 0.1),
          if (r.current.expense.isPositive)
            _Section(
              label: l10n.progress_habits_title,
              child: _Habits(report: r),
            ).uiFadeSlideIn(delay: const Duration(milliseconds: 260), offset: 0.1),
        ],
        _History(report: r, onOpenPeriod: onOpenPeriod).uiFadeSlideIn(delay: const Duration(milliseconds: 320), offset: 0.1),
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

/// Uppercase label (+ optional control on the right) and its content.
class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child, this.trailing});

  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 32),
            child: Row(
              children: [
                Expanded(child: UiSectionLabel(text: label, padding: EdgeInsets.zero)),
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

// -------------------------------------------------------------------- hero

/// SAVED / OVERSPENT + the net, one sentence that explains it, then
/// income | spent with their move against the baseline.
class _Hero extends StatelessWidget {
  const _Hero({required this.report, required this.baselineName});

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
    final cmp = r.comparison;

    final String sentence;
    if (c.isEmpty) {
      sentence = l10n.progress_nothing_in(ProgressLabels.period(r.granularity, r.viewed));
    } else if (over) {
      sentence = l10n.progress_overspent_by(net.abs().format());
    } else {
      sentence = l10n.progress_kept_share(((c.savingsRate ?? 0) * 100).round());
    }

    return Column(
      children: [
        Text((over ? l10n.progress_overspent : l10n.progress_saved).toUpperCase(), style: typo.sectionLabel),
        const UISpace.vert(4),
        UiTotalAmount(
          money: net.abs(),
          animated: true,
          fontSize: 40,
          color: over ? UIColorToken.neg500 : (c.isEmpty ? colors.secondContentColor : UIColorToken.blue),
        ),
        const UISpace.vert(4),
        Text(sentence, textAlign: TextAlign.center, style: typo.subtitle),
        const UISpace.vert(24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Side(
                label: l10n.progress_income,
                money: c.income,
                delta: r.incomeDelta,
                change: cmp == null ? null : c.income - cmp.income,
                risingIsGood: true,
                color: UIColorToken.blue,
              ),
            ),
            SizedBox(
              height: 64,
              child: VerticalDivider(width: 1, thickness: 1, color: colors.dividerColor),
            ),
            Expanded(
              child: _Side(
                label: l10n.progress_spent,
                money: c.expense,
                delta: r.expenseDelta,
                change: cmp == null ? null : c.expense - cmp.expense,
                risingIsGood: false,
              ),
            ),
          ],
        ),
        if (r.comparisonIsToDate) ...[
          const UISpace.vert(12),
          Text(
            l10n.progress_to_date_hint(baselineName),
            textAlign: TextAlign.center,
            style: typo.caption,
          ),
        ],
      ],
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({
    required this.label,
    required this.money,
    required this.delta,
    required this.change,
    required this.risingIsGood,
    this.color,
  });

  final String label;
  final Money money;
  final double? delta;
  final Money? change;
  final bool risingIsGood;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    return Column(
      children: [
        Text(label.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.sectionLabel),
        const UISpace.vert(6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: UiTotalAmount(
            money: money,
            animated: true,
            fontSize: 24,
            color: money.isZero ? context.colors.secondContentColor : color,
          ),
        ),
        const UISpace.vert(6),
        _Delta(change: change, ratio: delta, risingIsGood: risingIsGood),
      ],
    );
  }
}

/// `↗ 12% · +€85` — blue when the move is the good direction, red when
/// not, a muted dash with nothing to compare.
class _Delta extends StatelessWidget {
  const _Delta({required this.change, required this.risingIsGood, this.ratio});

  final Money? change;
  final double? ratio;
  final bool risingIsGood;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    final c = change;
    if (c == null || c.isZero) {
      return Text('—', style: typo.caption.copyWith(color: colors.secondContentColor));
    }
    final rising = c.isPositive;
    final color = rising == risingIsGood ? UIColorToken.blue : UIColorToken.neg500;
    final r = ratio;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        UIIcon(
          rising ? UIIconToken.icons.charts.trendUp01 : UIIconToken.icons.charts.trendDown01,
          size: 13,
          color: color,
        ),
        Flexible(
          child: Text(
            [if (r != null) ProgressLabels.percent(r), c.format(signed: true, positiveSign: true)].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typo.captionBold.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------- pace

/// "€120 less than September 2026 at this point" → the cumulative curve →
/// the forecast while the period is running.
class _Pace extends StatelessWidget {
  const _Pace({required this.report, required this.baselineName});

  final ProgressReport report;
  final String baselineName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final r = report;
    final diff = r.paceDelta;
    final forecast = r.forecast;

    String? insight;
    Color? tone;
    if (diff != null) {
      final base = r.paceBaseline![r.paceCurrent.length - 1];
      final same = diff.minor.abs() * 100 <= base.abs();
      final amount = diff.abs().format();
      if (same) {
        insight = r.isCurrent ? l10n.progress_pace_same(baselineName) : l10n.progress_total_same(baselineName);
      } else if (diff.isNegative) {
        insight = r.isCurrent ? l10n.progress_pace_less(amount, baselineName) : l10n.progress_total_less(amount, baselineName);
        tone = UIColorToken.blue;
      } else {
        insight = r.isCurrent ? l10n.progress_pace_more(amount, baselineName) : l10n.progress_total_more(amount, baselineName);
        tone = UIColorToken.neg500;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (insight != null) ...[
          Text(insight, style: typo.bodyMedium.copyWith(color: tone)),
          const UISpace.vert(16),
        ],
        ProgressPaceChart(report: r, baselineLabel: baselineName),
        if (forecast != null) ...[
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
                  style: typo.caption,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ------------------------------------------------------------ what changed

/// The three spending families that moved the most.
class _Movers extends StatelessWidget {
  const _Movers({required this.movers, required this.granularity});

  final List<ProgressTagNode> movers;
  final ProgressGranularity granularity;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;

    return Column(
      children: [
        for (var i = 0; i < movers.length; i++) ...[
          if (i > 0) const UIDivider(),
          () {
            final n = movers[i];
            final delta = n.delta!;
            final base = n.baseline!;
            final up = delta.isPositive;
            final color = up ? UIColorToken.neg500 : UIColorToken.blue;
            return UITap(
              onTap: () => context.router.push(TagDetailsRoute(tagId: n.tagId)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    UIIcon(
                      up ? UIIconToken.icons.charts.trendUp01 : UIIconToken.icons.charts.trendDown01,
                      size: 18,
                      color: color,
                    ),
                    const UISpace.horz(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          TagPathText(path: n.displayName, style: typo.listTitle),
                          Text(
                            l10n.progress_now_was(n.amount.format(), base.format()),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typo.caption,
                          ),
                        ],
                      ),
                    ),
                    const UISpace.horz(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 2,
                      children: [
                        Text(delta.format(signed: true, positiveSign: true), style: typo.listTitle.copyWith(color: color)),
                        Text(
                          base.isZero ? l10n.progress_new : ProgressLabels.percent(delta.minor / base.minor),
                          style: typo.caption.copyWith(color: base.isZero ? colors.secondContentColor : color),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }(),
        ],
      ],
    );
  }
}

// --------------------------------------------------------------- breakdown

/// Spending | Income by tag family. A family includes every nested tag
/// (counted once); the chevron reveals its children, a tap opens the tag.
/// Bars are a share of the period's own total, so overlapping tags (a row
/// carrying two families) never stretch a bar past the truth.
class _Breakdown extends HookWidget {
  const _Breakdown({required this.report});

  final ProgressReport report;

  static const int _collapsedRoots = 6;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final r = report;
    final income = useState(false);
    final expanded = useState<Set<String>>(const {});
    final showAll = useState(false);

    final b = income.value ? r.earning : r.spending;
    final total = income.value ? r.current.income : r.current.expense;
    final hasBaseline = r.comparison != null;

    void toggle(String id) {
      final next = Set<String>.of(expanded.value);
      if (!next.remove(id)) next.add(id);
      expanded.value = next;
    }

    final rows = <Widget>[];
    void add(ProgressTagNode n, int depth) {
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
          share: total.isPositive ? (n.amount.minor / total.minor).clamp(0.0, 1.0) : 0,
          delta: hasBaseline ? n.delta : null,
          risingIsGood: income.value,
          depth: depth,
          expanded: n.children.isEmpty ? null : open,
          onToggle: n.children.isEmpty ? null : () => toggle(n.tagId),
          onTap: () => context.router.push(TagDetailsRoute(tagId: n.tagId)),
        ),
      );
      if (open) {
        for (final child in n.children) {
          add(child, depth + 1);
        }
      }
    }

    final roots = showAll.value ? b.roots : b.roots.take(_collapsedRoots).toList();
    for (final n in roots) {
      add(n, 0);
    }
    if (b.untagged.isPositive) {
      rows.add(
        _TagRow(
          key: const ValueKey('progress-tag-untagged'),
          label: Text(l10n.progress_untagged, style: typo.listTitle.copyWith(color: context.colors.secondContentColor)),
          amount: b.untagged,
          count: b.untaggedCount,
          share: total.isPositive ? (b.untagged.minor / total.minor).clamp(0.0, 1.0) : 0,
          delta: hasBaseline && b.untaggedBaseline != null ? b.untagged - b.untaggedBaseline! : null,
          risingIsGood: income.value,
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
          income.value = i == 1;
          showAll.value = false;
        },
      ),
      child: AnimatedSize(
        duration: UIAnim.fast,
        curve: UIAnim.easeOut,
        alignment: Alignment.topCenter,
        child: b.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  income.value ? l10n.progress_no_income : l10n.progress_no_expenses,
                  style: typo.hint,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0) const UIDivider(),
                    rows[i],
                  ],
                  if (b.roots.length > _collapsedRoots)
                    UITap(
                      onTap: () => showAll.value = !showAll.value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          showAll.value ? l10n.progress_show_less : l10n.progress_show_all(b.roots.length),
                          textAlign: TextAlign.center,
                          style: typo.captionBold.copyWith(color: UIColorToken.blue),
                        ),
                      ),
                    ),
                  if (overlaps) ...[
                    const UISpace.vert(4),
                    Text(l10n.progress_overlap_hint, style: typo.caption),
                  ],
                ],
              ),
      ),
    );
  }
}

/// `#food ················ €420  ⌄`
/// `▬▬▬▬▬▬▬▬▬▬░░░░░░░░░░░░░░░░░░░`
/// `32% · 14 transactions      +€40`
class _TagRow extends StatelessWidget {
  const _TagRow({
    super.key,
    required this.label,
    required this.amount,
    required this.count,
    required this.share,
    required this.delta,
    required this.risingIsGood,
    required this.depth,
    this.expanded,
    this.onToggle,
    this.onTap,
  });

  final Widget label;
  final Money amount;
  final int count;
  final double share;
  final Money? delta;
  final bool risingIsGood;
  final int depth;

  /// Null = no nested tags (no chevron).
  final bool? expanded;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    final d = delta;
    final barColor = risingIsGood ? UIColorToken.blue : colors.expenseColor;

    return UITap(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: depth * 18.0, top: 12, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: label),
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
            const UISpace.vert(8),
            UiBudgetBar(
              spentRatio: share,
              color: depth == 0 ? barColor : barColor.withValues(alpha: 0.6),
              height: 4,
            ),
            const UISpace.vert(6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${ProgressLabels.percent(share)} · ${l10n.tags_usage(count)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typo.caption,
                  ),
                ),
                if (d != null && !d.isZero)
                  Text(
                    d.format(signed: true, positiveSign: true),
                    style: typo.captionBold.copyWith(
                      color: d.isPositive == risingIsGood ? UIColorToken.blue : UIColorToken.neg500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ habits

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

    final rows = <Widget>[
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
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const UIDivider(),
          rows[i],
        ],
        if (peak != null) ...[
          const UISpace.vert(24),
          Text(l10n.progress_peak_weekday(ProgressLabels.weekday(peak)), style: typo.bodyMedium),
          const UISpace.vert(2),
          Text(l10n.progress_weekday_hint, style: typo.caption),
          const UISpace.vert(14),
          ProgressWeekdayBars(averages: h.weekdayAverages, currency: r.currency),
        ],
      ],
    );
  }
}

/// Icon · label (+ caption) · value — the budget rules row, read-only
/// unless [onTap] is set.
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
        padding: const EdgeInsets.symmetric(vertical: 13),
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
            Text(value, style: typo.label),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UiSegmentedToggle(
            labels: [l10n.progress_saved, l10n.progress_income, l10n.progress_spent],
            selectedIndex: series.value.index,
            onChanged: (i) => series.value = ProgressHistorySeries.values[i],
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
    );
  }
}
