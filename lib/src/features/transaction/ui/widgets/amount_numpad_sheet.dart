import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/amount_input.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';

/// Numpad in a bottom sheet (wallet initial balance). Resolves with the raw
/// amount string, or null when dismissed.
abstract class AmountNumpadSheet {
  static Future<String?> show(
    BuildContext context, {
    required CurrencyType currency,
    required String initial,
    String? title,
    bool allowNegative = false,
  }) =>
      UIModalSheet.modalSheet<String>(
        context: context,
        title: title,
        fitContent: true,
        child: _AmountNumpad(currency: currency, initial: initial, allowNegative: allowNegative),
      );
}

class _AmountNumpad extends StatefulWidget {
  const _AmountNumpad({required this.currency, required this.initial, required this.allowNegative});

  final CurrencyType currency;
  final String initial;
  final bool allowNegative;

  @override
  State<_AmountNumpad> createState() => _AmountNumpadState();
}

class _AmountNumpadState extends State<_AmountNumpad> {
  late String _value = widget.initial.startsWith('-') ? widget.initial.substring(1) : widget.initial;
  late bool _negative = widget.initial.startsWith('-');

  void _apply(AmountInputResult r) {
    if (r.rejected) {
      AppVibrations.error();
      return;
    }
    setState(() => _value = r.value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final display = '${_negative ? '-' : ''}${widget.currency.symbol} ${AmountInput.display(_value)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const UISpace.vert(8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              display,
              style: UITextStyleToken.montserratLight.copyWith(fontSize: 40, color: colors.contentColor),
            ),
          ),
          if (widget.allowNegative)
            UITap(
              onTap: () => setState(() => _negative = !_negative),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text('+ / −', style: UITextStyleToken.caption(colors)),
              ),
            ),
          const UISpace.vert(16),
          UiNumpad(
            dotEnabled: widget.currency.scale > 0,
            onDigit: (d) => _apply(AmountInput.digit(_value, d, widget.currency)),
            onDot: () => _apply(AmountInput.dot(_value, widget.currency)),
            onBackspace: () => setState(() => _value = AmountInput.backspace(_value)),
            onClear: () => setState(() => _value = AmountInput.clear()),
          ),
          const UISpace.vert(16),
          UiPrimaryButton(
            label: l10n.common_confirm,
            onTap: () => Navigator.of(context).pop('${_negative && _value.isNotEmpty ? '-' : ''}$_value'),
          ),
        ],
      ),
    );
  }
}
