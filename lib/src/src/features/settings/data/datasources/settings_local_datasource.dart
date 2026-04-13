import 'dart:ui';
import 'package:fiin/src/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:fiin/src/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:fiin/src/src/core/providers/local/sqlite_database_provider.dart';
import 'package:fiin/src/src/core/utils/enums/app_theme_type.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/app_settings.dart';


final settingsLocalDataProvider = Provider((ref) =>
	SettingsLocalDatasource(services: ref.read(sqliteDataBaseProvider))
);


class SettingsLocalDatasource {
	final SQLiteServices services;

	SettingsLocalDatasource({required this.services});

  Future<void> initDatabase() async {
    await services.initDatabase();
  }

  Future<void> saveLocalSettings(AppSettingsModel newSettings) async {
    throw UnimplementedError();
  }

  Future<AppSettingsModel> getLocalSettings() async {
    //throw UnimplementedError();
    final dbInstance = services.db;

    final result = await dbInstance.query(
      SQLiteConfig.settingsTableName,
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) {
      // Should never happen, but safety net
      return AppSettingsModel.getInitSettings;
    }

    final map = result.first;

    return AppSettingsModel.fromJson(map);
  }

  Future<void> changeAppLanguage(Locale locale) async {
    final dbInstance = services.db;

    await dbInstance.update(
      SQLiteConfig.settingsTableName,
      {
        SQLiteConfig.languageCodeKey: locale.languageCode,
        SQLiteConfig.countryCodeKey: locale.countryCode,
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

	Future<void> changeAppThemeMode(AppThemeType type) async {
    final dbInstance = services.db;

    await dbInstance.update(
      SQLiteConfig.settingsTableName,
      {
        SQLiteConfig.themeModeKey: type.name,
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

	Future<void> onboardingCompleted() async {
    final dbInstance = services.db;

    await dbInstance.update(
      SQLiteConfig.settingsTableName,
      {
        SQLiteConfig.showOnboarding: 0,
      },
      where: 'id = ?',
      whereArgs: [1],
    );
	}
}
