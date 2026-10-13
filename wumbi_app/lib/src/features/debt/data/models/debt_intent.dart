import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/enums/debt_direction.dart';

part 'debt_intent.freezed.dart';

/// A person picked on a debt screen: an existing row, or a typed name that is
/// found-or-created by normalized name inside the write (like tags).
@freezed
sealed class PersonRef with _$PersonRef {
  const factory PersonRef.existing(String id) = ExistingPersonRef;
  const factory PersonRef.create(String name) = NewPersonRef;
}

/// What a person-linked income / expense draft means for debts
/// (spec B&D §7.3). Carried by `TransactionDraft.income/expense(debt: …)` and
/// resolved inside the same SQLite transaction as the wallet row, so the
/// money movement and the debt bookkeeping can never disagree.
@freezed
sealed class DebtIntent with _$DebtIntent {
  /// Transaction screen (GAVE / GOT): the app decides between "new debt" and
  /// "repayment" with `resolveDebtFlow` against fresh data, then repays FIFO.
  const factory DebtIntent.auto({
    required PersonRef person,
    String? description,
    DateTime? dueDate,
  }) = AutoDebtIntent;

  /// Debt sheet: pay back exactly this debt (no FIFO).
  const factory DebtIntent.repay({required String debtId}) = RepayDebtIntent;

  /// New-debt sheet with "money moved from wallet": open a debt with this
  /// direction. The direction must match the money flow (lent ↔ expense).
  const factory DebtIntent.open({
    required PersonRef person,
    required DebtDirection direction,
    String? description,
    DateTime? dueDate,
  }) = OpenDebtIntent;
}
