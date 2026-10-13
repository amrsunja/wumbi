import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Circular budget gauge `[spent | planned | free]` — the round sibling of
/// [UiBudgetBar] for the budget details hero. The arcs sweep in from zero on
/// first build and glide to new values afterwards (period browsing, edits).
///
/// Ratios are fractions of the effective limit and are clamped, so an
/// overspent budget closes the ring in its status colour. [child] sits in the
/// middle (remaining amount, caption…).
class UiBudgetRing extends StatelessWidget {
  const UiBudgetRing({
    super.key,
    required this.spentRatio,
    this.plannedRatio = 0,
    required this.color,
    this.size = 216,
    this.strokeWidth = 14,
    this.duration = const Duration(milliseconds: 1100),
    this.child,
  });

  final double spentRatio;
  final double plannedRatio;

  /// Status colour.
  final Color color;
  final double size;
  final double strokeWidth;
  final Duration duration;
  final Widget? child;

  static double _clamp(double v) => v.isNaN ? 0 : v.clamp(0.0, 1.0).toDouble();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    final spent = _clamp(spentRatio);
    final planned = _clamp(plannedRatio).clamp(0.0, 1.0 - spent).toDouble();

    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<Offset>(
        // `begin` only applies to the first build: the ring sweeps in once,
        // later changes animate from wherever it is.
        tween: Tween<Offset>(begin: Offset.zero, end: Offset(spent, planned)),
        duration: duration,
        curve: Curves.easeOutQuart,
        builder: (context, v, child) => CustomPaint(
          painter: _RingPainter(
            spent: v.dx,
            planned: v.dy,
            color: color,
            track: colors.secondContentColor.withValues(alpha: 0.16),
            strokeWidth: strokeWidth,
          ),
          child: child,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(strokeWidth + 14),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.spent,
    required this.planned,
    required this.color,
    required this.track,
    required this.strokeWidth,
  });

  final double spent;
  final double planned;
  final Color color;
  final Color track;
  final double strokeWidth;

  static const double _start = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    Paint stroke(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, stroke(track));

    const full = math.pi * 2;
    // Planned first (from the end of spent), spent on top of it.
    if (planned > 0.001) {
      canvas.drawArc(rect, _start + full * spent, full * planned, false, stroke(color.withValues(alpha: 0.35)));
    }
    if (spent > 0.001) {
      // A closed ring draws without the round-cap overlap seam.
      final sweep = spent >= 0.999 ? full : full * spent;
      final paint = stroke(color);
      if (spent >= 0.999) paint.strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, _start, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.spent != spent ||
      old.planned != planned ||
      old.color != color ||
      old.track != track ||
      old.strokeWidth != strokeWidth;
}
