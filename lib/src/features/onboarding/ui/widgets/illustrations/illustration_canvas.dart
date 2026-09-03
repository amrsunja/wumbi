import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/design_system/app_ui.dart';

/// Shared helpers for the onboarding canvas illustrations.
///
/// Every illustration follows the same motion recipe:
/// 1. `intro` (0..1, played once) — elements draw / pop in with a cascade.
/// 2. `idle` (0..1, looping) — every idle motion derives from it with
///    integer frequencies, so the loop wraps seamlessly.
abstract class IllustrationCanvas {
  /// Elastic pop for element [i] out of [count], spread over the intro.
  static double pop(double intro, double start, {double span = 0.35, Curve curve = Curves.elasticOut}) =>
      Interval(start, math.min(start + span, 1.0), curve: curve).transform(intro);

  /// Linear fade window.
  static double fade(double intro, double start, {double span = 0.12}) =>
      Interval(start, math.min(start + span, 1.0)).transform(intro);

  /// Draws [text] centred on [center] (or left-aligned at [left]).
  static void text(
    Canvas canvas,
    String text, {
    required TextStyle style,
    Offset? center,
    Offset? left,
    double opacity = 1,
    double maxWidth = double.infinity,
  }) {
    if (opacity <= 0) return;
    final painter = TextPainter(
      text: TextSpan(text: text, style: style.copyWith(color: style.color?.withValues(alpha: opacity))),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    final origin = center != null
        ? Offset(center.dx - painter.width / 2, center.dy - painter.height / 2)
        : Offset(left!.dx, left.dy - painter.height / 2);
    painter.paint(canvas, origin);
  }

  /// Soft card: rounded rect, faint shadow, optional fill alpha.
  static void card(
    Canvas canvas,
    Rect rect, {
    required Color fill,
    double radius = 18,
    double opacity = 1,
    double shadowAlpha = 0.10,
  }) {
    if (opacity <= 0) return;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    if (shadowAlpha > 0) {
      canvas.drawShadow(
        Path()..addRRect(rrect),
        UIColorToken.bismark.withValues(alpha: shadowAlpha * opacity),
        8,
        true,
      );
    }
    canvas.drawRRect(rrect, Paint()..color = fill.withValues(alpha: opacity));
  }

  /// Applies a scale around [pivot] for the duration of [body].
  static void scaled(Canvas canvas, Offset pivot, double scale, VoidCallback body) {
    if (scale <= 0) return;
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.scale(scale);
    canvas.translate(-pivot.dx, -pivot.dy);
    body();
    canvas.restore();
  }

  /// Four-point twinkle star.
  static void sparkle(Canvas canvas, Offset c, double r, Color color, double alpha, {double stroke = 2}) {
    if (alpha <= 0) return;
    final p = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = color.withValues(alpha: alpha);
    canvas.drawLine(c.translate(-r, 0), c.translate(r, 0), p);
    canvas.drawLine(c.translate(0, -r), c.translate(0, r), p);
  }

  /// Expanding ripple ring; [t] 0..1.
  static void ripple(Canvas canvas, Offset c, double r, double t, Color color, {double stroke = 2}) {
    if (t <= 0 || t >= 1) return;
    canvas.drawCircle(
      c,
      r * (1 + t * 1.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * (1 - t)
        ..color = color.withValues(alpha: (1 - t) * 0.6),
    );
  }
}

/// Boilerplate for a two-controller illustration (intro once + idle loop).
abstract class IllustrationState<T extends StatefulWidget> extends State<T> with TickerProviderStateMixin {
  late final AnimationController intro;
  late final AnimationController idle;

  Duration get introDuration => const Duration(milliseconds: 1800);
  Duration get idleDuration => const Duration(milliseconds: 4000);

  @override
  void initState() {
    super.initState();
    intro = AnimationController(vsync: this, duration: introDuration)..forward();
    idle = AnimationController(vsync: this, duration: idleDuration)..repeat();
  }

  @override
  void dispose() {
    intro.dispose();
    idle.dispose();
    super.dispose();
  }

  CustomPainter painter(AppThemeData theme, double intro, double idle);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([intro, idle]),
        builder: (_, _) => CustomPaint(
          size: Size.infinite,
          painter: painter(theme, intro.value, idle.value),
        ),
      ),
    );
  }
}
