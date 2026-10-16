import 'package:wumbi/src/core/errors/failures/failures.dart';
import 'package:wumbi/src/core/local/database/secure_storage/secure_storage_services.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:wumbi/src/core/money/currency_type.dart';
import 'package:wumbi/src/core/money/money.dart';
import 'package:wumbi/src/core/recurring/recurring_engine.dart';
import 'package:wumbi/src/core/utils/enums/repeat_frequency.dart';
import 'package:wumbi/src/core/utils/enums/transaction_type.dart';
import 'package:wumbi/src/core/utils/enums/wallet_color.dart';
import 'package:wumbi/src/features/progress/data/models/progress_stats.dart';
import 'package:wumbi/src/features/progress/data/progress_repository.dart';
import 'package:wumbi/src/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:wumbi/src/features/tag/data/tag_repository.dart';
import 'package:wumbi/src/features/transaction/data/models/transaction_model.dart';
import 'package:wumbi/src/features/transaction/data/transaction_repository.dart';
import 'package:wumbi/src/features/wallet/data/models/wallet_model.dart';
import 'package:wumbi/src/features/wallet/data/wallet_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' show Sqflite;

class _FakeSecureStorage implements SecureStorageServices {
  final Map<String, String> _data = {};

  @override
  Future<String?> readData(String key) async => _data[key];

  @override
  Future<void> writeData(String key, String? value) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> deleteData(String key) async => _data.remove(key);
}

late SQLiteServicesImpl sqlite;
late WalletRepository wallets;
late TagRepository tags;
late TransactionRepository transactions;
late RecurringEngine engine;
int writes = 0;

Future<void> _openFresh() async {
  sqlite = SQLiteServicesImpl(
    secureStorage: _FakeSecureStorage(),
    overridePath: inMemoryDatabasePath,
    opener: ({
      required path,
      required password,
      required version,
      required onConfigure,
      required onCreate,
      required onUpgrade,
    }) =>
        databaseFactoryFfi.openDatabase(
          path,
          options: OpenDatabaseOptions(
            version: version,
            onConfigure: onConfigure,
            onCreate: onCreate,
            onUpgrade: onUpgrade,
          ),
        ),
  );
  await sqlite.initDatabase();
  writes = 0;
  void bump() => writes++;
  wallets = WalletRepository(sqlite: sqlite, onWrite: bump);
  tags = TagRepository(sqlite: sqlite);
  transactions = TransactionRepository(sqlite: sqlite, tags: tags, onWrite: bump);
  engine = RecurringEngine(
    sqlite: sqlite,
    tags: tags,
    settings: SettingsLocalDatasource(services: sqlite),
    onWrite: bump,
  );
}

Future<WalletModel> _wallet(String name, CurrencyType c, {int initial = 0, bool primary = false}) async {
  final r = await wallets.create(
    WalletDraft(name: name, currency: c, initialBalanceMinor: initial, color: WalletColor.blue, isPrimary: primary),
  );
  return r.getOrThrow();
}

Future<Money> _balance(String id) async => (await wallets.byId(id)).getOrThrow().balance;

Future<int> _count(String sql, [List<Object?> args = const []]) async =>
    Sqflite.firstIntValue(await sqlite.db.rawQuery(sql, args)) ?? 0;

void main() {
  setUpAll(() => sqfliteFfiInit());
  setUp(_openFresh);
  tearDown(() => sqlite.close());

  group('wallet invariants', () {
    test('first wallet is primary regardless of the toggle', () async {
      final a = await _wallet('A', CurrencyType.usd);
      expect(a.isPrimary, isTrue);
      final b = await _wallet('B', CurrencyType.eur);
      expect(b.isPrimary, isFalse);
      expect(await _count('SELECT COUNT(*) FROM wallets WHERE is_primary = 1'), 1);
    });

    test('setting primary moves the flag', () async {
      final a = await _wallet('A', CurrencyType.usd);
      final b = await _wallet('B', CurrencyType.eur, primary: true);
      expect((await wallets.byId(a.id)).getOrThrow().isPrimary, isFalse);
      expect((await wallets.byId(b.id)).getOrThrow().isPrimary, isTrue);
      await wallets.setPrimary(a.id);
      expect(await _count('SELECT COUNT(*) FROM wallets WHERE is_primary = 1'), 1);
      expect((await wallets.byId(a.id)).getOrThrow().isPrimary, isTrue);
    });

    test('reorder persists sort_order and makes the first wallet primary', () async {
      final a = await _wallet('A', CurrencyType.usd);
      final b = await _wallet('B', CurrencyType.eur);
      final c = await _wallet('C', CurrencyType.gbp);
      expect((await wallets.reorder([c.id, a.id, b.id])).isSuccess(), isTrue);
      final list = (await wallets.listActive()).getOrThrow();
      expect(list.map((w) => w.id).toList(), [c.id, a.id, b.id]);
      expect(list.first.isPrimary, isTrue);
      expect(await _count('SELECT COUNT(*) FROM wallets WHERE is_primary = 1'), 1);
    });

    test('deleting the primary promotes the lowest sort_order wallet', () async {
      final a = await _wallet('A', CurrencyType.usd);
      final b = await _wallet('B', CurrencyType.eur);
      final c = await _wallet('C', CurrencyType.gbp);
      await wallets.softDelete(a.id);
      expect((await wallets.byId(b.id)).getOrThrow().isPrimary, isTrue);
      expect((await wallets.byId(c.id)).getOrThrow().isPrimary, isFalse);
      expect((await wallets.listActive()).getOrThrow().length, 2);
    });

    test('currency is locked once the wallet has transactions', () async {
      final a = await _wallet('A', CurrencyType.usd);
      final draft = WalletDraft(
        name: 'A',
        currency: CurrencyType.eur,
        initialBalanceMinor: 0,
        color: WalletColor.red,
        isPrimary: true,
      );
      expect((await wallets.update(a.id, draft)).isSuccess(), isTrue);

      await transactions.create(_income(a.id, 100));
      final refused = await wallets.update(a.id, draft.copyWith(currency: CurrencyType.gbp));
      expect(refused.tryGetError(), isA<WalletHasTransactionsFailure>());
    });

    test('empty name is a validation failure', () async {
      final r = await wallets.create(
        const WalletDraft(name: '   ', currency: CurrencyType.usd, initialBalanceMinor: 0, color: WalletColor.blue, isPrimary: false),
      );
      expect(r.tryGetError(), isA<ValidationFailure>());
    });
  });

  group('balances (derived view)', () {
    test('initial + income − expense ± transfers', () async {
      final a = await _wallet('A', CurrencyType.usd, initial: 10000);
      final b = await _wallet('B', CurrencyType.eur);
      await transactions.create(_income(a.id, 5000));
      await transactions.create(_expense(a.id, 1200));
      await transactions.create(
        TransactionDraft.transfer(
          fromWalletId: a.id,
          toWalletId: b.id,
          sent: const Money(2000, CurrencyType.usd),
          received: const Money(1840, CurrencyType.eur),
          rate: 0.92,
          description: '',
          tags: const [],
          date: DateTime(2026, 1, 5, 12),
          repeat: RepeatFrequency.never,
        ),
      );
      expect(await _balance(a.id), const Money(11800, CurrencyType.usd));
      expect(await _balance(b.id), const Money(1840, CurrencyType.eur));
    });

    test('editing the initial balance shifts the balance (D13)', () async {
      final a = await _wallet('A', CurrencyType.usd, initial: 1000);
      await transactions.create(_income(a.id, 500));
      await wallets.update(
        a.id,
        const WalletDraft(name: 'A', currency: CurrencyType.usd, initialBalanceMinor: 3000, color: WalletColor.blue, isPrimary: true),
      );
      expect(await _balance(a.id), const Money(3500, CurrencyType.usd));
    });
  });

  group('transactions', () {
    test('soft delete + restore (undo)', () async {
      final a = await _wallet('A', CurrencyType.usd);
      final t = (await transactions.create(_income(a.id, 700, tags: ['Food']))).getOrThrow();
      expect(await _balance(a.id), const Money(700, CurrencyType.usd));

      await transactions.softDelete(t.id);
      expect(await _balance(a.id), const Money(0, CurrencyType.usd));
      expect((await transactions.pageForWallet(a.id)).getOrThrow(), isEmpty);

      await transactions.restore(t.id);
      expect(await _balance(a.id), const Money(700, CurrencyType.usd));
      final withTags = (await transactions.byId(t.id)).getOrThrow();
      expect(withTags.tags, ['Food']);
    });

    test('tags: find-or-create, usage counts, diff on update', () async {
      final a = await _wallet('A', CurrencyType.usd);
      final t1 = (await transactions.create(_income(a.id, 100, tags: ['Food', '#food', 'Work']))).getOrThrow();
      expect(await _count('SELECT COUNT(*) FROM tags'), 2);
      expect(await _count("SELECT usage_count FROM tags WHERE normalized_name = 'food'"), 1);

      await transactions.create(_expense(a.id, 50, tags: ['food']));
      expect(await _count("SELECT usage_count FROM tags WHERE normalized_name = 'food'"), 2);

      await transactions.update(t1.id, _income(a.id, 100, tags: ['Work', 'Gym']));
      expect(await _count("SELECT usage_count FROM tags WHERE normalized_name = 'food'"), 1);
      expect(await _count("SELECT usage_count FROM tags WHERE normalized_name = 'gym'"), 1);
      expect((await transactions.byId(t1.id)).getOrThrow().tags, ['Work', 'Gym']);

      expect(await tags.suggest('f'), ['Food']);
    });

    test('income ↔ expense may change on update, transfer may not', () async {
      final a = await _wallet('A', CurrencyType.usd, initial: 10000);
      final b = await _wallet('B', CurrencyType.usd);
      final t = (await transactions.create(_income(a.id, 100))).getOrThrow();
      final switched = await transactions.update(t.id, _expense(a.id, 100));
      expect(switched.isSuccess(), isTrue);
      expect((await transactions.byId(t.id)).getOrThrow().transaction.type, TransactionType.expense);

      final tr = (await transactions.create(
        TransactionDraft.transfer(
          fromWalletId: a.id,
          toWalletId: b.id,
          sent: const Money(500, CurrencyType.usd),
          received: const Money(500, CurrencyType.usd),
          description: '',
          tags: const [],
          date: DateTime.now(),
          repeat: RepeatFrequency.never,
        ),
      ))
          .getOrThrow();
      final refused = await transactions.update(tr.id, _income(a.id, 100));
      expect(refused.tryGetError(), isA<ValidationFailure>());
    });

    test('wallet delete cascades to its income/expense, keeps transfers, pauses rules', () async {
      final a = await _wallet('A', CurrencyType.usd, initial: 10000);
      final b = await _wallet('B', CurrencyType.usd);
      await transactions.create(_income(a.id, 100));
      await transactions.create(_income(a.id, 100, repeat: RepeatFrequency.monthly));
      await transactions.create(
        TransactionDraft.transfer(
          fromWalletId: a.id,
          toWalletId: b.id,
          sent: const Money(500, CurrencyType.usd),
          received: const Money(500, CurrencyType.usd),
          description: '',
          tags: const [],
          date: DateTime(2026, 1, 5, 12),
          repeat: RepeatFrequency.never,
        ),
      );

      final outcome = (await wallets.softDelete(a.id)).getOrThrow();
      expect(outcome.pausedRules, 1);
      expect(await _balance(b.id), const Money(500, CurrencyType.usd));
      final rows = (await transactions.pageForWallet(b.id)).getOrThrow();
      expect(rows.single.fromWalletName, 'A');
      expect(rows.single.fromWalletDeleted, isTrue);
      expect(await _count('SELECT COUNT(*) FROM transactions WHERE deleted_at IS NULL'), 1);
    });
  });

  group('global search', () {
    test('matches description, tag, wallet name and amount', () async {
      final a = await _wallet('Groceries card', CurrencyType.usd);
      final b = await _wallet('Savings', CurrencyType.usd);
      await transactions.create(_described(a.id, 1250, 'Coffee at Blue Bottle', tags: ['Food']));
      await transactions.create(_described(b.id, 99900, 'Rent', tags: ['Home']));

      Future<List<String>> hits(String q) async =>
          (await transactions.search(q)).getOrThrow().map((r) => r.transaction.description).toList();

      expect(await hits('coffee'), ['Coffee at Blue Bottle'], reason: 'description, case-insensitive');
      expect(await hits('home'), ['Rent'], reason: 'tag');
      expect(await hits('Savings'), ['Rent'], reason: 'wallet name');
      expect(await hits('12'), ['Coffee at Blue Bottle'], reason: '12 → 12.50 (1250 minor)');
      expect(await hits('nothing here'), isEmpty);
      expect(await hits('   '), isEmpty, reason: 'a blank query never returns the whole ledger');
    });

    test('% and _ are literals, and deleted rows stay out', () async {
      final a = await _wallet('A', CurrencyType.usd);
      await transactions.create(_described(a.id, 100, '50% off'));
      final gone = (await transactions.create(_described(a.id, 200, 'Deleted row'))).getOrThrow();
      await transactions.softDelete(gone.id);

      final wildcard = (await transactions.search('%')).getOrThrow();
      expect(wildcard.length, 1, reason: '% must not match every row');
      expect(wildcard.single.transaction.description, '50% off');
      expect((await transactions.search('deleted')).getOrThrow(), isEmpty);
    });
  });

  group('progress', () {
    // `now` is injected, so these dates stay in the past whenever the suite runs.
    Future<ProgressReport> load(
      DateTime viewed,
      DateTime now, {
      ProgressGranularity granularity = ProgressGranularity.month,
      ProgressBaseline baseline = const ProgressBaseline.previous(),
      String? walletId,
    }) async =>
        (await ProgressRepository(sqlite: sqlite).load(
          granularity: granularity,
          viewed: viewed,
          baseline: baseline,
          target: CurrencyType.usd,
          walletId: walletId,
          now: now,
        ))
            .getOrThrow();

    test('a past month against the previous one: totals, deltas, pace, history window', () async {
      final w = await _wallet('Main', CurrencyType.usd);
      await transactions.create(_incomeOn(w.id, 30000, DateTime(2026, 2, 10, 12)));
      await transactions.create(_expenseOn(w.id, 10000, DateTime(2026, 2, 11, 12)));
      await transactions.create(_incomeOn(w.id, 60000, DateTime(2026, 3, 2, 12)));
      await transactions.create(_expenseOn(w.id, 25000, DateTime(2026, 3, 3, 12)));

      final r = await load(DateTime(2026, 3), DateTime(2026, 4, 15));

      expect(r.viewed, DateTime(2026, 3));
      expect(r.isCurrent, isFalse);
      expect(r.current.income.minor, 60000);
      expect(r.current.expense.minor, 25000);
      expect(r.comparison!.income.minor, 30000);
      expect(r.comparison!.expense.minor, 10000);
      expect(r.comparisonIsToDate, isFalse, reason: 'a finished month compares whole periods');
      expect(r.incomeDelta, closeTo(1.0, 1e-9));
      expect(r.expenseDelta, closeTo(1.5, 1e-9));
      expect(r.paceCurrent.length, 31, reason: 'every day of a past month');
      expect(r.paceCurrent[1], 0);
      expect(r.paceCurrent.last, 25000);
      expect(r.paceBaseline!.last, 10000, reason: 'February ends flat on its total');
      expect(r.paceDelta!.minor, 15000);
      expect(r.forecast, isNull, reason: 'no forecast for a finished period');
      expect(r.history.length, 12);
      expect(r.history.last.start, DateTime(2026, 4), reason: 'the window ends at the running month');
      expect(r.history.firstWhere((p) => p.start == DateTime(2026, 3)).expense.minor, 25000);
    });

    test('the running month compares against the same days of the baseline', () async {
      final w = await _wallet('Main', CurrencyType.usd);
      await transactions.create(_expenseOn(w.id, 1000, DateTime(2026, 2, 5, 12)));
      await transactions.create(_expenseOn(w.id, 5000, DateTime(2026, 2, 20, 12)));
      await transactions.create(_expenseOn(w.id, 2000, DateTime(2026, 3, 3, 12)));

      final r = await load(DateTime(2026, 3), DateTime(2026, 3, 10, 9));

      expect(r.isCurrent, isTrue);
      expect(r.comparisonIsToDate, isTrue);
      expect(r.comparison!.expense.minor, 1000, reason: 'Feb 1–10 only');
      expect(r.paceCurrent.length, 10, reason: 'up to and including today');
      expect(r.paceBaseline!.length, 31);
      expect(r.paceBaseline![9], 1000);
      expect(r.paceBaseline!.last, 6000, reason: 'the curve keeps the whole baseline month');
      expect(r.paceDelta!.minor, 1000);
      expect(r.forecast!.minor, 2000 + 5000, reason: "spent so far + the baseline's spending after day 10");
      expect(r.history.last.start, DateTime(2026, 3));
    });

    test('a longer baseline month lands its last days on the final slot', () async {
      final w = await _wallet('Main', CurrencyType.usd);
      await transactions.create(_expenseOn(w.id, 700, DateTime(2026, 1, 31, 12)));

      final r = await load(DateTime(2026, 2), DateTime(2026, 3, 15));

      expect(r.paceBaseline!.length, 28);
      expect(r.paceBaseline!.last, 700, reason: 'Jan 29–31 are not dropped');
      expect(r.paceDelta!.minor, -700);
    });

    test('the average baseline only counts periods holding data', () async {
      final w = await _wallet('Main', CurrencyType.usd);
      await transactions.create(_expenseOn(w.id, 3000, DateTime(2026, 2, 4, 12)));

      final r = await load(DateTime(2026, 3), DateTime(2026, 4, 15), baseline: const ProgressBaseline.average());

      expect(r.baselineStarts, [DateTime(2025, 12), DateTime(2026, 1), DateTime(2026, 2)]);
      expect(r.comparison!.expense.minor, 3000, reason: 'Dec and Jan are empty, not zeros');
    });

    test('same month last year and a picked month', () async {
      final w = await _wallet('Main', CurrencyType.usd);
      await transactions.create(_expenseOn(w.id, 4000, DateTime(2025, 3, 8, 12)));
      await transactions.create(_expenseOn(w.id, 900, DateTime(2025, 11, 8, 12)));

      final lastYear = await load(DateTime(2026, 3), DateTime(2026, 4, 15), baseline: const ProgressBaseline.lastYear());
      expect(lastYear.baselineStarts, [DateTime(2025, 3)]);
      expect(lastYear.comparison!.expense.minor, 4000);

      final picked = await load(
        DateTime(2026, 3),
        DateTime(2026, 4, 15),
        baseline: ProgressBaseline.custom(DateTime(2025, 11)),
      );
      expect(picked.comparison!.expense.minor, 900);

      final self = await load(DateTime(2025, 11), DateTime(2026, 4, 15), baseline: ProgressBaseline.custom(DateTime(2025, 11)));
      expect(self.baselineStarts, [DateTime(2025, 10)], reason: 'a period is never compared with itself');
    });

    test('transfers never count, and rows outside the period are dropped', () async {
      final a = await _wallet('A', CurrencyType.usd, initial: 100000);
      final b = await _wallet('B', CurrencyType.usd);
      await transactions.create(_transferOn(a.id, b.id, 50000, DateTime(2026, 3, 4, 12)));
      await transactions.create(_expenseOn(a.id, 700, DateTime(2024, 1, 4, 12)));

      final r = await load(DateTime(2026, 3), DateTime(2026, 3, 15));

      expect(r.current.isEmpty, isTrue, reason: 'a transfer moves money inside the ledger');
      expect(r.isLedgerEmpty, isTrue);
    });

    test('the wallet filter narrows totals and tags', () async {
      final a = await _wallet('A', CurrencyType.usd);
      final b = await _wallet('B', CurrencyType.usd);
      await transactions.create(_expenseOn(a.id, 1000, DateTime(2026, 3, 5, 12), tags: ['Food']));
      await transactions.create(_expenseOn(b.id, 4000, DateTime(2026, 3, 5, 12), tags: ['Rent']));

      final all = await load(DateTime(2026, 3), DateTime(2026, 3, 15));
      final onlyB = await load(DateTime(2026, 3), DateTime(2026, 3, 15), walletId: b.id);

      expect(all.current.expense.minor, 5000);
      expect(onlyB.current.expense.minor, 4000);
      expect(onlyB.walletId, b.id);
      expect(onlyB.spending.roots.map((n) => n.displayName), ['Rent']);
    });

    test('year granularity: history by year, pace by month', () async {
      final w = await _wallet('Main', CurrencyType.usd);
      await transactions.create(_incomeOn(w.id, 20000, DateTime(2025, 4, 1, 12)));
      await transactions.create(_incomeOn(w.id, 50000, DateTime(2026, 4, 1, 12)));
      await transactions.create(_expenseOn(w.id, 1200, DateTime(2026, 2, 1, 12)));

      final r = await load(DateTime(2026), DateTime(2026, 6, 1), granularity: ProgressGranularity.year);

      expect(r.history.map((p) => p.start.year), [2022, 2023, 2024, 2025, 2026]);
      expect(r.current.income.minor, 50000);
      expect(r.comparison!.income.minor, 20000, reason: 'Jan 1 – Jun 1 of 2025');
      expect(r.incomeDelta, closeTo(1.5, 1e-9));
      expect(r.paceCurrent.length, 6, reason: 'January … June');
      expect(r.paceCurrent[1], 1200);
    });

    test('tag families roll nested tags up once; movers rank by the biggest move', () async {
      final w = await _wallet('Main', CurrencyType.usd);
      await transactions.create(_expenseOn(w.id, 5000, DateTime(2026, 3, 2, 12), tags: ['Food']));
      await transactions.create(_expenseOn(w.id, 3000, DateTime(2026, 3, 3, 12), tags: ['Food/Coffee']));
      await transactions.create(_expenseOn(w.id, 2000, DateTime(2026, 3, 4, 12), tags: ['Food', 'Food/Coffee']));
      await transactions.create(_expenseOn(w.id, 1000, DateTime(2026, 3, 5, 12)));
      await transactions.create(_expenseOn(w.id, 4000, DateTime(2026, 2, 4, 12), tags: ['Food']));
      await transactions.create(_expenseOn(w.id, 7000, DateTime(2026, 2, 5, 12), tags: ['Travel']));

      final r = await load(DateTime(2026, 3), DateTime(2026, 4, 15));
      final food = r.spending.roots.single;

      expect(food.displayName, 'Food');
      expect(food.amount.minor, 10000, reason: 'the two-tag row counts once in its family');
      expect(food.count, 3);
      expect(food.baseline!.minor, 4000);
      expect(food.children.single.displayName, 'Food/Coffee');
      expect(food.children.single.amount.minor, 5000);
      expect(r.spending.untagged.minor, 1000);
      expect(r.spending.vanished.single.displayName, 'Travel');
      expect(r.movers().map((n) => n.displayName), ['Travel', 'Food'], reason: '−7000 before +6000');
      expect(r.earning.isEmpty, isTrue);
    });

    test('habits: daily average, biggest expense, priciest weekday', () async {
      final w = await _wallet('Main', CurrencyType.usd);
      await transactions.create(_expenseOn(w.id, 1000, DateTime(2026, 3, 2, 12))); // Monday
      await transactions.create(
        TransactionDraft.expense(
          walletId: w.id,
          amount: const Money(9000, CurrencyType.usd),
          description: 'TV',
          tags: const [],
          date: DateTime(2026, 3, 7, 12), // Saturday
          repeat: RepeatFrequency.never,
        ),
      );

      final h = (await load(DateTime(2026, 3), DateTime(2026, 4, 15))).habits;

      expect(h.dailyAverage.minor, (10000 / 31).round());
      expect(h.topExpense!.description, 'TV');
      expect(h.topExpense!.amount.minor, 9000);
      expect(h.peakWeekday, 5, reason: 'Monday-based index');
      expect(h.weekdayAverages[5], 9000 ~/ 4, reason: 'four Saturdays in March 2026');
      expect(h.averageExpense!.minor, 5000);
    });

    test('an untouched ledger reports empty with no comparison', () async {
      await _wallet('Main', CurrencyType.usd, initial: 5000);

      final r = await load(DateTime(2026, 3), DateTime(2026, 3, 15));

      expect(r.isLedgerEmpty, isTrue, reason: 'the initial balance is not a transaction');
      expect(r.comparison, isNull);
      expect(r.incomeDelta, isNull);
      expect(r.paceBaseline, isNull);
    });
  });

  group('recurring', () {
    test('rule creation + catch-up is idempotent and anchored', () async {
      final a = await _wallet('A', CurrencyType.usd);
      final start = DateTime(2026, 1, 31, 12);
      final first = (await transactions.create(
        _income(a.id, 1000, date: start, repeat: RepeatFrequency.monthly, tags: ['Rent']),
      ))
          .getOrThrow();
      expect(first.recurringRuleId, isNotNull);
      expect(await _count('SELECT COUNT(*) FROM recurring_rules'), 1);
      expect(await _count('SELECT COUNT(*) FROM recurring_rule_tags'), 1);

      // Nothing due yet.
      expect(await engine.catchUp(DateTime(2026, 2, 27)), 0);

      // Feb 28 and Mar 31 are due on Apr 1.
      expect(await engine.catchUp(DateTime(2026, 4, 1)), 2);
      final dates = (await sqlite.db.rawQuery(
        'SELECT transaction_date FROM transactions WHERE recurring_rule_id = ? ORDER BY transaction_date',
        [first.recurringRuleId],
      ))
          .map((r) => DateTime.fromMillisecondsSinceEpoch(r['transaction_date'] as int).day)
          .toList();
      expect(dates, [31, 28, 31]);

      // Re-running with the same clock generates nothing new.
      expect(await engine.catchUp(DateTime(2026, 4, 1)), 0);
      expect(await _count('SELECT COUNT(*) FROM transactions'), 3);
      expect(await _count("SELECT usage_count FROM tags WHERE normalized_name = 'rent'"), 3);
      expect(await _balance(a.id), const Money(3000, CurrencyType.usd));
    });

    test('paused rules do not generate; delete-and-stop deactivates', () async {
      final a = await _wallet('A', CurrencyType.usd);
      final t = (await transactions.create(
        _income(a.id, 10, date: DateTime(2026, 1, 1, 12), repeat: RepeatFrequency.daily),
      ))
          .getOrThrow();
      await transactions.setRuleActive(t.recurringRuleId!, false);
      expect(await engine.catchUp(DateTime(2026, 1, 10)), 0);
      await transactions.setRuleActive(t.recurringRuleId!, true);
      expect(await engine.catchUp(DateTime(2026, 1, 4)), 2);

      await transactions.softDelete(t.id, stopRule: true);
      expect(await _count('SELECT is_active FROM recurring_rules'), 0);
    });

    test('safety cap per run', () async {
      final a = await _wallet('A', CurrencyType.usd);
      await transactions.create(_income(a.id, 1, date: DateTime(2020, 1, 1, 12), repeat: RepeatFrequency.daily));
      final generated = await engine.catchUp(DateTime(2026, 1, 1));
      expect(generated, RecurringEngine.maxPerRule);
    });
  });
}

TransactionDraft _income(
  String walletId,
  int minor, {
  List<String> tags = const [],
  DateTime? date,
  RepeatFrequency repeat = RepeatFrequency.never,
}) =>
    TransactionDraft.income(
      walletId: walletId,
      amount: Money(minor, CurrencyType.usd),
      description: '',
      tags: tags,
      date: date ?? DateTime(2026, 1, 10, 12),
      repeat: repeat,
    );

TransactionDraft _described(
  String walletId,
  int minor,
  String description, {
  List<String> tags = const [],
}) =>
    TransactionDraft.expense(
      walletId: walletId,
      amount: Money(minor, CurrencyType.usd),
      description: description,
      tags: tags,
      date: DateTime(2026, 1, 12, 12),
      repeat: RepeatFrequency.never,
    );

TransactionDraft _expense(String walletId, int minor, {List<String> tags = const []}) =>
    TransactionDraft.expense(
      walletId: walletId,
      amount: Money(minor, CurrencyType.usd),
      description: '',
      tags: tags,
      date: DateTime(2026, 1, 11, 12),
      repeat: RepeatFrequency.never,
    );

TransactionDraft _incomeOn(String walletId, int minor, DateTime date) => TransactionDraft.income(
      walletId: walletId,
      amount: Money(minor, CurrencyType.usd),
      description: '',
      tags: const [],
      date: date,
      repeat: RepeatFrequency.never,
    );

TransactionDraft _expenseOn(
  String walletId,
  int minor,
  DateTime date, {
  List<String> tags = const [],
}) =>
    TransactionDraft.expense(
      walletId: walletId,
      amount: Money(minor, CurrencyType.usd),
      description: '',
      tags: tags,
      date: date,
      repeat: RepeatFrequency.never,
    );

TransactionDraft _transferOn(String fromId, String toId, int minor, DateTime date) =>
    TransactionDraft.transfer(
      fromWalletId: fromId,
      toWalletId: toId,
      sent: Money(minor, CurrencyType.usd),
      received: Money(minor, CurrencyType.usd),
      description: '',
      tags: const [],
      date: date,
      repeat: RepeatFrequency.never,
    );
