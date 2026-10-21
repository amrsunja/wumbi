import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/money/amount_input.dart';
import '../../../core/money/money.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/debt_direction.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../transaction/ui/widgets/amount_numpad_sheet.dart';
import '../../transaction/ui/widgets/date_picker_sheet.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../../wallet/ui/widgets/currency_picker_sheet.dart';
import '../data/models/person_model.dart';
import 'debt_labels.dart';
import 'debt_sheet_notifier.dart';
import 'debts_provider.dart';
import 'new_debt_notifier.dart';
import 'widgets/debt_wallet_sheet.dart';
import 'widgets/person_picker_sheet.dart';
import 'widgets/text_entry_sheet.dart';

/// Create (no `debtId`) / Edit debt — same anatomy as Create/Edit Wallet:
/// direction, big tappable amount, note, then plain label → value rows
/// (Person · Currency · Wallet · Due date) and a Delete | Save bar.
///
/// Edit mode: person name, note and due date only. Money, currency,
/// direction and wallet are fixed (mistakes are delete + re-enter).
@RoutePage()
class NewDebtPage extends HookConsumerWidget {
  const NewDebtPage({super.key, @QueryParam('debtId') this.debtId});

  /// Set: edit the stored debt instead of creating one.
  final String? debtId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo;
    final state = ref.watch(newDebtProvider);
    final notifier = ref.read(newDebtProvider.notifier);
    final wallets = ref.watch(walletsProvider).value ?? const <WalletSummary>[];
    final base = ref.watch(baseCurrencyProvider);

    // Edit mode: the stored debt, watched so the form lives as long as the page.
    final id = debtId;
    final editing = id != null;
    final details = id == null ? null : ref.watch(debtDetailsProvider(id)).value;
    if (id != null) ref.watch(debtSheetProvider(id));
    final ready = !editing || state.personName != null;

    final shakeController = useAnimationController(duration: 300.ms);
    final noteController = useTextEditingController();
    final noteFocus = useFocusNode();

    // Edit mode: seed the editable fields once, from the first load.
    final seeded = useRef(false);
    // Deferred: effects run during build, and providers can't change there.
    useEffect(() {
      if (details == null || seeded.value) return null;
      seeded.value = true;
      final stored = details;
      Future.microtask(() => notifier.seedFromDebt(stored));
      return null;
    }, [details]);

    // Keep the note field in sync once the stored note is seeded.
    useEffect(() {
      if (noteController.text != state.note) {
        noteController.value = TextEditingValue(
          text: state.note,
          selection: TextSelection.collapsed(offset: state.note.length),
        );
      }
      return null;
    }, [state.personId, editing]);

    void unfocusAll() {
      noteFocus.unfocus();
      FocusManager.instance.primaryFocus?.unfocus();
    }

    void shake() {
      AppVibrations.error();
      shakeController.forward(from: 0);
    }

    Future<bool> pickPerson() async {
      unfocusAll();
      final picked = await PersonPickerSheet.show(context, allowClear: state.personName != null);
      if (picked == null) return false;
      notifier.setPerson(picked);
      return true;
    }

    Future<void> renamePerson() async {
      unfocusAll();
      final personId = state.personId;
      if (id == null || personId == null) return;
      final name = await TextEntrySheet.show(
        context,
        title: l10n.debt_rename_person,
        initial: state.personName ?? '',
        maxLength: kMaxPersonNameLength,
      );
      if (name == null || !context.mounted) return;
      await ref.read(debtSheetProvider(id).notifier).renamePerson(personId, name);
      notifier.setPersonName(name);
    }

    Future<void> editAmount() async {
      unfocusAll();
      final raw = await AmountNumpadSheet.show(
        context,
        title: l10n.debt_amount,
        currency: state.currency,
        initial: state.amountInput,
      );
      if (raw != null) notifier.setAmountInput(raw);
    }

    Future<void> pickCurrency() async {
      unfocusAll();
      final picked = await CurrencyPickerSheet.show(
        context,
        title: l10n.currency_pick_title,
        selected: state.currency,
        pinned: [state.currency, base, if (state.wallet != null) state.wallet!.currency],
      );
      if (picked != null) notifier.setCurrency(picked);
    }

    Future<void> pickWallet() async {
      unfocusAll();
      final picked = await DebtWalletSheet.show(context, wallets: wallets, selectedId: state.wallet?.id);
      if (picked != null) notifier.setWallet(picked.wallet);
    }

    Future<void> pickDue() async {
      unfocusAll();
      final current = state.dueDate;
      if (current != null) {
        final choice = await UIAlertDialog.choose(
          context,
          title: l10n.debt_due_title,
          actions: [
            UIDialogAction(label: l10n.debt_due_change, primary: true),
            UIDialogAction(label: l10n.debt_due_remove, destructive: true),
            UIDialogAction(label: l10n.common_cancel),
          ],
        );
        if (choice == 1) notifier.setDueDate(null);
        if (choice != 0 || !context.mounted) return;
      }
      final picked = await DatePickerSheet.show(context, initial: current ?? DateTime.now());
      if (picked != null) notifier.setDueDate(picked);
    }

    Future<void> onCreate() async {
      unfocusAll();
      if (!(state.amount?.isPositive ?? false)) {
        shake();
        notifier.flagMissingAmount();
        return;
      }
      // No person yet: ask, then save straight away.
      if (state.personName == null) {
        final picked = await pickPerson();
        if (!picked || !context.mounted) return;
      }
      final ok = await notifier.save();
      if (!context.mounted) return;
      if (ok) {
        context.router.maybePop();
      } else {
        shake();
      }
    }

    Future<void> onSaveEdit() async {
      unfocusAll();
      if (id == null) return;
      final saved = await notifier.saveEdit(id);
      if (saved && context.mounted) context.router.maybePop();
    }

    Future<void> onDelete() async {
      unfocusAll();
      if (id == null) return;
      final moved = details == null
          ? 0
          : (details.summary.debt.principalTransactionId == null ? 0 : 1) +
              details.history.where((h) => h.payment.transactionId != null).length;
      final ok = await UIAlertDialog.confirm(
        context,
        title: l10n.debt_delete_title,
        message: moved == 0 ? null : l10n.debt_delete_message(moved),
        confirmLabel: l10n.common_delete,
        cancelLabel: l10n.common_cancel,
        destructive: true,
      );
      if (!ok || !context.mounted) return;
      final deleted = await ref.read(debtSheetProvider(id).notifier).deleteDebt();
      if (!deleted || !context.mounted) return;
      // Close the form and the deleted debt's details page under it.
      context.router.popUntil(
        (route) => route.settings.name != NewDebtRoute.name && route.settings.name != DebtDetailsRoute.name,
      );
    }

    final wallet = state.wallet;
    final amountText = editing
        ? (details?.summary.principal.format(withSymbol: false) ?? '')
        : state.amountInput.isEmpty
            ? Money.zero(state.currency).format(withSymbol: false)
            : AmountInput.display(state.amountInput);
    final amountMuted = !editing && state.amountInput.isEmpty;
    final walletName = editing
        ? (details?.principalWalletName ?? l10n.debt_not_in_wallet)
        : (wallet?.name ?? l10n.debt_not_in_wallet);

    return Scaffold(
      appBar: UIAppbar(
        title: editing ? l10n.debt_edit_title : l10n.debt_new,
        backTap: () => context.router.maybePop(),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: unfocusAll,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const UISpace.vert(16),

                      // Direction: fixed once stored (shown, not editable).
                      IgnorePointer(
                        ignoring: editing,
                        child: Opacity(
                          opacity: editing ? 0.5 : 1,
                          child: UiSegmentedToggle(
                            expanded: true,
                            labels: [l10n.debt_they_owe_me, l10n.debt_i_owe_them],
                            selectedIndex: state.direction == DebtDirection.lent ? 0 : 1,
                            onChanged: (i) {
                              AppVibrations.selection();
                              notifier.setDirection(i == 0 ? DebtDirection.lent : DebtDirection.borrowed);
                            },
                          ),
                        ),
                      ),
                      const UISpace.vert(32),

                      // Amount: tap → numpad sheet (create only).
                      UITap(
                        onTap: editing ? null : editAmount,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            spacing: 10,
                            children: [
                              Text(
                                state.currency.symbol,
                                style: typo.inter.display.copyWith(color: colors.secondContentColor),
                              ),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    amountText,
                                    style: typo.montserrat.formAmount.copyWith(
                                      color: amountMuted ? colors.secondContentColor : null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate(controller: shakeController, autoPlay: false)
                          .shakeX(hz: 10, amount: 6, duration: 300.ms),
                      const UISpace.vert(8),

                      // Note.
                      UIInputField(
                        controller: noteController,
                        focusNode: noteFocus,
                        style: UIInputFieldStyle.borderless,
                        centered: true,
                        hintText: l10n.debt_note_hint,
                        maxLength: kMaxDebtDescriptionLength,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        textStyle: typo.inter.bodyMedium,
                        onChanged: notifier.setNote,
                        onSubmitted: (_) => unfocusAll(),
                      ),
                      const UISpace.vert(40),

                      UiFormRow(
                        label: l10n.debt_form_person,
                        value: state.personName ?? l10n.debt_choose,
                        muted: state.personName == null,
                        onTap: editing ? () => renamePerson() : () => pickPerson(),
                      ),
                      // What is already open with this person.
                      _PersonBalanceHint(personId: state.personId, personName: state.personName),
                      UiFormRow(
                        label: l10n.wallet_currency,
                        value: '${state.currency.code} (${state.currency.symbol})',
                        valueWidget: editing ? _LockedValue('${state.currency.code} (${state.currency.symbol})') : null,
                        onTap: editing ? null : pickCurrency,
                      ),
                      UiFormRow(
                        label: l10n.debt_form_wallet,
                        value: walletName,
                        muted: !editing && wallet == null,
                        valueWidget: editing ? _LockedValue(walletName) : null,
                        onTap: editing || wallets.isEmpty ? null : pickWallet,
                      ),
                      // Money through a wallet in another currency is converted at save time.
                      if (!editing && wallet != null && wallet.currency != state.currency)
                        UiFormHint(
                          icon: UIIconToken.icons.general.infoCircle,
                          text: '${state.currency.code} → ${wallet.currency.code}',
                        ),
                      UiFormRow(
                        label: l10n.debt_due_date,
                        value: state.dueDate?.formatMediumDate() ?? l10n.debt_none,
                        muted: state.dueDate == null,
                        onTap: pickDue,
                      ),

                      // Validation message.
                      AnimatedSwitcher(
                        duration: 200.ms,
                        child: state.error == null
                            ? const SizedBox(height: 24)
                            : Padding(
                                key: ValueKey(state.error),
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  state.error!,
                                  textAlign: TextAlign.center,
                                  style: typo.inter.caption.copyWith(color: UIColorToken.neg500),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom bar: Delete (edit) · Save.
              Padding(
                // Tight bar, inset like the Transaction edit bar (page + bar padding).
                padding: const EdgeInsets.fromLTRB(kPageHorzPadding * 2, 0, kPageHorzPadding * 2, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (editing)
                      UiTextButton(
                        label: l10n.common_delete,
                        style: UiTextButtonStyle.secondary,
                        enabled: !state.isSaving,
                        onTap: onDelete,
                      )
                    else
                      const UISpace.horz(1),
                    UiTextButton(
                      label: l10n.common_save,
                      // Create: stays tappable without an amount so the tap can shake.
                      enabled: ready && !state.isSaving,
                      onTap: editing ? onSaveEdit : onCreate,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fixed value in edit mode: lock + text, no chevron.
class _LockedValue extends StatelessWidget {
  const _LockedValue(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        UIIcon(UIIconToken.icons.security.lock01, size: 14),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typo.subtitle.copyWith(color: context.colors.secondContentColor),
          ),
        ),
      ],
    );
  }
}

/// "Sara owes you €20" / "You owe Sara €5" / both, for an existing person
/// with open debts; nothing for a new or settled one.
class _PersonBalanceHint extends ConsumerWidget {
  const _PersonBalanceHint({required this.personId, required this.personName});

  final String? personId;
  final String? personName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = personId;
    final name = personName;
    final balance = id == null ? null : ref.watch(personBalanceProvider(id)).value;
    return UiFormHint(
      icon: UIIconToken.icons.users.user01,
      text: name == null || balance == null ? null : _text(context.l10n, name, balance),
    );
  }

  static String? _text(AppLocale l10n, String name, PersonBalance b) {
    if (!b.hasOpenDebts) return null;
    final owed = DebtLabels.side(b.owedToMe, b.owedToMeBase, incomplete: b.incomplete);
    final owe = DebtLabels.side(b.iOwe, b.iOweBase, incomplete: b.incomplete);
    if (b.owedToMe.isNotEmpty && b.iOwe.isNotEmpty) return l10n.debt_hint_both(name, owed, owe);
    if (b.owedToMe.isNotEmpty) return l10n.debt_owes_you(name, owed);
    return l10n.debt_you_owe(name, owe);
  }
}
