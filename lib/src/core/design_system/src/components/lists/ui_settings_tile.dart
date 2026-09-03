import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// 56 px settings row: 20 px leading icon (casper), 16 px medium title,
/// trailing chevron / value / switch. `destructive` paints icon + title neg500.
class UiSettingsTile extends StatelessWidget {
  const UiSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.switchValue,
    this.onSwitchChanged,
    this.onTap,
    this.destructive = false,
    this.showChevron = true,
  });

  final String icon;
  final String title;

  /// Trailing value text (e.g. "USD").
  final String? value;

  /// When set, renders a switch instead of chevron / value.
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback? onTap;
  final bool destructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final tint = destructive ? UIColorToken.neg500 : null;
    final isSwitch = switchValue != null;

    return UITap(
      onTap: isSwitch
          ? (onSwitchChanged == null ? null : () => onSwitchChanged!(!switchValue!))
          : onTap,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              UIIcon(icon, size: 20, color: tint),
              const UISpace.horz(16),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.of(context).typo.inter.body.copyWith(color: tint),
                ),
              ),
              if (isSwitch)
                UISwitch(value: switchValue!, onChanged: onSwitchChanged)
              else ...[
                if (value != null)
                  Text(
                    value!,
                    style: AppTheme.of(context).typo.inter.subtitle,
                  ),
                if (showChevron && !destructive) ...[
                  const UISpace.horz(6),
                  UIIcon(UIIconToken.icons.arrows.chevronRight, size: 18),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
