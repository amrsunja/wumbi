import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// One-shot count from 0 when the amount first shows: [builder] gets the
/// count `progress` (0 → 1 along [curve]) and whether it is still
/// `counting`. Meanwhile the amount fades in, rises [rise] px and sharpens
/// out of a [blur] (all over the first 45 %). Shows the final amount straight
/// away when the OS asks to reduce motion, and under a [UiCountUpSkip].
class UiCountUp extends StatefulWidget {
  const UiCountUp({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOutExpo,
    this.rise = 10,
    this.blur = 8,
    this.once,
  });

  final Widget Function(double progress, bool counting) builder;
  final Duration duration;
  final Curve curve;
  final double rise;
  final double blur;

  /// When set, only the first [UiCountUp] mounted with this key (per app
  /// run) counts; later ones — e.g. the same row rebuilt by a tab switch —
  /// show the final amount.
  final Object? once;

  static final Set<Object> _played = {};

  @override
  State<UiCountUp> createState() => _UiCountUpState();
}

class _UiCountUpState extends State<UiCountUp> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _count = CurvedAnimation(parent: _controller, curve: widget.curve);
  late final Animation<double> _reveal = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.45, curve: Curves.easeOutCubic),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final once = widget.once;
    final replay = once != null && !UiCountUp._played.add(once);
    if (replay || MediaQuery.disableAnimationsOf(context) || UiCountUpSkip.applies(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isCompleted) return widget.builder(1, false);

        final counter = widget.builder(_count.value, true);
        final r = _reveal.value;
        final sigma = widget.blur * (1 - r);
        return Opacity(
          opacity: r,
          child: Transform.translate(
            offset: Offset(0, widget.rise * (1 - r)),
            child: sigma < 0.05
                ? counter
                : ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                    child: counter,
                  ),
          ),
        );
      },
    );
  }
}

/// Shows every [UiCountUp] below at its final amount. For fresh copies of
/// an already-shown amount: a hero shuttle, a dragged list row.
class UiCountUpSkip extends InheritedWidget {
  const UiCountUpSkip({super.key, required super.child});

  static bool applies(BuildContext context) => context.getInheritedWidgetOfExactType<UiCountUpSkip>() != null;

  @override
  bool updateShouldNotify(UiCountUpSkip oldWidget) => false;
}
