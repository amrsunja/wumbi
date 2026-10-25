import 'package:flutter/material.dart';
import 'package:wumbi/src/core/design_system/app_ui.dart';

import 'wumbi_logo_draw.dart';

/// Splash surface: the logo drawing itself in on the app background.
///
/// Theme-aware: Carrara + dark ink (light), #120F1B + Carrara ink (dark).
/// The theme first follows the OS and switches to the saved one once
/// settings load (mid-draw, on [SplashPage]); background and ink cross-fade
/// then, while the draw-in keeps running.
class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: UIAnim.normal,
        curve: UIAnim.easeOut,
        color: AppTheme.of(context).colors.bgColor,
        alignment: Alignment.center,
        child: SizedBox(
          width: screen.width * 0.64,
          child: const WumbiLogoDraw(),
        ),
      ),
    );
  }
}
