import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/money/amount_input.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/budget_period_type.dart';
import '../../../core/utils/enums/rollover_mode.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../transaction/ui/widgets/date_picker_sheet.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../../wallet/ui/widgets/currency_picker_sheet.dart';
import '../../wallet/ui/widgets/wallet_multi_picker_sheet.dart';
import '../data/budget_repository.dart';
import 'budget_form_notifier.dart';
import 'budget_labels.dart';
import 'widgets/budget_sheets.dart';

/// Create / edit a budget (spec B&D §6.6). Same anatomy as the Transaction
/// screen: currency | wallets header, big limit on an on-page numpad, name +
/// #tags (keyboard tag bar), then period chips and a "what counts" hint.
@RoutePage()
class BudgetFormPage extends HookConsumerWidget {
  const BudgetFormPage({
    super.key,
    @QueryParam('budgetId') this.budgetId,
    @QueryParam('walletId') this.walletId,
    @QueryParam('tagId') this.tagId,
  });

  final String? budgetId;
  final String? walletId;
  final String? tagId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo;
    final args = BudgetFormArgs(budgetId: budgetId, walletId: walletId, tagId: tagId);
    final state = ref.watch(budgetFormProvider(args));
    final notifier = ref.read(budgetFormProvider(args).notifier);
    final wallets = ref.watch(walletsProvider).value ?? const <WalletSummary>[];
    final base = ref.watch(baseCurrencyProvider);

    final shakeController = useAnimationController(duration: 300.ms);
    final nameController = useTextEditingController();
    final nameFocus = useFocusNode();
    final tagsFocus = useFocusNode();

    // Locale's first day of the week as the weekly default (create mode).
    final firstDayIndex = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    useEffect(() {
      Future.microtask(() => notifier.initWeekday(firstDayIndex == 0 ? DateTime.sunday : firstDayIndex));
      return null;
    }, const []);

    // Prefill the name once the existing budget loads.
    useEffect(() {
      if (nameController.text != state.name) {
        nameController.value = TextEditingValue(
          text: state.name,
          selection: TextSelection.collapsed(offset: state.name.length),
        );
      }
      return null;
    }, [state.existing?.id]);

    final selectedWallets = wallets.where((w) => state.walletIds.contains(w.id)).toList();

    void unfocusAll() {
      nameFocus.unfocus();
      tagsFocus.unfocus();
      FocusManager.instance.primaryFocus?.unfocus();
    }

    Future<void> pickCurrency() async {
      unfocusAll();
      final picked = await CurrencyPickerSheet.show(
        context,
        title: l10n.currency_pick_title,
        selected: state.currency,
        pinned: [state.currency, base, ...selectedWallets.map((w) => w.currency)],
      );
      if (picked != null) notifier.setCurrency(picked);
    }

    Future<void> pickWallets() async {
      unfocusAll();
      final picked = await WalletMultiPickerSheet.show(
        context,
        wallets: wallets,
        selected: state.walletIds,
        title: l10n.budget_wallets,
        allLabel: l10n.budget_all_wallets,
      );
      if (picked != null) notifier.setWallets(picked);
    }

    Future<void> pickPeriod() async {
      unfocusAll();
      final picked = await BudgetPeriodSheet.show(context, selected: state.period);
      if (picked != null) notifier.setPeriod(picked);
    }

    Future<void> pickStart() async {
      unfocusAll();
      switch (state.period) {
        case BudgetPeriodType.monthly:
          final day = await MonthDaySheet.show(context, selected: state.monthDay);
          if (day != null) notifier.setMonthDay(day);
        case BudgetPeriodType.weekly:
          final weekday = await WeekdaySheet.show(context, selected: state.weekday);
          if (weekday != null) notifier.setWeekday(weekday);
        case BudgetPeriodType.yearly:
          final yearStart = await DatePickerSheet.show(context, initial: state.yearlyStart);
          if (yearStart != null) notifier.setYearlyStart(yearStart);
        case BudgetPeriodType.custom:
          final first = await DatePickerSheet.show(context, initial: state.customStart);
          if (first != null) notifier.setCustomStart(first);
      }
    }

    Future<void> pickCustomEnd() async {
      unfocusAll();
      final d = await DatePickerSheet.show(context, initial: state.customEnd, minDate: state.customStart);
      if (d != null) notifier.setCustomEnd(d);
    }

    Future<void> pickRollover() async {
      unfocusAll();
      final picked = await RolloverSheet.show(context, selected: state.rollover);
      if (picked != null) notifier.setRollover(picked);
    }

    Future<void> save() async {
      unfocusAll();
      final ok = await notifier.save();
      if (!context.mounted) return;
      if (!ok) {
        AppVibrations.error();
        shakeController.forward(from: 0);
        return;
      }
      AppVibrations.medium();
      context.router.maybePop();
    }

    Future<void> delete() async {
      unfocusAll();
      final name = state.existing?.name ?? notifier.autoName();
      final confirmed = await UIAlertDialog.confirm(
        context,
        title: l10n.budget_delete_title(name),
        message: l10n.budget_delete_message,
        confirmLabel: l10n.common_delete,
        cancelLabel: l10n.common_cancel,
        destructive: true,
      );
      if (!confirmed) return;
      final repo = ref.read(budgetRepositoryProvider);
      final events = ref.read(appEventProvider);
      final id = budgetId!;
      final deletedAt = await notifier.delete();
      if (deletedAt == null || !context.mounted) return;
      AppVibrations.heavy();
      events.send(ShowUndoEvent(
        l10n.budget_deleted,
        actionLabel: l10n.common_undo,
        onUndo: () => BudgetFormNotifier.restore(repo, events, id, deletedAt),
      ));
      // Close the form and the deleted budget's details page under it (if
      // any) in one go — back to wherever the budget was opened from.
      context.router.popUntil(
        (route) => route.settings.name != BudgetFormRoute.name && route.settings.name != BudgetDetailsRoute.name,
      );
    }

    // Header right side: "All wallets" / the wallet / "Card, Cash".
    final walletLabel = selectedWallets.isEmpty
        ? l10n.budget_all_wallets
        : selectedWallets.map((w) => w.name).join(', ');
    final walletColor =
        selectedWallets.length == 1 ? selectedWallets.single.color.color : colors.secondContentColor;
    final hasScope = selectedWallets.isNotEmpty || state.tags.isNotEmpty;

    final startLabel = switch (state.period) {
      BudgetPeriodType.monthly => l10n.budget_day_of_month(state.monthDay),
      BudgetPeriodType.weekly => WeekdaySheet.name(state.weekday),
      BudgetPeriodType.yearly => state.yearlyStart.formatShortDate(),
      BudgetPeriodType.custom => state.customStart.formatMediumDate(),
    };

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colors.isDark ? colors.bgColor : UIColorToken.cararra,
      appBar: UIAppbar(
        title: state.isEdit ? l10n.common_edit : l10n.budget_new,
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
                // Header: budget currency | wallets in scope.
                UiWalletInfoMenu(
                  name: walletLabel,
                  color: walletColor,
                  currencyType: state.currency,
                  onSelectCurrency: pickCurrency,
                  onSelectWallet: wallets.isEmpty ? null : pickWallets,
                ),
                const UISpace.vert(12),

                // Limit.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: UiAmountText(
                    text: AmountInput.display(state.limitInput),
                    style: typo.montserrat.input.copyWith(
                      color: state.limitInput.isEmpty ? colors.secondContentColor : null,
                    ),
                  ),
                )
                    .animate(controller: shakeController, autoPlay: false)
                    .shakeX(hz: 10, amount: 6, duration: 300.ms),
                const UISpace.vert(4),

                // Suggested limit (create mode, never auto-filled).
                SizedBox(
                  height: 24,
                  child: AnimatedSwitcher(
                    duration: 200.ms,
                    child: state.suggestion == null || state.isEdit
                        ? const SizedBox.shrink()
                        : _SuggestionChip(
                            key: ValueKey(state.suggestion),
                            label: _suggestionLabel(context, state),
                            onTap: notifier.applySuggestion,
                          ),
                  ),
                ),
                const UISpace.vert(8),

                // Name.
                UIInputField(
                  controller: nameController,
                  focusNode: nameFocus,
                  style: UIInputFieldStyle.borderless,
                  centered: true,
                  // Empty name → the auto name is saved; show it once there
                  // is a scope to derive it from.
                  hintText: hasScope ? notifier.autoName() : l10n.budget_name_placeholder,
                  maxLength: kMaxBudgetNameLength,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  textStyle: typo.inter.bodyMedium,
                  onChanged: notifier.setName,
                  onSubmitted: (_) => tagsFocus.requestFocus(),
                ),
                const UISpace.vert(4),

                // Tags: pick from the keyboard bar or type a new one.
                UiTagInput(
                  key: ValueKey('budget-tags-${state.existing?.id ?? 'new'}'),
                  tags: state.tags,
                  focusNode: tagsFocus,
                  hintText: l10n.transaction_tags_placeholder,
                  maxTags: kMaxBudgetTags,
                  maxTagLength: kMaxTagLength,
                  suggestions: notifier.suggestTags,
                  suggestionsStyle: UiTagSuggestionsStyle.keyboardBar,
                  onChanged: notifier.setTags,
                  onLimitReached: notifier.onTagLimitReached,
                  onSubmitted: unfocusAll,
                ),
                const Spacer(),

                // Count planned: switch + one line on what it does.
                _ToggleRow(
                  title: l10n.budget_count_planned,
                  description: l10n.budget_count_planned_desc,
                  value: state.includePlanned,
                  onChanged: (v) {
                    AppVibrations.selection();
                    notifier.setIncludePlanned(v);
                  },
                ),
                const UISpace.vert(8),

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

                // Period chips.
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
                            icon: UIIconToken.icons.mediaDevices.repeat01,
                            label: BudgetLabels.periodType(l10n, state.period),
                            highlighted: true,
                            onTap: pickPeriod,
                          ),
                          UiChip(
                            icon: UIIconToken.icons.time.calendar,
                            label: startLabel,
                            onTap: pickStart,
                          ),
                          if (state.period.isCustom)
                            UiChip(
                              label: '→ ${state.customEnd.formatMediumDate()}',
                              onTap: pickCustomEnd,
                            )
                          else
                            UiChip(
                              label: BudgetLabels.rollover(l10n, state.rollover),
                              highlighted: state.rollover != RolloverMode.none,
                              onTap: pickRollover,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Period chips.
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
                        ],
                      ),
                    ),
                  ),
                ),

                // What this budget actually counts, in words.
                UiFormHint(
                  icon: UIIconToken.icons.general.infoCircle,
                  text: _scopeSentence(context, state, selectedWallets),
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

                // Bottom bar: Delete (edit) / Cancel (create) · Save.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (state.isEdit)
                        UiTextButton(
                          label: l10n.common_delete,
                          style: UiTextButtonStyle.secondary,
                          enabled: !state.isSaving && !state.isLoading,
                          onTap: delete,
                        )
                      else
                        UiTextButton(
                          label: l10n.common_cancel,
                          style: UiTextButtonStyle.secondary,
                          enabled: !state.isSaving,
                          onTap: () => context.router.maybePop(),
                        ),
                      UiTextButton(
                        label: l10n.common_save,
                        // Stays tappable without a limit so the tap can shake.
                        enabled: !state.isSaving && !state.isLoading,
                        onTap: save,
                      ),
                    ],
                  ),
                ),
                const UISpace.vert(8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// "Suggested: €380 · avg. of last 3 months".
  static String _suggestionLabel(BuildContext context, BudgetFormState s) {
    final l10n = context.l10n;
    final amount = s.suggestion!.format();
    return switch (s.period) {
      BudgetPeriodType.weekly => l10n.budget_suggested_weeks(amount),
      BudgetPeriodType.yearly => l10n.budget_suggested_years(amount),
      _ => l10n.budget_suggested_months(amount),
    };
  }

  /// The single most important line for comprehension: what this budget
  /// actually counts, in words.
  static String _scopeSentence(BuildContext context, BudgetFormState s, List<WalletSummary> wallets) {
    final l10n = context.l10n;
    final walletNames = wallets.map((w) => w.name).join(', ');
    final tags = s.tags.map((t) => '#$t').toList();
    final tagText = tags.length <= 1
        ? tags.join()
        : '${tags.sublist(0, tags.length - 1).join(', ')} ${l10n.budget_scope_or} ${tags.last}';
    if (wallets.isEmpty && tags.isEmpty) return l10n.budget_scope_all;
    if (tags.isEmpty) return l10n.budget_scope_wallets(walletNames);
    if (wallets.isEmpty) return l10n.budget_scope_tags(tagText);
    return l10n.budget_scope_both(walletNames, tagText);
  }
}

/// Tappable suggestion pill (never auto-fills the limit).
class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return UITap(
      onTap: () {
        AppVibrations.light();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: UIColorToken.blue.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.typo.inter.caption.copyWith(color: UIColorToken.blue),
        ),
      ),
    );
  }
}

/// Title + short explanation on the left, compact switch on the right; the
/// whole row toggles.
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.title, required this.description, required this.value, required this.onChanged});

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    return UITap(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Text(title, style: typo.label),
                  Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: typo.caption),
                ],
              ),
            ),
            UISwitch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
