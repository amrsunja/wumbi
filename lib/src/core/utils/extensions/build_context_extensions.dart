import 'package:flutter/widgets.dart';

import '../../design_system/app_ui.dart';
import '../../locale/l10n.dart';

extension DarkMode on BuildContext {
  /// Is the platform in dark mode?
  bool get isDarkMode =>
      (MediaQuery.maybePlatformBrightnessOf(this) ??
          WidgetsBinding.instance.platformDispatcher.platformBrightness) ==
      Brightness.dark;
}

extension L10nContext on BuildContext {
  AppLocale get l10n => AppLocalizations.of(this);
}

extension ThemeContext on BuildContext {
  AppThemeData get appTheme => AppTheme.of(this);
  UIColorToken get colors => AppTheme.of(this).colors;
  UITypographyToken get typo => AppTheme.of(this).typo;
}
