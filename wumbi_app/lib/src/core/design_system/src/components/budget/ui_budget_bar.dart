import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Segmented budget bar `[spent | planned | free]` (spec B&D §6.1).
///
/// Spent is solid [color], planned the same colour at 35 % and the track the
/// secondary content colour at 20 % (same track as [UIProgressLine], which
/// stays the onboarding gradient bar). Ratios are fractions of the effective
/// limit and are clamped, so an overspent budget simply fills the bar.
class UiBudgetBar extends StatelessWidget {
  const UiBudgetBar({
    super.key,
    required this.spentRatio,
    this.plannedRatio = 0,
    required this.color,
    this.height = 6,
    this.duration = const Duration(milliseconds: 450),
  });

  /// 0 – 1 of the effective limit (values above 1 fill the bar).
  final double spentRatio;

  /// 0 – 1 of the effective limit, drawn after the spent segment.
  final double plannedRatio;

  /// Status colour.
  final Color color;

  /// 6 in rows, 10 in the details header, 4 for debts.
  final double height;
  final Duration duration;

  static double _clamp(double v) => v.isNaN ? 0 : v.clamp(0.0, 1.0).toDouble();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    final spent = _clamp(spentRatio);
    final planned = _clamp(plannedRatio).clamp(0.0, 1.0 - spent).toDouble();
    final radius = BorderRadius.circular(height);

    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(end: Offset(spent, planned)),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox(
        height: height,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(color: colors.secondContentColor.withValues(alpha: 0.2)),
              ),
              // Planned first (spent + planned wide), spent on top of it.
              Positioned.fill(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: (v.dx + v.dy).clamp(0.0, 1.0),
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.35), borderRadius: radius),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: v.dx.clamp(0.0, 1.0),
                    heightFactor: 1,
                    child: DecoratedBox(decoration: BoxDecoration(color: color, borderRadius: radius)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
