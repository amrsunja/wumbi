import 'dart:ui';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../../core/local/database/sqlite/sqlite_services.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/providers/local/sqlite_database_provider.dart';
import '../../../../core/utils/enums/app_theme_type.dart';
import '../models/app_settings.dart';

final settingsLocalDataProvider = Provider(
  (ref) => SettingsLocalDatasource(services: ref.read(sqliteDataBaseProvider)),
);

class SettingsLocalDatasource {
  SettingsLocalDatasource({required this.services});

  final SQLiteServices services;

  Future<void> initDatabase() => services.initDatabase();

  Future<void> resetAllData() => services.resetAllData();

  Future<AppSettingsModel> getLocalSettings() async {
    final result = await services.db.query(
      SQLiteConfig.settingsTable,
      where: '${SQLiteConfig.id} = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (result.isEmpty) return AppSettingsModel.getInitSettings;
    return AppSettingsModel.fromJson(result.first);
  }

  Future<void> _update(Map<String, Object?> values) => services.db.update(
        SQLiteConfig.settingsTable,
        values,
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [1],
      );

  Future<void> changeAppLanguage(Locale locale) => _update({
        SQLiteConfig.languageCodeKey: locale.languageCode,
        SQLiteConfig.countryCodeKey: locale.countryCode,
      });

  Future<void> changeAppThemeMode(AppThemeType type) =>
      _update({SQLiteConfig.themeModeKey: type.name});

  Future<void> changeBaseCurrency(CurrencyType currency) =>
      _update({SQLiteConfig.baseCurrency: currency.code});

  Future<void> changeNotifications(bool enabled) =>
      _update({SQLiteConfig.notificationsEnabled: enabled ? 1 : 0});

  Future<void> onboardingCompleted() => _update({SQLiteConfig.showOnboarding: 0});

  Future<void> setLastRecurringRunAt(int epochMs) =>
      _update({SQLiteConfig.lastRecurringRunAt: epochMs});
}
