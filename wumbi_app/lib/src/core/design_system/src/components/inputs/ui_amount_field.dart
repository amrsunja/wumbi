import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app_ui.dart';

/// Big centred amount typed on the native numeric keyboard, with the
/// currency symbol hugging it (`120$`). Used by the Create/Edit Wallet,
/// Budget and Debt forms.
///
/// Only digits go in — plus one decimal point when [decimals] > 0 (a `,`
/// from the keyboard becomes `.`). Anything else, typed or pasted, is
/// refused as a whole and [onRejected] fires. Leading zeros collapse
/// (`007` → `7`, `.5` → `0.5`).
///
/// [value] is the raw unsigned amount (`''` = empty, shown as the `0` hint);
/// [onChanged] reports every accepted edit. Outside changes to [value]
/// (suggestion chip, currency switch) replace the text.
class UiAmountField extends StatefulWidget {
  const UiAmountField({
    super.key,
    required this.value,
    required this.suffix,
    required this.onChanged,
    this.decimals = 2,
    this.maxIntegerDigits = 12,
    this.prefix = '',
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.onRejected,
  });

  final String value;

  /// Currency symbol, drawn right after the amount.
  final String suffix;

  /// Sign drawn before the amount (`-` for a negative wallet balance).
  final String prefix;
  final ValueChanged<String> onChanged;

  /// Fraction digits allowed; 0 = whole numbers only (no decimal key).
  final int decimals;
  final int maxIntegerDigits;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;

  /// A keystroke or paste was refused (non-digit, too many digits).
  final VoidCallback? onRejected;

  @override
  State<UiAmountField> createState() => _UiAmountFieldState();
}

class _UiAmountFieldState extends State<UiAmountField> {
  static const double _cursorWidth = 2;

  late final _controller = TextEditingController(text: widget.value);
  FocusNode? _ownFocus;

  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void didUpdateWidget(UiAmountField old) {
    super.didUpdateWidget(old);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final amountStyle = theme.typo.montserrat.formAmount;
    final muted = colors.secondContentColor;
    final empty = widget.value.isEmpty;

    final field = IntrinsicWidth(
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        keyboardType: widget.decimals > 0 ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
        autocorrect: false,
        enableSuggestions: false,
        textAlign: TextAlign.center,
        cursorColor: UIColorToken.blue,
        cursorWidth: _cursorWidth,
        style: amountStyle,
        inputFormatters: [
          _AmountFormatter(
            decimals: widget.decimals,
            maxIntegerDigits: widget.maxIntegerDigits,
            onRejected: widget.onRejected,
          ),
        ],
        onChanged: widget.onChanged,
        // The number pad has no Done key: a tap anywhere else closes it.
        onTapOutside: (_) => _focus.unfocus(),
        decoration: InputDecoration(
          isDense: true,
          isCollapsed: true,
          hintText: '0',
          hintStyle: amountStyle.copyWith(color: muted),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );

    // The whole row is the tap target: the field itself is only as wide as
    // the digits (a lone "0"). Part of the field's tap region, so a tap on the
    // symbol doesn't count as "outside" and drop the keyboard.
    return TextFieldTapRegion(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? _focus.requestFocus : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (widget.prefix.isNotEmpty)
                Text(widget.prefix, style: amountStyle.copyWith(color: empty ? muted : null)),
              Flexible(child: field),
              // A typed amount reserves room for the caret after it
              // (cursor + 1px gap); pull the symbol back so it hugs the digits.
              Transform.translate(
                offset: Offset(empty ? 0 : -(_cursorWidth + 1), 0),
                child: Text(widget.suffix, style: theme.typo.inter.display.copyWith(color: muted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Digits + at most one `.` (when [decimals] > 0), within the digit limits.
/// A refused edit keeps the old text whole — a paste of `12a` adds nothing.
class _AmountFormatter extends TextInputFormatter {
  _AmountFormatter({required this.decimals, required this.maxIntegerDigits, this.onRejected});

  final int decimals;
  final int maxIntegerDigits;
  final VoidCallback? onRejected;

  static final _shape = RegExp(r'^\d*(\.\d*)?$');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text.replaceAll(',', '.');
    if (raw == oldValue.text) return newValue.copyWith(text: raw);

    TextEditingValue reject() {
      onRejected?.call();
      return oldValue;
    }

    if (!_shape.hasMatch(raw)) return reject();
    final dot = raw.indexOf('.');
    if (dot != -1 && decimals == 0) return reject();

    final typedWhole = dot == -1 ? raw : raw.substring(0, dot);
    final fraction = dot == -1 ? null : raw.substring(dot + 1);
    if (fraction != null && fraction.length > decimals) return reject();

    // 007 → 7; a bare point gets its 0 (.5 → 0.5).
    var whole = typedWhole.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (dot != -1 && whole.isEmpty) whole = '0';
    if (whole.length > maxIntegerDigits) return reject();

    final text = fraction == null ? whole : '$whole.$fraction';
    if (text == raw) return newValue.copyWith(text: text);
    final shift = whole.length - typedWhole.length;
    final offset = (newValue.selection.end + shift).clamp(0, text.length);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
