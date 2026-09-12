import 'package:flutter/material.dart';

import '../../app_ui.dart';

/// Every secondary choice is a bottom sheet, not a screen.
abstract class UIModalSheet {
  static Future<T?> modalSheet<T>({
    required BuildContext context,
    required Widget child,

    /// Fraction of the screen height (0–1). Ignored when [fitContent] is true.
    double height = 0.6,
    bool fitContent = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isRoot = false,
    bool showSheetLine = true,
    bool resizeToAvoidBottomInset = true,
    Color? barrierColor,
    Color? bgColor,
    String? title,
    RouteSettings? routeSettings,
    EdgeInsets? padding,
  }) =>
      showModalBottomSheet<T>(
        routeSettings: routeSettings,
        barrierColor: barrierColor ?? UIColorToken.overlay,
        useSafeArea: true,
        showDragHandle: false,
        useRootNavigator: isRoot,
        elevation: 0,
        isScrollControlled: true,
        isDismissible: isDismissible,
        backgroundColor: Colors.transparent,
        enableDrag: enableDrag,
        context: context,
        builder: (context) {
          final theme = AppTheme.of(context);
          final colors = theme.colors;
          final mediaQuery = MediaQuery.of(context);
          final bottomInset = resizeToAvoidBottomInset ? mediaQuery.viewInsets.bottom : 0.0;

          final body = Column(
            mainAxisSize: fitContent ? MainAxisSize.min : MainAxisSize.max,
            children: [
              if (showSheetLine)
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.secondContentColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTheme.of(context).typo.inter.rowTitle,
                  ),
                ),
              if (fitContent) child else Expanded(child: child),
            ],
          );

          return AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Container(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
              height: fitContent ? null : mediaQuery.size.height * height,
              decoration: BoxDecoration(
                color: bgColor ?? colors.fgColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(theme.borders.sheetRadius)),
                boxShadow: UIShadowToken.sheetShadow,
              ),
              child: SafeArea(top: false, child: body),
            ),
          );
        },
      );
}
