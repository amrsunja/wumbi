import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/failures/failures.dart';
import '../../../core/fx/fx_service.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/money/amount_input.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/providers/data/fx_provider.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/debt_direction.dart';
import '../../../core/utils/enums/repeat_frequency.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../../transaction/data/transaction_repository.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../data/debt_repository.dart';
import '../data/models/debt_intent.dart';
import '../data/models/debt_model.dart';
import 'debt_labels.dart';
import 'person_pick.dart';

part 'new_debt_notifier.freezed.dart';

@freezed
abstract class NewDebtState with _$NewDebtState {
  const NewDebtState._();

  const factory NewDebtState({
    @Default(DebtDirection.lent) DebtDirection direction,
    String? personId,

    /// Chosen person's name (existing or to create); null = not chosen yet.
    String? personName,
    @Default('') String amountInput,
    required CurrencyType currency,
    @Default('') String note,
    DateTime? dueDate,

    /// Money moved through this wallet; null = "Not in a wallet" (default).
    WalletSummary? wallet,
    @Default(false) bool isSaving,
    String? error,
  }) = _NewDebtState;

  Money? get amount => AmountInput.toMoney(amountInput, currency);
  bool get canSave => personName != null && (amount?.isPositive ?? false) && !isSaving;
}

final newDebtProvider = NotifierProvider.autoDispose<NewDebtNotifier, NewDebtState>(NewDebtNotifier.new);

/// "New debt" page (spec B&D §8.5) — debts created outside the Transaction
/// screen. With a wallet the money moves through `TransactionRepository`
/// (`DebtIntent.open`); without, `DebtRepository.createWithoutMoney`.
class NewDebtNotifier extends Notifier<NewDebtState> {
  AppEvents get _events => ref.read(appEventProvider);
  AppLocale get _l10n => ref.read(l10nProvider);
  FxService get _fx => ref.read(fxServiceProvider);

  @override
  NewDebtState build() => NewDebtState(currency: ref.read(baseCurrencyProvider));

  void setDirection(DebtDirection d) => state = state.copyWith(direction: d);

  void setPerson(PersonPick pick) => state = switch (pick) {
        PickedPerson(:final person) => state.copyWith(personId: person.id, personName: person.name, error: null),
        NewPerson(:final name) => state.copyWith(personId: null, personName: name, error: null),
        NoPerson() => state.copyWith(personId: null, personName: null),
      };

  void setAmountInput(String raw) =>
      state = state.copyWith(amountInput: AmountInput.reScale(raw, state.currency), error: null);

  // On-page numpad (same rules as the Transaction screen).
  void onDigit(String d) => _applyInput(AmountInput.digit(state.amountInput, d, state.currency));

  void onDot() => _applyInput(AmountInput.dot(state.amountInput, state.currency));

  void onBackspace() {
    if (state.amountInput.isEmpty) return;
    state = state.copyWith(amountInput: AmountInput.backspace(state.amountInput), error: null);
  }

  void onClear() {
    if (state.amountInput.isEmpty) return;
    state = state.copyWith(amountInput: AmountInput.clear(), error: null);
  }

  /// Commit tapped with no amount: inline message (the page shakes).
  void flagMissingAmount() => state = state.copyWith(error: _l10n.validation_enter_amount);

  void _applyInput(AmountInputResult r) {
    if (r.rejected) {
      AppVibrations.error();
      return;
    }
    state = state.copyWith(amountInput: r.value, error: null);
  }

  void setCurrency(CurrencyType c) =>
      state = state.copyWith(currency: c, amountInput: AmountInput.reScale(state.amountInput, c));

  void setNote(String v) => state = state.copyWith(
        note: v.length > kMaxDebtDescriptionLength ? v.substring(0, kMaxDebtDescriptionLength) : v,
      );

  void setDueDate(DateTime? d) => state = state.copyWith(dueDate: d?.onlyDate());

  void setWallet(WalletSummary? w) => state = state.copyWith(wallet: w);

  /// Edit mode: seed the editable fields from the stored debt.
  void seedFromDebt(DebtDetails d) {
    if (!ref.mounted) return;
    final debt = d.summary.debt;
    state = state.copyWith(
      direction: debt.direction,
      personId: debt.personId,
      personName: d.summary.person.name,
      currency: debt.currency,
      note: debt.description,
      dueDate: debt.dueDate,
      error: null,
    );
  }

  void setPersonName(String name) => state = state.copyWith(personName: name);

  /// Edit mode save (note and due date). True when the page should close.
  Future<bool> saveEdit(String debtId) async {
    if (state.isSaving) return false;
    state = state.copyWith(isSaving: true, error: null);
    final result = await ref.read(debtRepositoryProvider).update(
          debtId,
          description: state.note.trim(),
          dueDate: state.dueDate,
          clearDueDate: state.dueDate == null,
        );
    if (!ref.mounted) return false;
    state = state.copyWith(isSaving: false);
    final failure = result.tryGetError();
    if (failure != null) {
      _events.send(ShowErrorEvent(failure));
      return false;
    }
    AppVibrations.medium();
    return true;
  }

  /// One-tap commit from the page's action buttons: [direction] is the
  /// button that was pressed. Returns true when the page should close.
  Future<bool> commit(DebtDirection direction) {
    state = state.copyWith(direction: direction);
    return save();
  }

  /// Returns true when the form should close.
  Future<bool> save() async {
    final amount = state.amount;
    final name = state.personName;
    if (name == null) {
      state = state.copyWith(error: _l10n.debt_error_person);
      return false;
    }
    if (amount == null || !amount.isPositive) {
      state = state.copyWith(error: _l10n.validation_enter_amount);
      return false;
    }
    if (state.isSaving) return false;
    state = state.copyWith(isSaving: true, error: null);
    final person = personRefOf(personId: state.personId, name: name);
    final description = state.note.trim();
    try {
      final wallet = state.wallet;
      if (wallet == null) {
        final result = await ref.read(debtRepositoryProvider).createWithoutMoney(
              DebtDraft(
                person: person,
                direction: state.direction,
                principal: amount,
                description: description,
                dueDate: state.dueDate,
              ),
            );
        final failure = result.tryGetError();
        if (failure != null) return _fail(failure);
      } else {
        var walletAmount = amount;
        Money? original;
        double? rate;
        if (wallet.currency != amount.currency) {
          final fx = await _fx.rate(amount.currency, wallet.currency);
          rate = fx.rate;
          walletAmount = convertMoney(amount, wallet.currency, fx.rate);
          original = amount;
        }
        final intent = DebtIntent.open(
          person: person,
          direction: state.direction,
          description: description,
          dueDate: state.dueDate,
        );
        // They owe me → money left my wallet; I owe them → it came in.
        final draft = state.direction == DebtDirection.lent
            ? TransactionDraft.expense(
                walletId: wallet.id,
                amount: walletAmount,
                original: original,
                rate: rate,
                description: description,
                tags: const [],
                date: DateTime.now(),
                repeat: RepeatFrequency.never,
                debt: intent,
              )
            : TransactionDraft.income(
                walletId: wallet.id,
                amount: walletAmount,
                original: original,
                rate: rate,
                description: description,
                tags: const [],
                date: DateTime.now(),
                repeat: RepeatFrequency.never,
                debt: intent,
              );
        final failure = (await ref.read(transactionRepositoryProvider).create(draft)).tryGetError();
        if (failure != null) return _fail(failure);
      }
    } on FxUnavailableException {
      return _fail(const FxUnavailableFailure());
    }
    if (!ref.mounted) return true;
    AppVibrations.medium();
    _events.send(ShowSuccessMessageEvent(DebtLabels.commitToast(
      _l10n,
      DebtCommitSummary(
        kind: state.direction == DebtDirection.lent ? DebtCommitKind.openedLent : DebtCommitKind.openedBorrowed,
        personName: name,
        amount: amount,
      ),
    )));
    state = state.copyWith(isSaving: false);
    return true;
  }

  bool _fail(Failure failure) {
    if (!ref.mounted) return false;
    state = state.copyWith(isSaving: false);
    if (failure is ValidationFailure) {
      state = state.copyWith(error: failure.toMessage(_l10n));
    } else {
      _events.send(ShowErrorEvent(failure));
    }
    return false;
  }
}
