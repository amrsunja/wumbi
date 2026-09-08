import 'package:sqflite_sqlcipher/sqflite.dart';

typedef Migration = Future<void> Function(DatabaseExecutor db);

/// Ordered list of migrations. `migrations[i]` upgrades the schema from
/// version `i + 1` to `i + 2`. `onUpgrade(db, old, new)` runs
/// `migrations[old - 1 .. new - 2]` inside one transaction.
///
/// A fresh install runs `SQLiteSchema.latest` in `onCreate` and never touches
/// this list.
abstract class SQLiteMigrations {
  static const List<Migration> migrations = [_v1ToV2];

  static Future<void> upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion >= newVersion) return;
    await db.transaction((txn) async {
      for (var v = oldVersion; v < newVersion; v++) {
        final index = v - 1;
        if (index < 0 || index >= migrations.length) continue;
        await migrations[index](txn);
      }
    });
  }

  /// v2 (2026-09):
  /// * `wallets` rebuilt without the 5-colour CHECK (20 swatches now).
  /// * `transactions.status` — 'posted' (default) | 'upcoming' (future-dated,
  ///   user-created; does not move money until its date arrives).
  /// * `wallet_balances` recreated to count posted rows only.
  ///
  /// The table rebuild follows the SQLite "12-step" ALTER pattern. Foreign
  /// keys from `transactions` / `recurring_rules` reference `wallets(id)` by
  /// name, so a same-named replacement keeps them valid — provided
  /// `PRAGMA foreign_keys` is OFF while the old table is dropped (otherwise
  /// the implicit DELETE fails). `SQLiteServicesImpl` turns it off in
  /// `onConfigure` when an upgrade is pending and back on after opening.
  static Future<void> _v1ToV2(DatabaseExecutor db) async {
    // 1. wallets → drop CHECK on color.
    await db.execute('''
      CREATE TABLE wallets_v2 (
        id                    TEXT PRIMARY KEY,
        name                  TEXT    NOT NULL,
        currency              TEXT    NOT NULL,
        initial_balance_minor INTEGER NOT NULL DEFAULT 0,
        color                 TEXT    NOT NULL DEFAULT 'blue',
        is_primary            INTEGER NOT NULL DEFAULT 0,
        sort_order            INTEGER NOT NULL DEFAULT 0,
        created_at            INTEGER NOT NULL,
        updated_at            INTEGER NOT NULL,
        deleted_at            INTEGER,
        sync_status           TEXT    NOT NULL DEFAULT 'pending'
      )''');
    await db.execute('''
      INSERT INTO wallets_v2
        (id, name, currency, initial_balance_minor, color, is_primary, sort_order, created_at, updated_at, deleted_at, sync_status)
      SELECT id, name, currency, initial_balance_minor, color, is_primary, sort_order, created_at, updated_at, deleted_at, sync_status
      FROM wallets''');
    await db.execute('DROP VIEW IF EXISTS wallet_balances');
    await db.execute('DROP TABLE wallets');
    await db.execute('ALTER TABLE wallets_v2 RENAME TO wallets');
    await db.execute('CREATE INDEX idx_wallets_deleted ON wallets(deleted_at)');
    await db.execute('CREATE INDEX idx_wallets_sort ON wallets(sort_order, created_at)');
    await db.execute(
      'CREATE UNIQUE INDEX idx_wallets_primary ON wallets(is_primary) WHERE is_primary = 1 AND deleted_at IS NULL',
    );

    // 2. transactions.status
    await db.execute(
      "ALTER TABLE transactions ADD COLUMN status TEXT NOT NULL DEFAULT 'posted' CHECK (status IN ('posted','upcoming'))",
    );
    await db.execute('CREATE INDEX idx_tx_status_date ON transactions(status, transaction_date)');

    // 3. view — posted rows only.
    await db.execute('''
      CREATE VIEW wallet_balances AS
      SELECT
        w.id       AS wallet_id,
        w.currency AS currency,
        w.initial_balance_minor
          + COALESCE((SELECT SUM(t.amount_minor)      FROM transactions t WHERE t.wallet_id      = w.id AND t.type = 'income'   AND t.status = 'posted' AND t.deleted_at IS NULL), 0)
          - COALESCE((SELECT SUM(t.amount_minor)      FROM transactions t WHERE t.wallet_id      = w.id AND t.type = 'expense'  AND t.status = 'posted' AND t.deleted_at IS NULL), 0)
          - COALESCE((SELECT SUM(t.from_amount_minor) FROM transactions t WHERE t.from_wallet_id = w.id AND t.type = 'transfer' AND t.status = 'posted' AND t.deleted_at IS NULL), 0)
          + COALESCE((SELECT SUM(t.to_amount_minor)   FROM transactions t WHERE t.to_wallet_id   = w.id AND t.type = 'transfer' AND t.status = 'posted' AND t.deleted_at IS NULL), 0)
                   AS balance_minor
      FROM wallets w
      WHERE w.deleted_at IS NULL''');
  }
}
