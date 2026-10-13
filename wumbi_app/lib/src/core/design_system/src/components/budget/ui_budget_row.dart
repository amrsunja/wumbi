import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// One budget at a glance (spec B&D §6.2): title and remaining on one line,
/// the segmented bar, then "Spent €170 of €400" (left) and a caption
/// ("October · €14/day", right). Text is passed in already localised.
class UiBudgetRow extends StatelessWidget {
  const UiBudgetRow({
    super.key,
    required this.title,
    required this.trailing,
    required this.caption,
    this.spent,
    this.spentEmphasis,
    required this.spentRatio,
    this.plannedRatio = 0,
    required this.color,
    this.trailingColor,
    this.barHeight = 6,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.onTap,
  });

  final String title;

  /// "€230 left" / "€12 over" / "Starts Nov 1" / "Ended".
  final String trailing;
  final String caption;

  /// "Spent €170 of €400" under the bar's start. Null: caption only.
  final String? spent;

  /// Substring of [spent] drawn bold in the status colour (the amount).
  final String? spentEmphasis;
  final double spentRatio;
  final double plannedRatio;

  /// Status colour of the bar.
  final Color color;

  /// Status colour for the trailing label when it matters (at risk / over);
  /// null keeps the row title colour.
  final Color? trailingColor;
  final double barHeight;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  /// [spent] with [spentEmphasis] highlighted, wherever the locale puts it.
  InlineSpan _spentSpan(TextStyle base) {
    final text = spent!;
    final emphasis = spentEmphasis;
    final at = emphasis == null || emphasis.isEmpty ? -1 : text.indexOf(emphasis);
    if (at < 0) return TextSpan(text: text);
    final strong = base.copyWith(fontWeight: FontWeight.w600, color: trailingColor ?? color);
    return TextSpan(
      children: [
        TextSpan(text: text.substring(0, at)),
        TextSpan(text: emphasis, style: strong),
        TextSpan(text: text.substring(at + emphasis!.length)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final typo = AppTheme.of(context).typo.inter;
    return UITap(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.rowTitle),
                ),
                const UISpace.horz(12),
                Text(
                  trailing,
                  maxLines: 1,
                  style: typo.rowTitle.copyWith(color: trailingColor),
                ),
              ],
            ),
            const UISpace.vert(8),
            UiBudgetBar(spentRatio: spentRatio, plannedRatio: plannedRatio, color: color, height: barHeight),
            const UISpace.vert(6),
            if (spent == null)
              Text(caption, maxLines: 2, overflow: TextOverflow.ellipsis, style: typo.caption)
            else
              // Spent keeps priority (up to 65 % of the width); the caption
              // takes what is left and ellipsises.
              LayoutBuilder(
                builder: (context, constraints) => Row(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.65),
                      child: Text.rich(
                        _spentSpan(typo.caption),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typo.caption,
                      ),
                    ),
                    const UISpace.horz(12),
                    Expanded(
                      child: Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: typo.caption,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
