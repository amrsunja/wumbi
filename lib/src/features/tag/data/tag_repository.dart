import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/errors/failures/failures.dart';
import '../../../core/local/database/sqlite/sqlite_services.dart';
import '../../../core/providers/local/sqlite_database_provider.dart';
import '../../../core/utils/typedefs.dart';
import 'models/tag_model.dart';
import 'tag_local_datasource.dart';
import 'tag_normalizer.dart';

final tagRepositoryProvider = Provider<TagRepository>(
  (ref) => TagRepository(sqlite: ref.read(sqliteDataBaseProvider)),
);

/// Tag attach = find-or-create, link, `usage_count += 1`; detach = unlink,
/// `usage_count -= 1`. `syncTransactionTags` diffs old vs new sets.
/// All mutating methods take the caller's transaction executor so they join
/// the transaction write atomically.
class TagRepository {
  TagRepository({required this.sqlite, this.datasource = const TagLocalDatasource()});

  final SQLiteServices sqlite;
  final TagLocalDatasource datasource;

  /// Attach [tags] to a new transaction. Returns the tag ids.
  Future<List<String>> attachToTransaction(
    DatabaseExecutor txn,
    String transactionId,
    List<String> tags,
    int now,
  ) async {
    final ids = <String>[];
    for (final raw in TagNormalizer.dedupe(tags)) {
      final tag = await datasource.findOrCreate(txn, raw, now);
      await datasource.linkTransaction(txn, transactionId, tag.id, now);
      await datasource.bumpUsage(txn, tag.id, 1, now);
      ids.add(tag.id);
    }
    return ids;
  }

  /// Diff old vs new: unlink removed, link added.
  Future<void> syncTransactionTags(
    DatabaseExecutor txn,
    String transactionId,
    List<String> newTags,
    int now,
  ) async {
    final current = await datasource.tagsOfTransaction(txn, transactionId);
    final wanted = TagNormalizer.dedupe(newTags);
    final wantedNormalized = wanted.map(TagNormalizer.normalize).toSet();

    for (final tag in current) {
      if (!wantedNormalized.contains(tag.normalizedName)) {
        await datasource.unlinkTransaction(txn, transactionId, tag.id);
        await datasource.bumpUsage(txn, tag.id, -1, now);
      }
    }
    final currentNormalized = current.map((t) => t.normalizedName).toSet();
    for (final raw in wanted) {
      if (currentNormalized.contains(TagNormalizer.normalize(raw))) continue;
      final tag = await datasource.findOrCreate(txn, raw, now);
      await datasource.linkTransaction(txn, transactionId, tag.id, now);
      await datasource.bumpUsage(txn, tag.id, 1, now);
    }
  }

  /// Copy a rule's tags onto a generated occurrence (`usage_count++`).
  Future<void> copyRuleTagsToTransaction(
    DatabaseExecutor txn,
    String ruleId,
    String transactionId,
    int now,
  ) async {
    for (final tagId in await datasource.tagIdsOfRule(txn, ruleId)) {
      await datasource.linkTransaction(txn, transactionId, tagId, now);
      await datasource.bumpUsage(txn, tagId, 1, now);
    }
  }

  Future<void> attachToRule(DatabaseExecutor txn, String ruleId, List<String> tagIds, int now) async {
    for (final id in tagIds) {
      await datasource.linkRule(txn, ruleId, id, now);
    }
  }

  Future<SuccessOrError<List<TagModel>>> tagsOfTransaction(String transactionId) =>
      Failure.exceptionsCatcher(() => datasource.tagsOfTransaction(sqlite.db, transactionId));

  /// Autocomplete display names (up to 5), ranked by usage then recency.
  Future<List<String>> suggest(String prefix) async {
    try {
      final tags = await datasource.suggest(sqlite.db, prefix);
      return tags.map((t) => t.displayName).toList();
    } catch (_) {
      return const [];
    }
  }
}
