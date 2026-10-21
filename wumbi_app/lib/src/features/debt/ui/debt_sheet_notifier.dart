import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/failures/failures.dart';
import '../../../core/fx/fx_service.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/money/money.dart';
import '../../../core/providers/data/fx_provider.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/enums/debt_direction.dart';
import '../../../core/utils/enums/payment_kind.dart';
import '../../../core/utils/enums/repeat_frequency.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../../transaction/data/transaction_repository.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../data/debt_repository.dart';
import '../data/models/debt_intent.dart';
import '../data/models/debt_model.dart';
import 'debt_labels.dart';

part 'debt_sheet_notifier.freezed.dart';

@freezed
abstract class DebtSheetState with _$DebtSheetState {
  const factory DebtSheetState({
    /// Wallet picked for the next movement; null with [walletPicked] = "Not
    /// in a wallet". Until the user picks, the page uses the default (the
    /// principal wallet if alive, else the primary one).
    String? walletId,
    @Default(false) bool walletPicked,
    @Default(false) bool isSaving,
  }) = _DebtSheetState;
}

final debtSheetProvider =
    NotifierProvider.autoDispose.family<DebtSheetNotifier, DebtSheetState, String>(DebtSheetNotifier.new);

/// Actions of the Debt Details page (spec B&D §8.4). Money that moves goes through
/// `TransactionRepository.create` with `DebtIntent.repay`, so the wallet row
/// and the payment are one write; settlements outside wallets and
/// forgiveness go through `DebtRepository.addPayment`.
class DebtSheetNotifier extends Notifier<DebtSheetState> {
  DebtSheetNotifier(this.debtId);

  final String debtId;

  DebtRepository get _debts => ref.read(debtRepositoryProvider);
  TransactionRepository get _transactions => ref.read(transactionRepositoryProvider);
  FxService get _fx => ref.read(fxServiceProvider);
  AppEvents get _events => ref.read(appEventProvider);
  AppLocale get _l10n => ref.read(l10nProvider);

  @override
  DebtSheetState build() => const DebtSheetState();

  void pickWallet(WalletSummary? wallet) => state = state.copyWith(walletId: wallet?.id, walletPicked: true);

  /// Pays back [amount] (debt currency) into / from [wallet], or outside the
  /// wallets when null. Returns true on success (the page may close).
  Future<bool> repay(
    DebtDetails d,
    Money amount, {
    required WalletSummary? wallet,
    String description = '',
    List<String> tags = const [],
    DateTime? date,
  }) async {
    final s = d.summary;
    if (state.isSaving) return false;
    if (amount.minor <= 0) return false;
    if (amount.minor > s.remaining.minor) {
      _events.send(ShowErrorEvent(DebtOverpaymentFailure(
        personName: s.person.name,
        direction: s.debt.direction,
        maxRemaining: s.remaining,
      )));
      AppVibrations.error();
      return false;
    }
    state = state.copyWith(isSaving: true);
    try {
      final String message;
      if (wallet == null) {
        final failure = (await _debts.addPayment(debtId, amountMinor: amount.minor, kind: PaymentKind.repayment))
            .tryGetError();
        if (failure != null) throw _Failed(failure);
        final left = s.remaining - amount;
        message = DebtLabels.commitToast(
          _l10n,
          DebtCommitSummary(
            kind: s.debt.direction == DebtDirection.lent ? DebtCommitKind.repaidIn : DebtCommitKind.repaidOut,
            personName: s.person.name,
            amount: amount,
            leftAfter: left.isPositive ? left : null,
          ),
        );
      } else {
        // Cross currency: convert the exact debt amount, and keep it as the
        // typed original so the allocation takes the exact path (no residue).
        var walletAmount = amount;
        Money? original;
        double? rate;
        if (wallet.currency != amount.currency) {
          final fx = await _fx.rate(amount.currency, wallet.currency);
          rate = fx.rate;
          walletAmount = convertMoney(amount, wallet.currency, fx.rate);
          original = amount;
        }
        final intent = DebtIntent.repay(debtId: debtId);
        final draft = s.debt.direction == DebtDirection.lent
            ? TransactionDraft.income(
                walletId: wallet.id,
                amount: walletAmount,
                original: original,
                rate: rate,
                description: description,
                tags: tags,
                date: date ?? DateTime.now(),
                repeat: RepeatFrequency.never,
                debt: intent,
              )
            : TransactionDraft.expense(
                walletId: wallet.id,
                amount: walletAmount,
                original: original,
                rate: rate,
                description: description,
                tags: tags,
                date: date ?? DateTime.now(),
                repeat: RepeatFrequency.never,
                debt: intent,
              );
        final result = await _transactions.create(draft);
        final saved = result.tryGetSuccess();
        if (saved == null) throw _Failed(result.tryGetError()!);
        final summary = (await _debts.commitSummary(saved.id)).tryGetSuccess();
        message = summary == null ? _l10n.transaction_saved(walletAmount.format(), wallet.name) : DebtLabels.commitToast(_l10n, summary);
      }
      AppVibrations.medium();
      _events.send(ShowSuccessMessageEvent(message));
      return true;
    } on FxUnavailableException {
      _events.send(const ShowErrorEvent(FxUnavailableFailure()));
      return false;
    } on _Failed catch (e) {
      _events.send(ShowErrorEvent(e.failure));
      return false;
    } finally {
      if (ref.mounted) state = state.copyWith(isSaving: false);
    }
  }

  /// "Forgive": the rest is waived, no money moves.
  Future<bool> forgive(DebtDetails d) async {
    final result = await _debts.addPayment(
      debtId,
      amountMinor: d.summary.remaining.minor,
      kind: PaymentKind.forgiveness,
    );
    return result.when((_) {
      AppVibrations.medium();
      _events.send(ShowInfoMessageEvent(_l10n.debt_forgiven_toast(d.summary.person.name)));
      return true;
    }, (error) {
      _events.send(ShowErrorEvent(error));
      return false;
    });
  }

  /// Delete the debt with its money (principal + returns), with Undo.
  Future<bool> deleteDebt() async {
    final debts = _debts;
    final events = _events;
    final l10n = _l10n;
    final result = await debts.delete(debtId);
    return result.when((outcome) {
      AppVibrations.heavy();
      events.send(ShowUndoEvent(
        l10n.debt_deleted,
        actionLabel: l10n.common_undo,
        onUndo: () async {
          final failure = (await debts.restore(debtId, outcome.deletedAtMs)).tryGetError();
          if (failure != null) events.send(ShowErrorEvent(failure));
        },
      ));
      return true;
    }, (error) {
      events.send(ShowErrorEvent(error));
      return false;
    });
  }

  /// History swipe-delete (payment + its transaction when unshared), Undo.
  Future<void> deletePayment(DebtPaymentRow row) async {
    final debts = _debts;
    final events = _events;
    final l10n = _l10n;
    final result = await debts.deletePayment(row.payment.id);
    result.when((deletedAt) {
      AppVibrations.heavy();
      events.send(ShowUndoEvent(
        l10n.debt_payment_deleted,
        actionLabel: l10n.common_undo,
        onUndo: () async {
          final failure = (await debts.restorePayment(row.payment.id, deletedAt)).tryGetError();
          if (failure != null) events.send(ShowErrorEvent(failure));
        },
      ));
    }, (error) => events.send(ShowErrorEvent(error)));
  }

  Future<void> updateDescription(String description) async {
    final failure = (await _debts.update(debtId, description: description)).tryGetError();
    if (failure != null) _events.send(ShowErrorEvent(failure));
  }

  Future<void> setDueDate(DateTime? due) async {
    final failure = (await _debts.update(debtId, dueDate: due, clearDueDate: due == null)).tryGetError();
    if (failure != null) _events.send(ShowErrorEvent(failure));
  }

  Future<void> renamePerson(String personId, String name) async {
    final failure = (await _debts.renamePerson(personId, name)).tryGetError();
    if (failure != null) _events.send(ShowErrorEvent(failure));
  }
}

class _Failed implements Exception {
  const _Failed(this.failure);
  final Failure failure;
}
