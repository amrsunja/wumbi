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
import '../../transaction/data/models/transaction_model.dart';
import '../data/models/wallet_model.dart';
import 'wallet_details_notifier.dart';
import 'wallets_provider.dart';
import 'widgets/recurring_rules_sheet.dart';
import 'widgets/wallet_picker_sheet.dart';

@RoutePage()
class WalletDetailsPage extends HookConsumerWidget {
  const WalletDetailsPage({super.key, @PathParam('id') required this.walletId});

  final String walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;

    // The wallet switcher replaces the page's wallet in place (same route).
    final currentId = useState(walletId);
    final id = currentId.value;
    final state = ref.watch(walletDetailsProvider(id));
    final notifier = ref.read(walletDetailsProvider(id).notifier);
    final wallets = ref.watch(walletsProvider).value ?? const <WalletSummary>[];
    final scrollController = useScrollController();

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
      body: Stack(
        children: [
          Positioned(right: 0, top: 4, child: UIFiinLooksFromRight(key: ValueKey('fiin-$id'))),
          if (state.wallet.hasError)
            UiEmptyState(image: AppAssets.images.fiinOo.path, title: l10n.wallet_not_found)
          else
            CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
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
                            onTap: () => RecurringRulesSheet.show(
                              context,
                              walletId: id,
                              walletCurrency: wallet?.currency ?? activeRules.first.currency,
                              rules: state.rules,
                              onToggle: notifier.setRuleActive,
                              onDelete: notifier.deleteRule,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 4,
                              children: [
                                UIIcon(UIIconToken.icons.mediaDevices.repeat01, size: 14, color: colors.secondContentColor),
                                Flexible(
                                  child: Text(
                                    '${l10n.wallet_repeating_summary(activeRules.length)} · '
                                    '${activeRules.map((r) => r.description.isEmpty ? _typeName(context, r.type) : r.description).join(', ')}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: UITextStyleToken.caption(colors),
                                  ),
                                ),
                                UIIcon(UIIconToken.icons.arrows.chevronRight, size: 14, color: colors.secondContentColor),
                              ],
                            ),
                          ),
                        ],
                        const UISpace.vert(28),
                      ],
                    ),
                  ),
                ),
                _TransactionList(walletId: id, wallet: wallet, state: state, notifier: notifier),
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                    ),
                  ),
                const SliverToBoxAdapter(child: UISpace.vert(96)),
              ],
            ),
        ],
      ),
    );
  }

  static String _typeName(BuildContext context, TransactionType type) => switch (type) {
        TransactionType.income => context.l10n.common_income,
        TransactionType.expense => context.l10n.common_expense,
        TransactionType.transfer => context.l10n.common_transfer,
      };
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
      return SliverToBoxAdapter(
        child: UiEmptyState(
          image: AppAssets.images.fiinTakeMoney.path,
          title: l10n.wallet_empty_title,
          subtitle: l10n.wallet_empty_subtitle,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
      sliver: SliverList.separated(
        itemCount: rows.length,
        separatorBuilder: (_, _) => const UIDivider(color: UIColorToken.athensGray),
        itemBuilder: (context, index) {
          final row = rows[index];
          return _SwipeToDelete(
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
          );
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
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: UIColorToken.red, borderRadius: BorderRadius.circular(12)),
        child: UIIcon(UIIconToken.icons.general.trash01, color: UIColorToken.white, size: 22),
      ),
      child: child,
    );
  }
}
