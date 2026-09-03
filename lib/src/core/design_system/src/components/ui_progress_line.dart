import 'package:flutter/material.dart';

import '../../app_ui.dart';

/// Hairline progress bar with a blue → violet gradient fill that animates
/// between values (onboarding header).
class UIProgressLine extends StatelessWidget {
  const UIProgressLine({
    super.key,
    required this.value,
    this.height = 2,
    this.duration = const Duration(milliseconds: 450),
  });

  /// 0.0 – 1.0
  final double value;
  final double height;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value.clamp(0.0, 1.0).toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.secondContentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
            ),
            // Fill: needs an explicit height inside the Stack (a bare
            // DecoratedBox would collapse to zero height).
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: v,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [UIColorToken.blue, UIColorToken.violet]),
                      borderRadius: BorderRadius.circular(height),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
