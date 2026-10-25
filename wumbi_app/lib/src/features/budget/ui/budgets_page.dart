import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../data/budget_metrics.dart';
import '../data/models/budget_model.dart';
import 'budget_labels.dart';
import 'budgets_provider.dart';
import 'widgets/budget_progress_row.dart';

/// `/budgets` (spec B&D §6.8): every budget, optionally only those scoped to
/// [walletId] ("+2 more budgets ›" on Wallet Details). Running budgets by
/// urgency, then one-time budgets not started yet, then finished ones
/// (collapsed).
@RoutePage()
class BudgetsPage extends HookConsumerWidget {
  const BudgetsPage({super.key, @QueryParam('walletId') this.walletId});

  final String? walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final all = ref.watch(budgetsProvider).value;
    final showFinished = useState(false);

    final scoped = all == null
        ? null
        : walletId == null
            ? all
            : all.where((p) => p.budget.walletIds.contains(walletId)).toList();
    final active = <BudgetProgress>[...?scoped?.where(isRunningBudget)]..sort(compareBudgetSeverity);
    final upcoming = scoped?.where((p) => p.status == BudgetStatus.notStarted).toList() ?? const <BudgetProgress>[];
    final finished = scoped?.where((p) => p.status == BudgetStatus.finished).toList() ?? const <BudgetProgress>[];

    final summary = scoped == null ? null : BudgetLabels.summary(l10n, scoped);

    void create() => context.router.push(BudgetFormRoute(walletId: walletId));

    Widget section(String label, List<BudgetProgress> items) => SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: UiSectionLabel(
                text: label,
                padding: const EdgeInsets.fromLTRB(kListHorzPadding, 20, kListHorzPadding, 0),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
              sliver: SliverList.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => BudgetProgressRow(
                  key: ValueKey('budgets-${items[index].budget.id}'),
                  progress: items[index],
                ),
              ),
            ),
          ],
        );

    return Scaffold(
      appBar: UIAppbar(title: l10n.budgets_title, backTap: () => context.router.maybePop()),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(kListHorzPadding, 8, kListHorzPadding, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.dashboard_budgets, style: typo.headline),
                  UiIconTextButton(icon: UIIconToken.icons.general.plusCircle, title: l10n.budget_new, onTap: create),
                ],
              ),
            ),
          ),
          // Same one-sentence digest as the Dashboard / Wallet tabs.
          if (summary != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(kListHorzPadding, 2, kListHorzPadding, 0),
                child: Text(
                  summary.$1,
                  style: typo.regular.copyWith(color: summary.$2 ?? UIColorToken.casper, fontSize: 12),
                ),
              ),
            ),
          if (scoped == null)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(kListHorzPadding, 24, kListHorzPadding, 0),
                child: UiSkeletonList(rows: 3),
              ),
            )
          else if (scoped.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: UiEmptyState(
                mood: WumbiMood.pouchOpen,
                title: l10n.budgets_empty_title,
                subtitle: l10n.budgets_empty_subtitle,
                action: UiIconTextButton(
                  icon: UIIconToken.icons.general.plusCircle,
                  title: l10n.budget_new,
                  onTap: create,
                ),
              ),
            )
          else ...[
            if (active.isNotEmpty) section(l10n.budgets_active, active),
            if (upcoming.isNotEmpty) section(l10n.budgets_upcoming, upcoming),
            if (finished.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: UITap(
                  onTap: () => showFinished.value = !showFinished.value,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(kListHorzPadding, 20, kListHorzPadding, 4),
                    child: Row(
                      spacing: 4,
                      children: [
                        Text(l10n.budgets_finished(finished.length).toUpperCase(), style: typo.sectionLabel),
                        UIIcon(
                          showFinished.value
                              ? UIIconToken.icons.arrows.chevronDown
                              : UIIconToken.icons.arrows.chevronRight,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showFinished.value)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
                  sliver: SliverList.builder(
                    itemCount: finished.length,
                    itemBuilder: (context, index) => BudgetProgressRow(progress: finished[index]),
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
