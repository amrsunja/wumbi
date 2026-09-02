import 'package:flutter/material.dart';

import '../../../../utils/app_vibrations.dart';
import '../../../app_ui.dart';

/// 3×4 grid: 1 2 3 / 4 5 6 / 7 8 9 / . 0 ⌫ — white 50 % tiles (fgColor in
/// dark mode), 8 px gaps, light haptic on touch-down, long-press ⌫ clears.
class UiNumpad extends StatelessWidget {
  const UiNumpad({
    super.key,
    required this.onDigit,
    required this.onDot,
    required this.onBackspace,
    required this.onClear,
    this.dotEnabled = true,
    this.keyHeight = 44,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDot;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final bool dotEnabled;
  final double keyHeight;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final tileColor = colors.isDark ? colors.fgColor : UIColorToken.white.withValues(alpha: 0.5);

    Widget key({
      required Widget child,
      VoidCallback? onTap,
      VoidCallback? onLongPress,
      bool enabled = true,
    }) {
      return Expanded(
        child: Opacity(
          opacity: enabled ? 1 : 0.35,
          child: Material(
            color: tileColor,
            borderRadius: BorderRadius.circular(theme.borders.tileRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(theme.borders.tileRadius),
              highlightColor: colors.secondContentColor.withValues(alpha: 0.15),
              splashColor: Colors.transparent,
              // Haptic on touch-down so the key feels instant.
              onTapDown: enabled ? (_) => AppVibrations.light() : null,
              onTap: enabled ? onTap : null,
              onLongPress: enabled && onLongPress != null
                  ? () {
                      AppVibrations.medium();
                      onLongPress();
                    }
                  : null,
              child: SizedBox(height: keyHeight, child: Center(child: child)),
            ),
          ),
        ),
      );
    }

    Widget digit(String d) => key(
          child: Text(
            d,
            style: UITextStyleToken.interMedium.copyWith(fontSize: 24, color: colors.contentColor),
          ),
          onTap: () => onDigit(d),
        );

    Widget row(List<Widget> keys) => Row(spacing: 8, children: keys);

    return Column(
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      children: [
        row([digit('1'), digit('2'), digit('3')]),
        row([digit('4'), digit('5'), digit('6')]),
        row([digit('7'), digit('8'), digit('9')]),
        row([
          key(
            enabled: dotEnabled,
            child: Text(
              '.',
              style: UITextStyleToken.interMedium.copyWith(fontSize: 24, color: colors.contentColor),
            ),
            onTap: onDot,
          ),
          digit('0'),
          key(
            child: UIIcon(UIIconToken.icons.editor.delete, size: 22, color: colors.contentColor),
            onTap: onBackspace,
            onLongPress: onClear,
          ),
        ]),
      ],
    );
  }
}
