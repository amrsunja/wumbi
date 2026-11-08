import 'dart:ui';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/money/currency_type.dart';
import '../../../../core/providers/data/db_revision_provider.dart';
import '../../../../core/providers/data/fx_provider.dart';
import '../../../../core/recurring/recurring_engine.dart';
import '../../../../core/upcoming/upcoming_poster.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/enums/app_theme_type.dart';
import '../../../../core/utils/state_management/app_events.dart';
import '../../../../core/utils/state_management/single_events.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../backup/data/backup_repository.dart';
import '../../../mascot/ui/mascot_providers.dart';
import '../../../notification/domain/notification_prefs.dart';
import '../../../notification/ui/notification_providers.dart';
import '../../../wallet/data/wallet_repository.dart';
import '../../data/models/app_settings.dart';
import '../../data/settings_repo.dart';
import 'settings_state.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

/// Base currency for the dashboard total (USD until settings are loaded).
final baseCurrencyProvider = Provider<CurrencyType>(
  (ref) => ref.watch(settingsProvider.select((s) => s.data?.baseCurrency)) ?? CurrencyType.usd,
);

/// Settings → Wumbi → "Wumbi talks": the talking hamster in the bottom-start
/// corner (`MascotPeek`) on / off (on until loaded). Empty-state and other
/// in-page hamsters ignore it.
final mascotTalksProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider.select((s) => s.data?.mascotTalks)) ?? true,
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

    // 3. Recurring catch-up — awaited, bounded. Then post upcoming rows whose
    //    date has arrived (also arms the in-app timer for the next one).
    await ref.read(recurringEngineProvider).catchUp(DateTime.now());
    await ref.read(upcomingPosterProvider).postDue();

    // 4. FX warm-up — not awaited.
    _warmUpRates(data!.baseCurrency);

    // 5. Notifications: taps, a fresh plan, and the page of the notification
    //    that launched the app (opened over the dashboard).
    final fromNotification = await ref.read(notificationsControllerProvider).start();

    // 6. Route.
    state = state.copyWith(isLoading: false);
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    _events.send(ReplaceAllRoutesEvent([
      if (data!.showOnboarding)
        const OnboardingRoute()
      else ...[
        const DashboardRoute(),
        if (fromNotification != null) fromNotification,
      ],
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

  Future<void> changeNotificationPrefs(NotificationPrefs prefs) =>
      _apply(() => _repo.changeNotificationPrefs(prefs));

  Future<void> changeMascotTalks(bool talks) => _apply(() => _repo.changeMascotTalks(talks));

  Future<void> onboardingCompleted() => _apply(_repo.onboardingCompleted);

  /// A backup was restored: every screen re-reads the new data (settings,
  /// balances, the hamster's memory), recurring rules catch up from the
  /// backup's last run, and the app opens on the dashboard.
  Future<void> reloadAfterRestore() async {
    final settings = await _repo.getLocalSettings();
    AppSettingsModel? data;
    settings.when((s) => data = s, (e) => _events.send(ShowErrorEvent(e)));
    if (data != null) state = state.copyWith(data: data);
    ref.read(dbRevisionProvider.notifier).bump();
    ref.invalidate(mascotMemoryProvider);

    await ref.read(recurringEngineProvider).catchUp(DateTime.now());
    await ref.read(upcomingPosterProvider).postDue();
    if (data != null) _warmUpRates(data!.baseCurrency);
    // Notifications re-plan by themselves: the scheduler listens to the
    // revision bump above (and reading it from here would be circular).

    _events.send(const ReplaceAllRoutesEvent([DashboardRoute()]));
  }

  /// Reset All Data ([A6]): wipe DB + key, re-init, back to onboarding.
  Future<bool> resetAllData() async {
    // "Everything erased" includes the backup undo point and its key.
    await ref.read(backupRepositoryProvider).deleteSafetySnapshot();
    final response = await _repo.resetAllData();
    var ok = false;
    response.when(
      (success) {
        ok = true;
        state = state.copyWith(data: success);
        ref.read(dbRevisionProvider.notifier).bump();
        // The file is gone: the companion's memory starts over too.
        ref.invalidate(mascotMemoryProvider);
        _events.send(const ReplaceAllRoutesEvent([OnboardingRoute()]));
      },
      (error) => _events.send(ShowErrorEvent(error)),
    );
    return ok;
  }
}
