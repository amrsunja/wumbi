import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// One debt: [dot] (wallet-style colour circle) · person and caption on the
/// left, remaining amount vertically centred on the right. Text is passed in
/// already localised; [alert] ("overdue") is drawn red after [caption].
class UiDebtRow extends StatelessWidget {
  const UiDebtRow({
    super.key,
    required this.title,
    required this.trailing,
    this.caption = '',
    this.alert,
    this.dimmed = false,
    this.dotColor,
    this.trailingColor,
    this.onTap,
    this.titleHeroTag,
  });

  /// Person name.
  final String title;

  /// "€100 left" / "Settled".
  final String trailing;
  final String caption;

  /// Appended to [caption] in red ("overdue").
  final String? alert;

  /// Settled debts are shown muted.
  final bool dimmed;

  /// Leading colour circle (income blue: owed to you, expense colour: you owe).
  final Color? dotColor;

  /// Colour of [trailing]; null → the row title colour.
  final Color? trailingColor;
  final VoidCallback? onTap;

  /// Hero tag shared with the details page (name → app bar).
  final Object? titleHeroTag;

  @override
  Widget build(BuildContext context) {
    final typo = AppTheme.of(context).typo.inter;
    final hasCaption = caption.isNotEmpty || alert != null;
    final titleHeroTag = this.titleHeroTag;
    final dot = dotColor;
    final titleText = Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.rowTitle);
    return Opacity(
      opacity: dimmed ? 0.55 : 1,
      child: UITap(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (dot != null) ...[
                UiCircleColorBadge(color: dot, size: 10),
                const UISpace.horz(12),
              ],
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
                    if (hasCaption) ...[
                      const UISpace.vert(4),
                      Text.rich(
                        TextSpan(
                          children: [
                            if (caption.isNotEmpty) TextSpan(text: caption),
                            if (caption.isNotEmpty && alert != null) const TextSpan(text: ' · '),
                            if (alert != null)
                              TextSpan(text: alert, style: typo.caption.copyWith(color: UIColorToken.neg500)),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typo.caption,
                      ),
                    ],
                  ],
                ),
              ),
              const UISpace.horz(12),
              Text(trailing, maxLines: 1, style: typo.rowTitle.copyWith(color: trailingColor)),
            ],
          ),
        ),
      ),
    );
  }
}
