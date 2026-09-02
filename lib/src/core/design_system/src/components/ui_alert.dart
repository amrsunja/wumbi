import 'package:flutter/material.dart';

import '../../app_ui.dart';

/// Inline alert banner used by snackbars.
class UIAlert extends StatelessWidget {
  final String label;
  final Color color;
  final Color contentColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  const UIAlert.success({super.key, required this.label, this.actionLabel, this.onAction})
      : color = UIColorToken.pos400,
        contentColor = UIColorToken.white;

  const UIAlert.info({super.key, required this.label, this.actionLabel, this.onAction})
      : color = UIColorToken.bismark,
        contentColor = UIColorToken.white;

  const UIAlert.error({super.key, required this.label, this.actionLabel, this.onAction})
      : color = UIColorToken.neg400,
        contentColor = UIColorToken.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: UITextStyleToken.interMedium.copyWith(color: contentColor, fontSize: 14),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const UISpace.horz(12),
            UITap(
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  actionLabel!.toUpperCase(),
                  style: UITextStyleToken.interBold.copyWith(
                    color: contentColor,
                    fontSize: 13,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Confirmation / error dialogs (spec: `UIAlert` with destructive action style).
abstract class UIAlertDialog {
  /// Returns `true` when the confirm action was tapped.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? message,
    required String confirmLabel,
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: UIColorToken.overlay,
      builder: (ctx) => _UIDialog(
        title: title,
        message: message,
        actions: [
          UIDialogAction(label: cancelLabel, onTap: () => Navigator.of(ctx).pop(false)),
          UIDialogAction(
            label: confirmLabel,
            destructive: destructive,
            primary: !destructive,
            onTap: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Dialog with arbitrary actions; resolves with the index of the tapped
  /// action (null when dismissed).
  static Future<int?> choose(
    BuildContext context, {
    required String title,
    String? message,
    required List<UIDialogAction> actions,
  }) =>
      showDialog<int>(
        context: context,
        barrierColor: UIColorToken.overlay,
        builder: (ctx) => _UIDialog(
          title: title,
          message: message,
          actions: [
            for (var i = 0; i < actions.length; i++)
              UIDialogAction(
                label: actions[i].label,
                destructive: actions[i].destructive,
                primary: actions[i].primary,
                onTap: () => Navigator.of(ctx).pop(i),
              ),
          ],
        ),
      );

  static Future<void> message(
    BuildContext context, {
    required String title,
    String? message,
    String buttonLabel = 'OK',
  }) =>
      showDialog<void>(
        context: context,
        barrierColor: UIColorToken.overlay,
        builder: (ctx) => _UIDialog(
          title: title,
          message: message,
          actions: [
            UIDialogAction(label: buttonLabel, primary: true, onTap: () => Navigator.of(ctx).pop()),
          ],
        ),
      );
}

class UIDialogAction {
  const UIDialogAction({
    required this.label,
    this.onTap,
    this.destructive = false,
    this.primary = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool destructive;
  final bool primary;
}

class _UIDialog extends StatelessWidget {
  const _UIDialog({required this.title, this.message, required this.actions});

  final String title;
  final String? message;
  final List<UIDialogAction> actions;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return Dialog(
      backgroundColor: colors.fgColor,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: UITextStyleToken.interSemiBold.copyWith(fontSize: 17, color: colors.contentColor),
            ),
            if (message != null) ...[
              const UISpace.vert(10),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: UITextStyleToken.interRegular.copyWith(fontSize: 14, color: colors.secondContentColor, height: 1.4),
              ),
            ],
            const UISpace.vert(20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final a in actions)
                  UITap(
                    onTap: a.onTap,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        a.label,
                        style: UITextStyleToken.interSemiBold.copyWith(
                          fontSize: 16,
                          color: a.destructive
                              ? UIColorToken.neg500
                              : a.primary
                                  ? UIColorToken.blue
                                  : colors.secondContentColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
