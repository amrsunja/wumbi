import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wumbi_logo_data.dart';

/// The Wumbi logo drawn on screen: each glyph of the wordmark is traced with a
/// hairline pen, inked in behind the trace, then the coin lands and the `$` is
/// drawn inside it.
///
/// Geometry comes from `assets/images/app_logo.svg` via [WumbiLogoData], so the
/// mark is vector-crisp at any size and needs no raster asset.
class WumbiLogoDraw extends HookWidget {
  const WumbiLogoDraw({
    super.key,
    this.duration = const Duration(milliseconds: 1500),
    this.delay = const Duration(milliseconds: 80),
    this.inkColor = _ink,
    this.coinColor = _coin,
    this.coinGlyphColor = Colors.white,
    this.strokeWidth = 1.5,
  });

  static const Color _ink = Color(0xff120F1B);
  static const Color _coin = Color(0xff3884FF);

  /// Full draw-in, from the first pen stroke to the settled mark.
  final Duration duration;

  /// Beat before the pen starts, so the page transition can settle first.
  final Duration delay;

  /// Wordmark colour. Pass a light ink on dark surfaces.
  final Color inkColor;

  /// The coin disc.
  final Color coinColor;

  /// The `$` sitting inside the coin.
  final Color coinGlyphColor;

  /// Pen width, in logical pixels — kept constant whatever the mark's size.
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: duration);

    useEffect(() {
      if (delay == Duration.zero) {
        controller.forward();
        return null;
      }
      final timer = Timer(delay, () {
        if (controller.isAnimating || controller.isCompleted) return;
        controller.forward();
      });
      return timer.cancel;
    }, const []);

    return AspectRatio(
      aspectRatio: WumbiLogoData.viewWidth / WumbiLogoData.viewHeight,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, _) => CustomPaint(
            size: Size.infinite,
            painter: _WumbiLogoPainter(
              t: controller.value,
              ink: inkColor,
              coin: coinColor,
              coinGlyph: coinGlyphColor,
              strokeWidth: strokeWidth,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline (all values normalized over [WumbiLogoDraw.duration])
// ---------------------------------------------------------------------------

const double _kGlyphStagger = 0.075; // gap between W · u · m · b · i
const double _kGlyphTrace = 0.40; // pen travel per glyph
const double _kFillDelay = 0.24; // ink starts flowing in behind the pen
const double _kFillSpan = 0.24;
const double _kCoinStart = 0.62;
const double _kCoinEnd = 0.88;
const double _kDollarTraceStart = 0.74;
const double _kDollarTraceEnd = 0.90;
const double _kDollarFillStart = 0.84;
const double _kDollarFillEnd = 1.0;

double _seg(double t, double from, double to) =>
    ((t - from) / (to - from)).clamp(0.0, 1.0);

class _WumbiLogoPainter extends CustomPainter {
  const _WumbiLogoPainter({
    required this.t,
    required this.ink,
    required this.coin,
    required this.coinGlyph,
    required this.strokeWidth,
  });

  final double t;
  final Color ink;
  final Color coin;
  final Color coinGlyph;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(
      size.width / WumbiLogoData.viewWidth,
      size.height / WumbiLogoData.viewHeight,
    );
    if (scale <= 0) return;

    canvas.save();
    canvas.translate(
      (size.width - WumbiLogoData.viewWidth * scale) / 2,
      (size.height - WumbiLogoData.viewHeight * scale) / 2,
    );
    canvas.scale(scale);

    // Pen width is defined in screen pixels, so undo the canvas scale.
    final pen = strokeWidth / scale;

    _paintWord(canvas, pen);
    _paintCoin(canvas, pen);

    canvas.restore();
  }

  void _paintWord(Canvas canvas, double pen) {
    final glyphs = _LogoGeometry.word;
    for (var i = 0; i < glyphs.length; i++) {
      final start = i * _kGlyphStagger;
      final trace = Curves.easeInOutSine.transform(
        _seg(t, start, start + _kGlyphTrace),
      );
      if (trace <= 0) continue;

      final fill = Curves.easeOutCubic.transform(
        _seg(t, start + _kFillDelay, start + _kFillDelay + _kFillSpan),
      );

      _drawGlyph(
        canvas,
        glyphs[i],
        trace: trace,
        fill: fill,
        color: ink,
        pen: pen,
        showPenTip: true,
      );
    }
  }

  void _paintCoin(Canvas canvas, double pen) {
    final land = _seg(t, _kCoinStart, _kCoinEnd);
    if (land <= 0) return;

    final pop = Curves.easeOutBack.transform(land);
    final fade = Curves.easeOut.transform(_seg(t, _kCoinStart, _kCoinStart + 0.10));
    final centre = _LogoGeometry.coin.bounds.center;

    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate((1 - pop) * -0.30);
    canvas.scale(0.55 + 0.45 * pop);
    canvas.translate(-centre.dx, -centre.dy);

    canvas.drawPath(
      _LogoGeometry.coin.path,
      Paint()
        ..style = PaintingStyle.fill
        ..isAntiAlias = true
        ..color = coin.withValues(alpha: fade),
    );

    final dollarTrace = Curves.easeInOutSine.transform(
      _seg(t, _kDollarTraceStart, _kDollarTraceEnd),
    );
    if (dollarTrace > 0) {
      _drawGlyph(
        canvas,
        _LogoGeometry.dollar,
        trace: dollarTrace,
        fill: Curves.easeOutCubic.transform(
          _seg(t, _kDollarFillStart, _kDollarFillEnd),
        ),
        color: coinGlyph,
        pen: pen * 0.8,
        showPenTip: false,
      );
    }

    canvas.restore();
  }

  void _drawGlyph(
    Canvas canvas,
    _Glyph glyph, {
    required double trace,
    required double fill,
    required Color color,
    required double pen,
    required bool showPenTip,
  }) {
    if (fill > 0) {
      canvas.drawPath(
        glyph.path,
        Paint()
          ..style = PaintingStyle.fill
          ..isAntiAlias = true
          ..color = color.withValues(alpha: fill),
      );
    }

    // The pen fades out as the ink behind it reaches full strength.
    final strokeAlpha = (1 - fill).clamp(0.0, 1.0);
    if (strokeAlpha <= 0) return;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = pen
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..color = color.withValues(alpha: strokeAlpha);

    for (final contour in glyph.contours) {
      if (trace >= 1) {
        canvas.drawPath(contour.path, strokePaint);
      } else {
        canvas.drawPath(
          contour.metric.extractPath(0, contour.metric.length * trace),
          strokePaint,
        );
      }
    }

    if (!showPenTip || trace <= 0 || trace >= 1) return;
    final lead = glyph.leadContour;
    final tip = lead.metric.getTangentForOffset(lead.metric.length * trace);
    if (tip == null) return;
    canvas.drawCircle(
      tip.position,
      pen * 1.7,
      Paint()
        ..isAntiAlias = true
        ..color = color.withValues(alpha: strokeAlpha * 0.9),
    );
  }

  @override
  bool shouldRepaint(_WumbiLogoPainter old) =>
      old.t != t ||
      old.ink != ink ||
      old.coin != coin ||
      old.coinGlyph != coinGlyph ||
      old.strokeWidth != strokeWidth;
}

// ---------------------------------------------------------------------------
// Geometry — parsed once, reused for every frame and every splash.
// ---------------------------------------------------------------------------

class _Contour {
  _Contour(this.metric) : path = metric.extractPath(0, metric.length);

  final ui.PathMetric metric;
  final Path path;
}

class _Glyph {
  _Glyph(String data) : path = _parseSvgPath(data) {
    contours = path.computeMetrics().map(_Contour.new).toList(growable: false);
    bounds = path.getBounds();
    leadContour = contours.reduce(
      (a, b) => b.metric.length > a.metric.length ? b : a,
    );
  }

  final Path path;
  late final List<_Contour> contours;
  late final Rect bounds;

  /// Longest contour — the one the pen tip rides.
  late final _Contour leadContour;
}

abstract final class _LogoGeometry {
  static final List<_Glyph> word = WumbiLogoData.word
      .map(_Glyph.new)
      .toList(growable: false);
  static final _Glyph coin = _Glyph(WumbiLogoData.coin);
  static final _Glyph dollar = _Glyph(WumbiLogoData.dollar);
}

final RegExp _svgToken = RegExp(
  r'([MmLlHhVvCcSsQqTtZz])|(-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?)',
);

/// Minimal SVG path-data parser — enough for the commands the logo uses
/// (`M`, `L`, `H`, `V`, `C`, `S`, `Z`, absolute and relative).
Path _parseSvgPath(String data) {
  final path = Path();
  final tokens = _svgToken.allMatches(data).toList(growable: false);

  var i = 0;
  var cmd = '';
  double cx = 0, cy = 0, sx = 0, sy = 0;
  double px = 0, py = 0; // reflected control point for S

  double next() => double.parse(tokens[i++].group(0)!);

  while (i < tokens.length) {
    final letter = tokens[i].group(1);
    if (letter != null) {
      cmd = letter;
      i++;
      if (cmd == 'Z' || cmd == 'z') {
        path.close();
        cx = sx;
        cy = sy;
        px = cx;
        py = cy;
        cmd = '';
        continue;
      }
      if (i >= tokens.length) break;
    }
    if (cmd.isEmpty) {
      i++; // stray number after a close — skip defensively
      continue;
    }

    switch (cmd) {
      case 'M':
        cx = next();
        cy = next();
        path.moveTo(cx, cy);
        sx = cx;
        sy = cy;
        cmd = 'L';
      case 'm':
        cx += next();
        cy += next();
        path.moveTo(cx, cy);
        sx = cx;
        sy = cy;
        cmd = 'l';
      case 'L':
        cx = next();
        cy = next();
        path.lineTo(cx, cy);
      case 'l':
        cx += next();
        cy += next();
        path.lineTo(cx, cy);
      case 'H':
        cx = next();
        path.lineTo(cx, cy);
      case 'h':
        cx += next();
        path.lineTo(cx, cy);
      case 'V':
        cy = next();
        path.lineTo(cx, cy);
      case 'v':
        cy += next();
        path.lineTo(cx, cy);
      case 'C':
      case 'c':
        {
          final rel = cmd == 'c';
          final ox = rel ? cx : 0.0;
          final oy = rel ? cy : 0.0;
          final x1 = ox + next();
          final y1 = oy + next();
          final x2 = ox + next();
          final y2 = oy + next();
          final x = ox + next();
          final y = oy + next();
          path.cubicTo(x1, y1, x2, y2, x, y);
          px = x2;
          py = y2;
          cx = x;
          cy = y;
          continue;
        }
      case 'S':
      case 's':
        {
          final rel = cmd == 's';
          final ox = rel ? cx : 0.0;
          final oy = rel ? cy : 0.0;
          final x1 = 2 * cx - px;
          final y1 = 2 * cy - py;
          final x2 = ox + next();
          final y2 = oy + next();
          final x = ox + next();
          final y = oy + next();
          path.cubicTo(x1, y1, x2, y2, x, y);
          px = x2;
          py = y2;
          cx = x;
          cy = y;
          continue;
        }
      case 'Q':
      case 'q':
        {
          final rel = cmd == 'q';
          final ox = rel ? cx : 0.0;
          final oy = rel ? cy : 0.0;
          final x1 = ox + next();
          final y1 = oy + next();
          final x = ox + next();
          final y = oy + next();
          path.quadraticBezierTo(x1, y1, x, y);
          px = x1;
          py = y1;
          cx = x;
          cy = y;
          continue;
        }
      case 'T':
      case 't':
        {
          final rel = cmd == 't';
          final ox = rel ? cx : 0.0;
          final oy = rel ? cy : 0.0;
          final x1 = 2 * cx - px;
          final y1 = 2 * cy - py;
          final x = ox + next();
          final y = oy + next();
          path.quadraticBezierTo(x1, y1, x, y);
          px = x1;
          py = y1;
          cx = x;
          cy = y;
          continue;
        }
      default:
        i++;
        continue;
    }
    px = cx;
    py = cy;
  }

  return path;
}
