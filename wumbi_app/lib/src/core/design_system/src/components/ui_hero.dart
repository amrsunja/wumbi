import 'package:flutter/material.dart';

/// [Hero] whose in-flight shuttle is the destination widget laid out at its
/// own (destination) size and scaled into the animated rect with a
/// [FittedBox]. Plain [Hero] lays the shuttle out at the *flying* rect, which
/// makes multi-line / flex content overflow while the rect is still small.
class UiHero extends StatelessWidget {
  const UiHero({
    super.key,
    required this.tag,
    required this.child,
    this.alignment = Alignment.center,
    this.pushedShuttle = false,
  });

  final Object tag;
  final Widget child;

  /// Where the scaled content sits inside the flying rect.
  final Alignment alignment;

  /// Fly the pushed page's widget both ways (default: the destination's).
  /// For pairs whose shapes differ — a bar growing into a ring shrinks back
  /// as the ring instead of snapping into a flying bar. Set on both sides.
  final bool pushedShuttle;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (flightContext, animation, direction, fromContext, toContext) {
        final source = pushedShuttle && direction == HeroFlightDirection.pop ? fromContext : toContext;
        final hero = source.widget as Hero;
        final box = source.findRenderObject() as RenderBox?;
        Widget shuttle = hero.child;
        if (box != null && box.hasSize) {
          shuttle = SizedBox.fromSize(size: box.size, child: shuttle);
        }
        return FittedBox(fit: BoxFit.contain, alignment: alignment, clipBehavior: Clip.hardEdge, child: shuttle);
      },
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}
