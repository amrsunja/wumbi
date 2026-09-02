# Fiin — v1 Product & Technical Specification

**Status:** Approved design for v1 (5 mockup screens + onboarding + recurring transactions)
**Date:** 2026-09-01
**Audience:** Implementation (Flutter / Dart), single developer
**Supersedes:** `database_documentation.md` (schema sections were merged, corrected and extended here)

---

## Table of contents

1. [Product overview](#1-product-overview)
2. [Scope of v1](#2-scope-of-v1)
3. [Decisions log (answers from the product owner)](#3-decisions-log)
4. [Money, currencies and exchange rates](#4-money-currencies-and-exchange-rates)
5. [Data model (SQLite / SQLCipher)](#5-data-model)
6. [Application architecture](#6-application-architecture)
7. [Navigation map](#7-navigation-map)
8. [Screen specifications](#8-screen-specifications)
   - 8.1 Splash
   - 8.2 Onboarding
   - 8.3 Dashboard (Home)
   - 8.4 Wallet Details
   - 8.5 Transaction (create / edit)
   - 8.6 Create / Edit Wallet
   - 8.7 Settings
9. [Recurring transactions engine](#9-recurring-transactions-engine)
10. [Design system: tokens and components](#10-design-system)
11. [Formatting rules (amounts, dates, tags)](#11-formatting-rules)
12. [Error handling, edge cases, empty states](#12-error-handling-and-edge-cases)
13. [Existing code: required fixes before feature work](#13-existing-code-fixes)
14. [Implementation roadmap](#14-implementation-roadmap)
15. [Testing strategy](#15-testing-strategy)
16. [Appendix A — full SQL DDL](#appendix-a--full-sql-ddl)
17. [Appendix B — key queries](#appendix-b--key-queries)
18. [Appendix C — Dart model sketches](#appendix-c--dart-model-sketches)

---

## 1. Product overview

Fiin is a minimalist, local-first personal budgeting app. The user owns a set of **wallets** (each in one currency) and records **transactions** (income, expense, transfer) against them. There are no categories; instead free-form **tags** are typed inline (`#food #work`) and are created on the fly. The whole experience is optimised for one thing: **logging a transaction in under three seconds** — open, type amount, tap INCOME/EXPENSE, done, screen stays open for the next one.

Core principles:

| Principle | Consequence |
|---|---|
| Local-first, encrypted | SQLCipher database, AES-256 key in secure storage. No account, no server in v1. Schema is sync-ready (UUIDs, soft delete, timestamps, `sync_status`). |
| One screen per job | 5 screens: Dashboard, Wallet Details, Transaction, Create/Edit Wallet, Settings. Every secondary choice (wallet, currency, transfer target, date, repeat) is a bottom sheet, not a screen. |
| Speed of entry | Custom numpad, one-tap commit, screen stays open after save, fields reset. |
| Multi-currency without ceremony | Wallets have a currency. Dashboard total is converted to one *base currency*. A transaction can be typed in any currency and is stored both as typed and as converted. |
| Tags, not categories | Type words, get tags. No taxonomy management. Analytics by tag is a v2 feature; the data model already supports it. |
| Brand | Mascot "Fiin" (cream blob holding a banknote) peeks in from screen edges. Calm palette: `bismark` text on `cararra` background, `blue` as the single accent. |

---

## 2. Scope of v1

### In scope

- Onboarding (first launch): welcome → base currency → first wallet.
- Dashboard: total net worth (base currency), wallet list, FAB to add transaction, settings.
- Wallet Details: balance, transaction list, wallet switcher, edit wallet, FAB.
- Transaction screen: amount numpad, currency selector, wallet selector, description, tags, date, repeat; one-tap INCOME / EXPENSE; TRANSFER via bottom sheet; edit mode (from list) with Delete / Save.
- Create / Edit Wallet: name, initial balance, currency, primary flag, colour, delete.
- Settings: Notifications (stub toggle), Currency (base currency), Dark Mode, Reset All Data, version.
- Recurring transactions (daily / weekly / monthly / yearly) created from the Transaction screen; catch-up generation on app start.
- Exchange rates via the `currency_converter` package with a local cache table for offline use.
- Swipe-to-delete transactions with undo.

### Explicitly out of scope (v1)

| Feature | Status |
|---|---|
| Account / Personal Information / Security screens | Removed from Settings. Will be designed with the sync feature. |
| Export Transactions | Row hidden in v1. Schema already supports full JSON export (section 5.9). |
| Charts / analytics by tag (`/graph`, `fl_chart`) | v2. |
| Freemium / IAP (`/freemium`, `in_app_purchase`) | v2. |
| Push / local notifications | Toggle is persisted only; no scheduling. |
| Cloud sync | v2. Schema is prepared; `sync_log` table is deferred. |
| Multi-language UI | Only `en` ARB shipped. Language settings page stays in code but is hidden until a second locale exists. |

---

## 3. Decisions log

Answers captured from the product owner on 2026-09-01. These are binding for v1.

| # | Topic | Decision |
|---|---|---|
| D1 | Dashboard currencies | Wallet rows show balances **in their own currency** (€5,678.90, ₿0.00420000). **Only the total** is converted to the base currency from Settings → Currency. |
| D2 | Transaction currency selector | The user may enter an amount in **any currency**. The amount is converted into the **wallet's currency** at the current rate; a small hint under the amount shows "≈ €113.20 will be added to Savings Vault". Both the **original** (as typed) and the **converted** amount are stored. Wallet Details shows both so the user sees the full picture. |
| D3 | Wallet selector on the Transaction screen | It is the **target wallet** for the transaction, changeable in place so the user never has to leave the screen. |
| D4 | INCOME / EXPENSE buttons | **One-tap commit.** Saves immediately with that type, **does not close the screen**, clears the amount so the next transaction can be entered right away. |
| D5 | TRANSFER button | Opens a **bottom sheet** to pick the destination wallet (plus an editable "amount received" field when currencies differ), saves on confirm, **does not close** the screen, clears the amount. |
| D6 | Settings → Account section | **Removed** from v1 (Personal Information, Security). |
| D7 | v1 extra scope | **Onboarding** and **recurring transactions** are in. Charts and freemium are out. |
| D8 | Edit / delete transaction | Tap a row in Wallet Details → Transaction screen in **edit mode** (fields pre-filled, bottom bar becomes Delete / Save, Save closes the screen). Rows also support **swipe-to-delete** with an undo snackbar. |
| D9 | Export | Not developed in v1. |
| D10 | Notifications | **Stub** — toggle is stored, nothing is scheduled. |
| D11 | Exchange rates source | `currency_converter` package (backed by fawazahmed0/currency-api, supports fiat + crypto), with a local `exchange_rates` cache. |
| D12 | Recurring UI | A **"Repeat" chip next to the date chip** on the Transaction screen (never / daily / weekly / monthly / yearly). Saving creates the rule and the first occurrence. Active rules for a wallet are listed from Wallet Details. |
| D13 | Wallet delete / initial balance | Delete → confirmation → **soft delete** the wallet and its income/expense transactions; transfers with other wallets stay visible on the other side. The amount field on Create/Edit Wallet is the **initial balance**; editing it shifts the wallet balance by the delta. |

Assumptions made by the spec author where the owner did not decide (flagged inline with **[A]** and listed here for review):

- **[A1]** After one-tap commit, the screen clears amount, description and tags, and keeps wallet, currency, date (reset to today if it was today) and Repeat (reset to *never*). Rationale: description/tags belong to the saved transaction; keeping them would create accidental duplicates.
- **[A2]** Transaction type is **not editable** in edit mode (delete + recreate instead). Keeps balance logic and transfer invariants simple.
- **[A3]** Wallet currency is **locked** once the wallet has at least one transaction.
- **[A4]** Balances are **derived** (initial balance + SUM of transactions) through a SQL view, not stored. See section 5.3 for the rationale.
- **[A5]** Dashboard "Across N wallets" counts all non-deleted wallets.
- **[A6]** Reset All Data also resets onboarding and returns to the Onboarding flow.
- **[A7]** Dark Mode toggle maps to `light`/`dark`; `system` is the value until the user first touches the toggle.

---

## 4. Money, currencies and exchange rates

### 4.1 Representation

All money is stored as **integers in minor units** (`INTEGER` in SQLite, `int` in Dart). Never `double` for stored or summed money.

Scale (number of decimals) per currency is a code-side table:

```dart
enum CurrencyType {
  usd(code: 'USD', symbol: r'$',   scale: 2),
  eur(code: 'EUR', symbol: '€',    scale: 2),
  gbp(code: 'GBP', symbol: '£',    scale: 2),
  chf(code: 'CHF', symbol: 'CHF',  scale: 2),
  cad(code: 'CAD', symbol: r'CA$', scale: 2),
  jpy(code: 'JPY', symbol: '¥',    scale: 0),
  aud(code: 'AUD', symbol: r'A$',  scale: 2),
  sek(code: 'SEK', symbol: 'kr',   scale: 2),
  nok(code: 'NOK', symbol: 'kr',   scale: 2),
  dkk(code: 'DKK', symbol: 'kr',   scale: 2),
  cny(code: 'CNY', symbol: '¥',    scale: 2),
  tryLira(code: 'TRY', symbol: '₺', scale: 2),
  btc(code: 'BTC', symbol: '₿',    scale: 8),   // NEW — required by the "Crypto / BTC" wallet in the mockup
  ;
  const CurrencyType({required this.code, required this.symbol, required this.scale});
  final String code; final String symbol; final int scale;
  bool get isCrypto => this == btc;
  static CurrencyType fromCode(String code) => values.firstWhere((c) => c.code == code.toUpperCase(), orElse: () => usd);
}
```

Conversions between display value and minor units:

```dart
int toMinor(String typed, CurrencyType c)   // "123.45" → 12345  (parse as Decimal-safe: split on '.', pad)
String fromMinor(int minor, CurrencyType c) // 12345 → "1,234.56" via NumberFormat with decimalDigits = c.scale
```

Rules:
- Parsing user input must **not** go through `double.parse` for scale ≤ 8 — split on `.`, pad/truncate the fraction to `scale`, combine as `int`. (For BTC, `0.00012345` must survive exactly.)
- Sums are always computed on minor ints; only the last step formats.

### 4.2 Exchange rates

Source: `currency_converter` (`CurrencyConverter.convert(from:, to:, amount:, withoutRounding: true)`), network required.

To avoid a network call on every keystroke and to work offline, rates are cached in the `exchange_rates` table as `rate = quote per 1 unit of base` (`REAL`). The rate itself is only ever used for one multiplication, then rounded to minor units; it is never summed.

```
convertMinor(fromMinor, from, to, rate):
  value    = fromMinor / 10^from.scale          // as double, single operation
  result   = value * rate * 10^to.scale
  return result.round()                          // half away from zero
```

`FxService` API (core service, provider `fxServiceProvider`):

```dart
abstract class FxService {
  /// Returns cached rate if fresher than [maxAge] (default 12h) else fetches and caches.
  /// Falls back to the stale cached rate when offline. Throws FxUnavailable if nothing cached.
  Future<FxRate> rate(CurrencyType from, CurrencyType to, {Duration maxAge = const Duration(hours: 12)});
  /// Best effort: refreshes rates for all pairs needed by the dashboard (wallet currencies → base).
  Future<void> warmUp(Set<CurrencyType> currencies, CurrencyType base);
}
class FxRate { final CurrencyType from, to; final double rate; final DateTime fetchedAt; final bool isStale; }
```

Behaviour:
- Rate for `from == to` is `1.0`, never fetched.
- The Transaction screen requests a rate only when the selected currency ≠ wallet currency; it is fetched once per (pair, screen session) and reused for each keystroke.
- Dashboard calls `warmUp` on load; UI never waits on it. If a pair has no cached rate, that wallet is excluded from the total and a caption says "Rates unavailable for BTC" (see 8.3).
- A transaction always stores the **rate that was actually used** (`exchange_rate`) so history never changes when rates move.

---
## 5. Data model

### 5.1 Conventions

| Convention | Rule |
|---|---|
| Primary keys | `TEXT` UUID v4 (`package:uuid`). Generated in Dart, never by SQLite. |
| Timestamps | `INTEGER` Unix epoch **milliseconds**, UTC. `created_at`, `updated_at` on every business table. |
| Soft delete | `deleted_at INTEGER NULL`. Every read query filters `deleted_at IS NULL` unless explicitly reading history. |
| Sync readiness | `sync_status TEXT NOT NULL DEFAULT 'pending'` (`pending` / `synced` / `conflict`). v1 writes `pending` and never reads it. |
| Booleans | `INTEGER` 0/1. |
| Money | `*_minor INTEGER` (section 4). |
| Currency codes | ISO-4217 uppercase `TEXT`, `BTC` for bitcoin. |
| Foreign keys | `PRAGMA foreign_keys = ON` in `onConfigure`. |
| Engine | `sqflite_sqlcipher`, `openDatabase(path, password:, version:, onConfigure:, onCreate:, onUpgrade:)`. Path from `getDatabasesPath()`, file `fiin.db`. |

### 5.2 Entity relationship

```
settings (1 row)                 exchange_rates (cache, no FK)

wallets 1 ──< transactions >── 1 wallets       (wallet_id | from_wallet_id / to_wallet_id)
                 │
                 ├──< transaction_tags >── tags
                 │
                 └── recurring_rules (recurring_rule_id)  ──< recurring_rule_tags >── tags
                                     └── wallets (wallet_id / from_wallet_id / to_wallet_id)
```

### 5.3 Balances are derived, not stored (design decision)

The previous document stored `current_balance_minor` on `wallets` and updated it inside every write. This is replaced by a **SQL view** that computes balances from `initial_balance_minor` + transactions. Reasons:

- One source of truth; no drift after a failed write, an interrupted app kill, a future sync merge, or the soft-delete/undo flow.
- Recurring catch-up, swipe-undo, wallet delete/restore and initial-balance edits all become a single `UPDATE`/`INSERT` without compensating arithmetic.
- Volume is tiny (a heavy user produces ~5k rows/year); the aggregate with the indexes below runs in < 1 ms.

```sql
CREATE VIEW wallet_balances AS
SELECT
  w.id                                                        AS wallet_id,
  w.currency                                                  AS currency,
  w.initial_balance_minor
    + COALESCE((SELECT SUM(t.amount_minor)      FROM transactions t WHERE t.wallet_id      = w.id AND t.type = 'income'   AND t.deleted_at IS NULL), 0)
    - COALESCE((SELECT SUM(t.amount_minor)      FROM transactions t WHERE t.wallet_id      = w.id AND t.type = 'expense'  AND t.deleted_at IS NULL), 0)
    - COALESCE((SELECT SUM(t.from_amount_minor) FROM transactions t WHERE t.from_wallet_id = w.id AND t.type = 'transfer' AND t.deleted_at IS NULL), 0)
    + COALESCE((SELECT SUM(t.to_amount_minor)   FROM transactions t WHERE t.to_wallet_id   = w.id AND t.type = 'transfer' AND t.deleted_at IS NULL), 0)
                                                              AS balance_minor
FROM wallets w
WHERE w.deleted_at IS NULL;
```

If profiling ever shows this to be slow, add a materialised `current_balance_minor` column later — the write path is already centralised in `TransactionRepository`, so it is a local change.

### 5.4 Table `settings` (single row, `id = 1`)

Extends the existing table. Column names are kept in `SQLiteConfig` as `static const`.

| Column | Type | Default | Notes |
|---|---|---|---|
| `id` | INTEGER PK | 1 | `CHECK (id = 1)` |
| `language_code` | TEXT | NULL | existing |
| `country_code` | TEXT | NULL | existing |
| `theme_mode` | TEXT NOT NULL | `'system'` | `system` / `light` / `dark` |
| `show_onboarding` | INTEGER NOT NULL | 1 | existing |
| `base_currency` | TEXT NOT NULL | `'USD'` | **new** — Settings → Currency; drives the dashboard total |
| `notifications_enabled` | INTEGER NOT NULL | 0 | **new** — stub toggle |
| `last_recurring_run_at` | INTEGER | NULL | **new** — watermark for the recurring engine |

### 5.5 Table `wallets`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | UUID |
| `name` | TEXT NOT NULL | 1–40 chars, trimmed |
| `currency` | TEXT NOT NULL | locked once the wallet has transactions **[A3]** |
| `initial_balance_minor` | INTEGER NOT NULL DEFAULT 0 | edited on Create/Edit Wallet (D13) |
| `color` | TEXT NOT NULL | one of the 5 palette keys: `blue` / `amber` / `red` / `green` / `violet` (stored as key, not hex, so the theme can restyle) |
| `is_primary` | INTEGER NOT NULL DEFAULT 0 | exactly one non-deleted wallet has 1 (enforced in repository, see 5.10) |
| `sort_order` | INTEGER NOT NULL DEFAULT 0 | creation order in v1; reorder is v2 |
| `created_at`, `updated_at` | INTEGER NOT NULL | |
| `deleted_at` | INTEGER | soft delete |
| `sync_status` | TEXT NOT NULL DEFAULT 'pending' | |

Indexes: `(deleted_at)`, `(sort_order)`, partial unique `idx_wallets_primary ON wallets(is_primary) WHERE is_primary = 1 AND deleted_at IS NULL`.

### 5.6 Table `transactions`

One table for the three types. Amount columns hold **positive** numbers; the sign is implied by `type`.

| Column | Type | income / expense | transfer |
|---|---|---|---|
| `id` | TEXT PK | | |
| `type` | TEXT NOT NULL | `income` / `expense` | `transfer` |
| `wallet_id` | TEXT FK wallets | **required** | NULL |
| `amount_minor` | INTEGER | **required**, in `currency` (= wallet currency) | NULL |
| `currency` | TEXT NOT NULL | wallet currency | from-wallet currency |
| `from_wallet_id` | TEXT FK wallets | NULL | **required** |
| `to_wallet_id` | TEXT FK wallets | NULL | **required**, ≠ `from_wallet_id` |
| `from_amount_minor` | INTEGER | NULL | **required**, in from-wallet currency |
| `to_amount_minor` | INTEGER | NULL | **required**, in to-wallet currency |
| `original_amount_minor` | INTEGER | set only when the user typed in a currency ≠ wallet currency (D2) | same, relative to from-wallet |
| `original_currency` | TEXT | code the user typed in | same |
| `exchange_rate` | REAL | rate used: `wallet ccy per 1 original ccy`; NULL if no conversion | rate used for `to_amount = from_amount × rate` (to-ccy per 1 from-ccy); NULL if same currency |
| `description` | TEXT | ≤ 80 chars, may be empty | |
| `transaction_date` | INTEGER NOT NULL | epoch ms of the user-chosen date, time = moment of creation on that day (see 11.2) | |
| `recurring_rule_id` | TEXT FK recurring_rules | set when generated by a rule (including the first occurrence) | |
| `created_at`, `updated_at`, `deleted_at`, `sync_status` | | | |

Constraints (`CHECK`) — SQLite on iOS/Android ships ≥ 3.32, all of this is supported:

```sql
CHECK (type IN ('income','expense','transfer')),
CHECK (
  (type IN ('income','expense')
     AND wallet_id IS NOT NULL AND amount_minor IS NOT NULL AND amount_minor >= 0
     AND from_wallet_id IS NULL AND to_wallet_id IS NULL)
  OR
  (type = 'transfer'
     AND from_wallet_id IS NOT NULL AND to_wallet_id IS NOT NULL AND from_wallet_id <> to_wallet_id
     AND from_amount_minor IS NOT NULL AND to_amount_minor IS NOT NULL
     AND from_amount_minor >= 0 AND to_amount_minor >= 0
     AND wallet_id IS NULL AND amount_minor IS NULL)
),
CHECK ((original_amount_minor IS NULL) = (original_currency IS NULL))
```

Indexes: `(wallet_id, transaction_date DESC)`, `(from_wallet_id, transaction_date DESC)`, `(to_wallet_id, transaction_date DESC)`, `(transaction_date)`, `(deleted_at)`, `(updated_at)`, `(recurring_rule_id)`.

Why `parent_transaction_id` and `is_recurring` from the old doc were dropped: `recurring_rule_id IS NOT NULL` already says "generated by a rule"; parent linkage has no v1 use case.

### 5.7 Tables `tags`, `transaction_tags`

`tags`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `normalized_name` | TEXT NOT NULL | lower-case, trimmed, leading `#` removed, NFC-normalised |
| `display_name` | TEXT NOT NULL | as first typed (case preserved) |
| `usage_count` | INTEGER NOT NULL DEFAULT 0 | maintained by repository on attach/detach |
| `last_used_at` | INTEGER | for autocomplete ranking |
| `created_at`, `updated_at`, `deleted_at`, `sync_status` | | |

Partial unique index: `ON tags(normalized_name) WHERE deleted_at IS NULL`.

`transaction_tags`

| Column | Type |
|---|---|
| `transaction_id` | TEXT NOT NULL FK transactions ON DELETE CASCADE |
| `tag_id` | TEXT NOT NULL FK tags ON DELETE CASCADE |
| `created_at` | INTEGER NOT NULL |
| PK | `(transaction_id, tag_id)` |

No surrogate `id` — the composite PK is the identity, also for sync.

### 5.8 Tables `recurring_rules`, `recurring_rule_tags`

`recurring_rules` mirrors the transaction shape (so a rule can be a transfer too) plus scheduling:

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `type` | TEXT NOT NULL | `income` / `expense` / `transfer` |
| `wallet_id`, `amount_minor`, `currency`, `from_wallet_id`, `to_wallet_id`, `from_amount_minor`, `to_amount_minor` | | same semantics as `transactions`; amounts are already in wallet currency (rules do not re-convert per occurrence) |
| `description` | TEXT | copied to each occurrence |
| `frequency` | TEXT NOT NULL | `daily` / `weekly` / `monthly` / `yearly` |
| `interval` | INTEGER NOT NULL DEFAULT 1 | always 1 in v1 UI; column kept for "every 2 weeks" later |
| `start_date` | INTEGER NOT NULL | date of the first occurrence (the transaction created on save) |
| `next_occurrence` | INTEGER NOT NULL | next date to generate |
| `occurrence_count` | INTEGER NOT NULL DEFAULT 1 | how many occurrences exist (first one included); `next_occurrence = advance(start_date, frequency, occurrence_count)` — anchored to `start_date`, so month-end clamping never drifts |
| `end_date` | INTEGER | NULL in v1 UI |
| `is_active` | INTEGER NOT NULL DEFAULT 1 | "Stop repeating" sets 0 |
| `created_at`, `updated_at`, `deleted_at`, `sync_status` | | |

Same `CHECK` invariants as `transactions` for the type/fields relationship, plus `CHECK (frequency IN (...))`.

`recurring_rule_tags(recurring_rule_id, tag_id, created_at)` — composite PK, copied into `transaction_tags` for every generated occurrence.

### 5.9 Tables `exchange_rates`, `schema_migrations`

`exchange_rates` (cache, section 4.2)

| Column | Type |
|---|---|
| `base_currency` | TEXT NOT NULL |
| `quote_currency` | TEXT NOT NULL |
| `rate` | REAL NOT NULL — quote per 1 base |
| `fetched_at` | INTEGER NOT NULL |
| PK | `(base_currency, quote_currency)` |

`schema_migrations` is **not** needed — `sqflite`'s `version` + `onUpgrade(db, old, new)` is the migration mechanism. Keep migrations as an ordered list `List<Migration>` in `sqlite_migrations.dart`, each `Future<void> Function(Database)`; `onUpgrade` runs `migrations[old..new-1]` inside one transaction.

Since the app has never shipped, **v1 schema = database version 1** with the full DDL in `onCreate`; the current dev `settings`-only DB is discarded (reinstall). `sync_log` from the old doc is deferred to v2.

### 5.10 Repository invariants (enforced in Dart, inside `db.transaction`)

| Invariant | Where |
|---|---|
| Exactly one primary wallet among non-deleted wallets. Setting primary = clear all, set one. Deleting the primary = promote the lowest `sort_order` remaining wallet. Creating the first wallet = primary regardless of toggle. | `WalletRepository` |
| Wallet currency cannot change if `EXISTS transactions WHERE (wallet_id = ? OR from_wallet_id = ? OR to_wallet_id = ?) AND deleted_at IS NULL`. | `WalletRepository.update` |
| Soft-deleting a wallet soft-deletes its `income`/`expense` transactions (same `deleted_at`), and deactivates its recurring rules. Transfers are untouched (D13). | `WalletRepository.softDelete` |
| Tag attach = find-or-create by `normalized_name`, insert link, `usage_count += 1`, `last_used_at = now`. Detach = delete link, `usage_count -= 1`. Editing a transaction diffs old vs new tag sets. | `TagRepository` |
| Transaction write, tag links and (optionally) rule creation happen in **one** SQLite transaction. | `TransactionRepository.create/update` |
| Undo of a swipe-delete = `UPDATE transactions SET deleted_at = NULL, updated_at = now`. Links in `transaction_tags` were never removed, so nothing else to restore. | `TransactionRepository.restore` |
| `exchange_rate`, `original_*` are immutable after creation unless the user re-enters the amount in edit mode (then recomputed with a fresh rate and shown before Save). | `TransactionRepository.update` |

---
## 6. Application architecture

### 6.1 Layering (per feature)

Keep the existing feature-first layout, flatten `lib/src/src/` → `lib/src/` (section 13), and use the same three layers for every feature:

```
lib/src/
  config/                      app_config.dart, app_runner.dart (unchanged)
  core/
    design_system/             tokens + ui components (section 10)
    local/database/sqlite/     sqlite_services.dart, sqlite_config.dart, sqlite_migrations.dart, sqlite_schema.dart (DDL)
    local/database/secure_storage/
    fx/                        fx_service.dart, fx_service_impl.dart (currency_converter + cache)
    money/                     money.dart (Money value object), currency_type.dart, money_format.dart
    recurring/                 recurring_engine.dart (section 9)
    routing/                   app_router.dart, route_paths.dart
    providers/                 sqlite, secure storage, fx, navigation
    utils/                     extensions, enums, debug, vibrations
  features/
    onboarding/   ui/
    dashboard/    data/ (dashboard_repo.dart)             ui/ (dashboard_page.dart, dashboard_notifier.dart, widgets/)
    wallet/       data/ (wallet_local_datasource.dart, wallet_repository.dart, models/wallet_model.dart)
                  ui/   (wallet_details_page.dart, wallet_form_page.dart, notifiers, widgets/)
    transaction/  data/ (transaction_local_datasource.dart, transaction_repository.dart, models/)
                  ui/   (transaction_page.dart, transaction_notifier.dart, widgets/ numpad, tag_input, sheets)
    tag/          data/ (tag_local_datasource.dart, tag_repository.dart, models/)
    settings/     (existing)
```

Layer responsibilities:

| Layer | Owns | Never does |
|---|---|---|
| `*_local_datasource.dart` | raw `sqflite` queries, row ↔ model mapping (`fromRow`/`toRow`) | business rules, conversions |
| `*_repository.dart` | invariants (5.10), `db.transaction(...)`, `Failure.exceptionsCatcher` → `Result` | UI types, `BuildContext` |
| `*_notifier.dart` | screen state (freezed), calls repos, emits single events (`AppEvents`) | SQL |
| `*_page.dart` / `widgets/` | rendering, hooks for controllers/animations | direct repo access |

### 6.2 State management

The project is on `hooks_riverpod` 3 but the existing `Presenter` is a `StateNotifier` from `hooks_riverpod/legacy`. For the new features use **Riverpod 3 `Notifier` / `AsyncNotifier`** (code-gen not required):

```dart
final transactionNotifierProvider =
    NotifierProvider.autoDispose.family<TransactionNotifier, TransactionState, TransactionArgs>(TransactionNotifier.new);

class TransactionNotifier extends Notifier<TransactionState> { ... }
```

Rules:
- One `Notifier` per screen; family keyed by route arguments (`walletId`, `transactionId`).
- Read-only cross-screen data (wallet list, base currency, balances) come from `AsyncNotifier` providers that expose a `Stream`-like refresh: after any write, the repository bumps a `dbRevisionProvider` (`int`) which those providers `ref.watch`; this replaces manual "reload dashboard after save" wiring.
- Single-shot effects (navigate, snackbar, haptics) go through the existing `AppEvents` stream, not through state.
- `SettingsPresenter` may stay as is; migrate opportunistically.

### 6.3 Result / error model

Keep `multiple_result` `Result<S, Failure>` and `Failure.exceptionsCatcher`. Add domain failures:

```dart
sealed class Failure { ... }
class DatabaseFailure extends Failure {}
class FxUnavailableFailure extends Failure {}      // no rate cached, offline
class ValidationFailure extends Failure { final String field; }
class WalletHasTransactionsFailure extends Failure {}  // currency change refused
```

### 6.4 Money value object

```dart
@immutable
class Money {
  final int minor; final CurrencyType currency;
  const Money(this.minor, this.currency);
  Money operator +(Money o) { assert(o.currency == currency); return Money(minor + o.minor, currency); }
  Money operator -(Money o) { ... }
  bool get isZero => minor == 0;
  String format({bool withSymbol = true, bool withSign = false}) => ...;   // section 11.1
  static Money parse(String typed, CurrencyType c) => ...;                 // section 4.1
}
```

All models, notifiers and widgets pass `Money`, never bare `num` + currency pairs (the current `UiWalletCard`/`UiTransactionCard` signatures change accordingly).

### 6.5 Startup sequence (Splash)

1. `SQLiteServices.initDatabase()` (key from secure storage, `PRAGMA foreign_keys = ON`, migrations).
2. `SettingsRepo.getLocalSettings()` → theme, base currency, `show_onboarding`.
3. `RecurringEngine.catchUp(now)` (section 9) — awaited, bounded (< 50 ms typical).
4. `FxService.warmUp(...)` — **not** awaited.
5. Route: `show_onboarding == 1` → `/onboarding`, else `/dashboard`. (The current `initLocalSettings` sends the same route in both branches — bug, see section 13.)

---

## 7. Navigation map

`auto_route`, all routes are full-screen pages; everything else is a `UIModalSheet`.

| Path | Page | Args | Transition |
|---|---|---|---|
| `/` | SplashPage | — | fade |
| `/onboarding` | OnboardingPage (PageView of 3 steps) | — | fade |
| `/dashboard` | DashboardPage | — | fade (root) |
| `/wallet/:id` | WalletDetailsPage | `walletId` | slide-left |
| `/wallet/new` | WalletFormPage | — | slide-up (modal) |
| `/wallet/:id/edit` | WalletFormPage | `walletId` | slide-up (modal) |
| `/transaction` | TransactionPage | `walletId?` (preselect), `transactionId?` (edit mode) | slide-up (modal) |
| `/settings` | SettingsPage | — | slide-left |
| `/settings/currency` | BaseCurrencyPage (or sheet) | — | slide-left |
| `/settings/about` | AboutProjectPage (existing) | — | slide-left |

Remove from `RoutePaths` for v1: `graph`, `goalsSettings`, `freemium`. Keep `appLangSettings` hidden.

Bottom sheets (not routes): WalletPickerSheet, CurrencyPickerSheet, TransferSheet, DatePickerSheet (`syncfusion_flutter_datepicker` inside `UIModalSheet`), RepeatPickerSheet, RecurringRulesSheet, ConfirmDialog (`UIAlert`).

Flow diagram:

```
Splash ─► Onboarding(1 welcome → 2 base currency → 3 first wallet) ─► Dashboard
Splash ─────────────────────────────────────────────────────────────► Dashboard
Dashboard ─ tap wallet ─► WalletDetails ─ tap ✎ ─► WalletForm(edit)
Dashboard ─ New Wallet ─► WalletForm(new)
Dashboard ─ ⚙ ─► Settings ─► BaseCurrency / About
Dashboard ─ (+) ─► Transaction(walletId = primary)
WalletDetails ─ (+) ─► Transaction(walletId = this)
WalletDetails ─ tap row ─► Transaction(transactionId, edit mode)
Transaction ─ TRANSFER ─► TransferSheet ─ confirm ─► (stays on Transaction)
```

---
## 8. Screen specifications

Every screen section has the same shape: **Layout** (top → bottom, mapped to components from section 10), **State**, **Behaviour**, **Data**, **Edge cases**.

Common chrome (all screens): background `UIColorToken.bgColor` (`cararra` light), horizontal padding 16, `UIAppbar` with 44 px back/`action` slots and an uppercase, letter-spaced, `casper` title (`DASHBOARD`, `SETTINGS`). Status bar: dark icons in light theme. Safe areas respected. Haptics via the existing `app_vibrations.dart`: light impact on numpad keys, medium on commit, heavy on delete.

### 8.1 Splash

- Full-screen `SplashWidget` (existing, `assets/images/splash.gif`), minimum display 600 ms so the GIF loop does not flash.
- Runs the startup sequence (6.5). Any failure shows `UIAlert` with Retry (existing loop in `SettingsPresenter.initDatabase`, keep it but cap at 3 automatic retries before showing the alert).

### 8.2 Onboarding

`PageView` with 3 steps, no swipe (buttons only), progress dots (3) above the primary button. Skip is not offered — step 3 creates the wallet the app needs.

| Step | Content | Primary button | Persisted |
|---|---|---|---|
| 1 Welcome | `fiin_hello.png` centred, title "Meet Fiin", subtitle "Track money in seconds. No categories, just tags." | Continue | — |
| 2 Base currency | Title "Your main currency", subtitle "Totals are shown in this currency. You can change it later in Settings." `UiSelectButton` opening `CurrencyPickerSheet`; default = device locale currency via `CurrencyConverter.getMyCurrency()` mapped to `CurrencyType`, fallback USD | Continue | `settings.base_currency` |
| 3 First wallet | Embedded `WalletForm` body (same widget as 8.6, without Delete, Primary toggle hidden and forced on), name placeholder "Wallet Name", initial balance, currency defaults to base currency, colour defaults to blue | Create wallet | `wallets` row, then `settings.show_onboarding = 0` |

After step 3: `ReplaceRouteEvent('/dashboard')`. The existing 4 onboarding page files collapse into `onboarding_page.dart` + three step widgets; `onboarding_1_page.dart` (component showcase) is deleted or moved to `tool/gallery_page.dart` behind `kDebugMode`.

### 8.3 Dashboard (Home)

**Layout**

```
UIAppbar           title "DASHBOARD" (centre), action: settings icon (general/settings01) → /settings, no back
UIFiinLooksFromLeft   mascot peeking from the left edge, top ≈ 110 px, slides in 400 ms on first build (flutter_animate)
UiTotalAmount      "$12,345.67" — Montserrat 44 w300, bismark; base-currency symbol; AnimatedFlipCounter on change
Caption            "Across 4 wallets" — inter medium 14, casper
Spacer 64
Section header     "Wallets" (inter semibold 20, bismark)  ····  UiIconTextButton(plusCircle, "New Wallet") → /wallet/new
List               UiWalletCard × N (spacing 24): colour badge · name (16 semibold) · currency code (12 bold, casper, tracking 1.2) · balance right-aligned in the wallet currency
FAB                UiFab(+) bottom-right, blue circle 52 px, inset 24/24 → /transaction (walletId = primary)
```

**State**

```dart
@freezed class DashboardState {
  AsyncValue<DashboardData> data;   // loading → skeleton (shimmer) on first load only
}
class DashboardData {
  Money total;                       // base currency
  int walletCount;                   // [A5]
  List<WalletSummary> wallets;       // id, name, currency, color, balance (Money), isPrimary
  List<CurrencyType> unconvertible;  // wallets excluded from total because no rate
  bool ratesStale;                   // any rate older than 24h
}
```

**Behaviour**

- `ref.watch(dbRevisionProvider)` → re-query on every write anywhere in the app; no pull-to-refresh needed.
- Total = Σ `convertMinor(balance, wallet.ccy → base, rate)` for wallets with a rate; wallets without a rate go into `unconvertible` and the caption becomes "Across 4 wallets · BTC not included" (tappable → retries `warmUp`). If rates are stale, the caption keeps the number and the total is still shown (no warning — staleness is acceptable UX-wise; a subtle refresh happens in the background).
- Tap on a wallet row → `/wallet/:id`.
- Wallet list order: `sort_order ASC, created_at ASC`. Primary wallet is **not** pinned to the top (mockup shows Checking first while Savings Vault is the primary in the transaction mock — order is creation order).
- Back button on Android on this screen = exit app (root route).

**Data**

```sql
SELECT w.id, w.name, w.currency, w.color, w.is_primary, w.sort_order, b.balance_minor
FROM wallets w JOIN wallet_balances b ON b.wallet_id = w.id
WHERE w.deleted_at IS NULL
ORDER BY w.sort_order, w.created_at;
```

**Edge cases**

- 0 wallets (only reachable after Reset or deleting all): total shows `$0.00`, caption "No wallets yet", list replaced by `UiEmptyState(fiin_oo.png, "Create your first wallet")` with the New Wallet button; FAB hidden (nothing to add to).
- 1 wallet: caption "Across 1 wallet" (pluralisation via ARB plural).
- Very long wallet name: single line, ellipsis; balance never truncates.
- Amount width: at 44 px Montserrat, `$123,456,789.00` fits on 375 pt; above that `FittedBox(scaleDown)`.

### 8.4 Wallet Details

**Layout**

```
UIAppbar           back (← → pop), action: edit icon (editor/edit05) → /wallet/:id/edit
Header row         centred UiWalletInfoMenu:  "USD"  |  "• Savings Vault ⌄"
                   - left = wallet currency, static (no chevron, casper 12 bold)
                   - right = UiSelectWalletButton with chevron → WalletPickerSheet(current excluded) → replaces route args
UIFiinLooksFromRight  mascot peeking from the right edge, aligned with header
UiTotalAmount      balance in wallet currency, Montserrat 44 w300
Optional row       UiRepeatingSummary  "2 repeating · Monthly Rent, Netflix"  (only if the wallet has active rules) → RecurringRulesSheet
List               transactions, newest first, grouped nothing (flat), UiTransactionCard rows separated by UIDivider (casper 30 %)
FAB                UiFab(+) → /transaction (walletId = this)
```

Row anatomy (`UiTransactionCard`):

| Element | Content |
|---|---|
| Title | `description` if non-empty, else fallback by type: "Income", "Expense", "Transfer to {wallet}" / "Transfer from {wallet}" |
| Subtitle | date `Oct 28, 09:00 AM` (11.2); if `original_amount_minor` is set, append ` · 120.00 EUR @ 1.0833` in the same 12 px casper line |
| Trailing | signed amount in **this wallet's currency**, 16 semibold: income `+$1,500.00` blue; expense `-$120.00` black; transfer out `-$50.00` casper; transfer in `+$50.00` casper |
| Tag chips | none in the row (keeps the list calm); tags are visible in edit mode. **[A]** |

**State**

```dart
@freezed class WalletDetailsState {
  AsyncValue<WalletSummary> wallet;
  AsyncValue<List<TransactionRow>> transactions;   // page size 50, `hasMore`, `isLoadingMore`
  List<RecurringRuleSummary> rules;
}
```

**Behaviour**

- Tap row → `/transaction?transactionId=…` (edit mode, 8.5.7).
- Swipe row left → red delete background with trash icon (`general/trash01`); release → **soft delete immediately**, row animates out, `SnackbarWidget` "Transaction deleted — Undo" for 4 s. Undo → `restore(id)`. Balance header updates on both actions through `dbRevisionProvider`.
- Wallet switcher: sheet lists all other wallets (badge, name, currency, balance); selecting one replaces the page state (same route, new `walletId`) — the list scrolls to top.
- Infinite scroll: load next page at 80 % scroll extent.
- Mascot animation plays once per page visit.

**Data**

```sql
SELECT t.*, fw.name AS from_wallet_name, tw.name AS to_wallet_name
FROM transactions t
LEFT JOIN wallets fw ON fw.id = t.from_wallet_id   -- no deleted_at filter: names of deleted wallets still resolve
LEFT JOIN wallets tw ON tw.id = t.to_wallet_id
WHERE t.deleted_at IS NULL
  AND (t.wallet_id = ?1 OR t.from_wallet_id = ?1 OR t.to_wallet_id = ?1)
ORDER BY t.transaction_date DESC, t.created_at DESC
LIMIT ?2 OFFSET ?3;
```

Per-row display amount for this wallet: income/expense → `amount_minor`; transfer where `from_wallet_id = this` → `-from_amount_minor`; where `to_wallet_id = this` → `+to_amount_minor`.

**Edge cases**

- Empty list: `UiEmptyState(fiin_take_money.png, "No transactions yet", "Tap + to add your first one")`.
- Transfer whose counterpart wallet is deleted: title "Transfer from Crypto (deleted)".
- Wallet deleted while open (cannot happen from this screen; after edit-delete the form pops **two** routes back to Dashboard).

### 8.5 Transaction (create / edit)

The most important screen. Opened as a modal (slide-up). Two modes: **create** (default) and **edit** (`transactionId` given).

#### 8.5.1 Layout

```
UIAppbar             back (←). No title. In edit mode: title "EDIT"
Header row           UiWalletInfoMenu:  "USD ⌄"  |  "• Savings Vault ⌄"
                     - left: entry currency, tappable → CurrencyPickerSheet (all CurrencyType, wallet currency first, then base, then recent)
                     - right: target wallet, tappable → WalletPickerSheet
Amount               "123.45" — Montserrat 44 w700 bismark; shows "0" when empty (casper). Digits animate in (AnimatedFlipCounter not used — plain text, it's an input)
Conversion hint      (only when entry currency ≠ wallet currency) inter medium 12 casper:
                     "≈ €113.20 will be added to Savings Vault · 1 USD = 0.9203 EUR"   /  "Rate unavailable — connect to update" (neg500)
Description          UIInputField, placeholder "description", single line, ≤ 80 chars, centred, no border (mockup style), casper placeholder
Tags                 UiTagInput, placeholder "#tags", centred; chips appear inline as words are completed (11.3)
Spacer (flex)
Chips row            centred:  UiDateChip "Oct 28, 2026 ⌄"   ·   UiRepeatChip "Repeat ⌄" (shows "Monthly ⌄" when set)
UiNumpad             3×4 grid: 1 2 3 / 4 5 6 / 7 8 9 / . 0 ⌫ — keys 44 px tall, fgColor tiles on bgColor, inter 24 medium bismark; long-press ⌫ clears
Bottom bar (create)  UiTypeActionButton × 3, equal width:
                     TRANSFER  (arrows/switchHorizontal01, casper circle, label casper)
                     INCOME    (arrows/arrowCircleUp, blue circle, label bismark)
                     EXPENSE   (arrows/arrowCircleDown, bismark circle, label bismark)
Bottom bar (edit)    Delete (neg500 text button, left)  ·  Save (blue, right)   — same row style as Create/Edit Wallet
```

#### 8.5.2 State

```dart
@freezed class TransactionState {
  TransactionMode mode;                 // create | edit
  TransactionType? editingType;         // fixed in edit mode [A2]
  WalletSummary wallet;                 // target
  List<WalletSummary> wallets;          // for pickers
  CurrencyType entryCurrency;           // defaults to wallet.currency
  String amountInput;                   // raw typed string, e.g. "123.4"  ("" = empty)
  FxRate? rate;                         // null when entryCurrency == wallet.currency
  AsyncValue<void> rateStatus;          // loading / error for the hint
  String description;
  List<String> tags;                    // display names, deduped by normalized form
  DateTime date;                        // date part chosen; time part per 11.2
  RepeatFrequency repeat;               // never | daily | weekly | monthly | yearly
  bool isSaving;
  String? validationError;              // shown inline above the bottom bar for 2 s
}
```

Derived getters: `Money? entryMoney` (parsed `amountInput` in `entryCurrency`), `Money? walletMoney` (converted; equals `entryMoney` when same currency), `bool canCommit = walletMoney != null && walletMoney.minor > 0 && (rate != null || entryCurrency == wallet.currency)`.

#### 8.5.3 Amount input rules (numpad)

- Digit: append. Leading `0` followed by a digit replaces the `0` (typing `0`,`5` → `5`; `0`,`.`,`5` → `0.5`).
- `.`: ignored if already present or if `scale == 0` (JPY). Typing `.` on empty input yields `0.`.
- Max integer digits: 12. Max fraction digits: `entryCurrency.scale`; further digits are ignored with a light error haptic.
- `⌫`: remove last char; long-press: clear. Clearing an empty input does nothing.
- Changing `entryCurrency` re-validates fraction length (truncate silently, e.g. switching USD→JPY drops decimals).
- Display: `amountInput` shown as typed, no thousands separators while typing (keeps the caret logic trivial); the hint line shows the fully formatted converted value.

#### 8.5.4 Currency ≠ wallet currency

1. On selecting a different currency, `rateStatus = loading`, hint shows a shimmer line; `FxService.rate(entry → wallet)` is called once. Result cached in state for the screen's lifetime.
2. Hint text formats: `≈ {walletMoney} will be added to {wallet.name} · 1 {entry} = {rate 4 sig. decimals} {wallet ccy}`.
3. Offline & no cached rate → hint in `neg500` "Rate unavailable — connect to update", `canCommit = false`, INCOME/EXPENSE buttons at 40 % opacity. TRANSFER stays enabled only if the entry currency equals the wallet currency.
4. Stale cached rate → hint gets a suffix "· rate from Oct 20" (casper); commit allowed.
5. On commit: `amount_minor = convertMinor(...)`, `currency = wallet.currency`, `original_amount_minor = entryMoney.minor`, `original_currency = entry.code`, `exchange_rate = rate.rate`.

#### 8.5.5 One-tap commit (INCOME / EXPENSE) — D4

```
onTapType(type):
  if (!canCommit) → shake amount (flutter_animate), error haptic, return
  isSaving = true
  repo.create(TransactionDraft(type, wallet, walletMoney, original, rate, description, tags, date, repeat))
       → inside one db.transaction:
           insert transactions row
           for each tag: find-or-create, link, usage_count++
           if repeat != never: insert recurring_rules (+ rule tags), set transactions.recurring_rule_id, next_occurrence = advance(date, repeat)
  on success:
     medium haptic; SnackbarWidget "Saved +$1,500.00 to Savings Vault" (1.5 s, non-blocking)
     reset per [A1]: amountInput = "", description = "", tags = [], repeat = never, date = today (if it was today, else keep — user is back-filling a past day)
     keep: wallet, entryCurrency, rate
  on failure: UIAlert with message, state unchanged
```

The screen is **not** popped. The user leaves with the back arrow.

#### 8.5.6 TRANSFER — D5

`TransferSheet` (`UIModalSheet`, 60 % height):

```
Title             "Transfer $123.45 from Savings Vault"
Wallet list       all non-deleted wallets except the source; each row: badge, name, currency, balance
On select (same currency)   → footer shows "Savings Vault −$123.45  →  Checking +$123.45", button "Confirm transfer"
On select (other currency)  → footer adds an editable amount field "Amount received" pre-filled from FxService(source → target) (numpad inline, same rules as 8.5.3, scale of target ccy), rate line underneath; the user may overwrite the amount, in which case exchange_rate is recomputed as received/sent
Confirm           → repo.create(transfer) → sheet closes, same reset as 8.5.5, snackbar "Moved $123.45 to Checking"
```

Stored: `from_wallet_id = wallet`, `to_wallet_id = target`, `from_amount_minor = walletMoney.minor` (already converted if entry currency ≠ source currency; `original_*` recorded then), `to_amount_minor` = received, `exchange_rate = to_per_from` or NULL, `currency = source ccy`.

If there is only one wallet, TRANSFER tap shows `UIAlert` "Create a second wallet to transfer" with a "New Wallet" action.

Repeat applies to transfers as well (rule with `type = transfer`).

#### 8.5.7 Edit mode — D8

- Entry: `/transaction?transactionId=…`. Loads the row, resolves wallet (for transfers: the wallet the user came from is the "target" shown; the sheet is not needed — the counterpart is shown as a read-only line "→ Checking +$50.00" under the amount).
- Pre-fills: `entryCurrency = original_currency ?? currency`, `amountInput = original ?? amount` formatted plain, description, tags, date, repeat = the rule's frequency if `recurring_rule_id` is set (chip becomes read-only "Monthly · part of a repeat").
- Bottom bar: **Delete** (confirm dialog "Delete this transaction?") → soft delete → pop. **Save** → `repo.update` (diffs tags; recomputes conversion only if amount or currency changed, fetching a fresh rate and showing the hint before the user taps Save) → pop.
- Type is not editable **[A2]**; the header shows a small type pill (INCOME / EXPENSE / TRANSFER) in place of the Repeat chip's left neighbour so the user knows what they are editing.
- If the transaction was generated by a rule, Delete offers two choices: "Delete this one" / "Delete and stop repeating" (deactivates the rule).
- Wallet picker in edit mode is allowed for income/expense **only if** the new wallet has the same currency (otherwise the picker greys those wallets out with "different currency"). For transfers the wallet picker is disabled.

#### 8.5.8 Date and Repeat chips

- `UiDateChip` → `DatePickerSheet` wrapping `UICalendarPicker` (Syncfusion), max date = today + 1 year (future-dating is allowed for planned expenses; recurring rules do the rest), min = 2000-01-01. Label: `Oct 28, 2026`; shows "Today" when today.
- `UiRepeatChip` → `RepeatPickerSheet` with 5 radio rows: Never, Every day, Every week, Every month, Every year. Label: "Repeat" when never, else "Monthly" etc. Semantics on save: section 9.

#### 8.5.9 Validation (surfaced as inline `validationError`, 2 s, neg500 12 px above the bottom bar)

| Condition | Message |
|---|---|
| amount empty or zero | "Enter an amount" |
| description > 80 chars | input hard-limits; no message |
| more than 10 tags | "Up to 10 tags" |
| no rate for foreign currency | "Rate unavailable" (hint already red) |
| transfer target == source | impossible via UI |

### 8.6 Create / Edit Wallet

**Layout**

```
UIAppbar            back (←), no title
Name                UIInputField, centred, placeholder "Wallet Name", inter 32 w300 (mock: large, casper placeholder), ≤ 40 chars, autofocus in create mode
Initial balance     row: currency symbol ("$", casper 32 w300) + amount text "0.00" (bismark when non-zero) — tap focuses an inline numpad (same UiNumpad, shown as a bottom sheet to keep the mock's clean layout) [A]
Spacer 56
Row  "Currency"                     value "USD ($)" + chevron → CurrencyPickerSheet    (disabled with lock icon + "Has transactions" when [A3] applies)
Row  "Primary Wallet"               CupertinoSwitch (blue)
Spacer 24
Colour picker       5 × 24 px rounded squares (radius 6): blue #3B82F6, amber #F59E0B (buttercup), red #FF697D (neg400) *, green #65AF83 (mountainMeadow), violet #8B5CF6; selected = 2 px blue ring with 3 px gap
Spacer (flex)
Bottom row          Delete (casper text, disabled/hidden in create mode)   ·   Save (blue, semibold 18; disabled at 40 % when name empty)
```

\* the mockup's red is closer to `#EF4444`; add `UIColorToken.red = Color(0xffEF4444)` rather than reusing `neg400`. Colour keys stored in DB: `blue | amber | red | green | violet` → `WalletColor` enum → `Color` via theme.

**State**

```dart
@freezed class WalletFormState {
  WalletFormMode mode;                 // create | edit
  String name; String initialBalanceInput; CurrencyType currency; bool isPrimary; WalletColor color;
  bool currencyLocked;                 // [A3]
  bool isPrimaryLocked;                // true when this is the only wallet or in onboarding
  bool isSaving; String? nameError;
}
```

**Behaviour**

- Create: Save → `WalletRepository.create(...)`; if it is the first wallet, `is_primary = 1` regardless. Pops to the caller (Dashboard).
- Edit: Save → `update`; `initial_balance_minor` overwritten (balance view recomputes — no delta arithmetic needed, D13 semantics hold automatically). Toggling Primary off on the current primary is refused (switch snaps back with a light haptic + snackbar "Pick another wallet as primary"); toggling on moves the flag.
- Delete (edit only): `UIAlert` "Delete Savings Vault? Its transactions will be removed. Transfers with other wallets stay visible." Confirm → `softDelete` (5.10) → pop **twice** (form + details) to Dashboard, snackbar "Wallet deleted" (no undo in v1 **[A]**).
- Changing currency in create mode updates the symbol next to the initial balance and re-truncates decimals.

**Edge cases**

- Duplicate names are allowed (colour disambiguates).
- Name of whitespace only → trimmed → empty → Save disabled.
- Deleting the last wallet is allowed; Dashboard shows the empty state.

### 8.7 Settings

**Layout** (grouped list, section labels uppercase 11 px casper with tracking 1.2, rows 56 px with leading 20 px icon in casper, title 16 medium bismark, trailing chevron/value/switch)

```
UIAppbar            back (←), title "SETTINGS"
PREFERENCES
  Notifications     icon alerts/bell01        trailing CupertinoSwitch → settings.notifications_enabled (stub, D10)
  Currency          icon finance/bankNote01   trailing "USD ›" → BaseCurrencyPage (list of CurrencyType, check on current) → settings.base_currency, dashboard re-converts
  Dark Mode         icon weather/moon01       trailing CupertinoSwitch → theme_mode light/dark [A7]
DATA & PRIVACY
  Reset All Data    icon general/trash01 in neg500, title neg500 → confirm dialog (typed confirmation not required; two-step: alert with "Reset" destructive button)
Footer              "Version: 1.0.0 (1)" from package_info_plus, casper 11, centred, bottom inset 24
```

Removed rows vs mockup: Personal Information, Security (D6), Export Transactions (D9, hidden — keep the ARB string). Optional rows kept from existing code, at the bottom of PREFERENCES: "Language" (hidden while only `en` exists), "About Fiin" → `AboutProjectPage`.

**Reset All Data**

1. Close DB, delete `fiin.db` (`deleteDatabase`), delete the SQLCipher key from secure storage, clear `exchange_rates` implicitly.
2. Re-init DB (new key, fresh schema, default settings with `show_onboarding = 1`) **[A6]**.
3. `ReplaceRouteEvent('/onboarding')`. Snackbar "All data removed".

---
## 9. Recurring transactions engine

### 9.1 Model

A rule is a template (5.8). The transaction created at save time is the **first occurrence** (`transaction_date = start_date`, `recurring_rule_id = rule.id`). `next_occurrence = advance(start_date, frequency, 1)`, `occurrence_count = 1`.

`advance(date, frequency)` in **local calendar time** (the user's wall clock), then stored as epoch ms:

| Frequency | Rule |
|---|---|
| daily | +1 day |
| weekly | +7 days |
| monthly | same day next month; if the day does not exist (31 → Feb), clamp to the last day of that month **and remember the anchor day** (`start_date`'s day) so March goes back to 31. Compute from `start_date + n months`, not from the previous occurrence. |
| yearly | same month/day next year; Feb 29 → Feb 28 in non-leap years, computed from `start_date + n years`. |

Occurrence time-of-day = time part of `start_date`.

### 9.2 Catch-up (`RecurringEngine.catchUp(now)`)

Runs at startup (6.5) and when the app returns to foreground after ≥ 1 h (`WidgetsBindingObserver`).

```
rules = SELECT * FROM recurring_rules WHERE is_active = 1 AND deleted_at IS NULL AND next_occurrence <= now
for rule in rules (one db.transaction per rule):
   generated = 0
   while rule.next_occurrence <= now:
       INSERT OR IGNORE transactions(copy of rule fields, transaction_date = rule.next_occurrence, recurring_rule_id = rule.id, description = rule.description)
       copy recurring_rule_tags → transaction_tags (usage_count++)
       rule.occurrence_count += 1
       rule.next_occurrence = advance(rule.start_date, frequency, rule.occurrence_count)   // Appendix C
       generated++
       if generated > 400: break   // safety cap (daily rule untouched for > 1 year); remaining will run next launch
   if rule.end_date != NULL and rule.next_occurrence > end_date: is_active = 0
   update rule
settings.last_recurring_run_at = now
bump dbRevisionProvider once at the end
```

Idempotency: `transactions` gets a partial unique index `idx_tx_rule_date ON transactions(recurring_rule_id, transaction_date) WHERE recurring_rule_id IS NOT NULL` so a crash between insert and rule update cannot duplicate an occurrence (`INSERT OR IGNORE`).

Occurrences for a soft-deleted wallet are never generated (rule was deactivated on wallet delete, 5.10).

### 9.3 Managing rules

- `RecurringRulesSheet` (from Wallet Details summary row): list of active rules for the wallet — description (or type fallback), amount, frequency, "Next: Nov 1". Row actions: switch (pause/resume → `is_active`), trash (soft delete rule; existing occurrences stay).
- From a generated transaction in edit mode: "Delete and stop repeating" (8.5.7).
- Editing a rule's amount/description: not in v1 — delete and recreate. (Documented in the sheet as a hint.)

---

## 10. Design system

### 10.1 Tokens (existing, `UIColorToken`, `UITextStyleToken`)

| Role | Light | Dark (existing values are placeholders — dark palette still needs a pass) |
|---|---|---|
| Background | `cararra #FAFAF8` | `#120F1B` |
| Surface (tiles, sheets) | `white` | `#15121F` |
| Text primary | `bismark #456285` | ← needs a light variant, e.g. `#D6E2F0` |
| Text secondary / placeholders / dividers | `casper #AEC2D4` | `#6F7F92` |
| Accent | `blue #3B82F6` | same |
| Income | `blue` | same |
| Expense | `black` (mock) → use `neu700` | `neu100` |
| Transfer | `casper` | same |
| Destructive | `neg500 #C03649` (mock uses a brighter `#EF4444`) | same |
| Wallet colours | `blue`, `buttercup`, `red (new)`, `mountainMeadow`, `violet` | same |

Type: Inter (via `google_fonts`) for UI; **Montserrat 300/700** for the big amounts (already used in `UiTotalAmount`). Sizes used: 44 (amount), 32 (form title), 20 (section), 18 (buttons), 16 (rows), 14 (chips), 12 (captions), 11 (section labels).

Radii: tiles 12, sheets 24 top, FAB circle, colour swatches 6. Elevation: none except FAB (`UIShadowToken`).

### 10.2 Existing components → usage

| Component | Used on | Change needed |
|---|---|---|
| `UIAppbar` | all | none |
| `UiTotalAmount` | Dashboard, Wallet Details, Transaction (w700 variant) | accept `Money`; add `weight` param |
| `UiWalletCard` | Dashboard | accept `Money`; `onTap` wiring |
| `UiTransactionCard` | Wallet Details | accept `Money` + `secondaryText` (original amount) + sign/colour by *effective direction*, not only `type`; date format 11.2 (current impl prints `28.10.2026, 9:0`) |
| `UiWalletInfoMenu` / `UiSelectButton` / `UiSelectWalletButton` | Wallet Details header, Transaction header | add `enabled` (no chevron, no tap) for the static currency label |
| `UiIconTextButton` | Dashboard "New Wallet" | none |
| `UiCircleColorBadge` | lists, pickers | none |
| `UIModalSheet` | all sheets | ensure drag handle + safe area |
| `UICalendarPicker` | DatePickerSheet | none |
| `UIInputField` | description, wallet name | `centered`, `borderless` style variant |
| `UIAlert` | confirms, errors | destructive action style |
| `UIFiinLook*` | Dashboard (left), Wallet Details (right) | none |
| `UICircularProgressBar`, `TimerWidget`, `WebViewPage`, `ScrollColumnExpandableWidget` | not used in v1 | keep |

### 10.3 New components

| Component | Props | Notes |
|---|---|---|
| `UiFab` | `onTap` | 52 px blue circle, white `+`, shadow |
| `UiNumpad` | `onDigit(String)`, `onDot()`, `onBackspace()`, `onClear()`, `dotEnabled` | 3×4 grid, tile bg `fgColor`, 8 px gaps, haptics |
| `UiTypeActionButton` | `icon`, `label`, `style: transfer|income|expense`, `enabled`, `onTap` | 40 px circle + 10 px uppercase label |
| `UiDateChip`, `UiRepeatChip` | `label`, `onTap`, `readOnly` | 12 px medium casper text + chevron |
| `UiTagInput` | `tags`, `onChanged`, `suggestions(query)` | chips inline; see 11.3 |
| `UiConversionHint` | `text`, `state: ok|loading|error|stale` | one line under the amount |
| `UiSettingsTile` | `icon`, `title`, `trailing: chevron|value|switch`, `destructive` | 56 px row |
| `UiSectionLabel` | `text` | uppercase casper 11 |
| `UiColorPicker` | `colors`, `selected`, `onSelect` | 5 swatches |
| `UiEmptyState` | `image`, `title`, `subtitle?`, `action?` | mascot-driven empty states |
| `UiSkeletonList` | — | shimmer for first load |
| `WalletPickerSheet`, `CurrencyPickerSheet`, `TransferSheet`, `DatePickerSheet`, `RepeatPickerSheet`, `RecurringRulesSheet` | feature-level widgets built from the above | |

### 10.4 Motion

`flutter_animate`: mascot slide-in (400 ms, easeOutBack), amount shake on invalid commit (3 × 6 px, 300 ms), row removal on delete (`AnimatedList`/`SliverAnimatedList`, 250 ms), FAB scale-in on page enter (200 ms). Total counter uses `AnimatedFlipCounter` (already a dependency) when the value changes while the Dashboard is visible.

---

## 11. Formatting rules

### 11.1 Amounts

`Money.format()` → `NumberFormat.currency(locale: 'en_US', symbol: currency.symbol, decimalDigits: currency.scale)`:

| Case | Output |
|---|---|
| USD 1234567 minor | `$12,345.67` |
| EUR | `€5,678.90` (symbol before, en_US style — matches mock; locale-aware placement is v2) |
| JPY | `¥1,500` |
| BTC 420000 minor | `₿0.00420000` (trailing zeros kept for crypto so width is stable) |
| CHF, kr | `CHF 1,234.00`, `kr 1,234.00` (space after multi-letter symbols) |
| signed (lists) | `+$1,500.00`, `-$120.00` |
| conversion hint rate | 4 significant decimals, trailing zeros trimmed: `1 USD = 0.9203 EUR`, `1 BTC = 61,234.5 USD` |

### 11.2 Dates

- Lists: `MMM d, hh:mm a` → `Oct 28, 09:00 AM` (same year); `MMM d, yyyy` for other years.
- Date chip: `MMM d, yyyy`, "Today" / "Yesterday" shortcuts.
- Stored `transaction_date`: if the chosen date is today → `DateTime.now()`; otherwise → chosen date at **12:00 local** (keeps ordering stable and avoids DST edge cases). Editing the date keeps the existing time when the date is unchanged.
- All comparisons in local time via `DateTime.toLocal()`; storage in UTC epoch ms.

### 11.3 Tags

- Input tokenises on space, comma or Enter. Leading `#` optional and stripped. `Food`, `#food`, `food ` → one tag `food` (display keeps the first-typed casing).
- Chips rendered inline in the field, tap ✕ to remove, backspace on empty input removes the last chip.
- Autocomplete: after 1 char, dropdown of up to 5 tags `WHERE normalized_name LIKE ?||'%' AND deleted_at IS NULL ORDER BY usage_count DESC, last_used_at DESC`.
- Max 10 tags per transaction, 30 chars per tag, no spaces inside a tag.

---

## 12. Error handling and edge cases

| Situation | Handling |
|---|---|
| DB open failure (corrupted, key missing) | Splash retries 3×, then `UIAlert` "Couldn't open your data" with "Retry" and "Reset app" (same as Reset All Data). Never silently recreate the DB. |
| Secure storage returns null after app reinstall on iOS while DB file survived | Impossible to decrypt → same alert as above. |
| Rate fetch fails | See 8.5.4; Dashboard excludes the wallet from total, caption explains. |
| App killed mid-transaction | SQLite transaction guarantees atomicity; catch-up index guarantees no duplicate occurrences. |
| Clock moved backwards | Catch-up uses `next_occurrence <= now`; nothing generated early; nothing deleted. |
| Huge amounts | 12 integer digits max (≈ 999 billion) — enough; `int` is 64-bit on all Flutter mobile targets. |
| Deleting a wallet that is the target of an active transfer rule | Rule is deactivated (5.10), snackbar mentions "1 repeat paused". |
| Concurrency | Single-process app; all writes go through repositories on the main isolate; `sqflite` serialises. No isolates needed in v1. |

---

## 13. Existing code fixes

Do these before feature work; each is small.

| # | File | Issue | Fix |
|---|---|---|---|
| 1 | `lib/src/src/**` | Double `src` directory | Move to `lib/src/`, fix imports, `l10n.yaml` paths. |
| 2 | `sqlite_services.dart` | `print(psw)` leaks the DB key to logs; copy-pasted strings ("barometerDB", "worship_barometer") | Remove; rename log messages. |
| 3 | `sqlite_services.dart` | `openDatabase('fiinapp.db')` relative path; no `onConfigure` | Use `join(await getDatabasesPath(), 'fiin.db')`; add `onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON')`; add `onUpgrade`. |
| 4 | `sqlite_config.dart` | `static String` keys | `static const`. |
| 5 | `transaction_type.dart` | `fromString` compares `toUpperCase()` against lowercase literals → always `undefined` | Compare `toLowerCase()`; drop `undefined` (use nullable). |
| 6 | `currency_type.dart` | no BTC; `formatCurrency` hardcodes JPY | Enhanced enum with `scale` (4.1); `Money.format`. |
| 7 | `settings_provider.dart` | `initLocalSettings` routes to dashboard in both branches | Route to `/onboarding` when `showOnboarding`. |
| 8 | `ui_transaction_card.dart` | Date formatted manually (`9:0`), amount `num` | Use `intl` pattern 11.2; `Money`. |
| 9 | `route_paths.dart` | `graph`, `goalsSettings`, `freemium` unused | Remove for v1. |
| 10 | `onboarding_1_page.dart` | Component showcase pretending to be onboarding | Move to `tool/gallery_page.dart` (debug only). |
| 11 | `.gitignore` | `.DS_Store` files committed | Add `.DS_Store`, run `git rm --cached`. |
| 12 | `pubspec.yaml` | `webview_flutter` **and** `flutter_inappwebview` both present; `syncfusion` (commercial licence) only for a date picker | Keep one webview (or none in v1); consider replacing Syncfusion with `table_calendar` or `showDatePicker` styled — licence risk before store release. Add `uuid`, `package_info_plus`, `connectivity_plus` (optional, for the "connect to update" hint). |
| 13 | `ui_color_token.dart` | dark theme reuses light `bismark`/`casper` | Provide dark variants (10.1). |

---

## 14. Implementation roadmap

Milestones are vertical slices; each ends with a runnable app.

| M | Deliverable | Contents |
|---|---|---|
| **M0 Foundation** (1–2 days) | clean base | Section 13 fixes; `Money`/`CurrencyType`; full schema v1 in `sqlite_schema.dart` + `onCreate`; `dbRevisionProvider`; `uuid`. Unit tests for `Money.parse/format`, `advance()`. |
| **M1 Wallets** (2 days) | Dashboard + Wallet form | `WalletRepository` (+ invariants), `wallet_balances` view, Dashboard (without FX: total only over base-currency wallets, caption "N not included"), Create/Edit/Delete wallet, empty states, mascot. |
| **M2 Transactions** (3–4 days) | the core loop | `TransactionRepository`, `TagRepository`, Transaction screen (create, one-tap commit, numpad, tags, date), Wallet Details list, swipe-delete + undo, edit mode. |
| **M3 Multi-currency** (2 days) | FX | `FxService` + cache; entry-currency selector + hint; TransferSheet with cross-currency amount; Dashboard total conversion. |
| **M4 Recurring** (2 days) | rules | Repeat chip, rule creation, catch-up engine, RecurringRulesSheet, delete-and-stop. |
| **M5 Settings & Onboarding** (1–2 days) | polish | Settings rewrite (rows per 8.7), base currency, dark mode toggle, Reset All Data, Onboarding 3 steps, version footer. |
| **M6 Release prep** (1–2 days) | store-ready | Dark palette pass, app icon/splash regen, Syncfusion licence decision, analytics-free privacy text, TestFlight/internal track. |

Total ≈ 12–15 working days for one developer.

---

## 15. Testing strategy

| Level | What | Tooling |
|---|---|---|
| Unit | `Money` parse/format for every currency scale; `convertMinor` rounding; `advance()` for month-end/leap cases; tag normalisation | `flutter_test` |
| Repository (integration, real SQLite) | invariants 5.10: single primary, currency lock, soft delete cascades, undo, tag usage counts, transfer balance effects, recurring idempotency | `sqflite_common_ffi` in-memory DB on desktop (no cipher needed for tests — abstract `openDatabase` behind `SQLiteServices`) |
| Notifier | `TransactionNotifier` input rules (8.5.3), commit reset (8.5.5), edit prefill | `ProviderContainer` tests |
| Widget | numpad, tag input, wallet form validation, settings toggles | `flutter_test` widget tests |
| Golden | Dashboard, Wallet Details, Transaction (light + dark) | `golden_toolkit` or `flutter_test` goldens at 375×812 |
| Manual checklist | offline FX path, reinstall/key loss path, catch-up after date change in device settings, RTL not required | — |

---
## Appendix A — full SQL DDL

Database version **1**. Execute in this order inside `onCreate` (one `batch`).

```sql
-- 1. settings -----------------------------------------------------------
CREATE TABLE settings (
  id                    INTEGER PRIMARY KEY CHECK (id = 1),
  language_code         TEXT,
  country_code          TEXT,
  theme_mode            TEXT    NOT NULL DEFAULT 'system' CHECK (theme_mode IN ('system','light','dark')),
  show_onboarding       INTEGER NOT NULL DEFAULT 1,
  base_currency         TEXT    NOT NULL DEFAULT 'USD',
  notifications_enabled INTEGER NOT NULL DEFAULT 0,
  last_recurring_run_at INTEGER
);
INSERT INTO settings (id) VALUES (1);

-- 2. wallets ------------------------------------------------------------
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
);
CREATE INDEX idx_wallets_deleted ON wallets(deleted_at);
CREATE INDEX idx_wallets_sort    ON wallets(sort_order, created_at);
CREATE UNIQUE INDEX idx_wallets_primary ON wallets(is_primary) WHERE is_primary = 1 AND deleted_at IS NULL;

-- 3. tags ---------------------------------------------------------------
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
);
CREATE UNIQUE INDEX idx_tags_normalized_active ON tags(normalized_name) WHERE deleted_at IS NULL;
CREATE INDEX idx_tags_usage ON tags(usage_count DESC, last_used_at DESC);

-- 4. recurring_rules ----------------------------------------------------
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
);
CREATE INDEX idx_rules_due     ON recurring_rules(is_active, next_occurrence);
CREATE INDEX idx_rules_wallet  ON recurring_rules(wallet_id);
CREATE INDEX idx_rules_deleted ON recurring_rules(deleted_at);

-- 5. transactions -------------------------------------------------------
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
);
CREATE INDEX idx_tx_wallet_date ON transactions(wallet_id, transaction_date DESC);
CREATE INDEX idx_tx_from_date   ON transactions(from_wallet_id, transaction_date DESC);
CREATE INDEX idx_tx_to_date     ON transactions(to_wallet_id, transaction_date DESC);
CREATE INDEX idx_tx_date        ON transactions(transaction_date DESC);
CREATE INDEX idx_tx_deleted     ON transactions(deleted_at);
CREATE INDEX idx_tx_updated     ON transactions(updated_at);
CREATE UNIQUE INDEX idx_tx_rule_date ON transactions(recurring_rule_id, transaction_date) WHERE recurring_rule_id IS NOT NULL;

-- 6. link tables --------------------------------------------------------
CREATE TABLE transaction_tags (
  transaction_id TEXT    NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
  tag_id         TEXT    NOT NULL REFERENCES tags(id)         ON DELETE CASCADE,
  created_at     INTEGER NOT NULL,
  PRIMARY KEY (transaction_id, tag_id)
);
CREATE INDEX idx_tt_tag ON transaction_tags(tag_id);

CREATE TABLE recurring_rule_tags (
  recurring_rule_id TEXT    NOT NULL REFERENCES recurring_rules(id) ON DELETE CASCADE,
  tag_id            TEXT    NOT NULL REFERENCES tags(id)            ON DELETE CASCADE,
  created_at        INTEGER NOT NULL,
  PRIMARY KEY (recurring_rule_id, tag_id)
);
CREATE INDEX idx_rrt_tag ON recurring_rule_tags(tag_id);

-- 7. exchange_rates -----------------------------------------------------
CREATE TABLE exchange_rates (
  base_currency  TEXT NOT NULL,
  quote_currency TEXT NOT NULL,
  rate           REAL NOT NULL,
  fetched_at     INTEGER NOT NULL,
  PRIMARY KEY (base_currency, quote_currency)
);

-- 8. view ---------------------------------------------------------------
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
WHERE w.deleted_at IS NULL;
```

## Appendix B — key queries

```sql
-- B1. Dashboard wallet list with balances (8.3)
SELECT w.id, w.name, w.currency, w.color, w.is_primary, b.balance_minor
FROM wallets w JOIN wallet_balances b ON b.wallet_id = w.id
WHERE w.deleted_at IS NULL
ORDER BY w.sort_order, w.created_at;

-- B2. Primary wallet
SELECT * FROM wallets WHERE is_primary = 1 AND deleted_at IS NULL LIMIT 1;

-- B3. Set primary (inside a transaction)
UPDATE wallets SET is_primary = 0, updated_at = ?now WHERE is_primary = 1 AND deleted_at IS NULL;
UPDATE wallets SET is_primary = 1, updated_at = ?now WHERE id = ?id;

-- B4. Wallet has transactions (currency lock)
SELECT EXISTS(SELECT 1 FROM transactions
              WHERE deleted_at IS NULL AND (wallet_id = ?id OR from_wallet_id = ?id OR to_wallet_id = ?id));

-- B5. Soft delete wallet (inside a transaction)
UPDATE wallets SET deleted_at = ?now, updated_at = ?now, is_primary = 0 WHERE id = ?id;
UPDATE transactions SET deleted_at = ?now, updated_at = ?now
  WHERE wallet_id = ?id AND deleted_at IS NULL;
UPDATE recurring_rules SET is_active = 0, updated_at = ?now
  WHERE (wallet_id = ?id OR from_wallet_id = ?id OR to_wallet_id = ?id) AND deleted_at IS NULL;
-- then promote a new primary if needed:
UPDATE wallets SET is_primary = 1, updated_at = ?now
  WHERE id = (SELECT id FROM wallets WHERE deleted_at IS NULL ORDER BY sort_order, created_at LIMIT 1)
  AND NOT EXISTS (SELECT 1 FROM wallets WHERE is_primary = 1 AND deleted_at IS NULL);

-- B6. Wallet transactions page (8.4)
SELECT t.*, fw.name AS from_wallet_name, fw.deleted_at AS from_wallet_deleted,
       tw.name AS to_wallet_name,  tw.deleted_at AS to_wallet_deleted
FROM transactions t
LEFT JOIN wallets fw ON fw.id = t.from_wallet_id
LEFT JOIN wallets tw ON tw.id = t.to_wallet_id
WHERE t.deleted_at IS NULL
  AND (t.wallet_id = ?id OR t.from_wallet_id = ?id OR t.to_wallet_id = ?id)
ORDER BY t.transaction_date DESC, t.created_at DESC
LIMIT ?limit OFFSET ?offset;

-- B7. Tags of a transaction
SELECT g.* FROM tags g JOIN transaction_tags tt ON tt.tag_id = g.id
WHERE tt.transaction_id = ?id AND g.deleted_at IS NULL;

-- B8. Tag autocomplete
SELECT id, display_name FROM tags
WHERE deleted_at IS NULL AND normalized_name LIKE ?prefix || '%'
ORDER BY usage_count DESC, last_used_at DESC LIMIT 5;

-- B9. Find-or-create tag
SELECT id FROM tags WHERE normalized_name = ?n AND deleted_at IS NULL;
-- if none: INSERT INTO tags (...) ; then
INSERT OR IGNORE INTO transaction_tags (transaction_id, tag_id, created_at) VALUES (?, ?, ?);
UPDATE tags SET usage_count = usage_count + 1, last_used_at = ?now, updated_at = ?now WHERE id = ?tag;

-- B10. Due recurring rules
SELECT * FROM recurring_rules
WHERE is_active = 1 AND deleted_at IS NULL AND next_occurrence <= ?now;

-- B11. Cached rate
SELECT rate, fetched_at FROM exchange_rates WHERE base_currency = ? AND quote_currency = ?;
INSERT OR REPLACE INTO exchange_rates (base_currency, quote_currency, rate, fetched_at) VALUES (?, ?, ?, ?);

-- B12. Full export (v2, order matters for import)
SELECT * FROM wallets; SELECT * FROM tags; SELECT * FROM recurring_rules; SELECT * FROM transactions;
SELECT * FROM transaction_tags; SELECT * FROM recurring_rule_tags;
```

## Appendix C — Dart model sketches

```dart
// core/money/money.dart
@immutable
class Money {
  const Money(this.minor, this.currency);
  final int minor;
  final CurrencyType currency;

  static Money parse(String input, CurrencyType c) {
    final s = input.trim();
    if (s.isEmpty) return Money(0, c);
    final parts = s.split('.');
    final intPart = parts[0].isEmpty ? '0' : parts[0];
    var frac = parts.length > 1 ? parts[1] : '';
    frac = frac.length > c.scale ? frac.substring(0, c.scale) : frac.padRight(c.scale, '0');
    return Money(int.parse('$intPart$frac'), c);
  }

  String format({bool signed = false, bool positiveSign = false}) {
    final f = NumberFormat.currency(locale: 'en_US', symbol: currency.symbol, decimalDigits: currency.scale);
    final s = f.format(minor.abs() / math.pow(10, currency.scale));   // formatting only — never stored
    if (signed && minor < 0) return '-$s';
    if (positiveSign && minor > 0) return '+$s';
    return s;
  }
}

int convertMinor(int fromMinor, CurrencyType from, CurrencyType to, double rate) {
  if (from == to) return fromMinor;
  final value = fromMinor / math.pow(10, from.scale);
  return (value * rate * math.pow(10, to.scale)).round();
}

// features/wallet/data/models/wallet_model.dart
@freezed
class WalletModel with _$WalletModel {
  const factory WalletModel({
    required String id, required String name, required CurrencyType currency,
    required int initialBalanceMinor, required WalletColor color, required bool isPrimary,
    required int sortOrder, required DateTime createdAt, required DateTime updatedAt, DateTime? deletedAt,
  }) = _WalletModel;
  factory WalletModel.fromRow(Map<String, Object?> r) => ...;
  Map<String, Object?> toRow() => ...;
}

class WalletSummary { final WalletModel wallet; final Money balance; }

// features/transaction/data/models/transaction_model.dart
@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id, required TransactionType type,
    String? walletId, int? amountMinor, required CurrencyType currency,
    String? fromWalletId, String? toWalletId, int? fromAmountMinor, int? toAmountMinor,
    int? originalAmountMinor, CurrencyType? originalCurrency, double? exchangeRate,
    required String description, required DateTime transactionDate, String? recurringRuleId,
    required DateTime createdAt, required DateTime updatedAt, DateTime? deletedAt,
  }) = _TransactionModel;
}

/// What the Transaction screen hands to the repository (no ids, no timestamps).
@freezed
class TransactionDraft with _$TransactionDraft {
  const factory TransactionDraft.income({required String walletId, required Money amount, Money? original, double? rate,
      required String description, required List<String> tags, required DateTime date, required RepeatFrequency repeat}) = _IncomeDraft;
  const factory TransactionDraft.expense({...same}) = _ExpenseDraft;
  const factory TransactionDraft.transfer({required String fromWalletId, required String toWalletId,
      required Money sent, required Money received, Money? original, double? rate,
      required String description, required List<String> tags, required DateTime date, required RepeatFrequency repeat}) = _TransferDraft;
}

// features/transaction/data/transaction_repository.dart (signature only)
abstract class TransactionRepository {
  Future<SuccessOrError<TransactionModel>> create(TransactionDraft draft);
  Future<SuccessOrError<TransactionModel>> update(String id, TransactionDraft draft);
  Future<SuccessOrError<void>> softDelete(String id, {bool stopRule = false});
  Future<SuccessOrError<void>> restore(String id);
  Future<SuccessOrError<List<TransactionRow>>> pageForWallet(String walletId, {int limit = 50, int offset = 0});
  Future<SuccessOrError<TransactionWithTags>> byId(String id);
}

// core/recurring/recurring_engine.dart
DateTime advance(DateTime start, RepeatFrequency f, int n) => switch (f) {
  RepeatFrequency.daily   => start.add(Duration(days: n)),
  RepeatFrequency.weekly  => start.add(Duration(days: 7 * n)),
  RepeatFrequency.monthly => _addMonthsClamped(start, n),
  RepeatFrequency.yearly  => _addMonthsClamped(start, 12 * n),
  RepeatFrequency.never   => throw StateError('never'),
};
DateTime _addMonthsClamped(DateTime d, int months) {
  final y = d.year + (d.month - 1 + months) ~/ 12;
  final m = (d.month - 1 + months) % 12 + 1;
  final lastDay = DateTime(y, m + 1, 0).day;
  return DateTime(y, m, math.min(d.day, lastDay), d.hour, d.minute);
}
```

---

*End of specification. Changes to this document should be recorded in a `## Changelog` section appended below.*

## Changelog

- 2026-09-01 — v1.0: initial specification from the five approved mockups and the decisions log.
