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
    this.countUpKey,
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

  /// When set, the balance counts up from 0 the first time a card with this
  /// key shows (once per app run; dashboard).
  final Object? countUpKey;

  @override
  Widget build(BuildContext context) {
    final typo = AppTheme.of(context).typo.inter;

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
                style: typo.rowTitle,
              ),
              Text(
                balance.currency.code,
                style: typo.currencyCode,
              ),
            ],
          ),
        ),
      ],
    );

    final balanceStyle = typo.rowTitle.copyWith(letterSpacing: -0.43);
    final balanceText = countUpKey != null
        ? UiCountUp(
            duration: const Duration(milliseconds: 650),
            // Gentler than the total's: the row's own stagger fade would hide
            // an early rush.
            curve: Curves.easeOutCubic,
            // The row already rises in.
            rise: 0,
            blur: 4,
            once: countUpKey,
            builder: (p, _) => Text(
              Money((balance.minor * p).round(), balance.currency).format(signed: true),
              style: balanceStyle,
            ),
          )
        : Text(balance.format(signed: true), style: balanceStyle);

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
