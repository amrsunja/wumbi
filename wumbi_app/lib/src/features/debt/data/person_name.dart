/// Display and identity forms of a person's name. Identity is
/// case-insensitive and whitespace-tolerant so "ahmed " and "Ahmed" are the
/// same person (find-or-create, rename-merge).
///
/// Unicode NFC normalisation is deferred, like `TagNormalizer`, until a
/// normaliser dependency is added.
abstract class PersonName {
  /// Trimmed, inner whitespace collapsed to one space, case preserved.
  static String display(String raw) => raw.trim().replaceAll(RegExp(r'\s+'), ' ');

  /// [display] lower-cased — `people.normalized_name`.
  static String normalize(String raw) => display(raw).toLowerCase();
}
