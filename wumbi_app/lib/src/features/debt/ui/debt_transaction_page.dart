import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/debt_direction.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../transaction/ui/widgets/amount_entry_display.dart';
import '../../transaction/ui/widgets/date_picker_sheet.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../data/models/debt_model.dart';
import 'debt_sheet_notifier.dart';
import 'debt_transaction_notifier.dart';
import 'debts_provider.dart';
import 'widgets/debt_wallet_sheet.dart';

/// Pay back / receive money for one debt: the Transaction screen's anatomy
/// (wallet header, amount on the numpad, description, tags, date, one action)
/// for a repayment. [full] prefills the whole remaining amount.
@RoutePage()
class DebtTransactionPage extends HookConsumerWidget {
  const DebtTransactionPage({
    super.key,
    @PathParam('id') required this.debtId,
    @QueryParam('full') this.full,
  });

  final String debtId;
  final bool? full;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo;
    final details = ref.watch(debtDetailsProvider(debtId)).value;
    final state = ref.watch(debtTransactionProvider(debtId));
    final notifier = ref.read(debtTransactionProvider(debtId).notifier);
    final saving = ref.watch(debtSheetProvider(debtId)).isSaving;
    final wallets = ref.watch(walletsProvider).value ?? const <WalletSummary>[];

    final shakeController = useAnimationController(duration: 300.ms);
    final descriptionController = useTextEditingController();
    final descriptionFocus = useFocusNode();
    final tagsFocus = useFocusNode();

    useEffect(() {
      if (details == null) return null;
      Future.microtask(() => notifier.seed(details, full: full ?? false));
      return null;
    }, [details]);

    // Keep the description field in sync with state resets.
    useEffect(() {
      if (descriptionController.text != state.description) {
        descriptionController.value = TextEditingValue(
          text: state.description,
          selection: TextSelection.collapsed(offset: state.description.length),
        );
      }
      return null;
    }, [state.description]);

    void unfocusAll() {
      descriptionFocus.unfocus();
      tagsFocus.unfocus();
      FocusManager.instance.primaryFocus?.unfocus();
    }

    void shake() {
      AppVibrations.error();
      shakeController.forward(from: 0);
    }

    final debt = details?.summary.debt;
    final lent = debt?.direction == DebtDirection.lent;
    // Preselected: the loan's wallet while it exists, else the primary one.
    final wallet = state.walletPicked ? state.wallet : _defaultWallet(details, wallets);

    Future<void> pickWallet() async {
      unfocusAll();
      final picked = await DebtWalletSheet.show(context, wallets: wallets, selectedId: wallet?.id);
      if (picked != null) notifier.pickWallet(picked.wallet);
    }

    Future<void> pickDate() async {
      unfocusAll();
      final picked = await DatePickerSheet.show(context, initial: state.date, maxDate: DateTime.now());
      if (picked != null) notifier.setDate(picked);
    }

    Future<void> onCommit() async {
      unfocusAll();
      final d = details;
      if (d == null) return;
      if (!(state.amount?.isPositive ?? false)) {
        shake();
        notifier.flagMissingAmount();
        return;
      }
      final ok = await notifier.commit(d, wallet);
      if (!context.mounted) return;
      if (ok) {
        context.router.maybePop();
      } else {
        shake();
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colors.isDark ? colors.bgColor : UIColorToken.cararra,
      appBar: UIAppbar(
        title: lent ? l10n.debt_got_part_back : l10n.debt_paid_part,
        backTap: () => context.router.maybePop(),
      ),
      // Tap anywhere outside the text fields → drop the keyboard.
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: unfocusAll,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
            child: Column(
              children: [
                // Header: debt currency | wallet the money moves through.
                UiWalletInfoMenu(
                  name: wallet?.name ?? l10n.debt_not_in_wallet,
                  color: wallet?.color.color ?? colors.secondContentColor,
                  currencyType: state.currency,
                  onSelectWallet: wallets.isEmpty ? null : pickWallet,
                ),
                const UISpace.vert(12),

                // Amount.
                AmountEntryDisplay(input: state.amountInput)
                    .animate(controller: shakeController, autoPlay: false)
                    .shakeX(hz: 10, amount: 6, duration: 300.ms),
                const UISpace.vert(4),
                // Money through a wallet in another currency is converted at save time.
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

                // Description and tags: stored with the wallet movement only.
                if (wallet != null) ...[
                  UIInputField(
                    controller: descriptionController,
                    focusNode: descriptionFocus,
                    style: UIInputFieldStyle.borderless,
                    centered: true,
                    hintText: l10n.transaction_description_placeholder,
                    maxLength: kMaxDescriptionLength,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    textStyle: typo.inter.bodyMedium,
                    onChanged: notifier.setDescription,
                    onSubmitted: (_) => tagsFocus.requestFocus(),
                  ),
                  const UISpace.vert(4),
                  UiTagInput(
                    key: const ValueKey('debt-transaction-tags'),
                    tags: state.tags,
                    focusNode: tagsFocus,
                    hintText: l10n.transaction_tags_placeholder,
                    maxTags: kMaxTagsPerTransaction,
                    maxTagLength: kMaxTagLength,
                    suggestions: notifier.suggestTags,
                    suggestionsStyle: UiTagSuggestionsStyle.keyboardBar,
                    onChanged: notifier.setTags,
                    onLimitReached: notifier.onTagLimitReached,
                    onSubmitted: unfocusAll,
                  ),
                ] else
                  UiFormHint(
                    icon: UIIconToken.icons.general.infoCircle,
                    text: l10n.debt_wallet_only_debt,
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

                // Date.
                UiChip(
                  label: state.date.formatChipDate(today: l10n.common_today, yesterday: l10n.common_yesterday),
                  onTap: pickDate,
                ),
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

                // One action: income when a debt comes back to me, expense when I pay it.
                Row(
                  children: [
                    Expanded(
                      child: UiTypeActionButton(
                        label: lent ? l10n.common_income : l10n.common_expense,
                        style: lent ? UiTypeActionStyle.income : UiTypeActionStyle.expense,
                        enabled: !saving && details != null,
                        onTap: onCommit,
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

/// The loan's wallet while it exists, else the primary one, else the first.
WalletSummary? _defaultWallet(DebtDetails? d, List<WalletSummary> wallets) {
  if (d == null) return null;
  final principal = d.principalWalletDeleted ? null : d.principalWalletId;
  return wallets.where((w) => w.id == principal).firstOrNull ??
      wallets.where((w) => w.isPrimary).firstOrNull ??
      wallets.firstOrNull;
}
