import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/typedefs.dart';
import '../widgets/onboarding_typography.dart';

/// Onboarding index 6 — "Create your first Wallet".
///
/// Left-aligned hero title with the accent word in blue, the mascot peeking
/// in from the right edge, "+ New Wallet" (opens the wallet form modal) and a
/// quiet "Skip" pinned to the bottom.
class OnboardingWalletPage extends StatelessWidget {
  const OnboardingWalletPage({
    super.key,
    required this.onCreate,
    required this.onSkip,
  });

  final VoidCallback onCreate;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final screen = MediaQuery.sizeOf(context);
    final mascotHeight = (screen.height * 0.26).clamp(160.0, 260.0).toDouble();

    return Stack(
      children: [
        // Mascot peeking in from the right edge, slightly below the middle.
        Positioned(
          right: 0,
          top: screen.height * 0.40,
          child: Image.asset(AppAssets.images.fiinLookRight.path, height: mascotHeight)
              // Idle: a slow, subtle bob so the character feels alive.
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -6, duration: 1800.ms, curve: Curves.easeInOut)
              // Entrance: peeks in from the edge once.
              .animate(delay: (UIAnim.stagger * 3).inMilliseconds.ms)
              .slideX(begin: 1, end: 0, duration: UIAnim.slow, curve: Curves.easeOutBack)
              .fadeIn(duration: UIAnim.fast),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: screen.height * 0.24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: RichText(
                  text: TextSpan(
                    style: OnboardingTypography.hero(colors),
                    children: [
                      TextSpan(text: '${l10n.onboarding_wallet_hero_prefix}\n'),
                      TextSpan(
                        text: l10n.onboarding_wallet_hero_accent,
                        style: const TextStyle(color: UIColorToken.blue),
                      ),
                    ],
                  ),
                ),
              ).uiFadeSlideIn(from: UISlideFrom.left, offset: 0.08),

              const Spacer(),

              Center(
                child: UITap(
                  onTap: onCreate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        UIIcon(UIIconToken.icons.general.plusCircle, color: UIColorToken.blue, size: 26),
                        Text(
                          l10n.dashboard_new_wallet,
                          style: UITextStyleToken.interBold.copyWith(
                            fontSize: 20,
                            letterSpacing: -0.4,
                            color: UIColorToken.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).uiElasticScaleIn(delay: UIAnim.stagger * 5, begin: 0.7),

              SizedBox(height: screen.height * 0.12),

              SafeArea(
                top: false,
                child: Center(
                  child: UITap(
                    onTap: onSkip,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      child: Text(
                        l10n.common_skip,
                        style: UITextStyleToken.interMedium.copyWith(
                          fontSize: 16,
                          color: colors.secondContentColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ).animate(delay: (UIAnim.stagger * 7).inMilliseconds.ms).fadeIn(duration: UIAnim.normal),
              const UISpace.vert(8),
            ],
          ),
        ),
      ],
    );
  }
}
