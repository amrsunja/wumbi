import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';

/// Onboarding header: back button / "Skip" / hairline gradient progress.
///
/// Collapses to zero height (animated) when [visible] is false — hero pages
/// (welcome, wallet, congrats) own the whole screen.
class OnboardingAppBar extends StatelessWidget {
  const OnboardingAppBar({
    super.key,
    required this.visible,
    required this.progress,
    this.onBack,
    this.onSkip,
  });

  final bool visible;
  final double progress;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return AnimatedSize(
      duration: UIAnim.normal,
      curve: UIAnim.easeOut,
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        duration: UIAnim.fast,
        opacity: visible ? 1 : 0,
        child: !visible
            ? const SizedBox(width: double.infinity)
            : SizedBox(
                height: 58,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: onBack == null
                                ? null
                                : Center(
                                    child: UIIcon(
                                      UIIconToken.icons.arrows.arrowNarrowLeft,
                                      size: 24,
                                      onTap: onBack,
                                    ),
                                  ).animate().fadeIn(duration: UIAnim.fast),
                          ),
                          SizedBox(
                            height: 44,
                            child: onSkip == null
                                ? null
                                : UITap(
                                    onTap: onSkip,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Center(
                                        child: Text(
                                          l10n.common_skip,
                                          style: context.typo.inter.medium.copyWith(
                                            fontSize: 14,
                                            color: colors.secondContentColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ).animate().fadeIn(duration: UIAnim.fast),
                          ),
                        ],
                      ),
                    ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
                      child: UIProgressLine(value: progress),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
