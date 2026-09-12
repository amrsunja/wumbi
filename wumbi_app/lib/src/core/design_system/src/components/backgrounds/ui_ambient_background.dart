import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Slow, soft blue light drifting along the top and bottom edges of a page
/// (Lissajous paths with integer frequencies → the 32 s loop is seamless).
/// The middle stays on the Carrara ground where the content sits. Radial
/// gradients only — no blur filters — inside its own [RepaintBoundary].
class UiAmbientBackground extends StatefulWidget {
  const UiAmbientBackground({super.key, this.colors, this.intensity = 1});

  /// Blob tints; defaults to the blue family (blue · sky · link water · casper).
  final List<Color>? colors;

  /// 0..1 multiplier on the blob alpha.
  final double intensity;

  static const List<Color> bluePalette = [
    UIColorToken.violet, // 3B82F6
    UIColorToken.blue, // 3B82F6
    Color(0xff60A5FA), // sky
    Color(0xff2563EB),
    UIColorToken.blue,
    UIColorToken.violet, // 3B82F6
  ];

  @override
  State<UiAmbientBackground> createState() => _UiAmbientBackgroundState();
}

class _UiAmbientBackgroundState extends State<UiAmbientBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 32))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context).colors;
    final custom = widget.colors;
    final tints = custom == null || custom.isEmpty ? UiAmbientBackground.bluePalette : custom;
    final alpha = (theme.isDark ? 0.14 : 0.2) * widget.intensity;

    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, _) => CustomPaint(
            painter: _AmbientPainter(t: _controller.value, tints: tints, alpha: alpha, dark: theme.isDark),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  _AmbientPainter({required this.t, required this.tints, required this.alpha, required this.dark});

  final double t;
  final List<Color> tints;
  final double alpha;
  final bool dark;

  /// Per blob: fx, fy (INTEGER drift frequencies → every term is periodic in
  /// one 2π loop, so `repeat()` wraps with no visible jump), phase, radius
  /// (× max side), anchor cx, cy (× size), x / y drift amplitude (× size),
  /// alpha weight. Blobs live along the top and bottom edges only.
  static const _blobs = <List<double>>[
    // top
    //[1, 2, 0.0, 0.30, 0.18, 0.02, 0.22, 0.05, 1.00], // deep blue
    //[2, 1, 2.1, 0.24, 0.78, 0.08, 0.18, 0.05, 0.85], // blue
    //[1, 3, 4.0, 0.20, 0.50, -0.04, 0.30, 0.04, 0.60], // sky, wide sweep
    // bottom
    [2, 1, 1.0, 0.32, 0.80, 0.98, 0.22, 0.05, 1.00], // deep blue
    [1, 2, 3.3, 0.26, 0.22, 0.92, 0.20, 0.06, 0.85], // blue
    [3, 1, 5.2, 0.18, 0.55, 1.04, 0.28, 0.04, 0.60], // sky, wide sweep
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (tints.isEmpty) return;
    final base = math.max(size.width, size.height);
    final angle = t * 2 * math.pi;

    for (var i = 0; i < _blobs.length; i++) {
      final b = _blobs[i];
      final dx = math.sin(angle * b[0] + b[2]) * size.width * b[6];
      final dy = math.cos(angle * b[1] + b[2]) * size.height * b[7];
      final center = Offset(size.width * b[4] + dx, size.height * b[5] + dy);
      final radius = base * b[3];
      // Gentle pulse (±12 %), integer frequency → seamless loop.
      final pulse = 1 + 0.12 * math.sin(angle + b[2]);
      final a = (alpha * b[8] * pulse).clamp(0.0, 1.0);
      final color = tints[i % tints.length];

      final paint = Paint()
        ..blendMode = dark ? BlendMode.screen : BlendMode.multiply
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: a),
            color.withValues(alpha: a * 0.5),
            color.withValues(alpha: 0),
          ],
          stops: const [0, 0.40, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_AmbientPainter old) =>
      old.t != t || old.alpha != alpha || old.tints != tints || old.dark != dark;
}
