import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/money/money.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../../core/utils/typedefs.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../transaction/data/models/transaction_filter.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../data/models/wallet_model.dart';
import 'wallet_details_notifier.dart';
import 'wallets_provider.dart';
import 'widgets/month_divider.dart';
import 'widgets/transaction_filter_sheet.dart';
import 'widgets/transaction_sort_sheet.dart';
import 'widgets/wallet_picker_sheet.dart';

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

    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) return;
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
    final activeRules = state.rules.where((r) => r.isActive).toList();

    Future<void> switchWallet() async {
      final picked = await WalletPickerSheet.show(
        context,
        wallets: wallets,
        title: l10n.wallet_switch_title,
        excludeId: id,
      );
      if (picked == null) return;
      currentId.value = picked.id;
      if (scrollController.hasClients) scrollController.jumpTo(0);
    }

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
          return CustomScrollView(
            controller: scrollController,
            slivers: [
              // The mascot lives inside the header sliver, so it scrolls away
              // with the header instead of floating over the list.
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(kListHorzPadding, 8, kListHorzPadding, 0),
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
                          if (activeRules.isNotEmpty) ...[
                            const UISpace.vert(10),
                            UITap(
                              onTap: () => context.router.push(SubscriptionsRoute(walletId: id)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 4,
                                children: [
                                  UIIcon(UIIconToken.icons.mediaDevices.repeat01, size: 14),
                                  Text(
                                    l10n.subscriptions_count(activeRules.length),
                                    style: context.typo.inter.caption,
                                  ),
                                  UIIcon(UIIconToken.icons.arrows.chevronRight, size: 14),
                                ],
                              ),
                            ),
                          ],
                          const UISpace.vert(24),
                          _ListToolbar(
                            filter: state.filter,
                            sort: state.sort,
                            onFilterTap: openFilter,
                            onSortTap: openSort,
                            onClear: notifier.clearFilter,
                          ),
                          const UISpace.vert(4),
                        ],
                      ),
                    ),
                    if (showMascot)
                      Positioned(
                        right: 8,
                        top: 4,
                        child: UIWumbiLook(key: ValueKey('wumbi-$id'), height: 64),
                      ),
                  ],
                ),
              ),
              _TransactionList(walletId: id, wallet: wallet, state: state, notifier: notifier),
              if (state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: UISpace.vert(96)),
            ],
          );
        },
      ),
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
          return switch (item) {
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
                      notifier.deleteTransaction(row, message: l10n.transaction_deleted, undoLabel: l10n.common_undo);
                    },
                    child: _TransactionTile(
                      row: row,
                      wallet: wallet!,
                      onTap: () => context.router.push(TransactionRoute(transactionId: row.id, walletId: walletId)),
                    ),
                  ),
                  if (hairline) const UIDivider(),
                ],
              ),
          };
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
      badge: t.isUpcoming ? l10n.transaction_upcoming_badge : null,
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
