import 'package:flutter/material.dart';
import 'package:wumbi/src/core/design_system/app_ui.dart';

import 'wumbi_logo_draw.dart';

/// Static stand-in for [SplashPage] — same mark, same draw-in.
class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: UIColorToken.white,
      body: Center(
        child: SizedBox(
          width: screen.width * 0.64,
          child: const WumbiLogoDraw(),
        ),
      ),
    );
  }
}
