import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';

part 'person_model.freezed.dart';

/// Someone the user lends to or borrows from. Names are unique among live
/// rows by [normalizedName] (lower-case, trimmed, whitespace collapsed).
@freezed
abstract class PersonModel with _$PersonModel {
  const PersonModel._();

  const factory PersonModel({
    required String id,
    required String name,
    required String normalizedName,
    DateTime? lastUsedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _PersonModel;

  factory PersonModel.fromRow(Map<String, Object?> r) => PersonModel(
        id: r[SQLiteConfig.id] as String,
        name: r[SQLiteConfig.personName] as String,
        normalizedName: r[SQLiteConfig.personNormalizedName] as String,
        lastUsedAt: r[SQLiteConfig.personLastUsedAt] == null
            ? null
            : DateTimeExtension.fromEpochMs(r[SQLiteConfig.personLastUsedAt] as int),
        createdAt: DateTimeExtension.fromEpochMs(r[SQLiteConfig.createdAt] as int),
        updatedAt: DateTimeExtension.fromEpochMs(r[SQLiteConfig.updatedAt] as int),
        deletedAt: r[SQLiteConfig.deletedAt] == null
            ? null
            : DateTimeExtension.fromEpochMs(r[SQLiteConfig.deletedAt] as int),
      );

  Map<String, Object?> toRow() => {
        SQLiteConfig.id: id,
        SQLiteConfig.personName: name,
        SQLiteConfig.personNormalizedName: normalizedName,
        SQLiteConfig.personLastUsedAt: lastUsedAt?.epochMs,
        SQLiteConfig.createdAt: createdAt.epochMs,
        SQLiteConfig.updatedAt: updatedAt.epochMs,
        SQLiteConfig.deletedAt: deletedAt?.epochMs,
      };
}

/// Open debts with one person, netted for display only ([A2]: every debt
/// stays its own row). Amounts are kept per currency because debts are never
/// converted when stored; the base totals use cached rates (read path).
@freezed
abstract class PersonBalance with _$PersonBalance {
  const PersonBalance._();

  const factory PersonBalance({
    required String personId,

    /// Σ remaining of open `lent` debts, minor units per currency (> 0 only).
    @Default(<CurrencyType, int>{}) Map<CurrencyType, int> owedToMe,

    /// Σ remaining of open `borrowed` debts, minor units per currency (> 0 only).
    @Default(<CurrencyType, int>{}) Map<CurrencyType, int> iOwe,

    /// Base-currency totals; null when nothing is open on that side.
    Money? owedToMeBase,
    Money? iOweBase,

    /// Some currency had no cached rate and is missing from the base totals.
    @Default(false) bool incomplete,
  }) = _PersonBalance;

  bool get hasOpenDebts => owedToMe.isNotEmpty || iOwe.isNotEmpty;
}

/// Person picker row: the person plus their open balance.
@freezed
abstract class PersonSummary with _$PersonSummary {
  const factory PersonSummary({
    required PersonModel person,
    required PersonBalance balance,
  }) = _PersonSummary;
}
