import '../../../core/design_system/app_ui.dart';
import '../../../core/money/money.dart';

/// Every sentence the hamster can say. The brain picks a phrase and its
/// arguments; `MascotPhrases` turns it into localised text (spec §3.4: ≤ 2
/// lines, one number at most, first person, warm, never blaming).
enum MascotPhrase {
  // dashboard — warnings
  debtOverdue,
  debtOverdueNudge,
  budgetOver,
  budgetOverBy,
  budgetNearLeft,
  budgetNearPercent,
  sleepDays,
  sleepQuiet,
  sighMonth,
  sighAhead,
  // since the last visit
  welcomeBack,
  // events
  eventReserve,
  eventBestMonth,
  eventDays,
  eventRecords,
  // insights
  chargeToday,
  chargeTomorrow,
  chargeSoon,
  debtDueToday,
  debtDueTomorrow,
  debtDueSoon,
  insightMover,
  insightUntagged,
  insightPeakDay,
  insightReserve,
  // tips
  tipBudget,
  tipSubscriptions,
  // greeting / summary
  greetingMorning,
  greetingAfternoon,
  greetingEvening,
  reserveFull,
  flowUp,
  flowDown,
  allCalm,
  allForNow,
  quietToday,
  // reactions
  reactionIncome,
  reactionBigIncome,
  reactionTransfer,
  reactionLent,
  reactionDebtClosed,
  reactionForgiven,
  reactionFirstWallet,
  reactionBudget,
  // screens
  walletNegative,
  walletDown,
  walletUp,
  walletSleeping,
  walletCalm,
  budgetsOver,
  budgetsNear,
  budgetsCalm,
  budgetDetailOver,
  budgetDetailPace,
  budgetDetailWithin,
  budgetDetailCalm,
  debtsOverdue,
  debtsAllClosed,
  debtsTracking,
  debtDetailOverdue,
  debtDetailLent,
  debtDetailDue,
  subsSpinning,
  tagsTop,
  tagUp,
  tagDown,
  progressSaved,
  progressOver,
  progressOverTag,
  progressForecast,
  progressCounting,
  // evening story — a whole day away
  eveningWaited,
  eveningMissed,
  eveningLog,
  eveningCount,
  // insights v2
  insightTopExpense,
  insightTopExpenseAmount,
  insightDailyAverage,
  insightDailyBelow,
  insightDailyAbove,
  insightWeekend,
  insightFrequentTag,
  insightSmallSpends,
  insightSavingsRate,
  insightNoIncome,
  insightForecastOver,
  insightForecastUnder,
  insightOwedToMe,
  insightNegativeWallet,
  insightNoRate,
  eventStreak,
  // tips v2
  tipSubsYearly,
  tipRecurringShare,
  tipNewMonth,
  tipMondayRecap,
  tipMonthEnd,
  tipTags,
  tipDebtDueDate,
  tipBudgetFor,
  // jokes
  jokeFriday,
  jokeLateNight,
  jokeCheeks,
  jokeTrees,
  jokeTwice,
  jokeSecret,
  // screen tips
  screenWalletFilter,
  screenWalletSwitch,
  screenWalletLimit,
  screenBudgetsRollover,
  screenBudgetsTags,
  screenBudgetPeriods,
  screenDebtsDue,
  screenDebtsQuick,
  screenSubsPause,
  screenTagsNest,
  screenTagsMap,
  screenTagRename,
  screenProgressBaseline,
  // answers
  ansSpentToday,
  ansNothingToday,
  ansSpentYesterday,
  ansNothingYesterday,
  ansSpentWeek,
  ansSpentMonth,
  ansNoExpenses,
  ansUpcoming,
  ansNothingUpcoming,
  ansOwed,
  ansNobodyOwes,
  ansReserveLow,
  ansReserveUnknown,
  // v3 — what people most want to know about their seeds
  ansWhere,
  ansWhereOne,
  ansWhereUntagged,
  tipRainyDay,
  tipPayYourselfFirst,
  insightIncomeUp,
  insightTagYearly,
  tipTreat,
  tipFutureSelf,
  insightNoSpendYesterday,
}

/// What the user can ask the hamster (quick replies on the stage).
enum MascotQuestion { today, yesterday, week, month, where, biggest, budgets, upcoming, owed, reserve, tip, joke }

/// A phrase with its arguments. Which ones a phrase reads is fixed by
/// `MascotPhrases`; [then] appends a second sentence (greeting + summary).
class MascotLine {
  const MascotLine(this.phrase, {this.name, this.name2, this.amount, this.amount2, this.count, this.date, this.then});

  final MascotPhrase phrase;

  /// Budget / tag / person / subscription name, or a weekday name.
  final String? name;

  /// A second name, in answers only ("…then “Cafe”").
  final String? name2;
  final Money? amount;

  /// A second amount, in answers only ("spent X, earned Y").
  final Money? amount2;

  /// Days, percent, months or a record count — the one number.
  final int? count;
  final DateTime? date;
  final MascotLine? then;

  /// Identity of what is said (memory hash, widget keys).
  String get signature =>
      '${phrase.name}|$name|$name2|${amount?.minor}${amount?.currency.code}|${amount2?.minor}|$count|${date?.toIso8601String()}|${then?.signature}';
}

/// Priority buckets, highest first (spec §3.2).
enum MascotTier { reaction, warning, event, sinceVisit, insight, tip, joke, greeting, summary }

enum MascotActionKind {
  openDebt,
  openDebts,
  openBudget,
  openBudgets,
  newBudget,
  openProgress,
  addTransaction,
  openSubscriptions,
  openWallet,
}

/// The one thing a bad (or useful) piece of news offers to do.
class MascotAction {
  const MascotAction(this.kind, [this.id]);

  final MascotActionKind kind;
  final String? id;
}

/// A further beat of a little story: the hamster changes emotion and says
/// the next line by itself (e.g. impatient → sad → "let's log today").
class MascotStep {
  const MascotStep(this.mood, this.line, {this.action});

  final WumbiMood mood;
  final MascotLine line;
  final MascotAction? action;
}

/// One thing the hamster can say right now.
class MascotMessage {
  const MascotMessage({
    required this.id,
    required this.tier,
    required this.mood,
    this.line,
    this.action,
    String? hash,
    this.cooldown,
    this.steps = const [],
    this.afterMood,
  }) : _hash = hash;

  /// Beats played after [line], each with its own emotion.
  final List<MascotStep> steps;

  /// The face it settles into a moment after speaking, without a new line
  /// (e.g. sorting the seeds → a kind smile).
  final WumbiMood? afterMood;

  /// Stable meaning ("warn.budgetOver", "insight.mover") — the memory key.
  final String id;
  final MascotTier tier;
  final WumbiMood mood;

  /// Null: emotion only (e.g. an expense was tossed into the pouch).
  final MascotLine? line;
  final MascotAction? action;
  final String? _hash;

  /// Minimum gap before the same meaning on the same data comes back. Null:
  /// once per [hash] (events, "since your last visit").
  final Duration? cooldown;

  /// The data behind the message; a different hash may be said again.
  String get hash => _hash ?? line?.signature ?? id;
}
