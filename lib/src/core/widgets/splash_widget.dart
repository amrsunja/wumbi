import 'package:fiin/src/core/design_system/app_ui.dart';
import 'package:fiin/src/core/utils/typedefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: UIColorToken.white,
      body: Center(
        child: SizedBox(
          height: screen.width * 0.7,
          child: Image.asset(AppAssets.images.splash.path),
        ).animate()
          ..scale(
            curve: Curves.fastOutSlowIn,
          )
      ),
    );
  }
}


