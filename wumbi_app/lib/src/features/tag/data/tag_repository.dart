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
import '../../budget/data/budget_local_datasource.dart';
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
    this.budgets = const BudgetLocalDatasource(),
  });

  final SQLiteServices sqlite;

  /// Needed for base-currency totals (tags hub). Null in unit tests → sums
  /// are reported per wallet currency only when the base matches.
  final FxService? fx;
  final void Function()? onWrite;
  final TagLocalDatasource datasource;

  /// Budget scope links (tag delete must not widen a budget to "any tag").
  final BudgetLocalDatasource budgets;

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

  /// Co-occurrence edges only — the hub builds the graph from the stats it
  /// already loaded instead of summing everything twice.
  Future<SuccessOrError<List<TagLink>>> links() => Failure.exceptionsCatcher(() => datasource.coOccurrences(sqlite.db));

  Future<SuccessOrError<List<TagWalletSum>>> walletsOfTag(String tagId) =>
      Failure.exceptionsCatcher(() => datasource.walletsOfTag(sqlite.db, tagId));

  /// Create a tag from the tags page (`food/coffee` also creates `food`).
  /// When the name already exists the existing tag is returned with
  /// `created: false` — nothing is written.
  Future<SuccessOrError<({TagModel tag, bool created})>> create(String rawName) =>
      Failure.exceptionsCatcher(() async {
        final display = _validName(rawName);
        final now = nowMs();
        late ({TagModel tag, bool created}) result;
        await sqlite.db.transaction((txn) async {
          final existing = await datasource.byNormalizedName(txn, TagNormalizer.normalize(display));
          if (existing != null) {
            result = (tag: existing, created: false);
            return;
          }
          result = (tag: await datasource.findOrCreate(txn, display, now), created: true);
        });
        if (result.created) onWrite?.call();
        return result;
      });

  /// Rename a tag — Obsidian semantics for nested tags: every tag inside it
  /// follows (`food` → `meals` turns `food/coffee` into `meals/coffee`), and
  /// a new path also moves it (`coffee` → `food/coffee` nests it under
  /// `food`, creating `food` if needed). When a new name already belongs to
  /// another live tag the two are merged (links moved, this one
  /// soft-deleted) and the surviving tag is returned.
  Future<SuccessOrError<TagModel>> rename(String id, String newName) =>
      Failure.exceptionsCatcher(() async {
        final display = _validName(newName);
        final normalized = TagNormalizer.normalize(display);
        final now = nowMs();
        late TagModel result;
        await sqlite.db.transaction((txn) async {
          final tag = await datasource.byId(txn, id);
          if (tag == null || tag.deletedAt != null) throw const NotFoundException('tag');
          // A tag cannot be moved inside itself.
          if (TagNormalizer.isDescendant(normalized, tag.normalizedName)) {
            throw const ValidationException('name');
          }
          final nested = await datasource.descendants(txn, tag.normalizedName);
          final rootDepth = TagNormalizer.segments(TagNormalizer.display(tag.displayName)).length;
          String suffixOf(TagModel child) => TagNormalizer.segments(TagNormalizer.display(child.displayName))
              .skip(rootDepth)
              .join(TagNormalizer.separator);
          // Every nested tag must still fit once moved under the new name.
          for (final child in nested) {
            if (display.length + 1 + suffixOf(child).length > kMaxTagLength) {
              throw const ValidationException('name');
            }
          }
          result = await _renameOne(txn, tag, display, now);
          for (final child in nested) {
            final current = await datasource.byId(txn, child.id);
            if (current == null || current.deletedAt != null) continue;
            await _renameOne(txn, current, '${result.displayName}${TagNormalizer.separator}${suffixOf(child)}', now);
          }
        });
        onWrite?.call();
        return result;
      });

  Future<TagModel> _renameOne(DatabaseExecutor txn, TagModel tag, String rawDisplay, int now) async {
    final display = TagNormalizer.display(rawDisplay);
    final normalized = TagNormalizer.normalize(display);
    for (final ancestor in TagNormalizer.ancestors(display)) {
      if (TagNormalizer.normalize(ancestor) == tag.normalizedName) continue;
      await datasource.findOrCreate(txn, ancestor, now);
    }
    final clash = await datasource.byNormalizedName(txn, normalized);
    if (clash != null && clash.id != tag.id) {
      await datasource.mergeInto(txn, tag.id, clash.id, now);
      return (await datasource.byId(txn, clash.id))!;
    }
    await datasource.rename(txn, tag.id, display, normalized, now);
    return tag.copyWith(displayName: display, normalizedName: normalized);
  }

  /// Trimmed display path; throws on empty / too long.
  static String _validName(String raw) {
    final display = TagNormalizer.display(raw);
    if (display.isEmpty) throw const ValidationException('name', 'Enter a tag name');
    if (display.length > kMaxTagLength) throw const ValidationException('name');
    return display;
  }

  /// Soft-delete a tag **and every tag nested inside it**, detaching them
  /// from every transaction, rule and budget. A budget whose tag scope
  /// becomes empty is soft-deleted too: it must never silently widen to
  /// "any tag" (spec B&D §4.4). Returns how many budgets were removed.
  Future<SuccessOrError<int>> delete(String id) => Failure.exceptionsCatcher(() async {
        final now = nowMs();
        var removedBudgets = 0;
        await sqlite.db.transaction((txn) async {
          final tag = await datasource.byId(txn, id);
          if (tag == null || tag.deletedAt != null) throw const NotFoundException('tag');
          final ids = [id, for (final child in await datasource.descendants(txn, tag.normalizedName)) child.id];
          final scoped = <String>[];
          for (final tagId in ids) {
            scoped.addAll(await budgets.budgetIdsWithTag(txn, tagId));
            await datasource.softDelete(txn, tagId, now);
          }
          removedBudgets = await budgets.softDeleteWithoutTags(txn, scoped, now);
        });
        onWrite?.call();
        return removedBudgets;
      });

  /// Creates the missing parents of nested tags (data typed before nesting
  /// existed). Cheap no-op once the tree is whole; bumps the DB revision only
  /// when something was inserted.
  Future<void> repairHierarchy() async {
    try {
      var created = 0;
      await sqlite.db.transaction((txn) async {
        created = await datasource.createMissingAncestors(txn, nowMs());
      });
      if (created > 0) onWrite?.call();
    } catch (_) {
      // Best effort — the hub still renders orphans as top-level tags.
    }
  }

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

  /// Autocomplete display names, ranked by usage then recency. An empty
  /// [prefix] returns the most used tags (keyboard tag bar).
  Future<List<String>> suggest(String prefix, {int limit = 6}) async {
    try {
      final tags = await datasource.suggest(sqlite.db, prefix, limit: limit);
      return tags.map((t) => t.displayName).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Ids of the live tags matching [names] (by normalized name). Names that
  /// are not a tag yet are skipped — nothing is created.
  Future<Set<String>> idsOfNames(Iterable<String> names) async {
    try {
      final ids = <String>{};
      for (final raw in TagNormalizer.dedupe(names)) {
        final tag = await datasource.byNormalizedName(sqlite.db, TagNormalizer.normalize(raw));
        if (tag != null) ids.add(tag.id);
      }
      return ids;
    } catch (_) {
      return const {};
    }
  }
}
