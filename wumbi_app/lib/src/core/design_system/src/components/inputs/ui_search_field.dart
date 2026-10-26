import 'package:flutter/material.dart';

import '../../../../utils/app_vibrations.dart';
import '../../../app_ui.dart';

/// Boxed [UIInputField] with a trailing clear (×) button, shown only while
/// the field has text. Clearing reports `''` through [onChanged] so callers
/// reset their query the same way as when the user deletes by hand.
///
/// Owns a controller when none is passed.
class UISearchField extends StatefulWidget {
  const UISearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.autofocus = false,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.search,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final bool autofocus;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Extra hook after the field is cleared (after `onChanged('')`).
  final VoidCallback? onClear;

  @override
  State<UISearchField> createState() => _UISearchFieldState();
}

class _UISearchFieldState extends State<UISearchField> {
  TextEditingController? _own;

  TextEditingController get _controller => widget.controller ?? (_own ??= TextEditingController());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  void _clear() {
    AppVibrations.light();
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        return UIInputField(
          controller: _controller,
          focusNode: widget.focusNode,
          hintText: widget.hintText,
          autofocus: widget.autofocus,
          maxLength: widget.maxLength,
          textCapitalization: widget.textCapitalization,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          suffixIcon: hasText
              ? Semantics(
                  button: true,
                  label: MaterialLocalizations.of(context).deleteButtonTooltip,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _clear,
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: UIIcon(
                          UIIconToken.icons.general.xClose,
                          size: 18,
                          color: colors.secondContentColor,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
