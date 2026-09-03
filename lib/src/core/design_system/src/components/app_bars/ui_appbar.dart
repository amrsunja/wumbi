import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// 44 px back / action slots with an uppercase, letter-spaced, casper title.
class UIAppbar extends StatelessWidget implements PreferredSizeWidget {
  const UIAppbar({
    super.key,
    this.title = '',
    this.backTap,
    this.action,
    this.leading,
    this.transparent = false,
  });

  final String title;
  final VoidCallback? backTap;
  final Widget? action;

  /// Custom leading widget; defaults to the back arrow when [backTap] is set.
  final Widget? leading;

  /// No background fill — lets an ambient background show through.
  final bool transparent;

  @override
  Size get preferredSize => const Size(double.infinity, 60);

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;

    Widget slot(Widget? child) => SizedBox(
          width: 44,
          height: 44,
          child: child == null ? null : Center(child: child),
        );

    return Container(
      color: transparent ? Colors.transparent : colors.bgColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              slot(
                leading ??
                    (backTap == null
                        ? null
                        : UIIcon(
                            UIIconToken.icons.arrows.arrowNarrowLeft,
                            size: 24,
                            onTap: backTap,
                          )),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.of(context).typo.inter.overline,
                  ),
                ),
              ),
              slot(action),
            ],
          ),
        ),
      ),
    );
  }
}
