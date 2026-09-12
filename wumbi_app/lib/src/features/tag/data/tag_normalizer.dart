/// Lower-case, trimmed, leading `#` removed, no inner whitespace (spec 5.7 / 11.3).
/// Unicode NFC normalisation is deferred until a normaliser dependency is added.
abstract class TagNormalizer {
  static String _strip(String raw) {
    var s = raw.trim();
    while (s.startsWith('#')) {
      s = s.substring(1);
    }
    return s.trim().replaceAll(RegExp(r'\s+'), '');
  }

  static String normalize(String raw) => _strip(raw).toLowerCase();

  /// Display name: as typed, `#` stripped, no spaces.
  static String display(String raw) => _strip(raw);

  /// Dedupe a typed list by normalized form, keeping the first display casing.
  static List<String> dedupe(Iterable<String> raw) {
    final seen = <String>{};
    final out = <String>[];
    for (final r in raw) {
      final n = normalize(r);
      if (n.isEmpty || !seen.add(n)) continue;
      out.add(display(r));
    }
    return out;
  }
}
