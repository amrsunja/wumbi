import 'dart:ui';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/failures/failures.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/utils/enums/app_theme_type.dart';
import '../../../core/utils/typedefs.dart';
import 'datasources/settings_local_datasource.dart';
import 'models/app_settings.dart';

final settingsRepoProvider = Provider(
  (ref) => SettingsRepo(localDatasource: ref.read(settingsLocalDataProvider)),
);

class SettingsRepo {
  SettingsRepo({required this.localDatasource});

  final SettingsLocalDatasource localDatasource;

  Future<SuccessOrError<void>> initDatabase() =>
      Failure.exceptionsCatcher(localDatasource.initDatabase);

  Future<SuccessOrError<AppSettingsModel>> resetAllData() =>
      Failure.exceptionsCatcher(() async {
        await localDatasource.resetAllData();
        return localDatasource.getLocalSettings();
      });

  Future<SuccessOrError<AppSettingsModel>> getLocalSettings() =>
      Failure.exceptionsCatcher(localDatasource.getLocalSettings);

  Future<SuccessOrError<AppSettingsModel>> changeAppLanguage(Locale locale) =>
      Failure.exceptionsCatcher(() async {
        await localDatasource.changeAppLanguage(locale);
        return localDatasource.getLocalSettings();
      });

  Future<SuccessOrError<AppSettingsModel>> changeAppThemeMode(AppThemeType type) =>
      Failure.exceptionsCatcher(() async {
        await localDatasource.changeAppThemeMode(type);
        return localDatasource.getLocalSettings();
      });

  Future<SuccessOrError<AppSettingsModel>> changeBaseCurrency(CurrencyType currency) =>
      Failure.exceptionsCatcher(() async {
        await localDatasource.changeBaseCurrency(currency);
        return localDatasource.getLocalSettings();
      });

  Future<SuccessOrError<AppSettingsModel>> changeNotifications(bool enabled) =>
      Failure.exceptionsCatcher(() async {
        await localDatasource.changeNotifications(enabled);
        return localDatasource.getLocalSettings();
      });

  Future<SuccessOrError<AppSettingsModel>> onboardingCompleted() =>
      Failure.exceptionsCatcher(() async {
        await localDatasource.onboardingCompleted();
        return localDatasource.getLocalSettings();
      });
}
