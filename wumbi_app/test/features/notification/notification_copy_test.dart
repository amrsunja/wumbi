import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wumbi/src/core/locale/l10n.dart';
import 'package:wumbi/src/core/money/currency_type.dart';
import 'package:wumbi/src/core/money/money.dart';
import 'package:wumbi/src/core/utils/enums/debt_direction.dart';
import 'package:wumbi/src/core/utils/enums/transaction_type.dart';
import 'package:wumbi/src/features/notification/domain/notification_kind.dart';
import 'package:wumbi/src/features/notification/domain/notification_message.dart';
import 'package:wumbi/src/features/notification/domain/notification_pacer.dart';
import 'package:wumbi/src/features/notification/ui/notification_copy.dart';

Money m(int major) => Money(major * 100, CurrencyType.eur);

/// One of every message shape (both directions of each debt reminder).
final messages = <NotificationMessage>[
  OverdraftRiskMessage(
    walletId: 'w',
    walletName: 'Main',
    moveName: '',
    moveAmount: m(800),
    balanceAfter: m(-120),
    date: DateTime(2026, 10, 30),
  ),
  ChargeTomorrowMessage(ruleId: 'r', name: 'Netflix', amount: m(14)),
  ChargeTomorrowMessage(ruleId: 'r', name: '', amount: m(14), walletName: 'Main', variant: 1),
  PlannedTodayMessage(transactionId: 't', type: TransactionType.expense, name: 'Rent', amount: m(800)),
  PlannedTodayMessage(transactionId: 't', type: TransactionType.income, name: '', amount: m(300)),
  IncomeTodayMessage(ruleId: 'r', name: 'Salary', amount: m(2400)),
  IncomeTodayMessage(ruleId: 'r', name: '', amount: m(2400)),
  for (final d in DebtDirection.values) ...[
    for (final days in [1, 2, 3, 5, 11, 30])
      DebtDueSoonMessage(debtId: 'd', person: 'Sam', direction: d, remaining: m(50), days: days),
    DebtDueTodayMessage(debtId: 'd', person: 'Sam', direction: d, remaining: m(50)),
    for (final days in [1, 2, 3, 7, 14, 30])
      DebtOverdueMessage(debtId: 'd', person: 'Sam', direction: d, remaining: m(50), days: days),
  ],
  for (final days in [30, 60]) DebtForgottenMessage(debtId: 'd', person: 'Sam', remaining: m(50), days: days),
  SafeToSpendMessage(budgetId: 'b', name: 'Food', perDay: m(12)),
  const SafeToSpendMessage(budgetId: 'b', name: 'Food'),
  for (final t in WeekTrend.values) WeeklyRecapMessage(spent: m(312), trend: t, percent: 12, topTag: 'food'),
  WeeklyRecapMessage(spent: m(312), trend: WeekTrend.same),
  for (var v = 0; v < LogReminderMessage.variants; v++) LogReminderMessage(variant: v),
  for (final days in [3, 4, 21, 101]) StreakReminderMessage(days: days),
  for (final s in WinBackStage.values) WinBackMessage(stage: s),
];

void main() {
  setUpAll(() => initializeDateFormatting());

  for (final locale in L10n.all) {
    test('every notification has a title and a body in ${locale.languageCode}', () {
      final l10n = lookupAppLocalizations(locale);
      for (final message in messages) {
        final text = NotificationCopy.message(l10n, message);
        expect(text.title.trim(), isNotEmpty, reason: '${message.runtimeType} title');
        expect(text.body.trim(), isNotEmpty, reason: '${message.runtimeType} body');
        expect('${text.title}${text.body}', isNot(contains('{')), reason: '${message.runtimeType}: raw ICU');
      }
      expect(l10n.notif_channel_name, isNotEmpty);
    });
  }

  test('extras are appended as one more line', () {
    final l10n = lookupAppLocalizations(L10n.en);
    final n = ScheduledNotification(
      id: 1,
      fireAt: DateTime(2026, 10, 22, 9),
      slot: NotificationSlot.morning,
      message: ChargeTomorrowMessage(ruleId: 'r', name: 'Netflix', amount: m(14)),
      extraCount: 2,
    );
    final text = NotificationCopy.of(l10n, n);
    expect(text.body.split('\n'), hasLength(2));
    expect(text.body, endsWith(l10n.notif_more(2)));
  });

  test('English reads like the hamster, with the real numbers', () {
    final l10n = lookupAppLocalizations(L10n.en);
    final t = NotificationCopy.message(l10n, messages.first);
    expect(t.title, '“Main” could go negative');
    expect(t.body, contains('800 €'));
    expect(t.body, contains('-120 €'));
    expect(t.body, contains('a payment'));
  });
}
