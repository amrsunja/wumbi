import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// "• Savings Vault ⌄" — chevron only when [enabled] and [onTap] is set.
class UiSelectWalletButton extends StatelessWidget {
  const UiSelectWalletButton({
    super.key,
    required this.name,
    required this.color,
    this.onTap,
    this.enabled = true,
  });

  final String name;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;

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
            UiCircleColorBadge(color: color, size: 7),
            const UISpace.horz(2),
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.of(context).typo.inter.label.copyWith(
                  letterSpacing: 0.3,
                ),
              ),
            ),
            if (interactive)
              UIIcon(UIIconToken.icons.arrows.chevronDown, size: 18),
          ],
        ),
      ),
    );
  }
}
