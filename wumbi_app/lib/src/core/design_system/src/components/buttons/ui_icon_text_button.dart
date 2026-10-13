import 'package:flutter/material.dart';

import '../../../app_ui.dart';

class UiIconTextButton extends StatelessWidget {
  const UiIconTextButton({
    super.key,
    this.icon,
    required this.title,
    this.color = UIColorToken.blue,
    this.onTap,
  });

  final String? icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Text(
              title,
              style: AppTheme.of(context).typo.inter.medium.copyWith(
                color: color.withValues(alpha: 1),
                letterSpacing: -0.35,
                fontSize: 13,
              ),
            ),
            if (icon != null) UIIcon(icon!, color: color.withValues(alpha: 1), size: 14),
          ],
        ),
      ),
    );
  }
}
