import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';

/// Text styles shared by every onboarding page.
abstract class OnboardingTypography {
  static TextStyle title(UIColorToken colors) => UITextStyleToken.interBold.copyWith(
        fontSize: 30,
        height: 1.15,
        letterSpacing: -0.6,
        color: colors.contentColor,
      );

  /// Big left-aligned hero title (wallet page).
  static TextStyle hero(UIColorToken colors) => UITextStyleToken.interBold.copyWith(
        fontSize: 36,
        height: 1.12,
        letterSpacing: -0.8,
        color: colors.contentColor,
      );

  static TextStyle body(UIColorToken colors) => UITextStyleToken.interRegular.copyWith(
        fontSize: 16,
        height: 1.5,
        color: colors.secondContentColor,
      );
}
