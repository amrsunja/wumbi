import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'ui_wumbi.dart';

/// Front-facing corner mascot (45 px). Drops in 400 ms (easeOutBack) once;
/// later mood changes cross-fade inside [UIWumbi].
class UIWumbiLook extends StatelessWidget {
  const UIWumbiLook({super.key, this.height = 45, this.animate = true, this.mood = WumbiMood.idle});

  final double height;
  final bool animate;
  final WumbiMood mood;

  @override
  Widget build(BuildContext context) {
    final image = UIWumbi(mood, height: height);
    if (!animate) return image;
    return image
        .animate()
        .slideY(begin: -0.6, end: 0, duration: 400.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 250.ms);
  }
}
