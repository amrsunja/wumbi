import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';

/// One-shot confetti celebration painted on a full-size canvas.
///
/// Two cannons in the bottom corners fire towards the upper middle; every
/// particle has its own launch velocity, gravity, horizontal drag, spin and
/// a paper-like side-to-side sway while it falls. No dependency — plays
/// automatically after [delay] and fades out by the end, so nothing is left
/// on screen. [OnboardingConfettiState.play] re-fires it (e.g. on the CTA).
class OnboardingConfetti extends StatefulWidget {
  const OnboardingConfetti({
    super.key,
    this.delay = const Duration(milliseconds: 350),
    this.duration = const Duration(milliseconds: 2800),
    this.particles = 90,
  });

  final Duration delay;
  final Duration duration;
  final int particles;

  @override
  State<OnboardingConfetti> createState() => OnboardingConfettiState();
}

class OnboardingConfettiState extends State<OnboardingConfetti> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _seed = 7;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  /// Fires (again). Completes when the burst has played out.
  Future<void> play() async {
    if (_controller.isAnimating) return;
    _seed += 13;
    await _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, _) => CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(t: _controller.value, count: widget.particles, seed: _seed),
          ),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.t, required this.count, required this.seed});

  final double t;
  final int count;
  final int seed;

  static const _colors = [
    UIColorToken.blue,
    Color(0xff60A5FA),
    UIColorToken.violet,
    UIColorToken.buttercup,
    UIColorToken.mountainMeadow,
    UIColorToken.linkWater,
  ];

  // Deterministic pseudo-random 0..1, stable across frames.
  double _rnd(int p, int salt) => ((math.sin(p * 17.0 + salt * 7.0 + seed * 3.0) * 10000).abs()) % 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;

    final alpha = (1 - Interval(0.62, 1.0, curve: Curves.easeIn).transform(t)) * 0.95;
    if (alpha <= 0) return;

    final unit = size.shortestSide;
    // Launch decelerates (drag), gravity pulls ½g·t² — the classic arc.
    final launch = 1 - math.pow(1 - t, 2.6).toDouble();

    for (var p = 0; p < count; p++) {
      final left = p.isEven;
      final origin = Offset(left ? -unit * 0.02 : size.width + unit * 0.02, size.height * (0.92 + 0.05 * _rnd(p, 9)));

      // Aim towards the upper middle with a spread.
      final baseAngle = left ? -math.pi * 0.36 : -math.pi * 0.64;
      final angle = baseAngle + (_rnd(p, 1) - 0.5) * 0.9;
      final speed = unit * (1.05 + 0.95 * _rnd(p, 2));
      final gravity = unit * (0.9 + 0.5 * _rnd(p, 5));

      // Paper sway once the launch energy is spent.
      final sway = math.sin(t * (6 + 6 * _rnd(p, 8)) + p) * unit * 0.025 * t;

      final pos = origin +
          Offset(math.cos(angle), math.sin(angle)) * speed * launch +
          Offset(sway, gravity * t * t);
      if (pos.dy > size.height + unit * 0.1) continue;

      final color = _colors[(_rnd(p, 3) * _colors.length).floor() % _colors.length];
      final paint = Paint()..color = color.withValues(alpha: alpha);
      final spin = _rnd(p, 6) * math.pi * 2 + t * (5 + 9 * _rnd(p, 7));
      // Foreshortening of a spinning rectangle — reads as tumbling paper.
      final flip = 0.35 + 0.65 * math.cos(spin * 1.7).abs();
      final s = unit * (0.014 + 0.012 * _rnd(p, 10));

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(spin);
      final kind = _rnd(p, 4);
      if (kind < 0.25) {
        canvas.drawCircle(Offset.zero, s * 0.55, paint);
      } else if (kind < 0.8) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: s * 1.6, height: s * 0.9 * flip),
            Radius.circular(s * 0.2),
          ),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(-s * 1.1, 0),
          Offset(s * 1.1, 0),
          Paint()
            ..strokeCap = StrokeCap.round
            ..strokeWidth = s * 0.35
            ..color = color.withValues(alpha: alpha),
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t || old.seed != seed || old.count != count;
}
