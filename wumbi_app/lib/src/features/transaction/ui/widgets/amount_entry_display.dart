import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/amount_input.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';

/// The amount being typed, exactly as on the Transaction screen: Montserrat
/// `input` style, the last typed character pops in elastically
/// ([UiAmountText]), casper while empty ("0"), scaled down to fit. Shared by
/// every numpad (Transaction screen, amount sheet, transfer "received") so
/// they read as one control.
///
/// [prefix] (sign, currency symbol) is drawn in the same style but outside
/// the animated text, so only the digits pop.
class AmountEntryDisplay extends StatelessWidget {
  const AmountEntryDisplay({super.key, required this.input, this.prefix = ''});

  /// Raw [AmountInput] string ('' = nothing typed yet).
  final String input;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.typo.montserrat.input.copyWith(color: input.isEmpty ? colors.secondContentColor : null);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          if (prefix.isNotEmpty) Text(prefix, style: style),
          UiAmountText(text: AmountInput.display(input), style: style),
        ],
      ),
    );
  }
}
