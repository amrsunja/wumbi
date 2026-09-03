import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/amount_input.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/enums/wallet_color.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/state_management/app_events.dart';
import '../../../../core/utils/state_management/single_events.dart';
import '../../../settings/ui/state_management/settings_provider.dart';
import '../../../transaction/ui/widgets/amount_numpad_sheet.dart';
import '../wallet_form_notifier.dart';
import 'currency_picker_sheet.dart';

/// Name · initial balance · Currency row · Primary switch · colour picker.
/// Shared by the Create/Edit Wallet page and onboarding step 3.
class WalletFormBody extends HookConsumerWidget {
  const WalletFormBody({
    super.key,
    required this.args,
    this.showPrimaryToggle = true,
    this.autofocusName = true,
  });

  final WalletFormArgs args;
  final bool showPrimaryToggle;
  final bool autofocusName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo;
    final state = ref.watch(walletFormProvider(args));
    final notifier = ref.read(walletFormProvider(args).notifier);
    final base = ref.watch(baseCurrencyProvider);

    final nameController = useTextEditingController();
    // Sync controller when the existing wallet loads.
    useEffect(() {
      if (nameController.text != state.name) {
        nameController.value = TextEditingValue(
          text: state.name,
          selection: TextSelection.collapsed(offset: state.name.length),
        );
      }
      return null;
    }, [state.existing?.id]);

    final balance = state.initialBalance;
    final balanceText = state.initialBalanceInput.isEmpty
        ? balance.format(withSymbol: false)
        : AmountInput.display(state.initialBalanceInput);
    final balanceIsZero = balance.isZero;

    Future<void> editBalance() async {
      final raw = await AmountNumpadSheet.show(
        context,
        currency: state.currency,
        initial: state.initialBalanceInput,
        allowNegative: true,
      );
      if (raw != null) notifier.setInitialBalanceInput(raw);
    }

    Future<void> pickCurrency() async {
      if (state.currencyLocked) return;
      final picked = await CurrencyPickerSheet.show(
        context,
        title: l10n.currency_pick_title,
        selected: state.currency,
        pinned: [state.currency, base],
      );
      if (picked != null) notifier.setCurrency(picked);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const UISpace.vert(24),
        UIInputField(
          controller: nameController,
          autofocus: autofocusName && !state.isEdit,
          style: UIInputFieldStyle.borderless,
          centered: true,
          hintText: l10n.wallet_name_placeholder,
          maxLength: kMaxWalletNameLength,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          textStyle: typo.inter.display,
          hintStyle: typo.inter.display.copyWith(color: colors.secondContentColor),
          onChanged: notifier.setName,
        ),
        const UISpace.vert(12),
        UITap(
          onTap: editBalance,
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
                      balanceText,
                      style: typo.montserrat.formAmount.copyWith(
                        color: balanceIsZero ? colors.secondContentColor : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const UISpace.vert(56),
        _FormRow(
          label: l10n.wallet_currency,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              if (state.currencyLocked) ...[
                UIIcon(UIIconToken.icons.security.lock01, size: 14),
                Text(l10n.wallet_has_transactions, style: typo.inter.caption),
              ] else
                Text(
                  '${state.currency.code} (${state.currency.symbol})',
                  style: typo.inter.subtitle,
                ),
              if (!state.currencyLocked)
                UIIcon(UIIconToken.icons.arrows.chevronRight, size: 18),
            ],
          ),
          onTap: state.currencyLocked ? null : pickCurrency,
        ),
        if (showPrimaryToggle)
          _FormRow(
            label: l10n.wallet_primary,
            trailing: UISwitch(
              value: state.isPrimary,
              onChanged: (v) {
                final ok = notifier.setPrimary(v);
                if (!ok) {
                  AppVibrations.light();
                  ref.read(appEventProvider).send(ShowInfoMessageEvent(l10n.wallet_pick_another_primary));
                }
              },
            ),
          ),
        const UISpace.vert(24),
        UiColorPicker<WalletColor>(
          options: WalletColor.values,
          colorOf: (c) => c.color,
          selected: state.color,
          onSelect: notifier.setColor,
        ),
      ],
    );
  }
}

class _FormRow extends StatelessWidget {
  const _FormRow({required this.label, required this.trailing, this.onTap});

  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return UITap(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: context.typo.inter.body,
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
