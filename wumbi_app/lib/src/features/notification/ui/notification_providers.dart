import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/locale/l10n.dart';
import '../../../core/providers/data/db_revision_provider.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../mascot/ui/mascot_actions.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../data/notification_gateway.dart';
import '../data/notification_permission.dart';
import '../data/notification_snapshot_source.dart';
import '../domain/notification_kind.dart';
import '../domain/notification_payload.dart';
import '../domain/notification_prefs.dart';
import 'notification_scheduler.dart';

final notificationGatewayProvider = Provider<NotificationGateway>((ref) => NotificationGateway());

final notificationPermissionServiceProvider = Provider<NotificationPermission>((ref) => const NotificationPermission());

/// Alive for the whole app once [NotificationsController.start] reads it.
final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  final scheduler = NotificationScheduler(
    gateway: ref.read(notificationGatewayProvider),
    permission: ref.read(notificationPermissionServiceProvider),
    source: ref.read(notificationSnapshotSourceProvider),
    settings: () => ref.read(settingsProvider).data,
  );
  // Any write may add / move / settle something worth a reminder.
  ref.listen(dbRevisionProvider, (_, _) => scheduler.requestSync());
  // A new language re-words every pending notification; the switches and
  // the base currency change what is planned.
  ref.listen(
    settingsProvider.select(
      (s) => (
        s.data?.locale,
        s.data?.notificationsEnabled,
        s.data?.notificationPrefs,
        s.data?.baseCurrency,
      ),
    ),
    (_, _) => scheduler.requestSync(delay: const Duration(milliseconds: 300)),
  );
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

/// Whether the OS lets Wumbi notify (re-read when Settings → Notifications
/// opens or the app comes back from the system settings).
final notificationPermissionProvider = FutureProvider.autoDispose<bool>(
  (ref) async => await ref.read(notificationPermissionServiceProvider).status() == NotificationAccess.granted,
);

/// Current per-category switches.
final notificationPrefsProvider = Provider<NotificationPrefs>(
  (ref) => ref.watch(settingsProvider.select((s) => s.data?.notificationPrefs)) ?? const NotificationPrefs(),
);

/// Master switch (settings row), off until loaded.
final notificationsEnabledProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider.select((s) => s.data?.notificationsEnabled)) ?? false,
);

final notificationsControllerProvider = Provider<NotificationsController>(NotificationsController.new);

/// How turning notifications on went.
enum NotificationEnableResult {
  /// Permission granted, master switch on.
  enabled,

  /// The user just said no in the system dialog — offer the settings.
  refused,

  /// Already refused for good: the system settings were opened directly
  /// (the OS would not show the dialog again). Coming back with the
  /// permission granted turns notifications on by itself.
  openedSettings,
}

/// Every user-facing notification action: startup, taps, permission, switches.
class NotificationsController {
  NotificationsController(this._ref);

  final Ref _ref;

  /// Set when the user was sent to the system settings to allow
  /// notifications; checked once on the next return to the app.
  bool _awaitingSettings = false;

  NotificationGateway get _gateway => _ref.read(notificationGatewayProvider);
  NotificationPermission get _permission => _ref.read(notificationPermissionServiceProvider);
  SettingsNotifier get _settings => _ref.read(settingsProvider.notifier);
  AppLocale get _l10n => _ref.read(l10nProvider);

  /// Splash, once the settings are loaded: taps start working, the plan is
  /// refreshed, and the page of the notification that cold-started the app
  /// (if any) is returned so it opens on top of the dashboard.
  Future<PageRouteInfo<Object?>?> start() async {
    await _gateway.initialize(onTap: _openFromTap);
    _ref.read(notificationSchedulerProvider).requestSync(delay: const Duration(seconds: 1));
    final action = NotificationPayload.decode(await _gateway.takeLaunchPayload());
    return action == null ? null : mascotActionRoute(action);
  }

  /// The app leaves the screen: plan with everything just written.
  void onBackground() => _ref.read(notificationSchedulerProvider).syncNow();

  /// The app is back. After a trip to the system settings, a granted
  /// permission switches notifications on — no second tap needed.
  Future<void> onForeground() async {
    _ref.invalidate(notificationPermissionProvider);
    if (!_awaitingSettings) return;
    _awaitingSettings = false;
    if (await _permission.status() != NotificationAccess.granted) return;
    if (!_ref.read(notificationsEnabledProvider)) await _settings.changeNotifications(true);
    _ref.read(appEventProvider).send(ShowSuccessMessageEvent(_l10n.notif_enabled_toast));
  }

  void _openFromTap(String? payload) {
    final action = NotificationPayload.decode(payload);
    if (action == null) return;
    final route = mascotActionRoute(action, primaryWalletId: _ref.read(primaryWalletProvider)?.id);
    if (route != null) _ref.read(appEventProvider).send(PushRouteInfoEvent(route));
  }

  /// Master switch on: granted → on; never asked → the system dialog;
  /// blocked → straight to the system settings. The UI handles [refused]
  /// (see `NotificationEnableFlow`).
  Future<NotificationEnableResult> enable() async {
    final before = await _permission.status();
    if (before == NotificationAccess.blocked) {
      await openSystemSettings();
      return NotificationEnableResult.openedSettings;
    }
    final access = before == NotificationAccess.granted ? before : await _permission.request();
    _ref.invalidate(notificationPermissionProvider);
    if (access != NotificationAccess.granted) return NotificationEnableResult.refused;
    await _settings.changeNotifications(true);
    return NotificationEnableResult.enabled;
  }

  Future<void> disable() => _settings.changeNotifications(false);

  Future<void> setCategory(NotificationCategory category, bool on) =>
      _settings.changeNotificationPrefs(_ref.read(notificationPrefsProvider).withCategory(category, on));

  /// The dashboard ask is shown once, whatever the answer.
  Future<void> markAsked() => _settings.changeNotificationPrefs(_ref.read(notificationPrefsProvider).asked(DateTime.now()));

  /// Opens the app's page in the system settings and remembers to check
  /// the permission when the user comes back.
  Future<void> openSystemSettings() async {
    _awaitingSettings = await _permission.openSettings();
  }
}
