import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../wallet/ui/widgets/currency_picker_sheet.dart';
import '../widgets/currency_coin.dart';
import '../widgets/currency_symbols_background.dart';
import '../widgets/onboarding_typography.dart';

/// Onboarding index 5 — mandatory base currency (persisted on Continue).
///
/// A levitating coin carries the selected symbol; faint currencies drift in
/// the background. Tapping the coin or the picker row opens the sheet.
class OnboardingCurrencyPage extends StatelessWidget {
  const OnboardingCurrencyPage({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.onNext,
  });

  final CurrencyType selected;
  final ValueChanged<CurrencyType> onChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Future<void> pick() async {
      final picked = await CurrencyPickerSheet.show(
        context,
        title: l10n.currency_pick_title,
        selected: selected,
        pinned: [selected],
      );
      if (picked != null && picked != selected) {
        AppVibrations.selection();
        onChanged(picked);
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        const CurrencySymbolsBackground().animate().fadeIn(duration: UIAnim.slow),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CurrencyCoin(
                      symbol: selected.symbol,
                      code: selected.code,
                      onTap: pick,
                    ).uiElasticScaleIn(begin: 0.5, duration: const Duration(milliseconds: 1100)),
                    const UISpace.vert(12),
                    Text(
                      l10n.onboarding_currency_title,
                      textAlign: TextAlign.center,
                      style: OnboardingTypography.title(context.typo),
                    ).uiFadeSlideIn(delay: UIAnim.stagger * 2),
                    const UISpace.vert(14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        l10n.onboarding_currency_subtitle,
                        textAlign: TextAlign.center,
                        style: OnboardingTypography.body(context.typo),
                      ),
                    ).uiFadeSlideIn(delay: UIAnim.stagger * 3),
                    const UISpace.vert(28),
                    _PickerRow(selected: selected, onTap: pick).uiFadeSlideIn(delay: UIAnim.stagger * 4),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: UiPrimaryButton(
                    label: l10n.common_continue,
                    onTap: onNext,
                  ).uiElasticScaleIn(delay: UIAnim.stagger * 5, begin: 0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pill: "USD · US Dollar ⌄" on the foreground colour, soft shadow.
class _PickerRow extends StatelessWidget {
  const _PickerRow({required this.selected, required this.onTap});

  final CurrencyType selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return UITap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 14, 12),
        decoration: BoxDecoration(
          color: colors.fgColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: UIShadowToken.dropShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(
              selected.code,
              style: context.typo.inter.bold.copyWith(fontSize: 16, color: UIColorToken.blue),
            ),
            Text(
              '·',
              style: context.typo.inter.bold.copyWith(fontSize: 16, color: colors.secondContentColor),
            ),
            Flexible(
              child: AnimatedSwitcher(
                duration: UIAnim.fast,
                child: Text(
                  selected.displayName,
                  key: ValueKey(selected.code),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typo.inter.rowTitle,
                ),
              ),
            ),
            UIIcon(UIIconToken.icons.arrows.chevronDown, size: 18),
          ],
        ),
      ),
    );
  }
}
