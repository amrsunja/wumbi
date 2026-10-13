import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/typedefs.dart';
import '../data/models/debt_model.dart';
import 'debts_provider.dart';
import 'widgets/debt_summary_row.dart';

/// `/debts` (spec B&D §8.3): "Owed to me" / "I owe" tabs, the open total in
/// the base currency, open debts (overdue first) and the settled ones folded
/// below.
@RoutePage()
class DebtsPage extends HookConsumerWidget {
  const DebtsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final overview = ref.watch(debtsOverviewProvider).value;
    final tab = useState<int?>(null);
    final showSettled = useState(false);

    // Initial tab: "Owed to me", unless it is empty and "I owe" is not.
    final index = tab.value ??
        (overview != null && overview.openLent.isEmpty && overview.openBorrowed.isNotEmpty ? 1 : 0);
    final lentTab = index == 0;
    final open = overview == null ? null : (lentTab ? overview.openLent : overview.openBorrowed);
    final settled = overview == null
        ? const <DebtSummary>[]
        : (lentTab ? overview.settledLent : overview.settledBorrowed);
    final people = open?.map((s) => s.person.id).toSet().length ?? 0;
    final overdue = open?.where((s) => s.overdue).length ?? 0;

    Widget debtRow(DebtSummary s) => DebtSummaryRow(key: ValueKey('debt-${s.debt.id}'), summary: s);

    return Scaffold(
      appBar: UIAppbar(
        title: l10n.debts_title,
        backTap: () => context.router.maybePop(),
        action: UIIcon(UIIconToken.icons.general.plusCircle, size: 22, onTap: () => context.router.push(const NewDebtRoute())),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 0),
              child: Column(
                children: [
                  UiSegmentedToggle(
                    labels: [l10n.debts_owed_to_me, l10n.debts_i_owe],
                    selectedIndex: index,
                    onChanged: (i) => tab.value = i,
                  ),
                  const UISpace.vert(16),
                  if (overview != null) ...[
                    UiTotalAmount(money: lentTab ? overview.owedToMeBase : overview.iOweBase, animated: true),
                    const UISpace.vert(8),
                    Text(
                      [
                        l10n.debts_people_count(people),
                        if (overdue > 0) l10n.debts_overdue_count(overdue),
                        if (overview.incomplete) '≈',
                      ].join(' · '),
                      textAlign: TextAlign.center,
                      style: typo.subtitle,
                    ),
                  ] else
                    const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          if (open == null)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(kListHorzPadding, 24, kListHorzPadding, 0),
                child: UiSkeletonList(rows: 3),
              ),
            )
          else ...[
            if (open.isEmpty)
              SliverToBoxAdapter(
                child: UiEmptyState(
                  image: AppAssets.images.wumbiOo.path,
                  title: lentTab ? l10n.debts_empty_owed_title : l10n.debts_empty_owe_title,
                  subtitle: l10n.debts_empty_subtitle,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(kListHorzPadding, 16, kListHorzPadding, 0),
                sliver: SliverList.separated(
                  itemCount: open.length,
                  separatorBuilder: (_, _) => const UIDivider(),
                  itemBuilder: (context, i) => debtRow(open[i]),
                ),
              ),
            if (settled.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: UITap(
                  onTap: () => showSettled.value = !showSettled.value,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(kListHorzPadding, 24, kListHorzPadding, 4),
                    child: Row(
                      spacing: 4,
                      children: [
                        Text(l10n.debts_settled(settled.length).toUpperCase(), style: typo.sectionLabel),
                        UIIcon(
                          showSettled.value
                              ? UIIconToken.icons.arrows.chevronDown
                              : UIIconToken.icons.arrows.chevronRight,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showSettled.value)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
                  sliver: SliverList.separated(
                    itemCount: settled.length,
                    separatorBuilder: (_, _) => const UIDivider(),
                    itemBuilder: (context, i) => debtRow(settled[i]),
                  ),
                ),
            ],
          ],
          const SliverToBoxAdapter(child: UISpace.vert(64)),
        ],
      ),
    );
  }
}
