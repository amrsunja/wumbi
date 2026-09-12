/// Full DDL per schema version (spec Appendix A).
///
/// `onCreate` runs [latest] as one batch; existing installs reach the same
/// shape through `SQLiteMigrations`. [v1] is kept verbatim so the v1→v2
/// migration can be tested against a real v1 database.
abstract class SQLiteSchema {
  static final List<String> latest = v3;

  /// v3 (2026-09): `settings.show_mascot` — the mascot can be hidden app-wide.
  static final List<String> v3 = SQLiteSchemaV3.statements;

  /// v2 (2026-09): `wallets.color` is a free key (20 swatches, validated in
  /// Dart), `transactions.status` ('posted' | 'upcoming'), and the balance
  /// view only counts posted rows.
  static const List<String> v2 = [
    ...SQLiteSchemaV2.statements,
  ];

  static const List<String> v1 = [
    // 1. settings ---------------------------------------------------------
    '''
    CREATE TABLE settings (
      id                    INTEGER PRIMARY KEY CHECK (id = 1),
      language_code         TEXT,
      country_code          TEXT,
      theme_mode            TEXT    NOT NULL DEFAULT 'system' CHECK (theme_mode IN ('system','light','dark')),
      show_onboarding       INTEGER NOT NULL DEFAULT 1,
      base_currency         TEXT    NOT NULL DEFAULT 'USD',
      notifications_enabled INTEGER NOT NULL DEFAULT 0,
      last_recurring_run_at INTEGER
    )''',
    'INSERT INTO settings (id) VALUES (1)',

    // 2. wallets ----------------------------------------------------------
    '''
    CREATE TABLE wallets (
      id                    TEXT PRIMARY KEY,
      name                  TEXT    NOT NULL,
      currency              TEXT    NOT NULL,
      initial_balance_minor INTEGER NOT NULL DEFAULT 0,
      color                 TEXT    NOT NULL DEFAULT 'blue' CHECK (color IN ('blue','amber','red','green','violet')),
      is_primary            INTEGER NOT NULL DEFAULT 0,
      sort_order            INTEGER NOT NULL DEFAULT 0,
      created_at            INTEGER NOT NULL,
      updated_at            INTEGER NOT NULL,
      deleted_at            INTEGER,
      sync_status           TEXT    NOT NULL DEFAULT 'pending'
    )''',
    'CREATE INDEX idx_wallets_deleted ON wallets(deleted_at)',
    'CREATE INDEX idx_wallets_sort ON wallets(sort_order, created_at)',
    'CREATE UNIQUE INDEX idx_wallets_primary ON wallets(is_primary) WHERE is_primary = 1 AND deleted_at IS NULL',

    // 3. tags -------------------------------------------------------------
    '''
    CREATE TABLE tags (
      id              TEXT PRIMARY KEY,
      normalized_name TEXT    NOT NULL,
      display_name    TEXT    NOT NULL,
      usage_count     INTEGER NOT NULL DEFAULT 0,
      last_used_at    INTEGER,
      created_at      INTEGER NOT NULL,
      updated_at      INTEGER NOT NULL,
      deleted_at      INTEGER,
      sync_status     TEXT    NOT NULL DEFAULT 'pending'
    )''',
    'CREATE UNIQUE INDEX idx_tags_normalized_active ON tags(normalized_name) WHERE deleted_at IS NULL',
    'CREATE INDEX idx_tags_usage ON tags(usage_count DESC, last_used_at DESC)',

    // 4. recurring_rules --------------------------------------------------
    '''
    CREATE TABLE recurring_rules (
      id                TEXT PRIMARY KEY,
      type              TEXT    NOT NULL CHECK (type IN ('income','expense','transfer')),
      wallet_id         TEXT REFERENCES wallets(id),
      amount_minor      INTEGER,
      currency          TEXT    NOT NULL,
      from_wallet_id    TEXT REFERENCES wallets(id),
      to_wallet_id      TEXT REFERENCES wallets(id),
      from_amount_minor INTEGER,
      to_amount_minor   INTEGER,
      exchange_rate     REAL,
      description       TEXT    NOT NULL DEFAULT '',
      frequency         TEXT    NOT NULL CHECK (frequency IN ('daily','weekly','monthly','yearly')),
      interval          INTEGER NOT NULL DEFAULT 1 CHECK (interval >= 1),
      start_date        INTEGER NOT NULL,
      next_occurrence   INTEGER NOT NULL,
      occurrence_count  INTEGER NOT NULL DEFAULT 1,
      end_date          INTEGER,
      is_active         INTEGER NOT NULL DEFAULT 1,
      created_at        INTEGER NOT NULL,
      updated_at        INTEGER NOT NULL,
      deleted_at        INTEGER,
      sync_status       TEXT    NOT NULL DEFAULT 'pending',
      CHECK (
        (type IN ('income','expense') AND wallet_id IS NOT NULL AND amount_minor IS NOT NULL AND amount_minor >= 0
           AND from_wallet_id IS NULL AND to_wallet_id IS NULL)
        OR
        (type = 'transfer' AND from_wallet_id IS NOT NULL AND to_wallet_id IS NOT NULL AND from_wallet_id <> to_wallet_id
           AND from_amount_minor IS NOT NULL AND to_amount_minor IS NOT NULL
           AND from_amount_minor >= 0 AND to_amount_minor >= 0
           AND wallet_id IS NULL AND amount_minor IS NULL)
      )
    )''',
    'CREATE INDEX idx_rules_due ON recurring_rules(is_active, next_occurrence)',
    'CREATE INDEX idx_rules_wallet ON recurring_rules(wallet_id)',
    'CREATE INDEX idx_rules_deleted ON recurring_rules(deleted_at)',

    // 5. transactions -----------------------------------------------------
    '''
    CREATE TABLE transactions (
      id                    TEXT PRIMARY KEY,
      type                  TEXT    NOT NULL CHECK (type IN ('income','expense','transfer')),
      wallet_id             TEXT REFERENCES wallets(id),
      amount_minor          INTEGER,
      currency              TEXT    NOT NULL,
      from_wallet_id        TEXT REFERENCES wallets(id),
      to_wallet_id          TEXT REFERENCES wallets(id),
      from_amount_minor     INTEGER,
      to_amount_minor       INTEGER,
      original_amount_minor INTEGER,
      original_currency     TEXT,
      exchange_rate         REAL,
      description           TEXT    NOT NULL DEFAULT '',
      transaction_date      INTEGER NOT NULL,
      recurring_rule_id     TEXT REFERENCES recurring_rules(id),
      created_at            INTEGER NOT NULL,
      updated_at            INTEGER NOT NULL,
      deleted_at            INTEGER,
      sync_status           TEXT    NOT NULL DEFAULT 'pending',
      CHECK (
        (type IN ('income','expense') AND wallet_id IS NOT NULL AND amount_minor IS NOT NULL AND amount_minor >= 0
           AND from_wallet_id IS NULL AND to_wallet_id IS NULL)
        OR
        (type = 'transfer' AND from_wallet_id IS NOT NULL AND to_wallet_id IS NOT NULL AND from_wallet_id <> to_wallet_id
           AND from_amount_minor IS NOT NULL AND to_amount_minor IS NOT NULL
           AND from_amount_minor >= 0 AND to_amount_minor >= 0
           AND wallet_id IS NULL AND amount_minor IS NULL)
      ),
      CHECK ((original_amount_minor IS NULL) = (original_currency IS NULL))
    )''',
    'CREATE INDEX idx_tx_wallet_date ON transactions(wallet_id, transaction_date DESC)',
    'CREATE INDEX idx_tx_from_date ON transactions(from_wallet_id, transaction_date DESC)',
    'CREATE INDEX idx_tx_to_date ON transactions(to_wallet_id, transaction_date DESC)',
    'CREATE INDEX idx_tx_date ON transactions(transaction_date DESC)',
    'CREATE INDEX idx_tx_deleted ON transactions(deleted_at)',
    'CREATE INDEX idx_tx_updated ON transactions(updated_at)',
    'CREATE UNIQUE INDEX idx_tx_rule_date ON transactions(recurring_rule_id, transaction_date) WHERE recurring_rule_id IS NOT NULL',

    // 6. link tables ------------------------------------------------------
    '''
    CREATE TABLE transaction_tags (
      transaction_id TEXT    NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
      tag_id         TEXT    NOT NULL REFERENCES tags(id)         ON DELETE CASCADE,
      created_at     INTEGER NOT NULL,
      PRIMARY KEY (transaction_id, tag_id)
    )''',
    'CREATE INDEX idx_tt_tag ON transaction_tags(tag_id)',
    '''
    CREATE TABLE recurring_rule_tags (
      recurring_rule_id TEXT    NOT NULL REFERENCES recurring_rules(id) ON DELETE CASCADE,
      tag_id            TEXT    NOT NULL REFERENCES tags(id)            ON DELETE CASCADE,
      created_at        INTEGER NOT NULL,
      PRIMARY KEY (recurring_rule_id, tag_id)
    )''',
    'CREATE INDEX idx_rrt_tag ON recurring_rule_tags(tag_id)',

    // 7. exchange_rates ---------------------------------------------------
    '''
    CREATE TABLE exchange_rates (
      base_currency  TEXT NOT NULL,
      quote_currency TEXT NOT NULL,
      rate           REAL NOT NULL,
      fetched_at     INTEGER NOT NULL,
      PRIMARY KEY (base_currency, quote_currency)
    )''',

    // 8. view -------------------------------------------------------------
    '''
    CREATE VIEW wallet_balances AS
    SELECT
      w.id       AS wallet_id,
      w.currency AS currency,
      w.initial_balance_minor
        + COALESCE((SELECT SUM(t.amount_minor)      FROM transactions t WHERE t.wallet_id      = w.id AND t.type = 'income'   AND t.deleted_at IS NULL), 0)
        - COALESCE((SELECT SUM(t.amount_minor)      FROM transactions t WHERE t.wallet_id      = w.id AND t.type = 'expense'  AND t.deleted_at IS NULL), 0)
        - COALESCE((SELECT SUM(t.from_amount_minor) FROM transactions t WHERE t.from_wallet_id = w.id AND t.type = 'transfer' AND t.deleted_at IS NULL), 0)
        + COALESCE((SELECT SUM(t.to_amount_minor)   FROM transactions t WHERE t.to_wallet_id   = w.id AND t.type = 'transfer' AND t.deleted_at IS NULL), 0)
                 AS balance_minor
    FROM wallets w
    WHERE w.deleted_at IS NULL''',
  ];
}

/// v2 DDL, see [SQLiteSchema.v2].
abstract class SQLiteSchemaV2 {
  static const List<String> statements = [
    // 1. settings ---------------------------------------------------------
    '''
    CREATE TABLE settings (
      id                    INTEGER PRIMARY KEY CHECK (id = 1),
      language_code         TEXT,
      country_code          TEXT,
      theme_mode            TEXT    NOT NULL DEFAULT 'system' CHECK (theme_mode IN ('system','light','dark')),
      show_onboarding       INTEGER NOT NULL DEFAULT 1,
      base_currency         TEXT    NOT NULL DEFAULT 'USD',
      notifications_enabled INTEGER NOT NULL DEFAULT 0,
      last_recurring_run_at INTEGER
    )''',
    'INSERT INTO settings (id) VALUES (1)',

    // 2. wallets ----------------------------------------------------------
    '''
    CREATE TABLE wallets (
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
    )''',
    'CREATE INDEX idx_wallets_deleted ON wallets(deleted_at)',
    'CREATE INDEX idx_wallets_sort ON wallets(sort_order, created_at)',
    'CREATE UNIQUE INDEX idx_wallets_primary ON wallets(is_primary) WHERE is_primary = 1 AND deleted_at IS NULL',

    // 3. tags -------------------------------------------------------------
    '''
    CREATE TABLE tags (
      id              TEXT PRIMARY KEY,
      normalized_name TEXT    NOT NULL,
      display_name    TEXT    NOT NULL,
      usage_count     INTEGER NOT NULL DEFAULT 0,
      last_used_at    INTEGER,
      created_at      INTEGER NOT NULL,
      updated_at      INTEGER NOT NULL,
      deleted_at      INTEGER,
      sync_status     TEXT    NOT NULL DEFAULT 'pending'
    )''',
    'CREATE UNIQUE INDEX idx_tags_normalized_active ON tags(normalized_name) WHERE deleted_at IS NULL',
    'CREATE INDEX idx_tags_usage ON tags(usage_count DESC, last_used_at DESC)',

    // 4. recurring_rules --------------------------------------------------
    '''
    CREATE TABLE recurring_rules (
      id                TEXT PRIMARY KEY,
      type              TEXT    NOT NULL CHECK (type IN ('income','expense','transfer')),
      wallet_id         TEXT REFERENCES wallets(id),
      amount_minor      INTEGER,
      currency          TEXT    NOT NULL,
      from_wallet_id    TEXT REFERENCES wallets(id),
      to_wallet_id      TEXT REFERENCES wallets(id),
      from_amount_minor INTEGER,
      to_amount_minor   INTEGER,
      exchange_rate     REAL,
      description       TEXT    NOT NULL DEFAULT '',
      frequency         TEXT    NOT NULL CHECK (frequency IN ('daily','weekly','monthly','yearly')),
      interval          INTEGER NOT NULL DEFAULT 1 CHECK (interval >= 1),
      start_date        INTEGER NOT NULL,
      next_occurrence   INTEGER NOT NULL,
      occurrence_count  INTEGER NOT NULL DEFAULT 1,
      end_date          INTEGER,
      is_active         INTEGER NOT NULL DEFAULT 1,
      created_at        INTEGER NOT NULL,
      updated_at        INTEGER NOT NULL,
      deleted_at        INTEGER,
      sync_status       TEXT    NOT NULL DEFAULT 'pending',
      CHECK (
        (type IN ('income','expense') AND wallet_id IS NOT NULL AND amount_minor IS NOT NULL AND amount_minor >= 0
           AND from_wallet_id IS NULL AND to_wallet_id IS NULL)
        OR
        (type = 'transfer' AND from_wallet_id IS NOT NULL AND to_wallet_id IS NOT NULL AND from_wallet_id <> to_wallet_id
           AND from_amount_minor IS NOT NULL AND to_amount_minor IS NOT NULL
           AND from_amount_minor >= 0 AND to_amount_minor >= 0
           AND wallet_id IS NULL AND amount_minor IS NULL)
      )
    )''',
    'CREATE INDEX idx_rules_due ON recurring_rules(is_active, next_occurrence)',
    'CREATE INDEX idx_rules_wallet ON recurring_rules(wallet_id)',
    'CREATE INDEX idx_rules_deleted ON recurring_rules(deleted_at)',

    // 5. transactions -----------------------------------------------------
    '''
    CREATE TABLE transactions (
      id                    TEXT PRIMARY KEY,
      type                  TEXT    NOT NULL CHECK (type IN ('income','expense','transfer')),
      wallet_id             TEXT REFERENCES wallets(id),
      amount_minor          INTEGER,
      currency              TEXT    NOT NULL,
      from_wallet_id        TEXT REFERENCES wallets(id),
      to_wallet_id          TEXT REFERENCES wallets(id),
      from_amount_minor     INTEGER,
      to_amount_minor       INTEGER,
      original_amount_minor INTEGER,
      original_currency     TEXT,
      exchange_rate         REAL,
      description           TEXT    NOT NULL DEFAULT '',
      transaction_date      INTEGER NOT NULL,
      status                TEXT    NOT NULL DEFAULT 'posted' CHECK (status IN ('posted','upcoming')),
      recurring_rule_id     TEXT REFERENCES recurring_rules(id),
      created_at            INTEGER NOT NULL,
      updated_at            INTEGER NOT NULL,
      deleted_at            INTEGER,
      sync_status           TEXT    NOT NULL DEFAULT 'pending',
      CHECK (
        (type IN ('income','expense') AND wallet_id IS NOT NULL AND amount_minor IS NOT NULL AND amount_minor >= 0
           AND from_wallet_id IS NULL AND to_wallet_id IS NULL)
        OR
        (type = 'transfer' AND from_wallet_id IS NOT NULL AND to_wallet_id IS NOT NULL AND from_wallet_id <> to_wallet_id
           AND from_amount_minor IS NOT NULL AND to_amount_minor IS NOT NULL
           AND from_amount_minor >= 0 AND to_amount_minor >= 0
           AND wallet_id IS NULL AND amount_minor IS NULL)
      ),
      CHECK ((original_amount_minor IS NULL) = (original_currency IS NULL))
    )''',
    'CREATE INDEX idx_tx_wallet_date ON transactions(wallet_id, transaction_date DESC)',
    'CREATE INDEX idx_tx_from_date ON transactions(from_wallet_id, transaction_date DESC)',
    'CREATE INDEX idx_tx_to_date ON transactions(to_wallet_id, transaction_date DESC)',
    'CREATE INDEX idx_tx_date ON transactions(transaction_date DESC)',
    'CREATE INDEX idx_tx_deleted ON transactions(deleted_at)',
    'CREATE INDEX idx_tx_status_date ON transactions(status, transaction_date)',
    'CREATE INDEX idx_tx_updated ON transactions(updated_at)',
    'CREATE UNIQUE INDEX idx_tx_rule_date ON transactions(recurring_rule_id, transaction_date) WHERE recurring_rule_id IS NOT NULL',

    // 6. link tables ------------------------------------------------------
    '''
    CREATE TABLE transaction_tags (
      transaction_id TEXT    NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
      tag_id         TEXT    NOT NULL REFERENCES tags(id)         ON DELETE CASCADE,
      created_at     INTEGER NOT NULL,
      PRIMARY KEY (transaction_id, tag_id)
    )''',
    'CREATE INDEX idx_tt_tag ON transaction_tags(tag_id)',
    '''
    CREATE TABLE recurring_rule_tags (
      recurring_rule_id TEXT    NOT NULL REFERENCES recurring_rules(id) ON DELETE CASCADE,
      tag_id            TEXT    NOT NULL REFERENCES tags(id)            ON DELETE CASCADE,
      created_at        INTEGER NOT NULL,
      PRIMARY KEY (recurring_rule_id, tag_id)
    )''',
    'CREATE INDEX idx_rrt_tag ON recurring_rule_tags(tag_id)',

    // 7. exchange_rates ---------------------------------------------------
    '''
    CREATE TABLE exchange_rates (
      base_currency  TEXT NOT NULL,
      quote_currency TEXT NOT NULL,
      rate           REAL NOT NULL,
      fetched_at     INTEGER NOT NULL,
      PRIMARY KEY (base_currency, quote_currency)
    )''',

    // 8. view — posted rows only; 'upcoming' rows do not move money yet ----
    '''
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
    WHERE w.deleted_at IS NULL''',
  ];
}

/// v3 DDL, see [SQLiteSchema.v3]. Only `settings` differs from v2, so the
/// rest of the tables are reused verbatim.
abstract class SQLiteSchemaV3 {
  static const String settingsTable = '''
    CREATE TABLE settings (
      id                    INTEGER PRIMARY KEY CHECK (id = 1),
      language_code         TEXT,
      country_code          TEXT,
      theme_mode            TEXT    NOT NULL DEFAULT 'system' CHECK (theme_mode IN ('system','light','dark')),
      show_onboarding       INTEGER NOT NULL DEFAULT 1,
      base_currency         TEXT    NOT NULL DEFAULT 'USD',
      notifications_enabled INTEGER NOT NULL DEFAULT 0,
      show_mascot           INTEGER NOT NULL DEFAULT 1,
      last_recurring_run_at INTEGER
    )''';

  static const String settingsSeed = 'INSERT INTO settings (id) VALUES (1)';

  static final List<String> statements = [
    settingsTable,
    settingsSeed,
    // v2's first two statements are its own settings table + seed row.
    ...SQLiteSchemaV2.statements.where(
      (s) => !s.contains('CREATE TABLE settings') && s != settingsSeed,
    ),
  ];
}
