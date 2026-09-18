import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/money/amount_input.dart';
import '../../../core/money/money.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../wallet/ui/widgets/currency_picker_sheet.dart';
import '../../wallet/ui/widgets/wallet_picker_sheet.dart';
import 'transaction_notifier.dart';
import 'transaction_state.dart';
import 'widgets/date_picker_sheet.dart';
import 'widgets/repeat_labels.dart';
import 'widgets/repeat_picker_sheet.dart';
import 'widgets/transfer_sheet.dart';

/// The most important screen: create (one-tap commit, stays open), edit a
/// stored transaction, or edit a subscription (`ruleId` — the recurring rule
/// itself, reached from the Subscriptions page).
@RoutePage()
class TransactionPage extends HookConsumerWidget {
  const TransactionPage({
    super.key,
    @QueryParam('walletId') this.walletId,
    @QueryParam('transactionId') this.transactionId,
    @QueryParam('ruleId') this.ruleId,
  });

  final String? walletId;
  final String? transactionId;

  /// Subscription edit mode.
  final String? ruleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo;
    final args = TransactionArgs(walletId: walletId, transactionId: transactionId, ruleId: ruleId);
    final state = ref.watch(transactionNotifierProvider(args));
    final notifier = ref.read(transactionNotifierProvider(args).notifier);
    final base = ref.watch(baseCurrencyProvider);

    final shakeController = useAnimationController(duration: 300.ms);
    final descriptionController = useTextEditingController();
    final descriptionFocus = useFocusNode();
    final tagsFocus = useFocusNode();

    // Keep the description field in sync with state resets / edit prefill.
    useEffect(() {
      if (descriptionController.text != state.description) {
        descriptionController.value = TextEditingValue(
          text: state.description,
          selection: TextSelection.collapsed(offset: state.description.length),
        );
      }
      return null;
    }, [state.description]);

    void shakeAmount() {
      AppVibrations.error();
      shakeController.forward(from: 0);
    }

    void unfocusAll() {
      descriptionFocus.unfocus();
      tagsFocus.unfocus();
      FocusManager.instance.primaryFocus?.unfocus();
    }

    Future<void> onTapType(TransactionType type) async {
      descriptionFocus.unfocus();
      tagsFocus.unfocus();
      if (!state.canCommit) {
        shakeAmount();
        notifier.validateForCommit();
        return;
      }
      await notifier.commit(type);
    }

    Future<void> onTapTransfer() async {
      descriptionFocus.unfocus();
      tagsFocus.unfocus();
      if (state.wallets.length < 2) {
        final choice = await UIAlertDialog.choose(
          context,
          title: l10n.transaction_need_second_wallet_title,
          message: l10n.transaction_need_second_wallet_message,
          actions: [
            UIDialogAction(label: l10n.common_cancel),
            UIDialogAction(label: l10n.dashboard_new_wallet, primary: true),
          ],
        );
        if (choice == 1 && context.mounted) context.router.push(WalletFormRoute());
        return;
      }
      if (!state.canCommit) {
        shakeAmount();
        notifier.validateForCommit();
        return;
      }
      final choice = await TransferSheet.show(
        context,
        source: state.wallet!,
        sent: state.walletMoney!,
        wallets: state.wallets,
      );
      if (choice == null) return;
      await notifier.transfer(target: choice.target, received: choice.received, rate: choice.rate);
    }

    Future<void> pickCurrency() async {
      final w = state.wallet;
      final picked = await CurrencyPickerSheet.show(
        context,
        title: l10n.currency_pick_title,
        selected: state.entryCurrency,
        pinned: [if (w != null) w.currency, base],
      );
      if (picked != null) notifier.setEntryCurrency(picked);
    }

    Future<void> pickWallet() async {
      final picked = await WalletPickerSheet.show(
        context,
        wallets: state.wallets,
        title: state.isTransferRuleEdit ? l10n.subscriptions_from_wallet : l10n.wallet_switch_title,
        selectedId: state.wallet?.id,
        excludeId: state.isTransferRuleEdit ? state.counterpart?.walletId : null,
        requireCurrency: state.isEdit ? state.wallet?.currency : null,
      );
      if (picked != null) notifier.setWallet(picked);
    }

    // Transfer subscription only: the destination side of the rule.
    Future<void> pickToWallet() async {
      final counterpart = state.counterpart;
      if (counterpart == null) return;
      final picked = await WalletPickerSheet.show(
        context,
        wallets: state.wallets,
        title: l10n.subscriptions_to_wallet,
        selectedId: counterpart.walletId,
        excludeId: state.wallet?.id,
        requireCurrency: counterpart.amount.currency,
      );
      if (picked != null) notifier.setRuleToWallet(picked);
    }

    Future<void> pickDate() async {
      final picked = await DatePickerSheet.show(context, initial: state.date);
      if (picked != null) notifier.setDate(picked);
    }

    Future<void> pickRepeat() async {
      final picked = await RepeatPickerSheet.show(
        context,
        selected: state.repeat,
        // A subscription always repeats: "Never" is not an option.
        excludeNever: state.isRuleEdit,
        title: state.isRuleEdit ? l10n.subscriptions_frequency : null,
      );
      if (picked != null) notifier.setRepeat(picked);
    }

    Future<void> onDelete() async {
      if (state.isRuleEdit) {
        final stop = await UIAlertDialog.confirm(
          context,
          title: l10n.repeat_delete_title,
          message: l10n.repeat_delete_message,
          confirmLabel: l10n.subscriptions_stop,
          cancelLabel: l10n.common_cancel,
          destructive: true,
        );
        if (!stop) return;
        final stopped = await notifier.stopSubscription();
        if (stopped && context.mounted) context.router.maybePop();
        return;
      }
      final generated = state.existing?.recurringRuleId != null;
      if (generated) {
        final choice = await UIAlertDialog.choose(
          context,
          title: l10n.transaction_delete_title,
          actions: [
            UIDialogAction(label: l10n.transaction_delete_this_one, destructive: true),
            UIDialogAction(label: l10n.transaction_delete_and_stop, destructive: true),
            UIDialogAction(label: l10n.common_cancel),
          ],
        );
        if (choice == null || choice == 2) return;
        final ok = await notifier.delete(stopRule: choice == 1);
        if (ok && context.mounted) context.router.maybePop();
        return;
      }
      final ok = await UIAlertDialog.confirm(
        context,
        title: l10n.transaction_delete_title,
        confirmLabel: l10n.common_delete,
        cancelLabel: l10n.common_cancel,
        destructive: true,
      );
      if (!ok) return;
      final deleted = await notifier.delete();
      if (deleted && context.mounted) context.router.maybePop();
    }

    Future<void> onSave() async {
      if (!state.canCommit) {
        shakeAmount();
        return;
      }
      final ok = await notifier.saveEdit();
      if (ok && context.mounted) context.router.maybePop();
    }

    final wallet = state.wallet;
    final walletColor = wallet?.color.color ?? colors.secondContentColor;
    final typeColor = switch (state.editingType) {
      TransactionType.income => UIColorToken.blue,
      TransactionType.expense => colors.expenseColor,
      TransactionType.transfer => colors.secondContentColor,
      null => colors.secondContentColor,
    };

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colors.isDark ? colors.bgColor : UIColorToken.cararra,
      appBar: UIAppbar(
        title: state.isRuleEdit
            ? l10n.subscriptions_edit_title
            : state.isEdit
                ? l10n.transaction_edit_title
                : '',
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
              // Header: entry currency | target wallet.
              UiWalletInfoMenu(
                name: wallet?.name ?? '—',
                color: walletColor,
                currencyType: state.entryCurrency,
                // A subscription keeps its currency; a transfer subscription
                // may still re-point its source wallet.
                onSelectCurrency: state.isTransferEdit || state.isRuleEdit ? null : pickCurrency,
                onSelectWallet: (state.isTransferEdit && !state.isRuleEdit) || state.wallets.length < 2
                    ? null
                    : pickWallet,
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
              _HintLine(state: state, onRetry: notifier.retryRate),
              const UISpace.vert(16),

              // Description.
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

              // Tags.
              UiTagInput(
                key: ValueKey('tags-${state.existing?.id ?? state.rule?.id ?? 'new'}'),
                tags: state.tags,
                focusNode: tagsFocus,
                hintText: l10n.transaction_tags_placeholder,
                maxTags: kMaxTagsPerTransaction,
                maxTagLength: kMaxTagLength,
                suggestions: notifier.suggestTags,
                onChanged: notifier.setTags,
                onLimitReached: notifier.onTagLimitReached,
                onSubmitted: unfocusAll,
              ),
              const Spacer(),

              // Validation message (2 s).
              AnimatedSwitcher(
                duration: 200.ms,
                child: state.validationError == null
                    ? const SizedBox(height: 16)
                    : SizedBox(
                        height: 16,
                        child: Text(
                          state.validationError!,
                          key: ValueKey(state.validationError),
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
                        // Edit mode: the loaded row is still upcoming (not counted yet).
                        if (state.isEdit && state.isExistingUpcoming)
                          UiTypePill(label: l10n.transaction_upcoming_badge, color: colors.secondContentColor),
                        if (state.isEdit && state.editingType != null)
                          // The type of a subscription never changes.
                          if (state.isTransferEdit || state.isRuleEdit)
                            UiTypePill(label: _typeLabel(context, state.editingType!), color: typeColor)
                          else ...[
                            UiTypePill(
                              label: l10n.common_income,
                              color: UIColorToken.blue,
                              selected: state.editingType == TransactionType.income,
                              onTap: () => notifier.setEditingType(TransactionType.income),
                            ),
                            UiTypePill(
                              label: l10n.common_expense,
                              color: colors.expenseColor,
                              selected: state.editingType == TransactionType.expense,
                              onTap: () => notifier.setEditingType(TransactionType.expense),
                            ),
                          ],
                        if (state.isTransferRuleEdit && state.counterpart != null)
                          UiChip(
                            label: '\u2192 ${state.counterpart!.walletName}',
                            icon: UIIconToken.icons.financeEcommerce.wallet02,
                            onTap: pickToWallet,
                          ),
                        UiChip(
                          // A subscription's date is its *next* due date.
                          label: state.isRuleEdit
                              ? l10n.repeat_next(
                                  state.date.formatChipDate(today: l10n.common_today, yesterday: l10n.common_yesterday),
                                )
                              : state.date
                                  .formatChipDate(today: l10n.common_today, yesterday: l10n.common_yesterday),
                          onTap: pickDate,
                        ),
                        if (state.repeatLocked)
                          UiChip(
                            label: l10n.transaction_repeat_part_of(repeatShortLabel(l10n, state.repeat)),
                            readOnly: true,
                            highlighted: true,
                          )
                        else if (!state.isEdit || state.isRuleEdit)
                          UiChip(
                            label: repeatShortLabel(l10n, state.repeat),
                            highlighted: !state.repeat.isNever,
                            onTap: pickRepeat,
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Future date → "Counted on <date>" (row will be stored as upcoming).
              _UpcomingHint(visible: state.willBeUpcoming, date: state.date),
              const UISpace.vert(12),

              // Numpad.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kNumpadHorzPadding),
                child: UiNumpad(
                  dotEnabled: state.entryCurrency.scale > 0,
                  onDigit: notifier.onDigit,
                  onDot: notifier.onDot,
                  onBackspace: notifier.onBackspace,
                  onClear: notifier.onClear,
                ),
              ),
              const UISpace.vert(12),

              // Bottom bar (edit): Delete (casper) on the left until the form is
              // touched, then it becomes Cancel (discard + pop). Save on the right.
              if (state.isEdit)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedSwitcher(
                      duration: 200.ms,
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(scale: Tween(begin: 0.9, end: 1.0).animate(anim), child: child),
                      ),
                      child: state.isDirty
                          ? UiTextButton(
                              key: const ValueKey('cancel'),
                              label: l10n.common_cancel,
                              style: UiTextButtonStyle.secondary,
                              enabled: !state.isSaving,
                              onTap: () => context.router.maybePop(),
                            )
                          : UiTextButton(
                              key: const ValueKey('delete'),
                              label: l10n.common_delete,
                              style: UiTextButtonStyle.secondary,
                              enabled: !state.isSaving && !state.isLoading,
                              onTap: onDelete,
                            ),
                    ),
                    UiTextButton(label: l10n.common_save, enabled: !state.isSaving && !state.isLoading, onTap: onSave),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: UiTypeActionButton(
                        label: l10n.common_transfer,
                        style: UiTypeActionStyle.transfer,
                        enabled: !state.isSaving && (state.sameCurrency || state.canCommit),
                        onTap: onTapTransfer,
                      ),
                    ),
                    Expanded(
                      child: UiTypeActionButton(
                        heroTag: kHeroFab,
                        label: l10n.common_income,
                        style: UiTypeActionStyle.income,
                        enabled: !state.isSaving && state.rateReady,
                        onTap: () => onTapType(TransactionType.income),
                      ),
                    ),
                    Expanded(
                      child: UiTypeActionButton(
                        label: l10n.common_expense,
                        style: UiTypeActionStyle.expense,
                        enabled: !state.isSaving && state.rateReady,
                        onTap: () => onTapType(TransactionType.expense),
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

  static String _typeLabel(BuildContext context, TransactionType type) => switch (type) {
        TransactionType.income => context.l10n.common_income,
        TransactionType.expense => context.l10n.common_expense,
        TransactionType.transfer => context.l10n.common_transfer,
      };
}

/// One-line "Counted on <date>" hint under the chips row, shown while the
/// chosen day is in the future (the row will be saved as *upcoming*).
/// Animates in / out so the numpad does not jump abruptly.
class _UpcomingHint extends StatelessWidget {
  const _UpcomingHint({required this.visible, required this.date});

  final bool visible;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo;
    return AnimatedSize(
      duration: 200.ms,
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: 200.ms,
        child: !visible
            ? const SizedBox(width: double.infinity, height: 0)
            : Padding(
                key: ValueKey('upcoming-${date.millisecondsSinceEpoch}'),
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    UIIcon(UIIconToken.icons.time.clock, size: 12, color: UIColorToken.blue),
                    Flexible(
                      child: Text(
                        l10n.transaction_upcoming_hint(date.formatMediumDate()),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: typo.inter.caption.copyWith(color: UIColorToken.blue),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Conversion hint / transfer counterpart line under the amount.
class _HintLine extends StatelessWidget {
  const _HintLine({required this.state, required this.onRetry});

  final TransactionState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wallet = state.wallet;
    final counterpart = state.counterpart;

    Widget line;
    if (wallet == null || state.sameCurrency) {
      line = const SizedBox.shrink();
    } else {
      switch (state.rateStatus) {
        case RateStatus.loading:
          line = const UiConversionHint(text: '', state: UiConversionHintState.loading);
        case RateStatus.error:
          line = UiConversionHint(
            text: l10n.transaction_rate_unavailable,
            state: UiConversionHintState.error,
            onTap: onRetry,
          );
        case RateStatus.ok:
        case RateStatus.stale:
        case RateStatus.none:
          final rate = state.rate;
          if (rate == null) {
            line = const SizedBox.shrink();
          } else {
            final converted = state.walletMoney ?? Money.zero(wallet.currency);
            var text = '${l10n.transaction_hint_added(converted.format(), wallet.name)} · '
                '${formatRate(rate.rate, state.entryCurrency, wallet.currency)}';
            if (rate.isStale) text += ' · ${l10n.transaction_hint_stale(rate.fetchedAt.formatShortDate())}';
            line = UiConversionHint(
              text: text,
              state: rate.isStale ? UiConversionHintState.stale : UiConversionHintState.ok,
            );
          }
      }
    }

    return SizedBox(
      height: counterpart != null ? 36 : 18,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          line,
          if (counterpart != null)
            UiConversionHint(
              text: counterpart.outgoing
                  ? l10n.transaction_counterpart_to(counterpart.walletName, counterpart.amount.format())
                  : l10n.transaction_counterpart_from(counterpart.walletName, counterpart.amount.format()),
            ),
        ],
      ),
    );
  }
}
