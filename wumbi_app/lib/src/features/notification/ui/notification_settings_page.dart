import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../domain/notification_kind.dart';
import 'notification_enable_flow.dart';
import 'notification_providers.dart';
import 'widgets/notification_sample_preview.dart';

/// Settings → Notifications: the master switch (asks the OS), a live
/// preview, and one switch per category.
@RoutePage()
class NotificationSettingsPage extends HookConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final enabled = ref.watch(notificationsEnabledProvider);
    final prefs = ref.watch(notificationPrefsProvider);
    final permitted = ref.watch(notificationPermissionProvider).value ?? true;
    final controller = ref.read(notificationsControllerProvider);

    // Back from the system settings: the permission may have changed.
    useOnAppLifecycleStateChange((_, state) {
      if (state == AppLifecycleState.resumed) ref.invalidate(notificationPermissionProvider);
    });

    final blocked = enabled && !permitted;

    return Scaffold(
      appBar: UIAppbar(title: l10n.notif_settings_title, backTap: () => context.router.maybePop()),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 32),
          children: [
            const NotificationSamplePreview(),
            const UISpace.vert(16),
            UiGroupCard(
              children: [
                UiToggleRow(
                  title: l10n.notif_settings_allow,
                  description: enabled ? l10n.notif_settings_allow_on : l10n.notif_settings_allow_off,
                  value: enabled,
                  onChanged: (on) {
                    AppVibrations.selection();
                    if (on) {
                      NotificationEnableFlow.run(context, ref);
                    } else {
                      controller.disable();
                    }
                  },
                ),
              ],
            ),
            if (blocked) ...[
              const UISpace.vert(8),
              UiFormHint(
                text: l10n.notif_settings_blocked,
                icon: UIIconToken.icons.alertsFeedback.alertCircle,
                color: UIColorToken.neg500,
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: UiTextButton(
                  label: l10n.notif_settings_open_system,
                  fontSize: 15,
                  onTap: controller.openSystemSettings,
                ),
              ),
            ],
            UiSectionLabel(text: l10n.notif_settings_what, padding: const EdgeInsets.fromLTRB(4, 24, 4, 8)),
            AnimatedOpacity(
              duration: UIAnim.fast,
              opacity: enabled ? 1 : 0.4,
              child: IgnorePointer(
                ignoring: !enabled,
                child: UiGroupCard(
                  children: [
                    for (final c in NotificationCategory.values)
                      UiToggleRow(
                        title: _title(l10n, c),
                        description: _description(l10n, c),
                        value: prefs.allows(c),
                        onChanged: (on) {
                          AppVibrations.selection();
                          controller.setCategory(c, on);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _title(AppLocale l10n, NotificationCategory c) => switch (c) {
        NotificationCategory.payments => l10n.notif_cat_payments,
        NotificationCategory.debts => l10n.notif_cat_debts,
        NotificationCategory.habits => l10n.notif_cat_habits,
        NotificationCategory.recaps => l10n.notif_cat_recaps,
        NotificationCategory.morningBudget => l10n.notif_cat_morning,
      };

  static String _description(AppLocale l10n, NotificationCategory c) => switch (c) {
        NotificationCategory.payments => l10n.notif_cat_payments_desc,
        NotificationCategory.debts => l10n.notif_cat_debts_desc,
        NotificationCategory.habits => l10n.notif_cat_habits_desc,
        NotificationCategory.recaps => l10n.notif_cat_recaps_desc,
        NotificationCategory.morningBudget => l10n.notif_cat_morning_desc,
      };
}
