import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// "USD ⌄" — static label (no chevron, no tap) when [enabled] is false.
class UiSelectButton extends StatelessWidget {
  const UiSelectButton({
    super.key,
    required this.title,
    this.style,
    this.onTap,
    this.enabled = true,
    this.trailingIcon,
  });

  final String title;
  final TextStyle? style;
  final VoidCallback? onTap;
  final bool enabled;

  /// Defaults to chevron-down; pass e.g. `chevronRight` for settings rows.
  final String? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final interactive = enabled && onTap != null;
    return UITap(
      onTap: interactive ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Text(
              title,
              style: style ?? AppTheme.of(context).typo.inter.select,
            ),
            if (interactive)
              UIIcon(
                trailingIcon ?? UIIconToken.icons.arrows.chevronDown,
                size: style?.fontSize != null ? style!.fontSize! + 4 : 16,
              ),
          ],
        ),
      ),
    );
  }
}
