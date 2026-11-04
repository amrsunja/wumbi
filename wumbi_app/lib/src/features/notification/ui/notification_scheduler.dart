import 'dart:async';

import '../../../core/locale/l10n.dart';
import '../../../core/utils/debug_print.dart';
import '../../settings/data/models/app_settings.dart';
import '../data/notification_gateway.dart';
import '../data/notification_permission.dart';
import '../data/notification_snapshot_source.dart';
import '../domain/notification_pacer.dart';
import '../domain/notification_payload.dart';
import '../domain/notification_planner.dart';
import 'notification_copy.dart';

/// snapshot → planner → pacer → words → OS. Rebuilds the whole plan every
/// time (cancel pending + schedule ≤ 40): cheap, and the plan can never drift
/// from the data, the language or the switches.
///
/// Triggers (see `notificationSchedulerProvider`): the app going to the
/// background (immediately), any DB write (debounced), and a change of
/// language, base currency or notification settings.
class NotificationScheduler {
  NotificationScheduler({
    required this.gateway,
    required this.permission,
    required this.source,
    required this.settings,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final NotificationGateway gateway;
  final NotificationPermission permission;
  final NotificationSnapshotSource source;
  final AppSettingsModel? Function() settings;
  final DateTime Function() _clock;

  static const Duration debounce = Duration(seconds: 3);

  Timer? _timer;
  Future<void>? _running;
  bool _dirty = false;

  /// Coalesces bursts (a save bumps the DB revision several times).
  void requestSync({Duration delay = debounce}) {
    _timer?.cancel();
    _timer = Timer(delay, syncNow);
  }

  /// Runs now; a request arriving mid-run triggers exactly one more run.
  Future<void> syncNow() async {
    _timer?.cancel();
    _timer = null;
    final current = _running;
    if (current != null) {
      _dirty = true;
      await current;
      return;
    }
    final run = _sync();
    _running = run;
    try {
      await run;
    } finally {
      _running = null;
    }
    if (_dirty) {
      _dirty = false;
      await syncNow();
    }
  }

  Future<void> _sync() async {
    try {
      final s = settings();
      if (s == null) return;
      if (!s.notificationsEnabled || await permission.status() != NotificationAccess.granted) {
        await gateway.cancelPending();
        return;
      }
      final now = _clock();
      final prefs = s.notificationPrefs;
      final snapshot = await source.load(now: now, base: s.baseCurrency, prefs: prefs);
      final plan = NotificationPacer.pace(
        NotificationPlanner.plan(snapshot, prefs),
        now: now,
        times: NotificationPlanner.timesFor(snapshot.recordTimes),
      );

      final l10n = lookupAppLocalizations(s.locale ?? L10n.defaultLocale);
      final channel = NotificationChannelText(
        name: l10n.notif_channel_name,
        description: l10n.notif_channel_description,
      );
      await gateway.cancelPending();
      for (final n in plan) {
        final text = NotificationCopy.of(l10n, n);
        await gateway.schedule(
          NotificationRequest(
            id: n.id,
            at: n.fireAt,
            title: text.title,
            body: text.body,
            mood: n.message.mood,
            payload: NotificationPayload.encode(n.message.action),
            threadId: n.message.kind.category.name,
          ),
          channel,
        );
      }
      debugPrint('Notifications: ${plan.length} scheduled');
    } catch (e) {
      debugPrint('Notifications sync failed: $e');
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
