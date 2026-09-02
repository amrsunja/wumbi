import 'package:flutter/material.dart';

import '../../../app_ui.dart';

enum UiTypeActionStyle { transfer, income, expense }

/// Asset icon (assets/icons/{transfer,income,expense}.svg — income / expense
/// carry their own filled circle, transfer is bare arrows) + 10 px uppercase
/// label. [heroTag] lets the dashboard FAB fly into the icon.
class UiTypeActionButton extends StatelessWidget {
  const UiTypeActionButton({
    super.key,
    required this.label,
    required this.style,
    this.enabled = true,
    this.onTap,
    this.heroTag,
  });

  final String label;
  final UiTypeActionStyle style;
  final bool enabled;
  final VoidCallback? onTap;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;

    final String asset;
    final Color tint;
    final Color labelColor;
    switch (style) {
      case UiTypeActionStyle.transfer:
        asset = UIIconToken.icons.transfer;
        tint = colors.secondContentColor;
        labelColor = colors.secondContentColor;
      case UiTypeActionStyle.income:
        asset = UIIconToken.icons.income;
        tint = UIColorToken.blue;
        labelColor = colors.contentColor;
      case UiTypeActionStyle.expense:
        asset = UIIconToken.icons.expense;
        tint = colors.contentColor;
        labelColor = colors.contentColor;
    }

    Widget icon = SizedBox(
      width: 40,
      height: 40,
      child: Center(child: UIIcon(asset, color: tint, size: 40)),
    );
    if (heroTag != null) {
      icon = UiHero(tag: heroTag!, child: icon);
    }

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: UITap(
        // Keep the tap alive when disabled so the caller can shake / haptic.
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              icon,
              Text(
                label.toUpperCase(),
                style: UITextStyleToken.interBold.copyWith(
                  fontSize: 10,
                  letterSpacing: 1.0,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
