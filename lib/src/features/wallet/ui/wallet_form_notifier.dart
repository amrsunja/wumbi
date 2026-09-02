import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/failures/failures.dart';
import '../../../core/money/amount_input.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/wallet_color.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../data/models/wallet_model.dart';
import '../data/wallet_repository.dart';
import 'wallets_provider.dart';

part 'wallet_form_notifier.freezed.dart';

enum WalletFormMode { create, edit }

@freezed
abstract class WalletFormState with _$WalletFormState {
  const WalletFormState._();

  const factory WalletFormState({
    required WalletFormMode mode,
    @Default('') String name,
    @Default('') String initialBalanceInput,
    required CurrencyType currency,
    @Default(false) bool isPrimary,
    @Default(WalletColor.blue) WalletColor color,

    /// [A3] currency locked once the wallet has transactions.
    @Default(false) bool currencyLocked,

    /// Only wallet / onboarding / current primary — toggle cannot go off.
    @Default(false) bool isPrimaryLocked,
    @Default(false) bool isSaving,
    @Default(false) bool isLoading,
    String? nameError,
    WalletModel? existing,
  }) = _WalletFormState;

  bool get isEdit => mode == WalletFormMode.edit;
  bool get canSave => name.trim().isNotEmpty && !isSaving && !isLoading;
  Money get initialBalance => Money.parse(initialBalanceInput, currency);
}

/// Arguments: `walletId` (edit) or null (create). `onboarding` forces primary.
class WalletFormArgs {
  const WalletFormArgs({this.walletId, this.onboarding = false});
  final String? walletId;
  final bool onboarding;

  @override
  bool operator ==(Object other) =>
      other is WalletFormArgs && other.walletId == walletId && other.onboarding == onboarding;

  @override
  int get hashCode => Object.hash(walletId, onboarding);
}

final walletFormProvider =
    NotifierProvider.autoDispose.family<WalletFormNotifier, WalletFormState, WalletFormArgs>(WalletFormNotifier.new);

class WalletFormNotifier extends Notifier<WalletFormState> {
  WalletFormNotifier(this.args);

  final WalletFormArgs args;

  WalletRepository get _repo => ref.read(walletRepositoryProvider);
  AppEvents get _events => ref.read(appEventProvider);

  @override
  WalletFormState build() {
    final base = ref.read(baseCurrencyProvider);
    if (args.walletId != null) {
      Future.microtask(_loadExisting);
      return WalletFormState(mode: WalletFormMode.edit, currency: base, isLoading: true);
    }
    final wallets = ref.read(walletsProvider).value ?? const <WalletSummary>[];
    final first = wallets.isEmpty;
    return WalletFormState(
      mode: WalletFormMode.create,
      currency: base,
      isPrimary: first || args.onboarding,
      isPrimaryLocked: first || args.onboarding,
    );
  }

  Future<void> _loadExisting() async {
    final id = args.walletId!;
    final result = await _repo.byId(id);
    if (!ref.mounted) return;
    await result.when(
      (summary) async {
        final w = summary.wallet;
        final locked = await _repo.hasTransactions(id);
        final wallets = ref.read(walletsProvider).value ?? const <WalletSummary>[];
        if (!ref.mounted) return;
        state = state.copyWith(
          existing: w,
          name: w.name,
          initialBalanceInput: w.initialBalanceMinor == 0 ? '' : w.initialBalance.toPlainString(),
          currency: w.currency,
          isPrimary: w.isPrimary,
          color: w.color,
          currencyLocked: locked.tryGetSuccess() ?? false,
          isPrimaryLocked: w.isPrimary || wallets.length <= 1,
          isLoading: false,
        );
      },
      (error) {
        state = state.copyWith(isLoading: false);
        _events.send(ShowErrorEvent(error));
      },
    );
  }

  void setName(String value) {
    final trimmed = value.length > kMaxWalletNameLength ? value.substring(0, kMaxWalletNameLength) : value;
    state = state.copyWith(name: trimmed, nameError: null);
  }

  void setInitialBalanceInput(String raw) =>
      state = state.copyWith(initialBalanceInput: AmountInput.reScale(raw, state.currency));

  void setCurrency(CurrencyType c) {
    if (state.currencyLocked) return;
    state = state.copyWith(
      currency: c,
      initialBalanceInput: AmountInput.reScale(state.initialBalanceInput, c),
    );
  }

  /// Returns false when the toggle must snap back (current primary cannot go off).
  bool setPrimary(bool value) {
    if (!value && state.isPrimaryLocked) return false;
    state = state.copyWith(isPrimary: value);
    return true;
  }

  void setColor(WalletColor c) => state = state.copyWith(color: c);

  WalletDraft _draft() => WalletDraft(
        name: state.name.trim(),
        currency: state.currency,
        initialBalanceMinor: state.initialBalance.minor,
        color: state.color,
        isPrimary: state.isPrimary,
      );

  /// Returns the saved wallet, or null on failure.
  Future<WalletModel?> save() async {
    if (!state.canSave) return null;
    state = state.copyWith(isSaving: true);
    final result = state.isEdit ? await _repo.update(args.walletId!, _draft()) : await _repo.create(_draft());
    if (!ref.mounted) return null;
    WalletModel? saved;
    result.when(
      (wallet) => saved = wallet,
      (error) {
        if (error is ValidationFailure && error.field == 'name') {
          state = state.copyWith(nameError: error.field);
        } else {
          _events.send(ShowErrorEvent(error));
        }
      },
    );
    state = state.copyWith(isSaving: false);
    return saved;
  }

  /// Returns the number of paused rules, or null on failure.
  Future<int?> delete() async {
    final id = args.walletId;
    if (id == null) return null;
    state = state.copyWith(isSaving: true);
    final result = await _repo.softDelete(id);
    if (!ref.mounted) return null;
    int? paused;
    result.when((outcome) => paused = outcome.pausedRules, (error) => _events.send(ShowErrorEvent(error)));
    state = state.copyWith(isSaving: false);
    return paused;
  }
}
