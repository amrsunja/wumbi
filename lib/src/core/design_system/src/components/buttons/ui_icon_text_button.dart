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
          spacing: 6,
          children: [
            if (icon != null) UIIcon(icon!, color: color, size: 14),
            Text(
              title,
              style: AppTheme.of(context).typo.inter.bold.copyWith(
                color: color,
                letterSpacing: -0.35,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
