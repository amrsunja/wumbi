import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/enums/repeat_frequency.dart';
import '../../../../core/utils/enums/transaction_status.dart';
import '../../../../core/utils/enums/transaction_type.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';

part 'transaction_model.freezed.dart';

@freezed
abstract class TransactionModel with _$TransactionModel {
  const TransactionModel._();

  const factory TransactionModel({
    required String id,
    required TransactionType type,
    String? walletId,
    int? amountMinor,
    required CurrencyType currency,
    String? fromWalletId,
    String? toWalletId,
    int? fromAmountMinor,
    int? toAmountMinor,
    int? originalAmountMinor,
    CurrencyType? originalCurrency,
    double? exchangeRate,
    required String description,
    required DateTime transactionDate,
    @Default(TransactionStatus.posted) TransactionStatus status,
    String? recurringRuleId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _TransactionModel;

  factory TransactionModel.fromRow(Map<String, Object?> r) => TransactionModel(
        id: r[SQLiteConfig.id] as String,
        type: TransactionType.fromString(r[SQLiteConfig.txType] as String),
        walletId: r[SQLiteConfig.txWalletId] as String?,
        amountMinor: r[SQLiteConfig.txAmountMinor] as int?,
        currency: CurrencyType.fromCode(r[SQLiteConfig.txCurrency] as String?),
        fromWalletId: r[SQLiteConfig.txFromWalletId] as String?,
        toWalletId: r[SQLiteConfig.txToWalletId] as String?,
        fromAmountMinor: r[SQLiteConfig.txFromAmountMinor] as int?,
        toAmountMinor: r[SQLiteConfig.txToAmountMinor] as int?,
        originalAmountMinor: r[SQLiteConfig.txOriginalAmountMinor] as int?,
        originalCurrency: CurrencyType.tryFromCode(r[SQLiteConfig.txOriginalCurrency] as String?),
        exchangeRate: (r[SQLiteConfig.txExchangeRate] as num?)?.toDouble(),
        description: (r[SQLiteConfig.txDescription] as String?) ?? '',
        transactionDate: DateTimeExtension.fromEpochMs(r[SQLiteConfig.txDate] as int),
        status: TransactionStatus.fromString(r[SQLiteConfig.txStatus] as String?),
        recurringRuleId: r[SQLiteConfig.txRecurringRuleId] as String?,
        createdAt: DateTimeExtension.fromEpochMs(r[SQLiteConfig.createdAt] as int),
        updatedAt: DateTimeExtension.fromEpochMs(r[SQLiteConfig.updatedAt] as int),
        deletedAt: r[SQLiteConfig.deletedAt] == null
            ? null
            : DateTimeExtension.fromEpochMs(r[SQLiteConfig.deletedAt] as int),
      );

  Map<String, Object?> toRow() => {
        SQLiteConfig.id: id,
        SQLiteConfig.txType: type.dbValue,
        SQLiteConfig.txWalletId: walletId,
        SQLiteConfig.txAmountMinor: amountMinor,
        SQLiteConfig.txCurrency: currency.code,
        SQLiteConfig.txFromWalletId: fromWalletId,
        SQLiteConfig.txToWalletId: toWalletId,
        SQLiteConfig.txFromAmountMinor: fromAmountMinor,
        SQLiteConfig.txToAmountMinor: toAmountMinor,
        SQLiteConfig.txOriginalAmountMinor: originalAmountMinor,
        SQLiteConfig.txOriginalCurrency: originalCurrency?.code,
        SQLiteConfig.txExchangeRate: exchangeRate,
        SQLiteConfig.txDescription: description,
        SQLiteConfig.txDate: transactionDate.epochMs,
        SQLiteConfig.txStatus: status.dbValue,
        SQLiteConfig.txRecurringRuleId: recurringRuleId,
        SQLiteConfig.createdAt: createdAt.epochMs,
        SQLiteConfig.updatedAt: updatedAt.epochMs,
        SQLiteConfig.deletedAt: deletedAt?.epochMs,
      };

  bool get isTransfer => type == TransactionType.transfer;
  bool get isUpcoming => status.isUpcoming;

  /// Amount typed by the user in a foreign currency (D2), if any.
  Money? get original => originalAmountMinor == null || originalCurrency == null
      ? null
      : Money(originalAmountMinor!, originalCurrency!);

  /// Signed amount from the point of view of [walletId] (spec 8.4).
  /// Income/expense → `amount_minor`; transfer out → `-from`; transfer in → `+to`.
  Money amountFor(String viewedWalletId, CurrencyType viewedCurrency) {
    switch (type) {
      case TransactionType.income:
        return Money(amountMinor ?? 0, currency);
      case TransactionType.expense:
        return Money(-(amountMinor ?? 0), currency);
      case TransactionType.transfer:
        if (fromWalletId == viewedWalletId) return Money(-(fromAmountMinor ?? 0), currency);
        return Money(toAmountMinor ?? 0, viewedCurrency);
    }
  }
}

/// A list row for Wallet Details: model + resolved counterpart wallet names.
@freezed
abstract class TransactionRow with _$TransactionRow {
  const TransactionRow._();

  const factory TransactionRow({
    required TransactionModel transaction,

    /// Owning wallet's name for income / expense (only resolved by tag-scoped
    /// queries; null on the wallet page where it is implied).
    String? walletName,
    String? fromWalletName,
    @Default(false) bool fromWalletDeleted,
    String? toWalletName,
    @Default(false) bool toWalletDeleted,

    /// Display names, in attach order (shown on the list card).
    @Default([]) List<String> tags,
  }) = _TransactionRow;

  String get id => transaction.id;
}

/// Full transaction for edit mode.
@freezed
abstract class TransactionWithTags with _$TransactionWithTags {
  const factory TransactionWithTags({
    required TransactionModel transaction,
    required List<String> tags,

    /// Frequency of the rule that generated it (null when not recurring).
    RepeatFrequency? ruleFrequency,
  }) = _TransactionWithTags;
}

/// What the Transaction screen hands to the repository (no ids, no timestamps).
@freezed
sealed class TransactionDraft with _$TransactionDraft {
  const TransactionDraft._();

  const factory TransactionDraft.income({
    required String walletId,
    required Money amount,
    Money? original,
    double? rate,
    required String description,
    required List<String> tags,
    required DateTime date,
    required RepeatFrequency repeat,
  }) = IncomeDraft;

  const factory TransactionDraft.expense({
    required String walletId,
    required Money amount,
    Money? original,
    double? rate,
    required String description,
    required List<String> tags,
    required DateTime date,
    required RepeatFrequency repeat,
  }) = ExpenseDraft;

  const factory TransactionDraft.transfer({
    required String fromWalletId,
    required String toWalletId,
    required Money sent,
    required Money received,
    Money? original,
    double? rate,
    required String description,
    required List<String> tags,
    required DateTime date,
    required RepeatFrequency repeat,
  }) = TransferDraft;

  TransactionType get type => switch (this) {
        IncomeDraft() => TransactionType.income,
        ExpenseDraft() => TransactionType.expense,
        TransferDraft() => TransactionType.transfer,
      };
}
