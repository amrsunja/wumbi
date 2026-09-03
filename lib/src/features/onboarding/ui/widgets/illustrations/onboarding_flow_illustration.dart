import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/design_system/app_ui.dart';
import 'illustration_canvas.dart';

/// «How it works» — a three-stop route: Wallet → Tap → Totals.
///
/// The route draws itself left→right, each stop pops in the moment the line
/// reaches it, labels fade under them. Idle: a glowing dot travels the route
/// and each stop pings as it passes — the loop of using the app.
class OnboardingFlowIllustration extends StatefulWidget {
  const OnboardingFlowIllustration({
    super.key,
    this.labels = const ['Add a wallet', 'Tap to log', 'See totals'],
  });

  /// Three stop labels (localised by the caller).
  final List<String> labels;

  @override
  State<OnboardingFlowIllustration> createState() => _State();
}

class _State extends IllustrationState<OnboardingFlowIllustration> {
  @override
  Duration get introDuration => const Duration(milliseconds: 2000);

  @override
  Duration get idleDuration => const Duration(milliseconds: 4500);

  @override
  CustomPainter painter(UIColorToken colors, double intro, double idle) =>
      _FlowPainter(colors: colors, intro: intro, idle: idle, labels: widget.labels);
}

class _FlowPainter extends CustomPainter {
  _FlowPainter({required this.colors, required this.intro, required this.idle, required this.labels});

  final UIColorToken colors;
  final double intro;
  final double idle;
  final List<String> labels;

  /// Stops (normalised), a gentle S from bottom-left to top-right.
  static const _stops = [Offset(0.16, 0.74), Offset(0.50, 0.46), Offset(0.84, 0.22)];
  static const _lineWindow = 0.6;

  static const _accent = [UIColorToken.blue, UIColorToken.violet, UIColorToken.mountainMeadow];

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    final k = side / 320;

    final path = _route(side);
    _paintRoute(canvas, side, path);
    _paintTraveller(canvas, side, path);
    _paintStops(canvas, side, k);
    _paintSparkles(canvas, side);
  }

  Path _route(double side) {
    Offset p(Offset o) => Offset(o.dx * side, o.dy * side);
    final a = p(_stops[0]), b = p(_stops[1]), c = p(_stops[2]);
    return Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(a.dx + side * 0.22, a.dy, b.dx - side * 0.22, b.dy, b.dx, b.dy)
      ..cubicTo(b.dx + side * 0.22, b.dy, c.dx - side * 0.22, c.dy, c.dx, c.dy);
  }

  void _paintRoute(Canvas canvas, double side, Path path) {
    final drawT = Interval(0.0, _lineWindow, curve: Curves.easeInOutCubic).transform(intro);
    if (drawT == 0) return;
    final metric = path.computeMetrics().first;

    // Dashed ghost of the whole route underneath.
    final ghost = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = side * 0.008
      ..color = colors.secondContentColor.withValues(alpha: 0.25 * drawT);
    final dash = side * 0.02;
    var d = 0.0;
    while (d < metric.length) {
      canvas.drawPath(metric.extractPath(d, math.min(d + dash, metric.length)), ghost);
      d += dash * 2;
    }

    final visible = metric.extractPath(0, metric.length * drawT);
    canvas.drawPath(
      visible,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = side * 0.014
        ..shader = const LinearGradient(colors: [UIColorToken.blue, UIColorToken.violet, UIColorToken.mountainMeadow])
            .createShader(Rect.fromLTWH(0, 0, side, side)),
    );
  }

  /// Position 0..1 of the travelling dot along the route (idle only).
  double get _travel => Curves.easeInOutSine.transform(idle);

  void _paintTraveller(Canvas canvas, double side, Path path) {
    if (intro < 1) return;
    final metric = path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(metric.length * _travel);
    if (tangent == null) return;
    final c = tangent.position;
    final r = side * 0.022;
    // Fades at both ends so the loop restart is invisible.
    final life = math.sin(math.pi * idle);

    canvas.drawCircle(c, r * 2.6, Paint()..color = UIColorToken.blue.withValues(alpha: 0.16 * life));
    canvas.drawCircle(c, r, Paint()..color = UIColorToken.white.withValues(alpha: life));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = side * 0.006
        ..color = UIColorToken.blue.withValues(alpha: life),
    );
  }

  double _stopStart(int i) => _lineWindow * (i / (_stops.length - 0.6));

  void _paintStops(Canvas canvas, double side, double k) {
    for (var i = 0; i < _stops.length; i++) {
      final start = _stopStart(i);
      final pop = IllustrationCanvas.pop(intro, start, span: 0.38);
      if (pop == 0) continue;

      final c = Offset(_stops[i].dx * side, _stops[i].dy * side);
      final r = side * 0.085;
      final color = _accent[i];

      // Ping as the traveller passes (idle), otherwise a slow breath.
      final dist = (_travel - i / (_stops.length - 1)).abs();
      final ping = intro == 1 ? math.max(0.0, 1 - dist / 0.12) : 0.0;
      final breathe = 1 + 0.03 * math.sin(2 * math.pi * idle + i * 2.1);

      if (ping > 0) {
        IllustrationCanvas.ripple(canvas, c, r, 1 - ping, color, stroke: side * 0.007);
      }

      IllustrationCanvas.scaled(canvas, c, pop * breathe * (1 + 0.08 * ping), () {
        canvas.drawShadow(Path()..addOval(Rect.fromCircle(center: c, radius: r)), color.withValues(alpha: 0.35), 8, true);
        canvas.drawCircle(c, r, Paint()..color = colors.fgColor);
        canvas.drawCircle(
          c,
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = side * 0.008
            ..color = color.withValues(alpha: 0.6 + 0.4 * ping),
        );
        switch (i) {
          case 0:
            _wallet(canvas, c, r * 0.9, color);
          case 1:
            _plus(canvas, c, r * 0.9, color);
          default:
            _bars(canvas, c, r * 0.9, color);
        }
      });

      // Step number chip + label.
      final labelFade = IllustrationCanvas.fade(intro, start + 0.12, span: 0.15);
      final below = i != 1; // middle label sits above to keep the route clear
      final ly = below ? c.dy + r * 1.65 : c.dy - r * 1.65;
      IllustrationCanvas.text(
        canvas,
        labels.length > i ? labels[i] : '',
        style: UITextStyleToken.interSemiBold.copyWith(fontSize: 12 * k, color: colors.contentColor),
        center: Offset(c.dx, ly),
        opacity: labelFade,
        maxWidth: side * 0.34,
      );
      IllustrationCanvas.text(
        canvas,
        'STEP ${i + 1}',
        style: UITextStyleToken.interBold.copyWith(fontSize: 7.5 * k, letterSpacing: 1.3, color: color),
        center: Offset(c.dx, ly + (below ? side * 0.055 : -side * 0.055)),
        opacity: labelFade,
      );
    }
  }

  void _wallet(Canvas canvas, Offset c, double r, Color color) {
    final rect = Rect.fromCenter(center: c, width: r * 1.2, height: r * 0.9);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.14
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(r * 0.2)), p);
    // Clasp
    canvas.drawCircle(Offset(rect.right - r * 0.28, c.dy), r * 0.11, Paint()..color = color);
    canvas.drawLine(Offset(rect.left, c.dy - r * 0.16), Offset(rect.right, c.dy - r * 0.16), p..strokeWidth = r * 0.08);
  }

  void _plus(Canvas canvas, Offset c, double r, Color color) {
    final p = Paint()
      ..strokeWidth = r * 0.16
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawLine(c.translate(-r * 0.45, 0), c.translate(r * 0.45, 0), p);
    canvas.drawLine(c.translate(0, -r * 0.45), c.translate(0, r * 0.45), p);
  }

  void _bars(Canvas canvas, Offset c, double r, Color color) {
    final p = Paint()
      ..strokeWidth = r * 0.2
      ..strokeCap = StrokeCap.round
      ..color = color;
    final heights = [0.35, 0.6, 0.9];
    for (var i = 0; i < 3; i++) {
      final x = c.dx + (i - 1) * r * 0.42;
      final grow = intro == 1 ? 1 + 0.08 * math.sin(2 * math.pi * idle * 2 + i) : 1.0;
      canvas.drawLine(Offset(x, c.dy + r * 0.45), Offset(x, c.dy + r * 0.45 - r * heights[i] * grow), p);
    }
  }

  void _paintSparkles(Canvas canvas, double side) {
    final fade = IllustrationCanvas.fade(intro, 0.8, span: 0.2);
    if (fade == 0) return;
    const spots = [
      (x: 0.08, y: 0.22, phase: 0.0, color: UIColorToken.blue),
      (x: 0.62, y: 0.86, phase: 2.2, color: UIColorToken.violet),
      (x: 0.94, y: 0.60, phase: 4.1, color: UIColorToken.mountainMeadow),
    ];
    for (final s in spots) {
      final tw = math.max(0.0, math.sin(2 * math.pi * idle * 2 + s.phase));
      IllustrationCanvas.sparkle(
        canvas,
        Offset(s.x * side, s.y * side),
        side * 0.016 * (0.5 + 0.5 * tw),
        s.color,
        fade * tw,
        stroke: side * 0.007,
      );
    }
  }

  @override
  bool shouldRepaint(_FlowPainter old) =>
      old.intro != intro || old.idle != idle || old.colors != colors || old.labels != labels;
}
