import 'dart:convert';

import 'notification_kind.dart';

/// Per-category switches (Settings → Notifications) plus the one-time ask.
/// Stored as JSON in `settings.notification_prefs`; the master switch stays
/// the existing `settings.notifications_enabled` column.
class NotificationPrefs {
  const NotificationPrefs({
    this.payments = true,
    this.debts = true,
    this.habits = true,
    this.recaps = true,
    this.morningBudget = false,
    this.askedAt,
  });

  final bool payments;
  final bool debts;
  final bool habits;
  final bool recaps;

  /// Opt-in: a daily message is a lot for people who only want alerts.
  final bool morningBudget;

  /// When the hamster asked for permission on the dashboard (asked once).
  final DateTime? askedAt;

  bool allows(NotificationCategory c) => switch (c) {
        NotificationCategory.payments => payments,
        NotificationCategory.debts => debts,
        NotificationCategory.habits => habits,
        NotificationCategory.recaps => recaps,
        NotificationCategory.morningBudget => morningBudget,
      };

  NotificationPrefs withCategory(NotificationCategory c, bool on) => NotificationPrefs(
        payments: c == NotificationCategory.payments ? on : payments,
        debts: c == NotificationCategory.debts ? on : debts,
        habits: c == NotificationCategory.habits ? on : habits,
        recaps: c == NotificationCategory.recaps ? on : recaps,
        morningBudget: c == NotificationCategory.morningBudget ? on : morningBudget,
        askedAt: askedAt,
      );

  NotificationPrefs asked(DateTime at) => NotificationPrefs(
        payments: payments,
        debts: debts,
        habits: habits,
        recaps: recaps,
        morningBudget: morningBudget,
        askedAt: at,
      );

  /// Null / broken JSON → defaults (a not-yet-migrated row reads the same).
  factory NotificationPrefs.decode(String? raw) {
    if (raw == null || raw.isEmpty) return const NotificationPrefs();
    try {
      final j = jsonDecode(raw) as Map<String, Object?>;
      final asked = j['askedAt'] as int?;
      return NotificationPrefs(
        payments: j['payments'] as bool? ?? true,
        debts: j['debts'] as bool? ?? true,
        habits: j['habits'] as bool? ?? true,
        recaps: j['recaps'] as bool? ?? true,
        morningBudget: j['morningBudget'] as bool? ?? false,
        askedAt: asked == null ? null : DateTime.fromMillisecondsSinceEpoch(asked),
      );
    } catch (_) {
      return const NotificationPrefs();
    }
  }

  String encode() => jsonEncode({
        'payments': payments,
        'debts': debts,
        'habits': habits,
        'recaps': recaps,
        'morningBudget': morningBudget,
        if (askedAt != null) 'askedAt': askedAt!.millisecondsSinceEpoch,
      });

  @override
  bool operator ==(Object other) =>
      other is NotificationPrefs &&
      other.payments == payments &&
      other.debts == debts &&
      other.habits == habits &&
      other.recaps == recaps &&
      other.morningBudget == morningBudget &&
      other.askedAt == askedAt;

  @override
  int get hashCode => Object.hash(payments, debts, habits, recaps, morningBudget, askedAt);
}
