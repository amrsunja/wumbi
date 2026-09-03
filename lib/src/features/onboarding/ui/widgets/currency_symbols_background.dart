import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';

/// Faint currency symbols drifting behind the currency screen — the "world
/// of currencies" the user is picking from. Lissajous drift with integer
/// frequencies → the 24 s loop wraps seamlessly. Ignores pointers.
class CurrencySymbolsBackground extends StatefulWidget {
  const CurrencySymbolsBackground({super.key, this.opacity = 1});

  final double opacity;

  @override
  State<CurrencySymbolsBackground> createState() => _CurrencySymbolsBackgroundState();
}

class _CurrencySymbolsBackgroundState extends State<CurrencySymbolsBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, _) => CustomPaint(
            size: Size.infinite,
            painter: _SymbolsPainter(t: _controller.value, colors: colors, opacity: widget.opacity),
          ),
        ),
      ),
    );
  }
}

class _SymbolsPainter extends CustomPainter {
  _SymbolsPainter({required this.t, required this.colors, required this.opacity});

  final double t;
  final UIColorToken colors;
  final double opacity;

  /// symbol, anchor x/y (× size), font size (× width), drift freq x/y, phase, alpha weight.
  static const _symbols = [
    ('€', 0.12, 0.14, 0.10, 1, 2, 0.0, 0.9),
    ('\$', 0.86, 0.10, 0.12, 2, 1, 1.1, 1.0),
    ('£', 0.08, 0.46, 0.08, 1, 3, 2.3, 0.7),
    ('¥', 0.92, 0.40, 0.09, 3, 1, 3.4, 0.8),
    ('₿', 0.16, 0.80, 0.11, 2, 2, 4.2, 0.9),
    ('₣', 0.88, 0.72, 0.08, 1, 2, 5.0, 0.6),
    ('₹', 0.50, 0.06, 0.07, 2, 3, 0.7, 0.6),
    ('₩', 0.72, 0.90, 0.07, 3, 2, 1.9, 0.6),
    ('₺', 0.30, 0.95, 0.06, 1, 1, 2.8, 0.5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final angle = 2 * math.pi * t;
    final base = colors.isDark ? UIColorToken.blue : UIColorToken.casper;

    for (final s in _symbols) {
      final (sym, ax, ay, fs, fx, fy, phase, w) = s;
      final dx = math.sin(angle * fx + phase) * size.width * 0.03;
      final dy = math.cos(angle * fy + phase) * size.height * 0.02;
      final center = Offset(size.width * ax + dx, size.height * ay + dy);
      final rot = math.sin(angle + phase) * 0.18;
      final alpha = (0.10 + 0.05 * math.sin(angle * 2 + phase)) * w * opacity;

      final tp = TextPainter(
        text: TextSpan(
          text: sym,
          style: UITextStyleToken.montserratBold.copyWith(fontSize: size.width * fs, color: base.withValues(alpha: alpha)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rot);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SymbolsPainter old) => old.t != t || old.colors != colors || old.opacity != opacity;
}
