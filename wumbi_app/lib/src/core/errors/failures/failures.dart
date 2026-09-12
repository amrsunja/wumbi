import 'package:flutter/widgets.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../locale/l10n.dart';
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
