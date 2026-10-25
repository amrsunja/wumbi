import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'ui_wumbi.dart';

/// Mascot peeking in from the right edge; slides in 400 ms (easeOutBack) once.
class UIWumbiLooksFromRight extends StatelessWidget {
  const UIWumbiLooksFromRight({super.key, this.height = 56, this.animate = true});

  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final image = UIWumbi(WumbiMood.peekRight, height: height);
    if (!animate) return image;
    return image
        .animate()
        .slideX(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 250.ms);
  }
}
