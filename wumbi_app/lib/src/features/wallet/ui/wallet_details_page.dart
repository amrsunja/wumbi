import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/money/money.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/debt_role.dart';
import '../../../core/utils/enums/repeat_frequency.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../../core/utils/typedefs.dart';
import '../../budget/data/budget_metrics.dart';
import '../../budget/data/models/budget_model.dart';
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
const double _kListBottomInset = 96;

enum _WalletTab { transactions, budgets, subscriptions }

/// Wallet Details: fixed header (wallet / currency, balance, tab bar) and one
/// scrollable tab body — Transactions (filter / sort, swipe to delete),
/// Budgets scoped to this wallet (+ Set a spending limit) and Subscriptions
/// touching it. Switching tab (or wallet) remounts the body, which replays
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
    final tabIndex = useState(0);
    final tab = _WalletTab.values[tabIndex.value];

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

    void selectTab(int i) {
      if (i == tabIndex.value) return;
      AppVibrations.selection();
      tabIndex.value = i;
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
            return UiEmptyState(image: AppAssets.images.wumbiOo.path, title: l10n.wallet_not_found);
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
                          selectedIndex: tabIndex.value,
                          onChanged: selectTab,
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
              // Only the tab body scrolls. A new key (tab or wallet) remounts
              // it and replays the cascade.
              Expanded(
                child: KeyedSubtree(
                  key: ValueKey('$id-${tab.name}'),
                  child: switch (tab) {
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
  const _TabScroll({required this.ready, required this.slivers, this.controller, this.bottomInset = true});

  final bool ready;
  final List<Widget> slivers;
  final ScrollController? controller;

  /// Room for the FAB under the last row. Off for a centred empty state
  /// ([SliverFillRemaining]), which must not scroll.
  final bool bottomInset;

  @override
  Widget build(BuildContext context) {
    return UIStaggerScope(
      key: ValueKey(ready),
      child: UIScrollEdgeFade(
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
            slivers: [
              _TransactionList(walletId: walletId, wallet: wallet, state: state, notifier: notifier),
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
    final over = budgets?.where((p) => p.status == BudgetStatus.over).length ?? 0;
    final atRisk = budgets?.where((p) => p.status == BudgetStatus.atRisk).length ?? 0;
    final running = budgets?.where(isRunningBudget).length ?? 0;

    final parts = <(String, Color?)>[
      if (over > 0) (l10n.dashboard_budgets_over(over), UIColorToken.neg500),
      if (atRisk > 0) (l10n.dashboard_budgets_at_risk(atRisk), UIColorToken.buttercup),
      if (running > 0 && over == 0 && atRisk == 0) (l10n.dashboard_budgets_on_track, null),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TabHeader(
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
        Expanded(
          child: budgets == null
              ? const _TabSkeleton()
              : _TabScroll(
                  ready: true,
                  bottomInset: budgets.isNotEmpty,
                  slivers: [
                    if (budgets.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: UIStaggerItem(
                          index: 0,
                          child: UiEmptyState(
                            image: AppAssets.images.wumbiOo.path,
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
                ),
        ),
      ],
    );
  }
}

/// Every subscription touching this wallet (pause switch, stop).
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TabHeader(
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
        Expanded(
          child: rules == null
              ? const _TabSkeleton()
              : _TabScroll(
                  ready: true,
                  bottomInset: rules.isNotEmpty,
                  slivers: [
                    if (rules.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: UIStaggerItem(
                          index: 0,
                          child: UiEmptyState(
                            image: AppAssets.images.wumbiOo.path,
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
                                    onTap: () => context.router.push(TransactionRoute(ruleId: r.id)),
                                    onToggle: (v) => ref.read(subscriptionsProvider.notifier).setActive(r.id, v),
                                    onDelete: () => confirmStopSubscription(context, ref, r),
                                  ),
                                  if (i + 1 < rules.length) const UIDivider(),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
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

/// One flat, heterogeneous sliver: group headers, month dividers and rows.
/// Keys are derived from the item (row id / month) so swipe-to-delete state
/// survives reloads.
sealed class _ListItem {
  const _ListItem();
}

class _UpcomingHeaderItem extends _ListItem {
  const _UpcomingHeaderItem(this.count);

  final int count;
}

class _MonthItem extends _ListItem {
  const _MonthItem(this.month);

  /// First instant of the month (local).
  final DateTime month;
}

class _RowItem extends _ListItem {
  const _RowItem(this.row);

  final TransactionRow row;
}

class _TransactionList extends StatelessWidget {
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

  /// The datasource already orders upcoming rows first; groups are formed
  /// while iterating. Month dividers only make sense for date sorts.
  static List<_ListItem> _buildItems(List<TransactionRow> rows, TransactionSort sort) {
    final items = <_ListItem>[];
    final upcomingCount = rows.where((r) => r.transaction.isUpcoming).length;
    var upcomingHeaderAdded = false;
    DateTime? lastMonth;

    for (final row in rows) {
      final t = row.transaction;
      if (t.isUpcoming) {
        if (!upcomingHeaderAdded) {
          items.add(_UpcomingHeaderItem(upcomingCount));
          upcomingHeaderAdded = true;
        }
        items.add(_RowItem(row));
        continue;
      }
      if (!sort.byAmount) {
        final date = t.transactionDate.toLocal();
        if (lastMonth == null || !lastMonth.isSameMonth(date)) {
          items.add(_MonthItem(date.monthStart));
          lastMonth = date;
        }
      }
      items.add(_RowItem(row));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = state.transactions.value;

    if (rows == null || wallet == null) {
      return const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.symmetric(horizontal: kListHorzPadding), child: UiSkeletonList(rows: 5)),
      );
    }

    if (rows.isEmpty) {
      if (state.filter.isEmpty) {
        return SliverToBoxAdapter(
          child: UiEmptyState(
            image: AppAssets.images.wumbiTakeMoney.path,
            title: l10n.wallet_empty_title,
            subtitle: l10n.wallet_empty_subtitle,
          ),
        );
      }
      return SliverToBoxAdapter(
        child: UiEmptyState(
          image: AppAssets.images.wumbiOo.path,
          title: l10n.wallet_filter_no_results_title,
          subtitle: l10n.wallet_filter_no_results_subtitle,
          action: UiTextButton(
            label: l10n.wallet_filter_clear,
            fontSize: 16,
            onTap: notifier.clearFilter,
          ),
        ),
      );
    }

    final items = _buildItems(rows, state.sort);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
      sliver: SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          // Hairline only between two consecutive rows, never before a header.
          final hairline = index + 1 < items.length && items[index + 1] is _RowItem;
          final Widget child = switch (item) {
            _UpcomingHeaderItem(:final count) => MonthDivider(
                key: const ValueKey('upcoming-header'),
                label: l10n.wallet_upcoming_section,
                caption: l10n.wallet_upcoming_hint(count),
              ),
            _MonthItem(:final month) => MonthDivider(
                key: ValueKey('month-${month.year}-${month.month}'),
                label: month.formatMonthYear(),
              ),
            _RowItem(:final row) => Column(
                key: ValueKey('row-${row.id}'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SwipeToDelete(
                    id: row.id,
                    onDelete: () {
                      AppVibrations.heavy();
                      notifier.deleteTransaction(
                        row,
                        message: (cascaded) => switch (row.debtRole) {
                          DebtRole.principal => l10n.debt_cascade_deleted(cascaded),
                          DebtRole.repayment => l10n.debt_return_deleted,
                          null => l10n.transaction_deleted,
                        },
                        undoLabel: l10n.common_undo,
                      );
                    },
                    child: _TransactionTile(
                      row: row,
                      wallet: wallet!,
                      onTap: () => openTransactionRow(context, row, walletId: walletId),
                    ),
                  ),
                  if (hairline) const UIDivider(),
                ],
              ),
          };
          return UIStaggerItem(key: child.key, index: index, child: child);
        },
      ),
    );
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

/// Swipe left → red background with trash icon; release → delete immediately.
class _SwipeToDelete extends StatelessWidget {
  const _SwipeToDelete({required this.id, required this.child, required this.onDelete});

  final String id;
  final Widget child;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('swipe-$id'),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {DismissDirection.endToStart: 0.35},
      resizeDuration: const Duration(milliseconds: 250),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: UIColorToken.red, borderRadius: BorderRadius.circular(12)),
        child: UIIcon(UIIconToken.icons.general.trash01, color: UIColorToken.white, size: 22),
      ),
      child: child,
    );
  }
}
