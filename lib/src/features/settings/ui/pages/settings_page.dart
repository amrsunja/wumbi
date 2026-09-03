import 'package:auto_route/auto_route.dart';
import 'package:wumbi/src/core/utils/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/enums/app_theme_type.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/state_management/app_events.dart';
import '../../../../core/utils/state_management/single_events.dart';
import '../state_management/settings_provider.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

@RoutePage()
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider).data;
    final notifier = ref.read(settingsProvider.notifier);
    final packageInfo = ref.watch(packageInfoProvider).value;

    final isDark = switch (settings?.themeMode) {
      AppThemeType.dark => true,
      AppThemeType.light => false,
      _ => context.isDarkMode,
    };

    Future<void> resetAllData() async {
      final ok = await UIAlertDialog.confirm(
        context,
        title: l10n.settings_reset_title,
        message: l10n.settings_reset_message,
        confirmLabel: l10n.settings_reset_action,
        cancelLabel: l10n.common_cancel,
        destructive: true,
      );
      if (!ok) return;
      AppVibrations.heavy();
      final done = await notifier.resetAllData();
      if (done) ref.read(appEventProvider).send(ShowInfoMessageEvent(l10n.settings_reset_done));
    }

    return Scaffold(
      appBar: UIAppbar(title: l10n.settings_title, backTap: () => context.router.maybePop()),
      body: SafeArea(
        top: false,
        child: Padding(
        padding: EdgeInsets.symmetric(horizontal: kPageHorzPadding),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    UiSectionLabel(text: l10n.settings_preferences),
                    UiSettingsTile(
                      icon: UIIconToken.icons.alertsFeedback.bell01,
                      title: l10n.settings_notifications,
                      switchValue: settings?.notificationsEnabled ?? false,
                      onSwitchChanged: notifier.changeNotifications,
                    ),
                    UiSettingsTile(
                      icon: UIIconToken.icons.financeEcommerce.bankNote01,
                      title: l10n.settings_currency,
                      value: settings?.baseCurrency.code,
                      onTap: () => context.router.push(const BaseCurrencyRoute()),
                    ),
                    UiSettingsTile(
                      icon: UIIconToken.icons.weather.moon01,
                      title: l10n.settings_dark_mode,
                      switchValue: isDark,
                      onSwitchChanged: notifier.setDarkMode,
                    ),
                    UiSettingsTile(
                      icon: UIIconToken.icons.general.infoCircle,
                      title: l10n.about,
                      onTap: () => context.router.push(const AboutProjectRoute()),
                    ),
                    UiSectionLabel(text: l10n.settings_data_privacy),
                    UiSettingsTile(
                      icon: UIIconToken.icons.general.trash01,
                      title: l10n.settings_reset_all_data,
                      destructive: true,
                      onTap: resetAllData,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                child: Text(
                  packageInfo == null ? '' : l10n.settings_version(packageInfo.version, packageInfo.buildNumber),
                  style: context.typo.inter.caption.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
