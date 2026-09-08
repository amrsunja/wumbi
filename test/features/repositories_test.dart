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
    Future<ProgressStats> load(
      ProgressGranularity granularity,
      DateTime now, {
      String? walletId,
    }) async =>
        (await ProgressRepository(sqlite: sqlite).load(
          granularity: granularity,
          target: CurrencyType.usd,
          walletId: walletId,
          now: now,
        ))
            .getOrThrow();

    test('buckets income and expense by month and compares against the previous one', () async {
      final w = await _wallet('Main', CurrencyType.usd);
      await transactions.create(_incomeOn(w.id, 30000, DateTime(2026, 2, 10, 12)));
      await transactions.create(_expenseOn(w.id, 10000, DateTime(2026, 2, 11, 12)));
      await transactions.create(_incomeOn(w.id, 60000, DateTime(2026, 3, 2, 12)));
      await transactions.create(_expenseOn(w.id, 25000, DateTime(2026, 3, 3, 12)));

      final stats = await load(ProgressGranularity.month, DateTime(2026, 3, 15));

      expect(stats.periods.length, 6);
      expect(stats.periods.last.start, DateTime(2026, 3), reason: 'last bucket = running month');
      expect(stats.periods.first.start, DateTime(2025, 10), reason: 'the window rolls over the year');
      expect(stats.current.income.minor, 60000);
      expect(stats.current.expense.minor, 25000);
      expect(stats.baseline!.income.minor, 30000);
      expect(stats.baseline!.expense.minor, 10000);
      expect(stats.incomeDelta, closeTo(1.0, 1e-9));
      expect(stats.expenseDelta, closeTo(1.5, 1e-9));
      expect(stats.netDelta, closeTo(0.75, 1e-9), reason: '(35000 - 20000) / 20000');
      expect(stats.periods.first.isEmpty, isTrue);
      expect(stats.peakMinor, 60000, reason: 'both charts scale off the tallest series');
    });

    test('a period that spent more than it earned reports a negative net', () async {
      final w = await _wallet('Main', CurrencyType.usd);
      await transactions.create(_expenseOn(w.id, 4000, DateTime(2026, 3, 2, 12)));

      final stats = await load(ProgressGranularity.month, DateTime(2026, 3, 15));

      expect(stats.current.net.minor, -4000);
      expect(stats.current.income.isZero, isTrue);
      expect(stats.netDelta, isNull, reason: 'nothing to compare an empty February against');
    });

    test('transfers never count, and rows outside the window are dropped', () async {
      final a = await _wallet('A', CurrencyType.usd, initial: 100000);
      final b = await _wallet('B', CurrencyType.usd);
      await transactions.create(_transferOn(a.id, b.id, 50000, DateTime(2026, 3, 4, 12)));
      await transactions.create(_expenseOn(a.id, 700, DateTime(2025, 1, 4, 12)));

      final stats = await load(ProgressGranularity.month, DateTime(2026, 3, 15));

      expect(stats.isEmpty, isTrue, reason: 'a transfer moves money inside the ledger');
    });

    test('the wallet filter narrows the aggregate', () async {
      final a = await _wallet('A', CurrencyType.usd);
      final b = await _wallet('B', CurrencyType.usd);
      await transactions.create(_expenseOn(a.id, 1000, DateTime(2026, 3, 5, 12)));
      await transactions.create(_expenseOn(b.id, 4000, DateTime(2026, 3, 5, 12)));

      final all = await load(ProgressGranularity.month, DateTime(2026, 3, 15));
      final onlyB = await load(ProgressGranularity.month, DateTime(2026, 3, 15), walletId: b.id);

      expect(all.current.expense.minor, 5000);
      expect(onlyB.current.expense.minor, 4000);
      expect(onlyB.walletId, b.id);
    });

    test('year granularity buckets by calendar year', () async {
      final w = await _wallet('Main', CurrencyType.usd);
      await transactions.create(_incomeOn(w.id, 20000, DateTime(2025, 4, 1, 12)));
      await transactions.create(_incomeOn(w.id, 50000, DateTime(2026, 4, 1, 12)));

      final stats = await load(ProgressGranularity.year, DateTime(2026, 6, 1));

      expect(stats.periods.length, 5);
      expect(stats.periods.map((p) => p.start.year), [2022, 2023, 2024, 2025, 2026]);
      expect(stats.current.income.minor, 50000);
      expect(stats.baseline!.income.minor, 20000);
      expect(stats.incomeDelta, closeTo(1.5, 1e-9));
    });

    test('the pie covers the running period only and counts a two-tag row twice', () async {
      final w = await _wallet('Main', CurrencyType.usd);
      await transactions.create(_expenseOn(w.id, 5000, DateTime(2026, 3, 2, 12), tags: ['Food']));
      await transactions.create(_expenseOn(w.id, 3000, DateTime(2026, 3, 3, 12), tags: ['Food', 'Travel']));
      await transactions.create(_expenseOn(w.id, 1000, DateTime(2026, 3, 4, 12)));
      await transactions.create(_expenseOn(w.id, 90000, DateTime(2026, 2, 4, 12), tags: ['Rent']));

      final stats = await load(ProgressGranularity.month, DateTime(2026, 3, 15));
      final byKey = {
        for (final slice in stats.expenseByTag)
          slice.kind == TagSliceKind.tag ? slice.label : slice.kind.name: slice.amount.minor,
      };

      expect(byKey['Food'], 8000);
      expect(byKey['Travel'], 3000);
      expect(byKey['untagged'], 1000, reason: 'the LEFT JOIN produces the untagged bucket');
      expect(byKey.containsKey('Rent'), isFalse, reason: 'last month is not in the pie');
      expect(stats.expenseByTag.first.label, 'Food', reason: 'biggest slice first');
      expect(stats.expenseByTag.first.normalizedName, 'food', reason: 'drives the palette lookup');
      expect(stats.taggedExpenseMinor, 12000, reason: 'slices overlap by design');
      expect(stats.current.expense.minor, 9000, reason: 'the period total never double-counts');
    });

    test('slices past the fifth fold into one "other" section', () async {
      final w = await _wallet('Main', CurrencyType.usd);
      for (var i = 0; i < 7; i++) {
        await transactions.create(
          _expenseOn(w.id, 1000 * (7 - i), DateTime(2026, 3, 2, 12), tags: ['t$i']),
        );
      }

      final stats = await load(ProgressGranularity.month, DateTime(2026, 3, 15));

      expect(stats.expenseByTag.length, 6, reason: '5 tags + other');
      expect(stats.expenseByTag.last.kind, TagSliceKind.other);
      expect(stats.expenseByTag.last.amount.minor, 3000, reason: '2000 + 1000');
      expect(stats.expenseByTag.last.count, 2);
      expect(stats.expenseByTag.last.tagId, isNull);
    });

    test('the wallet filter narrows the pie too', () async {
      final a = await _wallet('A', CurrencyType.usd);
      final b = await _wallet('B', CurrencyType.usd);
      await transactions.create(_expenseOn(a.id, 1000, DateTime(2026, 3, 5, 12), tags: ['Food']));
      await transactions.create(_expenseOn(b.id, 4000, DateTime(2026, 3, 5, 12), tags: ['Rent']));

      final onlyB = await load(ProgressGranularity.month, DateTime(2026, 3, 15), walletId: b.id);

      expect(onlyB.expenseByTag.map((s) => s.label), ['Rent']);
    });

    test('an untouched ledger reports empty with no deltas', () async {
      await _wallet('Main', CurrencyType.usd, initial: 5000);

      final stats = await load(ProgressGranularity.month, DateTime(2026, 3, 15));

      expect(stats.isEmpty, isTrue, reason: 'the initial balance is not a transaction');
      expect(stats.incomeDelta, isNull);
      expect(stats.netDelta, isNull);
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
