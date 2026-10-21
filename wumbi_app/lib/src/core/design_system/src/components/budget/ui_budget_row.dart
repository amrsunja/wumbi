import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// One budget as a wallet-style row:
///
///   [ring]  Title                 [amount]
///           €170 / €400
///
/// The ring sits at the start; the trailing amount ("€230 left" / "€12 over")
/// is vertically centred on the right.
class UiBudgetRow extends StatelessWidget {
  const UiBudgetRow({
    super.key,
    required this.title,
    required this.trailing,
    this.trailingColor,
    required this.subtitle,
    required this.spentRatio,
    this.plannedRatio = 0,
    required this.color,
    this.ringSize = 28,
    this.ringStrokeWidth = 3,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
    this.onTap,
    this.titleHeroTag,
    this.barHeroTag,
  });

  final String title;

  /// Short status: "€230 left" / "€12 over" / "Starts Nov 1" / "Ended".
  final String trailing;

  /// Colour of [trailing]; null → the expense colour (black / white in dark).
  final Color? trailingColor;

  /// Second line, already localised ("€170 / €400").
  final String subtitle;

  final double spentRatio;
  final double plannedRatio;

  /// Progress colour of the ring.
  final Color color;
  final double ringSize;
  final double ringStrokeWidth;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  /// Hero tags shared with the details page (title → app bar, ring → ring).
  final Object? titleHeroTag;
  final Object? barHeroTag;

  @override
  Widget build(BuildContext context) {
    final typo = AppTheme.of(context).typo.inter;
    final titleHeroTag = this.titleHeroTag;
    final barHeroTag = this.barHeroTag;

    final titleText = Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.rowTitle);
    final ring = UiBudgetRing(
      spentRatio: spentRatio,
      plannedRatio: plannedRatio,
      color: color,
      size: ringSize,
      strokeWidth: ringStrokeWidth,
      duration: const Duration(milliseconds: 700),
    );

    return UITap(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            barHeroTag == null ? ring : UiHero(tag: barHeroTag, pushedShuttle: true, child: ring),
            const UISpace.horz(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  titleHeroTag == null
                      ? titleText
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: UiHero(tag: titleHeroTag, alignment: Alignment.centerLeft, child: titleText),
                        ),
                  const UISpace.vert(2),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.caption),
                ],
              ),
            ),
            const UISpace.horz(12),
            Text(
              trailing,
              maxLines: 1,
              style: typo.rowTitle.copyWith(
                letterSpacing: -0.43,
                color: trailingColor ?? AppTheme.of(context).colors.expenseColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
