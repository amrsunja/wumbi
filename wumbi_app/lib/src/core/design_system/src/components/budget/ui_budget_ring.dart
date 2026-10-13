import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Circular budget gauge `[spent | planned | free]` — the round sibling of
/// [UiBudgetBar] for the budget details hero. The arcs sweep in from zero
/// once and glide to new values afterwards (period browsing, edits).
///
/// The sweep is clocked from [sweepStartedAt] (default: first build), not
/// from mount: every instance given the same instant draws the same point of
/// one sweep. A [Hero] shuttle and the ring that replaces it on landing are
/// two instances — sharing the instant keeps it a single continuous sweep.
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
    this.sweepStartedAt,
    this.child,
  });

  final double spentRatio;
  final double plannedRatio;

  /// Status colour.
  final Color color;
  final double size;
  final double strokeWidth;
  final Duration duration;

  /// When the sweep-in began; null = this instance's first build.
  final DateTime? sweepStartedAt;
  final Widget? child;

  static double _clamp(double v) => v.isNaN ? 0 : v.clamp(0.0, 1.0).toDouble();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    final spent = _clamp(spentRatio);
    final planned = _clamp(plannedRatio).clamp(0.0, 1.0 - spent).toDouble();

    return SizedBox.square(
      dimension: size,
      child: _Sweep(
        startedAt: sweepStartedAt,
        duration: duration,
        builder: (context, sweep, child) => TweenAnimationBuilder<Offset>(
          // No own sweep-in (begin == first end): the [_Sweep] factor does
          // it; later value changes glide from wherever the ring is.
          tween: Tween<Offset>(end: Offset(spent, planned)),
          duration: duration,
          curve: Curves.easeOutQuart,
          builder: (context, v, child) => CustomPaint(
            painter: _RingPainter(
              spent: v.dx * sweep,
              planned: v.dy * sweep,
              color: color,
              track: colors.secondContentColor.withValues(alpha: 0.16),
              strokeWidth: strokeWidth,
            ),
            child: child,
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

/// 0 → 1 (easeOutQuart) over [duration], measured from [startedAt]: an
/// instance mounted mid-sweep picks it up where it is, one mounted after it
/// starts full.
class _Sweep extends StatefulWidget {
  const _Sweep({required this.startedAt, required this.duration, required this.builder, required this.child});

  final DateTime? startedAt;
  final Duration duration;
  final ValueWidgetBuilder<double> builder;
  final Widget child;

  @override
  State<_Sweep> createState() => _SweepState();
}

class _SweepState extends State<_Sweep> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart);

  @override
  void initState() {
    super.initState();
    final start = widget.startedAt;
    final total = widget.duration.inMicroseconds;
    final elapsed = start == null ? 0 : DateTime.now().difference(start).inMicroseconds;
    final from = total == 0 ? 1.0 : (elapsed / total).clamp(0.0, 1.0).toDouble();
    if (from >= 1) {
      _controller.value = 1;
    } else {
      _controller.forward(from: from);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _curve,
        builder: (context, child) => widget.builder(context, _curve.value, child),
        child: widget.child,
      );
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
