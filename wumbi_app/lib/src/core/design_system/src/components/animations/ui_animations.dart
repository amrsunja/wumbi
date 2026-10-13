import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Shared timing & curve tokens so every animation in the app feels the same.
/// Tweak these in one place and the whole app's motion language follows.
abstract class UIAnim {
  const UIAnim._();

  // Durations -----------------------------------------------------------------
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration normal = Duration(milliseconds: 450);
  static const Duration slow = Duration(milliseconds: 650);
  static const Duration elastic = Duration(milliseconds: 900);

  /// Gap between consecutive items in a staggered reveal.
  static const Duration stagger = Duration(milliseconds: 90);

  /// PageView transitions inside a flow (onboarding).
  static const Duration page = Duration(milliseconds: 380);

  /// One row of a [UIStaggerScope] list cascade, and the gap between rows.
  /// Kept short: a tab switch must feel instant.
  static const Duration listItem = Duration(milliseconds: 340);
  static const Duration listStagger = Duration(milliseconds: 40);

  // Curves --------------------------------------------------------------------
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve springy = Curves.elasticOut;
  static const Curve pageCurve = Curves.fastOutSlowIn;

  // Slide offsets (fractions of the widget's own size) ------------------------
  static const double slideOffset = 0.18;
}

/// Direction a [UIFadeSlideIn] / [UIStaggered] item slides in from.
enum UISlideFrom { bottom, top, left, right, none }

/// A single-widget entrance: fades in while sliding from [from].
class UIFadeSlideIn extends StatelessWidget {
  const UIFadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = UIAnim.normal,
    this.curve = UIAnim.easeOut,
    this.from = UISlideFrom.bottom,
    this.offset = UIAnim.slideOffset,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final UISlideFrom from;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final anim = child.animate().fadeIn(delay: delay, duration: duration, curve: curve);
    return switch (from) {
      UISlideFrom.bottom => anim.slideY(begin: offset, end: 0, delay: delay, duration: duration, curve: curve),
      UISlideFrom.top => anim.slideY(begin: -offset, end: 0, delay: delay, duration: duration, curve: curve),
      UISlideFrom.left => anim.slideX(begin: -offset, end: 0, delay: delay, duration: duration, curve: curve),
      UISlideFrom.right => anim.slideX(begin: offset, end: 0, delay: delay, duration: duration, curve: curve),
      UISlideFrom.none => anim,
    };
  }
}

/// An attention-grabbing entrance: the child pops in with an elastic
/// (spring) scale while fading. For hero elements and primary CTAs.
class UIElasticScaleIn extends StatelessWidget {
  const UIElasticScaleIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = UIAnim.elastic,
    this.begin = 0.5,
    this.fade = true,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double begin;
  final bool fade;

  @override
  Widget build(BuildContext context) {
    var anim = child.animate().scaleXY(
          begin: begin,
          end: 1,
          delay: delay,
          duration: duration,
          curve: UIAnim.springy,
        );
    if (fade) anim = anim.fadeIn(delay: delay, duration: UIAnim.fast);
    return anim;
  }
}

/// Wraps a list of children so each one reveals after the previous, producing
/// a smooth cascade. Drop-in for `Column(children: ...)` / `Row(...)`.
class UIStaggered extends StatelessWidget {
  const UIStaggered._({
    super.key,
    required this.children,
    required this.axis,
    this.interval = UIAnim.stagger,
    this.duration = UIAnim.normal,
    this.initialDelay = Duration.zero,
    this.curve = UIAnim.easeOut,
    this.from = UISlideFrom.bottom,
    this.offset = UIAnim.slideOffset,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  });

  const UIStaggered.column({
    Key? key,
    required List<Widget> children,
    Duration interval = UIAnim.stagger,
    Duration duration = UIAnim.normal,
    Duration initialDelay = Duration.zero,
    Curve curve = UIAnim.easeOut,
    UISlideFrom from = UISlideFrom.bottom,
    double offset = UIAnim.slideOffset,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.min,
  }) : this._(
          key: key,
          children: children,
          axis: Axis.vertical,
          interval: interval,
          duration: duration,
          initialDelay: initialDelay,
          curve: curve,
          from: from,
          offset: offset,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
        );

  const UIStaggered.row({
    Key? key,
    required List<Widget> children,
    Duration interval = UIAnim.stagger,
    Duration duration = UIAnim.normal,
    Duration initialDelay = Duration.zero,
    Curve curve = UIAnim.easeOut,
    UISlideFrom from = UISlideFrom.right,
    double offset = UIAnim.slideOffset,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.min,
  }) : this._(
          key: key,
          children: children,
          axis: Axis.horizontal,
          interval: interval,
          duration: duration,
          initialDelay: initialDelay,
          curve: curve,
          from: from,
          offset: offset,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
        );

  final List<Widget> children;
  final Axis axis;
  final Duration interval;
  final Duration duration;
  final Duration initialDelay;
  final Curve curve;
  final UISlideFrom from;
  final double offset;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  List<Widget> _animatedChildren() {
    final animated = children.animate(interval: interval, delay: initialDelay).fadeIn(duration: duration, curve: curve);
    return switch (from) {
      UISlideFrom.bottom => animated.slideY(begin: offset, end: 0, duration: duration, curve: curve),
      UISlideFrom.top => animated.slideY(begin: -offset, end: 0, duration: duration, curve: curve),
      UISlideFrom.left => animated.slideX(begin: -offset, end: 0, duration: duration, curve: curve),
      UISlideFrom.right => animated.slideX(begin: offset, end: 0, duration: duration, curve: curve),
      UISlideFrom.none => animated,
    };
  }

  @override
  Widget build(BuildContext context) {
    final kids = _animatedChildren();
    return axis == Axis.vertical
        ? Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: kids,
          )
        : Row(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: kids,
          );
  }
}

/// A subtle, looping pulse ring behind a circular child.
class UIPulse extends StatelessWidget {
  const UIPulse({
    super.key,
    required this.child,
    required this.color,
    this.period = const Duration(milliseconds: 2800),
    this.maxScale = 1.6,
  });

  final Widget child;
  final Color color;
  final Duration period;
  final double maxScale;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.35)),
          )
              .animate(onPlay: (c) => c.repeat())
              .scaleXY(begin: 0.5, end: maxScale, duration: period, curve: Curves.easeOut)
              .fadeOut(duration: period, curve: Curves.easeOut),
        ),
        child,
      ],
    );
  }
}

/// Convenience extensions so any widget can opt into the shared motion
/// language without wrapping: `myWidget.uiFadeSlideIn(delay: 100.ms)`.
extension UIAnimX on Widget {
  Widget uiFadeSlideIn({
    Duration delay = Duration.zero,
    Duration duration = UIAnim.normal,
    Curve curve = UIAnim.easeOut,
    UISlideFrom from = UISlideFrom.bottom,
    double offset = UIAnim.slideOffset,
  }) =>
      UIFadeSlideIn(delay: delay, duration: duration, curve: curve, from: from, offset: offset, child: this);

  Widget uiElasticScaleIn({
    Duration delay = Duration.zero,
    Duration duration = UIAnim.elastic,
    double begin = 0.5,
    bool fade = true,
  }) =>
      UIElasticScaleIn(delay: delay, duration: duration, begin: begin, fade: fade, child: this);
}

/// One-shot cascade for a (lazily built) list: every [UIStaggerItem] below
/// fades in and rises [UIStaggerItem.offset] px, [interval] after the
/// previous one. Only the first [maxStaggered] rows are delayed (the rest are
/// off-screen anyway), so the whole reveal stays under
/// `itemDuration + interval × maxStaggered`. Rows built after the cascade
/// (scrolled into view, inserted later) simply show. Give the scope a new key
/// to replay it.
class UIStaggerScope extends StatefulWidget {
  const UIStaggerScope({
    super.key,
    required this.child,
    this.itemDuration = UIAnim.listItem,
    this.interval = UIAnim.listStagger,
    this.maxStaggered = 8,
  });

  final Widget child;
  final Duration itemDuration;
  final Duration interval;
  final int maxStaggered;

  @override
  State<UIStaggerScope> createState() => _UIStaggerScopeState();
}

class _UIStaggerScopeState extends State<UIStaggerScope> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.itemDuration + widget.interval * widget.maxStaggered,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _UIStaggerData(
        controller: _controller,
        itemDuration: widget.itemDuration,
        interval: widget.interval,
        maxStaggered: widget.maxStaggered,
        child: widget.child,
      );
}

class _UIStaggerData extends InheritedWidget {
  const _UIStaggerData({
    required this.controller,
    required this.itemDuration,
    required this.interval,
    required this.maxStaggered,
    required super.child,
  });

  final AnimationController controller;
  final Duration itemDuration;
  final Duration interval;
  final int maxStaggered;

  /// Row [index]'s slice of the shared controller.
  Animation<double> slice(int index) {
    final total = controller.duration!.inMicroseconds;
    final start = (interval * index.clamp(0, maxStaggered)).inMicroseconds / total;
    final end = (start + itemDuration.inMicroseconds / total).clamp(0.0, 1.0);
    return controller.drive(CurveTween(curve: Interval(start, end, curve: UIAnim.easeOut)));
  }

  @override
  bool updateShouldNotify(_UIStaggerData old) => controller != old.controller;
}

/// A row of a [UIStaggerScope] cascade; [index] is its position in the list.
/// Outside a scope (e.g. a reorder drag proxy in the overlay) it is a no-op.
class UIStaggerItem extends StatelessWidget {
  const UIStaggerItem({super.key, required this.index, required this.child, this.offset = 14});

  final int index;
  final Widget child;

  /// Rise distance in logical px.
  final double offset;

  @override
  Widget build(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<_UIStaggerData>();
    if (scope == null) return child;
    // A completed controller yields 1 for every slice: same widget tree, no
    // state loss, nothing to animate.
    final t = scope.slice(index);
    return FadeTransition(
      opacity: t,
      child: AnimatedBuilder(
        animation: t,
        builder: (context, child) => Transform.translate(offset: Offset(0, (1 - t.value) * offset), child: child),
        child: child,
      ),
    );
  }
}

/// "Smoke" edges for a vertical scrollable: content dissolves under the top
/// (and bottom) edge instead of being cut by pinned chrome. Each fade grows
/// with how far the list can still scroll that way, so a list at rest is
/// never faded.
class UIScrollEdgeFade extends StatefulWidget {
  const UIScrollEdgeFade({super.key, required this.child, this.top = 32, this.bottom = 32});

  /// Wraps a scrollable (it listens to its depth-0 notifications).
  final Widget child;
  final double top;
  final double bottom;

  @override
  State<UIScrollEdgeFade> createState() => _UIScrollEdgeFadeState();
}

class _UIScrollEdgeFadeState extends State<UIScrollEdgeFade> {
  final _fade = ValueNotifier<(double, double)>((0, 0));

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  bool _onNotification(Notification n) {
    final ScrollMetrics m;
    if (n is ScrollNotification && n.depth == 0) {
      m = n.metrics;
    } else if (n is ScrollMetricsNotification && n.depth == 0) {
      m = n.metrics;
    } else {
      return false;
    }
    if (m.axis != Axis.vertical || !m.hasContentDimensions) return false;
    _fade.value = (
      (m.pixels - m.minScrollExtent).clamp(0.0, widget.top),
      (m.maxScrollExtent - m.pixels).clamp(0.0, widget.bottom),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<Notification>(
      onNotification: _onNotification,
      child: ValueListenableBuilder<(double, double)>(
        valueListenable: _fade,
        child: widget.child,
        builder: (context, fade, child) => ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) {
            final h = rect.height <= 0 ? 1.0 : rect.height;
            final top = (fade.$1 / h).clamp(0.0, 0.5);
            final bottom = (1 - fade.$2 / h).clamp(0.5, 1.0);
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: const [Color(0x00000000), Color(0xFF000000), Color(0xFF000000), Color(0x00000000)],
              stops: [0, top, bottom, 1],
            ).createShader(rect);
          },
          child: child,
        ),
      ),
    );
  }
}
