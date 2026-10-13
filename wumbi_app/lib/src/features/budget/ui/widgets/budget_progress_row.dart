import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../data/models/budget_model.dart';
import '../budget_labels.dart';

/// [UiBudgetRow] fed from a [BudgetProgress]; taps open the budget details.
/// Every row shows what was spent ("Spent €170 of €400") next to the caption.
class BudgetProgressRow extends StatelessWidget {
  const BudgetProgressRow({super.key, required this.progress, this.onTap});

  final BudgetProgress progress;

  /// Defaults to opening `/budgets/:id`.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = progress;
    final spent = p.spent.format();
    return UiBudgetRow(
      title: p.budget.name,
      trailing: BudgetLabels.trailing(l10n, p),
      trailingColor: BudgetLabels.trailingColor(p.status),
      caption: BudgetLabels.caption(l10n, p),
      spent: l10n.budget_spent_of(spent, p.limit.format()),
      spentEmphasis: spent,
      spentRatio: p.spentRatio,
      plannedRatio: p.plannedRatio,
      color: BudgetLabels.statusColor(p.status, context.colors),
      onTap: onTap ?? () => context.router.push(BudgetDetailsRoute(budgetId: p.budget.id)),
    );
  }
}
