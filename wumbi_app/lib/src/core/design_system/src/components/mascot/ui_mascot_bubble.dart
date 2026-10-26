import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Which corner of a [UiMascotBubble] points at the mascot.
enum UiBubbleTail {
  /// Inline bubble right of the mascot (left in RTL): sharp top-start corner.
  start,

  /// Floating bubble left of a top-right corner mascot: sharp top-right.
  topRight,

  /// Above a mascot standing at the bottom-start: sharp bottom-start corner.
  bottomStart,

  /// No mascot next to it (mascot hidden): plain card.
  none,
}

/// Speech bubble: one short insight (≤ 2 lines in practice), an optional
/// blue action ("View ›") and a quiet secondary link. Inline on the page it sits on the same tinted
/// surface as `UiGroupCard`; [floating] (over content) it is opaque with a
/// hairline and a soft shadow.
class UiMascotBubble extends StatelessWidget {
  const UiMascotBubble({
    super.key,
    required this.text,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    this.tail = UiBubbleTail.start,
    this.floating = false,
    this.maxLines = 3,
  });

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Quiet second link next to the action (e.g. "Another thought").
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final UiBubbleTail tail;
  final bool floating;
  final int maxLines;

  static const Radius _round = Radius.circular(16);
  static const Radius _sharp = Radius.circular(4);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final typo = theme.typo.inter;

    final BorderRadiusGeometry radius = switch (tail) {
      UiBubbleTail.start => const BorderRadiusDirectional.only(
          topStart: _sharp,
          topEnd: _round,
          bottomStart: _round,
          bottomEnd: _round,
        ),
      UiBubbleTail.topRight => const BorderRadius.only(
          topLeft: _round,
          topRight: _sharp,
          bottomLeft: _round,
          bottomRight: _round,
        ),
      UiBubbleTail.bottomStart => const BorderRadiusDirectional.only(
          topStart: _round,
          topEnd: _round,
          bottomStart: _sharp,
          bottomEnd: _round,
        ),
      UiBubbleTail.none => const BorderRadius.all(_round),
    };

    final label = actionLabel;
    final secondary = secondaryLabel;
    final hasLinks = label != null || secondary != null;
    Widget link(String text, VoidCallback? onTap, Color color, {bool chevron = false}) => UITap(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 2,
              children: [
                Text(text, style: typo.label.copyWith(color: color, fontSize: 13)),
                if (chevron) UIIcon(UIIconToken.icons.arrows.chevronRight, size: 14, color: color),
              ],
            ),
          ),
        );
    return Container(
      padding: EdgeInsets.fromLTRB(14, 10, 14, hasLinks ? 6 : 11),
      decoration: BoxDecoration(
        color: floating ? colors.fgColor : colors.secondContentColor.withValues(alpha: 0.08),
        borderRadius: radius,
        border: floating ? Border.all(color: colors.dividerColor) : null,
        boxShadow: floating
            ? [
                BoxShadow(
                  color: UIColorToken.bismark.withValues(alpha: colors.isDark ? 0.3 : 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: typo.labelMedium.copyWith(height: 1.4),
          ),
          if (hasLinks)
            Wrap(
              spacing: 16,
              children: [
                if (label != null) link(label, onAction, UIColorToken.blue, chevron: true),
                if (secondary != null) link(secondary, onSecondary, colors.secondContentColor),
              ],
            ),
        ],
      ),
    );
  }
}
