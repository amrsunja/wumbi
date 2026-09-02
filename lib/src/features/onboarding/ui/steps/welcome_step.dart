import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/typedefs.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppAssets.images.fiinHello.path, height: 180)
              .animate()
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 400.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 300.ms),
          const UISpace.vert(32),
          Text(
            l10n.onboarding_welcome_title,
            style: UITextStyleToken.interSemiBold.copyWith(fontSize: 26, color: colors.contentColor),
          ),
          const UISpace.vert(12),
          Text(
            l10n.onboarding_welcome_subtitle,
            textAlign: TextAlign.center,
            style: UITextStyleToken.interRegular.copyWith(fontSize: 15, color: colors.secondContentColor, height: 1.5),
          ),
        ],
      ),
    );
  }
}
