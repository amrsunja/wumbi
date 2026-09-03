import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../widgets/onboarding_typography.dart';

/// Parametrized benefit / feature screen (onboarding indexes 1–4).
///
/// Layout: illustration (top ~40% of height) → title → body → pinned
/// "Continue" CTA. Every screen shares the layout and the entrance choreography;
/// they differ only in content.
class OnboardingBenefitPage extends StatelessWidget {
  const OnboardingBenefitPage({
    super.key,
    required this.title,
    required this.body,
    required this.illustration,
    required this.onNext,
  });

  final String title;
  final String body;
  final Widget illustration;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final height = MediaQuery.sizeOf(context).height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  const UISpace.vert(12),
                  SizedBox(
                    height: height * 0.40,
                    width: double.infinity,
                    child: illustration,
                  ).uiFadeSlideIn(offset: 0.06),
                  const UISpace.vert(28),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: OnboardingTypography.title(colors),
                  ).uiFadeSlideIn(delay: UIAnim.stagger),
                  const UISpace.vert(14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      body,
                      textAlign: TextAlign.center,
                      style: OnboardingTypography.body(colors),
                    ),
                  ).uiFadeSlideIn(delay: UIAnim.stagger * 2),
                  const UISpace.vert(24),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: UiPrimaryButton(
                label: l10n.common_continue,
                onTap: onNext,
              ).uiElasticScaleIn(delay: UIAnim.stagger * 3, begin: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
