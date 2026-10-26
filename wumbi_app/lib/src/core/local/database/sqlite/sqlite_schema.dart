/// Full DDL per schema version (spec Appendix A).
///
/// `onCreate` runs [latest] as one batch; existing installs reach the same
/// shape through `SQLiteMigrations`. [v1] is kept verbatim so the v1→v2
/// migration can be tested against a real v1 database.
abstract class SQLiteSchema {
  static final List<String> latest = v6;

  /// v6 (2026-10): `settings.mascot_talks` and the `mascot_memory` table
  /// (hamster companion: shown messages, milestones, visits).
  static final List<String> v6 = SQLiteSchemaV6.statements;

  /// v5 (2026-10): `wallets.include_in_total` (Dashboard total opt-out).
  static final List<String> v5 = SQLiteSchemaV5.statements;

  /// v4 (2026-10): budgets (+ wallet / tag scope links), people, debts,
  /// debt payments, and `transactions.debt_role`.
  static final List<String> v4 = SQLiteSchemaV4.statements;

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

/// v4 DDL, see [SQLiteSchema.v4]. `transactions` gains `debt_role` inline
/// (a fresh install never runs `ALTER TABLE`, exactly like v2 inlined
/// `status`); everything else in v3 is reused verbatim and the budget / debt
/// tables are appended. [budgetsAndDebts] is shared with the v3 → v4
/// migration so both paths create byte-identical new tables.
abstract class SQLiteSchemaV4 {
  static const String transactionsTable = '''
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
      debt_role             TEXT CHECK (debt_role IN ('principal','repayment')),
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
    )''';

  static const String debtRoleIndex =
      'CREATE INDEX idx_tx_debt_role ON transactions(debt_role) WHERE debt_role IS NOT NULL';

  /// New tables of v4 (spec Appendix A.1), in FK order.
  static const List<String> budgetsAndDebts = [
    // budgets -------------------------------------------------------------
    '''
    CREATE TABLE budgets (
      id               TEXT PRIMARY KEY,
      name             TEXT    NOT NULL,
      limit_minor      INTEGER NOT NULL CHECK (limit_minor > 0),
      currency         TEXT    NOT NULL,
      period           TEXT    NOT NULL CHECK (period IN ('weekly','monthly','yearly','custom')),
      anchor_date      INTEGER NOT NULL,
      end_date         INTEGER,
      rollover         TEXT    NOT NULL DEFAULT 'none' CHECK (rollover IN ('none','surplus','both')),
      include_planned  INTEGER NOT NULL DEFAULT 1,
      sort_order       INTEGER NOT NULL DEFAULT 0,
      created_at       INTEGER NOT NULL,
      updated_at       INTEGER NOT NULL,
      deleted_at       INTEGER,
      sync_status      TEXT    NOT NULL DEFAULT 'pending',
      CHECK ((period = 'custom') = (end_date IS NOT NULL)),
      CHECK (end_date IS NULL OR end_date > anchor_date),
      CHECK (period <> 'custom' OR rollover = 'none')
    )''',
    'CREATE INDEX idx_budgets_deleted ON budgets(deleted_at)',
    '''
    CREATE TABLE budget_wallets (
      budget_id  TEXT    NOT NULL REFERENCES budgets(id) ON DELETE CASCADE,
      wallet_id  TEXT    NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
      created_at INTEGER NOT NULL,
      PRIMARY KEY (budget_id, wallet_id)
    )''',
    'CREATE INDEX idx_bw_wallet ON budget_wallets(wallet_id)',
    '''
    CREATE TABLE budget_tags (
      budget_id  TEXT    NOT NULL REFERENCES budgets(id) ON DELETE CASCADE,
      tag_id     TEXT    NOT NULL REFERENCES tags(id)    ON DELETE CASCADE,
      created_at INTEGER NOT NULL,
      PRIMARY KEY (budget_id, tag_id)
    )''',
    'CREATE INDEX idx_bt_tag ON budget_tags(tag_id)',

    // people / debts ------------------------------------------------------
    '''
    CREATE TABLE people (
      id              TEXT PRIMARY KEY,
      name            TEXT    NOT NULL,
      normalized_name TEXT    NOT NULL,
      last_used_at    INTEGER,
      created_at      INTEGER NOT NULL,
      updated_at      INTEGER NOT NULL,
      deleted_at      INTEGER,
      sync_status     TEXT    NOT NULL DEFAULT 'pending'
    )''',
    'CREATE UNIQUE INDEX idx_people_normalized_active ON people(normalized_name) WHERE deleted_at IS NULL',
    '''
    CREATE TABLE debts (
      id                       TEXT PRIMARY KEY,
      person_id                TEXT    NOT NULL REFERENCES people(id),
      direction                TEXT    NOT NULL CHECK (direction IN ('lent','borrowed')),
      principal_minor          INTEGER NOT NULL CHECK (principal_minor > 0),
      currency                 TEXT    NOT NULL,
      description              TEXT    NOT NULL DEFAULT '',
      opened_at                INTEGER NOT NULL,
      due_date                 INTEGER,
      principal_transaction_id TEXT REFERENCES transactions(id),
      closed_at                INTEGER,
      close_reason             TEXT CHECK (close_reason IN ('repaid','forgiven')),
      created_at               INTEGER NOT NULL,
      updated_at               INTEGER NOT NULL,
      deleted_at               INTEGER,
      sync_status              TEXT    NOT NULL DEFAULT 'pending',
      CHECK ((closed_at IS NULL) = (close_reason IS NULL))
    )''',
    'CREATE INDEX idx_debts_person ON debts(person_id)',
    'CREATE INDEX idx_debts_open ON debts(closed_at, due_date)',
    'CREATE UNIQUE INDEX idx_debts_principal_tx ON debts(principal_transaction_id) WHERE principal_transaction_id IS NOT NULL',
    '''
    CREATE TABLE debt_payments (
      id             TEXT PRIMARY KEY,
      debt_id        TEXT    NOT NULL REFERENCES debts(id),
      transaction_id TEXT REFERENCES transactions(id),
      kind           TEXT    NOT NULL CHECK (kind IN ('repayment','forgiveness')),
      amount_minor   INTEGER NOT NULL CHECK (amount_minor > 0),
      paid_at        INTEGER NOT NULL,
      created_at     INTEGER NOT NULL,
      updated_at     INTEGER NOT NULL,
      deleted_at     INTEGER,
      sync_status    TEXT    NOT NULL DEFAULT 'pending',
      CHECK (kind = 'repayment' OR transaction_id IS NULL)
    )''',
    'CREATE INDEX idx_dp_debt ON debt_payments(debt_id)',
    'CREATE INDEX idx_dp_tx ON debt_payments(transaction_id)',
  ];

  static final List<String> statements = [
    for (final s in SQLiteSchemaV3.statements)
      if (s.contains('CREATE TABLE transactions (')) transactionsTable else s,
    debtRoleIndex,
    ...budgetsAndDebts,
  ];
}

/// v5 DDL, see [SQLiteSchema.v5]. `wallets` gains `include_in_total` inline;
/// everything else in v4 is reused verbatim.
abstract class SQLiteSchemaV5 {
  static const String walletsTable = '''
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
      sync_status           TEXT    NOT NULL DEFAULT 'pending',
      include_in_total      INTEGER NOT NULL DEFAULT 1
    )''';

  /// The v4 → v5 migration (same column shape as [walletsTable]).
  static const String includeInTotalColumn =
      'ALTER TABLE wallets ADD COLUMN include_in_total INTEGER NOT NULL DEFAULT 1';

  static final List<String> statements = [
    for (final s in SQLiteSchemaV4.statements)
      if (s.contains('CREATE TABLE wallets (')) walletsTable else s,
  ];
}

/// v6 DDL, see [SQLiteSchema.v6]. `settings` gains `mascot_talks` inline and
/// the key-value `mascot_memory` table is appended; everything else in v5 is
/// reused verbatim. The v5 → v6 migration shares [mascotTalksColumn] and
/// [mascotMemoryTable].
abstract class SQLiteSchemaV6 {
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
      last_recurring_run_at INTEGER,
      mascot_talks          INTEGER NOT NULL DEFAULT 1
    )''';

  static const String mascotTalksColumn =
      'ALTER TABLE settings ADD COLUMN mascot_talks INTEGER NOT NULL DEFAULT 1';

  static const String mascotMemoryTable = '''
    CREATE TABLE mascot_memory (
      key        TEXT PRIMARY KEY,
      value      TEXT    NOT NULL,
      updated_at INTEGER NOT NULL
    )''';

  static final List<String> statements = [
    for (final s in SQLiteSchemaV5.statements)
      if (s.contains('CREATE TABLE settings (')) settingsTable else s,
    mascotMemoryTable,
  ];
}
