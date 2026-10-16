import 'dart:math' as math;

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/failures/failures.dart';
import '../../../core/fx/fx_service.dart';
import '../../../core/local/database/sqlite/sqlite_services.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/providers/data/fx_provider.dart';
import '../../../core/providers/local/sqlite_database_provider.dart';
import '../../../core/utils/typedefs.dart';
import '../../tag/data/tag_normalizer.dart';
import 'models/progress_stats.dart';
import 'progress_local_datasource.dart';

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(
    sqlite: ref.read(sqliteDataBaseProvider),
    fx: ref.read(fxServiceProvider),
  ),
);

/// Read-only aggregate for the Progress page. Conversion uses the local FX
/// cache only (never the network): currencies with no cached rate are dropped
/// and reported in [ProgressReport.unconvertible], exactly like the tags hub.
class ProgressRepository {
  ProgressRepository({
    required this.sqlite,
    this.fx,
    this.datasource = const ProgressLocalDatasource(),
  });

  final SQLiteServices sqlite;

  /// Null in unit tests → only rows already in [target] are counted.
  final FxService? fx;
  final ProgressLocalDatasource datasource;

  /// [viewed] is any instant inside the period to report (normalised to its
  /// start). [target] is the base currency, or the filtered wallet's own
  /// currency (then nothing is converted).
  Future<SuccessOrError<ProgressReport>> load({
    required ProgressGranularity granularity,
    required DateTime viewed,
    required ProgressBaseline baseline,
    required CurrencyType target,
    String? walletId,
    DateTime? now,
  }) =>
      Failure.exceptionsCatcher(() async {
        final g = granularity;
        final clock = now ?? DateTime.now();
        final start = g.startOf(viewed);
        final end = g.shift(start, 1);
        final nowStart = g.startOf(clock);
        final isCurrent = start == nowStart;
        final base = baseline.supports(g) ? baseline : const ProgressBaseline.previous();
        final baseStarts = base.periodsFor(g, start);
        final fxCtx = _Fx(fx, target);
        final db = sqlite.db;

        // Days of the period starting at [s] that have happened.
        int elapsedDaysOf(DateTime s) {
          if (s == nowStart) return _dayIndex(clock, s) + 1;
          if (s.isAfter(nowStart)) return 0;
          return g.daysIn(s);
        }

        final elapsedDays = elapsedDaysOf(start);
        final slots = g.slotsIn(start);
        final elapsedSlots = isCurrent ? g.slotOf(clock) + 1 : (start.isAfter(nowStart) ? 0 : slots);

        // ---- viewed period ----
        final cur = await _convertRows(await datasource.rows(db, start: start, end: end, walletId: walletId), fxCtx);
        final current = _totals(cur, target);
        final paceCurrent = _cumulative(g, cur, slots).sublist(0, elapsedSlots);
        final tagCur = await datasource.sumsByTag(db, start: start, end: end, walletId: walletId);

        // ---- comparison ----
        // Only baseline periods holding data count (a 3-month average for a
        // ledger started last month is last month, not a third of it). While
        // the viewed period runs, totals and tags compare like for like: the
        // same stretch of each baseline period (day 1 → today's day). The pace
        // curve and the forecast keep the whole baseline period.
        final paceSum = List<int>.filled(slots, 0);
        final tagCmp = <TagRangeSum>[];
        var used = 0, income = 0, expense = 0, ni = 0, ne = 0, fullExpense = 0, baseDays = 0;
        for (final s in baseStarts) {
          final sEnd = g.shift(s, 1);
          final rows = await _convertRows(await datasource.rows(db, start: s, end: sEnd, walletId: walletId), fxCtx);
          if (rows.isEmpty) continue;
          used++;
          final cutoff = isCurrent ? _earliest(DateTime(s.year, s.month, s.day + elapsedDays), sEnd) : sEnd;
          final t = _totals(rows.where((r) => r.date.isBefore(cutoff)), target);
          income += t.income.minor;
          expense += t.expense.minor;
          ni += t.incomeCount;
          ne += t.expenseCount;
          fullExpense += _totals(rows, target).expense.minor;
          baseDays += elapsedDaysOf(s);

          final own = _cumulative(g, rows, g.slotsIn(s));
          for (var i = 0; i < slots; i++) {
            // A shorter baseline month stays flat on its total; a longer one
            // lands its remaining days on the viewed period's last slot.
            paceSum[i] += i == slots - 1 ? own.last : own[math.min(i, own.length - 1)];
          }
          tagCmp.addAll(await datasource.sumsByTag(db, start: s, end: cutoff, walletId: walletId));
        }

        int mean(int v) => (v / used).round();
        final comparison = used == 0
            ? null
            : ProgressTotals(
                income: Money(mean(income), target),
                expense: Money(mean(expense), target),
                incomeCount: mean(ni),
                expenseCount: mean(ne),
              );
        final paceBaseline = used == 0 ? null : [for (final v in paceSum) mean(v)];

        // ---- history ----
        final len = g.historyLength;
        final historyEnd = g.between(start, nowStart) < len ? nowStart : start;
        final history = await _history(g, g.shift(historyEnd, -(len - 1)), len, walletId, fxCtx);

        // ---- tags ----
        final k = math.max(used, 1);
        final spending = await _breakdown('expense', tagCur, comparison == null ? null : tagCmp, k, fxCtx);
        final earning = await _breakdown('income', tagCur, comparison == null ? null : tagCmp, k, fxCtx);

        // ---- habits ----
        final habits = _habits(
          start: start,
          elapsedDays: elapsedDays,
          rows: cur,
          target: target,
          baselineDailyAverage: used == 0 || baseDays == 0 ? null : Money((fullExpense / baseDays).round(), target),
        );

        return ProgressReport(
          granularity: g,
          currency: target,
          walletId: walletId,
          viewed: start,
          now: clock,
          baseline: base,
          baselineStarts: baseStarts,
          current: current,
          comparison: comparison,
          comparisonIsToDate: isCurrent && comparison != null,
          paceCurrent: paceCurrent,
          paceBaseline: paceBaseline,
          history: history,
          spending: spending,
          earning: earning,
          habits: habits,
          unconvertible: fxCtx.unconvertible.toList(),
        );
      });

  /// Whole calendar days from [from] to [date] (UTC math: DST-proof).
  static int _dayIndex(DateTime date, DateTime from) =>
      DateTime.utc(date.year, date.month, date.day).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

  static DateTime _earliest(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

  // ---------------------------------------------------------------- helpers

  Future<List<_Row>> _convertRows(List<ProgressTxRow> rows, _Fx fx) async {
    final out = <_Row>[];
    for (final r in rows) {
      final minor = await fx.convert(r.amountMinor, r.currencyCode);
      if (minor == null) continue;
      out.add(_Row(r, minor));
    }
    return out;
  }

  static ProgressTotals _totals(Iterable<_Row> rows, CurrencyType c) {
    var income = 0, expense = 0, ni = 0, ne = 0;
    for (final r in rows) {
      if (r.raw.isIncome) {
        income += r.minor;
        ni++;
      } else {
        expense += r.minor;
        ne++;
      }
    }
    return ProgressTotals(income: Money(income, c), expense: Money(expense, c), incomeCount: ni, expenseCount: ne);
  }

  /// Running spending total per slot of one period's [rows].
  static List<int> _cumulative(ProgressGranularity g, Iterable<_Row> rows, int slots) {
    final perSlot = List<int>.filled(slots, 0);
    for (final r in rows) {
      if (r.raw.isIncome) continue;
      final i = g.slotOf(r.raw.date);
      if (i >= 0 && i < slots) perSlot[i] += r.minor;
    }
    var run = 0;
    return [for (final v in perSlot) run += v];
  }

  Future<List<ProgressPeriod>> _history(
    ProgressGranularity g,
    DateTime first,
    int len,
    String? walletId,
    _Fx fx,
  ) async {
    final edges = [for (var i = 0; i <= len; i++) g.shift(first, i)];
    final sums = await datasource.sumsByPeriod(sqlite.db, boundaries: edges, walletId: walletId);
    final income = List<int>.filled(len, 0);
    final expense = List<int>.filled(len, 0);
    final ni = List<int>.filled(len, 0);
    final ne = List<int>.filled(len, 0);
    for (final s in sums) {
      if (s.bucket < 0 || s.bucket >= len) continue;
      final minor = await fx.convert(s.totalMinor, s.currencyCode);
      if (minor == null) continue;
      if (s.type == 'income') {
        income[s.bucket] += minor;
        ni[s.bucket] += s.count;
      } else {
        expense[s.bucket] += minor;
        ne[s.bucket] += s.count;
      }
    }
    final c = fx.target;
    return [
      for (var i = 0; i < len; i++)
        ProgressPeriod(
          start: edges[i],
          totals: ProgressTotals(
            income: Money(income[i], c),
            expense: Money(expense[i], c),
            incomeCount: ni[i],
            expenseCount: ne[i],
          ),
        ),
    ];
  }

  /// Tag tree of one [type]. Families are rebuilt from the normalised paths;
  /// a tag whose parent is absent (deleted ancestor) becomes a root.
  Future<ProgressBreakdown> _breakdown(
    String type,
    List<TagRangeSum> current,
    List<TagRangeSum>? baseline,
    int k,
    _Fx fx,
  ) async {
    final c = fx.target;
    final cur = await _sumTags(type, current, fx);
    final cmp = baseline == null ? null : await _sumTags(type, baseline, fx);

    final meta = <String, TagRangeSum>{
      for (final r in [...current, ...?baseline])
        if (r.tagId != null && r.type == type) r.tagId!: r,
    };
    final idByPath = {for (final m in meta.values) m.normalizedName: m.tagId!};

    Money? baseOf(String key) => cmp == null ? null : Money(((cmp[key]?.$1 ?? 0) / k).round(), c);

    final children = <String, List<String>>{};
    final roots = <String>[];
    for (final m in meta.values) {
      // Nearest listed ancestor (an intermediate level may be missing).
      String? parentId;
      for (var p = TagNormalizer.parentOf(m.normalizedName); p != null && parentId == null; p = TagNormalizer.parentOf(p)) {
        parentId = idByPath[p];
      }
      if (parentId == null) {
        roots.add(m.tagId!);
      } else {
        (children[parentId] ??= []).add(m.tagId!);
      }
    }

    ProgressTagNode node(String id) {
      final m = meta[id]!;
      final kids = [
        for (final child in children[id] ?? const <String>[])
          if ((cur[child]?.$1 ?? 0) > 0) node(child),
      ]..sort((a, b) => b.amount.minor.compareTo(a.amount.minor));
      return ProgressTagNode(
        tagId: id,
        displayName: m.displayName,
        normalizedName: m.normalizedName,
        amount: Money(cur[id]?.$1 ?? 0, c),
        count: cur[id]?.$2 ?? 0,
        baseline: baseOf(id),
        children: kids,
      );
    }

    final all = [for (final id in roots) node(id)];
    final live = all.where((n) => n.amount.isPositive).toList()
      ..sort((a, b) => b.amount.minor.compareTo(a.amount.minor));
    final vanished = all.where((n) => !n.amount.isPositive && (n.baseline?.isPositive ?? false)).toList();

    return ProgressBreakdown(
      roots: live,
      vanished: vanished,
      untagged: Money(cur['']?.$1 ?? 0, c),
      untaggedCount: cur['']?.$2 ?? 0,
      untaggedBaseline: baseOf(''),
    );
  }

  /// tag id ('' = untagged) → (converted minor, count) for one type.
  Future<Map<String, (int, int)>> _sumTags(String type, List<TagRangeSum> rows, _Fx fx) async {
    final out = <String, (int, int)>{};
    for (final r in rows) {
      if (r.type != type) continue;
      final minor = await fx.convert(r.totalMinor, r.currencyCode);
      if (minor == null) continue;
      final key = r.tagId ?? '';
      final prev = out[key] ?? (0, 0);
      out[key] = (prev.$1 + minor, prev.$2 + r.count);
    }
    return out;
  }

  static ProgressHabits _habits({
    required DateTime start,
    required int elapsedDays,
    required List<_Row> rows,
    required CurrencyType target,
    required Money? baselineDailyAverage,
  }) {
    var spent = 0, count = 0, recurring = 0, recurringCount = 0;
    _Row? top;
    final weekdaySum = List<int>.filled(7, 0);
    for (final r in rows) {
      if (r.raw.isIncome) continue;
      spent += r.minor;
      count++;
      if (r.raw.recurring) {
        recurring += r.minor;
        recurringCount++;
      }
      if (top == null || r.minor > top.minor) top = r;
      weekdaySum[r.raw.date.weekday - 1] += r.minor;
    }

    // How many of each weekday the elapsed part of the period holds.
    final weekdayDays = List<int>.filled(7, 0);
    for (var d = 0; d < elapsedDays; d++) {
      weekdayDays[DateTime(start.year, start.month, start.day + d).weekday - 1]++;
    }

    final t = top;
    return ProgressHabits(
      dailyAverage: Money(elapsedDays == 0 ? 0 : (spent / elapsedDays).round(), target),
      baselineDailyAverage: baselineDailyAverage,
      topExpense: t == null
          ? null
          : ProgressTopExpense(
              id: t.raw.id,
              walletId: t.raw.walletId,
              description: t.raw.description,
              amount: Money(t.minor, target),
              date: t.raw.date,
            ),
      recurring: Money(recurring, target),
      recurringCount: recurringCount,
      averageExpense: count == 0 ? null : Money((spent / count).round(), target),
      weekdayAverages: [
        for (var i = 0; i < 7; i++) weekdayDays[i] == 0 ? 0 : (weekdaySum[i] / weekdayDays[i]).round(),
      ],
    );
  }
}

/// A row with its amount already in the report currency.
class _Row {
  const _Row(this.raw, this.minor);

  final ProgressTxRow raw;
  final int minor;

  DateTime get date => raw.date;
}

/// Cached-rate conversion into [target]; codes without a cached rate are
/// collected in [unconvertible] and their amounts dropped.
class _Fx {
  _Fx(this.service, this.target);

  final FxService? service;
  final CurrencyType target;
  final Map<CurrencyType, FxRate?> _rates = {};
  final Set<CurrencyType> unconvertible = {};

  Future<int?> convert(int minor, String code) async {
    final currency = CurrencyType.fromCode(code);
    if (currency == target) return minor;
    final rate = _rates.containsKey(currency) ? _rates[currency] : _rates[currency] = await service?.cachedRate(currency, target);
    if (rate == null) {
      unconvertible.add(currency);
      return null;
    }
    return convertMinor(minor, currency, target, rate.rate);
  }
}
