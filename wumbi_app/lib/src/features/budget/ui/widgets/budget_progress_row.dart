import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../data/models/budget_model.dart';
import '../budget_labels.dart';

/// [UiBudgetRow] fed from a [BudgetProgress]. Taps open the budget details
/// (title → app bar, ring → ring; the row's numbers seed the page so the
/// heroes have a target on the first frame).
class BudgetProgressRow extends StatelessWidget {
  const BudgetProgressRow({super.key, required this.progress, this.onTap});

  final BudgetProgress progress;

  /// Defaults to opening `/budgets/:id`.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = progress;
    return UiBudgetRow(
      title: p.budget.name,
      trailing: BudgetLabels.trailing(l10n, p),
      trailingColor: BudgetLabels.trailingColor(p.status, context.colors),
      subtitle: BudgetLabels.rowSubtitle(l10n, p),
      spentRatio: p.spentRatio,
      plannedRatio: p.plannedRatio,
      color: BudgetLabels.statusColor(p, context.colors),
      titleHeroTag: heroBudgetName(p.budget.id),
      barHeroTag: heroBudgetProgress(p.budget.id),
      onTap: onTap ?? () => context.router.push(BudgetDetailsRoute(budgetId: p.budget.id, seed: p)),
    );
  }
}
