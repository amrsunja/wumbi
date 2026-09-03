import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app_ui.dart';

enum UiConversionHintState { ok, loading, error, stale }

/// One caption line under the amount: "≈ €113.20 will be added to Savings
/// Vault · 1 USD = 0.9203 EUR" / "Rate unavailable — connect to update".
class UiConversionHint extends StatelessWidget {
  const UiConversionHint({
    super.key,
    required this.text,
    this.state = UiConversionHintState.ok,
    this.onTap,
  });

  final String text;
  final UiConversionHintState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;

    if (state == UiConversionHintState.loading) {
      return Shimmer.fromColors(
        baseColor: colors.secondContentColor.withValues(alpha: 0.35),
        highlightColor: colors.secondContentColor.withValues(alpha: 0.1),
        child: Container(
          width: 220,
          height: 12,
          decoration: BoxDecoration(
            color: colors.secondContentColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
    }

    final color = state == UiConversionHintState.error ? UIColorToken.neg500 : colors.secondContentColor;
    return UITap(
      onTap: onTap,
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.of(context).typo.inter.caption.copyWith(color: color),
      ),
    );
  }
}
