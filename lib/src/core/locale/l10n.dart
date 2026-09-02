import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/settings/ui/state_management/settings_provider.dart';
import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

typedef AppLocale = AppLocalizations;

/// Localisation outside the widget tree (notifiers, events).
final l10nProvider = Provider<AppLocale>((ref) {
  final localSettings = ref.watch(settingsProvider.select((s) => s.data?.locale));
  return lookupAppLocalizations(localSettings ?? L10n.defaultLocale);
});

class L10n {
  static Locale get en => all[0];

  /// Only `en` ships in v1; the language page stays hidden until a second
  /// locale exists.
  static final all = [const Locale('en')];

  /// Kept for the RTL flip in [UIIcon]; Arabic is not shipped yet.
  static const Locale ar = Locale('ar');

  static Locale get defaultLocale {
    final appNativeLocale = ui.PlatformDispatcher.instance.locale;
    return all.firstWhereOrNull((value) => appNativeLocale.languageCode == value.languageCode) ?? en;
  }
}
