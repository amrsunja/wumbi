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

  /// Shipped locales, in the order shown on the language page. Arabic is
  /// laid out right-to-left by `MaterialApp` automatically.
  static const List<Locale> all = [
    Locale('en'),
    Locale('fr'),
    Locale('de'),
    Locale('nl'),
    Locale('tr'),
    Locale('ru'),
    Locale('ar'),
  ];

  static const Locale ar = Locale('ar');

  static bool isRtl(Locale locale) => locale.languageCode == ar.languageCode;

  /// Device locale when supported, else English.
  static Locale get defaultLocale {
    final appNativeLocale = ui.PlatformDispatcher.instance.locale;
    return all.firstWhereOrNull((value) => appNativeLocale.languageCode == value.languageCode) ?? en;
  }

  /// Native name of each language (shown on the language page next to the
  /// `appLanguage` string of that locale).
  static String nativeName(Locale locale) => switch (locale.languageCode) {
        'fr' => 'Français',
        'de' => 'Deutsch',
        'nl' => 'Nederlands',
        'tr' => 'Türkçe',
        'ru' => 'Русский',
        'ar' => 'العربية',
        _ => 'English',
      };
}
