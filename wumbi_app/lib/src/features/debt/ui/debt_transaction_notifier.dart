import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/locale/l10n.dart';
import '../../../core/money/amount_input.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../tag/data/tag_repository.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../data/models/debt_model.dart';
import 'debt_sheet_notifier.dart';

/// Pay-back / receive form state. Money is always in the debt's currency; the
/// wallet decides where it lands. Plain (no codegen): one screen, one owner.
class DebtTransactionState {
  const DebtTransactionState({
    required this.currency,
    required this.date,
    this.seeded = false,
    this.amountInput = '',
    this.description = '',
    this.tags = const [],
    this.wallet,
    this.walletPicked = false,
    this.error,
  });

  final CurrencyType currency;
  final DateTime date;
  final bool seeded;

  /// Raw [AmountInput] string in [currency].
  final String amountInput;
  final String description;
  final List<String> tags;

  /// Only read when [walletPicked]; otherwise the page's default wallet.
  final WalletSummary? wallet;
  final bool walletPicked;
  final String? error;

  Money? get amount => AmountInput.toMoney(amountInput, currency);

  DebtTransactionState copyWith({
    CurrencyType? currency,
    DateTime? date,
    bool? seeded,
    String? amountInput,
    String? description,
    List<String>? tags,
    WalletSummary? wallet,
    bool? walletPicked,
    String? error,
    bool clearError = false,
  }) =>
      DebtTransactionState(
        currency: currency ?? this.currency,
        date: date ?? this.date,
        seeded: seeded ?? this.seeded,
        amountInput: amountInput ?? this.amountInput,
        description: description ?? this.description,
        tags: tags ?? this.tags,
        wallet: wallet ?? this.wallet,
        walletPicked: walletPicked ?? this.walletPicked,
        error: clearError ? null : (error ?? this.error),
      );
}

final debtTransactionProvider =
    NotifierProvider.autoDispose.family<DebtTransactionNotifier, DebtTransactionState, String>(
  DebtTransactionNotifier.new,
);

/// Drives `DebtTransactionPage`. The write itself is `DebtSheetNotifier.repay`,
/// so the repayment, its wallet row and its tags/description stay one write.
class DebtTransactionNotifier extends Notifier<DebtTransactionState> {
  DebtTransactionNotifier(this.debtId);

  final String debtId;

  AppLocale get _l10n => ref.read(l10nProvider);

  @override
  DebtTransactionState build() => DebtTransactionState(
        currency: ref.read(baseCurrencyProvider),
        date: DateTime.now(),
      );

  /// Once per page: the debt's currency, and the whole remaining amount when
  /// [full] ("Paid in full" / "Returned in full").
  void seed(DebtDetails d, {required bool full}) {
    if (!ref.mounted || state.seeded) return;
    final remaining = d.summary.remaining;
    state = state.copyWith(
      seeded: true,
      currency: d.summary.debt.currency,
      amountInput: full ? remaining.toPlainString() : '',
    );
  }

  void pickWallet(WalletSummary? wallet) =>
      state = state.copyWith(wallet: wallet, walletPicked: true, clearError: true);

  void setDescription(String v) => state = state.copyWith(
        description: v.length > kMaxDescriptionLength ? v.substring(0, kMaxDescriptionLength) : v,
      );

  void setTags(List<String> tags) => state = state.copyWith(tags: tags, clearError: true);

  void onTagLimitReached() => state = state.copyWith(error: _l10n.validation_up_to_tags(kMaxTagsPerTransaction));

  Future<List<String>> suggestTags(String query) => ref.read(tagRepositoryProvider).suggest(query, limit: 20);

  void setDate(DateTime day) {
    final now = DateTime.now();
    state = state.copyWith(date: day.isAfter(now) ? now : day, clearError: true);
  }

  void setAmountInput(String raw) =>
      state = state.copyWith(amountInput: AmountInput.reScale(raw, state.currency), clearError: true);

  void onDigit(String d) => _applyInput(AmountInput.digit(state.amountInput, d, state.currency));

  void onDot() => _applyInput(AmountInput.dot(state.amountInput, state.currency));

  void onBackspace() {
    if (state.amountInput.isEmpty) return;
    state = state.copyWith(amountInput: AmountInput.backspace(state.amountInput), clearError: true);
  }

  void onClear() {
    if (state.amountInput.isEmpty) return;
    state = state.copyWith(amountInput: AmountInput.clear(), clearError: true);
  }

  void flagMissingAmount() => state = state.copyWith(error: _l10n.validation_enter_amount);

  void _applyInput(AmountInputResult r) {
    if (r.rejected) {
      AppVibrations.error();
      return;
    }
    state = state.copyWith(amountInput: r.value, clearError: true);
  }

  /// Writes the repayment through [wallet] (null = outside the wallets, which
  /// keeps no note or tags). True when the page should close.
  Future<bool> commit(DebtDetails details, WalletSummary? wallet) async {
    final amount = state.amount;
    if (amount == null || !amount.isPositive) {
      flagMissingAmount();
      return false;
    }
    return ref.read(debtSheetProvider(debtId).notifier).repay(
          details,
          amount,
          wallet: wallet,
          description: wallet == null ? '' : state.description.trim(),
          tags: wallet == null ? const [] : state.tags,
          date: state.date,
        );
  }
}
