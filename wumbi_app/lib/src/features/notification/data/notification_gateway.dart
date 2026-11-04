import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/design_system/app_ui.dart';
import '../../../core/utils/debug_print.dart';
import 'notification_art.dart';

/// One notification as the OS needs it.
class NotificationRequest {
  const NotificationRequest({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.mood,
    required this.payload,
    required this.threadId,
  });

  final int id;

  /// Local wall-clock time.
  final DateTime at;
  final String title;
  final String body;
  final WumbiMood mood;
  final String payload;

  /// Groups related notifications in the iOS notification centre.
  final String threadId;
}

/// Localised channel strings (Android shows them in the system settings).
class NotificationChannelText {
  const NotificationChannelText({required this.name, required this.description});

  final String name;
  final String description;
}

/// The only place that talks to `flutter_local_notifications`.
///
/// Every notification is a one-shot at an absolute instant (local time
/// converted to UTC), so no IANA time zone lookup is needed: Dart's local
/// `DateTime` already resolves DST, and re-planning on every background
/// trip keeps the instants fresh.
class NotificationGateway {
  NotificationGateway({FlutterLocalNotificationsPlugin? plugin, NotificationArt? art})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _art = art ?? NotificationArt();

  static const String channelId = 'wumbi_reminders';

  /// Monochrome status-bar icon (`android/app/src/main/res/drawable-*`).
  static const String smallIcon = 'ic_stat_wumbi';

  final FlutterLocalNotificationsPlugin _plugin;
  final NotificationArt _art;
  bool _initialized = false;

  bool get _supported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// [onTap] receives the payload of a notification tapped while the app is
  /// alive (foreground or background). Taps that cold-start the app are
  /// read once with [takeLaunchPayload].
  Future<void> initialize({required void Function(String? payload) onTap}) async {
    if (_initialized || !_supported) return;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(smallIcon),
          // Asked at the right moment by the app, never on launch.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestSoundPermission: false,
            requestBadgePermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (r) => onTap(r.payload),
      );
      _initialized = true;
    } catch (e) {
      debugPrint('Notifications init failed: $e');
    }
  }

  /// Payload of the notification that launched the app, once.
  bool _launchTaken = false;
  Future<String?> takeLaunchPayload() async {
    if (_launchTaken || !_initialized) return null;
    _launchTaken = true;
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp != true) return null;
      return details?.notificationResponse?.payload;
    } catch (_) {
      return null;
    }
  }

  /// Pending ones only: what is already in the notification centre stays.
  Future<void> cancelPending() async {
    if (!_initialized) return;
    try {
      await _plugin.cancelAllPendingNotifications();
    } catch (_) {}
    if (Platform.isIOS) await _art.clearSingles();
  }

  Future<void> schedule(NotificationRequest r, NotificationChannelText channel) async {
    if (!_initialized) return;
    try {
      final android = Platform.isAndroid ? await _art.shared(r.mood) : null;
      final ios = Platform.isIOS ? await _art.single(r.mood, r.id) : null;
      await _plugin.zonedSchedule(
        id: r.id,
        title: r.title,
        body: r.body,
        payload: r.payload,
        scheduledDate: tz.TZDateTime.from(r.at, tz.UTC),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
            color: UIColorToken.blue,
            largeIcon: android == null ? null : FilePathAndroidBitmap(android),
            styleInformation: BigTextStyleInformation(r.body),
          ),
          iOS: DarwinNotificationDetails(
            threadIdentifier: r.threadId,
            attachments: ios == null ? null : [DarwinNotificationAttachment(ios)],
          ),
        ),
      );
    } catch (e) {
      debugPrint('Notification ${r.id} not scheduled: $e');
    }
  }
}
