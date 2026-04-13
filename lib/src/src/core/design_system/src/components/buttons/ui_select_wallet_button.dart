import 'package:fiin/src/src/core/design_system/app_ui.dart';
import 'package:flutter/material.dart';

class UiSelectWalletButton extends StatelessWidget {
  const UiSelectWalletButton({
    super.key,
    required this.name,
    required this.color,
    this.onTap,
  });

  final String name;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return UITap(
      onTap: onTap,
      child: Row(
        mainAxisSize: .min,
        spacing: 4,
        children: [
          UiCircleColorBadge(color: color, size: 7),
          Text(
            name,
            style: UITextStyleToken.interSemiBold.copyWith(
              letterSpacing: 0.3,
              fontSize: 14,
              color: UIColorToken.bismark
            ),
          ),
    
          if (onTap != null)
            UIIcon(
              UIIconToken.icons.arrows.chevronDown,
              size: 18,
              color: UIColorToken.casper,
            )
        ],
      ),
    );
  }
}


