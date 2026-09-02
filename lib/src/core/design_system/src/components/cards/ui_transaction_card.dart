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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;

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

    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UITextStyleToken.interSemiBold.copyWith(fontSize: 16, color: colors.contentColor),
                  ),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UITextStyleToken.interMedium.copyWith(color: colors.secondContentColor, fontSize: 12),
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
                                style: UITextStyleToken.interSemiBold.copyWith(fontSize: 10, color: UIColorToken.blue),
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
              style: UITextStyleToken.interSemiBold.copyWith(fontSize: 16, color: amountColor),
            ),
          ],
        ),
      ),
    );
  }
}
