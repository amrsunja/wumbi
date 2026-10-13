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
import '../../../core/utils/typedefs.dart';
import '../../tag/data/models/tag_model.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../../wallet/ui/widgets/month_divider.dart';
import '../data/budget_metrics.dart';
import '../data/models/budget_model.dart';
import 'budget_details_notifier.dart';
import 'budget_form_page.dart';
import 'budget_labels.dart';
import 'widgets/budget_sheets.dart';

/// Room under each tab list so the last row clears the FAB.
const double _kListBottomInset = 104;

/// Ring (216) + gap + navigator: holds the header's place on first load so
/// the tabs don't jump.
const double _kHeaderPlaceholderHeight = 216 + 16 + 56;

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
    // One clock for the ring's sweep-in, shared by the hero shuttle and the
    // ring that replaces it on landing (else it sweeps twice).
    final ringSweepStart = useMemoized(DateTime.now);
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

    return Scaffold(
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
                // Fixed header: ring, period navigator, tabs.
                Padding(
                  padding: const EdgeInsets.fromLTRB(kListHorzPadding, 4, kListHorzPadding, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (progress == null)
                        const SizedBox(height: _kHeaderPlaceholderHeight)
                      else ...[
                        // Flies in from the row's bar (no entrance fade: the
                        // hero is the entrance).
                        Center(
                          child: UiHero(
                            tag: heroBudgetProgress(budgetId),
                            pushedShuttle: true,
                            child: _Ring(progress: progress, sweepStartedAt: ringSweepStart),
                          ),
                        ),
                        const UISpace.vert(16),
                        _PeriodNavigator(
                          progress: progress,
                          offset: offset.value,
                          onPrevious: () => browse(-1),
                          onNext: () => browse(1),
                          onBackToCurrent: backToCurrent,
                        ).uiFadeSlideIn(delay: const Duration(milliseconds: 120), offset: 0.3),
                      ],
                      const UISpace.vert(16),
                      UiSegmentedToggle(
                        expanded: true,
                        labels: [l10n.budget_tab_overview, l10n.wallet_tab_transactions],
                        selectedIndex: tabs.index,
                        onChanged: tabs.onTabTap,
                      ),
                    ],
                  ),
                ),
                // Swipeable tab bodies (only they scroll). Pages are not kept
                // alive, so their cascade replays on every switch.
                Expanded(
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

    final pace = _pace(context, p);
    final statusColor = BudgetLabels.statusColor(p.status, context.colors);

    Widget section(String label, Widget child, int delayMs) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiSectionLabel(text: label, padding: const EdgeInsets.fromLTRB(4, 28, 4, 8)),
            child,
          ],
        ).uiFadeSlideIn(delay: Duration(milliseconds: delayMs), offset: 0.2);

    return _TabScroll(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: AnimatedSwitcher(
                    duration: UIAnim.fast,
                    child: pace == null
                        ? const SizedBox(key: ValueKey('no-pace'), height: 0, width: double.infinity)
                        : Padding(
                            key: ValueKey(pace),
                            padding: const EdgeInsets.only(top: 4, bottom: 14),
                            child: _Pill(text: pace, color: statusColor, dot: true),
                          ),
                  ).uiFadeSlideIn(delay: const Duration(milliseconds: 200), offset: 0.3),
                ),
                const UISpace.vert(4),
                _Stats(progress: p),
                if (p.subscriptionCount > 0 && p.subscriptionPlanned != null) ...[
                  const UISpace.vert(8),
                  _SubscriptionsLink(progress: p),
                ],
                section(
                  l10n.budget_what_counts,
                  _ScopeCard(budget: p.budget, wallets: wallets, tags: tags),
                  420,
                ),
                section(l10n.settings_title, _RulesCard(budget: p.budget, onTap: onEdit), 500),
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
            child: UiEmptyState(image: AppAssets.images.wumbiOo.path, title: context.l10n.budget_no_spending),
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

/// Tinted card under the ring (fixed header):
///
/// ```
/// (‹)        October 2026         (›)
///      Oct 1 – 31 · 12 days left
/// ```
/// The label slides in the browsing direction; away from the running period
/// a "Back to today" link returns to it. One-time budgets have a single
/// period: no arrows.
class _PeriodNavigator extends HookWidget {
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
    final colors = context.colors;
    final typo = context.typo.inter;
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

    // +1 = moving forward in time (slide from the right), −1 = back.
    final direction = useRef(1);
    final lastIndex = useRef(p.period.index);
    if (p.period.index != lastIndex.value) {
      direction.value = p.period.index > lastIndex.value ? 1 : -1;
      lastIndex.value = p.period.index;
    }

    Widget slide(Widget child, Object key) => AnimatedSwitcher(
          duration: UIAnim.fast,
          switchInCurve: UIAnim.easeOut,
          switchOutCurve: UIAnim.easeOut,
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.center,
            children: [...previous, ?current],
          ),
          transitionBuilder: (child, animation) {
            final incoming = child.key == ValueKey(key);
            final dx = (incoming ? 0.25 : -0.25) * direction.value;
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(begin: Offset(dx, 0), end: Offset.zero).animate(animation),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(key: ValueKey(key), child: child),
        );

    final center = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        slide(
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: typo.rowTitle),
          label,
        ),
        const UISpace.vert(2),
        slide(
          Text(caption, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: typo.caption),
          caption,
        ),
        AnimatedSize(
          duration: UIAnim.fast,
          curve: UIAnim.easeOut,
          child: offset == 0
              ? const SizedBox(width: double.infinity)
              : UITap(
                  onTap: onBackToCurrent,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      l10n.budget_back_to_current,
                      style: typo.captionBold.copyWith(color: UIColorToken.blue),
                    ),
                  ),
                ),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: custom ? 14 : 8),
      decoration: BoxDecoration(
        color: colors.secondContentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: custom
          ? center
          : Row(
              children: [
                _NavButton(icon: UIIconToken.icons.arrows.chevronLeft, onTap: onPrevious),
                Expanded(child: center),
                _NavButton(icon: UIIconToken.icons.arrows.chevronRight, onTap: offset < 0 ? onNext : null),
              ],
            ),
    );
  }
}

/// Round 40 px arrow on the card colour; dimmed when there is nowhere to go.
class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedOpacity(
      duration: UIAnim.fast,
      opacity: onTap == null ? 0.3 : 1,
      child: UITap(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: colors.fgColor, shape: BoxShape.circle),
          child: UIIcon(icon, size: 20),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ overview cards

/// Tinted rounded card holding rows separated by hairlines.
class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.colors.secondContentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const UIDivider(),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// "Counts expenses from Card tagged #food." then one row per wallet and
/// the #tags — each opens its details.
class _ScopeCard extends StatelessWidget {
  const _ScopeCard({required this.budget, required this.wallets, required this.tags});

  final BudgetModel budget;
  final List<WalletSummary> wallets;
  final List<TagModel> tags;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    final scoped = wallets.where((w) => budget.walletIds.contains(w.id)).toList();

    return _Card(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 14, 4, 12),
          child: Text(
            BudgetLabels.scopeSentence(
              l10n,
              walletNames: scoped.map((w) => w.name).toList(),
              tagNames: tags.map((t) => t.displayName).toList(),
            ),
            style: typo.body,
          ),
        ),
        if (budget.walletIds.isEmpty)
          UiListRow(
            leading: UIIcon(UIIconToken.icons.financeEcommerce.wallet02, size: 18, color: colors.secondContentColor),
            title: l10n.budget_all_wallets,
          )
        else
          for (final w in scoped)
            UiListRow(
              leading: UiCircleColorBadge(color: w.color.color, size: 10),
              title: w.name,
              trailing: UIIcon(UIIconToken.icons.arrows.chevronRight, size: 16, color: colors.secondContentColor),
              onTap: () => context.router.push(WalletDetailsRoute(walletId: w.id)),
            ),
        if (tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: UIIcon(UIIconToken.icons.general.hash01, size: 18, color: colors.secondContentColor),
                ),
                const UISpace.horz(14),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final t in tags)
                        UITap(
                          onTap: () => context.router.push(TagDetailsRoute(tagId: t.id)),
                          child: _Pill(text: '#${t.displayName}', color: UIColorToken.blue),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Repeats · Starts on · Carry over · Planned payments — a tap opens the
/// form on that row's sheet.
class _RulesCard extends StatelessWidget {
  const _RulesCard({required this.budget, required this.onTap});

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

    return _Card(
      children: [
        _RuleRow(
          icon: UIIconToken.icons.mediaDevices.repeat01,
          label: l10n.budget_repeats,
          value: BudgetLabels.periodType(l10n, b.period),
          onTap: () => onTap(BudgetFormSheet.period),
        ),
        _RuleRow(
          icon: UIIconToken.icons.time.calendar,
          label: custom ? l10n.budget_period_section : l10n.budget_row_starts,
          value: start,
          onTap: () => onTap(BudgetFormSheet.start),
        ),
        if (!custom)
          _RuleRow(
            icon: UIIconToken.icons.arrows.flipForward,
            label: l10n.budget_carry_over,
            value: BudgetLabels.rollover(l10n, b.rollover),
            onTap: () => onTap(BudgetFormSheet.rollover),
          ),
        _RuleRow(
          icon: UIIconToken.icons.time.clockFastForward,
          label: l10n.budget_planned_title,
          value: BudgetLabels.countPlanned(l10n, b.includePlanned),
          onTap: () => onTap(BudgetFormSheet.planned),
        ),
      ],
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.icon, required this.label, required this.value, required this.onTap});

  final String icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            UIIcon(icon, size: 18, color: colors.secondContentColor),
            const UISpace.horz(14),
            Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.body)),
            const UISpace.horz(12),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: typo.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------- shared bits

/// Ring gauge with the remaining amount, its word and "42 % used".
class _Ring extends StatelessWidget {
  const _Ring({required this.progress, required this.sweepStartedAt});

  final BudgetProgress progress;
  final DateTime sweepStartedAt;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final p = progress;
    final statusColor = BudgetLabels.statusColor(p.status, context.colors);

    // Big number + its word: running → left / over; past → under / over.
    final over = p.remaining.isNegative;
    final String word;
    if (p.status == BudgetStatus.notStarted) {
      word = l10n.budget_starts(p.period.start.formatShortDate());
    } else if (over) {
      word = l10n.budget_over_caption;
    } else {
      word = p.isCurrent ? l10n.budget_left_caption : l10n.budget_under_caption;
    }
    final percent = p.spentRatio.isFinite ? (p.spentRatio * 100).round() : 0;

    return UiBudgetRing(
      sweepStartedAt: sweepStartedAt,
      spentRatio: p.spentRatio,
      plannedRatio: p.plannedRatio,
      color: statusColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UiTotalAmount(
            money: p.remaining.abs(),
            animated: true,
            fontSize: 30,
            color: over ? UIColorToken.neg500 : null,
          ),
          AnimatedSwitcher(
            duration: UIAnim.fast,
            child: Text(
              word,
              key: ValueKey(word),
              textAlign: TextAlign.center,
              style: typo.subtitle.copyWith(color: over ? UIColorToken.neg500 : null),
            ),
          ),
          const UISpace.vert(10),
          _Pill(text: l10n.budget_used_percent(percent), color: statusColor),
        ],
      ),
    );
  }
}

/// Spent · Limit · Planned · Per day · Forecast tiles, two per row (a lone
/// last tile spans the row). Values cross-fade when they change. When any
/// tile has a sub line, every tile reserves it so all share one height.
class _Stats extends StatelessWidget {
  const _Stats({required this.progress});

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = progress;
    final carry = p.carry;
    final perDay = p.perDay;
    final forecast = p.forecast;

    final tiles = <_StatData>[
      _StatData(
        label: l10n.budget_stat_spent,
        value: '${p.incomplete ? '≈ ' : ''}${p.spent.format()}',
        color: p.isOver ? UIColorToken.neg500 : null,
      ),
      _StatData(
        label: l10n.budget_stat_limit,
        value: p.limit.format(),
        sub: carry.isZero ? null : l10n.budget_carried(carry.format(signed: true, positiveSign: true)),
      ),
      if (p.planned.isPositive) _StatData(label: l10n.budget_stat_planned, value: p.planned.format()),
      if (perDay != null)
        _StatData(label: l10n.budget_stat_per_day, value: perDay.format(), sub: l10n.budget_days_left(p.daysLeft)),
      if (forecast != null)
        // No orange here: orange means ≥ 90 % of the limit is used.
        _StatData(label: l10n.budget_stat_forecast, value: forecast.format()),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final half = (constraints.maxWidth - gap) / 2;
        final reserveSub = tiles.any((t) => t.sub != null);
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < tiles.length; i++)
              SizedBox(
                key: ValueKey(tiles[i].label),
                width: i == tiles.length - 1 && tiles.length.isOdd ? constraints.maxWidth : half,
                child: _StatTile(data: tiles[i], reserveSub: reserveSub).uiFadeSlideIn(
                  delay: Duration(milliseconds: 260 + 60 * i),
                  offset: 0.25,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatData {
  const _StatData({required this.label, required this.value, this.sub, this.color});

  final String label;
  final String value;
  final String? sub;
  final Color? color;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.data, required this.reserveSub});

  final _StatData data;

  /// Keep the sub line's room even without one (equal tile heights).
  final bool reserveSub;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    final sub = data.sub;

    Widget fade(Widget child) => AnimatedSwitcher(
          duration: UIAnim.fast,
          layoutBuilder: (current, previous) => Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [...previous, ?current],
          ),
          child: child,
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: colors.secondContentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.label.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.sectionLabel),
          const UISpace.vert(6),
          fade(
            Text(
              data.value,
              key: ValueKey(data.value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.rowTitle.copyWith(color: data.color),
            ),
          ),
          if (reserveSub) ...[
            const UISpace.vert(2),
            fade(
              Text(
                sub ?? '',
                key: ValueKey(sub),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typo.caption,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Rounded tinted label: status pill, pace, scope chips.
class _Pill extends StatelessWidget {
  const _Pill({super.key, required this.text, required this.color, this.leading, this.dot = false});

  final String text;
  final Color color;
  final Widget? leading;

  /// Leading status dot in [color].
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (dot)
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          ?leading,
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.semiBold.copyWith(fontSize: 12, color: color),
            ),
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
