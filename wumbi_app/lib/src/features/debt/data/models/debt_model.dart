import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/enums/debt_close_reason.dart';
import '../../../../core/utils/enums/debt_direction.dart';
import '../../../../core/utils/enums/payment_kind.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';
import 'debt_intent.dart';
import 'person_model.dart';

part 'debt_model.freezed.dart';

/// One obligation between the user and a person (spec B&D §4.1). The
/// remaining amount is derived from live payments; only [closedAt] /
/// [closeReason] are cached, recomputed in the same transaction as any write
/// that can change them.
@freezed
abstract class DebtModel with _$DebtModel {
  const DebtModel._();

  const factory DebtModel({
    required String id,
    required String personId,
    required DebtDirection direction,
    required int principalMinor,
    required CurrencyType currency,
    @Default('') String description,

    /// Date of the loan — the FIFO key for repayments ([A3]).
    required DateTime openedAt,
    DateTime? dueDate,

    /// Wallet transaction that moved the money; null when no money moved.
    String? principalTransactionId,
    DateTime? closedAt,
    DebtCloseReason? closeReason,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _DebtModel;

  factory DebtModel.fromRow(Map<String, Object?> r) => DebtModel(
        id: r[SQLiteConfig.id] as String,
        personId: r[SQLiteConfig.debtPersonId] as String,
        direction: DebtDirection.fromString(r[SQLiteConfig.debtDirection] as String),
        principalMinor: r[SQLiteConfig.debtPrincipalMinor] as int,
        currency: CurrencyType.fromCode(r[SQLiteConfig.debtCurrency] as String?),
        description: (r[SQLiteConfig.debtDescription] as String?) ?? '',
        openedAt: DateTimeExtension.fromEpochMs(r[SQLiteConfig.debtOpenedAt] as int),
        dueDate: r[SQLiteConfig.debtDueDate] == null
            ? null
            : DateTimeExtension.fromEpochMs(r[SQLiteConfig.debtDueDate] as int),
        principalTransactionId: r[SQLiteConfig.debtPrincipalTransactionId] as String?,
        closedAt: r[SQLiteConfig.debtClosedAt] == null
            ? null
            : DateTimeExtension.fromEpochMs(r[SQLiteConfig.debtClosedAt] as int),
        closeReason: DebtCloseReason.tryFromString(r[SQLiteConfig.debtCloseReason] as String?),
        createdAt: DateTimeExtension.fromEpochMs(r[SQLiteConfig.createdAt] as int),
        updatedAt: DateTimeExtension.fromEpochMs(r[SQLiteConfig.updatedAt] as int),
        deletedAt: r[SQLiteConfig.deletedAt] == null
            ? null
            : DateTimeExtension.fromEpochMs(r[SQLiteConfig.deletedAt] as int),
      );

  Map<String, Object?> toRow() => {
        SQLiteConfig.id: id,
        SQLiteConfig.debtPersonId: personId,
        SQLiteConfig.debtDirection: direction.dbValue,
        SQLiteConfig.debtPrincipalMinor: principalMinor,
        SQLiteConfig.debtCurrency: currency.code,
        SQLiteConfig.debtDescription: description,
        SQLiteConfig.debtOpenedAt: openedAt.epochMs,
        SQLiteConfig.debtDueDate: dueDate?.epochMs,
        SQLiteConfig.debtPrincipalTransactionId: principalTransactionId,
        SQLiteConfig.debtClosedAt: closedAt?.epochMs,
        SQLiteConfig.debtCloseReason: closeReason?.dbValue,
        SQLiteConfig.createdAt: createdAt.epochMs,
        SQLiteConfig.updatedAt: updatedAt.epochMs,
        SQLiteConfig.deletedAt: deletedAt?.epochMs,
      };

  bool get isClosed => closedAt != null;
  Money get principal => Money(principalMinor, currency);
}

/// A (partial) settlement of a debt, always in the **debt's** currency.
@freezed
abstract class DebtPaymentModel with _$DebtPaymentModel {
  const DebtPaymentModel._();

  const factory DebtPaymentModel({
    required String id,
    required String debtId,

    /// Wallet transaction that moved the money; null = settled outside
    /// Wumbi's wallets (and always null for forgiveness).
    String? transactionId,
    required PaymentKind kind,
    required int amountMinor,
    required DateTime paidAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _DebtPaymentModel;

  factory DebtPaymentModel.fromRow(Map<String, Object?> r) => DebtPaymentModel(
        id: r[SQLiteConfig.id] as String,
        debtId: r[SQLiteConfig.dpDebtId] as String,
        transactionId: r[SQLiteConfig.dpTransactionId] as String?,
        kind: PaymentKind.fromString(r[SQLiteConfig.dpKind] as String),
        amountMinor: r[SQLiteConfig.dpAmountMinor] as int,
        paidAt: DateTimeExtension.fromEpochMs(r[SQLiteConfig.dpPaidAt] as int),
        createdAt: DateTimeExtension.fromEpochMs(r[SQLiteConfig.createdAt] as int),
        updatedAt: DateTimeExtension.fromEpochMs(r[SQLiteConfig.updatedAt] as int),
        deletedAt: r[SQLiteConfig.deletedAt] == null
            ? null
            : DateTimeExtension.fromEpochMs(r[SQLiteConfig.deletedAt] as int),
      );

  Map<String, Object?> toRow() => {
        SQLiteConfig.id: id,
        SQLiteConfig.dpDebtId: debtId,
        SQLiteConfig.dpTransactionId: transactionId,
        SQLiteConfig.dpKind: kind.dbValue,
        SQLiteConfig.dpAmountMinor: amountMinor,
        SQLiteConfig.dpPaidAt: paidAt.epochMs,
        SQLiteConfig.createdAt: createdAt.epochMs,
        SQLiteConfig.updatedAt: updatedAt.epochMs,
        SQLiteConfig.deletedAt: deletedAt?.epochMs,
      };
}

/// A live debt with its person and derived amounts (lists, sheets).
@freezed
abstract class DebtSummary with _$DebtSummary {
  const DebtSummary._();

  const factory DebtSummary({
    required DebtModel debt,
    required PersonModel person,
    required Money principal,
    required Money paid,
    required Money remaining,
    required bool overdue,
  }) = _DebtSummary;

  bool get isOpen => remaining.isPositive;

  /// 0–1 share already settled (progress bar).
  double get paidRatio => principal.minor <= 0 ? 1 : (paid.minor / principal.minor).clamp(0.0, 1.0);
}

/// Debt sheet history row: a payment plus the wallet side of its transaction.
@freezed
abstract class DebtPaymentRow with _$DebtPaymentRow {
  const factory DebtPaymentRow({
    required DebtPaymentModel payment,
    String? walletId,
    String? walletName,

    /// The wallet was deleted ("(wallet deleted)" in the history).
    @Default(false) bool walletDeleted,

    /// Amount that moved in the wallet's currency (may differ from the
    /// payment amount for cross-currency repayments).
    Money? walletAmount,
  }) = _DebtPaymentRow;
}

/// New debt with no wallet movement (`DebtRepository.createWithoutMoney`).
@freezed
abstract class DebtDraft with _$DebtDraft {
  const factory DebtDraft({
    required PersonRef person,
    required DebtDirection direction,
    required Money principal,
    @Default('') String description,

    /// Defaults to now.
    DateTime? openedAt,
    DateTime? dueDate,
  }) = _DebtDraft;
}

/// Debts page model: open and settled debts per side plus base totals.
@freezed
abstract class DebtsOverview with _$DebtsOverview {
  const DebtsOverview._();

  const factory DebtsOverview({
    /// Sorted: overdue first, then due soonest, then newest.
    required List<DebtSummary> openLent,
    required List<DebtSummary> openBorrowed,

    /// Most recently closed first.
    required List<DebtSummary> settledLent,
    required List<DebtSummary> settledBorrowed,

    /// Σ remaining of open debts per side in the base currency (cached rates).
    required Money owedToMeBase,
    required Money iOweBase,

    /// Some currency had no cached rate and is missing from the totals (`≈`).
    @Default(false) bool incomplete,
    required int overdueCount,
  }) = _DebtsOverview;

  int get openCount => openLent.length + openBorrowed.length;
}

/// Debt sheet model.
@freezed
abstract class DebtDetails with _$DebtDetails {
  const factory DebtDetails({
    required DebtSummary summary,

    /// Newest first.
    required List<DebtPaymentRow> history,
    required PersonBalance personBalance,

    /// Wallet of the principal transaction (default target of "Returned in
    /// full"); null when no money moved.
    String? principalWalletId,
    String? principalWalletName,
    @Default(false) bool principalWalletDeleted,
  }) = _DebtDetails;
}

enum DebtCommitKind { openedLent, openedBorrowed, repaidIn, repaidOut }

/// What a debt-linked commit did, for the toast (spec B&D §7.7).
@freezed
abstract class DebtCommitSummary with _$DebtCommitSummary {
  const factory DebtCommitSummary({
    required DebtCommitKind kind,
    required String personName,

    /// Amount in the wallet transaction's currency.
    required Money amount,

    /// What is still open with that person on the affected side, in the
    /// debts' currency; null = all settled.
    Money? leftAfter,
  }) = _DebtCommitSummary;
}

/// Result of deleting a debt (undo needs the exact `deleted_at`).
@freezed
abstract class DebtDeleteOutcome with _$DebtDeleteOutcome {
  const factory DebtDeleteOutcome({
    required int deletedAtMs,

    /// Wallet transactions removed by the cascade (principal + returns).
    required int transactionsDeleted,
  }) = _DebtDeleteOutcome;
}
