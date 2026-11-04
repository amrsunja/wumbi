import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/routing/app_router.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../domain/mascot_message.dart';

/// Opens what a hamster message offers ("View ›", "Add ›").
void runMascotAction(BuildContext context, WidgetRef ref, MascotAction action) {
  final route = mascotActionRoute(action, primaryWalletId: ref.read(primaryWalletProvider)?.id);
  if (route != null) context.router.push(route);
}

/// The page behind a [MascotAction] — shared by the in-app bubbles and the
/// notifications (a tap on one opens the same page). Null when the action
/// needs an id it does not have.
PageRouteInfo<Object?>? mascotActionRoute(MascotAction action, {String? primaryWalletId}) {
  final id = action.id;
  return switch (action.kind) {
    MascotActionKind.openDebt => id == null ? const DebtsRoute() : DebtDetailsRoute(debtId: id),
    MascotActionKind.openDebts => const DebtsRoute(),
    MascotActionKind.openBudget => id == null ? BudgetsRoute() : BudgetDetailsRoute(budgetId: id),
    MascotActionKind.openBudgets => BudgetsRoute(),
    MascotActionKind.newBudget => BudgetFormRoute(),
    MascotActionKind.openProgress => const ProgressRoute(),
    MascotActionKind.addTransaction => TransactionRoute(walletId: primaryWalletId),
    MascotActionKind.openSubscriptions => SubscriptionsRoute(),
    MascotActionKind.openWallet => id == null ? null : WalletDetailsRoute(walletId: id),
  };
}
