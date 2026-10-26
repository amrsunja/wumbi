import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/routing/app_router.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../domain/mascot_message.dart';

/// Opens what a hamster message offers ("View ›", "Add ›").
void runMascotAction(BuildContext context, WidgetRef ref, MascotAction action) {
  final router = context.router;
  final id = action.id;
  switch (action.kind) {
    case MascotActionKind.openDebt:
      router.push(id == null ? const DebtsRoute() : DebtDetailsRoute(debtId: id));
    case MascotActionKind.openDebts:
      router.push(const DebtsRoute());
    case MascotActionKind.openBudget:
      router.push(id == null ? BudgetsRoute() : BudgetDetailsRoute(budgetId: id));
    case MascotActionKind.openBudgets:
      router.push(BudgetsRoute());
    case MascotActionKind.newBudget:
      router.push(BudgetFormRoute());
    case MascotActionKind.openProgress:
      router.push(const ProgressRoute());
    case MascotActionKind.addTransaction:
      router.push(TransactionRoute(walletId: ref.read(primaryWalletProvider)?.id));
    case MascotActionKind.openSubscriptions:
      router.push(SubscriptionsRoute());
    case MascotActionKind.openWallet:
      if (id != null) router.push(WalletDetailsRoute(walletId: id));
  }
}
