#!/usr/bin/env python3
"""Regenerate lib/src/core/widgets/wumbi_logo_data.dart from the logo SVG.

Usage: python3 tool/gen_logo_paths.py
"""
import re
import textwrap

SVG = 'assets/images/app_logo.svg'
DART = 'lib/src/core/widgets/wumbi_logo_data.dart'
NAMES = ['w', 'u', 'm', 'b', 'i', 'coin', 'dollar']

svg = open(SVG).read()
paths = re.findall(r'<path d="([^"]+)" fill="([^"]+)"', svg)
assert len(paths) == len(NAMES), 'unexpected path count: %d' % len(paths)

vb = re.search(r'viewBox="0 0 (\d+) (\d+)"', svg)
vw, vh = vb.group(1), vb.group(2)

out = [
    '// GENERATED from assets/images/app_logo.svg — do not edit by hand.',
    '// Regenerate with: python3 tool/gen_logo_paths.py',
    '',
    "/// Raw SVG path data for the Wumbi logo, in the artwork's own",
    '/// %s x %s viewBox coordinate space.' % (vw, vh),
    'abstract final class WumbiLogoData {',
    '  static const double viewWidth = %s;' % vw,
    '  static const double viewHeight = %s;' % vh,
    '',
]
for name, (d, fill) in zip(NAMES, paths):
    d = ' '.join(d.split())
    chunks = textwrap.wrap(d, 92, break_long_words=True, break_on_hyphens=False)
    lines = []
    for i, c in enumerate(chunks):
        c = c.replace('\\', '\\\\').replace("'", "\\'")
        if i != len(chunks) - 1:
            c += ' '  # keep tokens apart across adjacent string literals
        lines.append("      '%s'" % c)
    out.append('  /// `%s` (fill %s).' % (name, fill))
    out.append('  static const String %s =\n%s;' % (name, '\n'.join(lines)))
    out.append('')
out.append('  /// Wordmark glyphs, in stroke order.')
out.append('  static const List<String> word = <String>[w, u, m, b, i];')
out.append('}')
open(DART, 'w').write('\n'.join(out) + '\n')
print('wrote %s' % DART)
