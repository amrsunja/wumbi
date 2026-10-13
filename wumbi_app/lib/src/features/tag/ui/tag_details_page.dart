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
import '../../../core/utils/typedefs.dart';
import '../../debt/ui/debt_labels.dart';
import '../../debt/ui/debt_rows.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../../wallet/ui/widgets/month_divider.dart';
import '../data/models/tag_model.dart';
import '../data/models/tag_stats.dart';
import '../data/tag_normalizer.dart';
import 'tag_details_notifier.dart';
import 'widgets/tag_create_sheet.dart';
import 'widgets/tag_rename_sheet.dart';
import 'widgets/tag_visuals.dart';

/// Room under each tab list so the last row clears the bottom edge.
const double _kListBottomInset = 64;

enum _TagAction { rename, move, addNested, delete }

enum _TagTab { transactions, wallets, nested }

/// `/tags/:id` — same anatomy as Wallet Details: a fixed header (tag path,
/// net total, spent · earned, tab bar) and one scrollable tab body —
/// Transactions (default), Wallets, Nested tags. Rows dissolve under the
/// tab bar like on the Dashboard.
@RoutePage()
class TagDetailsPage extends HookConsumerWidget {
  const TagDetailsPage({super.key, @PathParam('id') required this.tagId});

  final String tagId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(tagDetailsProvider(tagId));
    final notifier = ref.read(tagDetailsProvider(tagId).notifier);
    final showMascot = ref.watch(showMascotProvider);
    final scrollController = useScrollController();
    final tabIndex = useState(0);
    final tab = _TagTab.values[tabIndex.value];

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
    final tag = stats?.tag;

    /// Rename / move both go through the repository rename (nested tags
    /// follow; an existing name merges).
    Future<void> applyRename(String newName, {required String doneMessage}) async {
      final renamed = await notifier.rename(newName);
      if (renamed == null || !context.mounted) return;
      final events = ref.read(appEventProvider);
      if (renamed.id != tagId) {
        events.send(ShowInfoMessageEvent(l10n.tag_merged(renamed.displayName)));
        context.router.replace(TagDetailsRoute(tagId: renamed.id));
      } else {
        events.send(ShowInfoMessageEvent(doneMessage));
      }
    }

    Future<void> rename() async {
      if (tag == null) return;
      final newName = await TagRenameSheet.show(
        context,
        initialName: tag.displayName,
        hint: l10n.tag_rename_nested_hint,
      );
      if (newName == null || !context.mounted) return;
      await applyRename(newName, doneMessage: l10n.tag_renamed);
    }

    Future<void> move() async {
      if (tag == null) return;
      final picked = await TagMoveSheet.show(context, tag: tag);
      if (picked == null || !context.mounted) return;
      final parent = picked.parent;
      final path = parent == null ? tag.leafName : '$parent${TagNormalizer.separator}${tag.leafName}';
      await applyRename(path, doneMessage: l10n.tag_moved);
    }

    Future<void> delete() async {
      if (tag == null) return;
      final nested = state.descendantCount;
      final ok = await UIAlertDialog.confirm(
        context,
        title: l10n.tag_delete_title(tag.displayName),
        message: nested > 0 ? l10n.tag_delete_nested_message(nested) : l10n.tag_delete_message,
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

    Future<void> addNested() async {
      if (tag == null) return;
      await createTagFlow(context, ref, parentPath: tag.displayName);
    }

    Future<void> openActions() async {
      if (tag == null) return;
      final action = await _ActionsSheet.show(context, tag: tag);
      if (action == null || !context.mounted) return;
      switch (action) {
        case _TagAction.rename:
          await rename();
        case _TagAction.move:
          await move();
        case _TagAction.addNested:
          await addNested();
        case _TagAction.delete:
          await delete();
      }
    }

    void openTag(String id) => context.router.push(TagDetailsRoute(tagId: id));

    void selectTab(int i) {
      if (i == tabIndex.value) return;
      AppVibrations.selection();
      tabIndex.value = i;
    }

    return Scaffold(
      appBar: UIAppbar(
        backTap: () => context.router.maybePop(),
        action: tag == null
            ? null
            : UIIcon(UIIconToken.icons.general.dotsHorizontal, size: 24, onTap: openActions),
      ),
      body: state.notFound
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fixed header: path, net, spent · earned, tabs.
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(kListHorzPadding, 8, kListHorzPadding, 15),
                      child: Column(
                        children: [
                          if (stats == null)
                            const SizedBox(height: 32)
                          else
                            _TagPath(tag: stats.tag, ancestors: state.ancestors, onAncestorTap: openTag),
                          const UISpace.vert(6),
                          Text(
                            stats == null
                                ? ''
                                : [
                                    l10n.tags_usage(stats.transactionCount),
                                    if (state.descendantCount > 0) l10n.tag_includes_nested(state.descendantCount),
                                  ].join(' · '),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.typo.inter.caption,
                          ),
                          const UISpace.vert(22),
                          if (stats == null)
                            const SizedBox(height: 54)
                          else
                            UiTotalAmount(money: stats.net, animated: true),
                          const UISpace.vert(8),
                          if (stats != null) _SpentEarned(stats: stats) else const SizedBox(height: 18),
                          const UISpace.vert(24),
                          UiSegmentedToggle(
                            expanded: true,
                            labels: [l10n.tag_transactions, l10n.tag_wallets, l10n.tag_nested_tags],
                            counts: [null, state.wallets.length, state.children.length],
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
                        child: UIWumbiLook(key: ValueKey('wumbi-tag-$tagId')),
                      ),
                  ],
                ),
                // Only the tab body scrolls; a new key remounts it and
                // replays the cascade.
                Expanded(
                  child: KeyedSubtree(
                    key: ValueKey('$tagId-${tab.name}'),
                    child: switch (tab) {
                      _TagTab.transactions => _TransactionsTab(state: state, controller: scrollController),
                      _TagTab.wallets => _WalletsTab(state: state),
                      _TagTab.nested => _NestedTab(state: state, onOpen: openTag, onAdd: addNested),
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// ------------------------------------------------------------------- header

/// `#food › coffee › latte`: parents small, muted and tappable; the tag
/// itself as the title. Scrolls sideways when the path is too long.
class _TagPath extends StatelessWidget {
  const _TagPath({required this.tag, required this.ancestors, required this.onAncestorTap});

  final TagModel tag;
  final List<TagModel> ancestors;
  final ValueChanged<String> onAncestorTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    final title = Text(
      ancestors.isEmpty ? '#${tag.leafName}' : tag.leafName,
      maxLines: 1,
      style: typo.headline.copyWith(fontSize: 22),
    );
    if (ancestors.isEmpty) {
      return Center(child: FittedBox(fit: BoxFit.scaleDown, child: title));
    }

    Widget chevron() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: UIIcon(UIIconToken.icons.arrows.chevronRight, size: 14, color: colors.secondContentColor),
        );

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        reverse: true,
        padding: .symmetric(horizontal: 70),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < ancestors.length; i++) ...[
              UITap(
                onTap: () => onAncestorTap(ancestors[i].id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    i == 0 ? '#${ancestors[i].leafName}' : ancestors[i].leafName,
                    style: typo.label.copyWith(color: colors.secondContentColor),
                  ),
                ),
              ),
              chevron(),
            ],
            title,
          ],
        ),
      ),
    );
  }
}

/// `SPENT -€120.00 · EARNED +€40.00` under the net total.
class _SpentEarned extends StatelessWidget {
  const _SpentEarned({required this.stats});

  final TagStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    final unconvertible = stats.unconvertible.map((c) => c.code).join(', ');
    return Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '${l10n.tags_spent}:  '),
              TextSpan(
                text: '-${stats.expense.format()}',
                style: typo.label.copyWith(color: colors.expenseColor, letterSpacing: 0),
              ),
              const TextSpan(text: '   |   '),
              TextSpan(text: '${l10n.tags_earned}:  '),
              TextSpan(
                text: '+${stats.income.format()}',
                style: typo.label.copyWith(color: UIColorToken.blue, letterSpacing: 0),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: typo.caption,
        ),
        if (unconvertible.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(l10n.tags_not_included(unconvertible), style: typo.caption),
          ),
      ],
    );
  }
}

// --------------------------------------------------------------------- tabs

/// Scrollable tab body: smoke edges + one-shot cascade. [ready] flips once
/// the data has loaded so the cascade plays on the real rows.
class _TabScroll extends StatelessWidget {
  const _TabScroll({required this.ready, required this.slivers, this.controller});

  final bool ready;
  final List<Widget> slivers;
  final ScrollController? controller;

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
            const SliverToBoxAdapter(child: UISpace.vert(_kListBottomInset)),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: UIStaggerItem(
        index: 0,
        child: UiEmptyState(image: AppAssets.images.wumbiOo.path, title: title, action: action),
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

class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab({required this.state, required this.controller});

  final TagDetailsState state;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = state.transactions.value;

    final items = <Widget>[];
    if (rows != null) {
      DateTime? lastMonth;
      for (final row in rows) {
        final date = row.transaction.transactionDate.toLocal();
        if (lastMonth == null || !date.isSameMonth(lastMonth)) {
          items.add(MonthDivider(label: date.formatMonthYear()));
          lastMonth = date;
        } else {
          items.add(const UIDivider());
        }
        items.add(_TransactionTile(row: row));
      }
    }

    return _TabScroll(
      ready: rows != null,
      controller: controller,
      slivers: [
        if (rows == null)
          const _Loading()
        else if (rows.isEmpty)
          _Empty(title: l10n.tag_no_transactions)
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
            sliver: SliverList.builder(
              itemCount: items.length,
              itemBuilder: (context, i) => UIStaggerItem(index: i, child: items[i]),
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
      ],
    );
  }
}

class _WalletsTab extends StatelessWidget {
  const _WalletsTab({required this.state});

  final TagDetailsState state;

  @override
  Widget build(BuildContext context) {
    final wallets = state.wallets;
    final loaded = state.transactions.value != null;
    return _TabScroll(
      ready: loaded,
      slivers: [
        if (!loaded)
          const _Loading()
        else if (wallets.isEmpty)
          _Empty(title: context.l10n.tag_no_transactions)
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding - 4),
            sliver: SliverList.separated(
              itemCount: wallets.length,
              separatorBuilder: (_, _) => const UIDivider(),
              itemBuilder: (context, i) => UIStaggerItem(index: i, child: _WalletRow(sum: wallets[i])),
            ),
          ),
      ],
    );
  }
}

/// Tags nested directly inside this one + "⊕ Add nested tag".
class _NestedTab extends StatelessWidget {
  const _NestedTab({required this.state, required this.onOpen, required this.onAdd});

  final TagDetailsState state;
  final ValueChanged<String> onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final children = state.children;
    final loaded = state.stats.value != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(kListHorzPadding, 6, kListHorzPadding - 4, 0),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: UiIconTextButton(
              icon: UIIconToken.icons.general.plusCircle,
              title: l10n.tag_add_nested,
              color: UIColorToken.blue,
              onTap: onAdd,
            ),
          ),
        ),
        Expanded(
          child: _TabScroll(
            ready: loaded,
            slivers: [
              if (!loaded)
                const _Loading()
              else if (children.isEmpty)
                _Empty(title: l10n.tag_nested_empty)
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
                  sliver: SliverList.separated(
                    itemCount: children.length,
                    separatorBuilder: (_, _) => const UIDivider(),
                    itemBuilder: (context, i) => UIStaggerItem(
                      index: i,
                      child: _NestedRow(stats: children[i], onTap: () => onOpen(children[i].id)),
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

/// Same anatomy as a tags-list row: name + usage, amounts on the right.
class _NestedRow extends StatelessWidget {
  const _NestedRow({required this.stats, required this.onTap});

  final TagStats stats;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text('#${stats.tag.leafName}', maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.rowTitle),
                  Text(
                    context.l10n.tags_usage(stats.transactionCount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typo.caption,
                  ),
                ],
              ),
            ),
            const UISpace.horz(12),
            TagAmounts(stats: stats),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ actions

abstract class _ActionsSheet {
  static Future<_TagAction?> show(BuildContext context, {required TagModel tag}) {
    final l10n = context.l10n;
    return UIModalSheet.modalSheet<_TagAction>(
      context: context,
      fitContent: true,
      title: '#${tag.displayName}',
      child: Builder(
        builder: (context) {
          void pick(_TagAction a) => Navigator.of(context).pop(a);
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                UiSettingsTile(
                  icon: UIIconToken.icons.general.edit02,
                  title: l10n.tag_rename,
                  showChevron: false,
                  onTap: () => pick(_TagAction.rename),
                ),
                UiSettingsTile(
                  icon: UIIconToken.icons.arrows.cornerDownRight,
                  title: l10n.tag_move,
                  showChevron: false,
                  onTap: () => pick(_TagAction.move),
                ),
                UiSettingsTile(
                  icon: UIIconToken.icons.general.plusCircle,
                  title: l10n.tag_add_nested,
                  showChevron: false,
                  onTap: () => pick(_TagAction.addNested),
                ),
                UiSettingsTile(
                  icon: UIIconToken.icons.general.trash01,
                  title: l10n.tag_delete,
                  destructive: true,
                  showChevron: false,
                  onTap: () => pick(_TagAction.delete),
                ),
              ],
            ),
          );
        },
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


// ------------------------------------------------------------- transactions

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
    if (title.isEmpty) title = DebtLabels.rowTitle(l10n, row) ?? '';
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
      badge: t.isUpcoming ? l10n.transaction_upcoming_badge : DebtLabels.rowBadge(l10n, row),
      onTap: () => openTransactionRow(context, row, walletId: viewedWalletId),
    );
  }
}
