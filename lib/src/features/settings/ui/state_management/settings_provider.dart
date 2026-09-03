import 'dart:ui';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/money/currency_type.dart';
import '../../../../core/providers/data/db_revision_provider.dart';
import '../../../../core/providers/data/fx_provider.dart';
import '../../../../core/recurring/recurring_engine.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/enums/app_theme_type.dart';
import '../../../../core/utils/state_management/app_events.dart';
import '../../../../core/utils/state_management/single_events.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../wallet/data/wallet_repository.dart';
import '../../data/models/app_settings.dart';
import '../../data/settings_repo.dart';
import 'settings_state.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

/// Base currency for the dashboard total (USD until settings are loaded).
final baseCurrencyProvider = Provider<CurrencyType>(
  (ref) => ref.watch(settingsProvider.select((s) => s.data?.baseCurrency)) ?? CurrencyType.usd,
);

class SettingsNotifier extends Notifier<SettingsState> {
  static const _maxAutoRetries = 3;

  SettingsRepo get _repo => ref.read(settingsRepoProvider);
  AppEvents get _events => ref.read(appEventProvider);

  @override
  SettingsState build() => const SettingsState(isLoading: false, data: null);

  /// Startup sequence (spec 6.5). Called from Splash.
  Future<void> startUp() async {
    state = state.copyWith(isLoading: true, initFailed: false);

    // 1. Database — up to 3 automatic retries before surfacing the alert.
    var opened = false;
    for (var attempt = 0; attempt < _maxAutoRetries && !opened; attempt++) {
      final response = await _repo.initDatabase();
      opened = response.isSuccess();
      if (!opened) await Future<void>.delayed(const Duration(milliseconds: 600));
    }
    if (!opened) {
      state = state.copyWith(isLoading: false, initFailed: true);
      return;
    }

    // 2. Settings.
    final settings = await _repo.getLocalSettings();
    AppSettingsModel? data;
    settings.when((s) => data = s, (e) => _events.send(ShowErrorEvent(e)));
    if (data == null) {
      state = state.copyWith(isLoading: false, initFailed: true);
      return;
    }
    state = state.copyWith(data: data);

    // 3. Recurring catch-up — awaited, bounded.
    await ref.read(recurringEngineProvider).catchUp(DateTime.now());

    // 4. FX warm-up — not awaited.
    _warmUpRates(data!.baseCurrency);

    // 5. Route.
    state = state.copyWith(isLoading: false);
    _events.send(ReplaceAllRoutesEvent([
      if (!data!.showOnboarding) const OnboardingRoute() else const DashboardRoute(),
    ]));
  }

  void _warmUpRates(CurrencyType base) {
    Future(() async {
      final wallets = await ref.read(walletRepositoryProvider).listActive();
      wallets.when(
        (list) => ref.read(fxServiceProvider).warmUp(list.map((w) => w.currency).toSet(), base),
        (_) {},
      );
    });
  }

  Future<void> _apply(Future<SuccessOrError<AppSettingsModel>> Function() call) async {
    final response = await call();
    response.when(
      (success) => state = state.copyWith(data: success),
      (error) => _events.send(ShowErrorEvent(error)),
    );
  }

  Future<void> changeAppLanguage(Locale locale) => _apply(() => _repo.changeAppLanguage(locale));

  Future<void> changeAppThemeMode(AppThemeType type) => _apply(() => _repo.changeAppThemeMode(type));

  /// Dark Mode toggle → light / dark ([A7]).
  Future<void> setDarkMode(bool enabled) =>
      changeAppThemeMode(enabled ? AppThemeType.dark : AppThemeType.light);

  Future<void> changeBaseCurrency(CurrencyType currency) async {
    await _apply(() => _repo.changeBaseCurrency(currency));
    _warmUpRates(currency);
    ref.read(dbRevisionProvider.notifier).bump();
  }

  Future<void> changeNotifications(bool enabled) => _apply(() => _repo.changeNotifications(enabled));

  Future<void> onboardingCompleted() => _apply(_repo.onboardingCompleted);

  /// Reset All Data ([A6]): wipe DB + key, re-init, back to onboarding.
  Future<bool> resetAllData() async {
    final response = await _repo.resetAllData();
    var ok = false;
    response.when(
      (success) {
        ok = true;
        state = state.copyWith(data: success);
        ref.read(dbRevisionProvider.notifier).bump();
        _events.send(const ReplaceAllRoutesEvent([OnboardingRoute()]));
      },
      (error) => _events.send(ShowErrorEvent(error)),
    );
    return ok;
  }
}
