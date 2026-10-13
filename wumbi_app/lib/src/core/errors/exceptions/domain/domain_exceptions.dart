import '../../../money/money.dart';
import '../../../utils/enums/debt_direction.dart';

/// Domain exceptions thrown inside repositories; mapped to [Failure]s by
/// `Failure.exceptionsCatcher`.
class FxUnavailableException implements Exception {
  const FxUnavailableException([this.message = 'No exchange rate available']);
  final String message;

  @override
  String toString() => 'FxUnavailableException: $message';
}

class ValidationException implements Exception {
  const ValidationException(this.field, [this.message]);
  final String field;
  final String? message;

  @override
  String toString() => 'ValidationException($field): $message';
}

class WalletHasTransactionsException implements Exception {
  const WalletHasTransactionsException();
}

class NotFoundException implements Exception {
  const NotFoundException(this.entity);
  final String entity;

  @override
  String toString() => 'NotFoundException: $entity';
}

/// A repayment larger than what is open with the person ([A1]: refused, never
/// turned into an opposite debt). Nothing is written.
class DebtOverpaymentException implements Exception {
  const DebtOverpaymentException({
    required this.personName,
    required this.direction,
    required this.maxRemaining,
  });

  final String personName;

  /// Side being repaid: `lent` → "Ahmed owes you only …",
  /// `borrowed` → "You owe Sara only …".
  final DebtDirection direction;
  final Money maxRemaining;

  @override
  String toString() => 'DebtOverpaymentException($personName, ${direction.name}, max: $maxRemaining)';
}

/// Deleting a person who still has live debts.
class PersonHasDebtsException implements Exception {
  const PersonHasDebtsException();
}

/// Repay / forgive a debt that is already settled (stale UI).
class DebtClosedException implements Exception {
  const DebtClosedException();
}
