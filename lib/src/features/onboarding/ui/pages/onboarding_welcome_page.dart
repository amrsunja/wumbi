import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/typedefs.dart';
import '../widgets/onboarding_typography.dart';

/// Onboarding index 0 — fullscreen hero welcome. No header: the page owns
/// the whole screen. "Get started" advances the flow.
class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppAssets.images.fiinHello.path, height: 200)
                    .uiElasticScaleIn(begin: 0.7, duration: const Duration(milliseconds: 1100)),
                const UISpace.vert(40),
                Text(
                  l10n.onboarding_welcome_title,
                  textAlign: TextAlign.center,
                  style: OnboardingTypography.title(context.typo),
                ).uiFadeSlideIn(delay: UIAnim.stagger * 2),
                const UISpace.vert(14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.onboarding_welcome_subtitle,
                    textAlign: TextAlign.center,
                    style: OnboardingTypography.body(context.typo),
                  ),
                ).uiFadeSlideIn(delay: UIAnim.stagger * 3),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: UiPrimaryButton(
                label: l10n.onboarding_welcome_start,
                onTap: onStart,
              ).uiElasticScaleIn(delay: UIAnim.stagger * 4, begin: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
