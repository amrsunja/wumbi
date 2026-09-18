import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/enums/repeat_frequency.dart';
import '../../../../core/utils/enums/transaction_type.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';

part 'recurring_rule_model.freezed.dart';

/// A recurring rule mirrors the transaction shape plus scheduling (spec 5.8).
@freezed
abstract class RecurringRuleModel with _$RecurringRuleModel {
  const RecurringRuleModel._();

  const factory RecurringRuleModel({
    required String id,
    required TransactionType type,
    String? walletId,
    int? amountMinor,
    required CurrencyType currency,
    String? fromWalletId,
    String? toWalletId,
    int? fromAmountMinor,
    int? toAmountMinor,
    double? exchangeRate,
    required String description,
    required RepeatFrequency frequency,
    @Default(1) int interval,
    required DateTime startDate,
    required DateTime nextOccurrence,
    @Default(1) int occurrenceCount,
    DateTime? endDate,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _RecurringRuleModel;

  factory RecurringRuleModel.fromRow(Map<String, Object?> r) => RecurringRuleModel(
        id: r[SQLiteConfig.id] as String,
        type: TransactionType.fromString(r[SQLiteConfig.txType] as String),
        walletId: r[SQLiteConfig.txWalletId] as String?,
        amountMinor: r[SQLiteConfig.txAmountMinor] as int?,
        currency: CurrencyType.fromCode(r[SQLiteConfig.txCurrency] as String?),
        fromWalletId: r[SQLiteConfig.txFromWalletId] as String?,
        toWalletId: r[SQLiteConfig.txToWalletId] as String?,
        fromAmountMinor: r[SQLiteConfig.txFromAmountMinor] as int?,
        toAmountMinor: r[SQLiteConfig.txToAmountMinor] as int?,
        exchangeRate: (r[SQLiteConfig.txExchangeRate] as num?)?.toDouble(),
        description: (r[SQLiteConfig.txDescription] as String?) ?? '',
        frequency: RepeatFrequency.fromString(r[SQLiteConfig.ruleFrequency] as String?),
        interval: (r[SQLiteConfig.ruleInterval] as int?) ?? 1,
        startDate: DateTimeExtension.fromEpochMs(r[SQLiteConfig.ruleStartDate] as int),
        nextOccurrence: DateTimeExtension.fromEpochMs(r[SQLiteConfig.ruleNextOccurrence] as int),
        occurrenceCount: (r[SQLiteConfig.ruleOccurrenceCount] as int?) ?? 1,
        endDate: r[SQLiteConfig.ruleEndDate] == null
            ? null
            : DateTimeExtension.fromEpochMs(r[SQLiteConfig.ruleEndDate] as int),
        isActive: r[SQLiteConfig.ruleIsActive] == 1,
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
        SQLiteConfig.txExchangeRate: exchangeRate,
        SQLiteConfig.txDescription: description,
        SQLiteConfig.ruleFrequency: frequency.dbValue,
        SQLiteConfig.ruleInterval: interval,
        SQLiteConfig.ruleStartDate: startDate.epochMs,
        SQLiteConfig.ruleNextOccurrence: nextOccurrence.epochMs,
        SQLiteConfig.ruleOccurrenceCount: occurrenceCount,
        SQLiteConfig.ruleEndDate: endDate?.epochMs,
        SQLiteConfig.ruleIsActive: isActive ? 1 : 0,
        SQLiteConfig.createdAt: createdAt.epochMs,
        SQLiteConfig.updatedAt: updatedAt.epochMs,
        SQLiteConfig.deletedAt: deletedAt?.epochMs,
      };

  bool get isTransfer => type == TransactionType.transfer;

  /// Amount shown in the rules sheet, from the given wallet's point of view.
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

/// Rule + tag display names (subscriptions page edit sheet).
@freezed
abstract class RecurringRuleWithTags with _$RecurringRuleWithTags {
  const factory RecurringRuleWithTags({
    required RecurringRuleModel rule,
    required List<String> tags,
  }) = _RecurringRuleWithTags;
}

/// Partial edit of a rule: every field is optional — null keeps the stored
/// value. `amountMinor` is the sent amount for transfers;
/// `receivedAmountMinor` / `exchangeRate` only apply to cross-currency
/// transfers. `nextOccurrence` re-anchors the whole series on that day.
class RecurringRuleDraft {
  const RecurringRuleDraft({
    this.amountMinor,
    this.receivedAmountMinor,
    this.exchangeRate,
    this.description = '',
    this.frequency,
    this.nextOccurrence,
    this.walletId,
    this.fromWalletId,
    this.toWalletId,
    this.tags,
  });

  final int? amountMinor;
  final int? receivedAmountMinor;
  final double? exchangeRate;
  final String description;
  final RepeatFrequency? frequency;

  /// New due date. The rule is re-anchored on it (`startDate` = this day,
  /// `occurrenceCount` = 0), so the schedule reads exactly as shown.
  final DateTime? nextOccurrence;
  final String? walletId;
  final String? fromWalletId;
  final String? toWalletId;
  final List<String>? tags;
}
