import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';

/// The hero of the base-currency screen: a glossy coin levitating on a pulsing
/// pool of light. The symbol flips when the selection changes.
///
/// Idle (one seamless 4 s loop): the coin bobs, tilts a hair, its highlight
/// sweeps; the halo behind breathes, the floor shadow shrinks as the coin
/// rises, sparkles twinkle and a few light motes orbit.
class CurrencyCoin extends StatefulWidget {
  const CurrencyCoin({
    super.key,
    required this.symbol,
    required this.code,
    this.size = 150,
    this.onTap,
  });

  final String symbol;
  final String code;
  final double size;
  final VoidCallback? onTap;

  @override
  State<CurrencyCoin> createState() => _CurrencyCoinState();
}

class _CurrencyCoinState extends State<CurrencyCoin> with SingleTickerProviderStateMixin {
  late final AnimationController _idle;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))..repeat();
  }

  @override
  void dispose() {
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    final size = widget.size;
    // Scene is wider/taller than the coin: room for halo, shadow, motes.
    final scene = Size(size * 2.2, size * 1.9);

    return UITap(
      onTap: widget.onTap,
      child: SizedBox.fromSize(
        size: scene,
        child: AnimatedBuilder(
          animation: _idle,
          builder: (context, _) {
            final t = _idle.value;
            final bob = math.sin(2 * math.pi * t); // -1..1, one bob per loop
            final floatY = -bob * size * 0.06;
            final tilt = math.sin(2 * math.pi * t + 1.2) * 0.035;

            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CoinAuraPainter(t: t, bob: bob, coinSize: size, dark: colors.isDark),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, floatY),
                  child: Transform.rotate(
                    angle: tilt,
                    child: _CoinFace(symbol: widget.symbol, code: widget.code, size: size, t: t),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CoinFace extends StatelessWidget {
  const _CoinFace({required this.symbol, required this.code, required this.size, required this.t});

  final String symbol;
  final String code;
  final double size;
  final double t;

  @override
  Widget build(BuildContext context) {
    // Highlight sweeps across the face once per loop.
    final sweep = math.sin(2 * math.pi * t);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(-0.8 + 0.4 * sweep, -1),
          end: Alignment(0.8, 1),
          colors: const [Color(0xff60A5FA), UIColorToken.blue, Color(0xff6D5BF6), UIColorToken.violet],
          stops: const [0, 0.42, 0.78, 1],
        ),
        boxShadow: [
          BoxShadow(color: UIColorToken.blue.withValues(alpha: 0.45), blurRadius: 30, offset: const Offset(0, 14)),
          BoxShadow(color: UIColorToken.violet.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rim ring
          Container(
            width: size * 0.84,
            height: size * 0.84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: UIColorToken.white.withValues(alpha: 0.35), width: size * 0.012),
            ),
          ),
          // Glossy top-left highlight
          Positioned(
            left: size * 0.16,
            top: size * 0.10,
            child: Container(
              width: size * 0.34,
              height: size * 0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.elliptical(size * 0.34, size * 0.2)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    UIColorToken.white.withValues(alpha: 0.55 + 0.15 * sweep),
                    UIColorToken.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          // Symbol — flips when the currency changes.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: Tween<double>(begin: 0.4, end: 1).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Column(
              key: ValueKey(code),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  symbol,
                  style: UITextStyleToken.montserratBold.copyWith(
                    fontSize: size * 0.40,
                    height: 1,
                    color: UIColorToken.white,
                    shadows: [Shadow(color: UIColorToken.black.withValues(alpha: 0.18), blurRadius: 6, offset: const Offset(0, 3))],
                  ),
                ),
                SizedBox(height: size * 0.03),
                Text(
                  code,
                  style: UITextStyleToken.interBold.copyWith(
                    fontSize: size * 0.085,
                    letterSpacing: 2,
                    color: UIColorToken.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Halo + floor shadow + sparkles + orbiting motes behind the coin.
class _CoinAuraPainter extends CustomPainter {
  _CoinAuraPainter({required this.t, required this.bob, required this.coinSize, required this.dark});

  final double t;
  final double bob;
  final double coinSize;
  final bool dark;

  static double _rnd(int p, int salt) => ((math.sin(p * 17.0 + salt * 7.0) * 10000).abs()) % 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = coinSize / 2;
    final pulse = 0.5 + 0.5 * math.sin(2 * math.pi * t);
    final pulse2 = 0.5 + 0.5 * math.sin(2 * math.pi * t * 2 + 2.1);

    // Outer halo — breathes against the inner one.
    canvas.drawCircle(
      c,
      s * (1.65 + 0.12 * pulse),
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 34)
        ..color = UIColorToken.blue.withValues(alpha: (dark ? 0.22 : 0.16) + 0.07 * pulse),
    );
    canvas.drawCircle(
      c,
      s * (1.15 + 0.08 * pulse2),
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
        ..color = UIColorToken.violet.withValues(alpha: 0.12 + 0.06 * pulse2),
    );

    // Floor shadow: further/smaller as the coin rises (bob > 0).
    final lift = (bob + 1) / 2; // 0 low .. 1 high
    final shadowRect = Rect.fromCenter(
      center: Offset(c.dx, c.dy + s * 1.28),
      width: s * (1.5 - 0.35 * lift),
      height: s * (0.28 - 0.07 * lift),
    );
    canvas.drawOval(
      shadowRect,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..color = UIColorToken.bismark.withValues(alpha: 0.18 - 0.07 * lift),
    );

    // Soft light rays, precessing 1/12 turn per loop (seamless).
    const rays = 12;
    final rayPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    for (var i = 0; i < rays; i++) {
      final a = 2 * math.pi * t / rays + i * 2 * math.pi / rays;
      final tw = 0.5 + 0.5 * math.sin(2 * math.pi * t * 2 + i * 2.4);
      rayPaint
        ..strokeWidth = s * 0.05
        ..color = UIColorToken.blue.withValues(alpha: 0.05 + 0.08 * tw);
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * s * 1.08,
        c + Offset(math.cos(a), math.sin(a)) * s * (1.35 + 0.18 * tw),
        rayPaint,
      );
    }

    // Orbiting motes — one revolution per loop on elliptic paths.
    const motes = 5;
    for (var i = 0; i < motes; i++) {
      final dir = i.isEven ? 1.0 : -1.0;
      final a = dir * 2 * math.pi * t + i * 2 * math.pi / motes;
      final rx = s * (1.45 + 0.35 * _rnd(i, 1));
      final ry = s * (0.55 + 0.35 * _rnd(i, 2));
      final pos = c + Offset(math.cos(a) * rx, math.sin(a) * ry - s * 0.1);
      final glow = 0.5 + 0.5 * math.sin(2 * math.pi * t * 3 + i * 1.7);
      // Behind the coin when on the far side of the ellipse.
      final behind = math.sin(a) < 0;
      final alpha = (0.35 + 0.5 * glow) * (behind ? 0.5 : 1);
      canvas.drawCircle(
        pos,
        s * 0.09,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
          ..color = (i.isEven ? UIColorToken.blue : UIColorToken.violet).withValues(alpha: alpha * 0.6),
      );
      canvas.drawCircle(pos, s * 0.035 * (0.7 + 0.5 * glow), Paint()..color = UIColorToken.white.withValues(alpha: alpha));
    }

    // Sparkles.
    const sparks = [
      (dx: -1.55, dy: -0.75, phase: 0.0, freq: 1),
      (dx: 1.60, dy: -0.45, phase: 1.6, freq: 2),
      (dx: -1.35, dy: 0.55, phase: 3.1, freq: 1),
      (dx: 1.40, dy: 0.75, phase: 4.5, freq: 2),
      (dx: 0.15, dy: -1.45, phase: 5.6, freq: 1),
      (dx: -0.75, dy: -1.25, phase: 2.4, freq: 2),
    ];
    for (final sp in sparks) {
      final tw = math.max(0.0, math.sin(2 * math.pi * t * sp.freq + sp.phase));
      if (tw < 0.05) continue;
      final sc = c + Offset(sp.dx, sp.dy) * s;
      final r = s * 0.11 * tw;
      final color = sp.phase.floor().isEven ? UIColorToken.blue : UIColorToken.violet;
      final p = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = s * 0.035
        ..color = color.withValues(alpha: tw * 0.85);
      canvas.drawLine(sc.translate(-r, 0), sc.translate(r, 0), p);
      canvas.drawLine(sc.translate(0, -r), sc.translate(0, r), p);
      canvas.drawCircle(
        sc,
        r * 0.35,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
          ..color = UIColorToken.white.withValues(alpha: tw * 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(_CoinAuraPainter old) => old.t != t || old.dark != dark || old.coinSize != coinSize;
}
