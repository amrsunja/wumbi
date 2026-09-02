import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../wallet/ui/widgets/currency_picker_sheet.dart';

class CurrencyStep extends StatelessWidget {
  const CurrencyStep({super.key, required this.selected, required this.onChanged});

  final CurrencyType selected;
  final ValueChanged<CurrencyType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.onboarding_currency_title,
            style: UITextStyleToken.interSemiBold.copyWith(fontSize: 26, color: colors.contentColor),
          ),
          const UISpace.vert(12),
          Text(
            l10n.onboarding_currency_subtitle,
            textAlign: TextAlign.center,
            style: UITextStyleToken.interRegular.copyWith(fontSize: 15, color: colors.secondContentColor, height: 1.5),
          ),
          const UISpace.vert(40),
          UiSelectButton(
            title: '${selected.code} (${selected.symbol}) · ${selected.displayName}',
            style: UITextStyleToken.interSemiBold.copyWith(fontSize: 18, color: colors.contentColor),
            onTap: () async {
              final picked = await CurrencyPickerSheet.show(
                context,
                title: l10n.currency_pick_title,
                selected: selected,
                pinned: [selected],
              );
              if (picked != null) onChanged(picked);
            },
          ),
        ],
      ),
    );
  }
}
