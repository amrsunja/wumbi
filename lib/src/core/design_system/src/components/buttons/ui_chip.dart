import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Date / Repeat chip: bare 10 px medium text + small chevron, no background.
/// `readOnly` hides the chevron and ignores taps ("Monthly · part of a repeat").
class UiChip extends StatelessWidget {
  const UiChip({
    super.key,
    required this.label,
    this.onTap,
    this.readOnly = false,
    this.icon,
    this.highlighted = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool readOnly;
  final String? icon;

  /// Blue text — used when Repeat is set to something other than never.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    final color = highlighted ? UIColorToken.blue : colors.secondContentColor;
    return UITap(
      onTap: readOnly ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 3,
          children: [
            if (icon != null) UIIcon(icon!, size: 12, color: color),
            Text(
              label,
              style: AppTheme.of(context).typo.inter.chip.copyWith(color: color),
            ),
            if (!readOnly) UIIcon(UIIconToken.icons.arrows.chevronDown, size: 12, color: color),
          ],
        ),
      ),
    );
  }
}

/// Small uppercase pill: INCOME / EXPENSE / TRANSFER in edit mode.
/// [selected] = false renders it as an outlined, muted option (type toggle).
class UiTypePill extends StatelessWidget {
  const UiTypePill({super.key, required this.label, required this.color, this.selected = true, this.onTap});

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    final fg = selected ? color : colors.secondContentColor;
    return UITap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(color: selected ? Colors.transparent : colors.dividerColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTheme.of(context).typo.inter.micro.copyWith(color: fg),
        ),
      ),
    );
  }
}
