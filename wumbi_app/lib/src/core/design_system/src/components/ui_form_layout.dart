import 'package:flutter/material.dart';

/// Body of a Create/Edit form page (Wallet, Budget, Debt): the scrolling
/// [content] and its submit control.
///
/// - Create: [overlayButton] (a full-width primary button) floats over the
///   content on a transparent background — give the content
///   [overlayInset] of bottom padding so its last row clears the button.
/// - Edit: [bar] (Delete · Save) sits under the content as before.
class UiFormLayout extends StatelessWidget {
  const UiFormLayout({super.key, required this.content, this.overlayButton, this.bar, this.horizontalPadding = 16})
    : assert(overlayButton == null || bar == null);

  /// Room the content leaves under itself for [overlayButton].
  static const double overlayInset = 52 + _buttonBottom + 24;
  static const double _buttonBottom = 12;

  final Widget content;
  final Widget? overlayButton;
  final Widget? bar;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final button = overlayButton;
    if (button == null) {
      return Column(
        children: [
          Expanded(child: content),
          ?bar,
        ],
      );
    }
    return Stack(
      children: [
        Positioned.fill(child: content),
        Positioned(
          left: horizontalPadding,
          right: horizontalPadding,
          bottom: _buttonBottom,
          // Page-coloured backing: a disabled (faded) button must not let
          // the rows scrolling under it show through.
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: button,
          ),
        ),
      ],
    );
  }
}
