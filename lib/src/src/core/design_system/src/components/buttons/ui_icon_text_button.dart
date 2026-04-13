import 'package:fiin/src/src/core/design_system/app_ui.dart';
import 'package:flutter/material.dart';

class UiIconTextButton extends StatelessWidget {
  const UiIconTextButton({
    super.key,
    this.icon,
    required this.title,
    this.color = UIColorToken.blue
  });

  final String? icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6,
      children: [
        if (icon != null)
          UIIcon(icon!, color: color, size: 20),
        
        Text(
          title,
          style: UITextStyleToken.interBold.copyWith(
            color: color,
            letterSpacing: -0.35,
            fontSize: 14
          ),
        )
      ],
    );
  }
}


