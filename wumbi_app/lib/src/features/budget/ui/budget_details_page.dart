import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/budget_period_type.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../../core/utils/hooks/use_swipe_tabs.dart';
import '../../tag/data/models/tag_model.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../../wallet/ui/widgets/month_divider.dart';
import '../../mascot/domain/mascot_screens.dart';
import '../../mascot/ui/mascot_answers.dart';
import '../../mascot/ui/widgets/mascot_peek.dart';
import '../data/budget_metrics.dart';
import '../data/models/budget_model.dart';
import 'budget_details_notifier.dart';
import 'budget_form_page.dart';
import 'budget_labels.dart';
import 'widgets/budget_sheets.dart';

/// Room under each tab list so the last row clears the FAB.
const double _kListBottomInset = 134;

enum _BudgetTab { overview, transactions }

/// `/budgets/:id` (spec B&D §6.7) — the name in the app bar, a fixed header
/// (ring gauge, period navigator, tab bar) and two swipeable tabs sharing the
/// browsed period:
/// - Overview: pace → stat tiles → what counts (wallets, tags → their
///   details) → rules (each opens the form on its own sheet);
/// - Transactions: the rows the period counts.
///
/// Browsing periods keeps the previous numbers on screen and lets the ring /
/// counters glide to the new ones. The FAB adds a transaction preset to this
/// budget's wallet and tags.
@RoutePage()
class BudgetDetailsPage extends HookConsumerWidget {
  const BudgetDetailsPage({super.key, @PathParam('id') required this.budgetId, this.seed});

  final String budgetId;

  /// The tapped row's progress (running period): shown until the provider
  /// loads, so the name / ring heroes have a target on the first frame.
  final BudgetProgress? seed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final offset = useState(0);
    final args = BudgetDetailsArgs(budgetId: budgetId, periodOffset: offset.value);
    final state = ref.watch(budgetDetailsProvider(args));
    final notifier = ref.read(budgetDetailsProvider(args).notifier);
    final scrollController = useScrollController();
    final wallets = ref.watch(walletsProvider).value ?? const <WalletSummary>[];
    final tabs = useSwipeTabs();

    // Infinite scroll of the Transactions tab (the only one on the controller).
    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients || scrollController.positions.length != 1) return;
        final pos = scrollController.position;
        if (pos.maxScrollExtent > 0 && pos.pixels >= pos.maxScrollExtent * 0.8) notifier.loadMore();
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController, notifier]);

    // Deleted underneath us: leave quietly (the form already showed Undo).
    useEffect(() {
      if (!state.notFound) return null;
      Future.microtask(() {
        if (context.mounted) context.router.maybePop();
      });
      return null;
    }, [state.notFound]);

    // Each period is its own provider instance (it starts empty): keep the
    // last numbers on screen meanwhile so the ring and counters animate from
    // them instead of flashing a skeleton.
    final lastProgress = useRef<BudgetProgress?>(seed);
    final lastTags = useRef<List<TagModel>>(const []);
    final loaded = state.progress.value != null;
    if (loaded) {
      lastProgress.value = state.progress.value;
      lastTags.value = state.tags;
    }
    final progress = state.progress.value ?? lastProgress.value;
    final tags = loaded ? state.tags : lastTags.value;
    final tagNames = [for (final t in tags) t.displayName];

    void browse(int delta) {
      AppVibrations.selection();
      offset.value = offset.value + delta;
    }

    void backToCurrent() {
      AppVibrations.selection();
      offset.value = 0;
    }

    void edit([BudgetFormSheet? sheet]) =>
        context.router.push(BudgetFormRoute(budgetId: budgetId, sheet: sheet?.name));

    return MascotPeekLayer(
      states: progress == null
          ? null
          : MascotScreens.withTips(
              MascotScreens.budgetDetails(progress, now: DateTime.now()),
              MascotScreens.budgetDetailsTips(),
            ),
      hidden: state.notFound,
      questions: MascotQuestions.budgets,
      child: Scaffold(
      appBar: UIAppbar(
        title: progress?.budget.name ?? '',
        titleHeroTag: heroBudgetName(budgetId),
        backTap: () => context.router.maybePop(),
        action: progress == null ? null : UIIcon(UIIconToken.icons.general.edit05, size: 22, onTap: edit),
      ),
      floatingActionButton: progress == null || state.notFound
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: UiFab(
                heroTag: kHeroFab,
                onTap: () => context.router.push(
                  TransactionRoute(
                    walletId: _walletFor(progress.budget, wallets),
                    tags: tagNames.isEmpty ? null : tagNames,
                  ),
                ),
              ),
            ),
      body: state.notFound
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: amount left, period navigator, tabs. Natural height.
                Padding(
                  padding: const EdgeInsets.fromLTRB(kListHorzPadding, 8, kListHorzPadding, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (progress != null) ...[
                        _Summary(progress: progress),
                        const UISpace.vert(20),
                        _PeriodNavigator(
                          progress: progress,
                          offset: offset.value,
                          onPrevious: () => browse(-1),
                          onNext: () => browse(1),
                          onBackToCurrent: backToCurrent,
                        ),
                        const UISpace.vert(16),
                      ],
                      UiSegmentedToggle(
                        expanded: true,
                        labels: [l10n.budget_tab_overview, l10n.wallet_tab_transactions],
                        selectedIndex: tabs.index,
                        onChanged: tabs.onTabTap,
                      ),
                      const UISpace.vert(8),
                    ],
                  ),
                ),
                // Body (60 %): swipeable tabs, only they scroll. Pages are not
                // kept alive, so their cascade replays on every switch.
                Expanded(
                  flex: 6,
                  child: PageView(
                    controller: tabs.controller,
                    onPageChanged: tabs.onPageChanged,
                    children: [
                      for (final t in _BudgetTab.values)
                        KeyedSubtree(
                          key: ValueKey('$budgetId-${t.name}'),
                          child: switch (t) {
                            _BudgetTab.overview => _OverviewTab(
                                progress: progress,
                                tags: tags,
                                wallets: wallets,
                                onEdit: edit,
                              ),
                            _BudgetTab.transactions => _TransactionsTab(
                                state: state,
                                offset: offset.value,
                                controller: scrollController,
                              ),
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
    ),
    );
  }

  /// Wallet the FAB preselects: none for an all-wallets budget (the
  /// Transaction page falls back to the primary one), else the primary if it
  /// is in scope, else the first scoped wallet in the user's order.
  static String? _walletFor(BudgetModel b, List<WalletSummary> wallets) {
    if (b.walletIds.isEmpty) return null;
    final scoped = wallets.where((w) => b.walletIds.contains(w.id));
    for (final w in scoped) {
      if (w.isPrimary) return w.id;
    }
    return scoped.firstOrNull?.id ?? b.walletIds.first;
  }
}

// --------------------------------------------------------------------- tabs

/// Scrollable tab body with smoke edges.
class _TabScroll extends StatelessWidget {
  const _TabScroll({required this.slivers, this.controller, this.topFade = 32});

  final List<Widget> slivers;
  final ScrollController? controller;

  /// 0 for lists with sticky month headers: the pinned header is the edge.
  final double topFade;

  @override
  Widget build(BuildContext context) {
    return UIScrollEdgeFade(
      top: topFade,
      child: CustomScrollView(
        controller: controller,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          const SliverToBoxAdapter(child: UISpace.vert(4)),
          ...slivers,
          const SliverToBoxAdapter(child: UISpace.vert(_kListBottomInset)),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(kListHorzPadding, 16, kListHorzPadding, 0),
          child: UiSkeletonList(rows: 4),
        ),
      );
}

/// Pace → tiles → what counts → rules.
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.progress,
    required this.tags,
    required this.wallets,
    required this.onEdit,
  });

  final BudgetProgress? progress;
  final List<TagModel> tags;
  final List<WalletSummary> wallets;
  final ValueChanged<BudgetFormSheet> onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = progress;
    if (p == null) return const _TabScroll(slivers: [_Loading()]);

    return _TabScroll(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Stats(progress: p),
                if (p.subscriptionCount > 0 && p.subscriptionPlanned != null) ...[
                  const UISpace.vert(8),
                  _SubscriptionsLink(progress: p),
                ],
                UiSectionLabel(text: l10n.budget_what_counts, padding: const EdgeInsets.fromLTRB(4, 24, 4, 8)),
                UiGroupCard(
                  children: [
                    if (p.budget.walletIds.isEmpty)
                      UiValueRow(label: l10n.budget_all_wallets)
                    else
                      for (final w in wallets.where((w) => p.budget.walletIds.contains(w.id)))
                        UiValueRow(
                          leading: UiCircleColorBadge(color: w.color.color, size: 10),
                          label: w.name,
                          onTap: () => context.router.push(WalletDetailsRoute(walletId: w.id)),
                        ),
                    for (final t in tags)
                      UiValueRow(
                        label: '#${t.displayName}',
                        onTap: () => context.router.push(TagDetailsRoute(tagId: t.id)),
                      ),
                  ],
                ),
                UiSectionLabel(text: l10n.settings_title, padding: const EdgeInsets.fromLTRB(4, 24, 4, 8)),
                _RulesList(budget: p.budget, onTap: onEdit),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// "On track" / "€25 ahead of pace" / "€40 faster than planned" (running
  /// period only; within 1 % of the limit counts as on track).
  static String? _pace(BuildContext context, BudgetProgress p) {
    if (!p.isCurrent || !p.limit.isPositive || !p.spent.isPositive) return null;
    final l10n = context.l10n;
    final delta = p.paceDelta;
    if (delta.minor.abs() * 100 < p.limit.minor) return l10n.budget_on_track;
    return delta.isPositive ? l10n.budget_ahead_of_pace(delta.format()) : l10n.budget_faster_than_planned(delta.abs().format());
  }
}

/// The rows the period counts — month sections when the period spans
/// several months.
class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab({required this.state, required this.offset, required this.controller});

  final BudgetDetailsState state;
  final int offset;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final rows = state.rows.value;
    // Fresh scope per period and once the rows arrive: the cascade plays on
    // the real rows.
    return UIStaggerScope(
      key: ValueKey('$offset-${rows != null}'),
      child: _TabScroll(
        controller: controller,
        topFade: 0,
        slivers: [
          ..._rowSlivers(context, rows),
          if (state.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static List<Widget> _rowSlivers(BuildContext context, List<TransactionRow>? list) {
    if (list == null) return const [_Loading()];
    if (list.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: UIStaggerItem(
            index: 0,
            child: UiEmptyState(mood: WumbiMood.sleep, title: context.l10n.budget_no_spending),
          ),
        ),
      ];
    }

    // Rows arrive newest first.
    final months = <(DateTime, List<TransactionRow>)>[];
    for (final row in list) {
      final date = row.transaction.transactionDate.toLocal();
      if (months.isEmpty || !months.last.$1.isSameMonth(date)) {
        months.add((date, [row]));
      } else {
        months.last.$2.add(row);
      }
    }

    Widget tile(TransactionRow row, int index) => UIStaggerItem(
          key: ValueKey('budget-row-${row.id}'),
          index: index,
          child: _RowTile(row: row),
        );

    if (months.length == 1) {
      return [
        const SliverToBoxAdapter(child: UISpace.vert(4)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
          sliver: SliverList.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => const UIDivider(),
            itemBuilder: (context, i) => tile(list[i], i),
          ),
        ),
      ];
    }

    final sections = <Widget>[];
    var stagger = 0;
    for (final (month, monthRows) in months) {
      final header = stagger++;
      final first = stagger;
      stagger += monthRows.length;
      sections.add(
        SliverStickySection(
          key: ValueKey('month-${month.year}-${month.month}'),
          header: UIStaggerItem(index: header, child: MonthDivider(label: month.formatMonthYear())),
          sliver: SliverList.separated(
            itemCount: monthRows.length,
            separatorBuilder: (_, _) => const UIDivider(),
            itemBuilder: (context, i) => tile(monthRows[i], first + i),
          ),
        ),
      );
    }
    return sections;
  }
}

// ----------------------------------------------------------- period navigator

/// [UiPeriodNavigator] for a budget: `October 2026` / `Oct 1 – 31 · 12 days
/// left`. One-time budgets have a single period: no arrows.
class _PeriodNavigator extends StatelessWidget {
  const _PeriodNavigator({
    required this.progress,
    required this.offset,
    required this.onPrevious,
    required this.onNext,
    required this.onBackToCurrent,
  });

  final BudgetProgress progress;

  /// 0 = running period, −1 = previous …
  final int offset;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onBackToCurrent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = progress;
    final b = p.budget;
    final custom = b.period.isCustom;

    final range = BudgetLabels.range(p.period);
    final label = custom ? range : BudgetLabels.period(l10n, b, p.period, isCurrent: p.isCurrent);
    final caption = [
      if (label != range) range,
      if (p.status == BudgetStatus.notStarted)
        l10n.budget_starts(p.period.start.formatShortDate())
      else if (p.isCurrent)
        l10n.budget_days_left(p.daysLeft)
      else
        l10n.budget_ended,
    ].join(' · ');

    return UiPeriodNavigator(
      label: label,
      caption: caption,
      position: p.period.index,
      showArrows: !custom,
      onPrevious: onPrevious,
      onNext: offset < 0 ? onNext : null,
      backLabel: offset == 0 ? null : l10n.budget_back_to_current,
      onBackToCurrent: onBackToCurrent,
    );
  }
}

// ------------------------------------------------------------- overview rows

/// Settings section: Repeats · Starts on · Carry over · Planned payments.
/// Each row opens the form on its own sheet.
class _RulesList extends StatelessWidget {
  const _RulesList({required this.budget, required this.onTap});

  final BudgetModel budget;
  final ValueChanged<BudgetFormSheet> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final b = budget;
    final custom = b.period.isCustom;
    final anchor = b.anchorDate;
    final end = b.endDate;

    final String start = switch (b.period) {
      BudgetPeriodType.monthly => l10n.budget_day_of_month(anchor.day),
      BudgetPeriodType.weekly => WeekdaySheet.name(anchor.weekday),
      BudgetPeriodType.yearly => anchor.formatShortDate(),
      BudgetPeriodType.custom => end == null
          ? anchor.formatMediumDate()
          : '${anchor.formatMediumDate()} – ${DateTime(end.year, end.month, end.day - 1).formatMediumDate()}',
    };

    return UiGroupCard(
      children: [
        UiValueRow(
          label: l10n.budget_repeats,
          value: BudgetLabels.periodType(l10n, b.period),
          onTap: () => onTap(BudgetFormSheet.period),
        ),
        UiValueRow(
          label: custom ? l10n.budget_period_section : l10n.budget_row_starts,
          value: start,
          onTap: () => onTap(BudgetFormSheet.start),
        ),
        if (!custom)
          UiValueRow(
            label: l10n.budget_carry_over,
            value: BudgetLabels.rollover(l10n, b.rollover),
            onTap: () => onTap(BudgetFormSheet.rollover),
          ),
        UiValueRow(
          label: l10n.budget_planned_title,
          value: BudgetLabels.countPlanned(l10n, b.includePlanned),
          onTap: () => onTap(BudgetFormSheet.planned),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------- shared bits

/// Header: what's left, one context line, a bar that glides between periods.
class _Summary extends StatelessWidget {
  const _Summary({required this.progress});

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final p = progress;
    final over = p.remaining.isNegative;
    final color = BudgetLabels.statusColor(p, context.colors);
    final ratio = p.spentRatio.isFinite ? p.spentRatio.clamp(0.0, 1.0).toDouble() : 0.0;
    final percent = p.spentRatio.isFinite ? (p.spentRatio * 100).round() : 0;
    final pace = _OverviewTab._pace(context, p);

    final word = switch (p.status) {
      BudgetStatus.notStarted => l10n.budget_starts(p.period.start.formatShortDate()),
      _ when over => l10n.budget_over_caption,
      _ when p.isCurrent => l10n.budget_left_caption,
      _ => l10n.budget_under_caption,
    };

    final contextLine = [
      l10n.budget_spent_of(p.spent.format(), p.limit.format()),
      if (p.isCurrent) l10n.budget_days_left(p.daysLeft),
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiTotalAmount(
          money: p.remaining.abs(),
          animated: true,
          fontSize: 36,
          color: over ? UIColorToken.neg500 : null,
        ),
        Text(
          word,
          textAlign: TextAlign.center,
          style: typo.caption.copyWith(color: over ? UIColorToken.neg500 : null),
        ),
        const UISpace.vert(16),
        TweenAnimationBuilder<double>(
          tween: Tween(end: ratio),
          duration: const Duration(milliseconds: 600),
          curve: UIAnim.easeOut,
          builder: (_, value, _) => ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              color: color,
              backgroundColor: color.withValues(alpha: 0.12),
            ),
          ),
        ),
        const UISpace.vert(8),
        Row(
          children: [
            Expanded(
              child: Text(contextLine, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.caption),
            ),
            Text(l10n.budget_used_percent(percent), style: typo.captionBold.copyWith(color: color)),
          ],
        ),
        if (pace != null) ...[
          const UISpace.vert(6),
          Text(pace, style: typo.captionBold.copyWith(color: color)),
        ],
      ],
    );
  }
}

/// Summary figures as one grouped card: label on the left (with an optional
/// sub line), value on the right. Scans top to bottom like a settings list.
class _Stats extends StatelessWidget {
  const _Stats({required this.progress});

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = progress;
    final carry = p.carry;
    final perDay = p.remaining.isNegative ? null : p.perDay;
    final forecast = p.forecast;

    return UiGroupCard(
      children: [
        _StatRow(
          label: l10n.budget_stat_spent,
          value: '${p.incomplete ? '≈ ' : ''}${p.spent.format()}',
          valueColor: p.isOver ? UIColorToken.neg500 : null,
        ),
        _StatRow(
          label: l10n.budget_stat_limit,
          value: p.limit.format(),
          sub: carry.isZero ? null : l10n.budget_carried(carry.format(signed: true, positiveSign: true)),
        ),
        if (perDay != null)
          _StatRow(
            label: l10n.budget_stat_per_day,
            value: perDay.format(),
            sub: l10n.budget_days_left(p.daysLeft),
          ),
        if (forecast != null) _StatRow(label: l10n.budget_stat_forecast, value: forecast.format()),
        if (p.planned.isPositive) _StatRow(label: l10n.budget_stat_planned, value: p.planned.format()),
      ],
    );
  }
}

/// One figure in [_Stats]: label + optional sub line on the left, value right.
class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, this.sub, this.valueColor});

  final String label;
  final String value;
  final String? sub;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.body),
                if (sub != null)
                  Text(sub!, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.caption),
              ],
            ),
          ),
          const UISpace.horz(12),
          Text(
            value,
            maxLines: 1,
            textAlign: TextAlign.end,
            style: typo.rowTitle.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

/// "2 subscriptions · €45" → Subscriptions page.
class _SubscriptionsLink extends StatelessWidget {
  const _SubscriptionsLink({required this.progress});

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = progress;
    return UITap(
      onTap: () => context.router.push(SubscriptionsRoute()),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          spacing: 6,
          children: [
            UIIcon(UIIconToken.icons.mediaDevices.repeat01, size: 14),
            Expanded(
              child: Text(
                l10n.budget_subscriptions_planned(p.subscriptionCount, p.subscriptionPlanned!.format()),
                style: context.typo.inter.caption,
              ),
            ),
            UIIcon(UIIconToken.icons.arrows.chevronRight, size: 14),
          ],
        ),
      ),
    ).uiFadeSlideIn(delay: const Duration(milliseconds: 480), offset: 0.3);
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.row});

  final TransactionRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = row.transaction;
    return UiTransactionCard(
      title: t.description.isEmpty ? l10n.common_expense : t.description,
      subtitle: t.transactionDate.formatListDate(),
      amount: t.amountFor(t.walletId ?? '', t.currency).abs(),
      direction: UiTransactionDirection.expense,
      secondaryText: row.walletName,
      tags: row.tags,
      upcoming: t.isUpcoming,
      badge: t.isUpcoming ? l10n.transaction_upcoming_badge : null,
      onTap: () => context.router.push(TransactionRoute(transactionId: row.id, walletId: t.walletId)),
    );
  }
}
