import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../data/models/tag_stats.dart';
import 'tag_details_notifier.dart';
import 'widgets/tag_rename_sheet.dart';

/// `/tags/:id` — totals, wallets and every transaction carrying the tag.
@RoutePage()
class TagDetailsPage extends HookConsumerWidget {
  const TagDetailsPage({super.key, @PathParam('id') required this.tagId});

  final String tagId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(tagDetailsProvider(tagId));
    final notifier = ref.read(tagDetailsProvider(tagId).notifier);
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

    // Deleted / merged underneath us (another screen, undo, …): say so and leave.
    useEffect(() {
      if (!state.notFound) return null;
      Future.microtask(() {
        if (!context.mounted) return;
        ref.read(appEventProvider).send(ShowInfoMessageEvent(l10n.tag_not_found));
        context.router.maybePop();
      });
      return null;
    }, [state.notFound]);

    final stats = state.stats.value;
    final name = stats?.name ?? '';

    Future<void> rename() async {
      if (stats == null) return;
      final newName = await TagRenameSheet.show(context, initialName: stats.name);
      if (newName == null || !context.mounted) return;
      final tag = await notifier.rename(newName);
      if (tag == null || !context.mounted) return;
      final events = ref.read(appEventProvider);
      if (tag.id != tagId) {
        events.send(ShowInfoMessageEvent(l10n.tag_merged(tag.displayName)));
        context.router.replace(TagDetailsRoute(tagId: tag.id));
      } else {
        events.send(ShowInfoMessageEvent(l10n.tag_renamed));
      }
    }

    Future<void> delete() async {
      if (stats == null) return;
      final ok = await UIAlertDialog.confirm(
        context,
        title: l10n.tag_delete_title(stats.name),
        message: l10n.tag_delete_message,
        confirmLabel: l10n.common_delete,
        cancelLabel: l10n.common_cancel,
        destructive: true,
      );
      if (!ok || !context.mounted) return;
      AppVibrations.heavy();
      final deleted = await notifier.delete();
      if (!deleted || !context.mounted) return;
      ref.read(appEventProvider).send(ShowInfoMessageEvent(l10n.tag_deleted));
      context.router.maybePop();
    }

    return Scaffold(
      appBar: _TagAppBar(
        title: name.isEmpty ? '' : '#$name',
        onBack: () => context.router.maybePop(),
        onEdit: stats == null ? null : rename,
        onDelete: stats == null ? null : delete,
      ),
      body: state.notFound
          ? const SizedBox.shrink()
          : CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 12, kPageHorzPadding, 0),
                    child: _Header(stats: state.stats),
                  ),
                ),
                if (state.wallets.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: UiSectionLabel(
                      text: l10n.tag_wallets,
                      padding: const EdgeInsets.fromLTRB(kListHorzPadding, 28, kListHorzPadding, 4),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding - 4),
                    sliver: SliverList.separated(
                      itemCount: state.wallets.length,
                      separatorBuilder: (_, _) => const UIDivider(),
                      itemBuilder: (context, index) => _WalletRow(sum: state.wallets[index]),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: UiSectionLabel(
                    text: l10n.tag_transactions,
                    padding: const EdgeInsets.fromLTRB(kListHorzPadding, 28, kListHorzPadding, 4),
                  ),
                ),
                _TransactionList(transactions: state.transactions),
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: UISpace.vert(64)),
              ],
            ),
    );
  }
}

// ------------------------------------------------------------------ app bar

/// Same metrics as `UIAppbar` (60 px, 44 px slots, overline title) with two
/// trailing actions; an empty slot after the back arrow keeps the title
/// centred.
class _TagAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TagAppBar({
    required this.title,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Size get preferredSize => const Size(double.infinity, 60);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget slot(Widget? child) => SizedBox(width: 44, height: 44, child: child == null ? null : Center(child: child));

    return Container(
      color: colors.bgColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              slot(UIIcon(UIIconToken.icons.arrows.arrowNarrowLeft, size: 24, onTap: onBack)),
              slot(null),
              Expanded(
                child: Center(
                  child: Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typo.inter.overline,
                  ),
                ),
              ),
              slot(onEdit == null ? null : UIIcon(UIIconToken.icons.general.edit02, size: 22, onTap: onEdit)),
              slot(
                onDelete == null
                    ? null
                    : UIIcon(UIIconToken.icons.general.trash01, size: 22, color: UIColorToken.neg500, onTap: onDelete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------- header

class _Header extends StatelessWidget {
  const _Header({required this.stats});

  final AsyncValue<TagStats> stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    final s = stats.value;

    if (s == null) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(8, 12, 8, 0),
        child: UiSkeletonList(rows: 2),
      );
    }

    final net = s.net;
    final netColor = net.isNegative
        ? colors.expenseColor
        : net.isPositive
            ? UIColorToken.blue
            : colors.contentColor;

    final codes = s.unconvertible.map((c) => c.code).join(', ');
    final caption = s.unconvertible.isEmpty
        ? l10n.tags_usage(s.transactionCount)
        : '${l10n.tags_usage(s.transactionCount)} · ${l10n.tags_not_included(codes)}';

    return Column(
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: _StatTile(
                label: l10n.tags_spent,
                value: '-${s.expense.format()}',
                color: colors.expenseColor,
              ),
            ),
            Expanded(
              child: _StatTile(
                label: l10n.tags_earned,
                value: '+${s.income.format()}',
                color: UIColorToken.blue,
              ),
            ),
            Expanded(
              child: _StatTile(
                label: l10n.tags_net,
                value: net.format(signed: true, positiveSign: true),
                color: netColor,
              ),
            ),
          ],
        ),
        const UISpace.vert(12),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: typo.caption,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

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
              value,
              maxLines: 1,
              style: typo.rowTitle.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ wallets

class _WalletRow extends StatelessWidget {
  const _WalletRow({required this.sum});

  final TagWalletSum sum;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    final net = sum.net;
    final netColor = net.isNegative
        ? colors.expenseColor
        : net.isPositive
            ? UIColorToken.blue
            : colors.contentColor;

    return UiListRow(
      leading: UiCircleColorBadge(color: sum.color.color, size: 10),
      title: sum.walletDeleted ? '${sum.name} ${l10n.tag_wallet_deleted}' : sum.name,
      subtitle: l10n.tags_usage(sum.count),
      trailing: Text(
        net.format(signed: true, positiveSign: true),
        style: typo.listTitle.copyWith(color: netColor),
      ),
    );
  }
}

// ------------------------------------------------------------- transactions

/// Flat list: month dividers interleaved with transaction rows.
sealed class _ListItem {
  const _ListItem();
}

class _MonthItem extends _ListItem {
  const _MonthItem(this.label);
  final String label;
}

class _TransactionItem extends _ListItem {
  const _TransactionItem(this.row, {required this.dividerAbove});
  final TransactionRow row;
  final bool dividerAbove;
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.transactions});

  final AsyncValue<List<TransactionRow>> transactions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = transactions.value;

    if (rows == null) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(kListHorzPadding, 16, kListHorzPadding, 0),
          child: UiSkeletonList(rows: 4),
        ),
      );
    }

    if (rows.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kListHorzPadding, 16, kListHorzPadding, 0),
          child: Text(l10n.tag_no_transactions, style: context.typo.inter.caption),
        ),
      );
    }

    final items = <_ListItem>[];
    DateTime? lastMonth;
    for (final row in rows) {
      final date = row.transaction.transactionDate.toLocal();
      final newMonth = lastMonth == null || !date.isSameMonth(lastMonth);
      if (newMonth) {
        items.add(_MonthItem(date.formatMonthYear()));
        lastMonth = date;
      }
      items.add(_TransactionItem(row, dividerAbove: !newMonth));
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
      sliver: SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => switch (items[index]) {
          _MonthItem(:final label) => Padding(
              padding: EdgeInsets.only(top: index == 0 ? 8.0 : 20.0, bottom: 2),
              child: Text(label.toUpperCase(), style: context.typo.inter.overline),
            ),
          _TransactionItem(:final row, :final dividerAbove) => Column(
              children: [
                if (dividerAbove) const UIDivider(),
                _TransactionTile(row: row),
              ],
            ),
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.row});

  final TransactionRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = row.transaction;

    // The tag page has no wallet of its own: view income / expense from
    // their wallet and transfers from the sending side.
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

    final amount = t.amountFor(viewedWalletId, t.currency).abs();

    return UiTransactionCard(
      title: title,
      subtitle: t.transactionDate.formatListDate(),
      amount: amount,
      direction: direction,
      secondaryText: walletName,
      tags: row.tags,
      upcoming: t.isUpcoming,
      badge: t.isUpcoming ? l10n.transaction_upcoming_badge : null,
      onTap: () => context.router.push(TransactionRoute(transactionId: row.id, walletId: viewedWalletId)),
    );
  }
}
