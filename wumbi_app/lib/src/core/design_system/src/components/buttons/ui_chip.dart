import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Date / Repeat chip: bare 12 px medium text + small chevron, no background.
/// `readOnly` hides the chevron and ignores taps ("Monthly · part of a repeat").
class UiChip extends StatelessWidget {
  const UiChip({
    super.key,
    required this.label,
    this.onTap,
    this.readOnly = false,
    this.icon,
    this.highlighted = false,
    this.showChevron = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool readOnly;
  final String? icon;

  /// Blue text — used when Repeat is set to something other than never.
  final bool highlighted;

  /// False for toggle chips (tap flips a flag, nothing opens).
  final bool showChevron;

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
            if (icon != null) UIIcon(icon!, size: 14, color: color),
            Text(
              label,
              style: AppTheme.of(context).typo.inter.labelMedium.copyWith(color: color),
            ),
            if (!readOnly && showChevron) UIIcon(UIIconToken.icons.arrows.chevronDown, size: 14, color: color),
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

/// Selectable rounded chip for pickers laid out in a `Wrap` (currency picker).
/// Optional muted [leading] text before the bold [label] (e.g. `€  EUR`).
/// [selected] tints it blue; otherwise it is a card-coloured outlined pill.
class UiChoiceChip extends StatelessWidget {
  const UiChoiceChip({super.key, required this.label, this.leading, this.selected = false, this.onTap});

  final String label;
  final String? leading;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    final typo = AppTheme.of(context).typo.inter;
    final fg = selected ? UIColorToken.blue : colors.contentColor;
    return Semantics(
      button: true,
      selected: selected,
      child: UITap(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? UIColorToken.blue.withValues(alpha: 0.12) : colors.fgColor,
            border: Border.all(color: selected ? UIColorToken.blue : colors.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              if (leading != null)
                Text(
                  leading!,
                  style: typo.labelMedium.copyWith(
                    color: selected ? UIColorToken.blue : colors.secondContentColor,
                  ),
                ),
              Text(label, style: typo.label.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
