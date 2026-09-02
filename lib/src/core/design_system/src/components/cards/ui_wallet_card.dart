import 'package:flutter/material.dart';

import '../../../../money/money.dart';
import '../../../app_ui.dart';

/// Dashboard wallet row: colour badge · name · currency code · balance (own currency).
class UiWalletCard extends StatelessWidget {
  const UiWalletCard({
    super.key,
    required this.title,
    required this.balance,
    required this.color,
    this.onTap,
    this.trailing,
    this.animatedBadge = false,
    this.badgePhase = 0,
    this.nameHeroTag,
    this.balanceHeroTag,
  });

  final String title;
  final Money balance;
  final Color color;
  final VoidCallback? onTap;

  /// Replaces the balance text (e.g. a check mark in pickers).
  final Widget? trailing;

  /// Breathing glow on the colour dot (dashboard).
  final bool animatedBadge;
  final double badgePhase;

  /// When set, the name block / balance fly to the matching Hero on the next page.
  final Object? nameHeroTag;
  final Object? balanceHeroTag;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;

    Widget hero(Object? tag, Widget child) =>
        tag == null ? child : UiHero(tag: tag, alignment: Alignment.centerLeft, child: child);

    final nameBlock = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 18,
      children: [
        UiCircleColorBadge(color: color, animated: animatedBadge, phase: badgePhase),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UITextStyleToken.interSemiBold.copyWith(fontSize: 16, color: colors.contentColor),
              ),
              Text(
                balance.currency.code,
                style: UITextStyleToken.interBold.copyWith(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: colors.secondContentColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final balanceText = Text(
      balance.format(signed: true),
      style: UITextStyleToken.interSemiBold.copyWith(
        fontSize: 16,
        letterSpacing: -0.43,
        color: colors.contentColor,
      ),
    );

    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Align(alignment: Alignment.centerLeft, child: hero(nameHeroTag, nameBlock))),
            const UISpace.horz(12),
            trailing ?? hero(balanceHeroTag, balanceText),
          ],
        ),
      ),
    );
  }
}
