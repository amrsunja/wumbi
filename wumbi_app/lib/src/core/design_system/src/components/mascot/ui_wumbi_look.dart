import 'package:wumbi/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Front-facing mascot illustration. Used as a page decoration (wallet
/// details, top-right); drops in 400 ms (easeOutBack) once.
class UIWumbiLook extends StatelessWidget {
  const UIWumbiLook({super.key, this.height = 64, this.animate = true});

  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(Assets.images.wumbiLook.path, height: height);
    if (!animate) return image;
    return image
        .animate()
        .slideY(begin: -0.6, end: 0, duration: 400.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 250.ms);
  }
}
