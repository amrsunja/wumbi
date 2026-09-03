import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/typedefs.dart';
import '../widgets/onboarding_confetti.dart';
import '../widgets/onboarding_typography.dart';

/// Onboarding index 7 — congrats: the mascot pops in holding the banknote,
/// confetti fires once, the CTA hands off to the dashboard.
class OnboardingFinalPage extends HookWidget {
  const OnboardingFinalPage({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final confettiKey = useMemoized(() => GlobalKey<OnboardingConfettiState>());
    final leaving = useState(false);

    useEffect(() {
      // Haptic lands together with the confetti burst.
      Future<void>.delayed(const Duration(milliseconds: 350), AppVibrations.medium);
      return null;
    }, const []);

    Future<void> done() async {
      if (leaving.value) return;
      leaving.value = true;
      AppVibrations.light();
      onDone();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppAssets.images.fiinTakeMoney.path, height: 210)
                        .uiElasticScaleIn(begin: 0.4, duration: const Duration(milliseconds: 1100)),
                    const UISpace.vert(40),
                    Text(
                      l10n.onboarding_final_title,
                      textAlign: TextAlign.center,
                      style: OnboardingTypography.title(context.typo),
                    ).uiFadeSlideIn(delay: UIAnim.stagger * 2),
                    const UISpace.vert(14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.onboarding_final_body,
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
                    label: l10n.onboarding_final_button,
                    loading: leaving.value,
                    onTap: done,
                  ).uiElasticScaleIn(delay: UIAnim.stagger * 5, begin: 0.85),
                ),
              ),
            ],
          ),
        ),

        // Confetti on top of everything; ignores pointers.
        Positioned.fill(child: OnboardingConfetti(key: confettiKey)),
      ],
    );
  }
}
