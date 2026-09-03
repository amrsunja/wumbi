import 'package:wumbi/src/core/errors/failures/failures.dart';
import 'package:wumbi/src/core/local/database/secure_storage/secure_storage_services.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:wumbi/src/core/money/currency_type.dart';
import 'package:wumbi/src/core/money/money.dart';
import 'package:wumbi/src/core/recurring/recurring_engine.dart';
import 'package:wumbi/src/core/utils/enums/repeat_frequency.dart';
import 'package:wumbi/src/core/utils/enums/transaction_type.dart';
import 'package:wumbi/src/core/utils/enums/wallet_color.dart';
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

TransactionDraft _expense(String walletId, int minor, {List<String> tags = const []}) =>
    TransactionDraft.expense(
      walletId: walletId,
      amount: Money(minor, CurrencyType.usd),
      description: '',
      tags: tags,
      date: DateTime(2026, 1, 11, 12),
      repeat: RepeatFrequency.never,
    );
