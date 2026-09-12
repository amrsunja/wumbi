import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/typedefs.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../data/models/progress_stats.dart';
import 'progress_notifier.dart';
import 'widgets/progress_bar_chart.dart';
import 'widgets/progress_lines_chart.dart';
import 'widgets/progress_tag_pie_chart.dart';
import 'widgets/progress_scope_sheet.dart';

/// `/progress` — income vs expense over the last few months or years, with
/// the running period compared against the one before it.
@RoutePage()
class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final state = ref.watch(progressProvider);
    final notifier = ref.read(progressProvider.notifier);
    final wallets = ref.watch(walletsProvider).value ?? const <WalletSummary>[];

    WalletSummary? selected;
    for (final wallet in wallets) {
      if (wallet.id == state.walletId) selected = wallet;
    }

    Future<void> pickScope() async {
      final scope = await ProgressScopeSheet.show(
        context,
        wallets: wallets,
        selectedId: state.walletId,
      );
      if (scope == null) return;
      notifier.setWallet(scope.walletId);
    }

    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: colors.bgColor)),
        const Positioned.fill(child: UiAmbientBackground()),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: UIAppbar(
            title: l10n.progress_title,
            transparent: true,
            backTap: () => context.router.maybePop(),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 4, kPageHorzPadding, 48),
            child: Column(
              children: [
                _ScopeBar(
                  label: selected?.name ?? l10n.progress_all_wallets,
                  color: selected?.color.color,
                  onTap: wallets.isEmpty ? null : pickScope,
                ),
                const UISpace.vert(8),
                _PeriodToggle(
                  granularity: state.granularity,
                  onChanged: notifier.setGranularity,
                ),
                const UISpace.vert(20),
                _Body(state: state),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------- scope

/// Outlined pill mirroring the dashboard header links: the wallet the page is
/// scoped to, or "All wallets".
class _ScopeBar extends StatelessWidget {
  const _ScopeBar({required this.label, required this.color, required this.onTap});

  final String label;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return UITap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: colors.dividerColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            if (color != null)
              UiCircleColorBadge(color: color!, size: 8)
            else
              UIIcon(UIIconToken.icons.financeEcommerce.wallet02, size: 14),
            Text(label, style: context.typo.inter.captionBold),
            if (onTap != null) UIIcon(UIIconToken.icons.arrows.chevronDown, size: 14),
          ],
        ),
      ),
    );
  }
}

/// Month / Year, styled like the tags hub toggle.
class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({required this.granularity, required this.onChanged});

  final ProgressGranularity granularity;
  final ValueChanged<ProgressGranularity> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    const options = ProgressGranularity.values;

    String labelOf(ProgressGranularity value) => switch (value) {
          ProgressGranularity.month => l10n.progress_month,
          ProgressGranularity.year => l10n.progress_year,
        };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        for (final option in options)
          UITap(
            onTap: () => onChanged(option),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: typo.label.copyWith(
                      color: option == granularity ? UIColorToken.blue : colors.secondContentColor,
                    ),
                    child: Text(labelOf(option)),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: option == granularity ? 22 : 0,
                    height: 2,
                    decoration: BoxDecoration(
                      color: UIColorToken.blue,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// --------------------------------------------------------------------- body

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final ProgressState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = state.stats.value;

    if (state.stats.hasError && stats == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(l10n.error_unknown, style: context.typo.inter.caption),
      );
    }

    if (stats == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: UiSkeletonList(rows: 4),
      );
    }

    if (stats.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: UiEmptyState(
          image: AppAssets.images.wumbiOo.path,
          title: l10n.progress_empty_title,
          subtitle: l10n.progress_empty_subtitle,
        ),
      );
    }

    final colors = context.colors;

    return Column(
      children: [
        _CurrentNet(stats: stats),
        const UISpace.vert(20),
        _DeltaTiles(stats: stats),
        const UISpace.vert(20),
        _ChartCard(
          title: l10n.progress_chart_title,
          trailing: _IncomeExpenseLegend(expenseColor: colors.expenseColor),
          child: ProgressBarChart(stats: stats),
        ),
        const UISpace.vert(14),
        _ChartCard(
          title: l10n.progress_trend_title,
          trailing: _IncomeExpenseLegend(expenseColor: colors.expenseColor),
          child: ProgressLinesChart(stats: stats),
        ),
        const UISpace.vert(14),
        _TagsCard(stats: stats),
        if (stats.unconvertible.isNotEmpty) ...[
          const UISpace.vert(14),
          Text(
            l10n.progress_not_included(stats.unconvertible.map((c) => c.code).join(', ')),
            textAlign: TextAlign.center,
            style: context.typo.inter.caption,
          ),
        ],
      ],
    );
  }
}

/// Net of the running period, with the baseline written underneath.
class _CurrentNet extends StatelessWidget {
  const _CurrentNet({required this.stats});

  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final net = stats.current.net;
    final caption = switch (stats.granularity) {
      ProgressGranularity.month => l10n.progress_vs_last_month,
      ProgressGranularity.year => l10n.progress_vs_last_year,
    };

    return Column(
      children: [
        UiTotalAmount(
          money: net,
          animated: true,
          fontSize: 40,
          color: net.isNegative ? colors.expenseColor : UIColorToken.blue,
        ),
        const UISpace.vert(8),
        Text(
          '${stats.labelOf(stats.current)} · $caption',
          textAlign: TextAlign.center,
          style: context.typo.inter.subtitle,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- KPI tiles

class _DeltaTiles extends StatelessWidget {
  const _DeltaTiles({required this.stats});

  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final current = stats.current;

    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: _StatTile(
            label: l10n.progress_income,
            money: current.income,
            valueColor: UIColorToken.blue,
            delta: stats.incomeDelta,
            // Earning more than last period is the good direction.
            risingIsGood: true,
          ),
        ),
        Expanded(
          child: _StatTile(
            label: l10n.progress_expense,
            money: current.expense,
            valueColor: colors.expenseColor,
            delta: stats.expenseDelta,
            risingIsGood: false,
          ),
        ),
        Expanded(
          child: _StatTile(
            label: l10n.progress_net,
            money: current.net,
            valueColor: current.net.isNegative ? colors.expenseColor : UIColorToken.blue,
            delta: stats.netDelta,
            risingIsGood: true,
            signed: true,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.money,
    required this.valueColor,
    required this.delta,
    required this.risingIsGood,
    this.signed = false,
  });

  final String label;
  final Money money;
  final Color valueColor;

  /// Relative change against the baseline period; null = nothing to compare.
  final double? delta;

  /// Whether an increase should read as a win (income, net) or not (expense).
  final bool risingIsGood;
  final bool signed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colors.fgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typo.sectionLabel,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              signed ? money.format(signed: true, positiveSign: true) : money.format(),
              maxLines: 1,
              style: typo.rowTitle.copyWith(color: valueColor),
            ),
          ),
          _DeltaBadge(delta: delta, risingIsGood: risingIsGood),
        ],
      ),
    );
  }
}

/// `▲ 12 %` — blue when the move is the good direction, red when it is not,
/// and a muted dash while there is no baseline to compare against.
class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({required this.delta, required this.risingIsGood});

  final double? delta;
  final bool risingIsGood;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    final value = delta;

    if (value == null || value == 0) {
      return Text('—', style: typo.caption.copyWith(color: colors.secondContentColor));
    }

    final rising = value > 0;
    final good = rising == risingIsGood;
    final color = good ? UIColorToken.blue : UIColorToken.neg500;
    final percent = (value.abs() * 100).round();

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        UIIcon(
          rising ? UIIconToken.icons.charts.trendUp01 : UIIconToken.icons.charts.trendDown01,
          size: 12,
          color: color,
        ),
        Flexible(
          child: Text(
            '$percent%',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typo.caption.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------- chart

/// Shared shell for the three charts: fg-coloured panel, hairline border,
/// a title row that can carry a legend on the right.
class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(
        color: colors.fgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typo.inter.listTitle,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const UISpace.vert(16),
          child,
        ],
      ),
    );
  }
}

/// Donut of the running period's spending per tag. A tapped slice opens that
/// tag; the card degrades to a caption when nothing was spent.
class _TagsCard extends StatelessWidget {
  const _TagsCard({required this.stats});

  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _ChartCard(
      title: l10n.progress_tags_title,
      trailing: Text(stats.labelOf(stats.current), style: context.typo.inter.caption),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
        child: stats.expenseByTag.isEmpty
            ? Text(l10n.progress_no_expenses, style: context.typo.inter.caption)
            : ProgressTagPieChart(
                stats: stats,
                onTagTap: (tagId) => context.router.push(TagDetailsRoute(tagId: tagId)),
              ),
      ),
    );
  }
}

/// Shared key for the two charts that plot both series.
class _IncomeExpenseLegend extends StatelessWidget {
  const _IncomeExpenseLegend({required this.expenseColor});

  final Color expenseColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendDot(color: UIColorToken.blue, label: l10n.progress_income),
        const UISpace.horz(10),
        _LegendDot(color: expenseColor, label: l10n.progress_expense),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(label, style: context.typo.inter.caption),
      ],
    );
  }
}
