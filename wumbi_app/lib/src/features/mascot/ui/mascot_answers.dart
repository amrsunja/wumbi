import 'dart:math' as math;

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/providers/data/fx_provider.dart';
import '../../../core/providers/local/sqlite_database_provider.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../progress/data/progress_local_datasource.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../subscription/ui/subscriptions_provider.dart';
import '../domain/mascot_brain.dart';
import '../domain/mascot_message.dart';
import '../domain/mascot_signals.dart';
import 'mascot_providers.dart';

/// What the hamster replies: an emotion that fits, a line, maybe an action.
class MascotAnswer {
  const MascotAnswer(this.mood, this.line, {this.action, this.afterMood});

  final WumbiMood mood;

  /// The face it settles into ~2.5 s after answering.
  final WumbiMood? afterMood;
  final MascotLine line;
  final MascotAction? action;
}

/// Answers the quick replies from the user's own numbers (base currency).
class MascotAnswers {
  MascotAnswers(this.ref);

  final WidgetRef ref;
  final math.Random _random = math.Random();

  /// Jokes the hamster tells on request: its face, the line, and the face
  /// it settles into after.
  static const List<(WumbiMood, MascotPhrase, WumbiMood?)> jokes = [
    (WumbiMood.cheeksStuffed, MascotPhrase.jokeCheeks, null),
    (WumbiMood.reserveFull, MascotPhrase.jokeTrees, null),
    (WumbiMood.sorting, MascotPhrase.jokeTwice, WumbiMood.kindly),
    (WumbiMood.hush, MascotPhrase.jokeSecret, null),
  ];

  Future<MascotAnswer> answer(MascotQuestion q) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    MascotSignals? signals;
    try {
      signals = await ref.read(mascotSignalsProvider.future);
    } catch (_) {}

    switch (q) {
      case MascotQuestion.today:
        final t = await _spending(today, today.add(const Duration(days: 1)));
        return t.count == 0
            ? const MascotAnswer(WumbiMood.happy, MascotLine(MascotPhrase.ansNothingToday))
            : MascotAnswer(WumbiMood.counting, MascotLine(MascotPhrase.ansSpentToday, amount: t.expense, count: t.count));
      case MascotQuestion.yesterday:
        final y = today.subtract(const Duration(days: 1));
        final t = await _spending(y, today);
        return t.count == 0
            ? const MascotAnswer(WumbiMood.celebrate, MascotLine(MascotPhrase.ansNothingYesterday))
            : MascotAnswer(WumbiMood.counting, MascotLine(MascotPhrase.ansSpentYesterday, amount: t.expense, count: t.count));
      case MascotQuestion.week:
        final start = today.subtract(Duration(days: now.weekday - 1));
        final t = await _spending(start, today.add(const Duration(days: 1)));
        return MascotAnswer(WumbiMood.counting, MascotLine(MascotPhrase.ansSpentWeek, amount: t.expense),
            action: const MascotAction(MascotActionKind.openProgress));
      case MascotQuestion.month:
        final t = await _spending(DateTime(now.year, now.month), today.add(const Duration(days: 1)));
        final up = t.income.minor >= t.expense.minor && t.income.isPositive;
        return MascotAnswer(
          up ? WumbiMood.happy : WumbiMood.counting,
          MascotLine(MascotPhrase.ansSpentMonth, amount: t.expense, amount2: t.income),
          action: const MascotAction(MascotActionKind.openProgress),
        );
      case MascotQuestion.where:
        final s = signals;
        final families = s?.topFamilies ?? const <MascotNamed>[];
        if (s != null && s.untaggedPercent >= 50 && s.monthExpenseCount >= 5) {
          return MascotAnswer(WumbiMood.sorting, MascotLine(MascotPhrase.ansWhereUntagged, count: s.untaggedPercent),
              action: const MascotAction(MascotActionKind.openProgress));
        }
        if (families.isEmpty) return const MascotAnswer(WumbiMood.calm, MascotLine(MascotPhrase.ansNoExpenses));
        final first = families.first;
        return MascotAnswer(
          WumbiMood.thinking,
          families.length == 1
              ? MascotLine(MascotPhrase.ansWhereOne, name: first.name, count: first.count)
              : MascotLine(MascotPhrase.ansWhere, name: first.name, count: first.count, name2: families[1].name),
          action: const MascotAction(MascotActionKind.openProgress),
        );
      case MascotQuestion.biggest:
        final top = signals?.topExpense;
        final amount = top?.amount;
        if (top == null || amount == null) {
          return const MascotAnswer(WumbiMood.calm, MascotLine(MascotPhrase.ansNoExpenses));
        }
        return MascotAnswer(
          WumbiMood.thinking,
          top.name.isEmpty
              ? MascotLine(MascotPhrase.insightTopExpenseAmount, amount: amount)
              : MascotLine(MascotPhrase.insightTopExpense, name: top.name, amount: amount),
          action: const MascotAction(MascotActionKind.openProgress),
        );
      case MascotQuestion.budgets:
        final s = signals;
        if (s == null || s.budgetCount == 0) {
          return const MascotAnswer(WumbiMood.kindly, MascotLine(MascotPhrase.tipBudget),
              action: MascotAction(MascotActionKind.newBudget));
        }
        final over = s.overBudget;
        if (over != null) {
          return MascotAnswer(WumbiMood.stop, MascotLine(MascotPhrase.budgetOverBy, name: over.name, amount: over.amount),
              action: MascotAction(MascotActionKind.openBudget, over.id));
        }
        final near = s.nearBudget;
        if (near != null) {
          return MascotAnswer(WumbiMood.nervous, MascotLine(MascotPhrase.budgetNearLeft, name: near.name, amount: near.amount),
              action: MascotAction(MascotActionKind.openBudget, near.id));
        }
        return const MascotAnswer(WumbiMood.thumbsUp, MascotLine(MascotPhrase.budgetsCalm),
            action: MascotAction(MascotActionKind.openBudgets));
      case MascotQuestion.upcoming:
        final up = await _upcoming(now);
        return up.count == 0
            ? const MascotAnswer(WumbiMood.calm, MascotLine(MascotPhrase.ansNothingUpcoming))
            : MascotAnswer(WumbiMood.calendar, MascotLine(MascotPhrase.ansUpcoming, amount: up.amount, count: up.count),
                action: const MascotAction(MascotActionKind.openSubscriptions));
      case MascotQuestion.owed:
        final owed = signals?.owedToMe;
        final amount = owed?.amount;
        if (owed == null || amount == null) {
          return const MascotAnswer(WumbiMood.thumbsUp, MascotLine(MascotPhrase.ansNobodyOwes));
        }
        return MascotAnswer(WumbiMood.alert, MascotLine(MascotPhrase.ansOwed, amount: amount, name: owed.name),
            action: const MascotAction(MascotActionKind.openDebts));
      case MascotQuestion.reserve:
        final r = signals?.reserveMonths;
        if (r == null) return const MascotAnswer(WumbiMood.shrug, MascotLine(MascotPhrase.ansReserveUnknown));
        // Determined face: "let's fill those cheeks together".
        if (r < 1) return const MascotAnswer(WumbiMood.saving, MascotLine(MascotPhrase.ansReserveLow));
        if (r >= 3) {
          return MascotAnswer(WumbiMood.reserveFull, MascotLine(MascotPhrase.reserveFull, count: r.floor()));
        }
        return MascotAnswer(WumbiMood.calm, MascotLine(MascotPhrase.insightReserve, count: r.floor()));
      case MascotQuestion.tip:
        final s = signals;
        final pool = s == null
            ? const <MascotMessage>[]
            : MascotBrain.dashboard(s)
                .where((m) => (m.tier == MascotTier.insight || m.tier == MascotTier.tip) && m.line != null)
                .toList();
        if (pool.isEmpty) return const MascotAnswer(WumbiMood.sorting, MascotLine(MascotPhrase.tipTags));
        final m = pool[_random.nextInt(pool.length)];
        return MascotAnswer(m.mood, m.line!, action: m.action, afterMood: m.afterMood);
      case MascotQuestion.joke:
        final j = jokes[_random.nextInt(jokes.length)];
        return MascotAnswer(j.$1, MascotLine(j.$2), afterMood: j.$3);
    }
  }

  /// Income / expense (posted, no transfers or debt money) in [start, end).
  Future<({Money expense, Money income, int count})> _spending(DateTime start, DateTime end) async {
    final base = ref.read(baseCurrencyProvider);
    final fx = ref.read(fxServiceProvider);
    var expense = 0;
    var income = 0;
    var count = 0;
    try {
      final rows = await const ProgressLocalDatasource().rows(ref.read(sqliteDataBaseProvider).db, start: start, end: end);
      final rates = <CurrencyType, double?>{};
      for (final r in rows) {
        final c = CurrencyType.fromCode(r.currencyCode);
        int? minor = r.amountMinor;
        if (c != base) {
          if (!rates.containsKey(c)) rates[c] = (await fx.cachedRate(c, base))?.rate;
          final rate = rates[c];
          minor = rate == null ? null : convertMinor(r.amountMinor, c, base, rate);
        }
        if (minor == null) continue;
        if (r.isIncome) {
          income += minor;
        } else {
          expense += minor;
          count++;
        }
      }
    } catch (_) {}
    return (expense: Money(expense, base), income: Money(income, base), count: count);
  }

  /// Subscriptions charging in the next 7 days.
  Future<({Money amount, int count})> _upcoming(DateTime now) async {
    final base = ref.read(baseCurrencyProvider);
    final fx = ref.read(fxServiceProvider);
    var total = 0;
    var count = 0;
    try {
      final rules = await ref.read(subscriptionsProvider.future);
      for (final r in rules) {
        if (!r.isActive || r.deletedAt != null || r.type != TransactionType.expense) continue;
        final days = MascotSignals.calendarDays(now, r.nextOccurrence);
        if (days < 0 || days > 7) continue;
        count++;
        final m = Money(r.amountMinor ?? 0, r.currency);
        if (m.currency == base) {
          total += m.minor;
        } else {
          final rate = (await fx.cachedRate(m.currency, base))?.rate;
          if (rate != null) total += convertMinor(m.minor, m.currency, base, rate);
        }
      }
    } catch (_) {}
    return (amount: Money(total, base), count: count);
  }
}

/// Quick replies each screen offers first (the rest follow as they are used).
abstract class MascotQuestions {
  static const List<MascotQuestion> dashboard = [
    MascotQuestion.today,
    MascotQuestion.where,
    MascotQuestion.tip,
    MascotQuestion.month,
    MascotQuestion.budgets,
    MascotQuestion.yesterday,
    MascotQuestion.upcoming,
    MascotQuestion.week,
    MascotQuestion.biggest,
    MascotQuestion.reserve,
    MascotQuestion.owed,
    MascotQuestion.joke,
  ];
  static const List<MascotQuestion> wallet = [
    MascotQuestion.today,
    MascotQuestion.week,
    MascotQuestion.month,
    MascotQuestion.tip,
    MascotQuestion.joke,
  ];
  static const List<MascotQuestion> budgets = [
    MascotQuestion.budgets,
    MascotQuestion.month,
    MascotQuestion.tip,
    MascotQuestion.joke,
  ];
  static const List<MascotQuestion> debts = [
    MascotQuestion.owed,
    MascotQuestion.upcoming,
    MascotQuestion.tip,
    MascotQuestion.joke,
  ];
  static const List<MascotQuestion> subscriptions = [
    MascotQuestion.upcoming,
    MascotQuestion.month,
    MascotQuestion.tip,
    MascotQuestion.joke,
  ];
  static const List<MascotQuestion> tags = [
    MascotQuestion.where,
    MascotQuestion.biggest,
    MascotQuestion.month,
    MascotQuestion.tip,
    MascotQuestion.joke,
  ];
  static const List<MascotQuestion> progress = [
    MascotQuestion.where,
    MascotQuestion.week,
    MascotQuestion.biggest,
    MascotQuestion.reserve,
    MascotQuestion.tip,
    MascotQuestion.joke,
  ];
}

