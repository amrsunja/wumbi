import 'package:flutter/material.dart';

import '../../../app_ui.dart';

enum UiTextButtonStyle { primary, secondary, destructive }

/// Text-only button used in bottom bars: Delete / Cancel (secondary, casper), Save (primary blue).
class UiTextButton extends StatelessWidget {
  const UiTextButton({
    super.key,
    required this.label,
    this.onTap,
    this.style = UiTextButtonStyle.primary,
    this.enabled = true,
    this.fontSize = 18,
  });

  final String label;
  final VoidCallback? onTap;
  final UiTextButtonStyle style;
  final bool enabled;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    // secondary = casper in both themes (Delete / Cancel in bottom bars).
    final color = switch (style) {
      UiTextButtonStyle.primary => UIColorToken.blue,
      UiTextButtonStyle.secondary => UIColorToken.casper,
      UiTextButtonStyle.destructive => UIColorToken.neg500,
    };
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: UITap(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            label,
            style: AppTheme.of(context).typo.inter.button.copyWith(fontSize: fontSize, color: color),
          ),
        ),
      ),
    );
  }
}
