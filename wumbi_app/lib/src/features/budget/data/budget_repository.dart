import 'dart:math' as math;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' show DatabaseExecutor;

import '../../../core/errors/exceptions/domain/domain_exceptions.dart';
import '../../../core/errors/failures/failures.dart';
import '../../../core/fx/fx_service.dart';
import '../../../core/local/database/sqlite/sqlite_services.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/providers/data/db_revision_provider.dart';
import '../../../core/providers/data/fx_provider.dart';
import '../../../core/providers/local/sqlite_database_provider.dart';
import '../../../core/recurring/recurring_schedule.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/budget_period_type.dart';
import '../../../core/utils/enums/rollover_mode.dart';
import '../../../core/utils/enums/transaction_status.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/typedefs.dart';
import '../../tag/data/tag_local_datasource.dart';
import '../../tag/data/tag_normalizer.dart';
import '../../transaction/data/models/recurring_rule_model.dart';
import '../../transaction/data/transaction_local_datasource.dart';
import '../../wallet/data/wallet_local_datasource.dart';
import 'budget_local_datasource.dart';
import 'budget_metrics.dart';
import 'budget_period.dart';
import 'models/budget_model.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => BudgetRepository(
    sqlite: ref.read(sqliteDataBaseProvider),
    fx: ref.read(fxServiceProvider),
    onWrite: ref.read(dbRevisionBumperProvider),
  ),
);

/// Budgets: CRUD with scope validation, and derived progress per period
/// (spec B&D §5). Nothing about spending is stored — every read recomputes
/// from transactions, so edits / deletes anywhere are reflected for free.
///
/// Currency conversion uses **cached rates only** ([A5]): amounts in a
/// currency with no cached rate are skipped and the result is flagged
/// `incomplete`. FX is never called inside a `db.transaction` (the FX cache
/// lives in the same database; a nested access would deadlock).
class BudgetRepository {
  BudgetRepository({
    required this.sqlite,
    this.fx,
    this.onWrite,
    this.datasource = const BudgetLocalDatasource(),
    this.wallets = const WalletLocalDatasource(),
    this.tags = const TagLocalDatasource(),
    this.transactions = const TransactionLocalDatasource(),
  });

  final SQLiteServices sqlite;

  /// Null in unit tests → only amounts already in the budget currency count.
  final FxService? fx;
  final void Function()? onWrite;
  final BudgetLocalDatasource datasource;
  final WalletLocalDatasource wallets;
  final TagLocalDatasource tags;
  final TransactionLocalDatasource transactions;

  // ------------------------------------------------------------------ reads

  Future<SuccessOrError<BudgetModel>> byId(String id) => Failure.exceptionsCatcher(() async {
        final budget = await datasource.byId(sqlite.db, id);
        if (budget == null || budget.deletedAt != null) throw const NotFoundException('budget');
        return budget;
      });

  /// Every live budget measured over the period containing [now] (custom
  /// budgets: their single period, even before / after it).
  Future<SuccessOrError<List<BudgetProgress>>> listProgress({DateTime? now}) =>
      Failure.exceptionsCatcher(() async {
        final at = now ?? DateTime.now();
        final db = sqlite.db;
        final rates = _RateCache(fx);
        final out = <BudgetProgress>[];
        for (final b in await datasource.listLive(db)) {
          out.add(await _progress(db, b, periodIndexAt(b, at), at, rates));
        }
        return out;
      });

  /// One budget over the period [periodOffset] steps from the running one
  /// (≤ 0; details page browsing). Custom budgets have a single period.
  Future<SuccessOrError<BudgetProgress>> progressOf(String id, {int periodOffset = 0, DateTime? now}) =>
      Failure.exceptionsCatcher(() async {
        final at = now ?? DateTime.now();
        final db = sqlite.db;
        final b = await datasource.byId(db, id);
        if (b == null || b.deletedAt != null) throw const NotFoundException('budget');
        final index = b.period.isCustom ? 0 : periodIndexAt(b, at) + (periodOffset > 0 ? 0 : periodOffset);
        return _progress(db, b, index, at, _RateCache(fx));
      });

  /// Live budgets whose **running** period contains this posted, non-debt
  /// expense (spec B&D §5.7), most severe first. Drives the commit toast.
  Future<SuccessOrError<List<BudgetProgress>>> impactOf(String transactionId, {DateTime? now}) =>
      Failure.exceptionsCatcher(() async {
        final at = now ?? DateTime.now();
        final db = sqlite.db;
        final tx = await transactions.byId(db, transactionId);
        if (tx == null ||
            tx.deletedAt != null ||
            tx.type != TransactionType.expense ||
            tx.status != TransactionStatus.posted ||
            tx.isDebtLinked) {
          return const <BudgetProgress>[];
        }
        final rates = _RateCache(fx);
        final out = <BudgetProgress>[];
        for (final b in await datasource.matchingTransaction(db, transactionId)) {
          final period = currentPeriod(b, at);
          if (period == null || !period.contains(tx.transactionDate)) continue;
          out.add(await _progress(db, b, period.index, at, rates));
        }
        return out..sort(compareBudgetSeverity);
      });

  /// Average spent of a (possibly unsaved) scope over the last 3 complete
  /// periods of [period], rounded up to a nice number (spec B&D §5.6). Null
  /// when none of them has spending, and for one-time budgets.
  Future<SuccessOrError<Money?>> suggestLimit({
    required Set<String> walletIds,
    required Set<String> tagIds,
    required BudgetPeriodType period,
    required DateTime anchorDate,
    required CurrencyType currency,
    DateTime? now,
  }) =>
      Failure.exceptionsCatcher(() async {
        if (period.isCustom) return null;
        final at = now ?? DateTime.now();
        final k = periodIndexOf(period, anchorDate, at);
        final edges = [
          for (var i = k - 3; i <= k - 1; i++) periodOf(period, anchorDate, null, i).start,
          periodOf(period, anchorDate, null, k - 1).end,
        ];
        final sums = await datasource.bucketSums(sqlite.db, walletIds: walletIds, tagIds: tagIds, boundaries: edges);
        if (sums.every((s) => s.totalMinor == 0)) return null;
        final rates = _RateCache(fx);
        var total = 0;
        for (final s in sums) {
          total += await rates.convert(s.totalMinor, CurrencyType.fromCode(s.currencyCode), currency);
        }
        final nice = niceLimitCeil(total ~/ 3, currency);
        return nice == null ? null : Money(nice, currency);
      });

  // ----------------------------------------------------------------- writes

  /// [tagNames]: tags typed in the form; existing ones are reused, new ones
  /// created in the same transaction (rolled back if validation fails).
  Future<SuccessOrError<BudgetModel>> create(BudgetDraft draft, {List<String> tagNames = const []}) =>
      Failure.exceptionsCatcher(() async {
        final now = DateTime.now();
        final nowMillis = nowMs();
        late BudgetModel budget;
        await sqlite.db.transaction((txn) async {
          final clean = await _validate(txn, await _withTagNames(txn, draft, tagNames, nowMillis));
          budget = _toModel(clean, id: newId(), now: now, sortOrder: await datasource.nextSortOrder(txn));
          await datasource.insert(txn, budget);
          await datasource.setWallets(txn, budget.id, budget.walletIds, nowMillis);
          await datasource.setTags(txn, budget.id, budget.tagIds, nowMillis);
        });
        onWrite?.call();
        return budget;
      });

  /// Limit / scope / period edits apply to every period, past ones included
  /// ([A6]: history is derived, there are no per-period snapshots).
  Future<SuccessOrError<BudgetModel>> update(String id, BudgetDraft draft, {List<String> tagNames = const []}) =>
      Failure.exceptionsCatcher(() async {
        final now = DateTime.now();
        final nowMillis = nowMs();
        late BudgetModel budget;
        await sqlite.db.transaction((txn) async {
          final existing = await datasource.byId(txn, id);
          if (existing == null || existing.deletedAt != null) throw const NotFoundException('budget');
          final clean = await _validate(txn, await _withTagNames(txn, draft, tagNames, nowMillis));
          budget = _toModel(clean, id: id, now: now, sortOrder: existing.sortOrder, createdAt: existing.createdAt);
          await datasource.update(txn, budget);
          await datasource.setWallets(txn, id, budget.walletIds, nowMillis);
          await datasource.setTags(txn, id, budget.tagIds, nowMillis);
        });
        onWrite?.call();
        return budget;
      });

  /// Soft delete. Returns the `deleted_at` stamp the undo must pass back.
  Future<SuccessOrError<int>> delete(String id) => Failure.exceptionsCatcher(() async {
        final now = nowMs();
        await sqlite.db.transaction((txn) async {
          final existing = await datasource.byId(txn, id);
          if (existing == null || existing.deletedAt != null) throw const NotFoundException('budget');
          await datasource.softDelete(txn, id, now);
        });
        onWrite?.call();
        return now;
      });

  Future<SuccessOrError<void>> restore(String id, int deletedAtMs) => Failure.exceptionsCatcher(() async {
        final restored = await datasource.restore(sqlite.db, id, deletedAtMs, nowMs());
        if (restored == 0) throw const NotFoundException('budget');
        onWrite?.call();
      });

  // ---------------------------------------------------------------- helpers

  /// Resolves typed tag names (find-or-create) into [BudgetDraft.tagIds].
  Future<BudgetDraft> _withTagNames(DatabaseExecutor txn, BudgetDraft draft, List<String> names, int now) async {
    if (names.isEmpty) return draft;
    final ids = {...draft.tagIds};
    for (final raw in TagNormalizer.dedupe(names)) {
      ids.add((await tags.findOrCreate(txn, raw, now)).id);
    }
    return draft.copyWith(tagIds: ids);
  }

  Future<BudgetDraft> _validate(DatabaseExecutor txn, BudgetDraft draft) async {
    final name = draft.name.trim();
    if (name.isEmpty || name.length > kMaxBudgetNameLength) throw const ValidationException('name');
    if (draft.limit.minor <= 0) throw const ValidationException('limit', 'Enter an amount');
    if (draft.tagIds.length > kMaxBudgetTags) {
      throw const ValidationException('tags', 'Up to $kMaxBudgetTags tags');
    }
    final anchor = DateTime(draft.anchorDate.year, draft.anchorDate.month, draft.anchorDate.day);
    DateTime? end;
    if (draft.period.isCustom) {
      final e = draft.endDate;
      if (e == null) throw const ValidationException('endDate');
      end = DateTime(e.year, e.month, e.day);
      if (!end.isAfter(anchor)) throw const ValidationException('endDate');
    }
    for (final id in draft.walletIds) {
      final w = await wallets.rawById(txn, id);
      if (w == null || w.deletedAt != null) throw const ValidationException('wallets');
    }
    for (final id in draft.tagIds) {
      final t = await tags.byId(txn, id);
      if (t == null || t.deletedAt != null) throw const ValidationException('tags');
    }
    return draft.copyWith(
      name: name,
      anchorDate: anchor,
      endDate: end,
      // One-time budgets have nothing to carry into.
      rollover: draft.period.isCustom ? RolloverMode.none : draft.rollover,
    );
  }

  BudgetModel _toModel(
    BudgetDraft d, {
    required String id,
    required DateTime now,
    required int sortOrder,
    DateTime? createdAt,
  }) =>
      BudgetModel(
        id: id,
        name: d.name,
        limitMinor: d.limit.minor,
        currency: d.limit.currency,
        period: d.period,
        anchorDate: d.anchorDate,
        endDate: d.endDate,
        rollover: d.rollover,
        includePlanned: d.includePlanned,
        sortOrder: sortOrder,
        walletIds: d.walletIds,
        tagIds: d.tagIds,
        createdAt: createdAt ?? now,
        updatedAt: now,
      );

  /// Spent, planned, carry and metrics of period [index] of [b].
  Future<BudgetProgress> _progress(
    DatabaseExecutor db,
    BudgetModel b,
    int index,
    DateTime now,
    _RateCache rates,
  ) async {
    final c = b.currency;
    final period = periodAt(b, index);
    final isCurrent = period.contains(now);
    var incomplete = false;

    Future<int> sum(Map<String, int> byCurrency) async {
      var total = 0;
      for (final e in byCurrency.entries) {
        final from = CurrencyType.fromCode(e.key);
        final converted = await rates.tryConvert(e.value, from, c);
        if (converted == null) {
          incomplete = true;
        } else {
          total += converted;
        }
      }
      return total;
    }

    final spent = await sum(await datasource.sumsByCurrency(
      db,
      walletIds: b.walletIds,
      tagIds: b.tagIds,
      start: period.start,
      end: period.end,
      status: TransactionStatus.posted,
    ));

    var planned = 0;
    var subscriptionCount = 0;
    var subscriptionPlanned = 0;
    if (b.includePlanned && isCurrent) {
      final from = now.isAfter(period.start) ? now : period.start;
      planned += await sum(await datasource.sumsByCurrency(
        db,
        walletIds: b.walletIds,
        tagIds: b.tagIds,
        start: from,
        end: period.end,
        status: TransactionStatus.upcoming,
      ));
      final byCurrency = <String, int>{};
      for (final rule in await datasource.plannedRules(db, walletIds: b.walletIds, tagIds: b.tagIds)) {
        final n = _occurrencesIn(rule, from, period.end);
        if (n == 0) continue;
        subscriptionCount++;
        byCurrency.update(rule.currency.code, (v) => v + n * (rule.amountMinor ?? 0),
            ifAbsent: () => n * (rule.amountMinor ?? 0));
      }
      subscriptionPlanned = await sum(byCurrency);
      planned += subscriptionPlanned;
    }

    var carry = 0;
    if (!b.rollover.isNone && !b.period.isCustom && index > 0) {
      final n = math.min(index, kBudgetRolloverLookback);
      final edges = [for (var i = index - n; i <= index; i++) periodAt(b, i).start];
      final perBucket = List<int>.filled(n, 0);
      for (final s in await datasource.bucketSums(db, walletIds: b.walletIds, tagIds: b.tagIds, boundaries: edges)) {
        if (s.bucket < 0 || s.bucket >= n) continue;
        final converted = await rates.tryConvert(s.totalMinor, CurrencyType.fromCode(s.currencyCode), c);
        if (converted == null) {
          incomplete = true;
          continue;
        }
        perBucket[s.bucket] += converted;
      }
      carry = rolloverCarry(limit: b.limitMinor, spentPerPeriod: perBucket, mode: b.rollover);
    }

    final limit = b.limitMinor + carry;
    final m = computeBudgetMetrics(
      limit: limit,
      spent: spent,
      planned: planned,
      period: period,
      isCustom: b.period.isCustom,
      now: now,
    );
    return BudgetProgress(
      budget: b,
      period: period,
      isCurrent: m.isCurrent,
      limit: Money(limit, c),
      carry: Money(carry, c),
      spent: Money(spent, c),
      planned: Money(planned, c),
      remaining: Money(m.remaining, c),
      free: Money(m.free, c),
      perDay: m.perDay == null ? null : Money(m.perDay!, c),
      forecast: m.forecast == null ? null : Money(m.forecast!, c),
      paceDelta: Money(m.paceDelta, c),
      daysLeft: m.daysLeft,
      timeRatio: m.timeRatio,
      spentRatio: m.spentRatio,
      status: m.status,
      incomplete: incomplete,
      subscriptionCount: subscriptionCount,
      subscriptionPlanned: subscriptionCount == 0 ? null : Money(subscriptionPlanned, c),
    );
  }

  /// Future occurrences of a subscription in `[from, end)` (and ≤ its own
  /// end date), walked with the engine's step so re-anchored rules project
  /// exactly the dates catch-up will generate.
  static int _occurrencesIn(RecurringRuleModel rule, DateTime from, DateTime end) {
    if (rule.frequency.isNever) return 0;
    var n = 0;
    var walked = 0;
    final ruleEnd = rule.endDate;
    for (final date in occurrencesFrom(
      startDate: rule.startDate,
      frequency: rule.frequency,
      nextOccurrence: rule.nextOccurrence,
      occurrenceCount: rule.occurrenceCount,
    )) {
      if (!date.isBefore(end)) break;
      if (ruleEnd != null && date.isAfter(ruleEnd)) break;
      if (!date.isBefore(from)) n++;
      if (++walked >= kMaxPlannedOccurrencesPerRule) break;
    }
    return n;
  }
}

/// Cached-rate conversion with a per-call memo (one DB read per pair).
class _RateCache {
  _RateCache(this.fx);

  final FxService? fx;
  final Map<(CurrencyType, CurrencyType), double?> _rates = {};

  /// Null when no cached rate exists for the pair.
  Future<int?> tryConvert(int minor, CurrencyType from, CurrencyType to) async {
    if (from == to) return minor;
    final key = (from, to);
    final rate = _rates.containsKey(key) ? _rates[key] : _rates[key] = (await fx?.cachedRate(from, to))?.rate;
    if (rate == null) return null;
    return convertMinor(minor, from, to, rate);
  }

  /// Unconvertible amounts count as 0 (suggestions are best effort).
  Future<int> convert(int minor, CurrencyType from, CurrencyType to) async =>
      await tryConvert(minor, from, to) ?? 0;
}
