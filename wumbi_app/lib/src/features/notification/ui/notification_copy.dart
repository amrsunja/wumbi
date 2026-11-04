import 'package:intl/intl.dart';

import '../../../core/locale/l10n.dart';
import '../domain/notification_message.dart';
import '../domain/notification_pacer.dart';

/// A notification in words.
class NotificationText {
  const NotificationText(this.title, this.body);

  final String title;
  final String body;
}

/// Every notification sentence, in the language passed in (not the one on
/// screen: plans are rebuilt in the new language when it changes). Written
/// per language in the arb files, in the hamster's voice — like
/// `MascotPhrases` for the in-app bubbles.
abstract class NotificationCopy {
  static NotificationText of(AppLocale l10n, ScheduledNotification n) {
    final t = message(l10n, n.message);
    if (n.extraCount <= 0) return t;
    return NotificationText(t.title, '${t.body}\n${l10n.notif_more(n.extraCount)}');
  }

  static NotificationText message(AppLocale l10n, NotificationMessage m) {
    String or(String name, String fallback) => name.isEmpty ? fallback : name;

    return switch (m) {
      OverdraftRiskMessage() => NotificationText(
          l10n.notif_overdraft_title(m.walletName),
          l10n.notif_overdraft_body(
            or(m.moveName, l10n.notif_a_payment),
            m.moveAmount.format(),
            _date(l10n, m.date),
            m.balanceAfter.format(signed: true),
          ),
        ),
      ChargeTomorrowMessage() => NotificationText(
          l10n.notif_charge_title(or(m.name, l10n.notif_subscription)),
          m.walletName != null && m.variant.isOdd
              ? l10n.notif_charge_body_wallet(m.amount.format(), m.walletName!)
              : l10n.notif_charge_body(m.amount.format()),
        ),
      PlannedTodayMessage(isIncome: true) => NotificationText(
          l10n.notif_today_title(or(m.name, l10n.notif_expected_income)),
          l10n.notif_income_body(m.amount.format()),
        ),
      PlannedTodayMessage() => NotificationText(
          l10n.notif_today_title(or(m.name, l10n.notif_planned_payment)),
          l10n.notif_planned_body(m.amount.format()),
        ),
      IncomeTodayMessage() => NotificationText(
          m.name.isEmpty ? l10n.notif_payday : l10n.notif_payday_named(m.name),
          l10n.notif_income_body(m.amount.format()),
        ),
      DebtDueSoonMessage(owedToMe: true) => NotificationText(
          l10n.notif_debt_soon_lent_title(m.person, m.remaining.format()),
          l10n.notif_debt_soon_lent_body(m.days),
        ),
      DebtDueSoonMessage() => NotificationText(
          l10n.notif_debt_soon_borrowed_title(m.person),
          l10n.notif_debt_soon_borrowed_body(m.remaining.format(), m.days),
        ),
      DebtDueTodayMessage(owedToMe: true) => NotificationText(
          l10n.notif_debt_today_lent_title(m.person),
          l10n.notif_debt_today_lent_body(m.remaining.format()),
        ),
      DebtDueTodayMessage() => NotificationText(
          l10n.notif_debt_today_borrowed_title(m.person),
          l10n.notif_debt_today_borrowed_body(m.remaining.format()),
        ),
      DebtOverdueMessage(owedToMe: true) => NotificationText(
          l10n.notif_debt_late_lent_title(m.person, m.days),
          l10n.notif_debt_late_lent_body(m.remaining.format()),
        ),
      DebtOverdueMessage() => NotificationText(
          l10n.notif_debt_late_borrowed_title(m.person),
          l10n.notif_debt_late_borrowed_body(m.remaining.format(), m.days),
        ),
      DebtForgottenMessage() => NotificationText(
          l10n.notif_debt_forgotten_title(m.person),
          l10n.notif_debt_forgotten_body(m.remaining.format(), m.days),
        ),
      SafeToSpendMessage(perDay: final perDay?) => NotificationText(
          l10n.notif_safe_title(m.name),
          l10n.notif_safe_body(perDay.format()),
        ),
      SafeToSpendMessage() => NotificationText(
          l10n.notif_safe_empty_title(m.name),
          l10n.notif_safe_empty_body,
        ),
      WeeklyRecapMessage() => NotificationText(
          l10n.notif_week_title(m.spent.format()),
          switch (m.trend) {
            WeekTrend.less => l10n.notif_week_less('${m.percent}'),
            WeekTrend.more => l10n.notif_week_more('${m.percent}'),
            WeekTrend.same => m.topTag == null ? l10n.notif_week_plain : l10n.notif_week_tag(m.topTag!),
          },
        ),
      LogReminderMessage() => switch (m.variant % LogReminderMessage.variants) {
          0 => NotificationText(l10n.notif_log_title_1, l10n.notif_log_body_1),
          1 => NotificationText(l10n.notif_log_title_2, l10n.notif_log_body_2),
          2 => NotificationText(l10n.notif_log_title_3, l10n.notif_log_body_3),
          _ => NotificationText(l10n.notif_log_title_4, l10n.notif_log_body_4),
        },
      StreakReminderMessage() => NotificationText(
          l10n.notif_streak_title(m.days),
          l10n.notif_streak_body,
        ),
      WinBackMessage(stage: WinBackStage.missYou) => NotificationText(
          l10n.notif_miss_title,
          l10n.notif_miss_body,
        ),
      WinBackMessage() => NotificationText(
          l10n.notif_asleep_title,
          l10n.notif_asleep_body,
        ),
    };
  }

  /// "Fri, Oct 30" in the notification's language.
  static String _date(AppLocale l10n, DateTime d) {
    try {
      return DateFormat.MMMEd(l10n.localeName).format(d);
    } catch (_) {
      return DateFormat.MMMEd('en_US').format(d);
    }
  }
}
