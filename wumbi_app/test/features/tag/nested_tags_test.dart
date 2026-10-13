import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' show Sqflite;
import 'package:wumbi/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:wumbi/src/core/money/currency_type.dart';
import 'package:wumbi/src/core/money/money.dart';
import 'package:wumbi/src/core/utils/enums/repeat_frequency.dart';
import 'package:wumbi/src/core/utils/enums/wallet_color.dart';
import 'package:wumbi/src/features/tag/data/models/tag_stats.dart';
import 'package:wumbi/src/features/tag/data/models/tag_tree.dart';
import 'package:wumbi/src/features/tag/data/tag_repository.dart';
import 'package:wumbi/src/features/transaction/data/models/transaction_model.dart';
import 'package:wumbi/src/features/transaction/data/transaction_repository.dart';
import 'package:wumbi/src/features/wallet/data/models/wallet_model.dart';
import 'package:wumbi/src/features/wallet/data/wallet_repository.dart';

import '../../helpers/test_db.dart';

/// Obsidian-style nested tags: `food/coffee` lives inside `food`, parents
/// roll their nested tags up, rename / delete carry the subtree.
late SQLiteServicesImpl sqlite;
late WalletRepository wallets;
late TagRepository tags;
late TransactionRepository transactions;

Future<void> _openFresh() async {
  sqlite = ffiSqlite(inMemoryDatabasePath);
  await sqlite.initDatabase();
  wallets = WalletRepository(sqlite: sqlite, onWrite: () {});
  tags = TagRepository(sqlite: sqlite);
  transactions = TransactionRepository(sqlite: sqlite, tags: tags, onWrite: () {});
}

Future<WalletModel> _wallet() async => (await wallets.create(
      const WalletDraft(name: 'A', currency: CurrencyType.usd, initialBalanceMinor: 0, color: WalletColor.blue, isPrimary: true),
    ))
        .getOrThrow();

TransactionDraft _expense(String walletId, int minor, List<String> tagNames) => TransactionDraft.expense(
      walletId: walletId,
      amount: Money(minor, CurrencyType.usd),
      description: '',
      tags: tagNames,
      date: DateTime(2026, 1, 11, 12),
      repeat: RepeatFrequency.never,
    );

Future<int> _count(String sql, [List<Object?> args = const []]) async =>
    Sqflite.firstIntValue(await sqlite.db.rawQuery(sql, args)) ?? 0;

Future<Map<String, TagStats>> _stats() async =>
    {for (final s in (await tags.stats(CurrencyType.usd)).getOrThrow()) s.tag.normalizedName: s};

void main() {
  setUpAll(() => sqfliteFfiInit());
  setUp(_openFresh);
  tearDown(() => sqlite.close());

  test('a nested tag creates its parents', () async {
    final w = await _wallet();
    await transactions.create(_expense(w.id, 100, ['Food/Coffee/Latte']));
    expect(await _count('SELECT COUNT(*) FROM tags WHERE deleted_at IS NULL'), 3);
    expect(await _count("SELECT usage_count FROM tags WHERE normalized_name = 'food'"), 0);
    expect(await _count("SELECT usage_count FROM tags WHERE normalized_name = 'food/coffee/latte'"), 1);
  });

  test('parents roll up nested tags, each transaction once', () async {
    final w = await _wallet();
    await transactions.create(_expense(w.id, 2000, ['food/coffee']));
    await transactions.create(_expense(w.id, 8000, ['food/groceries']));
    await transactions.create(_expense(w.id, 500, ['food', 'food/coffee']));
    await transactions.create(_expense(w.id, 999, ['foodtruck']));

    final s = await _stats();
    expect(s['food']!.expense.minor, 10500);
    expect(s['food']!.transactionCount, 3);
    expect(s['food/coffee']!.expense.minor, 2500);
    expect(s['foodtruck']!.expense.minor, 999, reason: 'a shared prefix is not nesting');

    final foodId = s['food']!.id;
    final rows = (await transactions.pageForTag(foodId)).getOrThrow();
    expect(rows.length, 3);

    final tree = TagTree.build(s.values.toList());
    final food = tree.firstWhere((n) => n.normalizedName == 'food');
    expect(food.children.map((c) => c.normalizedName).toSet(), {'food/coffee', 'food/groceries'});
    expect(food.descendantCount, 2);
  });

  test('renaming a parent renames its nested tags and merges clashes', () async {
    final w = await _wallet();
    await transactions.create(_expense(w.id, 100, ['food/coffee']));
    await transactions.create(_expense(w.id, 100, ['meals/coffee']));
    final food = (await _stats())['food']!;

    final renamed = (await tags.rename(food.id, 'meals')).getOrThrow();
    expect(renamed.normalizedName, 'meals');
    final s = await _stats();
    expect(s.keys.toSet(), {'meals', 'meals/coffee'});
    expect(s['meals/coffee']!.transactionCount, 2);
  });

  test('moving a tag under another parent', () async {
    final w = await _wallet();
    await transactions.create(_expense(w.id, 100, ['coffee']));
    final coffee = (await _stats())['coffee']!;
    final moved = (await tags.rename(coffee.id, 'food/coffee')).getOrThrow();
    expect(moved.id, coffee.id);
    expect((await _stats()).keys.toSet(), {'food', 'food/coffee'});
    expect((await tags.rename(coffee.id, 'food/coffee/x')).isError(), isTrue, reason: 'no moving inside itself');
  });

  test('deleting a parent deletes its nested tags', () async {
    final w = await _wallet();
    await transactions.create(_expense(w.id, 100, ['food/coffee', 'travel']));
    final food = (await _stats())['food']!;
    expect((await tags.delete(food.id)).isSuccess(), isTrue);
    expect((await _stats()).keys.toSet(), {'travel'});
    expect(await _count('SELECT COUNT(*) FROM transaction_tags'), 1);
  });

  test('create from the tags page, existing name is reused', () async {
    final first = (await tags.create('#Home/Utilities')).getOrThrow();
    expect(first.created, isTrue);
    expect(first.tag.displayName, 'Home/Utilities');
    final again = (await tags.create('home/utilities')).getOrThrow();
    expect(again.created, isFalse);
    expect(again.tag.id, first.tag.id);
    expect(await tags.suggest('home'), containsAll(['Home', 'Home/Utilities']));
  });

  test('repairHierarchy adds parents missing from older data', () async {
    final w = await _wallet();
    await transactions.create(_expense(w.id, 100, ['a/b']));
    await sqlite.db.rawUpdate("UPDATE tags SET deleted_at = 1 WHERE normalized_name = 'a'");
    await tags.repairHierarchy();
    expect(await _count("SELECT COUNT(*) FROM tags WHERE normalized_name = 'a' AND deleted_at IS NULL"), 1);
  });
}
