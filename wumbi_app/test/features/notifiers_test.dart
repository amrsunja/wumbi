import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' show Sqflite;
import 'package:wumbi/src/core/locale/l10n.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:wumbi/src/core/money/currency_type.dart';
import 'package:wumbi/src/core/money/money.dart';
import 'package:wumbi/src/core/providers/data/fx_provider.dart';
import 'package:wumbi/src/core/providers/local/sqlite_database_provider.dart';
import 'package:wumbi/src/core/utils/enums/repeat_frequency.dart';
import 'package:wumbi/src/core/utils/enums/transaction_type.dart';
import 'package:wumbi/src/core/utils/enums/wallet_color.dart';
import 'package:wumbi/src/core/utils/state_management/app_events.dart';
import 'package:wumbi/src/core/utils/state_management/single_events.dart';
import 'package:wumbi/src/features/budget/data/budget_repository.dart';
import 'package:wumbi/src/features/budget/data/models/budget_model.dart';
import 'package:wumbi/src/core/utils/enums/budget_period_type.dart';
import 'package:wumbi/src/features/budget/ui/budget_form_notifier.dart';
import 'package:wumbi/src/features/debt/data/models/person_model.dart';
import 'package:wumbi/src/features/debt/ui/person_pick.dart';
import 'package:wumbi/src/features/transaction/ui/transaction_notifier.dart';
import 'package:wumbi/src/features/transaction/ui/transaction_state.dart';
import 'package:wumbi/src/features/wallet/data/models/wallet_model.dart';
import 'package:wumbi/src/features/wallet/data/wallet_repository.dart';
import 'package:wumbi/src/features/wallet/ui/wallets_provider.dart';

import '../helpers/test_db.dart';

late SQLiteServicesImpl sqlite;
late ProviderContainer container;
late List<SingleEvent> events;

Future<WalletModel> _wallet(String name, CurrencyType c) async {
  final w = (await container.read(walletRepositoryProvider).create(
            WalletDraft(name: name, currency: c, initialBalanceMinor: 100000, color: WalletColor.blue, isPrimary: false),
          ))
      .getOrThrow();
  await container.read(walletsProvider.future);
  return w;
}

/// A live Transaction screen notifier for [walletId] (kept alive by a listener).
TransactionNotifier _screen(String walletId) {
  final provider = transactionNotifierProvider(TransactionArgs(walletId: walletId));
  container.listen(provider, (_, _) {});
  return container.read(provider.notifier);
}

TransactionState _state(String walletId) => container.read(transactionNotifierProvider(TransactionArgs(walletId: walletId)));

void _type(TransactionNotifier n, String digits) {
  for (final d in digits.split('')) {
    n.onDigit(d);
  }
}

Future<int> _count(String sql) async => Sqflite.firstIntValue(await sqlite.db.rawQuery(sql)) ?? 0;

/// Lets fire-and-forget microtasks (event sends after awaits) settle.
Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);

  late StreamSubscription<SingleEvent> sub;

  setUp(() async {
    sqlite = ffiSqlite(inMemoryDatabasePath);
    await sqlite.initDatabase();
    container = ProviderContainer(
      overrides: [
        sqliteDataBaseProvider.overrideWithValue(sqlite),
        fxServiceProvider.overrideWithValue(FakeFx()),
        l10nProvider.overrideWithValue(lookupAppLocalizations(const Locale('en'))),
      ],
    );
    events = [];
    sub = container.read(appEventProvider).singleEvents.listen(events.add);
  });

  tearDown(() async {
    await sub.cancel();
    container.dispose();
    await sqlite.close();
  });

  group('TransactionNotifier · person chip', () {
    test('a person blocks Repeat and future dates (and vice versa)', () async {
      final w = await _wallet('Card', CurrencyType.usd);
      final n = _screen(w.id);

      n.setRepeat(RepeatFrequency.monthly);
      expect(_state(w.id).personLocked, isTrue, reason: 'repeating → no person');
      n.setRepeat(RepeatFrequency.never);

      n.setPerson(const NewPerson('Ahmed'));
      expect(_state(w.id).hasPerson, isTrue);
      n.setRepeat(RepeatFrequency.weekly);
      expect(_state(w.id).repeat, RepeatFrequency.never);

      final today = DateTime.now();
      n.setDate(today.add(const Duration(days: 5)));
      expect(_state(w.id).date, DateTime(today.year, today.month, today.day), reason: 'clamped to today');

      n.setPerson(const NoPerson());
      expect(_state(w.id).hasPerson, isFalse);
    });

    test('GAVE opens a debt, toasts it, and the person resets', () async {
      final w = await _wallet('Card', CurrencyType.usd);
      final n = _screen(w.id);
      n.setPerson(const NewPerson('Ahmed'));
      _type(n, '50');

      expect(await n.commit(TransactionType.expense), isTrue);
      await _settle();
      expect(await _count("SELECT COUNT(*) FROM debts WHERE direction = 'lent' AND principal_minor = 5000"), 1);
      expect(await _count("SELECT COUNT(*) FROM transactions WHERE debt_role = 'principal'"), 1);
      expect(_state(w.id).hasPerson, isFalse, reason: 'cleared with description and tags');
      final toast = events.whereType<ShowSuccessMessageEvent>().last;
      expect(toast.message, 'Lent 50 \$ to Ahmed');
    });

    test('over-repayment stays on screen with an inline message and a shake', () async {
      final w = await _wallet('Card', CurrencyType.usd);
      final n = _screen(w.id);
      n.setPerson(const NewPerson('Ahmed'));
      _type(n, '50');
      await n.commit(TransactionType.expense);

      final person = PersonModel.fromRow((await sqlite.db.query('people')).single);
      n.setPerson(PickedPerson(person));
      _type(n, '60');
      expect(await n.commit(TransactionType.income), isFalse);
      final s = _state(w.id);
      expect(s.validationError, 'Ahmed owes you only 50 \$');
      expect(s.shakeSignal, 1);
      expect(s.amountInput, '60', reason: 'nothing is lost');
    });
  });

  group('TransactionNotifier · budget toast', () {
    test('suffix with what is left, warning when this expense crosses the limit', () async {
      final w = await _wallet('Card', CurrencyType.usd);
      final today = DateTime.now();
      await container.read(budgetRepositoryProvider).create(
            BudgetDraft(
              name: 'Groceries',
              limit: const Money(2000, CurrencyType.usd),
              period: BudgetPeriodType.custom,
              anchorDate: DateTime(today.year, today.month, today.day - 1),
              endDate: DateTime(today.year, today.month, today.day + 2),
              walletIds: {w.id},
            ),
          );
      final n = _screen(w.id);

      _type(n, '15');
      await n.commit(TransactionType.expense);
      await _settle();
      final ok = events.last;
      expect(ok, isA<ShowSuccessMessageEvent>());
      expect((ok as ShowSuccessMessageEvent).message, endsWith('Groceries: 5 \$ left'));

      _type(n, '10');
      await n.commit(TransactionType.expense);
      await _settle();
      final warn = events.last;
      expect(warn, isA<ShowInfoMessageEvent>(), reason: 'crossed from not-over to over');
      expect((warn as ShowInfoMessageEvent).message, endsWith('Groceries: 5 \$ over'));
    });
  });

  group('BudgetFormNotifier', () {
    BudgetFormNotifier form() {
      final provider = budgetFormProvider(const BudgetFormArgs());
      container.listen(provider, (_, _) {});
      return container.read(provider.notifier);
    }

    BudgetFormState formState() => container.read(budgetFormProvider(const BudgetFormArgs()));

    test('auto name and currency following a single wallet until picked by hand', () async {
      final usd = await _wallet('Card', CurrencyType.usd);
      final eur = await _wallet('Euros', CurrencyType.eur);
      final n = form();

      expect(n.autoName(), 'All spending');
      n.setWallets({eur.id});
      expect(formState().currency, CurrencyType.eur);
      expect(n.autoName(), 'Euros');
      n.setWallets({eur.id, usd.id});
      expect(n.autoName(), 'Card, Euros', reason: 'wallet order');

      n.setCurrency(CurrencyType.gbp);
      n.setWallets({usd.id});
      expect(formState().currency, CurrencyType.gbp, reason: 'manual pick wins');
    });

    test('validation: an amount is required; a valid form saves', () async {
      await _wallet('Card', CurrencyType.usd);
      final n = form();
      expect(await n.save(), isFalse);
      expect(formState().error, 'Enter an amount');

      n.setLimitInput('400');
      expect(await n.save(), isTrue);
      final saved = (await container.read(budgetRepositoryProvider).listProgress()).getOrThrow().single;
      expect(saved.budget.name, 'All spending');
      expect(saved.budget.limitMinor, 40000);
      expect(saved.budget.period, BudgetPeriodType.monthly);
    });
  });
}
