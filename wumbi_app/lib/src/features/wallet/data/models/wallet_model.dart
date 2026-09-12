import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/enums/wallet_color.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';

part 'wallet_model.freezed.dart';

@freezed
abstract class WalletModel with _$WalletModel {
  const WalletModel._();

  const factory WalletModel({
    required String id,
    required String name,
    required CurrencyType currency,
    required int initialBalanceMinor,
    required WalletColor color,
    required bool isPrimary,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _WalletModel;

  factory WalletModel.fromRow(Map<String, Object?> r) => WalletModel(
        id: r[SQLiteConfig.id] as String,
        name: r[SQLiteConfig.walletName] as String,
        currency: CurrencyType.fromCode(r[SQLiteConfig.walletCurrency] as String?),
        initialBalanceMinor: (r[SQLiteConfig.walletInitialBalanceMinor] as int?) ?? 0,
        color: WalletColor.fromString(r[SQLiteConfig.walletColor] as String?),
        isPrimary: r[SQLiteConfig.walletIsPrimary] == 1,
        sortOrder: (r[SQLiteConfig.walletSortOrder] as int?) ?? 0,
        createdAt: DateTimeExtension.fromEpochMs(r[SQLiteConfig.createdAt] as int),
        updatedAt: DateTimeExtension.fromEpochMs(r[SQLiteConfig.updatedAt] as int),
        deletedAt: r[SQLiteConfig.deletedAt] == null
            ? null
            : DateTimeExtension.fromEpochMs(r[SQLiteConfig.deletedAt] as int),
      );

  Map<String, Object?> toRow() => {
        SQLiteConfig.id: id,
        SQLiteConfig.walletName: name,
        SQLiteConfig.walletCurrency: currency.code,
        SQLiteConfig.walletInitialBalanceMinor: initialBalanceMinor,
        SQLiteConfig.walletColor: color.dbValue,
        SQLiteConfig.walletIsPrimary: isPrimary ? 1 : 0,
        SQLiteConfig.walletSortOrder: sortOrder,
        SQLiteConfig.createdAt: createdAt.epochMs,
        SQLiteConfig.updatedAt: updatedAt.epochMs,
        SQLiteConfig.deletedAt: deletedAt?.epochMs,
      };

  Money get initialBalance => Money(initialBalanceMinor, currency);
}

/// Wallet + derived balance (from the `wallet_balances` view).
@freezed
abstract class WalletSummary with _$WalletSummary {
  const WalletSummary._();

  const factory WalletSummary({
    required WalletModel wallet,
    required Money balance,
  }) = _WalletSummary;

  String get id => wallet.id;
  String get name => wallet.name;
  CurrencyType get currency => wallet.currency;
  WalletColor get color => wallet.color;
  bool get isPrimary => wallet.isPrimary;
}

/// Input for create / update (no id, no timestamps).
@freezed
abstract class WalletDraft with _$WalletDraft {
  const factory WalletDraft({
    required String name,
    required CurrencyType currency,
    required int initialBalanceMinor,
    required WalletColor color,
    required bool isPrimary,
  }) = _WalletDraft;
}
