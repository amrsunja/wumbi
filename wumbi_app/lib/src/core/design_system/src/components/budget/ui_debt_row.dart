import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// One debt (spec B&D §8.3): person and remaining, a caption ("Dinner · due
/// Oct 20") whose [alert] part ("overdue") is red, and a thin blue bar of
/// what was already paid back. Text is passed in already localised.
class UiDebtRow extends StatelessWidget {
  const UiDebtRow({
    super.key,
    required this.title,
    required this.trailing,
    required this.paidRatio,
    this.caption = '',
    this.alert,
    this.color = UIColorToken.blue,
    this.dimmed = false,
    this.onTap,
  });

  /// Person name.
  final String title;

  /// "€100 left" / "Settled".
  final String trailing;

  /// 0 – 1 already paid back.
  final double paidRatio;
  final String caption;

  /// Appended to [caption] in red ("overdue").
  final String? alert;
  final Color color;

  /// Settled debts are shown muted.
  final bool dimmed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typo = AppTheme.of(context).typo.inter;
    final hasCaption = caption.isNotEmpty || alert != null;
    return Opacity(
      opacity: dimmed ? 0.55 : 1,
      child: UITap(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.rowTitle)),
                  const UISpace.horz(12),
                  Text(trailing, maxLines: 1, style: typo.rowTitle),
                ],
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
              const UISpace.vert(8),
              UiBudgetBar(spentRatio: paidRatio, color: color, height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
