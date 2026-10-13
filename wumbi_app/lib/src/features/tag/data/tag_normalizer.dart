/// Lower-case, trimmed, leading `#` removed, no inner whitespace (spec 5.7 / 11.3).
/// Unicode NFC normalisation is deferred until a normaliser dependency is added.
///
/// Nested tags (Obsidian style): `/` separates levels — `food/coffee` lives
/// inside `food`. Empty levels are dropped (`food//coffee/` → `food/coffee`),
/// so a path never starts, ends or doubles a slash.
abstract class TagNormalizer {
  static const String separator = '/';

  static String _strip(String raw) {
    var s = raw.trim();
    while (s.startsWith('#')) {
      s = s.substring(1);
    }
    s = s.trim().replaceAll(RegExp(r'\s+'), '');
    if (!s.contains(separator)) return s;
    return s.split(separator).where((part) => part.isNotEmpty).join(separator);
  }

  static String normalize(String raw) => _strip(raw).toLowerCase();

  /// Display name: as typed, `#` stripped, no spaces, clean `/` levels.
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

  // ------------------------------------------------------------------ paths

  /// `food/coffee/latte` → `[food, coffee, latte]`.
  static List<String> segments(String path) =>
      path.isEmpty ? const [] : path.split(separator);

  /// Last level: `food/coffee` → `coffee`.
  static String leaf(String path) {
    final i = path.lastIndexOf(separator);
    return i < 0 ? path : path.substring(i + 1);
  }

  /// Parent path, or null for a top-level tag: `food/coffee` → `food`.
  static String? parentOf(String path) {
    final i = path.lastIndexOf(separator);
    return i < 0 ? null : path.substring(0, i);
  }

  /// Every ancestor path, outermost first: `a/b/c` → `[a, a/b]`.
  static List<String> ancestors(String path) {
    final parts = segments(path);
    return [for (var i = 1; i < parts.length; i++) parts.sublist(0, i).join(separator)];
  }

  /// 0 for a top-level tag.
  static int depth(String path) => separator.allMatches(path).length;

  /// True when [path] sits (at any depth) inside [ancestor]. Compare
  /// normalized forms.
  static bool isDescendant(String path, String ancestor) =>
      path.length > ancestor.length && path.startsWith('$ancestor$separator');

  /// Same tag or nested inside it.
  static bool isSelfOrDescendant(String path, String ancestor) =>
      path == ancestor || isDescendant(path, ancestor);
}
