#!/usr/bin/env python3
"""Stand-in for `flutter gen-l10n` covering every arb in lib/src/core/locale/arbs.

Run from the repo root: `python3 tool/gen_l10n.py`.
The real generator overwrites these files on `flutter pub get` / build; this
script only exists so the repo stays analyzable without a Flutter toolchain.
"""
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
ARB_DIR = ROOT / 'lib/src/core/locale/arbs'
OUT_DIR = ROOT / 'lib/src/core/locale/gen'
TEMPLATE = 'en'

# Locale order = the order of L10n.all in lib/src/core/locale/l10n.dart.
LOCALE_ORDER = ['en', 'fr', 'de', 'nl', 'tr', 'ru', 'ar']

PLURAL_CATEGORIES = ['zero', 'one', 'two', 'few', 'many', 'other']
EXPLICIT = {'=0': 'zero', '=1': 'one', '=2': 'two'}


def load(locale):
    return json.loads((ARB_DIR / f'app_{locale}.arb').read_text(encoding='utf-8'))


def locales():
    found = sorted(p.stem[4:] for p in ARB_DIR.glob('app_*.arb'))
    ordered = [l for l in LOCALE_ORDER if l in found]
    return ordered + [l for l in found if l not in ordered]


def class_suffix(locale):
    return ''.join(part.capitalize() for part in re.split(r'[_-]', locale))


def dart_str(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def interpolate(text, names):
    """Dart string literal with `{name}` turned into `${name}`.

    The braced form is required: several translations glue a placeholder
    directly to non-ASCII text, which a bare `$name` would not terminate.
    """
    body = dart_str(text)  # escapes any literal `$` in the message
    for name in sorted(names, key=len, reverse=True):
        body = body.replace('{' + name + '}', '${' + name + '}')
    return body


def split_branches(body):
    """`=0{...} one{...} other{...}` -> [(selector, text)] (brace aware)."""
    out = []
    i = 0
    while i < len(body):
        m = re.compile(r'\s*([=\w]+)\s*\{').match(body, i)
        if not m:
            break
        selector = m.group(1)
        depth = 1
        j = m.end()
        start = j
        while j < len(body) and depth:
            if body[j] == '{':
                depth += 1
            elif body[j] == '}':
                depth -= 1
            j += 1
        out.append((selector, body[start:j - 1]))
        i = j
    return out


def plural_parts(value):
    """Returns (var, [(category, text)]) or None when not a plural message."""
    m = re.match(r'^\s*\{\s*(\w+)\s*,\s*plural\s*,(.*)\}\s*$', value, re.S)
    if not m:
        return None
    var = m.group(1)
    branches = []
    for selector, text in split_branches(m.group(2)):
        category = EXPLICIT.get(selector, selector)
        if category not in PLURAL_CATEGORIES:
            continue
        branches.append((category, text))
    if not branches:
        return None
    # `=0` and `zero` (etc.) can both appear — the first wins.
    seen, unique = set(), []
    for category, text in branches:
        if category in seen:
            continue
        seen.add(category)
        unique.append((category, text))
    unique.sort(key=lambda b: PLURAL_CATEGORIES.index(b[0]))
    return var, unique


def method_signature(key, placeholders):
    params = ', '.join(f"{p.get('type', 'Object')} {name}" for name, p in placeholders.items())
    return f'String {key}({params})'


def build(template, locale, data):
    """Returns (abstract_members, impl_members) for one locale."""
    abstract, impl = [], []
    for key, value in template.items():
        if key.startswith('@'):
            continue
        translated = data.get(key, value)
        placeholders = (template.get('@' + key) or {}).get('placeholders', {})
        doc = dart_str(template[key]).strip("'")
        if not placeholders:
            abstract.append(
                f'  /// No description provided for @{key}.\n'
                f'  ///\n'
                f'  /// In en, this message translates to:\n'
                f'  /// **\'{doc}\'**\n'
                f'  String get {key};\n'
            )
            impl.append(f'  @override\n  String get {key} => {dart_str(translated)};\n')
            continue

        signature = method_signature(key, placeholders)
        abstract.append(
            f'  /// No description provided for @{key}.\n'
            f'  ///\n'
            f'  /// In en, this message translates to:\n'
            f'  /// **\'{doc}\'**\n'
            f'  {signature};\n'
        )
        parts = plural_parts(translated)
        if parts:
            var, branches = parts
            args = ',\n      '.join(
                f'{category}: {interpolate(text, placeholders)}' for category, text in branches
            )
            impl.append(
                f'  @override\n  {signature} {{\n'
                f'    String _temp0 = intl.Intl.pluralLogic(\n'
                f'      {var},\n'
                f'      locale: localeName,\n'
                f'      {args},\n'
                f'    );\n'
                f"    return '$_temp0';\n"
                f'  }}\n'
            )
        else:
            impl.append(
                f'  @override\n  {signature} {{\n'
                f'    return {interpolate(translated, placeholders)};\n'
                f'  }}\n'
            )
    return abstract, impl


def main():
    template = load(TEMPLATE)
    all_locales = locales()
    codes = ', '.join(f"Locale('{l}')" for l in all_locales)
    quoted = ', '.join(f"'{l}'" for l in all_locales)
    imports = '\n'.join(f"import 'app_localizations_{l}.dart';" for l in all_locales)
    cases = '\n'.join(
        f"    case '{l}':\n      return AppLocalizations{class_suffix(l)}();" for l in all_locales
    )

    header = f'''import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

{imports}

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
abstract class AppLocalizations {{
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {{
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }}

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[{codes}];

'''
    footer = f'''}}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {{
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {{
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }}

  @override
  bool isSupported(Locale locale) =>
      <String>[{quoted}].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}}

AppLocalizations lookupAppLocalizations(Locale locale) {{
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {{
{cases}
  }}

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}}
'''

    abstract, _ = build(template, TEMPLATE, template)
    (OUT_DIR / 'app_localizations.dart').write_text(header + '\n'.join(abstract) + footer, encoding='utf-8')

    names = {
        'en': 'English', 'fr': 'French', 'de': 'German', 'nl': 'Dutch',
        'tr': 'Turkish', 'ru': 'Russian', 'ar': 'Arabic',
    }
    for locale in all_locales:
        data = load(locale)
        _, impl = build(template, locale, data)
        suffix = class_suffix(locale)
        body = f'''// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for {names.get(locale, locale)} (`{locale}`).
class AppLocalizations{suffix} extends AppLocalizations {{
  AppLocalizations{suffix}([String locale = '{locale}']) : super(locale);

'''
        (OUT_DIR / f'app_localizations_{locale}.dart').write_text(body + '\n'.join(impl) + '}\n', encoding='utf-8')
        print(f'{locale}: {len(impl)} messages')


if __name__ == '__main__':
    main()
