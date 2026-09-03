import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/design_system/app_ui.dart';
import 'illustration_canvas.dart';

/// Benefit 2 — «Tags, not categories».
///
/// A single transaction card in the middle; free-form tag chips pop in around
/// it and attach with hairlines. Idle: chips float on their own phase and a
/// highlight ping travels from chip to chip — the "one expense, many tags"
/// beat.
class OnboardingTagsIllustration extends StatefulWidget {
  const OnboardingTagsIllustration({super.key});

  @override
  State<OnboardingTagsIllustration> createState() => _State();
}

class _State extends IllustrationState<OnboardingTagsIllustration> {
  @override
  Duration get idleDuration => const Duration(milliseconds: 5000);

  @override
  CustomPainter painter(AppThemeData theme, double intro, double idle) =>
      _TagsPainter(colors: theme.colors, typo: theme.typo, intro: intro, idle: idle);
}

class _TagsPainter extends CustomPainter {
  _TagsPainter({required this.colors, required this.typo, required this.intro, required this.idle});

  final UIColorToken colors;
  final UITypographyToken typo;
  final double intro;
  final double idle;

  static const _card = Offset(0.5, 0.52);

  static const _tags = [
    (label: '#coffee', x: 0.20, y: 0.16, start: 0.30, phase: 0.0),
    (label: '#friends', x: 0.74, y: 0.12, start: 0.40, phase: 1.3),
    (label: '#work', x: 0.86, y: 0.42, start: 0.50, phase: 2.6),
    (label: '#weekend', x: 0.78, y: 0.86, start: 0.60, phase: 3.9),
    (label: '#trip', x: 0.22, y: 0.90, start: 0.70, phase: 5.2),
    (label: '#food', x: 0.10, y: 0.52, start: 0.80, phase: 0.7),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    final k = side / 320;

    _paintLinks(canvas, side);
    _paintCard(canvas, side, k);
    _paintTags(canvas, side, k);
  }

  Offset _tagCenter(int i, double side) {
    final t = _tags[i];
    final float = math.sin(2 * math.pi * idle + t.phase) * side * 0.010;
    return Offset(t.x * side, t.y * side + float);
  }

  /// Which chip is currently "pinged" (idle loop split evenly).
  int get _activeTag => (idle * _tags.length).floor() % _tags.length;
  double get _pingT => (idle * _tags.length) % 1.0;

  void _paintLinks(Canvas canvas, double side) {
    final c = Offset(_card.dx * side, _card.dy * side);
    for (var i = 0; i < _tags.length; i++) {
      final grow = IllustrationCanvas.pop(intro, _tags[i].start - 0.08, span: 0.30, curve: Curves.easeOutCubic);
      if (grow == 0) continue;
      final end = _tagCenter(i, side);
      final p = Offset.lerp(c, end, grow)!;
      final active = intro == 1 && i == _activeTag;
      canvas.drawLine(
        c,
        p,
        Paint()
          ..strokeWidth = side * (active ? 0.006 : 0.004)
          ..strokeCap = StrokeCap.round
          ..color = UIColorToken.blue.withValues(alpha: active ? 0.35 + 0.35 * math.sin(math.pi * _pingT) : 0.16),
      );
    }
  }

  void _paintCard(Canvas canvas, double side, double k) {
    final pop = IllustrationCanvas.pop(intro, 0.02, span: 0.4, curve: Curves.easeOutBack);
    final fade = IllustrationCanvas.fade(intro, 0.02);
    if (fade == 0) return;

    final breathe = 1 + 0.012 * math.sin(2 * math.pi * idle);
    final c = Offset(_card.dx * side, _card.dy * side);
    final w = side * 0.56;
    final h = side * 0.30;
    final rect = Rect.fromCenter(center: c, width: w, height: h);

    IllustrationCanvas.scaled(canvas, c, (0.8 + 0.2 * pop) * breathe, () {
      IllustrationCanvas.card(canvas, rect, fill: colors.fgColor, radius: h * 0.22, opacity: fade, shadowAlpha: 0.14);

      IllustrationCanvas.text(
        canvas,
        'Coffee with Anna',
        style: typo.inter.semiBold.copyWith(fontSize: 13 * k, color: colors.contentColor),
        left: Offset(rect.left + w * 0.09, rect.top + h * 0.28),
        opacity: fade,
        maxWidth: w * 0.85,
      );
      IllustrationCanvas.text(
        canvas,
        'Today, 09:12',
        style: typo.inter.medium.copyWith(fontSize: 9.5 * k, color: colors.secondContentColor),
        left: Offset(rect.left + w * 0.09, rect.top + h * 0.50),
        opacity: fade,
      );
      IllustrationCanvas.text(
        canvas,
        '-\$4.50',
        style: typo.montserrat.bold.copyWith(fontSize: 20 * k, color: colors.expenseColor),
        left: Offset(rect.left + w * 0.09, rect.top + h * 0.78),
        opacity: fade,
      );

      // Tiny "#" hint the tags come out of.
      final tagDot = Offset(rect.right - w * 0.12, rect.top + h * 0.30);
      canvas.drawCircle(tagDot, h * 0.13, Paint()..color = UIColorToken.blue.withValues(alpha: 0.14 * fade));
      IllustrationCanvas.text(
        canvas,
        '#',
        style: typo.inter.bold.copyWith(fontSize: 13 * k, color: UIColorToken.blue),
        center: tagDot,
        opacity: fade,
      );
    });
  }

  void _paintTags(Canvas canvas, double side, double k) {
    for (var i = 0; i < _tags.length; i++) {
      final t = _tags[i];
      final pop = IllustrationCanvas.pop(intro, t.start, span: 0.32);
      final fade = IllustrationCanvas.fade(intro, t.start, span: 0.08);
      if (fade == 0) continue;

      final c = _tagCenter(i, side);
      final active = intro == 1 && i == _activeTag;
      final glow = active ? math.sin(math.pi * _pingT) : 0.0;

      final style = typo.inter.semiBold.copyWith(fontSize: 12 * k, color: UIColorToken.blue);
      final tp = TextPainter(text: TextSpan(text: t.label, style: style), textDirection: TextDirection.ltr)..layout();
      final w = tp.width + side * 0.075;
      final h = side * 0.085;
      final rect = Rect.fromCenter(center: c, width: w, height: h);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(h / 2));

      IllustrationCanvas.scaled(canvas, c, pop * (1 + 0.08 * glow), () {
        if (glow > 0) {
          IllustrationCanvas.ripple(canvas, c, h * 0.9, _pingT, UIColorToken.blue, stroke: side * 0.006);
        }
        canvas.drawShadow(Path()..addRRect(rrect), UIColorToken.blue.withValues(alpha: 0.18 + 0.25 * glow), 5, true);
        canvas.drawRRect(
          rrect,
          Paint()..color = Color.lerp(_chipFill, UIColorToken.blue, glow * 0.85)!.withValues(alpha: fade),
        );
        IllustrationCanvas.text(
          canvas,
          t.label,
          style: style.copyWith(color: Color.lerp(UIColorToken.blue, UIColorToken.white, glow)),
          center: c,
          opacity: fade,
        );
      });
    }
  }

  Color get _chipFill => colors.isDark ? UIColorToken.blue.withValues(alpha: 0.18) : UIColorToken.linkWater;

  @override
  bool shouldRepaint(_TagsPainter old) => old.intro != intro || old.idle != idle || old.colors != colors;
}
