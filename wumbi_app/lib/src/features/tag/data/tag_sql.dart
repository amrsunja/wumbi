import '../../../core/local/database/sqlite/sqlite_config.dart';

/// SQL fragments for nested tags (Obsidian semantics): a parent tag matches
/// every transaction carrying it **or any tag nested inside it**.
///
/// Prefix matching uses `substr` instead of `LIKE` so `_` / `%` in tag names
/// are never wildcards.
abstract class TagSql {
  static const _tags = SQLiteConfig.tagsTable;
  static const _id = SQLiteConfig.id;
  static const _n = SQLiteConfig.tagNormalizedName;
  static const _del = SQLiteConfig.deletedAt;

  /// `c` is [parentAlias] itself or nested inside it.
  static String selfOrDescendant(String childAlias, String parentAlias) =>
      '($childAlias.$_id = $parentAlias.$_id OR '
      "substr($childAlias.$_n, 1, length($parentAlias.$_n) + 1) = $parentAlias.$_n || '/')";

  /// Sub-select of live tag ids equal to or nested inside any of the ids
  /// bound by [placeholders] (e.g. `?, ?` or `?3,?4`). Use as
  /// `tag_id IN (${TagSql.expandIds(ph)})`.
  static String expandIds(String placeholders) =>
      'SELECT tc.$_id FROM $_tags tp JOIN $_tags tc ON tc.$_del IS NULL AND ${selfOrDescendant('tc', 'tp')} '
      'WHERE tp.$_id IN ($placeholders)';
}
