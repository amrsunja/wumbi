import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/design_system/app_ui.dart';
import 'illustration_canvas.dart';

/// Benefit 1 — «Wallets in any currency».
///
/// Three wallet rows (USD / EUR / BTC) deal in one after another like cards,
/// currency badges pop in above them; idle: rows breathe on their own phase,
/// badges orbit gently and twinkle.
class OnboardingWalletsIllustration extends StatefulWidget {
  const OnboardingWalletsIllustration({super.key});

  @override
  State<OnboardingWalletsIllustration> createState() => _State();
}

class _State extends IllustrationState<OnboardingWalletsIllustration> {
  @override
  Duration get idleDuration => const Duration(milliseconds: 5000);

  @override
  CustomPainter painter(AppThemeData theme, double intro, double idle) =>
      _WalletsPainter(colors: theme.colors, typo: theme.typo, intro: intro, idle: idle);
}

class _WalletsPainter extends CustomPainter {
  _WalletsPainter({required this.colors, required this.typo, required this.intro, required this.idle});

  final UIColorToken colors;
  final UITypographyToken typo;
  final double intro;
  final double idle;

  static const _wallets = [
    (name: 'Checking', code: 'USD', amount: '\$5,678.90', color: UIColorToken.blue, y: 0.34, start: 0.05, phase: 0.0),
    (name: 'Savings', code: 'EUR', amount: '€2,340.00', color: UIColorToken.mountainMeadow, y: 0.58, start: 0.22, phase: 2.1),
    (name: 'Crypto', code: 'BTC', amount: '₿0.0421', color: UIColorToken.buttercup, y: 0.82, start: 0.39, phase: 4.2),
  ];

  static const _badges = [
    (symbol: '\$', x: 0.18, y: 0.13, color: UIColorToken.blue, start: 0.58, dir: 1.0),
    (symbol: '€', x: 0.50, y: 0.08, color: UIColorToken.mountainMeadow, start: 0.66, dir: -1.0),
    (symbol: '₿', x: 0.82, y: 0.14, color: UIColorToken.buttercup, start: 0.74, dir: 1.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    final k = side / 320; // typography scale

    _paintRows(canvas, side, k);
    _paintBadges(canvas, side, k);
    _paintSparkles(canvas, side);
  }

  void _paintRows(Canvas canvas, double side, double k) {
    final w = side * 0.86;
    final h = side * 0.18;

    for (var i = 0; i < _wallets.length; i++) {
      final wlt = _wallets[i];
      final pop = IllustrationCanvas.pop(intro, wlt.start, span: 0.4, curve: Curves.easeOutBack);
      final fade = IllustrationCanvas.fade(intro, wlt.start);
      if (fade == 0) continue;

      // Deal-in: slides up while scaling; idle: slow breathing float.
      final float = math.sin(2 * math.pi * idle + wlt.phase) * side * 0.008;
      final slide = (1 - pop) * side * 0.10;
      final center = Offset(side / 2, wlt.y * side + float + slide);
      final rect = Rect.fromCenter(center: center, width: w, height: h);

      IllustrationCanvas.scaled(canvas, center, 0.85 + 0.15 * pop, () {
        IllustrationCanvas.card(canvas, rect, fill: colors.fgColor, radius: h * 0.3, opacity: fade);

        // Colour dot
        final dot = Offset(rect.left + h * 0.42, rect.center.dy);
        canvas.drawCircle(dot, h * 0.11, Paint()..color = wlt.color.withValues(alpha: fade));
        canvas.drawCircle(
          dot,
          h * 0.11 * 2.1,
          Paint()..color = wlt.color.withValues(alpha: fade * 0.14),
        );

        // Name + code
        final textLeft = rect.left + h * 0.80;
        IllustrationCanvas.text(
          canvas,
          wlt.name,
          style: typo.inter.semiBold.copyWith(fontSize: 14 * k, color: colors.contentColor),
          left: Offset(textLeft, rect.center.dy - h * 0.16),
          opacity: fade,
        );
        IllustrationCanvas.text(
          canvas,
          wlt.code,
          style: typo.inter.bold.copyWith(fontSize: 9.5 * k, letterSpacing: 1.2, color: colors.secondContentColor),
          left: Offset(textLeft, rect.center.dy + h * 0.20),
          opacity: fade,
        );

        // Amount
        IllustrationCanvas.text(
          canvas,
          wlt.amount,
          style: typo.montserrat.light.copyWith(fontSize: 16 * k, color: colors.contentColor),
          center: Offset(rect.right - h * 1.05, rect.center.dy),
          opacity: fade,
          maxWidth: w * 0.42,
        );
      });
    }
  }

  void _paintBadges(Canvas canvas, double side, double k) {
    for (var i = 0; i < _badges.length; i++) {
      final b = _badges[i];
      final pop = IllustrationCanvas.pop(intro, b.start, span: 0.3);
      if (pop == 0) continue;

      // Small elliptic orbit around the anchor — one loop per idle cycle.
      final a = b.dir * 2 * math.pi * idle + i * 2.0;
      final c = Offset(
        b.x * side + math.cos(a) * side * 0.018,
        b.y * side + math.sin(a) * side * 0.012,
      );
      final r = side * 0.062 * pop;

      canvas.drawCircle(c, r * 1.35, Paint()..color = b.color.withValues(alpha: 0.12));
      canvas.drawShadow(Path()..addOval(Rect.fromCircle(center: c, radius: r)), b.color.withValues(alpha: 0.35), 6, true);
      canvas.drawCircle(c, r, Paint()..color = b.color);
      IllustrationCanvas.text(
        canvas,
        b.symbol,
        style: typo.inter.bold.copyWith(fontSize: 16 * k * pop, color: UIColorToken.white),
        center: c,
      );
    }
  }

  void _paintSparkles(Canvas canvas, double side) {
    final fade = IllustrationCanvas.fade(intro, 0.8, span: 0.2);
    if (fade == 0) return;
    const spots = [
      (x: 0.06, y: 0.28, phase: 0.0, color: UIColorToken.blue),
      (x: 0.95, y: 0.44, phase: 2.2, color: UIColorToken.violet),
      (x: 0.90, y: 0.95, phase: 4.1, color: UIColorToken.buttercup),
      (x: 0.08, y: 0.70, phase: 1.3, color: UIColorToken.mountainMeadow),
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
  bool shouldRepaint(_WalletsPainter old) => old.intro != intro || old.idle != idle || old.colors != colors;
}
