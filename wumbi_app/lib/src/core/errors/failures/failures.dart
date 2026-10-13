import 'package:flutter/widgets.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../locale/l10n.dart';
import '../../money/money.dart';
import '../../utils/enums/debt_direction.dart';
import '../../utils/typedefs.dart';
import '../exceptions/cache/cache_exception.dart';
import '../exceptions/database/database_exception.dart';
import '../exceptions/domain/domain_exceptions.dart';

sealed class Failure {
  const Failure();

  static Future<SuccessOrError<T>> exceptionsCatcher<T>(
    Future<T> Function() onSuccess,
  ) async {
    try {
      return Result.success(await onSuccess());
    } on CacheException catch (e) {
      return Result.error(CacheFailure(exception: e));
    } on DatabaseException catch (e) {
      return Result.error(DatabaseFailure(exception: e));
    } on FxUnavailableException {
      return Result.error(const FxUnavailableFailure());
    } on DebtOverpaymentException catch (e) {
      return Result.error(
        DebtOverpaymentFailure(personName: e.personName, direction: e.direction, maxRemaining: e.maxRemaining),
      );
    } on PersonHasDebtsException {
      return Result.error(const PersonHasDebtsFailure());
    } on DebtClosedException {
      return Result.error(const DebtClosedFailure());
    } on ValidationException catch (e) {
      return Result.error(ValidationFailure(field: e.field, message: e.message));
    } on WalletHasTransactionsException {
      return Result.error(const WalletHasTransactionsFailure());
    } on NotFoundException catch (e) {
      return Result.error(NotFoundFailure(entity: e.entity));
    } catch (e, st) {
      debugPrint('$e\n$st');
      return Result.error(UnknownFailure(exception: e));
    }
  }

  String toMessage(AppLocale locale);
}

class CacheFailure extends Failure {
  final CacheException exception;
  const CacheFailure({required this.exception});

  @override
  String toMessage(AppLocale locale) => 'CacheFailure: - ${exception.message}';
}

class DatabaseFailure extends Failure {
  final DatabaseException exception;
  const DatabaseFailure({required this.exception});

  @override
  String toMessage(AppLocale locale) {
    debugPrint('DatabaseFailure: ${exception.data} - ${exception.message}');
    return locale.error_db_failure;
  }
}

/// No rate cached and the device is offline.
class FxUnavailableFailure extends Failure {
  const FxUnavailableFailure();

  @override
  String toMessage(AppLocale locale) => locale.error_rate_unavailable;
}

class ValidationFailure extends Failure {
  final String field;
  final String? message;
  const ValidationFailure({required this.field, this.message});

  @override
  String toMessage(AppLocale locale) => message ?? locale.error_validation;
}

/// Over-repayment ([A1]). A [ValidationFailure] on the `amount` field so the
/// Transaction screen shows it inline (with the amount shake), not as a toast.
class DebtOverpaymentFailure extends ValidationFailure {
  final String personName;
  final DebtDirection direction;
  final Money maxRemaining;

  const DebtOverpaymentFailure({
    required this.personName,
    required this.direction,
    required this.maxRemaining,
  }) : super(field: 'amount');

  @override
  String toMessage(AppLocale locale) => switch (direction) {
        DebtDirection.lent => locale.debt_error_owes_you_only(personName, maxRemaining.format()),
        DebtDirection.borrowed => locale.debt_error_you_owe_only(personName, maxRemaining.format()),
      };
}

/// A person with live debts cannot be deleted.
class PersonHasDebtsFailure extends ValidationFailure {
  const PersonHasDebtsFailure() : super(field: 'person');

  @override
  String toMessage(AppLocale locale) => locale.person_error_has_debts;
}

/// The debt was settled in the meantime (stale sheet).
class DebtClosedFailure extends Failure {
  const DebtClosedFailure();

  @override
  String toMessage(AppLocale locale) => locale.debt_error_closed;
}

/// Wallet currency change refused because the wallet already has transactions.
class WalletHasTransactionsFailure extends Failure {
  const WalletHasTransactionsFailure();

  @override
  String toMessage(AppLocale locale) => locale.error_wallet_has_transactions;
}

class NotFoundFailure extends Failure {
  final String entity;
  const NotFoundFailure({required this.entity});

  @override
  String toMessage(AppLocale locale) => locale.error_not_found;
}

class UnknownFailure extends Failure {
  final Object? exception;
  const UnknownFailure({this.exception});

  @override
  String toMessage(AppLocale locale) => locale.error_unknown;
}
