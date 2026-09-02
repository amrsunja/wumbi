import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Wallet colour dot. With [animated] the glow "breathes" (blur + alpha on a
/// 2.6 s loop); [phase] (0..1) desynchronises neighbouring dots.
class UiCircleColorBadge extends StatefulWidget {
  const UiCircleColorBadge({
    super.key,
    required this.color,
    this.size = 10,
    this.animated = false,
    this.phase = 0,
  });

  final Color color;
  final double size;
  final bool animated;
  final double phase;

  @override
  State<UiCircleColorBadge> createState() => _UiCircleColorBadgeState();
}

class _UiCircleColorBadgeState extends State<UiCircleColorBadge> with SingleTickerProviderStateMixin {
  // Created eagerly (never lazily): Hero flights mount and dispose throw-away
  // copies of this widget, and a `late` controller first touched in dispose()
  // would look up TickerMode on a deactivated element.
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animated) _start();
  }

  void _start() {
    _controller ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
      value: widget.phase.clamp(0.0, 1.0),
    );
    if (!_controller!.isAnimating) _controller!.repeat();
  }

  @override
  void didUpdateWidget(covariant UiCircleColorBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animated) {
      _start();
    } else {
      _controller?.stop();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (!widget.animated || controller == null) return _dot(glow: 0.5, blur: widget.size, ring: 0);

    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        // 0 → 1 → 0 sine breathing.
        final t = (1 - math.cos(controller.value * 2 * math.pi)) / 2;
        return _dot(
          glow: 0.35 + 0.45 * t,
          blur: widget.size * (0.9 + 1.4 * t),
          ring: widget.size * 0.9 * t,
        );
      },
    );
  }

  Widget _dot({required double glow, required double blur, required double ring}) {
    final color = widget.color;
    // Layout stays [size]×[size]; the glow paints outside the bounds.
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(blurRadius: blur, color: color.withValues(alpha: glow)),
          if (ring > 0) BoxShadow(blurRadius: blur * 1.6, spreadRadius: ring, color: color.withValues(alpha: 0.10)),
        ],
      ),
    );
  }
}
