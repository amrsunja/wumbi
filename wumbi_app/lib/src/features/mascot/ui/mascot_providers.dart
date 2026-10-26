import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/providers/data/db_revision_provider.dart';
import '../../../core/providers/data/fx_provider.dart';
import '../../../core/providers/local/sqlite_database_provider.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../budget/data/budget_metrics.dart';
import '../../budget/data/models/budget_model.dart';
import '../../budget/ui/budgets_provider.dart';
import '../../dashboard/ui/dashboard_notifier.dart';
import '../../debt/ui/debts_provider.dart';
import '../../progress/data/models/progress_stats.dart';
import '../../progress/data/progress_local_datasource.dart';
import '../../progress/data/progress_repository.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../subscription/ui/subscriptions_provider.dart';
import '../data/mascot_memory.dart';
import '../data/mascot_repository.dart';
import '../domain/mascot_brain.dart';
import '../domain/mascot_message.dart';
import '../domain/mascot_reaction.dart';
import '../domain/mascot_screens.dart';
import '../domain/mascot_signals.dart';

// ------------------------------------------------------------------ memory

/// The hamster's local memory. Loaded once per launch — which counts as a
/// visit — and kept in memory; every change is written through.
final mascotMemoryProvider = AsyncNotifierProvider<MascotMemoryNotifier, MascotMemory>(MascotMemoryNotifier.new);

class MascotMemoryNotifier extends AsyncNotifier<MascotMemory> {
  MascotMemoryStore get _store => MascotMemoryStore(ref.read(sqliteDataBaseProvider));

  @override
  Future<MascotMemory> build() async {
    MascotMemory loaded;
    try {
      loaded = await _store.load();
    } catch (_) {
      loaded = const MascotMemory();
    }
    final visited = loaded.visited(DateTime.now());
    _save(visited);
    return visited;
  }

  void _save(MascotMemory m) => _store.save(m).catchError((Object _) {});

  void _update(MascotMemory Function(MascotMemory) change) {
    final current = state.value;
    if (current == null) return;
    final next = change(current);
    state = AsyncData(next);
    _save(next);
  }

  /// A new session after a long pause (see [mascotSessionProvider]).
  void recordVisit() => _update((m) => m.visited(DateTime.now()));

  void markShown(MascotMessage message) => _update((m) => m.markShown(message, DateTime.now()));

  void quietToday() => _update((m) => m.quietToday(DateTime.now()));
}

// ----------------------------------------------------------------- session

/// One "open" of the app (spec §3.3): a launch, or a return after
/// [MascotSessionNotifier.pause] in the background. Each session the
/// dashboard says the next thought.
final mascotSessionProvider = NotifierProvider<MascotSessionNotifier, int>(MascotSessionNotifier.new);

class MascotSessionNotifier extends Notifier<int> {
  static const Duration pause = Duration(minutes: 5);

  @override
  int build() => 0;

  /// Called by `App` on resume; true when a new session started.
  bool resumedAfter(Duration away) {
    if (away < pause) return false;
    state = state + 1;
    ref.read(mascotMemoryProvider.notifier).recordVisit();
    return true;
  }
}

// --------------------------------------------------------------- reactions

/// The latest action to react to, consumed by the first mascot slot that is
/// on screen ([useMascotReaction]).
final mascotReactionProvider = NotifierProvider<MascotReactionNotifier, MascotReaction?>(MascotReactionNotifier.new);

class MascotReactionNotifier extends Notifier<MascotReaction?> {
  @override
  MascotReaction? build() => null;

  void push(MascotReactionKind kind, {Money? amount}) =>
      state = MascotReaction(kind, amount: amount, at: DateTime.now());

  /// Income, converted to the base currency (when a rate is cached) so the
  /// slot can tell a big income from a regular one.
  Future<void> pushIncome(Money amount) async {
    final base = ref.read(baseCurrencyProvider);
    var shown = amount;
    if (amount.currency != base) {
      try {
        final rate = await ref.read(fxServiceProvider).cachedRate(amount.currency, base);
        if (rate != null) shown = convertMoney(amount, base, rate.rate);
      } catch (_) {}
    }
    push(MascotReactionKind.income, amount: shown);
  }

  /// True when [r] was still pending (the caller plays it).
  bool consume(MascotReaction r) {
    if (!identical(state, r)) return false;
    state = null;
    return true;
  }
}

// ------------------------------------------------------------------- data

/// This month against the previous one (to date), in the base currency —
/// the same numbers as Progress. Shared by the dashboard, Tags and Tag
/// details.
final mascotMonthReportProvider = FutureProvider.autoDispose<ProgressReport?>((ref) async {
  ref.watch(dbRevisionProvider);
  final base = ref.watch(baseCurrencyProvider);
  final now = DateTime.now();
  final result = await ref.read(progressRepositoryProvider).load(
        granularity: ProgressGranularity.month,
        viewed: now,
        baseline: const ProgressBaseline.previous(),
        target: base,
        now: now,
      );
  return result.tryGetSuccess();
});

/// One wallet's month so far (Wallet details corner).
final mascotWalletActivityProvider =
    FutureProvider.autoDispose.family<MascotWalletActivity?, String>((ref, walletId) async {
  ref.watch(dbRevisionProvider);
  return ref.read(mascotRepositoryProvider).walletActivity(walletId);
});

/// Weekday name (0 = Monday) in the app language, capitalised.
String mascotWeekdayName(int index) {
  final day = DateTime(2024, 1, 1 + index); // 2024-01-01 is a Monday.
  String name;
  try {
    name = DateFormat('EEEE', Intl.defaultLocale).format(day);
  } catch (_) {
    name = DateFormat('EEEE', 'en_US').format(day);
  }
  return name.isEmpty ? name : '${name[0].toUpperCase()}${name.substring(1)}';
}

/// Everything the dashboard brain reads (spec §3.1).
final mascotSignalsProvider = FutureProvider.autoDispose<MascotSignals>((ref) async {
  ref.watch(dbRevisionProvider);
  final base = ref.watch(baseCurrencyProvider);
  final prevVisit = ref.watch(mascotMemoryProvider.select((m) => m.value?.prevVisitAt));
  final dashboardF = ref.watch(dashboardProvider.future);
  final budgetsF = ref.watch(budgetsProvider.future);
  final debtsF = ref.watch(debtsOverviewProvider.future);
  final rulesF = ref.watch(subscriptionsProvider.future);
  final reportF = ref.watch(mascotMonthReportProvider.future);
  final repo = ref.read(mascotRepositoryProvider);
  final fx = ref.read(fxServiceProvider);

  final dashboard = await dashboardF;
  final budgets = await budgetsF;
  final debts = await debtsF;
  final rules = await rulesF;
  final report = await reportF;
  final activity = await repo.activity(since: prevVisit);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final rates = <CurrencyType, double?>{};
  Future<int?> toBase(Money m) async {
    if (m.currency == base) return m.minor;
    if (!rates.containsKey(m.currency)) {
      rates[m.currency] = (await fx.cachedRate(m.currency, base))?.rate;
    }
    final rate = rates[m.currency];
    return rate == null ? null : convertMinor(m.minor, m.currency, base, rate);
  }

  // ---- month & the user's own base --------------------------------------
  final zero = Money.zero(base);
  final monthStart = DateTime(now.year, now.month);
  final complete = report == null
      ? const <ProgressPeriod>[]
      : report.history.where((p) => p.start.isBefore(monthStart) && !p.isEmpty).toList();
  var avgExpense = MascotBrain.meanOf(complete.map((p) => p.expense));
  final avgIncome = MascotBrain.meanOf(complete.map((p) => p.income));
  if (avgExpense == null && report != null && now.day >= 7 && report.current.expense.isPositive) {
    // No complete month yet: project this one.
    final days = DateTime(now.year, now.month + 1, 0).day;
    avgExpense = Money((report.current.expense.minor / now.day * days).round(), base);
  }

  // ---- obligations of the next 30 days ----------------------------------
  var obligations = 0;
  var subsMonthly = 0;
  for (final r in rules) {
    if (!r.isActive || r.deletedAt != null || r.type != TransactionType.expense) continue;
    final monthly = ((r.amountMinor ?? 0) * monthlyFactor(r.frequency, r.interval)).round();
    subsMonthly += await toBase(Money(monthly, r.currency)) ?? 0;
  }
  obligations += subsMonthly;
  for (final d in debts.openBorrowed) {
    final due = d.debt.dueDate;
    if (due == null || MascotSignals.calendarDays(today, due) > 30) continue;
    obligations += await toBase(d.remaining) ?? 0;
  }
  final running = budgets.where(isRunningBudget).toList();
  for (final p in running) {
    obligations += await toBase(p.free) ?? 0;
  }
  final avg = avgExpense;
  final reserve = avg == null || !avg.isPositive ? null : (dashboard.total.minor - obligations) / avg.minor;

  // ---- budgets ------------------------------------------------------------
  MascotBudgetSignal budgetSignal(BudgetProgress p, {required bool over}) => MascotBudgetSignal(
        id: p.budget.id,
        name: p.budget.name,
        amount: over ? p.remaining.abs() : p.remaining,
        percent: p.spentRatio.isFinite ? (p.spentRatio * 100).round() : 100,
      );
  final overList = running.where((p) => p.status == BudgetStatus.over).toList()..sort(compareBudgetSeverity);
  final nearList = running.where(MascotScreens.isNearLimit).toList()
    ..sort((a, b) => b.spentRatio.compareTo(a.spentRatio));

  // ---- debts --------------------------------------------------------------
  MascotDebtSignal? overdue;
  MascotDebtSignal? dueSoon;
  for (final d in [...debts.openLent, ...debts.openBorrowed]) {
    final days = MascotScreens.daysUntilDue(d, now);
    if (days == null) continue;
    if (d.overdue) {
      final late = -days < 1 ? 1 : -days;
      if (overdue == null || late > overdue.days) {
        overdue = MascotDebtSignal(id: d.debt.id, name: d.person.name, days: late);
      }
    } else if (days >= 0 && days <= 3 && (dueSoon == null || days < dueSoon.days)) {
      dueSoon = MascotDebtSignal(id: d.debt.id, name: d.person.name, days: days);
    }
  }

  // ---- subscriptions -------------------------------------------------------
  final charge = MascotScreens.nextCharge(rules, now);

  // ---- insights ---------------------------------------------------------
  MascotMoverSignal? mover;
  int? peak;
  var best = report == null ? null : _bestLastMonth(report, now);
  if (report != null) {
    for (final n in report.movers(limit: 3)) {
      final b = n.baseline;
      final delta = n.delta;
      if (b == null || delta == null || !b.isPositive || !delta.isPositive) continue;
      final percent = (delta.minor * 100 / b.minor).round();
      if (percent >= 25) {
        mover = MascotMoverSignal(tagId: n.tagId, name: n.displayName, percent: percent);
        break;
      }
    }
    if (now.day >= 14) peak = MascotScreens.strongPeakWeekday(report.habits);
  }
  if (now.day > 10) best = null;

  // ---- insights v2 ------------------------------------------------------
  final weekStart = today.subtract(Duration(days: now.weekday - 1));
  final lastWeekStart = weekStart.subtract(const Duration(days: 7));
  final times = await repo.recordTimes(since: today.subtract(const Duration(days: 40)));
  final recordsToday = times.where((t) => !t.isBefore(today)).length;
  final recordDays = {for (final t in times) DateTime(t.year, t.month, t.day)};
  var streak = 0;
  var cursor = recordDays.contains(today) ? today : today.subtract(const Duration(days: 1));
  while (recordDays.contains(cursor)) {
    streak++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }

  var lastWeek = 0;
  var smallSum = 0;
  var smallCount = 0;
  DateTime? lastIncomeAt;
  var yesterdayExpenses = 0;
  final yesterday = today.subtract(const Duration(days: 1));
  final avgTicket = report?.habits.averageExpense;
  final rowsFrom = lastWeekStart.isBefore(monthStart) ? lastWeekStart : monthStart;
  try {
    final rows = await const ProgressLocalDatasource().rows(
      ref.read(sqliteDataBaseProvider).db,
      start: rowsFrom,
      end: today.add(const Duration(days: 1)),
    );
    for (final r in rows) {
      if (r.isIncome) {
        if (lastIncomeAt == null || r.date.isAfter(lastIncomeAt)) lastIncomeAt = r.date;
        continue;
      }
      if (!r.date.isBefore(yesterday) && r.date.isBefore(today)) yesterdayExpenses++;
      final minor = await toBase(Money(r.amountMinor, CurrencyType.fromCode(r.currencyCode)));
      if (minor == null) continue;
      if (!r.date.isBefore(lastWeekStart) && r.date.isBefore(weekStart)) lastWeek += minor;
      if (!r.date.isBefore(monthStart) &&
          avgTicket != null &&
          avgTicket.isPositive &&
          minor * 10 < avgTicket.minor * 3) {
        smallSum += minor;
        smallCount++;
      }
    }
  } catch (_) {}

  MascotNamed? topExpense;
  Money? dailyAverage;
  int? dailyChange;
  int? weekendPercent;
  MascotNamed? frequentTag;
  int? savingsRate;
  int? recurringPercent;
  MascotNamed? budgetSuggestion;
  var untaggedPercent = 0;
  final topFamilies = <MascotNamed>[];
  if (report != null) {
    final h = report.habits;
    final t = h.topExpense;
    if (t != null && t.amount.isPositive) {
      topExpense = MascotNamed(id: t.id, name: t.description.trim(), amount: t.amount);
    }
    if (h.dailyAverage.isPositive) {
      dailyAverage = h.dailyAverage;
      final b = h.baselineDailyAverage;
      if (b != null && b.isPositive && now.day >= 7) {
        dailyChange = ((h.dailyAverage.minor - b.minor) * 100 / b.minor).round();
      }
    }
    final w = h.weekdayAverages;
    if (w.length == 7 && now.day >= 14) {
      final weekdays = (w[0] + w[1] + w[2] + w[3] + w[4]) / 5;
      final weekend = (w[5] + w[6]) / 2;
      if (weekdays > 0) weekendPercent = ((weekend - weekdays) * 100 / weekdays).round();
    }
    final roots = report.spending.roots;
    if (roots.isNotEmpty) {
      final byCount = [...roots]..sort((a, b) => b.count.compareTo(a.count));
      frequentTag = MascotNamed(id: byCount.first.tagId, name: byCount.first.displayName, count: byCount.first.count);
      final expense = report.current.expense.minor;
      final byAmount = [...roots]..sort((a, b) => b.amount.minor.compareTo(a.amount.minor));
      for (final n in byAmount.take(3)) {
        if (!n.amount.isPositive || expense <= 0) continue;
        topFamilies.add(MascotNamed(
          id: n.tagId,
          name: n.displayName,
          amount: n.amount,
          count: (n.amount.minor * 100 / expense).round(),
        ));
      }
      final topTag = byAmount.first;
      final watched = budgets.any((p) => p.budget.tagIds.contains(topTag.tagId));
      final share = expense <= 0 ? 0 : (topTag.amount.minor * 100 / expense).round();
      if (!watched && share >= 25 && report.current.expenseCount >= 8) {
        budgetSuggestion = MascotNamed(id: topTag.tagId, name: topTag.displayName, count: share);
      }
    }
    final rate = report.current.savingsRate;
    if (rate != null) savingsRate = (rate * 100).round();
    if (report.current.expense.isPositive && h.recurring.isPositive) {
      recurringPercent = (h.recurring.minor * 100 / report.current.expense.minor).round();
    }
    final count = report.current.expenseCount;
    if (count > 0) untaggedPercent = (report.spending.untaggedCount * 100 / count).round();
  }

  MascotNamed? owedToMe;
  if (debts.owedToMeBase.isPositive && debts.openLent.isNotEmpty) {
    final topLent = [...debts.openLent]..sort((a, b) => b.remaining.minor.compareTo(a.remaining.minor));
    owedToMe = MascotNamed(id: topLent.first.debt.id, name: topLent.first.person.name, amount: debts.owedToMeBase);
  }
  final negativeWallet = dashboard.wallets.where((w) => w.includeInTotal && w.balance.isNegative).firstOrNull;
  final noDue = debts.openBorrowed.where((d) => d.debt.dueDate == null).firstOrNull;

  final last = activity.lastRecordAt;
  final first = activity.firstUseAt;
  return MascotSignals(
    now: now,
    base: base,
    monthIncome: report?.current.income ?? zero,
    monthExpense: report?.current.expense ?? zero,
    monthExpenseCount: report?.current.expenseCount ?? 0,
    avgMonthlyExpense: avgExpense,
    avgMonthlyIncome: avgIncome,
    reserveMonths: reserve,
    overBudget: overList.isEmpty ? null : budgetSignal(overList.first, over: true),
    overBudgetCount: overList.length,
    nearBudget: nearList.isEmpty ? null : budgetSignal(nearList.first, over: false),
    budgetCount: budgets.length,
    overdueDebt: overdue,
    overdueCount: debts.overdueCount,
    dueSoonDebt: dueSoon,
    chargeSoon: charge == null
        ? null
        : MascotChargeSignal(
            id: charge.$1.id,
            name: charge.$1.description.trim(),
            amount: Money(charge.$1.amountMinor ?? 0, charge.$1.currency),
            days: charge.$2,
          ),
    activeSubscriptions: rules.where((r) => r.isActive && r.deletedAt == null).length,
    daysSinceLastRecord: last == null ? null : MascotSignals.calendarDays(last, now),
    recordCount: activity.recordCount,
    daysWithWumbi: first == null ? null : MascotSignals.calendarDays(first, now),
    prevVisitAt: prevVisit,
    recordsSinceVisit: activity.recordsSince,
    mover: mover,
    peakWeekday: peak == null ? null : mascotWeekdayName(peak),
    untaggedCount: report?.spending.untaggedCount ?? 0,
    bestMonthSaved: best,
    recordsToday: recordsToday,
    streakDays: streak,
    topExpense: topExpense,
    dailyAverage: dailyAverage,
    dailyChangePercent: dailyChange,
    weekendPercent: weekendPercent,
    frequentTag: frequentTag,
    smallSpends: smallCount >= 10 ? Money(smallSum, base) : null,
    savingsRatePercent: savingsRate,
    forecast: report?.forecast,
    owedToMe: owedToMe,
    negativeWallet: negativeWallet == null ? null : MascotNamed(id: negativeWallet.id, name: negativeWallet.name),
    noRateCodes: dashboard.unconvertible.isEmpty ? null : dashboard.unconvertible.map((c) => c.code).join(', '),
    subsMonthly: subsMonthly > 0 ? Money(subsMonthly, base) : null,
    recurringPercent: recurringPercent,
    lastWeekExpense: lastWeek > 0 ? Money(lastWeek, base) : null,
    borrowedNoDue: noDue == null ? null : MascotNamed(id: noDue.debt.id, name: noDue.person.name),
    budgetSuggestion: budgetSuggestion,
    untaggedPercent: untaggedPercent,
    walletCount: dashboard.walletCount,
    daysSinceIncome: lastIncomeAt == null ? null : MascotSignals.calendarDays(lastIncomeAt, now),
    noSpendYesterday: yesterdayExpenses == 0 && activity.recordCount >= 10 && times.isNotEmpty,
    topFamilies: topFamilies,
  );
});

/// Last month's savings when it beat each of the 5 months before it (at
/// least 3 of them with data).
Money? _bestLastMonth(ProgressReport r, DateTime now) {
  final lastStart = DateTime(now.year, now.month - 1);
  ProgressPeriod? last;
  for (final p in r.history) {
    if (p.start == lastStart) last = p;
  }
  if (last == null || !last.net.isPositive) return null;
  final saved = last.net;
  final before = r.history.where((p) {
    final back = ProgressGranularity.month.between(p.start, lastStart);
    return back >= 1 && back <= 5 && !p.isEmpty;
  }).toList();
  if (before.length < 3) return null;
  return before.every((p) => p.net.minor < saved.minor) ? saved : null;
}

// --------------------------------------------------------------- dashboard

/// What the dashboard hamster says now (spec §3.3). The hamster picks by
/// itself: a new thought each session and each time the dashboard comes
/// back on top (after [minShow]); warnings hold while they last. Every
/// thought carries its own emotion.
final mascotDashboardProvider =
    NotifierProvider.autoDispose<MascotDashboardController, MascotMessage?>(MascotDashboardController.new);

class MascotDashboardController extends Notifier<MascotMessage?> {
  /// A thought stays at least this long before a return moves on.
  static const Duration minShow = Duration(seconds: 40);

  int _session = -1;
  String? _pickedId;
  DateTime? _pickedAt;
  final Set<String> _skipped = {};

  @override
  MascotMessage? build() {
    final signals = ref.watch(mascotSignalsProvider).value;
    final memory = ref.watch(mascotMemoryProvider).value;
    final session = ref.watch(mascotSessionProvider);
    if (signals == null || memory == null) return stateOrNull;
    if (session != _session) {
      _session = session;
      _pickedId = null;
      _skipped.clear();
    }
    return _compute(signals, memory);
  }

  MascotMessage _compute(MascotSignals signals, MascotMemory memory) {
    // Warnings reword per session and per day.
    final candidates = MascotBrain.dashboard(signals, variant: _session + signals.now.day);
    final picked = MascotBrain.select(
      candidates,
      memory: memory,
      now: signals.now,
      stickyId: _pickedId,
      skipped: _skipped,
    );
    if (picked.id != _pickedId) {
      _pickedId = picked.id;
      _pickedAt = DateTime.now();
      // Remember it was said (after this build: it changes the memory).
      Future.microtask(() {
        if (ref.mounted) ref.read(mascotMemoryProvider.notifier).markShown(picked);
      });
    }
    return picked;
  }

  /// The dashboard is back on top: the hamster moves on to its next thought
  /// (warnings stay until solved).
  void rotate() {
    final current = state;
    final signals = ref.read(mascotSignalsProvider).value;
    final memory = ref.read(mascotMemoryProvider).value;
    if (current == null || signals == null || memory == null) return;
    if (current.tier == MascotTier.warning) return;
    final at = _pickedAt;
    if (at != null && DateTime.now().difference(at) < minShow) return;
    _skipped.add(current.id);
    _pickedId = null;
    state = _compute(signals, memory);
  }
}

/// Whether the hamster speaks now: Settings → "Wumbi talks" and no
/// long-press "quiet today".
final mascotSpeaksProvider = Provider.autoDispose<bool>((ref) {
  final talks = ref.watch(mascotTalksProvider);
  final quiet = ref.watch(mascotMemoryProvider.select((m) => m.value?.isQuiet(DateTime.now()) ?? false));
  return talks && !quiet;
});

