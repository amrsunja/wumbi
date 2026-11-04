import 'package:permission_handler/permission_handler.dart';

/// What the OS currently allows, in the terms the UI acts on.
enum NotificationAccess {
  /// Notifications can be shown (provisional / limited count as yes).
  granted,

  /// Never asked, or refused once on Android: the system dialog can still
  /// be shown.
  askable,

  /// Refused for good (iOS after one "Don't allow", Android after two) or
  /// restricted: only the app's page in the system settings can change it.
  blocked,
}

/// Notification permission through `permission_handler` (same approach as
/// the Nour app): one place for check, request and the jump to the system
/// settings. Never throws — an unsupported platform reads as [blocked].
class NotificationPermission {
  const NotificationPermission();

  Future<NotificationAccess> status() => _guard(() => Permission.notification.status);

  /// Shows the system dialog when the OS still allows it.
  Future<NotificationAccess> request() => _guard(() => Permission.notification.request());

  /// The app's page in the system settings (where notifications are turned
  /// back on after a refusal). True when the page could be opened.
  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (_) {
      return false;
    }
  }

  static Future<NotificationAccess> _guard(Future<PermissionStatus> Function() read) async {
    try {
      return of(await read());
    } catch (_) {
      return NotificationAccess.blocked;
    }
  }

  static NotificationAccess of(PermissionStatus s) {
    if (s.isGranted || s.isProvisional || s.isLimited) return NotificationAccess.granted;
    if (s.isPermanentlyDenied || s.isRestricted) return NotificationAccess.blocked;
    return NotificationAccess.askable;
  }
}
