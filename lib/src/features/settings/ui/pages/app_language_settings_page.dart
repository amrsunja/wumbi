import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/locale/l10n.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../state_management/settings_provider.dart';

/// Hidden until a second locale exists (spec 2).
@RoutePage()
class AppLanguageSettingsPage extends ConsumerWidget {
  const AppLanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(settingsProvider).data?.locale;

    return Scaffold(
      appBar: UIAppbar(title: l10n.settings_language, backTap: () => context.router.maybePop()),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding, vertical: 8),
        itemCount: L10n.all.length,
        separatorBuilder: (_, _) => const UIDivider(),
        itemBuilder: (context, index) {
          final locale = L10n.all[index];
          return UiListRow(
            title: lookupAppLocalizations(locale).appLanguage,
            subtitle: locale.languageCode.toUpperCase(),
            selected: (current ?? L10n.defaultLocale).languageCode == locale.languageCode,
            onTap: () => ref.read(settingsProvider.notifier).changeAppLanguage(locale),
          );
        },
      ),
    );
  }
}
