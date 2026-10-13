import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import '../../../core/routing/app_router.dart';
import '../../transaction/data/models/transaction_model.dart';

/// The single place deciding what tapping a transaction row opens (spec B&D
/// §8.6): debt-linked rows open their debt details ([A8]: they are not edited
/// on the Transaction screen), everything else opens the Transaction screen.
/// Used by Wallet Details, Tag details and Search.
Future<void> openTransactionRow(BuildContext context, TransactionRow row, {String? walletId}) async {
  final debtId = row.debtId;
  if (row.transaction.isDebtLinked && debtId != null) {
    await context.router.push(DebtDetailsRoute(debtId: debtId));
    return;
  }
  await context.router.push(TransactionRoute(transactionId: row.id, walletId: walletId));
}
