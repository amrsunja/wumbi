import 'package:fiin/src/src/core/design_system/app_ui.dart';
import 'package:flutter/material.dart';

class UiSelectButton extends StatelessWidget {
  const UiSelectButton({
    super.key,
    required this.title,
    this.style,
    this.onTap,
  });

  final String title;
  final TextStyle? style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.6 : 1,
      child: UITap(
        onTap: onTap,
        child: Row(
          mainAxisSize: .min,
          spacing: 4,
          children: [
            Text(
              title,
              style: style ?? UITextStyleToken.interBold.copyWith(
                letterSpacing: 0.3,
                fontSize: 14,
                color: UIColorToken.bismark.withValues(alpha: 0.7)
              ),
            ),

            if (onTap != null)
              UIIcon(
                UIIconToken.icons.arrows.chevronDown,
                size: style?.fontSize ?? 18,
                color: UIColorToken.casper,
              )
          ],
        ),
      ),
    );
  }
}
