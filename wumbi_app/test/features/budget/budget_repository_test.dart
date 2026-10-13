import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' show Sqflite;
import 'package:wumbi/src/core/errors/failures/failures.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:wumbi/src/core/money/currency_type.dart';
import 'package:wumbi/src/core/money/money.dart';
import 'package:wumbi/src/core/utils/enums/budget_period_type.dart';
import 'package:wumbi/src/core/utils/enums/repeat_frequency.dart';
import 'package:wumbi/src/core/utils/enums/rollover_mode.dart';
import 'package:wumbi/src/core/utils/enums/wallet_color.dart';
import 'package:wumbi/src/features/budget/data/budget_metrics.dart';
import 'package:wumbi/src/features/budget/data/budget_repository.dart';
import 'package:wumbi/src/features/budget/data/models/budget_model.dart';
import 'package:wumbi/src/features/debt/data/debt_repository.dart';
import 'package:wumbi/src/features/debt/data/models/debt_intent.dart';
import 'package:wumbi/src/features/tag/data/tag_repository.dart';
import 'package:wumbi/src/features/transaction/data/models/transaction_model.dart';
import 'package:wumbi/src/features/transaction/data/transaction_repository.dart';
import 'package:wumbi/src/features/wallet/data/models/wallet_model.dart';
import 'package:wumbi/src/features/wallet/data/wallet_repository.dart';

import '../../helpers/test_db.dart';

late SQLiteServicesImpl sqlite;
late FakeFx fx;
late WalletRepository wallets;
late TagRepository tags;
late TransactionRepository transactions;
late BudgetRepository budgets;

/// Every budget read in this file is evaluated "on March 15, 2026".
final now = DateTime(2026, 3, 15);

Future<WalletModel> _wallet(String name, [CurrencyType c = CurrencyType.eur]) async => (await wallets.create(
      WalletDraft(name: name, currency: c, initialBalanceMinor: 0, color: WalletColor.blue, isPrimary: false),
    ))
        .getOrThrow();

Future<TransactionModel> _expense(
  WalletModel w,
  int minor,
  DateTime date, {
  List<String> tags = const [],
  RepeatFrequency repeat = RepeatFrequency.never,
  DebtIntent? debt,
}) async =>
    (await transactions.create(
      TransactionDraft.expense(
        walletId: w.id,
        amount: Money(minor, w.currency),
        description: '',
        tags: tags,
        date: date,
        repeat: repeat,
        debt: debt,
      ),
    ))
        .getOrThrow();

Future<String> _tagId(String normalized) async => (await sqlite.db.query(
      'tags',
      where: 'normalized_name = ? AND deleted_at IS NULL',
      whereArgs: [normalized],
    ))
        .single['id']! as String;

BudgetDraft _draft({
  String name = 'Budget',
  int limit = 100000,
  CurrencyType currency = CurrencyType.eur,
  Set<String> walletIds = const {},
  Set<String> tagIds = const {},
  BudgetPeriodType period = BudgetPeriodType.monthly,
  DateTime? anchor,
  DateTime? end,
  RolloverMode rollover = RolloverMode.none,
  bool includePlanned = true,
}) =>
    BudgetDraft(
      name: name,
      limit: Money(limit, currency),
      period: period,
      anchorDate: anchor ?? DateTime(2026, 3, 1),
      endDate: end,
      rollover: rollover,
      includePlanned: includePlanned,
      walletIds: walletIds,
      tagIds: tagIds,
    );

Future<BudgetModel> _budget(BudgetDraft draft) async => (await budgets.create(draft)).getOrThrow();

Future<BudgetProgress> _progress(BudgetModel b, {int offset = 0}) async =>
    (await budgets.progressOf(b.id, periodOffset: offset, now: now)).getOrThrow();

Future<int> _count(String sql) async => Sqflite.firstIntValue(await sqlite.db.rawQuery(sql)) ?? 0;

void main() {
  setUpAll(sqfliteFfiInit);
  setUp(() async {
    sqlite = ffiSqlite(inMemoryDatabasePath);
    await sqlite.initDatabase();
    fx = FakeFx();
    void noop() {}
    wallets = WalletRepository(sqlite: sqlite, onWrite: noop);
    tags = TagRepository(sqlite: sqlite, fx: fx);
    transactions = TransactionRepository(
      sqlite: sqlite,
      tags: tags,
      debts: DebtRepository(sqlite: sqlite, fx: fx),
      onWrite: noop,
    );
    budgets = BudgetRepository(sqlite: sqlite, fx: fx);
  });
  tearDown(() => sqlite.close());

  group('spent', () {
    test('posted expenses in scope, a two-tag row counted once, nothing else', () async {
      final card = await _wallet('Card');
      final cash = await _wallet('Cash');
      await _expense(card, 1000, DateTime(2026, 3, 2, 12), tags: ['food']);
      await _expense(card, 500, DateTime(2026, 3, 3, 12), tags: ['food', 'market']);
      await _expense(cash, 700, DateTime(2026, 3, 4, 12), tags: ['food']);
      await _expense(card, 300, DateTime(2026, 3, 5, 12));
      await _expense(card, 200, DateTime(2026, 2, 27, 12), tags: ['food']); // previous period
      final gone = await _expense(card, 50, DateTime(2026, 3, 6, 12), tags: ['food']);
      await transactions.softDelete(gone.id);
      await transactions.create(
        TransactionDraft.income(
          walletId: card.id,
          amount: const Money(9999, CurrencyType.eur),
          description: '',
          tags: const ['food'],
          date: DateTime(2026, 3, 6, 12),
          repeat: RepeatFrequency.never,
        ),
      );
      await transactions.create(
        TransactionDraft.transfer(
          fromWalletId: card.id,
          toWalletId: cash.id,
          sent: const Money(400, CurrencyType.eur),
          received: const Money(400, CurrencyType.eur),
          description: '',
          tags: const ['food'],
          date: DateTime(2026, 3, 7, 12),
          repeat: RepeatFrequency.never,
        ),
      );
      final food = await _tagId('food');
      final market = await _tagId('market');

      final byTags = await _progress(await _budget(_draft(tagIds: {food, market})));
      expect(byTags.spent.minor, 2200, reason: 'any wallet, ANY tag, once per row');

      final byWallet = await _progress(await _budget(_draft(walletIds: {card.id})));
      expect(byWallet.spent.minor, 1800, reason: 'income, transfers, deleted and last month excluded');

      final both = await _progress(await _budget(_draft(walletIds: {card.id}, tagIds: {food})));
      expect(both.spent.minor, 1500);

      final all = await _progress(await _budget(_draft()));
      expect(all.spent.minor, 2500);
      expect(all.remaining.minor, 100000 - 2500);
      expect(all.isCurrent, isTrue);
      expect(all.incomplete, isFalse);
    });

    test('upcoming rows are planned, not spent', () async {
      final card = await _wallet('Card');
      final soon = await _expense(card, 4000, DateTime(2026, 3, 20, 12));
      final stale = await _expense(card, 900, DateTime(2026, 3, 10, 12));
      await sqlite.db.update('transactions', {'status': 'upcoming'}, where: 'id IN (?, ?)', whereArgs: [soon.id, stale.id]);

      final p = await _progress(await _budget(_draft()));
      expect(p.spent.minor, 0);
      expect(p.planned.minor, 4000, reason: 'only upcoming rows dated from now on');
      expect(p.free.minor, 96000);

      final off = await _progress(await _budget(_draft(includePlanned: false)));
      expect(off.planned.minor, 0);
    });

    test('debt money never counts', () async {
      final card = await _wallet('Card');
      await _expense(card, 1000, DateTime(2026, 3, 2, 12));
      await _expense(
        card,
        5000,
        DateTime(2026, 3, 3, 12),
        debt: const DebtIntent.auto(person: PersonRef.create('Ahmed')),
      );
      expect((await _progress(await _budget(_draft()))).spent.minor, 1000);
    });

    test('other currencies use cached rates; missing rates flag incomplete', () async {
      final card = await _wallet('Card');
      final usd = await _wallet('Dollars', CurrencyType.usd);
      await _expense(card, 1000, DateTime(2026, 3, 2, 12));
      await _expense(usd, 1000, DateTime(2026, 3, 2, 12));
      final b = await _budget(_draft());

      final offline = await _progress(b);
      expect(offline.spent.minor, 1000);
      expect(offline.incomplete, isTrue);

      fx.rates[(CurrencyType.usd, CurrencyType.eur)] = 0.9;
      final online = await _progress(b);
      expect(online.spent.minor, 1900);
      expect(online.incomplete, isFalse);
      expect(fx.networkCalls, 0, reason: 'reads never hit the network');
    });
  });

  group('planned subscriptions', () {
    test('future occurrences inside the running period, paused rules ignored', () async {
      final m = await _wallet('Monthly in');
      final n = await _wallet('Monthly out');
      final d = await _wallet('Daily');
      final p = await _wallet('Paused');
      await _expense(m, 1500, DateTime(2026, 2, 20, 12), repeat: RepeatFrequency.monthly); // next Mar 20
      await _expense(n, 1500, DateTime(2026, 3, 5, 12), repeat: RepeatFrequency.monthly); // next Apr 5
      await _expense(d, 100, DateTime(2026, 3, 10, 12), repeat: RepeatFrequency.daily); // next Mar 11
      final paused = await _expense(p, 100, DateTime(2026, 3, 10, 12), repeat: RepeatFrequency.daily);
      await transactions.setRuleActive(paused.recurringRuleId!, false);

      Future<int> planned(WalletModel w) async => (await _progress(await _budget(_draft(walletIds: {w.id})))).planned.minor;

      expect(await planned(m), 1500);
      expect(await planned(n), 0);
      expect(await planned(d), 1700, reason: 'Mar 15 … Mar 31 at 12:00 = 17 days');
      expect(await planned(p), 0);
    });

    test('a past period has no planned, per-day or pace', () async {
      final d = await _wallet('Daily');
      await _expense(d, 100, DateTime(2026, 3, 10, 12), repeat: RepeatFrequency.daily);
      await _expense(d, 3000, DateTime(2026, 2, 10, 12));
      final b = await _budget(_draft(walletIds: {d.id}, anchor: DateTime(2026, 1, 1)));
      final feb = await _progress(b, offset: -1);
      expect(feb.period.start, DateTime(2026, 2, 1));
      expect(feb.isCurrent, isFalse);
      expect(feb.planned.minor, 0);
      expect(feb.perDay, isNull);
      expect(feb.spent.minor, 3000);
      expect(feb.daysLeft, 0);
    });
  });

  group('rollover', () {
    test('carry looks back 12 periods at most', () async {
      final b = await _budget(_draft(limit: 10000, anchor: DateTime(2025, 1, 1), rollover: RolloverMode.surplus));
      final p = await _progress(b);
      expect(p.period.index, 14);
      expect(p.carry.minor, 120000, reason: '12 untouched months, not 14');
      expect(p.limit.minor, 130000);
    });

    test('both carries overspend into the next period', () async {
      final card = await _wallet('Card');
      await _expense(card, 15000, DateTime(2026, 1, 10, 12));
      await _expense(card, 2000, DateTime(2026, 2, 10, 12));
      final b = await _budget(_draft(limit: 10000, anchor: DateTime(2026, 1, 1), rollover: RolloverMode.both));
      final p = await _progress(b);
      expect(p.carry.minor, 3000, reason: '−5000, then 5000 − 2000');
      expect(p.limit.minor, 13000);

      final surplus = await _budget(_draft(limit: 10000, anchor: DateTime(2026, 1, 1), rollover: RolloverMode.surplus));
      expect((await _progress(surplus)).carry.minor, 8000, reason: '0, then 10000 − 2000');
    });
  });

  group('impactOf', () {
    test('matching current budgets, most severe first; non-expenses and backdated rows ignored', () async {
      final card = await _wallet('Card');
      final cash = await _wallet('Cash');
      await _expense(card, 1000, DateTime(2026, 3, 2, 12), tags: ['food']);
      final food = await _tagId('food');
      final tight = await _budget(_draft(name: 'Tight', limit: 1500, tagIds: {food}));
      final loose = await _budget(_draft(name: 'Card', walletIds: {card.id}));
      await _budget(_draft(name: 'Cash only', walletIds: {cash.id}));

      final tx = await _expense(card, 900, DateTime(2026, 3, 14, 12), tags: ['Food']);
      final impact = (await budgets.impactOf(tx.id, now: now)).getOrThrow();
      expect(impact.map((p) => p.budget.id), [tight.id, loose.id]);
      expect(impact.first.status, BudgetStatus.over);
      expect(impact.first.remaining.minor, -400);

      final old = await _expense(card, 100, DateTime(2026, 2, 2, 12), tags: ['food']);
      expect((await budgets.impactOf(old.id, now: now)).getOrThrow(), isEmpty);

      final income = (await transactions.create(
        TransactionDraft.income(
          walletId: card.id,
          amount: const Money(100, CurrencyType.eur),
          description: '',
          tags: const ['food'],
          date: DateTime(2026, 3, 14, 12),
          repeat: RepeatFrequency.never,
        ),
      ))
          .getOrThrow();
      expect((await budgets.impactOf(income.id, now: now)).getOrThrow(), isEmpty);
    });
  });

  group('suggestion', () {
    test('average of the last 3 complete periods, rounded up', () async {
      final card = await _wallet('Card');
      await _expense(card, 10000, DateTime(2025, 12, 10, 12));
      await _expense(card, 30000, DateTime(2026, 1, 10, 12));
      await _expense(card, 99999, DateTime(2026, 3, 2, 12)); // running period: ignored

      final s = (await budgets.suggestLimit(
        walletIds: {card.id},
        tagIds: const {},
        period: BudgetPeriodType.monthly,
        anchorDate: DateTime(2026, 3, 1),
        currency: CurrencyType.eur,
        now: now,
      ))
          .getOrThrow();
      expect(s, const Money(14000, CurrencyType.eur), reason: '40000 / 3 = 133.33 → 140');
    });

    test('nothing when the history is empty, or for one-time budgets', () async {
      final card = await _wallet('Card');
      Future<Money?> suggest(BudgetPeriodType period) async => (await budgets.suggestLimit(
            walletIds: {card.id},
            tagIds: const {},
            period: period,
            anchorDate: DateTime(2026, 3, 1),
            currency: CurrencyType.eur,
            now: now,
          ))
              .getOrThrow();
      expect(await suggest(BudgetPeriodType.monthly), isNull);
      await _expense(card, 5000, DateTime(2026, 2, 10, 12));
      expect(await suggest(BudgetPeriodType.custom), isNull);
      expect(await suggest(BudgetPeriodType.weekly), isNull, reason: 'February is outside the last 3 weeks');
    });
  });

  group('invariants', () {
    test('wallet delete unlinks it and deletes budgets left with no wallet', () async {
      final card = await _wallet('Card');
      final cash = await _wallet('Cash');
      final onlyCard = await _budget(_draft(walletIds: {card.id}));
      final both = await _budget(_draft(walletIds: {card.id, cash.id}));
      final all = await _budget(_draft());

      final outcome = (await wallets.softDelete(card.id)).getOrThrow();
      expect(outcome.removedBudgets, 1);
      expect((await budgets.byId(onlyCard.id)).tryGetError(), isA<NotFoundFailure>());
      expect((await budgets.byId(both.id)).getOrThrow().walletIds, {cash.id});
      expect((await budgets.byId(all.id)).getOrThrow().walletIds, isEmpty, reason: 'never widened, never deleted');
    });

    test('tag merge moves budget scopes', () async {
      final card = await _wallet('Card');
      await _expense(card, 100, DateTime(2026, 3, 2, 12), tags: ['food', 'market']);
      final food = await _tagId('food');
      final market = await _tagId('market');
      final onlyMarket = await _budget(_draft(tagIds: {market}));
      final both = await _budget(_draft(tagIds: {food, market}));

      await tags.rename(market, 'Food');
      expect((await budgets.byId(onlyMarket.id)).getOrThrow().tagIds, {food});
      expect((await budgets.byId(both.id)).getOrThrow().tagIds, {food});
      expect(await _count('SELECT COUNT(*) FROM budget_tags'), 2);
    });

    test('tag delete unlinks it and deletes budgets left with no tag', () async {
      final card = await _wallet('Card');
      await _expense(card, 100, DateTime(2026, 3, 2, 12), tags: ['food', 'market']);
      final food = await _tagId('food');
      final market = await _tagId('market');
      final onlyFood = await _budget(_draft(tagIds: {food}));
      final both = await _budget(_draft(tagIds: {food, market}));

      expect((await tags.delete(food)).getOrThrow(), 1);
      expect((await budgets.byId(onlyFood.id)).tryGetError(), isA<NotFoundFailure>());
      expect((await budgets.byId(both.id)).getOrThrow().tagIds, {market});
    });

    test('validation', () async {
      final card = await _wallet('Card');
      Future<Failure?> err(BudgetDraft d) async => (await budgets.create(d)).tryGetError();

      expect(await err(_draft(limit: 0)), isA<ValidationFailure>());
      expect(await err(_draft(name: '   ')), isA<ValidationFailure>());
      expect(await err(_draft(name: 'x' * 41)), isA<ValidationFailure>());
      expect(
        await err(_draft(period: BudgetPeriodType.custom, anchor: DateTime(2026, 3, 10), end: DateTime(2026, 3, 10))),
        isA<ValidationFailure>(),
      );
      await wallets.softDelete(card.id);
      expect(await err(_draft(walletIds: {card.id})), isA<ValidationFailure>());
    });

    test('custom budgets never roll over; delete + restore', () async {
      final b = await _budget(
        _draft(
          period: BudgetPeriodType.custom,
          anchor: DateTime(2026, 4, 1),
          end: DateTime(2026, 4, 16),
          rollover: RolloverMode.both,
        ),
      );
      expect(b.rollover, RolloverMode.none);
      final p = await _progress(b);
      expect(p.status, BudgetStatus.notStarted);
      expect(p.planned.minor, 0);

      final deletedAt = (await budgets.delete(b.id)).getOrThrow();
      expect((await budgets.listProgress(now: now)).getOrThrow(), isEmpty);
      await budgets.restore(b.id, deletedAt);
      expect((await budgets.listProgress(now: now)).getOrThrow().single.budget.id, b.id);
    });
  });
}
