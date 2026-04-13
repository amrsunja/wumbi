import 'dart:ui';
import 'package:fiin/src/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:fiin/src/src/core/utils/enums/app_theme_type.dart';
import 'package:fiin/src/src/core/utils/typedefs.dart';

class AppSettingsModel {
	final Locale? locale;
	final AppThemeType themeMode;
  final bool showOnboarding;

	const AppSettingsModel({
		required this.locale,
		required this.themeMode,
		required this.showOnboarding,
	});

	factory AppSettingsModel.fromJson(Json json) => AppSettingsModel(
		locale: json[SQLiteConfig.languageCodeKey] == null ? null : Locale(
			json[SQLiteConfig.languageCodeKey],
			json[SQLiteConfig.countryCodeKey]
		),
		themeMode: AppThemeType.fromJson(json[SQLiteConfig.themeModeKey]),
    showOnboarding: json[SQLiteConfig.showOnboarding] == 1,
	);

	Json toJson() => {
		SQLiteConfig.languageCodeKey: locale?.languageCode,
		SQLiteConfig.countryCodeKey: locale?.countryCode,
		SQLiteConfig.themeModeKey: themeMode.name,
    SQLiteConfig.showOnboarding: showOnboarding,
	};

	static AppSettingsModel get getInitSettings => const AppSettingsModel(
		locale: null,
		themeMode: AppThemeType.system,
    showOnboarding: true
	);
}
