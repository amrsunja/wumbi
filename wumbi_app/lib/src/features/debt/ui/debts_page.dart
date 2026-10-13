import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/money/money.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/hooks/use_swipe_tabs.dart';
import '../../../core/utils/typedefs.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../data/models/debt_model.dart';
import 'debts_provider.dart';
import 'widgets/debt_summary_row.dart';

/// Room under each tab list so the last row clears the floating button.
const double _kListBottomInset = 96;

enum _DebtTab { owedToMe, iOwe, settled }

/// `/debts` (spec B&D §8.3) — same anatomy as Subscriptions: a fixed header
/// (what I'll receive · what I owe in the base currency, Owed to me | I owe |
/// Settled tabs, overdue dots) and one swipeable tab body. Open tabs
/// list overdue first, then due soonest; Settled mixes both sides, most
/// recently closed first. "New debt" is the floating button.
@RoutePage()
class DebtsPage extends HookConsumerWidget {
  const DebtsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final overview = ref.watch(debtsOverviewProvider).value;
    final showMascot = ref.watch(showMascotProvider);

    // Opens on "I owe" when nobody owes me but I owe someone.
    final tabs = useSwipeTabs(
      initialIndex: overview != null && overview.openLent.isEmpty && overview.openBorrowed.isNotEmpty ? 1 : 0,
    );

    final o = overview;
    final settled = o == null
        ? null
        : ([...o.settledLent, ...o.settledBorrowed]
          ..sort((a, b) => (b.debt.closedAt ?? b.debt.updatedAt).compareTo(a.debt.closedAt ?? a.debt.updatedAt)));
    final hasAny = (o?.openCount ?? 0) > 0 || (settled?.isNotEmpty ?? false);

    return Scaffold(
      appBar: UIAppbar(title: l10n.debts_title, backTap: () => context.router.maybePop()),
      floatingActionButton: UiFab(onTap: () => context.router.push(const NewDebtRoute()), label: l10n.debt_new),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixed header: both sides, tabs.
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(kListHorzPadding, 28, kListHorzPadding, 15),
                child: Column(
                  children: [
                    if (o == null)
                      const SizedBox(height: 64)
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _SideTotal(
                              label: l10n.debts_to_receive,
                              money: o.owedToMeBase,
                              approx: o.incomplete,
                              color: UIColorToken.blue,
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: VerticalDivider(width: 1, thickness: 1, color: context.colors.dividerColor),
                          ),
                          Expanded(
                            child: _SideTotal(label: l10n.debts_to_pay, money: o.iOweBase, approx: o.incomplete),
                          ),
                        ],
                      ),
                    const UISpace.vert(32),
                    UiSegmentedToggle(
                      expanded: true,
                      labels: [l10n.debts_owed_to_me, l10n.debts_i_owe, l10n.debt_settled_label],
                      // Overdue: a dot on its side's tab.
                      dots: [
                        o?.openLent.any((d) => d.overdue) ?? false,
                        o?.openBorrowed.any((d) => d.overdue) ?? false,
                        false,
                      ],
                      counts: [o?.openLent.length, o?.openBorrowed.length, settled?.length],
                      selectedIndex: tabs.index,
                      onChanged: tabs.onTabTap,
                    ),
                  ],
                ),
              ),
              if (showMascot)
                // Inside the header (a negative top tucks the antenna under
                // the app bar).
                const Positioned(right: 8, top: 12, child: UIWumbiLook(key: ValueKey('wumbi-debts'))),
            ],
          ),
          // Swipeable tab bodies (only they scroll). Pages are not kept
          // alive, so the cascade replays on every switch.
          Expanded(
            child: PageView(
              controller: tabs.controller,
              onPageChanged: tabs.onPageChanged,
              children: [
                for (final t in _DebtTab.values)
                  _DebtsTab(
                    key: ValueKey('debts-${t.name}'),
                    debts: switch (t) {
                      _DebtTab.owedToMe => o?.openLent,
                      _DebtTab.iOwe => o?.openBorrowed,
                      _DebtTab.settled => settled,
                    },
                    showSide: t == _DebtTab.settled,
                    // Nothing at all yet → explain how debts appear;
                    // otherwise just "none in this tab".
                    emptyTitle: switch (t) {
                      _DebtTab.owedToMe => l10n.debts_empty_owed_title,
                      _DebtTab.iOwe => l10n.debts_empty_owe_title,
                      _DebtTab.settled => l10n.debts_settled_empty,
                    },
                    emptySubtitle: hasAny || t == _DebtTab.settled ? null : l10n.debts_empty_subtitle,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "TO RECEIVE / €130" — one side of the header.
class _SideTotal extends StatelessWidget {
  const _SideTotal({required this.label, required this.money, required this.approx, this.color});

  final String label;
  final Money money;

  /// Some currency had no cached rate: the total is approximate.
  final bool approx;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    final zero = money.isZero;
    return Column(
      children: [
        Text(label.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.sectionLabel),
        const UISpace.vert(6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (approx && !zero) Text('≈ ', style: typo.subtitle),
              Flexible(
                child: UiTotalAmount(
                  money: money,
                  animated: true,
                  fontSize: 28,
                  color: zero ? context.colors.secondContentColor : color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One tab body: skeleton → empty state | debt rows. Smoke edges + one-shot
/// cascade, like the Subscriptions tabs.
class _DebtsTab extends StatelessWidget {
  const _DebtsTab({
    super.key,
    required this.debts,
    required this.showSide,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  final List<DebtSummary>? debts;

  /// Settled mixes both sides: each row says which.
  final bool showSide;
  final String emptyTitle;
  final String? emptySubtitle;

  @override
  Widget build(BuildContext context) {
    final list = debts;
    return UIStaggerScope(
      key: ValueKey(list != null),
      child: UIScrollEdgeFade(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            const SliverToBoxAdapter(child: UISpace.vert(4)),
            if (list == null)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(kListHorzPadding, 16, kListHorzPadding, 0),
                  child: UiSkeletonList(rows: 4),
                ),
              )
            else if (list.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: UIStaggerItem(
                  index: 0,
                  child: UiEmptyState(
                    image: AppAssets.images.wumbiOo.path,
                    title: emptyTitle,
                    subtitle: emptySubtitle,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
                sliver: SliverList.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const UIDivider(),
                  itemBuilder: (context, i) => UIStaggerItem(
                    index: i,
                    child: DebtSummaryRow(key: ValueKey('debt-${list[i].debt.id}'), summary: list[i], showSide: showSide),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: UISpace.vert(_kListBottomInset)),
          ],
        ),
      ),
    );
  }
}
