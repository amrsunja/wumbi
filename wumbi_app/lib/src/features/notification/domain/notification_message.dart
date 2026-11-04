import '../../../core/design_system/app_ui.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/enums/debt_direction.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../mascot/domain/mascot_message.dart';
import 'notification_kind.dart';

/// What one notification says, before it is put into words. Each type picks
/// the hamster's emotion for its own situation and where a tap leads (the
/// same [MascotAction]s the in-app bubbles use). Texts live in
/// `NotificationCopy`, per language.
sealed class NotificationMessage {
  const NotificationMessage();

  NotificationKind get kind;
  WumbiMood get mood;
  MascotAction get action;

  /// Same thing, same day → same wording (re-planning many times a day
  /// must not reshuffle the text).
  String get key;

  /// [kind]'s priority, nudged per case (owing money outranks being owed).
  int get priority => kind.priority;
}

/// A wallet goes below zero once a planned payment leaves it.
final class OverdraftRiskMessage extends NotificationMessage {
  const OverdraftRiskMessage({
    required this.walletId,
    required this.walletName,
    required this.moveName,
    required this.moveAmount,
    required this.balanceAfter,
    required this.date,
  });

  final String walletId;
  final String walletName;
  final String moveName;
  final Money moveAmount;

  /// Negative.
  final Money balanceAfter;
  final DateTime date;

  @override
  NotificationKind get kind => NotificationKind.overdraftRisk;
  @override
  WumbiMood get mood => WumbiMood.nervous;
  @override
  MascotAction get action => MascotAction(MascotActionKind.openWallet, walletId);
  @override
  String get key => 'overdraft:$walletId';
}

/// A subscription / recurring expense charges tomorrow.
final class ChargeTomorrowMessage extends NotificationMessage {
  const ChargeTomorrowMessage({
    required this.ruleId,
    required this.name,
    required this.amount,
    this.walletName,
    this.variant = 0,
  });

  final String ruleId;
  final String name;
  final Money amount;
  final String? walletName;
  final int variant;

  @override
  NotificationKind get kind => NotificationKind.chargeTomorrow;
  @override
  WumbiMood get mood => WumbiMood.calendar;
  @override
  MascotAction get action => const MascotAction(MascotActionKind.openSubscriptions);
  @override
  String get key => 'charge:$ruleId';
}

/// A one-off planned (upcoming) row is dated today.
final class PlannedTodayMessage extends NotificationMessage {
  const PlannedTodayMessage({
    required this.transactionId,
    required this.type,
    required this.name,
    required this.amount,
    this.walletId,
  });

  final String transactionId;
  final TransactionType type;
  final String name;
  final Money amount;
  final String? walletId;

  bool get isIncome => type == TransactionType.income;

  @override
  NotificationKind get kind => NotificationKind.plannedToday;
  @override
  WumbiMood get mood => isIncome ? WumbiMood.catching : WumbiMood.handing;
  @override
  MascotAction get action => walletId == null
      ? const MascotAction(MascotActionKind.addTransaction)
      : MascotAction(MascotActionKind.openWallet, walletId);
  @override
  String get key => 'planned:$transactionId';
}

/// A recurring income (salary…) is due today.
final class IncomeTodayMessage extends NotificationMessage {
  const IncomeTodayMessage({required this.ruleId, required this.name, required this.amount, this.walletId});

  final String ruleId;
  final String name;
  final Money amount;
  final String? walletId;

  @override
  NotificationKind get kind => NotificationKind.incomeToday;
  @override
  WumbiMood get mood => WumbiMood.cheeksStuffed;
  @override
  MascotAction get action => walletId == null
      ? const MascotAction(MascotActionKind.openSubscriptions)
      : MascotAction(MascotActionKind.openWallet, walletId);
  @override
  String get key => 'income:$ruleId';
}

/// Shared shape of the debt reminders.
sealed class DebtMessage extends NotificationMessage {
  const DebtMessage({required this.debtId, required this.person, required this.direction, required this.remaining});

  final String debtId;
  final String person;
  final DebtDirection direction;
  final Money remaining;

  bool get owedToMe => direction == DebtDirection.lent;

  @override
  MascotAction get action => MascotAction(MascotActionKind.openDebt, debtId);
}

/// [days] (3) until the due date.
final class DebtDueSoonMessage extends DebtMessage {
  const DebtDueSoonMessage({
    required super.debtId,
    required super.person,
    required super.direction,
    required super.remaining,
    required this.days,
  });

  final int days;

  @override
  NotificationKind get kind => NotificationKind.debtDueSoon;
  @override
  WumbiMood get mood => owedToMe ? WumbiMood.kindly : WumbiMood.calendar;
  @override
  String get key => 'debtSoon:$debtId';
}

final class DebtDueTodayMessage extends DebtMessage {
  const DebtDueTodayMessage({
    required super.debtId,
    required super.person,
    required super.direction,
    required super.remaining,
  });

  @override
  NotificationKind get kind => NotificationKind.debtDueToday;

  /// Owed to me: the pouch is open, waiting. I owe: the bell.
  @override
  WumbiMood get mood => owedToMe ? WumbiMood.pouchOpen : WumbiMood.alert;
  @override
  int get priority => kind.priority + (owedToMe ? 0 : 5);
  @override
  String get key => 'debtToday:$debtId';
}

/// [days] past the due date.
final class DebtOverdueMessage extends DebtMessage {
  const DebtOverdueMessage({
    required super.debtId,
    required super.person,
    required super.direction,
    required super.remaining,
    required this.days,
  });

  final int days;

  @override
  NotificationKind get kind => NotificationKind.debtOverdue;
  @override
  WumbiMood get mood => owedToMe ? WumbiMood.impatient : WumbiMood.nervous;
  @override
  int get priority => kind.priority + (owedToMe ? 0 : 5);
  @override
  String get key => 'debtLate:$debtId:$days';
}

/// Money lent without a due date, [days] ago and still not back.
final class DebtForgottenMessage extends DebtMessage {
  const DebtForgottenMessage({
    required super.debtId,
    required super.person,
    required super.remaining,
    required this.days,
  }) : super(direction: DebtDirection.lent);

  final int days;

  @override
  NotificationKind get kind => NotificationKind.debtForgotten;
  @override
  WumbiMood get mood => WumbiMood.thinking;
  @override
  String get key => 'debtOld:$debtId:$days';
}

/// Morning: what one budget allows today ([perDay] null = nothing left).
final class SafeToSpendMessage extends NotificationMessage {
  const SafeToSpendMessage({required this.budgetId, required this.name, this.perDay});

  final String budgetId;
  final String name;
  final Money? perDay;

  bool get isEmpty => perDay == null;

  @override
  NotificationKind get kind => NotificationKind.safeToSpend;
  @override
  WumbiMood get mood => isEmpty ? WumbiMood.stop : WumbiMood.kindly;
  @override
  MascotAction get action => MascotAction(MascotActionKind.openBudget, budgetId);
  @override
  String get key => 'safe:$budgetId';
}

enum WeekTrend { less, more, same }

/// Sunday evening: the week's spending against the previous one.
final class WeeklyRecapMessage extends NotificationMessage {
  const WeeklyRecapMessage({required this.spent, required this.trend, this.percent = 0, this.topTag});

  final Money spent;
  final WeekTrend trend;

  /// |change| vs last week, %.
  final int percent;
  final String? topTag;

  @override
  NotificationKind get kind => NotificationKind.weeklyRecap;
  @override
  WumbiMood get mood => switch (trend) {
        WeekTrend.less => WumbiMood.proud,
        WeekTrend.more => WumbiMood.thinking,
        WeekTrend.same => WumbiMood.counting,
      };
  @override
  MascotAction get action => const MascotAction(MascotActionKind.openProgress);
  @override
  String get key => 'week';
}

/// Evening, nothing logged that day. Four wordings, each with its own face.
final class LogReminderMessage extends NotificationMessage {
  const LogReminderMessage({required this.variant});

  static const int variants = 4;

  final int variant;

  @override
  NotificationKind get kind => NotificationKind.logReminder;
  @override
  WumbiMood get mood => switch (variant % variants) {
        0 => WumbiMood.counting,
        1 => WumbiMood.impatient,
        2 => WumbiMood.searching,
        _ => WumbiMood.sigh,
      };
  @override
  MascotAction get action => const MascotAction(MascotActionKind.addTransaction);
  @override
  String get key => 'log';
}

/// Evening, a streak of [days] days to keep alive.
final class StreakReminderMessage extends NotificationMessage {
  const StreakReminderMessage({required this.days});

  final int days;

  @override
  NotificationKind get kind => NotificationKind.streakReminder;
  @override
  WumbiMood get mood => days >= 14 ? WumbiMood.victory : WumbiMood.proud;
  @override
  MascotAction get action => const MascotAction(MascotActionKind.addTransaction);
  @override
  String get key => 'streak';
}

enum WinBackStage {
  /// Three quiet days: it misses you.
  missYou,

  /// A quiet week: it fell asleep. The last one — then silence.
  asleep,
}

final class WinBackMessage extends NotificationMessage {
  const WinBackMessage({required this.stage});

  final WinBackStage stage;

  @override
  NotificationKind get kind => NotificationKind.winBack;
  @override
  WumbiMood get mood => stage == WinBackStage.missYou ? WumbiMood.sad : WumbiMood.sleep;
  @override
  MascotAction get action => const MascotAction(MascotActionKind.addTransaction);
  @override
  String get key => 'winBack:${stage.name}';
}
