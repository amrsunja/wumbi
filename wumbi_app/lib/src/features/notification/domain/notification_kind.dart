/// What the user switches on or off in Settings → Notifications.
enum NotificationCategory {
  /// Subscriptions, planned payments, payday, a wallet about to go negative.
  payments,

  /// Due dates and late returns, both ways.
  debts,

  /// Evening "log today" nudges, streaks and the hello after a silence.
  habits,

  /// Sunday evening: what the week cost.
  recaps,

  /// Morning: what can be spent today and stay within a budget. Opt-in.
  morningBudget,
}

/// The only two moments of the day a notification may arrive. Nothing is
/// ever delivered at night or at a random minute.
enum NotificationSlot { morning, evening }

/// Every notification Wumbi can send. [priority] decides which one wins when
/// several land in the same slot (the others become "+N more inside").
enum NotificationKind {
  overdraftRisk(NotificationCategory.payments, NotificationSlot.morning, 100, lateFallback: true),
  debtOverdue(NotificationCategory.debts, NotificationSlot.morning, 85),
  debtDueToday(NotificationCategory.debts, NotificationSlot.morning, 80, lateFallback: true),
  chargeTomorrow(NotificationCategory.payments, NotificationSlot.morning, 70),
  debtDueSoon(NotificationCategory.debts, NotificationSlot.morning, 65),
  incomeToday(NotificationCategory.payments, NotificationSlot.morning, 60),
  plannedToday(NotificationCategory.payments, NotificationSlot.morning, 55),
  debtForgotten(NotificationCategory.debts, NotificationSlot.morning, 50),
  safeToSpend(NotificationCategory.morningBudget, NotificationSlot.morning, 40),
  weeklyRecap(NotificationCategory.recaps, NotificationSlot.evening, 30),
  streakReminder(NotificationCategory.habits, NotificationSlot.evening, 27),
  logReminder(NotificationCategory.habits, NotificationSlot.evening, 25),
  winBack(NotificationCategory.habits, NotificationSlot.evening, 20);

  const NotificationKind(this.category, this.slot, this.priority, {this.lateFallback = false});

  final NotificationCategory category;
  final NotificationSlot slot;
  final int priority;

  /// When today's morning is already gone, deliver it this evening instead
  /// of dropping it (worth hearing the same day).
  final bool lateFallback;

  /// Money matters are counted in the "+N more inside" line of a slot; a
  /// habit nudge never is.
  bool get isMoney => category == NotificationCategory.payments || category == NotificationCategory.debts;
}
