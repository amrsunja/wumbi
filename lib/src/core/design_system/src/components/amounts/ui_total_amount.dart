import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';

import '../../../../money/money.dart';
import '../../../app_ui.dart';

enum UiTotalAmountWeight { light, bold }

/// Big Montserrat amount. `animated` uses AnimatedFlipCounter on value change
/// (Dashboard / Wallet Details); the Transaction screen uses plain text.
class UiTotalAmount extends StatelessWidget {
  const UiTotalAmount({
    super.key,
    required this.money,
    this.weight = UiTotalAmountWeight.light,
    this.textAlign = TextAlign.center,
    this.animated = false,
    this.fontSize = 44,
    this.color,
  });

  final Money money;
  final UiTotalAmountWeight weight;
  final TextAlign textAlign;
  final bool animated;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    final base = weight == UiTotalAmountWeight.bold
        ? UITextStyleToken.montserratBold
        : UITextStyleToken.montserratLight;
    final style = base.copyWith(fontSize: fontSize, color: color ?? colors.contentColor);

    if (animated) {
      final scale = money.currency.scale;
      final value = money.minor.abs() / (scale == 0 ? 1 : _pow10(scale));
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: AnimatedFlipCounter(
          value: value,
          fractionDigits: scale,
          thousandSeparator: ',',
          prefix: '${money.isNegative ? '-' : ''}${money.currency.formatSymbol}',
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          textStyle: style,
        ),
      );
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
