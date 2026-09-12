import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/errors/exceptions/domain/domain_exceptions.dart';
import '../../../core/errors/failures/failures.dart';
import '../../../core/fx/fx_service.dart';
import '../../../core/local/database/sqlite/sqlite_services.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/providers/data/db_revision_provider.dart';
import '../../../core/providers/data/fx_provider.dart';
import '../../../core/providers/local/sqlite_database_provider.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/typedefs.dart';
import 'models/tag_model.dart';
import 'models/tag_stats.dart';
import 'tag_local_datasource.dart';
import 'tag_normalizer.dart';

final tagRepositoryProvider = Provider<TagRepository>(
  (ref) => TagRepository(
    sqlite: ref.read(sqliteDataBaseProvider),
    fx: ref.read(fxServiceProvider),
    onWrite: ref.read(dbRevisionBumperProvider),
  ),
);

/// Tag attach = find-or-create, link, `usage_count += 1`; detach = unlink,
/// `usage_count -= 1`. `syncTransactionTags` diffs old vs new sets.
/// All mutating methods take the caller's transaction executor so they join
/// the transaction write atomically.
class TagRepository {
  TagRepository({
    required this.sqlite,
    this.fx,
    this.onWrite,
    this.datasource = const TagLocalDatasource(),
  });

  final SQLiteServices sqlite;

  /// Needed for base-currency totals (tags hub). Null in unit tests → sums
  /// are reported per wallet currency only when the base matches.
  final FxService? fx;
  final void Function()? onWrite;
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

  /// Diff a rule's tag set (subscriptions edit). Usage counts belong to
  /// transactions, so they are not touched here.
  Future<void> syncRuleTags(DatabaseExecutor txn, String ruleId, List<String> newTags, int now) async {
    final current = await datasource.tagsOfRule(txn, ruleId);
    final wanted = TagNormalizer.dedupe(newTags);
    final wantedNormalized = wanted.map(TagNormalizer.normalize).toSet();
    for (final tag in current) {
      if (!wantedNormalized.contains(tag.normalizedName)) {
        await datasource.unlinkRule(txn, ruleId, tag.id);
      }
    }
    final currentNormalized = current.map((t) => t.normalizedName).toSet();
    for (final raw in wanted) {
      if (currentNormalized.contains(TagNormalizer.normalize(raw))) continue;
      final tag = await datasource.findOrCreate(txn, raw, now);
      await datasource.linkRule(txn, ruleId, tag.id, now);
    }
  }

  Future<SuccessOrError<List<TagModel>>> tagsOfTransaction(String transactionId) =>
      Failure.exceptionsCatcher(() => datasource.tagsOfTransaction(sqlite.db, transactionId));

  // ------------------------------------------------------------- tags hub

  Future<SuccessOrError<List<TagModel>>> listAll() =>
      Failure.exceptionsCatcher(() => datasource.listAll(sqlite.db));

  Future<SuccessOrError<TagModel>> byId(String id) => Failure.exceptionsCatcher(() async {
        final tag = await datasource.byId(sqlite.db, id);
        if (tag == null || tag.deletedAt != null) throw const NotFoundException('tag');
        return tag;
      });

  /// Every live tag with base-currency totals, most-moved first.
  Future<SuccessOrError<List<TagStats>>> stats(CurrencyType base) =>
      Failure.exceptionsCatcher(() async {
        final db = sqlite.db;
        final tags = await datasource.listAll(db);
        final sums = await datasource.sumsByTag(db);
        return _buildStats(tags, sums, base);
      });

  Future<SuccessOrError<TagStats>> statsOf(String tagId, CurrencyType base) =>
      Failure.exceptionsCatcher(() async {
        final db = sqlite.db;
        final tag = await datasource.byId(db, tagId);
        if (tag == null || tag.deletedAt != null) throw const NotFoundException('tag');
        final sums = await datasource.sumsByTag(db, tagId: tagId);
        return (await _buildStats([tag], sums, base)).first;
      });

  /// Nodes (stats) + co-occurrence edges for the graph view.
  Future<SuccessOrError<TagGraphData>> graph(CurrencyType base) =>
      Failure.exceptionsCatcher(() async {
        final db = sqlite.db;
        final tags = await datasource.listAll(db);
        final sums = await datasource.sumsByTag(db);
        final links = await datasource.coOccurrences(db);
        return TagGraphData(nodes: await _buildStats(tags, sums, base), links: links, base: base);
      });

  Future<SuccessOrError<List<TagWalletSum>>> walletsOfTag(String tagId) =>
      Failure.exceptionsCatcher(() => datasource.walletsOfTag(sqlite.db, tagId));

  /// Rename a tag. When the new normalized name already belongs to another
  /// live tag, the two are merged into that tag (links moved, this one
  /// soft-deleted) and the surviving tag is returned.
  Future<SuccessOrError<TagModel>> rename(String id, String newName) =>
      Failure.exceptionsCatcher(() async {
        final display = TagNormalizer.display(newName);
        final normalized = TagNormalizer.normalize(newName);
        if (normalized.isEmpty) throw const ValidationException('name', 'Enter a tag name');
        if (display.length > kMaxTagLength) throw const ValidationException('name');
        final now = nowMs();
        late TagModel result;
        await sqlite.db.transaction((txn) async {
          final tag = await datasource.byId(txn, id);
          if (tag == null || tag.deletedAt != null) throw const NotFoundException('tag');
          final clash = await datasource.byNormalizedName(txn, normalized);
          if (clash != null && clash.id != id) {
            await datasource.mergeInto(txn, id, clash.id, now);
            result = (await datasource.byId(txn, clash.id))!;
            return;
          }
          await datasource.rename(txn, id, display, normalized, now);
          result = tag.copyWith(displayName: display, normalizedName: normalized);
        });
        onWrite?.call();
        return result;
      });

  /// Soft-delete a tag and detach it from every transaction and rule.
  Future<SuccessOrError<void>> delete(String id) => Failure.exceptionsCatcher(() async {
        await sqlite.db.transaction((txn) => datasource.softDelete(txn, id, nowMs()));
        onWrite?.call();
      });

  Future<List<TagStats>> _buildStats(List<TagModel> tags, List<TagCurrencySum> sums, CurrencyType base) async {
    final byTag = <String, List<TagCurrencySum>>{};
    for (final s in sums) {
      byTag.putIfAbsent(s.tagId, () => []).add(s);
    }
    final rates = <CurrencyType, FxRate?>{};
    final out = <TagStats>[];
    for (final tag in tags) {
      var income = 0;
      var expense = 0;
      var count = 0;
      final unconvertible = <CurrencyType>{};
      for (final s in byTag[tag.id] ?? const <TagCurrencySum>[]) {
        count += s.count;
        final currency = CurrencyType.fromCode(s.currencyCode);
        int converted;
        if (currency == base) {
          converted = s.totalMinor;
        } else {
          final rate = rates.containsKey(currency)
              ? rates[currency]
              : rates[currency] = await fx?.cachedRate(currency, base);
          if (rate == null) {
            unconvertible.add(currency);
            continue;
          }
          converted = convertMinor(s.totalMinor, currency, base, rate.rate);
        }
        if (s.type == 'income') {
          income += converted;
        } else {
          expense += converted;
        }
      }
      out.add(
        TagStats(
          tag: tag,
          income: Money(income, base),
          expense: Money(expense, base),
          transactionCount: count,
          unconvertible: unconvertible.toList(),
        ),
      );
    }
    out.sort((a, b) {
      final byVolume = b.volumeMinor.compareTo(a.volumeMinor);
      return byVolume != 0 ? byVolume : b.tag.usageCount.compareTo(a.tag.usageCount);
    });
    return out;
  }

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
