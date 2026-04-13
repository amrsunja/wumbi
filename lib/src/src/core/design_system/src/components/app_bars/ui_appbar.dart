import 'package:fiin/src/src/core/design_system/app_ui.dart';
import 'package:flutter/material.dart';


class UIAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? backTap;
  final Widget? action;

  const UIAppbar({
    super.key,
    required this.title,
    this.backTap,
    this.action,
  });

  @override
  Size get preferredSize => Size(double.infinity, 60);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.bgColor,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20
          ),
          child: Row(
            spacing: 4,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (backTap != null)
                UIIcon(
                  UIIconToken.icons.arrows.arrowNarrowLeft,
                  size: 24,
                  onTap: backTap,
                ),
              Flexible(
                child: Center(
                  child: Text(
                    title.toUpperCase(),
                    style: UITextStyleToken.interBold.copyWith(
                      letterSpacing: 1.6,
                      color: UIColorToken.bismark.withValues(alpha: 0.5),
                      fontSize: 14
                    ),
                  ),
                ),
              ),
                  
              if (action != null)
                action!
              else
                UISpace.horz(24)
            ],
          ),
        ),
      ),
    );
  }
}
