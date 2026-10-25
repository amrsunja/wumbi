import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/money/money.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/repeat_frequency.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../../core/utils/hooks/use_swipe_tabs.dart';
import '../../budget/data/models/budget_model.dart';
import '../../budget/ui/budget_labels.dart';
import '../../budget/ui/budgets_provider.dart';
import '../../budget/ui/widgets/budget_progress_row.dart';
import '../../debt/ui/debt_labels.dart';
import '../../debt/ui/debt_rows.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../subscription/ui/subscriptions_provider.dart';
import '../../subscription/ui/widgets/subscription_row.dart';
import '../../transaction/data/models/recurring_rule_model.dart';
import '../../transaction/data/models/transaction_filter.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../data/models/wallet_model.dart';
import 'wallet_details_notifier.dart';
import 'wallets_provider.dart';
import 'widgets/month_divider.dart';
import 'widgets/transaction_filter_sheet.dart';
import 'widgets/transaction_sort_sheet.dart';
import 'widgets/wallet_picker_sheet.dart';

/// Room under each tab list so the last row clears the FAB.
const double _kListBottomInset = 126;

enum _WalletTab { transactions, budgets, subscriptions }

/// Wallet Details: fixed header (wallet / currency, balance, tab bar) and
/// swipeable tab bodies — Transactions (filter / sort), Budgets scoped to
/// this wallet (+ Set a spending limit) and Subscriptions touching it.
/// Switching tab (swipe or tap) or wallet rebuilds the body, which replays
/// the row cascade; rows dissolve under the tab bar like on the Dashboard.
@RoutePage()
class WalletDetailsPage extends HookConsumerWidget {
  const WalletDetailsPage({super.key, @PathParam('id') required this.walletId});

  final String walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    // The wallet switcher replaces the page's wallet in place (same route).
    final currentId = useState(walletId);
    final id = currentId.value;
    final state = ref.watch(walletDetailsProvider(id));
    final notifier = ref.read(walletDetailsProvider(id).notifier);
    final wallets = ref.watch(walletsProvider).value ?? const <WalletSummary>[];
    final scrollController = useScrollController();
    final showMascot = ref.watch(showMascotProvider);
    final tabs = useSwipeTabs();

    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients || scrollController.positions.length != 1) return;
        final pos = scrollController.position;
        if (pos.maxScrollExtent > 0 && pos.pixels >= pos.maxScrollExtent * 0.8) {
          notifier.loadMore();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController, notifier]);

    // Seed the header from the already-loaded wallet list so the Hero flight
    // from the dashboard has its target on the very first frame.
    final wallet = state.wallet.value ?? ref.watch(walletByIdProvider(id));
    final budgetCount = ref.watch(_walletScopedBudgetsProvider(id))?.length ?? 0;
    final subscriptionCount = ref.watch(_walletRulesProvider(id))?.length ?? 0;

    Future<void> switchWallet() async {
      final picked = await WalletPickerSheet.show(
        context,
        wallets: wallets,
        title: l10n.wallet_switch_title,
        excludeId: id,
      );
      if (picked == null) return;
      currentId.value = picked.id;
    }

    return Scaffold(
      appBar: UIAppbar(
        backTap: () => context.router.maybePop(),
        action: wallet == null
            ? null
            : UIIcon(
                UIIconToken.icons.general.edit05,
                size: 22,
                onTap: () => context.router.push(WalletFormRoute(walletId: id)),
              ),
      ),
      floatingActionButton: wallet == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: UiFab(
                heroTag: kHeroFab,
                animateIn: false,
                onTap: () => context.router.push(TransactionRoute(walletId: id)),
              ),
            ),
      body: Builder(
        builder: (context) {
          if (state.wallet.hasError) {
            return UiEmptyState(mood: WumbiMood.confused, title: l10n.wallet_not_found);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fixed header: wallet / currency, balance, tabs.
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(kListHorzPadding, 8, kListHorzPadding, 15),
                    child: Column(
                      children: [
                        if (wallet != null)
                          UiWalletInfoMenu(
                            name: wallet.name,
                            color: wallet.color.color,
                            currencyType: wallet.currency,
                            walletHeroTag: heroWalletName(id),
                            onSelectWallet: wallets.length > 1 ? switchWallet : null,
                          )
                        else
                          const UISpace.vert(32),
                        const UISpace.vert(28),
                        if (wallet != null)
                          UiHero(
                            tag: heroWalletBalance(id),
                            child: UiTotalAmount(money: wallet.balance, animated: true),
                          )
                        else
                          const SizedBox(height: 54),
                        const UISpace.vert(24),
                        UiSegmentedToggle(
                          expanded: true,
                          labels: [l10n.wallet_tab_transactions, l10n.wallet_tab_budgets, l10n.wallet_tab_subscriptions],
                          counts: [null, budgetCount, subscriptionCount],
                          selectedIndex: tabs.index,
                          onChanged: tabs.onTabTap,
                        ),
                      ],
                    ),
                  ),
                  if (showMascot)
                    Positioned(
                      right: 8,
                      top: 4,
                      child: UIWumbiLook(key: ValueKey('wumbi-$id')),
                    ),
                ],
              ),
              // Swipeable tab bodies (only they scroll). Pages are not kept
              // alive, so the cascade replays on every switch; the wallet id
              // in the key remounts them after a wallet switch.
              Expanded(
                child: PageView(
                  controller: tabs.controller,
                  onPageChanged: tabs.onPageChanged,
                  children: [
                    for (final t in _WalletTab.values)
                      KeyedSubtree(
                        key: ValueKey('$id-${t.name}'),
                        child: switch (t) {
                          _WalletTab.transactions => _TransactionsTab(
                              walletId: id,
                              wallet: wallet,
                              state: state,
                              notifier: notifier,
                              controller: scrollController,
                            ),
                          _WalletTab.budgets => _BudgetsTab(walletId: id),
                          _WalletTab.subscriptions => _SubscriptionsTab(walletId: id),
                        },
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------------ tab data

/// Budgets explicitly scoped to the wallet (its `budget_wallets` contains
/// it): running ones first, most urgent first, then not started / ended.
/// Null while loading.
final _walletScopedBudgetsProvider = Provider.autoDispose.family<List<BudgetProgress>?, String>((ref, walletId) {
  final all = ref.watch(budgetsProvider).value;
  if (all == null) return null;
  final scoped = all.where((p) => p.budget.walletIds.contains(walletId));
  return [
    ...scoped.where(isRunningBudget).toList()..sort(compareBudgetSeverity),
    ...scoped.where((p) => !isRunningBudget(p)),
  ];
});

/// Every non-deleted rule touching the wallet (active first). Null while
/// loading.
final _walletRulesProvider = Provider.autoDispose.family<List<RecurringRuleModel>?, String>((ref, walletId) {
  final rules = ref.watch(subscriptionsProvider).value;
  return rules?.where((r) => ruleTouchesWallet(r, walletId)).toList();
});

// --------------------------------------------------------------------- tabs

/// Scrollable tab body: smoke edges + one-shot cascade. [ready] flips once
/// the data has loaded so the cascade plays on the real rows, not on the
/// skeleton.
class _TabScroll extends StatelessWidget {
  const _TabScroll({
    required this.ready,
    required this.slivers,
    this.controller,
    this.bottomInset = true,
    this.topFade = 32,
  });

  final bool ready;
  final List<Widget> slivers;
  final ScrollController? controller;

  /// Room for the FAB under the last row. Off for a centred empty state
  /// ([SliverFillRemaining]), which must not scroll.
  final bool bottomInset;

  /// 0 for lists with sticky month headers: the pinned header is the edge.
  final double topFade;

  @override
  Widget build(BuildContext context) {
    return UIStaggerScope(
      key: ValueKey(ready),
      child: UIScrollEdgeFade(
        top: topFade,
        child: CustomScrollView(
          controller: controller,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            const SliverToBoxAdapter(child: UISpace.vert(4)),
            ...slivers,
            if (bottomInset) const SliverToBoxAdapter(child: UISpace.vert(_kListBottomInset)),
          ],
        ),
      ),
    );
  }
}

/// Fixed row above a tab list: summary on the left, optional action right.
class _TabHeader extends StatelessWidget {
  const _TabHeader({this.summary, this.action});

  final Widget? summary;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    if (summary == null && action == null) return const UISpace.vert(8);
    return Padding(
      // The button carries 4 px of tap padding: its edge lines up with the
      // rows' trailing edge.
      padding: const EdgeInsets.fromLTRB(kListHorzPadding, 6, kListHorzPadding - 4, 0),
      child: Row(
        children: [
          Expanded(child: summary ?? const SizedBox.shrink()),
          if (action != null) ...[const UISpace.horz(12), action!],
        ],
      ),
    );
  }
}

class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab({
    required this.walletId,
    required this.wallet,
    required this.state,
    required this.notifier,
    required this.controller,
  });

  final String walletId;
  final WalletSummary? wallet;
  final WalletDetailsState state;
  final WalletDetailsNotifier notifier;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    Future<void> openFilter() async {
      final picked = await TransactionFilterSheet.show(context, initial: state.filter);
      if (picked == null) return;
      await notifier.setFilter(picked);
    }

    Future<void> openSort() async {
      final picked = await TransactionSortSheet.show(context, selected: state.sort);
      if (picked == null) return;
      await notifier.setSort(picked);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(kListHorzPadding, 8, kListHorzPadding, 0),
          child: _ListToolbar(
            filter: state.filter,
            sort: state.sort,
            onFilterTap: openFilter,
            onSortTap: openSort,
            onClear: notifier.clearFilter,
          ),
        ),
        Expanded(
          child: _TabScroll(
            ready: state.transactions.value != null && wallet != null,
            controller: controller,
            // Sticky headers whenever the list is sectioned (upcoming group
            // or date sort); the plain amount-sorted list keeps the fade.
            topFade: _TransactionList.hasSections(state) ? 0 : 32,
            slivers: [
              ..._TransactionList(
                walletId: walletId,
                wallet: wallet,
                state: state,
                notifier: notifier,
              ).slivers(context),
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
        ),
      ],
    );
  }
}

/// Budgets scoped to this wallet + "⊕ Set a spending limit".
class _BudgetsTab extends ConsumerWidget {
  const _BudgetsTab({required this.walletId});

  final String walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final budgets = ref.watch(_walletScopedBudgetsProvider(walletId));
    final parts = <(String, Color?)>[?BudgetLabels.summary(l10n, budgets ?? const [])];

    return _TabScroll(
      ready: budgets != null,
      bottomInset: budgets != null && budgets.isNotEmpty,
      slivers: [
        SliverToBoxAdapter(
          child: _TabHeader(
            summary: parts.isEmpty
                ? null
                : Text.rich(
                    TextSpan(
                      children: [
                        for (var i = 0; i < parts.length; i++) ...[
                          if (i > 0) const TextSpan(text: '  ·  '),
                          TextSpan(
                            text: parts[i].$1.toUpperCase(),
                            style: parts[i].$2 == null ? null : TextStyle(color: parts[i].$2),
                          ),
                        ],
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typo.inter.sectionLabel,
                  ),
            action: UiIconTextButton(
              icon: UIIconToken.icons.general.plusCircle,
              title: l10n.budget_set_limit,
              color: UIColorToken.blue,
              onTap: () => context.router.push(BudgetFormRoute(walletId: walletId)),
            ),
          ),
        ),
        if (budgets == null)
          const SliverToBoxAdapter(child: _TabSkeleton())
        else if (budgets.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: UIStaggerItem(
              index: 0,
              child: UiEmptyState(
                mood: WumbiMood.sleep,
                title: l10n.wallet_budgets_empty,
                subtitle: l10n.wallet_budgets_empty_subtitle,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
            sliver: SliverList.builder(
              itemCount: budgets.length,
              itemBuilder: (context, i) => UIStaggerItem(
                key: ValueKey('budget-${budgets[i].budget.id}'),
                index: i,
                child: BudgetProgressRow(progress: budgets[i]),
              ),
            ),
          ),
      ],
    );
  }
}

/// Every subscription touching this wallet (pause switch; stop from the
/// edit page).
class _SubscriptionsTab extends ConsumerWidget {
  const _SubscriptionsTab({required this.walletId});

  final String walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final rules = ref.watch(_walletRulesProvider(walletId));
    final wallets = ref.watch(walletsProvider).value ?? const <WalletSummary>[];
    final walletsById = <String, WalletSummary>{for (final w in wallets) w.id: w};
    final monthly = ref.watch(monthlySubscriptionTotalProvider(walletId)).value;
    final tagsByRule = ref.watch(subscriptionTagsProvider).value ?? const <String, List<String>>{};

    return _TabScroll(
      ready: rules != null,
      bottomInset: rules != null && rules.isNotEmpty,
      slivers: [
        SliverToBoxAdapter(
          child: _TabHeader(
            action: UiIconTextButton(
              icon: UIIconToken.icons.general.plusCircle,
              title: l10n.subscriptions_new,
              color: UIColorToken.blue,
              onTap: () => context.router.push(TransactionRoute(walletId: walletId, repeat: RepeatFrequency.monthly)),
            ),
            summary: monthly == null || monthly.isZero
                ? null
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      l10n.subscriptions_monthly_total(monthly.format()).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typo.inter.sectionLabel,
                    ),
                  ),
          ),
        ),
        if (rules == null)
          const SliverToBoxAdapter(child: _TabSkeleton())
        else if (rules.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: UIStaggerItem(
              index: 0,
              child: UiEmptyState(
                mood: WumbiMood.sleep,
                title: l10n.subscriptions_empty_title,
                subtitle: l10n.subscriptions_empty_subtitle,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
            sliver: SliverList.builder(
              itemCount: rules.length,
              itemBuilder: (context, i) {
                final r = rules[i];
                return UIStaggerItem(
                  key: ValueKey('rule-${r.id}'),
                  index: i,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SubscriptionRow(
                        rule: r,
                        walletsById: walletsById,
                        tags: tagsByRule[r.id] ?? const [],
                        showWallet: false,
                        onTap: () => context.router.push(TransactionRoute(ruleId: r.id)),
                        onToggle: (v) => ref.read(subscriptionsProvider.notifier).setActive(r.id, v),
                      ),
                      if (i + 1 < rules.length) const UIDivider(),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _TabSkeleton extends StatelessWidget {
  const _TabSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(kListHorzPadding, 16, kListHorzPadding, 0),
      children: const [UiSkeletonList(rows: 4)],
    );
  }
}

/// Filter (left, with an active-count pill) and Sort (right, current label).
class _ListToolbar extends StatelessWidget {
  const _ListToolbar({
    required this.filter,
    required this.sort,
    required this.onFilterTap,
    required this.onSortTap,
    required this.onClear,
  });

  final TransactionFilter filter;
  final TransactionSort sort;
  final VoidCallback onFilterTap;
  final VoidCallback onSortTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final active = filter.activeCount > 0;

    // The sort button takes whatever is left and may ellipsise its label; the
    // filter button keeps its natural width (it is a plain Row child, so it
    // must not contain a Flexible).
    return Row(
      children: [
        _ToolbarButton(
          icon: UIIconToken.icons.general.filterLines,
          label: l10n.wallet_filter,
          active: active,
          count: active ? filter.activeCount : null,
          onTap: onFilterTap,
        ),
        if (active) ...[
          const UISpace.horz(4),
          UITap(
            onTap: onClear,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Text(
                l10n.common_clear,
                style: context.typo.inter.caption.copyWith(color: UIColorToken.blue),
              ),
            ),
          ),
        ],
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _ToolbarButton(
              icon: UIIconToken.icons.arrows.switchVertical01,
              label: transactionSortLabel(l10n, sort),
              shrinkLabel: true,
              onTap: onSortTap,
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.count,
    this.shrinkLabel = false,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final int? count;

  /// Ellipsise the label when the parent gives bounded width (only valid
  /// inside a flex child / Align — never as a bare Row child).
  final bool shrinkLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    final color = active ? UIColorToken.blue : colors.secondContentColor;

    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: typo.label.copyWith(color: active ? UIColorToken.blue : null),
    );

    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            UIIcon(icon, size: 16, color: color),
            if (shrinkLabel) Flexible(child: text) else text,
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: UIColorToken.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: typo.micro.copyWith(color: UIColorToken.white, letterSpacing: 0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- list items

/// Builds the Transactions tab's slivers: an "Upcoming" section, then one
/// section per month (date sorts only), each with a sticky header
/// ([SliverStickySection]). Amount sorts list past rows without months.
/// Returned as a list so every section is a direct child of the scroll view
/// (sections must not be nested in another group).
class _TransactionList {
  const _TransactionList({
    required this.walletId,
    required this.wallet,
    required this.state,
    required this.notifier,
  });

  final String walletId;
  final WalletSummary? wallet;
  final WalletDetailsState state;
  final WalletDetailsNotifier notifier;

  /// True when the loaded list will render at least one sticky header.
  static bool hasSections(WalletDetailsState state) {
    final rows = state.transactions.value;
    if (rows == null || rows.isEmpty) return false;
    return !state.sort.byAmount || rows.any((r) => r.transaction.isUpcoming);
  }

  List<Widget> slivers(BuildContext context) {
    final l10n = context.l10n;
    final rows = state.transactions.value;
    final wallet = this.wallet;

    if (rows == null || wallet == null) {
      return const [
        SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.symmetric(horizontal: kListHorzPadding), child: UiSkeletonList(rows: 5)),
        ),
      ];
    }

    if (rows.isEmpty) {
      if (state.filter.isEmpty) {
        return [
          SliverToBoxAdapter(
            child: UiEmptyState(
              mood: WumbiMood.pouchOpen,
              title: l10n.wallet_empty_title,
              subtitle: l10n.wallet_empty_subtitle,
            ),
          ),
        ];
      }
      return [
        SliverToBoxAdapter(
          child: UiEmptyState(
            mood: WumbiMood.searching,
            title: l10n.wallet_filter_no_results_title,
            subtitle: l10n.wallet_filter_no_results_subtitle,
            action: UiTextButton(
              label: l10n.wallet_filter_clear,
              fontSize: 16,
              onTap: notifier.clearFilter,
            ),
          ),
        ),
      ];
    }

    // The datasource already orders upcoming rows first.
    final upcoming = rows.where((r) => r.transaction.isUpcoming).toList();
    final past = rows.where((r) => !r.transaction.isUpcoming).toList();

    var stagger = 0;

    // Rows with hairlines between them; stagger indices continue across
    // sections so the cascade reads top to bottom.
    Widget rowList(List<TransactionRow> list) {
      final first = stagger;
      stagger += list.length;
      return SliverList.separated(
        itemCount: list.length,
        separatorBuilder: (_, _) => const UIDivider(),
        itemBuilder: (context, i) {
          final row = list[i];
          return UIStaggerItem(
            key: ValueKey('row-${row.id}'),
            index: first + i,
            child: _TransactionTile(
              row: row,
              wallet: wallet,
              onTap: () => openTransactionRow(context, row, walletId: walletId),
            ),
          );
        },
      );
    }

    Widget section(String key, MonthDivider header, List<TransactionRow> list) {
      final headerIndex = stagger++;
      return SliverStickySection(
        key: ValueKey(key),
        header: UIStaggerItem(index: headerIndex, child: header),
        sliver: rowList(list),
      );
    }

    final slivers = <Widget>[
      if (upcoming.isNotEmpty)
        section(
          'upcoming',
          MonthDivider(label: l10n.wallet_upcoming_section, caption: l10n.wallet_upcoming_hint(upcoming.length)),
          upcoming,
        ),
    ];

    if (past.isEmpty) return slivers;

    if (state.sort.byAmount) {
      slivers.add(
        SliverPadding(
          key: const ValueKey('by-amount'),
          padding: EdgeInsets.fromLTRB(kListHorzPadding, upcoming.isEmpty ? 0 : 8, kListHorzPadding, 0),
          sliver: rowList(past),
        ),
      );
      return slivers;
    }

    final months = <(DateTime, List<TransactionRow>)>[];
    for (final row in past) {
      final date = row.transaction.transactionDate.toLocal();
      if (months.isEmpty || !months.last.$1.isSameMonth(date)) {
        months.add((date.monthStart, [row]));
      } else {
        months.last.$2.add(row);
      }
    }
    for (final (month, list) in months) {
      slivers.add(
        section('month-${month.year}-${month.month}', MonthDivider(label: month.formatMonthYear()), list),
      );
    }
    return slivers;
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.row, required this.wallet, required this.onTap});

  final TransactionRow row;
  final WalletSummary wallet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = row.transaction;

    final UiTransactionDirection direction;
    String title = t.description;
    if (title.isEmpty) title = DebtLabels.rowTitle(l10n, row) ?? '';
    switch (t.type) {
      case TransactionType.income:
        direction = UiTransactionDirection.income;
        if (title.isEmpty) title = l10n.common_income;
      case TransactionType.expense:
        direction = UiTransactionDirection.expense;
        if (title.isEmpty) title = l10n.common_expense;
      case TransactionType.transfer:
        final outgoing = t.fromWalletId == wallet.id;
        direction = outgoing ? UiTransactionDirection.transferOut : UiTransactionDirection.transferIn;
        if (title.isEmpty) {
          final name = outgoing ? row.toWalletName : row.fromWalletName;
          final deleted = outgoing ? row.toWalletDeleted : row.fromWalletDeleted;
          final label = '${name ?? '?'}${deleted ? ' ${l10n.wallet_deleted_suffix}' : ''}';
          title = outgoing ? l10n.wallet_transfer_to(label) : l10n.wallet_transfer_from(label);
        }
    }

    final amount = t.amountFor(wallet.id, wallet.currency).abs();
    final original = t.original;
    String? secondary;
    if (original != null && t.exchangeRate != null) {
      secondary = '${original.formatWithCode()} @ ${_rate(t.exchangeRate!)}';
    } else if (t.isTransfer && t.exchangeRate != null && t.fromWalletId != wallet.id) {
      // Incoming cross-currency transfer: show what was sent.
      secondary = '${Money(t.fromAmountMinor ?? 0, t.currency).formatWithCode()} @ ${_rate(t.exchangeRate!)}';
    }

    return UiTransactionCard(
      title: title,
      subtitle: t.transactionDate.formatListDate(),
      amount: amount,
      direction: direction,
      secondaryText: secondary,
      tags: row.tags,
      upcoming: t.isUpcoming,
      badge: t.isUpcoming ? l10n.transaction_upcoming_badge : DebtLabels.rowBadge(l10n, row),
      onTap: onTap,
    );
  }

  static String _rate(double r) {
    var s = r.toStringAsFixed(4);
    if (s.contains('.')) s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return s;
  }
}
