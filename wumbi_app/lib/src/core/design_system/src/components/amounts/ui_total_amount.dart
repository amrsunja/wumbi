import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';

import '../../../../money/money.dart';
import '../../../app_ui.dart';

enum UiTotalAmountWeight { light, bold }

/// Big Montserrat amount. `animated` uses AnimatedFlipCounter on value change
/// (Dashboard / Wallet Details); the Transaction screen uses plain text.
/// `countUp` (with `animated`) also counts up from 0 the first time the
/// amount shows (Dashboard).
class UiTotalAmount extends StatelessWidget {
  const UiTotalAmount({
    super.key,
    required this.money,
    this.weight = UiTotalAmountWeight.light,
    this.textAlign = TextAlign.center,
    this.animated = false,
    this.countUp = false,
    this.fontSize = 44,
    this.color,
  });

  final Money money;
  final UiTotalAmountWeight weight;
  final TextAlign textAlign;
  final bool animated;
  final bool countUp;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final montserrat = AppTheme.of(context).typo.montserrat;
    final base = weight == UiTotalAmountWeight.bold ? montserrat.input : montserrat.total;
    final style = base.copyWith(fontSize: fontSize, color: color);

    if (animated) {
      final scale = money.currency.scale;
      final value = money.minor.abs() / (scale == 0 ? 1 : _pow10(scale));

      Widget counter(double shown, Duration duration) => FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedFlipCounter(
              value: shown,
              fractionDigits: money.displayScale,
              thousandSeparator: ',',
              prefix: money.isNegative ? '-' : null,
              suffix: money.currency.formatSuffix,
              duration: duration,
              curve: Curves.easeOutCubic,
              textStyle: style,
            ),
          );

      const flip = Duration(milliseconds: 300);
      if (countUp) {
        // Each frame sets the exact value; the flip tween stays off so the
        // digits count instead of rolling.
        return UiCountUp(builder: (p, counting) => counter(value * p, counting ? Duration.zero : flip));
      }
      return counter(value, flip);
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(money.format(signed: true), textAlign: textAlign, style: style),
    );
  }

  static int _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }
}
