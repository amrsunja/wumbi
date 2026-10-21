import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/enums/debt_direction.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';
import '../../data/models/debt_model.dart';
import '../debt_labels.dart';

/// [UiDebtRow] fed from a [DebtSummary]; taps open the debt details (the
/// name hero; the row's summary seeds the page so it has a target).
/// [showSide] prefixes the caption with "Owed to me" / "I owe" (lists mixing
/// both sides: the Dashboard).
class DebtSummaryRow extends StatelessWidget {
  const DebtSummaryRow({super.key, required this.summary, this.showSide = false});

  final DebtSummary summary;
  final bool showSide;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = summary;
    final due = s.debt.dueDate;
    final caption = [
      if (showSide) s.debt.direction == DebtDirection.lent ? l10n.debts_owed_to_me : l10n.debts_i_owe,
      if (s.debt.description.isNotEmpty) s.debt.description,
      if (due != null && s.isOpen && !s.overdue) l10n.debt_due(due.formatShortDate()),
    ].join(' · ');
    final tone = s.debt.direction == DebtDirection.lent ? UIColorToken.blue : context.colors.expenseColor;
    return UiDebtRow(
      title: s.person.name,
      trailing: DebtLabels.remaining(l10n, s),
      caption: caption,
      alert: s.overdue ? l10n.debt_overdue : null,
      dimmed: !s.isOpen,
      // Income blue: someone owes you. Expense colour: you owe someone.
      dotColor: tone,
      trailingColor: tone,
      titleHeroTag: heroDebtName(s.debt.id),
      onTap: () => context.router.push(DebtDetailsRoute(debtId: s.debt.id, seed: s)),
    );
  }
}
