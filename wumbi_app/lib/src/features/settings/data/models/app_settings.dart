import 'dart:ui';

import '../../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/utils/enums/app_theme_type.dart';
import '../../../../core/utils/typedefs.dart';

class AppSettingsModel {
  const AppSettingsModel({
    required this.locale,
    required this.themeMode,
    required this.showOnboarding,
    required this.baseCurrency,
    required this.notificationsEnabled,
    required this.showMascot,
    required this.lastRecurringRunAt,
  });

  final Locale? locale;
  final AppThemeType themeMode;
  final bool showOnboarding;

  /// Settings → Currency; drives the dashboard total.
  final CurrencyType baseCurrency;

  /// Stub toggle (D10) — persisted only.
  final bool notificationsEnabled;

  /// Settings → Preferences; hides the decorative mascot app-wide.
  final bool showMascot;

  /// Watermark for the recurring engine.
  final DateTime? lastRecurringRunAt;

  factory AppSettingsModel.fromJson(Json json) => AppSettingsModel(
        locale: json[SQLiteConfig.languageCodeKey] == null
            ? null
            : Locale(
                json[SQLiteConfig.languageCodeKey] as String,
                json[SQLiteConfig.countryCodeKey] as String?,
              ),
        themeMode: AppThemeType.fromJson(json[SQLiteConfig.themeModeKey] as String?),
        showOnboarding: json[SQLiteConfig.showOnboarding] == 1,
        baseCurrency: CurrencyType.fromCode(json[SQLiteConfig.baseCurrency] as String?),
        notificationsEnabled: json[SQLiteConfig.notificationsEnabled] == 1,
        // Missing column on a not-yet-migrated row reads as "show".
        showMascot: json[SQLiteConfig.showMascot] != 0,
        lastRecurringRunAt: json[SQLiteConfig.lastRecurringRunAt] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                json[SQLiteConfig.lastRecurringRunAt] as int,
                isUtc: true,
              ).toLocal(),
      );

  Json toJson() => {
        SQLiteConfig.languageCodeKey: locale?.languageCode,
        SQLiteConfig.countryCodeKey: locale?.countryCode,
        SQLiteConfig.themeModeKey: themeMode.name,
        SQLiteConfig.showOnboarding: showOnboarding ? 1 : 0,
        SQLiteConfig.baseCurrency: baseCurrency.code,
        SQLiteConfig.notificationsEnabled: notificationsEnabled ? 1 : 0,
        SQLiteConfig.showMascot: showMascot ? 1 : 0,
        SQLiteConfig.lastRecurringRunAt: lastRecurringRunAt?.toUtc().millisecondsSinceEpoch,
      };

  AppSettingsModel copyWith({
    Locale? locale,
    AppThemeType? themeMode,
    bool? showOnboarding,
    CurrencyType? baseCurrency,
    bool? notificationsEnabled,
    bool? showMascot,
    DateTime? lastRecurringRunAt,
  }) =>
      AppSettingsModel(
        locale: locale ?? this.locale,
        themeMode: themeMode ?? this.themeMode,
        showOnboarding: showOnboarding ?? this.showOnboarding,
        baseCurrency: baseCurrency ?? this.baseCurrency,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        showMascot: showMascot ?? this.showMascot,
        lastRecurringRunAt: lastRecurringRunAt ?? this.lastRecurringRunAt,
      );

  static AppSettingsModel get getInitSettings => const AppSettingsModel(
        locale: null,
        themeMode: AppThemeType.system,
        showOnboarding: true,
        baseCurrency: CurrencyType.usd,
        notificationsEnabled: false,
        showMascot: true,
        lastRecurringRunAt: null,
      );
}
