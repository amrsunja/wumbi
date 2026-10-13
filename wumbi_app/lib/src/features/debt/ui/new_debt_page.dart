import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/money/amount_input.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/debt_direction.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../transaction/ui/widgets/date_picker_sheet.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../../wallet/ui/widgets/currency_picker_sheet.dart';
import '../data/models/person_model.dart';
import 'debt_labels.dart';
import 'debts_provider.dart';
import 'new_debt_notifier.dart';
import 'widgets/debt_wallet_sheet.dart';
import 'widgets/person_picker_sheet.dart';

/// "New debt" for money that did not go through the Transaction screen
/// ("Sara paid my dinner"), spec B&D §8.5. Same anatomy as the Transaction
/// screen: currency | wallet header, amount on an on-page numpad, note,
/// person / due chips, and one-tap commit — THEY OWE ME / I OWE THEM.
@RoutePage()
class NewDebtPage extends HookConsumerWidget {
  const NewDebtPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo;
    final state = ref.watch(newDebtProvider);
    final notifier = ref.read(newDebtProvider.notifier);
    final wallets = ref.watch(walletsProvider).value ?? const <WalletSummary>[];
    final base = ref.watch(baseCurrencyProvider);

    final shakeController = useAnimationController(duration: 300.ms);
    final noteController = useTextEditingController();
    final noteFocus = useFocusNode();

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

    Future<void> onCommit(DebtDirection direction) async {
      unfocusAll();
      if (!(state.amount?.isPositive ?? false)) {
        shake();
        notifier.flagMissingAmount();
        return;
      }
      // No person yet: ask, then commit straight away.
      if (state.personName == null) {
        final picked = await pickPerson();
        if (!picked || !context.mounted) return;
      }
      final ok = await notifier.commit(direction);
      if (!context.mounted) return;
      if (ok) {
        context.router.maybePop();
      } else {
        shake();
      }
    }

    final wallet = state.wallet;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colors.isDark ? colors.bgColor : UIColorToken.cararra,
      appBar: UIAppbar(title: l10n.debt_new, backTap: () => context.router.maybePop()),
      // Tap anywhere outside the note → drop the keyboard.
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: unfocusAll,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
            child: Column(
              children: [
                // Header: debt currency | wallet the money moved through.
                UiWalletInfoMenu(
                  name: wallet?.name ?? l10n.debt_not_in_wallet,
                  color: wallet?.color.color ?? colors.secondContentColor,
                  currencyType: state.currency,
                  onSelectCurrency: pickCurrency,
                  onSelectWallet: wallets.isEmpty ? null : pickWallet,
                ),
                const UISpace.vert(12),

                // Amount.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: UiAmountText(
                    text: AmountInput.display(state.amountInput),
                    style: typo.montserrat.input.copyWith(
                      color: state.amountInput.isEmpty ? colors.secondContentColor : null,
                    ),
                  ),
                )
                    .animate(controller: shakeController, autoPlay: false)
                    .shakeX(hz: 10, amount: 6, duration: 300.ms),
                const UISpace.vert(4),
                // Money through a wallet in another currency is converted
                // at save time.
                SizedBox(
                  height: 18,
                  child: wallet == null || wallet.currency == state.currency
                      ? null
                      : Center(
                          child: Text(
                            '${state.currency.code} → ${wallet.currency.code}',
                            style: typo.inter.caption,
                          ),
                        ),
                ),
                const UISpace.vert(16),

                // Note.
                UIInputField(
                  controller: noteController,
                  focusNode: noteFocus,
                  style: UIInputFieldStyle.borderless,
                  centered: true,
                  hintText: l10n.debt_note_placeholder,
                  maxLength: kMaxDebtDescriptionLength,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  textStyle: typo.inter.bodyMedium,
                  onChanged: notifier.setNote,
                  onSubmitted: (_) => unfocusAll(),
                ),
                const Spacer(),

                // Validation message.
                AnimatedSwitcher(
                  duration: 200.ms,
                  child: state.error == null
                      ? const SizedBox(height: 16)
                      : SizedBox(
                          height: 16,
                          child: Text(
                            state.error!,
                            key: ValueKey(state.error),
                            style: typo.inter.caption.copyWith(color: UIColorToken.neg500),
                          ),
                        ),
                ),
                const UISpace.vert(4),

                // Chips row.
                LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 10,
                        children: [
                          UiChip(
                            icon: UIIconToken.icons.users.user01,
                            label: state.personName ?? l10n.debt_person_chip,
                            highlighted: state.personName != null,
                            onTap: pickPerson,
                          ),
                          UiChip(
                            icon: UIIconToken.icons.time.calendar,
                            label: state.dueDate == null
                                ? l10n.debt_add_due
                                : l10n.debt_due(state.dueDate!.formatShortDate()),
                            highlighted: state.dueDate != null,
                            onTap: pickDue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // What is already open with this person.
                _PersonBalanceHint(personId: state.personId, personName: state.personName),
                const UISpace.vert(12),

                // Numpad.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kNumpadHorzPadding),
                  child: UiNumpad(
                    dotEnabled: state.currency.scale > 0,
                    onDigit: notifier.onDigit,
                    onDot: notifier.onDot,
                    onBackspace: notifier.onBackspace,
                    onClear: notifier.onClear,
                  ),
                ),
                const UISpace.vert(12),

                // One-tap commit: which way the debt goes.
                Row(
                  children: [
                    Expanded(
                      child: UiTypeActionButton(
                        // Lent: the money left me (same side as GAVE).
                        label: l10n.debt_they_owe_me,
                        style: UiTypeActionStyle.expense,
                        enabled: !state.isSaving,
                        onTap: () => onCommit(DebtDirection.lent),
                      ),
                    ),
                    Expanded(
                      child: UiTypeActionButton(
                        // Borrowed: the money came to me (same side as GOT).
                        label: l10n.debt_i_owe_them,
                        style: UiTypeActionStyle.income,
                        enabled: !state.isSaving,
                        onTap: () => onCommit(DebtDirection.borrowed),
                      ),
                    ),
                  ],
                ),
                const UISpace.vert(8),
              ],
            ),
          ),
        ),
      ),
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
