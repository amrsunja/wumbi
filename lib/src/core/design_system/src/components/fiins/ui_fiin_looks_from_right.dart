import 'package:fiin/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Mascot peeking in from the right edge; slides in 400 ms (easeOutBack) once.
class UIFiinLooksFromRight extends StatelessWidget {
  const UIFiinLooksFromRight({super.key, this.height = 64, this.animate = true});

  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(Assets.images.fiinLookRight.path, height: height);
    if (!animate) return image;
    return image
        .animate()
        .slideX(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 250.ms);
  }
}
