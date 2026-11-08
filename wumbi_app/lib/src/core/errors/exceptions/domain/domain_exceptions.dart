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

/// Why a `.wumbi` backup could not be created, read or restored. Mapped to
/// `BackupFailure` (one localized message per reason).
enum BackupErrorReason {
  /// Not a Wumbi backup (unreadable, another app's file, unknown format).
  notABackup,

  /// A CSV export was picked — CSV is for spreadsheets, never restorable.
  csvNotRestorable,

  /// The file is damaged: bad checksum, broken compression, malformed data.
  corrupted,

  /// Made by a newer Wumbi (unknown format or schema version).
  newerVersion,

  /// Encrypted backup opened without a password.
  passwordRequired,

  /// Decryption failed: wrong password, or the encrypted file was altered.
  wrongPassword,

  /// Larger than the import limit.
  tooLarge,

  /// Readable, but the data breaks the database rules (missing links,
  /// invalid values) — nothing was changed.
  invalidData,
}

class BackupException implements Exception {
  const BackupException(this.reason, [this.detail]);
  final BackupErrorReason reason;
  final Object? detail;

  @override
  String toString() => 'BackupException(${reason.name})${detail == null ? '' : ': $detail'}';
}
