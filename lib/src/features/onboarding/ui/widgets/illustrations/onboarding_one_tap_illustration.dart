import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/design_system/app_ui.dart';
import 'illustration_canvas.dart';

/// Benefit 3 — «Log it in one tap».
///
/// A mini transaction screen: the amount types itself digit by digit (each
/// key lights up as it is "pressed"), the Income button is tapped — ripple,
/// the amount flips green and a check badge pops. Idle: the button keeps a
/// calm pulse + ripple, the check twinkles.
class OnboardingOneTapIllustration extends StatefulWidget {
  const OnboardingOneTapIllustration({super.key});

  @override
  State<OnboardingOneTapIllustration> createState() => _State();
}

class _State extends IllustrationState<OnboardingOneTapIllustration> {
  @override
  Duration get introDuration => const Duration(milliseconds: 2600);

  @override
  Duration get idleDuration => const Duration(milliseconds: 3600);

  @override
  CustomPainter painter(UIColorToken colors, double intro, double idle) =>
      _OneTapPainter(colors: colors, intro: intro, idle: idle);
}

class _OneTapPainter extends CustomPainter {
  _OneTapPainter({required this.colors, required this.intro, required this.idle});

  final UIColorToken colors;
  final double intro;
  final double idle;

  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '⌫'];

  /// Digits typed during the intro, with the key index they light up.
  static const _sequence = [(ch: '1', key: 0), (ch: '2', key: 1), (ch: '.', key: 9), (ch: '5', key: 4), (ch: '0', key: 10)];

  // Layout (× side). Card 0.04–0.98 tall; numpad rows end at ~0.84, the
  // commit button sits under them, the check badge overlaps the card corner.
  static const _cardRect = Rect.fromLTWH(0.14, 0.04, 0.72, 0.94);
  static const _amountY = 0.16;
  static const _subtitleY = 0.245;
  static const _gridTop = 0.30;
  static const _cell = 0.15;
  static const _cellH = 0.117;
  static const _gap = 0.025;
  static const _commitY = 0.905;
  static const _commitR = 0.048;

  static const _typeStart = 0.16;
  static const _typeEnd = 0.58;
  static const _tapAt = 0.64;
  static const _doneAt = 0.74;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    final k = side / 320;

    _paintPhone(canvas, side);
    _paintAmount(canvas, side, k);
    _paintNumpad(canvas, side, k);
    _paintCommit(canvas, side, k);
  }

  /// How many characters are typed so far and which key is lit.
  (int typed, int litKey, double press) _typing() {
    if (intro < _typeStart) return (0, -1, 0);
    final t = ((intro - _typeStart) / (_typeEnd - _typeStart)).clamp(0.0, 1.0);
    final n = _sequence.length;
    final pos = t * n;
    final idx = math.min(pos.floor(), n - 1);
    final local = pos - idx; // 0..1 inside this keystroke
    final typed = t >= 1 ? n : idx + (local > 0.25 ? 1 : 0);
    final press = t >= 1 ? 0.0 : math.sin(math.pi * local.clamp(0.0, 1.0));
    return (typed, t >= 1 ? -1 : _sequence[idx].key, press);
  }

  double get _committed => Interval(_doneAt, _doneAt + 0.14, curve: Curves.easeOut).transform(intro);

  void _paintPhone(Canvas canvas, double side) {
    final fade = IllustrationCanvas.fade(intro, 0.0, span: 0.15);
    if (fade == 0) return;
    final rect = Rect.fromLTWH(
      _cardRect.left * side,
      _cardRect.top * side,
      _cardRect.width * side,
      _cardRect.height * side,
    );
    IllustrationCanvas.card(canvas, rect, fill: colors.fgColor, radius: side * 0.09, opacity: fade, shadowAlpha: 0.12);
  }

  void _paintAmount(Canvas canvas, double side, double k) {
    final fade = IllustrationCanvas.fade(intro, 0.05, span: 0.12);
    if (fade == 0) return;
    final (typed, _, _) = _typing();
    final text = typed == 0 ? '0.00' : _sequence.take(typed).map((e) => e.ch).join();
    final done = _committed;
    final color = Color.lerp(typed == 0 ? colors.secondContentColor : colors.contentColor, UIColorToken.mountainMeadow, done)!;

    // Bump on each new character.
    final (_, _, press) = _typing();
    final bump = 1 + 0.05 * press;
    final c = Offset(side * 0.5, side * _amountY);

    IllustrationCanvas.scaled(canvas, c, bump * (1 + 0.06 * done), () {
      IllustrationCanvas.text(
        canvas,
        done > 0 ? '+$text' : text,
        style: UITextStyleToken.montserratBold.copyWith(fontSize: 28 * k, color: color),
        center: c,
        opacity: fade,
      );
    });

    // Caret blinking while typing.
    if (intro < _tapAt && typed < _sequence.length) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: UITextStyleToken.montserratBold.copyWith(fontSize: 28 * k)),
        textDirection: TextDirection.ltr,
      )..layout();
      final blink = (math.sin(2 * math.pi * idle * 6) > 0) ? 1.0 : 0.2;
      canvas.drawLine(
        Offset(c.dx + tp.width / 2 + side * 0.012, c.dy - side * 0.05),
        Offset(c.dx + tp.width / 2 + side * 0.012, c.dy + side * 0.05),
        Paint()
          ..strokeWidth = side * 0.006
          ..strokeCap = StrokeCap.round
          ..color = UIColorToken.blue.withValues(alpha: fade * blink),
      );
    }

    IllustrationCanvas.text(
      canvas,
      'USD  ·  Checking',
      style: UITextStyleToken.interMedium.copyWith(fontSize: 9.5 * k, color: colors.secondContentColor),
      center: Offset(side * 0.5, side * _subtitleY),
      opacity: fade,
    );
  }

  void _paintNumpad(Canvas canvas, double side, double k) {
    final (_, lit, press) = _typing();
    final cell = side * _cell;
    final cellH = side * _cellH;
    final gap = side * _gap;
    final gridWidth = 3 * cell + 2 * gap;
    final gridLeft = (side - gridWidth) / 2; // centred in the scene
    final gridTop = side * _gridTop;

    for (var i = 0; i < _keys.length; i++) {
      final pop = IllustrationCanvas.pop(intro, 0.02 + i * 0.012, span: 0.30, curve: Curves.easeOutBack);
      if (pop == 0) continue;
      final col = i % 3;
      final row = i ~/ 3;
      final c = Offset(gridLeft + col * (cell + gap) + cell / 2, gridTop + row * (cellH + gap) + cellH / 2);
      final isLit = i == lit;
      final scale = pop * (isLit ? 1 - 0.10 * press : 1);

      IllustrationCanvas.scaled(canvas, c, scale, () {
        final rect = Rect.fromCenter(center: c, width: cell, height: cellH);
        final fill = Color.lerp(_keyFill, UIColorToken.blue, isLit ? press * 0.9 : 0)!;
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.22)), Paint()..color = fill);
        IllustrationCanvas.text(
          canvas,
          _keys[i],
          style: UITextStyleToken.interMedium.copyWith(
            fontSize: 13 * k,
            color: Color.lerp(colors.contentColor, UIColorToken.white, isLit ? press : 0),
          ),
          center: c,
        );
      });
    }
  }

  void _paintCommit(Canvas canvas, double side, double k) {
    final pop = IllustrationCanvas.pop(intro, 0.10, span: 0.35);
    if (pop == 0) return;

    final c = Offset(side * 0.5, side * _commitY);
    final r = side * _commitR;

    // The tap: squash then release, ripple ring; later a calm idle pulse.
    final tap = Interval(_tapAt, _tapAt + 0.10).transform(intro);
    final squash = 1 - 0.18 * math.sin(math.pi * tap);
    final idlePulse = intro == 1 ? 1 + 0.03 * math.sin(2 * math.pi * idle) : 1.0;
    final double rippleT;
    if (intro == 1) {
      // Idle: one ripple in the first 45 % of every loop.
      final cyc = (idle + 0.5) % 1.0;
      rippleT = cyc < 0.45 ? cyc / 0.45 : 0;
    } else {
      rippleT = Interval(_tapAt + 0.04, _tapAt + 0.26).transform(intro);
    }
    IllustrationCanvas.ripple(canvas, c, r, rippleT, UIColorToken.blue, stroke: side * 0.008);

    IllustrationCanvas.scaled(canvas, c, pop * squash * idlePulse, () {
      canvas.drawShadow(Path()..addOval(Rect.fromCircle(center: c, radius: r)), UIColorToken.blue.withValues(alpha: 0.4), 8, true);
      canvas.drawCircle(c, r, Paint()..color = UIColorToken.blue);
      // Arrow up
      final p = Paint()
        ..color = UIColorToken.white
        ..strokeWidth = side * 0.011
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(c.translate(0, r * 0.42), c.translate(0, -r * 0.42), p);
      canvas.drawLine(c.translate(-r * 0.36, -r * 0.06), c.translate(0, -r * 0.42), p);
      canvas.drawLine(c.translate(r * 0.36, -r * 0.06), c.translate(0, -r * 0.42), p);
    });

    IllustrationCanvas.text(
      canvas,
      'INCOME',
      style: UITextStyleToken.interBold.copyWith(fontSize: 7.5 * k, letterSpacing: 1.4, color: colors.secondContentColor),
      left: c.translate(r * 1.6, 0),
      opacity: pop,
    );

    // Check badge next to the amount once committed.
    final done = IllustrationCanvas.pop(intro, _doneAt, span: 0.26);
    if (done > 0) {
      // Stacked on the card's top-right corner.
      final bc = Offset(_cardRect.right * side - side * 0.02, _cardRect.top * side + side * 0.02);
      final br = side * 0.05;
      final tw = intro == 1 ? 1 + 0.06 * math.sin(2 * math.pi * idle * 2) : 1.0;
      IllustrationCanvas.scaled(canvas, bc, done * tw, () {
        canvas.drawShadow(Path()..addOval(Rect.fromCircle(center: bc, radius: br * 1.2)), UIColorToken.mountainMeadow.withValues(alpha: 0.35), 6, true);
        // White rim so the badge reads as sitting on top of the card.
        canvas.drawCircle(bc, br * 1.2, Paint()..color = colors.fgColor);
        canvas.drawCircle(bc, br, Paint()..color = UIColorToken.mountainMeadow);
        final p = Paint()
          ..color = UIColorToken.white
          ..strokeWidth = side * 0.009
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;
        canvas.drawPath(
          Path()
            ..moveTo(bc.dx - br * 0.42, bc.dy)
            ..lineTo(bc.dx - br * 0.10, bc.dy + br * 0.32)
            ..lineTo(bc.dx + br * 0.46, bc.dy - br * 0.32),
          p,
        );
      });
    }
  }

  Color get _keyFill => colors.isDark ? UIColorToken.white.withValues(alpha: 0.06) : UIColorToken.athensGray;

  @override
  bool shouldRepaint(_OneTapPainter old) => old.intro != intro || old.idle != idle || old.colors != colors;
}
