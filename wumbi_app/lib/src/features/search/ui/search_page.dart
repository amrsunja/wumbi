import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../../core/utils/typedefs.dart';
import '../../transaction/data/models/transaction_model.dart';
import 'search_notifier.dart';

/// `/search` — one box over every wallet: description, wallet name, tag or
/// amount. Results are transaction rows; tapping one opens it.
@RoutePage()
class SearchPage extends HookConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final state = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);
    final controller = useTextEditingController();
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

    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: colors.bgColor)),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: UIAppbar(
            title: l10n.search_title,
            backTap: () => context.router.maybePop(),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 4, kPageHorzPadding, 8),
                child: UIInputField(
                  controller: controller,
                  hintText: l10n.search_placeholder,
                  autofocus: true,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.search,
                  onChanged: notifier.onQueryChanged,
                  onSubmitted: notifier.submit,
                ),
              ),
              Expanded(
                child: _Results(
                  state: state,
                  scrollController: scrollController,
                  onRetry: () => notifier.submit(controller.text),
                  onClear: () {
                    controller.clear();
                    notifier.clear();
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

class _Results extends StatelessWidget {
  const _Results({
    required this.state,
    required this.scrollController,
    required this.onClear,
    required this.onRetry,
  });

  final SearchState state;
  final ScrollController scrollController;
  final VoidCallback onClear;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (state.isIdle) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
        child: Text(
          l10n.search_hint,
          textAlign: TextAlign.center,
          style: context.typo.inter.hint,
        ),
      );
    }

    if (state.results.hasError) {
      return UiEmptyState(
        image: AppAssets.images.wumbiOo.path,
        title: l10n.error_unknown,
        action: UiTextButton(label: l10n.common_retry, fontSize: 16, onTap: onRetry),
      );
    }

    final rows = state.results.value;
    if (rows == null) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(kListHorzPadding, 16, kListHorzPadding, 0),
        child: UiSkeletonList(rows: 5),
      );
    }

    if (rows.isEmpty) {
      return UiEmptyState(
        image: AppAssets.images.wumbiOo.path,
        title: l10n.search_no_results_title,
        subtitle: l10n.search_no_results_subtitle,
        action: UiTextButton(label: l10n.common_clear, fontSize: 16, onTap: onClear),
      );
    }

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(kListHorzPadding, 4, kListHorzPadding, 4),
            child: Text(l10n.search_results_count(rows.length), style: context.typo.inter.caption),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
          sliver: SliverList.separated(
            itemCount: rows.length,
            separatorBuilder: (_, _) => const UIDivider(),
            itemBuilder: (context, index) => _ResultTile(row: rows[index]),
          ),
        ),
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
  }
}

/// Same shape as the tag page's row: results span wallets, so the wallet name
/// is the secondary line.
class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.row});

  final TransactionRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = row.transaction;
    final viewedWalletId = t.walletId ?? t.fromWalletId ?? '';

    final UiTransactionDirection direction;
    String title = t.description;
    String? walletName;
    switch (t.type) {
      case TransactionType.income:
        direction = UiTransactionDirection.income;
        if (title.isEmpty) title = l10n.common_income;
        walletName = row.walletName;
      case TransactionType.expense:
        direction = UiTransactionDirection.expense;
        if (title.isEmpty) title = l10n.common_expense;
        walletName = row.walletName;
      case TransactionType.transfer:
        final outgoing = t.fromWalletId == viewedWalletId;
        direction = outgoing ? UiTransactionDirection.transferOut : UiTransactionDirection.transferIn;
        if (title.isEmpty) {
          final name = outgoing ? row.toWalletName : row.fromWalletName;
          final deleted = outgoing ? row.toWalletDeleted : row.fromWalletDeleted;
          final label = '${name ?? '?'}${deleted ? ' ${l10n.wallet_deleted_suffix}' : ''}';
          title = outgoing ? l10n.wallet_transfer_to(label) : l10n.wallet_transfer_from(label);
        }
        walletName = outgoing ? row.fromWalletName : row.toWalletName;
    }

    return UiTransactionCard(
      title: title,
      subtitle: t.transactionDate.formatListDate(),
      amount: t.amountFor(viewedWalletId, t.currency).abs(),
      direction: direction,
      secondaryText: walletName,
      tags: row.tags,
      upcoming: t.isUpcoming,
      badge: t.isUpcoming ? l10n.transaction_upcoming_badge : null,
      onTap: () => context.router.push(
        TransactionRoute(transactionId: row.id, walletId: viewedWalletId),
      ),
    );
  }
}
