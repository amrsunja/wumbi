#!/usr/bin/env python3
"""Minimal stand-in for `flutter gen-l10n` (en only). Run from repo root.
The real generator overwrites these files on `flutter pub get` / build."""
import json, re, pathlib

root = pathlib.Path(__file__).resolve().parent.parent
arb = json.loads((root / 'lib/src/core/locale/arbs/app_en.arb').read_text())
out_dir = root / 'lib/src/core/locale/gen'

entries = [(k, v) for k, v in arb.items() if not k.startswith('@')]

def placeholders(key):
    meta = arb.get('@' + key, {})
    return meta.get('placeholders', {})

def dart_str(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"

abstract = []
impl = []
for key, value in entries:
    ph = placeholders(key)
    if not ph:
        abstract.append(f"  /// In en, this message translates to:\n  /// **{dart_str(value)}**\n  String get {key};\n")
        impl.append(f"  @override\n  String get {key} => {dart_str(value)};\n")
        continue
    params = ', '.join(f"{p['type']} {name}" for name, p in ph.items())
    abstract.append(f"  /// In en, this message translates to:\n  /// **{dart_str(value)}**\n  String {key}({params});\n")
    m = re.match(r'^\{(\w+), plural, (.*)\}$', value)
    if m:
        var, body = m.group(1), m.group(2)
        cases = dict(re.findall(r'(=\d+|other)\{([^{}]*(?:\{\w+\}[^{}]*)*)\}', body))
        def conv(s):
            return dart_str(s).replace('{' + var + '}', '$' + var)
        args = []
        if '=0' in cases: args.append(f"zero: {conv(cases['=0'])}")
        if '=1' in cases: args.append(f"one: {conv(cases['=1'])}")
        args.append(f"other: {conv(cases['other'])}")
        impl.append(
            f"  @override\n  String {key}({params}) {{\n"
            f"    String _temp0 = intl.Intl.pluralLogic(\n      {var},\n      locale: localeName,\n      "
            + ',\n      '.join(args) + ",\n    );\n    return '$_temp0';\n  }\n")
    else:
        body = dart_str(value)
        for name in ph:
            body = body.replace('{' + name + '}', '$' + name)
        impl.append(f"  @override\n  String {key}({params}) {{\n    return {body};\n  }}\n")

header = '''import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

'''
footer = '''}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
'''
(out_dir / 'app_localizations.dart').write_text(header + '\n'.join(abstract) + footer)

en_header = '''// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

'''
(out_dir / 'app_localizations_en.dart').write_text(en_header + '\n'.join(impl) + '}\n')
print(f'generated {len(entries)} messages')
