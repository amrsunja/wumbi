import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/enums/debt_direction.dart';
import '../domain/notification_message.dart';

/// Example messages for the in-app previews — one per kind of situation, so
/// tapping through them shows every face the hamster makes.
abstract class NotificationSamples {
  static List<NotificationMessage> of(CurrencyType base, {required String person}) {
    Money m(int major) => Money(major * _unit(base), base);
    return [
      ChargeTomorrowMessage(ruleId: 'sample', name: 'Netflix', amount: Money(1399 * _unit(base) ~/ 100, base)),
      DebtDueTodayMessage(
        debtId: 'sample',
        person: person,
        direction: DebtDirection.lent,
        remaining: m(50),
      ),
      const LogReminderMessage(variant: 1),
      WeeklyRecapMessage(spent: m(312), trend: WeekTrend.less, percent: 12),
      const StreakReminderMessage(days: 7),
      const WinBackMessage(stage: WinBackStage.missYou),
    ];
  }

  /// Minor units in one major unit (100 for EUR, 1 for JPY…).
  static int _unit(CurrencyType c) {
    var u = 1;
    for (var i = 0; i < c.scale; i++) {
      u *= 10;
    }
    return u;
  }
}
