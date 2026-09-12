import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';

/// Text styles shared by every onboarding page (derived from the themed
/// typography token so colours follow light / dark automatically).
abstract class OnboardingTypography {
  static TextStyle title(UITypographyToken typo) => typo.inter.bold.copyWith(
        fontSize: 30,
        height: 1.15,
        letterSpacing: -0.6,
      );

  /// Big left-aligned hero title (wallet page).
  static TextStyle hero(UITypographyToken typo) => typo.inter.bold.copyWith(
        fontSize: 36,
        height: 1.12,
        letterSpacing: -0.8,
      );

  static TextStyle body(UITypographyToken typo) => typo.inter.paragraph.copyWith(fontSize: 16);
}
