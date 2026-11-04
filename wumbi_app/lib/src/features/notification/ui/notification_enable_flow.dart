import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import 'notification_providers.dart';

/// "Turn notifications on", from any screen (Settings switch, the hamster's
/// ask): asks the OS, and when the user says no, explains once and offers
/// the app's page in the system settings. Returns true when they are on.
abstract class NotificationEnableFlow {
  static Future<bool> run(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(notificationsControllerProvider);
    final result = await controller.enable();
    if (result != NotificationEnableResult.refused || !context.mounted) {
      return result == NotificationEnableResult.enabled;
    }
    final l10n = context.l10n;
    final openSettings = await UIAlertDialog.confirm(
      context,
      title: l10n.notif_refused_title,
      message: l10n.notif_refused_body,
      confirmLabel: l10n.notif_settings_open_system,
      cancelLabel: l10n.notif_ask_later,
    );
    if (openSettings) await controller.openSystemSettings();
    return false;
  }
}
