import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_ui.dart';

enum UIInputFieldStyle {
  /// Rounded white tile with a blue focus border.
  boxed,

  /// No border, centred text — Transaction description / wallet name.
  borderless,
}

class UIInputField extends StatelessWidget {
  const UIInputField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.label,
    this.style = UIInputFieldStyle.boxed,
    this.textStyle,
    this.hintStyle,
    this.centered = false,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.sentences,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? label;
  final UIInputFieldStyle style;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool centered;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    final borderless = style == UIInputFieldStyle.borderless;

    final effectiveTextStyle = textStyle ??
        UITextStyleToken.interMedium.copyWith(color: colors.contentColor, fontSize: 16);
    final effectiveHintStyle = hintStyle ??
        effectiveTextStyle.copyWith(color: colors.secondContentColor);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      cursorColor: UIColorToken.blue,
      textAlign: centered ? TextAlign.center : TextAlign.start,
      maxLength: maxLength,
      maxLengthEnforcement: maxLength == null ? null : MaxLengthEnforcement.enforced,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: effectiveTextStyle,
      decoration: InputDecoration(
        counterText: '',
        isDense: borderless,
        label: label == null ? null : Text(label!),
        hintText: hintText,
        hintStyle: effectiveHintStyle,
        filled: !borderless,
        fillColor: colors.fgColor,
        contentPadding: borderless
            ? const EdgeInsets.symmetric(vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: borderless ? InputBorder.none : null,
        focusedBorder: borderless
            ? InputBorder.none
            : OutlineInputBorder(
                borderSide: const BorderSide(color: UIColorToken.blue),
                borderRadius: BorderRadius.circular(12),
              ),
        enabledBorder: borderless
            ? InputBorder.none
            : OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(12),
              ),
        disabledBorder: InputBorder.none,
      ),
    );
  }
}
