import 'package:flutter/material.dart';

import '../../../../money/money.dart';
import '../../../app_ui.dart';

/// Colour / sign by *effective direction* for the wallet being viewed.
enum UiTransactionDirection { income, expense, transferOut, transferIn }

class UiTransactionCard extends StatelessWidget {
  const UiTransactionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.direction,
    this.secondaryText,
    this.tags = const [],
    this.upcoming = false,
    this.badge,
    this.onTap,
  });

  final String title;

  /// Formatted date (`Oct 28, 09:00 AM`).
  final String subtitle;

  /// Positive amount in the viewed wallet's currency; sign comes from [direction].
  final Money amount;
  final UiTransactionDirection direction;

  /// Appended to the subtitle: `120.00 EUR @ 1.0833`.
  final String? secondaryText;

  /// `#food #work` line under the caption (hidden when empty).
  final List<String> tags;

  /// Future-dated, not yet counted: whole row dimmed, dashed amount colour.
  final bool upcoming;

  /// Small pill after the title (e.g. "Upcoming"). Shown only when non-null.
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final typo = theme.typo.inter;

    final Color amountColor;
    final String sign;
    switch (direction) {
      case UiTransactionDirection.income:
        amountColor = UIColorToken.blue;
        sign = '+';
      case UiTransactionDirection.expense:
        amountColor = colors.expenseColor;
        sign = '-';
      case UiTransactionDirection.transferOut:
        amountColor = colors.secondContentColor;
        sign = '-';
      case UiTransactionDirection.transferIn:
        amountColor = colors.secondContentColor;
        sign = '+';
    }

    final caption = secondaryText == null ? subtitle : '$subtitle · $secondaryText';

    final badgeText = badge;

    return UITap(
      onTap: onTap,
      child: Opacity(
        opacity: upcoming ? 0.55 : 1,
        child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typo.rowTitle,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const UISpace.horz(6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.secondContentColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText.toUpperCase(),
                            style: typo.micro.copyWith(fontSize: 9, color: colors.secondContentColor),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typo.caption,
                  ),
                  if (tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final t in tags)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: UIColorToken.blue.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '#$t',
                                style: typo.semiBold.copyWith(fontSize: 10, color: UIColorToken.blue),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const UISpace.horz(12),
            Text(
              '$sign${amount.abs().format()}',
              style: typo.rowTitle.copyWith(color: amountColor),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
