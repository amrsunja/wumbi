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
  });

  final Object tag;
  final Widget child;

  /// Where the scaled content sits inside the flying rect.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (flightContext, animation, direction, fromContext, toContext) {
        final toHero = toContext.widget as Hero;
        final toBox = toContext.findRenderObject() as RenderBox?;
        Widget shuttle = toHero.child;
        if (toBox != null && toBox.hasSize) {
          shuttle = SizedBox.fromSize(size: toBox.size, child: shuttle);
        }
        return FittedBox(fit: BoxFit.contain, alignment: alignment, clipBehavior: Clip.hardEdge, child: shuttle);
      },
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}
