import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../budget/ui/budget_labels.dart';
import '../../budget/ui/budgets_provider.dart';
import '../../budget/ui/widgets/budget_progress_row.dart';
import '../../debt/ui/debts_provider.dart';
import '../../debt/ui/widgets/debt_summary_row.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../subscription/ui/subscriptions_provider.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/data/wallet_repository.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../data/dashboard_repo.dart';
import 'dashboard_notifier.dart';

/// Room under each tab list so the last row clears the FAB.
const double _kListBottomInset = 126;

/// Dashboard: pinned total + quick links + "Wallets / Budgets / Debts" tab
/// bar; only the active tab's list scrolls (its rows dissolve under the tab
/// bar). Every tab reads providers kept alive app-wide
/// (`keepAppStateAlive`), so switching never re-queries the DB.
@RoutePage()
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final dashboard = ref.watch(dashboardProvider);
    final data = dashboard.value;
    final hasWallets = data != null && !data.isEmpty;
    final showMascot = ref.watch(showMascotProvider);

    // Recompute the derived providers shared by the header pills, the tab
    // summary and the tab pages here, before any of them builds. One flushed
    // lazily inside a child's build (e.g. `_Header` watching the debts
    // count) notifies a sibling mid-build ("setState() called during build",
    // e.g. right after saving a budget or a debt); flushed here, every
    // listener is a descendant, which Flutter allows. `select` keeps this
    // page from rebuilding on their changes.
    ref
      ..watch(dashboardBudgetsProvider.select(_ignore))
      ..watch(debtsOverviewProvider.select(_ignore))
      ..watch(dashboardDebtsProvider.select(_ignore))
      ..watch(openDebtsBadgeProvider.select(_ignore))
      ..watch(activeSubscriptionCountProvider.select(_ignore));

    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: colors.bgColor)),
        const Positioned.fill(child: UiAmbientBackground()),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: UIAppbar(
            title: l10n.dashboard_title,
            transparent: true,
            action: UIIcon(
              UIIconToken.icons.general.settings01,
              size: 22,
              onTap: () => context.router.push(const SettingsRoute()),
            ),
          ),
          floatingActionButton: hasWallets
              ? Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: UiFab(
                    heroTag: kHeroFab,
                    onTap: () {
                      final primary = ref.read(primaryWalletProvider);
                      return context.router.push(TransactionRoute(walletId: primary?.id));
                    },
                  ),
                )
              : null,
          body: Stack(
            children: [
              // Peeking mascot only once the user has a wallet, and only while
              // Settings → Show mascot is on; the empty state already shows the
              // big centred illustration.
              if (hasWallets && showMascot)
                const Positioned(left: 0, top: 12, child: UIWumbiLooksFromLeft()),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 20, kPageHorzPadding, 0),
                    child: _Header(data: data),
                  ),
                  Expanded(
                    child: switch (data) {
                      null => const _Loading(),
                      DashboardData(isEmpty: true) => const _NoWallets(),
                      _ => const _MoneyTabs(),
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.data});

  final DashboardData? data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final d = data;

    if (d == null) {
      return const SizedBox(height: 84);
    }

    final codes = d.unconvertible.map((c) => c.code).join(', ');
    final caption = [
      // Every wallet switched off: only "N not counted" (never "No wallets yet").
      if (d.countedWallets > 0 || d.excludedCount == 0) l10n.dashboard_across_wallets(d.countedWallets),
      if (d.excludedCount > 0) l10n.dashboard_wallets_excluded(d.excludedCount),
      if (d.unconvertible.isNotEmpty) l10n.dashboard_not_included(codes),
    ].join(' · ');

    return Column(
      children: [
        UiTotalAmount(money: d.total, animated: true),
        const UISpace.vert(16),
        UITap(
          onTap: d.unconvertible.isEmpty ? null : () => ref.read(dashboardProvider.notifier).retryRates(),
          child: Text(
            caption,
            textAlign: TextAlign.center,
            style: context.typo.inter.subtitle,
          ),
        ),
        if (!d.isEmpty) ...[
          const UISpace.vert(12),
          _HeaderLinks(
            subscriptionCount: ref.watch(activeSubscriptionCountProvider),
            hasDebts: ref.watch(dashboardDebtsProvider.select((debts) => debts?.hasAny ?? false)),
            openDebtCount: ref.watch(openDebtsBadgeProvider.select((b) => b.count)),
          ),
        ],
      ],
    );
  }
}

/// Small outlined pills under the total: Search, Progress, "# Tags",
/// "N Subscriptions" (only with an active rule) and "N debts" (open ones;
/// plain "Debts" once all are settled, so the settled history stays one tap
/// away — the Debts tab shows only open ones; overdue dot on its label).
class _HeaderLinks extends StatelessWidget {
  const _HeaderLinks({required this.subscriptionCount, required this.hasDebts, required this.openDebtCount});

  final int subscriptionCount;
  final bool hasDebts;
  final int openDebtCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _HeaderPill(
          icon: UIIconToken.icons.general.searchMd,
          label: l10n.search_title,
          onTap: () => context.router.push(const SearchRoute()),
        ),
        _HeaderPill(
          icon: UIIconToken.icons.charts.barChart10,
          label: l10n.progress_title,
          onTap: () => context.router.push(const ProgressRoute()),
        ),
        _HeaderPill(
          icon: UIIconToken.icons.general.hash01,
          label: l10n.dashboard_tags,
          onTap: () => context.router.push(const TagsRoute()),
        ),
        if (subscriptionCount > 0)
          _HeaderPill(
            icon: UIIconToken.icons.mediaDevices.repeat01,
            label: l10n.subscriptions_count(subscriptionCount),
            onTap: () => context.router.push(SubscriptionsRoute()),
          ),
        if (hasDebts)
          _HeaderPill(
            icon: UIIconToken.icons.financeEcommerce.coinsHand,
            label: openDebtCount > 0 ? l10n.debts_count(openDebtCount) : l10n.debts_title,
            onTap: () => context.router.push(const DebtsRoute()),
          ),
      ],
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label, required this.onTap});

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return UITap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: colors.dividerColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            UIIcon(icon, size: 14),
            Text(label, style: context.typo.inter.captionBold),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ no tabs yet

class _Loading extends StatelessWidget {
  const _Loading({this.top = 64});

  final double top;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(kListHorzPadding, top, kListHorzPadding, 0),
      children: const [UiSkeletonList()],
    );
  }
}

/// No wallet yet: the single call to action, no tabs.
class _NoWallets extends StatelessWidget {
  const _NoWallets();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 32, bottom: _kListBottomInset),
      child: UiEmptyState(
        mood: WumbiMood.pouchOpen,
        title: l10n.dashboard_empty_title,
        subtitle: l10n.dashboard_empty_subtitle,
        action: UiIconTextButton(
          icon: UIIconToken.icons.general.plusCircle,
          title: l10n.dashboard_new_wallet,
          onTap: () => context.router.push(WalletFormRoute()),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------- tabs

enum _MoneyTab { wallets, budgets, debts }

bool _ignore(Object? _) => true;

/// Tab bar, the active tab's summary + create button (fixed), and the
/// swipeable pages.
///
/// Pages are not kept alive: a page is built when it starts sliding into
/// view, so its [UIStaggerScope] cascade replays on every switch (swipe or
/// tap). Their data comes from app-wide kept-alive providers — building a
/// page never hits the DB.
class _MoneyTabs extends HookConsumerWidget {
  const _MoneyTabs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pages = usePageController();
    final index = useState(0);
    final overdue = ref.watch(openDebtsBadgeProvider.select((b) => b.overdueCount > 0));


    void select(int i) {
      if (i == index.value) return;
      AppVibrations.selection();
      index.value = i;
    }

    // Tap: neighbours slide, a two-step jump lands directly (no flash of the
    // page in between); the cascade animates either way.
    void onTabTap(int i) {
      if (i == index.value) return;
      final from = index.value;
      select(i);
      if ((i - from).abs() == 1) {
        pages.animateToPage(i, duration: UIAnim.page, curve: UIAnim.pageCurve);
      } else {
        pages.jumpToPage(i);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const UISpace.vert(28),
        UiSegmentedToggle(
          expanded: true,
          labels: [l10n.dashboard_wallets, l10n.dashboard_budgets, l10n.debts_title],
          dots: [false, false, overdue],
          selectedIndex: index.value,
          onChanged: onTabTap,
        ),
        Expanded(
          child: PageView(
            controller: pages,
            onPageChanged: select,
            children: const [_WalletsTab(), _BudgetsTab(), _DebtsTab()],
          ),
        ),
      ],
    );
  }
}

/// The active tab's summary + create button. First sliver of each tab, so it
/// scrolls with the rows.
class _TabActionBar extends StatelessWidget {
  const _TabActionBar({required this.tab});

  final _MoneyTab tab;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final String createLabel;
    final VoidCallback create;
    switch (tab) {
      case _MoneyTab.wallets:
        createLabel = l10n.dashboard_new_wallet;
        create = () => context.router.push(WalletFormRoute());
      case _MoneyTab.budgets:
        createLabel = l10n.budget_new;
        create = () => context.router.push(BudgetFormRoute());
      case _MoneyTab.debts:
        createLabel = l10n.debt_new;
        create = () => context.router.push(NewDebtRoute());
    }

    return Padding(
      // The button carries 4 px of tap padding: its edge lines up with the
      // rows' trailing edge.
      padding: const EdgeInsets.fromLTRB(kListHorzPadding, 6, kListHorzPadding - 4, 0),
      child: Row(
        children: [
          Expanded(
            child: _TabSummary(tab: tab),
          ),
          const UISpace.horz(12),
          // Short "⊕ New"; the full label stays for screen readers.
          Semantics(
            button: true,
            label: createLabel,
            excludeSemantics: true,
            child: UiIconTextButton(
              icon: UIIconToken.icons.general.plusCircle,
              title: l10n.dashboard_new,
              color: UIColorToken.blue,
              onTap: create,
            ),
          ),
        ],
      ),
    );
  }
}

/// One-line digest of the active tab, left of the create button:
/// Wallets — how to reorder (only with 2+ wallets);
/// Budgets — one sentence: over / close to the limit / within budgets;
/// Debts — what is owed each way (base currency) and the overdue count.
class _TabSummary extends ConsumerWidget {
  const _TabSummary({super.key, required this.tab});

  final _MoneyTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final style = context.typo.inter.regular.copyWith(color: UIColorToken.casper, fontSize: 12);

    final List<(String, Color?)> parts;
    switch (tab) {
      case _MoneyTab.wallets:
        final count = ref.watch(dashboardProvider.select((d) => d.value?.wallets.length ?? 0));
        parts = [if (count > 1) (l10n.dashboard_reorder_hint, null)];
      case _MoneyTab.budgets:
        final running = ref.watch(dashboardBudgetsProvider)?.running ?? const [];
        parts = [?BudgetLabels.summary(l10n, running)];
      case _MoneyTab.debts:
        final o = ref.watch(debtsOverviewProvider).value;
        final approx = o != null && o.incomplete ? '≈ ' : '';
        parts = [
          if (o != null && o.owedToMeBase.isPositive)
            (l10n.dashboard_debts_to_receive('$approx${o.owedToMeBase.format()}'), null),
          if (o != null && o.iOweBase.isPositive) (l10n.dashboard_debts_to_pay('$approx${o.iOweBase.format()}'), null),
          if (o != null && o.overdueCount > 0) (l10n.debts_overdue_count(o.overdueCount), UIColorToken.neg500),
        ];
    }

    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < parts.length; i++) ...[
            if (i > 0) const TextSpan(text: '  ·  '),
            TextSpan(
              text: parts[i].$1,
              style: parts[i].$2 == null ? null : TextStyle(color: parts[i].$2),
            ),
          ],
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

/// Scrollable body shared by the tabs: smoke edges + one-shot cascade.
/// Mounted fresh whenever its page slides into view (and once its data is
/// ready), which replays the cascade.
class _TabScroll extends StatelessWidget {
  const _TabScroll({required this.tab, required this.slivers});

  final _MoneyTab tab;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return UIStaggerScope(
      child: UIScrollEdgeFade(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(child: _TabActionBar(tab: tab)),
            ...slivers,
            const SliverToBoxAdapter(child: UISpace.vert(_kListBottomInset)),
          ],
        ),
      ),
    );
  }
}

class _TabSkeleton extends StatelessWidget {
  const _TabSkeleton();

  @override
  Widget build(BuildContext context) => const _Loading(top: 16);
}

/// Rows of a non-reorderable tab, each staggered.
class _StaggeredRows extends StatelessWidget {
  const _StaggeredRows({required this.children, this.gap = 0});

  final List<Widget> children;

  /// Space below each row.
  final double gap;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
      sliver: SliverList.builder(
        itemCount: children.length,
        itemBuilder: (context, i) => UIStaggerItem(
          index: i,
          child: Padding(padding: EdgeInsets.only(bottom: gap), child: children[i]),
        ),
      ),
    );
  }
}

/// Wallet rows: the ones counted in the total, then — under their own title —
/// the ones switched out of it ("Count in total balance" off). Long-press +
/// drag reorders within a group; the saved order is counted → not counted,
/// so the new first wallet (primary) is a counted one whenever there is one.
/// The dragged order is shown optimistically until the DB refresh (which
/// yields the same order) lands.
class _WalletsTab extends HookConsumerWidget {
  const _WalletsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final data = ref.watch(dashboardProvider).value;
    final override = useState<List<WalletSummary>?>(null);

    useEffect(() {
      override.value = null;
      return null;
    }, [data?.wallets]);

    if (data == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TabActionBar(tab: _MoneyTab.wallets),
          const Expanded(child: _TabSkeleton()),
        ],
      );
    }

    final wallets = override.value ?? data.wallets;
    final counted = [for (final w in wallets) if (w.includeInTotal) w];
    final excluded = [for (final w in wallets) if (!w.includeInTotal) w];

    Future<void> save(List<WalletSummary> next) async {
      override.value = next;
      AppVibrations.medium();
      final result = await ref.read(walletRepositoryProvider).reorder(next.map((w) => w.id).toList());
      result.whenError((e) {
        override.value = null;
        ref.read(appEventProvider).send(ShowErrorEvent(e));
      });
    }

    ReorderCallback reorderWithin(List<WalletSummary> group, {required bool isCounted}) => (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex -= 1;
          if (oldIndex == newIndex) return;
          final next = List<WalletSummary>.from(group);
          next.insert(newIndex, next.removeAt(oldIndex));
          save(isCounted ? [...next, ...excluded] : [...counted, ...next]);
        };

    Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = Curves.easeOut.transform(animation.value);
          return Transform.scale(
            scale: 1 + 0.03 * t,
            child: Material(
              color: Color.lerp(Colors.transparent, colors.fgColor, t),
              borderRadius: BorderRadius.circular(16),
              shadowColor: UIColorToken.bismark.withValues(alpha: 0.18 * t),
              elevation: 12 * t,
              child: child,
            ),
          );
        },
        child: child,
      );
    }

    // [first] = position of the group's first row in the whole tab (stagger
    // cascade, badge phase).
    Widget group(List<WalletSummary> items, {required bool isCounted, required int first}) => SliverPadding(
          // 8 px of the gutter lives inside each item so the lifted (dragged)
          // card gets a background inset around its content.
          padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding - 8),
          sliver: SliverReorderableList(
            itemCount: items.length,
            onReorder: reorderWithin(items, isCounted: isCounted),
            onReorderStart: (_) => AppVibrations.light(),
            proxyDecorator: proxyDecorator,
            itemBuilder: (context, index) {
              final w = items[index];
              final position = first + index;
              return ReorderableDelayedDragStartListener(
                key: ValueKey('wallet-${w.id}'),
                index: index,
                child: UIStaggerItem(
                  index: position,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: UiWalletCard(
                      title: w.name,
                      balance: w.balance,
                      color: w.color.color,
                      animatedBadge: true,
                      badgePhase: (position * 0.23) % 1,
                      nameHeroTag: heroWalletName(w.id),
                      balanceHeroTag: heroWalletBalance(w.id),
                      onTap: () => context.router.push(WalletDetailsRoute(walletId: w.id)),
                    ),
                  ),
                ),
              );
            },
          ),
        );

    return _TabScroll(
      tab: _MoneyTab.wallets,
      slivers: [
        if (counted.isNotEmpty) group(counted, isCounted: true, first: 0),
        if (excluded.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
            sliver: SliverToBoxAdapter(
              child: UIStaggerItem(
                index: counted.length,
                child: UiSectionLabel(
                  text: l10n.dashboard_wallets_not_counted,
                  padding: EdgeInsets.only(top: counted.isEmpty ? 4 : 20, bottom: 0),
                ),
              ),
            ),
          ),
          group(excluded, isCounted: false, first: counted.length + 1),
        ],
      ],
    );
  }
}

/// Running budgets, most urgent first (spec B&D §6.3), and "All budgets ›"
/// whenever some live budget is not running. With no budget at all, one calm
/// caption line invites to create the first one.
class _BudgetsTab extends ConsumerWidget {
  const _BudgetsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final data = ref.watch(dashboardBudgetsProvider);
    if (data == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TabActionBar(tab: _MoneyTab.budgets),
          const Expanded(child: _TabSkeleton()),
        ],
      );
    }

    return _TabScroll(
      tab: _MoneyTab.budgets,
      slivers: [
        _StaggeredRows(
          gap: 20,
          children: [
            if (data.total == 0)
              _Hint(text: l10n.budget_empty_hint, onTap: () => context.router.push(BudgetFormRoute())),
            for (final p in data.running) BudgetProgressRow(key: ValueKey('budget-${p.budget.id}'), progress: p),
            if (data.total > data.running.length)
              _AllLink(label: l10n.budgets_all, onTap: () => context.router.push(BudgetsRoute())),
          ],
        ),
      ],
    );
  }
}

/// Open debts of both sides, overdue first. The Debts page (per-side
/// totals, settled ones) is the "Debts" header pill.
class _DebtsTab extends ConsumerWidget {
  const _DebtsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final data = ref.watch(dashboardDebtsProvider);
    if (data == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TabActionBar(tab: _MoneyTab.debts),
          const Expanded(child: _TabSkeleton()),
        ],
      );
    }

    return _TabScroll(
      tab: _MoneyTab.debts,
      slivers: [
        _StaggeredRows(
          children: [
            if (data.open.isEmpty) _Hint(text: l10n.debts_empty_hint, onTap: () => context.router.push(NewDebtRoute())),
            for (final s in data.open) DebtSummaryRow(key: ValueKey('debt-${s.debt.id}'), summary: s, showSide: true),
          ],
        ),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text, style: context.typo.inter.hint),
      ),
    );
  }
}

class _AllLink extends StatelessWidget {
  const _AllLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: UITap(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Text(label, style: context.typo.inter.label.copyWith(color: UIColorToken.blue)),
              UIIcon(UIIconToken.icons.arrows.chevronRight, size: 14, color: UIColorToken.blue),
            ],
          ),
        ),
      ),
    );
  }
}
