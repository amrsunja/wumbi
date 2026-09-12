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
