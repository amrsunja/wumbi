import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';

/// A budget worth talking about.
class MascotBudgetSignal {
  const MascotBudgetSignal({required this.id, required this.name, required this.amount, required this.percent});

  final String id;
  final String name;

  /// Over: by how much; near: what is left (budget currency).
  final Money amount;

  /// Spent / limit, %.
  final int percent;
}

/// A debt worth talking about.
class MascotDebtSignal {
  const MascotDebtSignal({required this.id, required this.name, required this.days});

  final String id;
  final String name;

  /// Overdue: days past the due date (≥ 1). Due soon: days left (0–3).
  final int days;
}

/// A subscription that charges soon.
class MascotChargeSignal {
  const MascotChargeSignal({required this.id, required this.name, required this.amount, required this.days});

  final String id;

  /// Empty when the rule has no description.
  final String name;
  final Money amount;

  /// 0 today, 1 tomorrow, 2–3 soon.
  final int days;
}

/// The spending family that grew the most against last month (to date).
class MascotMoverSignal {
  const MascotMoverSignal({required this.tagId, required this.name, required this.percent});

  final String tagId;
  final String name;
  final int percent;
}

/// Something with an id and a name the hamster can point at (a wallet, a
/// debt, a tag) and the one number about it.
class MascotNamed {
  const MascotNamed({required this.id, required this.name, this.count = 0, this.amount});

  final String id;
  final String name;
  final int count;
  final Money? amount;
}

/// Everything the dashboard brain looks at (spec §3.1), already reduced to
/// plain values in the base currency. Built by `mascotSignalsProvider`;
/// pure input for `MascotBrain`.
class MascotSignals {
  const MascotSignals({
    required this.now,
    required this.base,
    required this.monthIncome,
    required this.monthExpense,
    this.monthExpenseCount = 0,
    this.avgMonthlyExpense,
    this.avgMonthlyIncome,
    this.reserveMonths,
    this.overBudget,
    this.overBudgetCount = 0,
    this.nearBudget,
    this.budgetCount = 0,
    this.overdueDebt,
    this.overdueCount = 0,
    this.dueSoonDebt,
    this.chargeSoon,
    this.activeSubscriptions = 0,
    this.daysSinceLastRecord,
    this.recordCount = 0,
    this.daysWithWumbi,
    this.prevVisitAt,
    this.recordsSinceVisit = 0,
    this.mover,
    this.peakWeekday,
    this.untaggedCount = 0,
    this.bestMonthSaved,
    this.recordsToday = 0,
    this.streakDays = 0,
    this.topExpense,
    this.dailyAverage,
    this.dailyChangePercent,
    this.weekendPercent,
    this.frequentTag,
    this.smallSpends,
    this.savingsRatePercent,
    this.forecast,
    this.owedToMe,
    this.negativeWallet,
    this.noRateCodes,
    this.subsMonthly,
    this.recurringPercent,
    this.lastWeekExpense,
    this.borrowedNoDue,
    this.budgetSuggestion,
    this.untaggedPercent = 0,
    this.walletCount = 1,
    this.daysSinceIncome,
    this.noSpendYesterday = false,
    this.topFamilies = const [],
  });

  /// Wallets the user has.
  final int walletCount;

  /// Days since the last income was recorded (within ~5 weeks), null if none.
  final int? daysSinceIncome;

  /// Yesterday had no expense at all (and the user records regularly).
  final bool noSpendYesterday;

  /// This month's biggest spending families, biggest first:
  /// [MascotNamed.amount] = spent, [MascotNamed.count] = share of spending (%).
  final List<MascotNamed> topFamilies;

  /// Rows the user entered today (created today).
  final int recordsToday;

  /// Consecutive days (ending today or yesterday) with at least one record.
  final int streakDays;

  /// Biggest single expense this month (name may be empty).
  final MascotNamed? topExpense;

  /// Average spend per day this month, and its change against the usual
  /// daily average (%, negative = less).
  final Money? dailyAverage;
  final int? dailyChangePercent;

  /// How much more an average weekend day costs than a weekday (%).
  final int? weekendPercent;

  /// Spending family used most often this month ([MascotNamed.count] times).
  final MascotNamed? frequentTag;

  /// Sum of this month's small purchases (each well under a usual one),
  /// when there were many of them.
  final Money? smallSpends;

  /// Share of this month's income kept (%), when there is income.
  final int? savingsRatePercent;

  /// Expected spending at the end of this month.
  final Money? forecast;

  /// Owed to the user; [MascotNamed.name] = who owes the most.
  final MascotNamed? owedToMe;

  /// A counted wallet below zero.
  final MascotNamed? negativeWallet;

  /// Currencies left out of the total (no cached rate), "USD, GBP".
  final String? noRateCodes;

  /// Active expense subscriptions per month (base currency).
  final Money? subsMonthly;

  /// Share of this month's spending that came from recurring rules (%).
  final int? recurringPercent;

  /// Spending of the previous Monday–Sunday.
  final Money? lastWeekExpense;

  /// An open "I owe" debt without a due date.
  final MascotNamed? borrowedNoDue;

  /// A big spending family no budget watches ([MascotNamed.count] = %).
  final MascotNamed? budgetSuggestion;

  /// Share of this month's expenses without a tag (%).
  final int untaggedPercent;

  /// Days left in this month after today.
  int get daysLeftInMonth => DateTime(now.year, now.month + 1, 0).day - now.day;

  final DateTime now;
  final CurrencyType base;

  /// Since the 1st (transfers and debt money excluded, like Progress).
  final Money monthIncome;
  final Money monthExpense;
  final int monthExpenseCount;

  /// The user's own base: mean of the last complete months (≤ 3).
  final Money? avgMonthlyExpense;
  final Money? avgMonthlyIncome;

  /// (Counted balance − obligations of the next 30 days) / average monthly
  /// spending. `< 0.5` low, `0.5–3` fine, `≥ 3` full cheeks. Null without a
  /// spending base.
  final double? reserveMonths;

  final MascotBudgetSignal? overBudget;
  final int overBudgetCount;

  /// ≥ 80 % spent while < 80 % of the period has passed.
  final MascotBudgetSignal? nearBudget;
  final int budgetCount;

  final MascotDebtSignal? overdueDebt;
  final int overdueCount;
  final MascotDebtSignal? dueSoonDebt;
  final MascotChargeSignal? chargeSoon;
  final int activeSubscriptions;

  /// Null when nothing was ever recorded.
  final int? daysSinceLastRecord;
  final int recordCount;
  final int? daysWithWumbi;
  final DateTime? prevVisitAt;
  final int recordsSinceVisit;

  final MascotMoverSignal? mover;

  /// Weekday name whose average spend is at least twice the others'.
  final String? peakWeekday;
  final int untaggedCount;

  /// Last month's savings when it was the best of the last six.
  final Money? bestMonthSaved;

  Money get monthFlow => monthIncome - monthExpense;

  int? get daysSincePrevVisit {
    final p = prevVisitAt;
    if (p == null) return null;
    return calendarDays(p, now);
  }

  bool get firstOpenToday {
    final p = prevVisitAt;
    return p == null || calendarDays(p, now) > 0;
  }

  /// Whole calendar days from [from] to [to] (local dates).
  static int calendarDays(DateTime from, DateTime to) =>
      DateTime.utc(to.year, to.month, to.day).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
}
