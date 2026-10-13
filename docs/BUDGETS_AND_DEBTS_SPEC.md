# Wumbi — Budgets & Debts Specification (v1.1 features)

> **Audience:** Claude (implementation agent) and the product owner.
> **Status:** approved product direction (2026-10-07). Binding unless a section is marked **[A]** (assumption: implement as written, flag it in the PR/summary).
> **Companion docs:** `docs/WUMBI_SPEC_V1.md` (base spec: money, data conventions, architecture, design system). This document extends it. Where they disagree, **the current code wins over WUMBI_SPEC_V1**, and this document wins over both for the two new features.

---

## Table of contents

0. [Read this first — instructions for Claude](#0-read-this-first--instructions-for-claude)
1. [Product summary](#1-product-summary)
2. [Decisions log](#2-decisions-log)
3. [Cross-feature rules](#3-cross-feature-rules)
4. [Data model & migration v3 → v4](#4-data-model--migration-v3--v4)
5. [Budgets — domain logic](#5-budgets--domain-logic)
6. [Budgets — UI](#6-budgets--ui)
7. [Debts — domain logic](#7-debts--domain-logic)
8. [Debts — UI](#8-debts--ui)
9. [Changes to existing features](#9-changes-to-existing-features)
10. [Routes, providers, components, l10n](#10-routes-providers-components-l10n)
11. [Implementation plan & acceptance criteria](#11-implementation-plan--acceptance-criteria)
12. [Testing](#12-testing)
13. [Edge cases](#13-edge-cases)
14. [Out of scope](#14-out-of-scope)
- [Appendix A — SQL](#appendix-a--sql)
- [Appendix B — Dart sketches](#appendix-b--dart-sketches)
- [Changelog](#changelog)

---

## 0. Read this first — instructions for Claude

You are implementing two features in an existing, carefully structured Flutter app. **Correctness and consistency with the existing architecture matter more than speed.** Write code a senior reviewer would merge without comments.

### 0.1 Before writing any code

1. Read `docs/WUMBI_SPEC_V1.md` sections 4 (money/FX), 5 (data model conventions), 6 (architecture), 10 (design system), 11 (formatting).
2. Read these reference implementations end-to-end — they define the patterns you must copy:

| Pattern | Reference files |
|---|---|
| Schema + migration | `lib/src/core/local/database/sqlite/sqlite_schema.dart`, `sqlite_migrations.dart`, `sqlite_config.dart`, `test/core/migration_v2_test.dart` |
| Datasource (raw SQL, row ↔ model) | `features/tag/data/tag_local_datasource.dart`, `features/progress/data/progress_local_datasource.dart` |
| Repository (invariants, `db.transaction`, `Failure.exceptionsCatcher`, `onWrite`) | `features/transaction/data/transaction_repository.dart`, `features/tag/data/tag_repository.dart` (txn-scoped helpers that join a caller's transaction) |
| Cross-screen read provider (`AsyncNotifier` + `dbRevisionProvider` + optimistic update) | `features/subscription/ui/subscriptions_provider.dart` |
| FX in read models (cached rates only, skip unconvertible) | `monthlySubscriptionTotalProvider` in the same file |
| Screen notifier + single events | `features/transaction/ui/transaction_notifier.dart`, `features/wallet/ui/wallet_details_notifier.dart` |
| Page layout / slivers / header | `features/dashboard/ui/dashboard_page.dart`, `features/wallet/ui/wallet_details_page.dart`, `features/tag/ui/tag_details_page.dart` |
| Form page | `features/wallet/ui/wallet_form_page.dart`, `widgets/wallet_form_body.dart` |
| Bottom sheets | `UIModalSheet.modalSheet`, `WalletPickerSheet`, `TransactionFilterSheet`, `RepeatPickerSheet`, `AmountNumpadSheet` |
| Period math | `lib/src/core/recurring/recurring_schedule.dart` (`advance`, `addMonthsClamped`) |
| Tests (real SQLite via ffi) | `test/features/repositories_test.dart` |

3. If anything in this document conflicts with what you find in the code, **follow the code's conventions**, implement the product behaviour described here, and record the deviation in the [Changelog](#changelog) at the bottom of this file. If a conflict changes **product behaviour**, stop and ask.

### 0.2 Engineering rules (non-negotiable)

**Architecture**
- Feature-first layout: `lib/src/features/<feature>/{data,ui}`. New features: `budget/`, `debt/`.
- Layer responsibilities (from WUMBI_SPEC_V1 §6.1) are strict:
  - `*_local_datasource.dart` — SQL only, row ↔ model mapping. No business rules, no FX.
  - `*_repository.dart` — invariants, `sqlite.db.transaction(...)`, FX conversion, `Failure.exceptionsCatcher` → `SuccessOrError<T>`. Calls `onWrite()` **once, after** a successful commit. Never imports Flutter widgets or `BuildContext`.
  - `*_notifier.dart` / `*_provider.dart` — Riverpod 3 `Notifier` / `AsyncNotifier` (no legacy `StateNotifier`, no codegen). Side effects (toasts, navigation, haptics) through `appEventProvider` single events, never through state.
  - Pages / widgets — rendering only, `flutter_hooks` for local UI state. No repository calls from widgets.
- Read providers `ref.watch(dbRevisionProvider)` so every write anywhere refreshes them. Do not add manual "reload after save" wiring.
- Pure domain logic (period math, budget metrics, debt resolution, allocation) lives in plain Dart files with no Flutter / sqflite imports, so it is unit-testable: `features/budget/data/budget_period.dart`, `budget_metrics.dart`, `features/debt/data/debt_resolution.dart`.

**Data**
- All column / table names via `SQLiteConfig` `static const`s. No string literals for column names in queries.
- UUID v4 ids from `newId()`; timestamps `nowMs()` / `epochMs` extensions (UTC epoch ms). Period boundaries are **local** midnights converted to epoch ms (never SQLite `strftime`).
- Money is `int` minor units wrapped in `Money`. `double` only for the single FX multiplication inside `convertMinor`. Never sum doubles.
- Soft delete everywhere (`deleted_at`). Every read filters `deleted_at IS NULL` unless explicitly reading history.
- **Derived, not stored.** Budget spent/remaining and debt remaining are computed from transactions/payments. The only cached status is `debts.closed_at` / `close_reason`, recomputed inside the same SQLite transaction as any write that can change it.
- Every multi-row write is one `db.transaction`. Cascades share one `now` value so undo can restore exactly the rows that were deleted together.

**UI**
- Reuse existing design-system components first (list in §10.3). New components go into `lib/src/core/design_system/src/components/…` with the `Ui` prefix, are exported from `app_ui.dart`, use tokens only (`context.colors`, `context.typo`, `UIColorToken`), work in light **and** dark theme, and are added to `lib/src/tool/gallery_page.dart`.
- Every user-visible string goes into **all 7 ARB files** (`lib/src/core/locale/arbs/app_{en,ru,fr,de,nl,tr,ar}.arb`). English is the template; provide real translations for the others (not English copies). Use ICU plurals like the existing `subscriptions_count`. Run `flutter gen-l10n`.
- Haptics through `AppVibrations` (light on selection, medium on commit, heavy on delete), matching existing screens.
- Secondary choices are bottom sheets (`UIModalSheet`), not routes.

**Quality gates (every milestone)**
- `dart run build_runner build --delete-conflicting-outputs` (freezed + auto_route) succeeds.
- `flutter analyze` → zero issues. `flutter test` → green, including the new tests from §12.
- No unrelated refactors. No new packages except `share_plus` (§8.6). Keep diffs focused.
- Doc comments (`///`) on every public class/method explaining **why**, in the same tone as the existing code.
- If asked to commit: one commit per milestone, gitmoji style as in `git log` (`✨`, `♻️`, `🐛`, `🗃️` for migrations).

---

## 1. Product summary

### 1.1 Budgets
A **budget** is a standalone spending limit: *"€400 per month on groceries"*. It has a **period**, a **limit**, and a **scope** = which expenses count (a set of wallets and/or a set of tags). It answers three questions at a glance: *how much is spent, how much is already committed (planned), how much is safe to spend per day until the period ends.*

Scope examples:

| Scope | Example | Meaning |
|---|---|---|
| wallets only | "Card: €1,500 / month" | every expense from Card |
| tags only | "#food: €400 / month" | every expense tagged #food in any wallet |
| wallets + tags | "#cafe on Card: €100 / week" | expenses from Card tagged #cafe |
| neither | "All spending: €2,500 / month" | every expense |

### 1.2 Debts
Personal debts between the user and **people**: *"Ahmed owes me €50"*, *"I owe Sara €200"*. Creating a debt is as fast as logging a transaction (one extra chip). Closing one takes two taps. Debt money moves wallet balances but **is never counted as spending or income** in budgets, Progress or tag analytics.

---

## 2. Decisions log

| # | Topic | Decision |
|---|---|---|
| B1 | Budget concept | Standalone entity, independent of wallets. Scope = wallets ∪ tags (both optional). Empty wallet set = all wallets; empty tag set = any/no tag. |
| B2 | Tag matching | A transaction matches when it carries **any** of the budget's tags. It is counted **once** even with several matching tags. |
| B3 | What counts | Posted `expense` rows only. Transfers never count (money moving between own wallets). Debt-linked rows never count (§3.1). Income never reduces spent (no refunds logic in v1). |
| B4 | Planned | Optional per budget (`include_planned`, default on): `upcoming` expenses + future occurrences of active expense subscriptions inside the current period. |
| B5 | Periods | weekly / monthly / yearly / one-time (custom range). Monthly start day is configurable (e.g. salary day = 25). |
| B6 | Rollover | none (default) / carry surplus / carry surplus and overspend. Not available for one-time budgets. |
| B7 | Visibility | Dashboard section **"Budgets"** under "Wallets" (always visible once a wallet exists). Wallet Details block under the balance for budgets scoped to that wallet. Toast after an expense commit. No budget hint before commit on the Transaction screen (the type is chosen by the final tap). |
| B8 | Budget detail | A dedicated page (`/budgets/:id`) because a budget may span several wallets — wallet-scoped list filters cannot show it. |
| D1 | Debt scope | Personal debts with people only. Credit cards / loans as liability wallets: out of scope (§14). |
| D2 | Debt money | A debt may move money (linked wallet transaction) or not (e.g. a friend paid for my dinner). |
| D3 | Analytics | Debt-linked transactions move balances (they are real money) but are excluded from budgets, Progress and tag sums. |
| D4 | Creation UX | **Person** chip on the Transaction screen. With a person selected the bottom bar becomes **GAVE / GOT** (TRANSFER hidden). The app resolves new debt vs. repayment and states the outcome in a hint line above the numpad. |
| D5 | Closing UX | Debt sheet with a primary **"Returned in full"** button (two taps total), plus Part / Forgive / Remind. No swipe-to-settle (swipe already means delete). |
| D6 | Entry point | Dashboard pill **"N debts"**, shown only while open debts exist (same contextual pattern as "N Subscriptions"). Red dot when any is overdue. Debts page also creatable via its own ⊕. |
| D7 | Net worth | **[A]** Dashboard total is unchanged (wallet balances only). Debts are not added to or subtracted from it. |
| D8 | Notifications | **[A]** Out of scope (the notifications toggle is still a stub). |

Assumptions **[A]** (implement as written, list them in your final summary):

- **[A1]** Over-repayment is refused with an inline validation message ("Ahmed owes you only €150"). No automatic opposite debt.
- **[A2]** Each GAVE/GOT that is not a repayment creates a **new** debt row (separate items: "dinner", "taxi"). Person-level netting is display-only.
- **[A3]** Repayments are allocated **FIFO** (oldest open debt first) when resolved from the Transaction screen. From the Debt sheet the repayment targets that specific debt.
- **[A4]** Person chip and Repeat are mutually exclusive (no recurring debts). Person chip and a future date are mutually exclusive (no upcoming debts).
- **[A5]** Budget metrics convert currencies with **cached** rates at read time (like the subscription monthly total). Unconvertible currencies are skipped and the budget is flagged `incomplete`.
- **[A6]** Editing a budget's limit/scope applies to all periods, past ones included (history is derived, no per-period snapshots).
- **[A7]** Debt currency = the currency the user typed (`original_currency` if set, else the wallet currency).
- **[A8]** Debt-linked transactions are not editable through the Transaction edit screen. Tapping them opens the Debt sheet. Amount mistakes = delete (with undo) and re-enter, consistent with spec V1 [A2].

---

## 3. Cross-feature rules

### 3.1 Debt-linked transactions
A transaction is **debt-linked** when `transactions.debt_role IS NOT NULL` (`'principal'` = money moved when the debt was opened; `'repayment'` = money moved when (part of) a debt was paid back).

| Consumer | Rule |
|---|---|
| `wallet_balances` view | **unchanged** — debt money is real money |
| Budgets (spent, planned, suggestions) | `AND t.debt_role IS NULL` |
| Progress (`ProgressLocalDatasource.sumsByPeriod`, `expenseByTag`) | `AND t.debt_role IS NULL` |
| Tag stats (`TagLocalDatasource.sumsByTag`, `walletsOfTag` sums, graph) | `AND t.debt_role IS NULL` |
| Wallet Details / Tag details / Search lists | rows are **shown**, marked with a debt badge, and open the Debt sheet on tap |
| Recurring rules | never debt-linked ([A4]) |

### 3.2 Time
All periods are half-open `[start, end)` in **local** time at midnight, stored/compared as UTC epoch ms. `now` is injected (`DateTime? now`) into every pure function and repository read for testability (same convention as `UpcomingPoster.postDue({DateTime? now})`).

### 3.3 FX
- Reads (budgets, debt totals, person balances in base currency): `FxService.cachedRate` only, never network. Unconvertible → skip + flag.
- Writes (debt repayment allocation across currencies): `FxService.rate(...)` (may fetch; throws `FxUnavailableException` → existing `FxUnavailableFailure`). Same-currency paths never touch FX and must be exact.

---

## 4. Data model & migration v3 → v4

`SQLiteConfig.dbVersion` 3 → **4**. Add `SQLiteSchemaV4` (latest) = v3 statements + new statements below, and `_v3ToV4` in `SQLiteMigrations.migrations`. Full DDL in [Appendix A](#appendix-a--sql). Add every table/column name as a `static const` in `SQLiteConfig`.

### 4.1 New tables

**`budgets`**

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | UUID |
| `name` | TEXT NOT NULL | 1–40 chars, trimmed. Default derived from scope (§6.6) |
| `limit_minor` | INTEGER NOT NULL | `> 0`, in `currency` |
| `currency` | TEXT NOT NULL | ISO code; default base currency, or the wallet currency when the scope is exactly one wallet |
| `period` | TEXT NOT NULL | `weekly` / `monthly` / `yearly` / `custom` |
| `anchor_date` | INTEGER NOT NULL | local midnight (epoch ms) of the first day of the first period. Monthly: its day-of-month is the start day. Weekly: its weekday is the start weekday |
| `end_date` | INTEGER | `custom` only: **exclusive** end (local midnight of the day after the last day) |
| `rollover` | TEXT NOT NULL DEFAULT 'none' | `none` / `surplus` / `both` |
| `include_planned` | INTEGER NOT NULL DEFAULT 1 | |
| `sort_order` | INTEGER NOT NULL DEFAULT 0 | creation order (reorder: later) |
| `created_at`, `updated_at`, `deleted_at`, `sync_status` | | standard |

**`budget_wallets`** `(budget_id, wallet_id, created_at)`, composite PK. Empty = all wallets.
**`budget_tags`** `(budget_id, tag_id, created_at)`, composite PK. Empty = any tag.

**`people`**

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `name` | TEXT NOT NULL | display name, 1–40 chars |
| `normalized_name` | TEXT NOT NULL | lower-case, trimmed, NFC; partial unique among live rows |
| `last_used_at` | INTEGER | picker ordering |
| `created_at`, `updated_at`, `deleted_at`, `sync_status` | | |

**`debts`**

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `person_id` | TEXT NOT NULL FK people | |
| `direction` | TEXT NOT NULL | `lent` (they owe me) / `borrowed` (I owe them) |
| `principal_minor` | INTEGER NOT NULL | `> 0`, in `currency` |
| `currency` | TEXT NOT NULL | [A7] |
| `description` | TEXT NOT NULL DEFAULT '' | ≤ 80 chars |
| `opened_at` | INTEGER NOT NULL | the date of the loan (FIFO order key) |
| `due_date` | INTEGER | optional, local midnight |
| `principal_transaction_id` | TEXT FK transactions | NULL when no money moved |
| `closed_at` | INTEGER | cached status, see §7.4 |
| `close_reason` | TEXT | `repaid` / `forgiven`; NULL iff `closed_at` NULL |
| `created_at`, `updated_at`, `deleted_at`, `sync_status` | | |

**`debt_payments`**

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `debt_id` | TEXT NOT NULL FK debts | |
| `transaction_id` | TEXT FK transactions | the wallet transaction that moved the money; NULL = settled outside Wumbi's wallets |
| `kind` | TEXT NOT NULL | `repayment` / `forgiveness` (forgiveness never has a transaction) |
| `amount_minor` | INTEGER NOT NULL | `> 0`, in the **debt's** currency |
| `paid_at` | INTEGER NOT NULL | |
| `created_at`, `updated_at`, `deleted_at`, `sync_status` | | |

One repayment transaction can produce several `debt_payments` rows (FIFO over several debts of the same person, [A3]).

### 4.2 Changed table

`transactions` gets `debt_role TEXT NULL CHECK (debt_role IN ('principal','repayment'))` + partial index. `TransactionModel` gets `DebtRole? debtRole` (new enum `lib/src/core/utils/enums/debt_role.dart`, same shape as `TransactionStatus`) in `fromRow`/`toRow`.

### 4.3 Relationship

```
people 1 ──< debts 1 ──< debt_payments >── 0..1 transactions (debt_role = 'repayment')
                 └── 0..1 transactions (principal_transaction_id, debt_role = 'principal')

budgets 1 ──< budget_wallets >── wallets
        1 ──< budget_tags    >── tags
```

### 4.4 Repository invariants (new)

| Invariant | Owner |
|---|---|
| A budget whose wallet set **becomes empty because its wallets were deleted** is soft-deleted (it must never silently widen to "all wallets"). Same for tags. | `WalletRepository.softDelete`, tag delete/merge paths |
| Tag merge (`TagLocalDatasource.mergeInto`) also moves `budget_tags` (`UPDATE OR IGNORE`, then delete leftovers), like it does for rule tags. | `TagLocalDatasource` |
| Wallet soft delete deletes its `budget_wallets` links (then rule above). Debts are **not** touched by wallet deletion: an obligation does not disappear with a wallet; the debt history shows "wallet deleted". | `WalletRepository.softDelete` |
| `WalletDeleteOutcome` gains `removedBudgets` (count) → existing delete snackbar mentions it. | `WalletRepository` |
| `debts.closed_at/close_reason` recomputed after every write touching the debt or its payments (§7.4). | `DebtRepository` (txn-scoped helper) |
| A transaction with `debt_role` is created only through `TransactionRepository.create` with a `DebtIntent` (§7.3). | `TransactionRepository` |

---

## 5. Budgets — domain logic

### 5.1 Period math (`budget_period.dart`, pure)

```dart
/// Half-open local range [start, end).
class BudgetPeriod { final DateTime start; final DateTime end; final int index; }

BudgetPeriod periodAt(BudgetModel b, int index);          // index 0 = first period from anchor
BudgetPeriod? currentPeriod(BudgetModel b, DateTime now); // null when custom and now < anchor or now >= end
int periodIndexAt(BudgetModel b, DateTime now);
```

| Period | `start(k)` | `end(k)` |
|---|---|---|
| weekly | `DateTime(a.y, a.m, a.d + 7k)` (calendar days, DST-safe) | `start(k+1)` |
| monthly | `addMonthsClamped(anchor, k)` — anchored to `anchor_date`, never chained from the previous period, so day 31 → Feb 28 → Mar 31 | `addMonthsClamped(anchor, k+1)` |
| yearly | `addMonthsClamped(anchor, 12k)` | `addMonthsClamped(anchor, 12(k+1))` |
| custom | `anchor` (k = 0 only) | `end_date` |

Reuse `addMonthsClamped` from `core/recurring/recurring_schedule.dart` (do not duplicate it). Times are always 00:00 local.

Choosing `anchor_date` in the form:
- monthly with start day `d` (1–31): the latest date ≤ today whose day is `d` (clamped to the month's last day). Default `d = 1`.
- weekly with start weekday `w`: the latest date ≤ today with weekday `w`. Default = locale's first day of week (`MaterialLocalizations.firstDayOfWeekIndex`).
- yearly: latest occurrence of the chosen month/day ≤ today. Default Jan 1.
- custom: the chosen first day; `end_date` = chosen last day + 1 day.

### 5.2 Spent

Sum of `amount_minor` of transactions matching the scope in `[start, end)`, grouped by `currency`, then converted to the budget currency with cached rates ([A5]). Query B1 in Appendix A. Conditions: `deleted_at IS NULL`, `status = 'posted'`, `type = 'expense'`, `debt_role IS NULL`, wallet scope, tag scope (`EXISTS`, counted once).

### 5.3 Planned (only when `include_planned = 1` and the period is current)

1. **Upcoming rows**: same as spent but `status = 'upcoming'`, date in `[max(now, start), end)`.
2. **Subscriptions**: active, non-deleted `recurring_rules` with `type = 'expense'`, wallet in scope (`wallet_id`), tags in scope via `recurring_rule_tags` (ANY). For each rule, enumerate future occurrences starting at `rule.nextOccurrence` and advancing **exactly the way `RecurringEngine.catchUp` does** (read it first: rules can be re-anchored by `updateRule`, so do not assume `start_date + n` blindly; extract the engine's "next date after" step into a shared pure function if needed instead of re-implementing it). Count occurrences with `date ≥ max(now, start)` and `date < end` (and `≤ end_date` if set), cap 400 per rule. Each occurrence adds `amount_minor` in `rule.currency`.

Planned is 0 for past periods and for future custom budgets.

### 5.4 Rollover

For `rollover != none` and current index `k > 0`, compute spent for the previous `min(k, 12)` periods in **one** grouped query (bucket `CASE` exactly like `ProgressLocalDatasource.sumsByPeriod`). Then, oldest first, starting with `carry = 0`:

```
effective_i = limit + carry
leftover_i  = effective_i - spent_i
carry       = rollover == surplus ? max(0, leftover_i) : leftover_i     // 'both' may go negative
```

The current period's effective limit is `limit + carry`. Periods older than 12 back are ignored (carry starts at 0 there).

### 5.5 Metrics (`budget_metrics.dart`, pure)

Inputs: effective limit `L`, `spent S`, `planned P` (all budget currency minor ints), period, `now`.

| Metric | Formula | Shown |
|---|---|---|
| remaining | `L - S` (may be negative) | "€230 left" / "€12 over" |
| free | `max(0, L - S - P)` | free segment of the bar |
| daysLeft | whole local days from today (inclusive) to `end` (exclusive) | |
| perDay | `free / daysLeft` (integer division, round down) when current and `daysLeft ≥ 1` | "€14/day" |
| timeRatio | `elapsed / length` (ms) | pace |
| spentRatio | `S / L` (L ≤ 0 → treat as ∞) | bar |
| forecast | `S / elapsedDays × totalDays` when `elapsedDays ≥ 3` | details only |

**Status** (first match wins):

| Status | Condition | Colour |
|---|---|---|
| `notStarted` | custom, `now < start` | `secondContentColor` |
| `finished` | custom, `now ≥ end` | `secondContentColor` |
| `over` | `S > L` | `UIColorToken.neg500` |
| `atRisk` | `S + P > L` **or** (`spentRatio - timeRatio > 0.10` **and** `spentRatio ≥ 0.25`) | `UIColorToken.buttercup` |
| `ok` | otherwise | `UIColorToken.blue` |

Pace text (details page): "On track", "€25 ahead of pace" (`S < L × timeRatio`, difference shown), "€40 faster than planned".

### 5.6 Limit suggestion

When creating a budget, compute the average spent of the scope over the last **3 complete** periods of the chosen type (single grouped query, same bucket technique). Round **up** to a "nice" number: < 100 → nearest 5; < 1,000 → nearest 10; else nearest 50 (in major units). Show only when at least one of those periods has spending. Never auto-fill: show as a tappable suggestion chip.

### 5.7 Budget impact of a new expense

`BudgetRepository.impactOf(String transactionId, {DateTime? now})` → the `BudgetProgress` list of live, current budgets whose scope matches that transaction (wallet + tags). Used for the commit toast (§6.5).

---

## 6. Budgets — UI

Everything below is derived from the existing screens. Keep spacing, typography and paddings consistent with their neighbours (`kPageHorzPadding`, `kListHorzPadding`, `context.typo.inter.*`).

### 6.1 New component: `UiBudgetBar`

Segmented horizontal bar: `[spent | planned | free]`.

| Prop | Notes |
|---|---|
| `spentRatio`, `plannedRatio` | 0–1 of the effective limit (clamped; `spent > limit` → full bar in status colour) |
| `color` | status colour (§5.5) |
| `height` | 6 (rows), 10 (details header) |

Spent = solid `color`; planned = `color` at 35 % alpha; track = `secondContentColor` at 20 % (same as `UIProgressLine` track). Rounded ends, animated like `UIProgressLine` (450 ms, easeOutCubic). Do **not** modify `UIProgressLine` (it is the onboarding gradient bar).

### 6.2 New component: `UiBudgetRow`

Used on Dashboard, Budgets page and Wallet Details.

```
Groceries                                   €230 left      ← rowTitle  |  rowTitle, status colour when atRisk/over
[▓▓▓▓▓▓▓▓▒▒▒▒░░░░░░░░░░░░░░░░]                              ← UiBudgetBar h6
October · €14/day                                           ← caption (secondary)
```
- Right label: `remaining ≥ 0` → "€230 left"; `< 0` → "€12 over" (neg500); `notStarted` → "Starts Nov 1"; `finished` → "Ended".
- Caption: period label (`October`, `This week`, `2026`, `Oct 1 – 15`) + `· €X/day` when perDay is available + `· ≈` marker when `incomplete`.
- Whole row tappable (`UITap`) → Budget details.

### 6.3 Dashboard — "Budgets" section

Placed **under** the wallet list, same anatomy as the "Wallets" section header:

```
Wallets                                   ⊕ New wallet
  …wallet rows…
                                          (UISpace.vert 40)
Budgets                                   ⊕ New budget       ← headline + UiIconTextButton (same as Wallets)
  Groceries   ▓▓▓▓▓▓▒▒░░░░   €230 left
  #cafe       ▓▓▓▓▓▓▓▓▓▓▓▓   €12 over
  Card        ▓▓▓░░░░░░░░░   €1,120 left
  All budgets ›                                               ← only when > 3 live budgets
```
- Shows at most **3** current budgets, ordered by severity (`over` → `atRisk` → `ok`), then by `spentRatio` desc. `finished` custom budgets are not shown here.
- Empty state (no budgets): header row + one caption-style line under it, tappable → Budget form: *"Set a spending limit for a wallet or a #tag"*. No big `UiEmptyState` — the dashboard must stay calm.
- Hidden entirely while the dashboard has no wallets (its own empty state is shown).
- Do **not** add a "Budgets" pill to `_HeaderLinks` (pills already wrap to two lines).

### 6.4 Wallet Details — budget block

Inside the header column, **between the balance and the subscriptions caption** (`↻ N subscriptions ›`):

```
[UiWalletInfoMenu]
[UiTotalAmount balance]
                                   (UISpace.vert 16)
Groceries                                   €230 left     ← UiBudgetRow of the most severe budget scoped to this wallet
[▓▓▓▓▓▓▒▒░░░░░░░░]
Spent €170 of €400 · October · €14/day                    ← caption variant: explicit "Spent X of Y" so it is never confused with the balance
+2 more budgets ›                                         ← caption link → /budgets?walletId=<id>, only when > 1
↻ 2 subscriptions ›
[filter | sort]
```
- "Scoped to this wallet" = `budget_wallets` contains this wallet. Budgets with an empty wallet set (all wallets) are **not** shown here (they would appear on every wallet and add noise); they live on the Dashboard.
- No budget for this wallet → a caption link in the same style as the subscriptions link: `⊕ Set a spending limit ›` → Budget form prefilled with `walletIds = {this}` and `currency = wallet currency`.
- `UiBudgetRow` gets a `captionOverride`/variant flag for the "Spent X of Y" caption; do not fork the widget.

### 6.5 Transaction screen — commit toast

No new UI on the Transaction screen. In `TransactionNotifier`, after a successful **expense** commit (posted, not upcoming, not debt-linked):

1. `await budgetRepository.impactOf(saved.id)`.
2. If non-empty, pick the most severe (same ordering as §6.3) and append to the existing success message:
   - ok/atRisk: `"-€30.00 saved to Card · Groceries: €12 left"`
   - over: `"-€30.00 saved to Card · Groceries: €18 over"`
3. If **this** commit moved the budget from not-over to over, send `ShowInfoMessageEvent` instead of `ShowSuccessMessageEvent` and call `AppVibrations.error()`; otherwise keep the success event. Keep the existing CANCEL action (`_cancelAction`) in both cases.
4. `impactOf` failures must never block or fail the commit (log and fall back to the original message).

Compute "was not over before" as `S_after - amount ≤ L` using the returned progress.

### 6.6 Budget form — `/budget/form` (`BudgetFormPage`, modal like `WalletFormPage`)

Arguments: `budgetId?` (edit), `walletId?` (prefill scope), `tagId?` (prefill scope).

```
UIAppbar (back)
            €400                         ← big amount (Montserrat like wallet form), tap → AmountNumpadSheet
            EUR ›                        ← tap → CurrencyPickerSheet
Name        [Groceries            ]      ← UIInputField; placeholder = auto name
WHAT COUNTS                              ← UiSectionLabel
Wallets     All wallets ›                ← WalletMultiPickerSheet (new)
Tags        #food #market ›              ← TagMultiPickerSheet (new; extract the tag selector from TransactionFilterSheet into a reusable widget instead of copying it)
"Counts expenses from Card tagged #food or #market."   ← live sentence, caption; the single most important line for comprehension
PERIOD
Repeats     Monthly ›                    ← BudgetPeriodSheet: Weekly / Monthly / Yearly / One-time
Starts on   Day 25 ›                     ← day-of-month / weekday / date / date range depending on period
Carry over  Don't carry over ›           ← RolloverSheet; hidden for One-time
Count planned   [switch]                 ← "Include upcoming and subscriptions"
[ Suggested: €380 · avg. of last 3 months ]   ← chip, only when available (§5.6)

bottom bar:  Delete (edit only, secondary)            Save
```
- Auto name when the field is empty: tags → `#food, #market`; else wallets → `Card, Cash`; else `All spending`.
- Validation (repository, `ValidationException` → inline like wallet form): limit > 0; name ≤ 40; custom: end > start; at most 10 tags.
- Currency default: base currency; switches to the wallet's currency when exactly one wallet is selected and the user has not picked a currency manually.
- Delete: `UIAlertDialog.confirm` (destructive) → soft delete → pop → toast "Budget deleted" with Undo (`ShowUndoEvent`, restore).
- Save in create mode → pop and push nothing (the dashboard section updates via `dbRevisionProvider`).

### 6.7 Budget details — `/budgets/:id` (`BudgetDetailsPage`)

Modeled on `TagDetailsPage` (header + transaction list).

```
UIAppbar  (back)                         action: edit → BudgetFormPage(budgetId)
‹  October 2026  ›                       ← browse periods (index offset); › disabled on current
          €230 left                      ← UiTotalAmount (status colour when over)
[▓▓▓▓▓▓▓▓▒▒▒▒░░░░░░░░░░░░]               ← UiBudgetBar h10
Spent €170 · Planned €60 · Limit €400 (+€35 carried)
€14/day for 12 days · €25 ahead of pace · forecast €390
Card · #food #market                     ← scope summary (caption)
— list —
Upcoming group (dimmed, like Wallet Details)     ← planned rows (upcoming transactions only; subscriptions are summarised as "2 subscriptions · €45" caption row → SubscriptionsRoute)
Rows of the period (UiTransactionCard), newest first; tap → TransactionRoute(transactionId) edit mode
```
- Past periods: no planned, no per-day, no pace; show final result ("€35 under" / "€12 over").
- Empty list: `UiEmptyState` with the mascot, "No spending yet this period".
- Paging: reuse the 50-row paging approach of Wallet Details.

### 6.8 Budgets page — `/budgets` (`BudgetsPage`)

Reached from "All budgets ›" and "+N more budgets ›" (optional `walletId` filter, like `SubscriptionsPage`).

```
UIAppbar "BUDGETS"
Header row:  "Budgets"                      ⊕ New budget
Active:      UiBudgetRow × N (severity order)
Upcoming:    custom budgets not started yet
Finished:    custom budgets that ended (collapsed by default)
Empty:       UiEmptyState(mascot, "No budgets yet", "Set a limit and watch what's left") + New budget button
```

---

## 7. Debts — domain logic

### 7.1 Remaining & person balance

```
paid(debt)      = Σ debt_payments.amount_minor  WHERE debt_id = debt.id AND deleted_at IS NULL     (both kinds)
remaining(debt) = principal_minor − paid(debt)                                                       (debt currency)
open(debt)      ⇔ remaining > 0  ⇔ closed_at IS NULL
overdue(debt)   ⇔ open AND due_date IS NOT NULL AND due_date < start of today
```

Payments count even if their transaction was later deleted **by wallet deletion** (the person really paid). Payments are only removed by explicit user deletion (§7.5).

`PersonBalance(personId)` = for open debts: `owedToMe` (Σ remaining of `lent`) and `iOwe` (Σ remaining of `borrowed`), each kept **per currency** (`Map<CurrencyType, int>`) plus a base-currency total via cached rates for display.

### 7.2 Resolving GAVE / GOT (`debt_resolution.dart`, pure)

Input: `PersonBalance`, flow (`outgoing` = GAVE = money left my wallet, `incoming` = GOT = money came in). Output (`DebtResolution`):

| Flow | Person has open… | Result |
|---|---|---|
| GAVE (out) | `borrowed` debts (I owe them) | **repayment** of my debts to them (FIFO) |
| GAVE (out) | none of those | **new `lent` debt** (they owe me) |
| GOT (in) | `lent` debts (they owe me) | **repayment** of their debts (FIFO) |
| GOT (in) | none of those | **new `borrowed` debt** (I owe them) |

The **same function** produces the hint text inputs (UI, before commit) and drives the write (repository, inside the transaction, re-evaluated against fresh data). Never duplicate this logic.

### 7.3 Writes through `TransactionRepository.create`

`TransactionDraft.income` / `.expense` get an optional `DebtIntent? debt`:

```dart
sealed class DebtIntent {
  /// Transaction screen: person + flow, resolved by §7.2 inside the write.
  const factory DebtIntent.auto({required PersonRef person, String? description, DateTime? dueDate}) = _Auto;
  /// Debt sheet: pay back exactly this debt (no FIFO).
  const factory DebtIntent.repay({required String debtId}) = _Repay;
  /// New-debt sheet with "money moved from wallet": open a debt with this direction.
  const factory DebtIntent.open({required PersonRef person, required DebtDirection direction, String? description, DateTime? dueDate}) = _Open;
}
/// Existing person id, or a new name to find-or-create (like tags).
sealed class PersonRef { existing(String id) | create(String name) }
```

Inside the single `db.transaction` of `create` (after `datasource.insert` and tags):

1. Resolve `PersonRef` (find-or-create by `normalized_name`, update `last_used_at`).
2. Determine the outcome: `auto` → §7.2 with the flow implied by the draft type (expense = outgoing, income = incoming); `repay` → that debt (validate: open, direction matches the flow: `lent` needs income, `borrowed` needs expense); `open` → validate direction matches the flow.
3. **New debt** → insert `debts` row: `direction`, `currency`/`principal_minor` per [A7] (original typed amount if present, else wallet amount), `opened_at = transaction_date`, `principal_transaction_id = tx.id`; set `tx.debt_role = 'principal'`.
4. **Repayment** → allocation (below); set `tx.debt_role = 'repayment'`; recompute status of every touched debt.
5. Constraints: draft must have `repeat == never` and a non-future date ([A4]) → otherwise `ValidationException('person')`.

**Allocation** (amount `A` in wallet currency `W`, open target debts ordered by `opened_at, created_at`):

```
left = A
for debt in targets:
    remD = remaining(debt)                                  // debt currency D
    if D == W:            takeW = min(left, remD); takeD = takeW
    else:
        rateDW = fx.rate(D, W); rateWD = fx.rate(W, D)       // network allowed (write path)
        remW   = convertMinor(remD, D, W, rateDW)
        takeW  = min(left, remW)
        takeD  = takeW == remW ? remD : convertMinor(takeW, W, D, rateWD)
        // if the typed original currency == D and there is a single target, use the typed original amount (exact)
    insert debt_payments(debt, kind: repayment, amount: takeD, transaction_id: tx.id, paid_at: tx.date)
    left -= takeW
    if left == 0: break
if left > 0: throw DebtOverpaymentException(personName, direction, maxRemaining)      // [A1], nothing is written
```

A rounding residue of ≤ 1 minor unit in the debt currency closes the debt (treat `remaining ≤ 1` after a cross-currency payment as 0 by adding the residue to the last payment).

### 7.4 Status recompute

`DebtRepository.recomputeStatus(DatabaseExecutor txn, String debtId, int now)`:
- `remaining ≤ 0` → `closed_at = max(paid_at of live payments)`, `close_reason = 'forgiven'` if any live payment is a forgiveness else `'repaid'`.
- `remaining > 0` → `closed_at = NULL`, `close_reason = NULL`.
Call it after every insert / soft delete / restore of a payment or a debt.

### 7.5 Deletion & undo (cascades share one `now`)

| Action | Effect (one transaction, same `deleted_at`) | Undo |
|---|---|---|
| Swipe-delete a `principal` transaction | soft-delete the tx, its debt, the debt's payments **and their repayment transactions**. If one of those repayment transactions also paid other debts (FIFO), its payments to those debts are soft-deleted too and those debts are recomputed: a transaction is never left partially allocated | restore every row (tx, debts, payments) carrying that exact `deleted_at`; recompute all touched debts |
| Swipe-delete a `repayment` transaction | soft-delete the tx and its payments; recompute touched debts (they may reopen) | restore tx + payments with that `deleted_at`; recompute |
| Delete debt (Debt sheet) — confirm dialog: "Delete this debt? N wallet transactions will be deleted too." | same as principal cascade | toast Undo → same restore |
| Delete a payment row in the Debt sheet history | payment + its transaction if no other live payment references it; recompute | Undo |
| Wallet soft delete | debts/payments untouched (§4.4); their transactions disappear with the wallet as today | — |

Implementation: `TransactionRepository.softDelete`/`restore` call txn-scoped `DebtRepository.onTransactionDeleted(txn, tx, now)` / `onTransactionRestored(txn, tx, deletedAt)` (read `deleted_at` **before** restoring). `DebtRepository` itself may use `TransactionLocalDatasource` (datasource-level `softDelete`/`restore`, plus new `softDeleteMany`/`restoreWhereDeletedAt`) for the debt-delete cascade. **No dependency from `DebtRepository` to `TransactionRepository`** (avoid cycles: `TransactionRepository → DebtRepository → datasources`).

### 7.6 Errors

Repositories have no access to l10n, so every user-facing refusal is a **typed domain exception** mapped to a **typed `Failure`** whose `toMessage(AppLocale)` builds the localized text. Add them to `domain_exceptions.dart`, `failures.dart` and `Failure.exceptionsCatcher` (same pattern as `WalletHasTransactionsException` → `WalletHasTransactionsFailure`):

| Exception → Failure | When | Message (en) |
|---|---|---|
| `DebtOverpaymentException(personName, direction, maxRemaining: Money)` → `DebtOverpaymentFailure` | allocation leaves `left > 0` | "Ahmed owes you only €150" / "You owe Sara only €20" |
| `PersonHasDebtsException` → `PersonHasDebtsFailure` | delete person with live debts | "Settle or delete this person's debts first" |
| `DebtClosedException` → `DebtClosedFailure` | repay/forgive a closed debt (stale UI) | "This debt is already settled" |

`TransactionNotifier` shows `DebtOverpaymentFailure` in the inline `validationError` slot (with the amount shake), not as an error toast. Everything else goes through `ShowErrorEvent`.

### 7.7 Commit summary for toasts

`TransactionRepository.create` keeps returning `TransactionModel`. After a debt-linked commit, the notifier calls `DebtRepository.commitSummary(transactionId)` → `DebtCommitSummary { DebtCommitKind kind (openedLent | openedBorrowed | repaidIn | repaidOut), String personName, Money amount, Money? leftAfter /* null = all settled */ }` and builds the §8.1 toast. A failure here must not affect the already successful commit (fall back to the plain saved message).

### 7.8 Writes through `DebtRepository`

| Method | Purpose |
|---|---|
| `createWithoutMoney(DebtDraft)` | new debt with no wallet movement |
| `addPayment(debtId, {required int amountMinor, required PaymentKind kind})` | repayment settled outside wallets, or forgiveness (forgiveness amount = full remaining) |
| `update(debtId, {description, dueDate})` | edits; principal/currency/direction are immutable ([A8]) |
| `delete(debtId)` / `restore(debtId, deletedAt)` | §7.5 |
| `renamePerson(personId, name)` | merge into an existing live person with the same normalized name (like tag rename/merge) |
| `deletePerson(personId)` | only when the person has no live debts; else `ValidationException` |

Reads: `overview({DateTime? now})` → `DebtsOverview` (open lent/borrowed lists, settled lists, base totals, overdue count), `byId(debtId)` → `DebtDetails` (debt, person, payments with wallet names, person balance), `searchPeople(query)` → people with their `PersonBalance` (ordered: has open debts first, then `last_used_at` desc), `personBalance(personId)`.

---

## 8. Debts — UI

### 8.1 Transaction screen (create mode only)

**Chips row** (existing horizontal scroll): `[Date] [Repeat] [👤 Person]`
- New `UiChip(icon: UIIconToken.icons.users.user01, label: person?.name ?? l10n.debt_person_chip, highlighted: person != null, onTap: pickPerson)`.
- Hidden in edit mode and subscription edit mode.
- `readOnly` while Repeat ≠ never or the date is in the future; while a person is set, Repeat is `readOnly` and `DatePickerSheet.show` gets `maxDate: today` ([A4]).

**PersonPickerSheet** (new, `UIModalSheet`): search field on top; rows = people (`UiCircleColorBadge`-style initial avatar, name, trailing balance caption "owes you €150" / "you owe €20" / nothing); first row "⊕ Add “<query>”" when the query matches no live person; last row "No person" (clears) when a person is selected. Swipe-to-delete only for people without live debts.

**Bottom bar with a person selected**: TRANSFER is removed and the two remaining `UiTypeActionButton`s become:

| Button | Style | Label | Draft |
|---|---|---|---|
| left | `expense` | **GAVE** | `TransactionDraft.expense(..., debt: DebtIntent.auto(person))` |
| right | `income` (keeps `heroTag: kHeroFab`) | **GOT** | `TransactionDraft.income(..., debt: DebtIntent.auto(person))` |

**Debt hint** (new `_DebtHint`, same slot, size and animation as `_UpcomingHint`, under the chips row): computed from `personBalanceProvider(personId)` + §7.2:

| Person balance | Hint |
|---|---|
| they owe me X | "Ahmed owes you €150 · GOT counts as a return" |
| I owe them Y | "You owe Ahmed €20 · GAVE counts as paying back" |
| both (rare) | "Ahmed owes you €150 · you owe €20" |
| nothing open | "No open debts with Ahmed · GAVE lends, GOT borrows" |

**Validation**: over-repayment → existing inline `validationError` (2 s) + amount shake, e.g. "Ahmed owes you only €150".

**Toasts after commit** (existing success event + CANCEL action):

| Outcome | Message |
|---|---|
| new lent | "Lent €50 to Ahmed" |
| new borrowed | "Borrowed €50 from Ahmed" |
| repayment in | "Ahmed returned €50 · €100 left" / "Ahmed returned €50 · all settled" |
| repayment out | "Paid back €20 to Sara · €180 left" / "… · all settled" |

**Reset after commit** ([A1] of spec V1): the person is cleared together with description and tags.

### 8.2 Dashboard pill

In `_HeaderLinks`, after the subscriptions pill: `_HeaderPill(icon: users.users01, label: l10n.debts_count(n))` shown only when open debts `n > 0`; a 6 px `neg500` dot at the end of the pill when `overdueCount > 0`. Tap → `DebtsRoute()`.

### 8.3 Debts page — `/debts` (`DebtsPage`)

```
UIAppbar "DEBTS"                                    action: ⊕ → NewDebtSheet
[ Owed to me | I owe ]                              ← TagsViewToggle (reuse; move to design system as UiSegmentedToggle if you need it outside tags — do not copy it)
             €230                                   ← UiTotalAmount: Σ remaining of the tab, base currency (≈ when incomplete)
      3 people · 1 overdue                          ← caption
— open debts —                                      ← sorted: overdue first, then due soonest, then newest
UiDebtRow ×N
Settled (5) ›                                       ← collapsed section; expands closed debts (most recent first)
Empty tab: UiEmptyState(mascot, "Nobody owes you", "Pick a person on the transaction screen when you lend money")
```
Initial tab: "Owed to me", unless it is empty and "I owe" is not.

**`UiDebtRow`** (new component):
```
Ahmed                                   €100 left        ← rowTitle | rowTitle
Dinner · due Oct 20                                      ← caption; "overdue" in neg500 when overdue
[▓▓▓▓▓▓▓▓░░░░░░░░]                                       ← UiBudgetBar(spentRatio = paid/principal, color: blue), h4
```
Tap → `DebtSheet`.

### 8.4 Debt sheet (`DebtSheet`, `UIModalSheet`, fit content)

```
Ahmed                                        ⋯           ← overflow: Edit description · Rename person · Delete debt
Dinner · Oct 3 · [due Oct 20 ▾]                          ← due chip (UiChip) → DatePickerSheet (clearable)
€100 left of €150                                         ← Montserrat amount + caption
[▓▓▓▓▓▓▓▓░░░░░░░░]
Overall Ahmed owes you €130                               ← only when the person has other open debts / opposite ones
[        Returned in full        ]                        ← primary (UiPrimaryButton); "Paid in full" for borrowed
         to Card ›                                        ← wallet for the movement; default = principal tx wallet if alive, else primary; includes "Not in a wallet"
   Part   ·   Forgive   ·   Remind ↗                      ← UiTextButtons; Remind only for lent debts
HISTORY
Oct 10   Returned €50 → Card                  (swipe to delete, undo)
Oct 3    Lent €150 from Card
```
- **Returned in full** → `TransactionRepository.create(income|expense draft, wallet = selected, debt: DebtIntent.repay(debtId))`. Same currency: amount = remaining. Different currency: amount = remaining converted debt → wallet currency (FX), **and** the draft's `original` = remaining in the debt currency, so allocation takes the exact path (§7.3) and the debt closes with no residue. "Not in a wallet" → `DebtRepository.addPayment(kind: repayment)`. Then close the sheet, toast per §8.1.
- **Part** → `AmountNumpadSheet` (in the debt currency) → same paths with that amount; amount > remaining → validation message.
- **Forgive** → `UIAlertDialog.confirm` → `addPayment(kind: forgiveness, amount = remaining)` (no money moves).
- **Remind** → `share_plus` (use the API of the installed version, e.g. `SharePlus.instance.share(ShareParams(text: …))`; not the deprecated `Share.share`) with a localized message: *"Hi Ahmed! Just a reminder about €100 for Dinner (Oct 3). Thanks!"* (omit the description part when empty).
- Closed debts open the same sheet read-only (no action buttons; overflow keeps Delete).

### 8.5 New debt sheet (`NewDebtSheet`)

For debts created outside the Transaction screen (e.g. "Sara paid my dinner").
```
[ They owe me | I owe them ]          ← segmented toggle
Person      Choose ›                  ← PersonPickerSheet
Amount      €0.00 ›                   ← AmountNumpadSheet + currency picker (default base currency)
Note        [            ]
Due date    None ›
Money moved Not in a wallet ›         ← WalletPickerSheet + "Not in a wallet" (default)
[ Save ]
```
Wallet chosen → `TransactionRepository.create(draft with DebtIntent.open(...))` (they owe me → expense from that wallet, I owe them → income into it). No wallet → `DebtRepository.createWithoutMoney`.

### 8.6 Debt-linked rows in transaction lists

Applies to Wallet Details, Tag details and Search (extend `TransactionRow` with `DebtRole? debtRole`, `String? debtId`, `String? personName`; resolve in one extra query per page, mirroring `_withTags`):
- `badge`: "Loan" (principal) / "Return" (repayment).
- Title fallback when the description is empty: "Lent to Ahmed" / "Borrowed from Ahmed" / "Ahmed paid back" / "Paid back Ahmed".
- Tap → `DebtSheet(debtId)` instead of the edit screen. Centralise this in **one** helper (`openTransactionRow(context, row)`) used by all three lists. Do not duplicate the branching.
- Swipe-delete → `TransactionRepository.softDelete` (cascade §7.5); the undo toast text mentions the cascade ("Loan deleted with 2 returns").

Add dependency `share_plus` (latest stable compatible with the project's Flutter SDK).

---

## 9. Changes to existing features

| Area | Change |
|---|---|
| `SQLiteConfig` | `dbVersion = 4`; constants for all new tables/columns |
| `SQLiteSchema` / `SQLiteMigrations` | `SQLiteSchemaV4`, `latest = v4`, `_v3ToV4` |
| `TransactionModel` | `debtRole` field |
| `TransactionDraft` | optional `DebtIntent? debt` on income/expense |
| `TransactionRepository` | `create` handles `DebtIntent`; `softDelete`/`restore` call debt hooks; constructor gets `DebtRepository` (txn-scoped helpers) |
| `TransactionRow` + list queries | debt fields (§8.6) |
| `ProgressLocalDatasource` | `AND t.debt_role IS NULL` in both queries |
| `TagLocalDatasource` | `AND t.debt_role IS NULL` in sums; `mergeInto` moves `budget_tags`; tag soft delete removes `budget_tags` and soft-deletes budgets left with no tags |
| `WalletRepository.softDelete` | `budget_wallets` cleanup + empty-scope budget deletion; `WalletDeleteOutcome.removedBudgets` |
| `TransactionNotifier` / `TransactionState` | `person` (selected `PersonSummary?`), chip rules, GAVE/GOT, debt hint, budget toast |
| `DashboardPage` | Budgets section, debts pill |
| `WalletDetailsPage` | budget block, debt-row routing |
| `TagDetailsPage`, `SearchPage` | debt-row routing |
| `AppRouter` / `RoutePaths` | new routes (§10.1) |
| Reset All Data | nothing to do (the DB file is deleted) — verify |

---

## 10. Routes, providers, components, l10n

### 10.1 Routes (`RoutePaths` + `AppRouter`, plain `AutoRoute` like the others)

| Path | Page | Args |
|---|---|---|
| `/budgets` | `BudgetsPage` | `walletId?` |
| `/budgets/:id` | `BudgetDetailsPage` | `budgetId` |
| `/budget/form` | `BudgetFormPage` | `budgetId?`, `walletId?`, `tagId?` |
| `/debts` | `DebtsPage` | — |

Sheets (not routes): `PersonPickerSheet`, `DebtSheet`, `NewDebtSheet`, `WalletMultiPickerSheet`, `TagMultiPickerSheet`, `BudgetPeriodSheet`, `RolloverSheet`.

### 10.2 Providers

| Provider | Type | Notes |
|---|---|---|
| `budgetRepositoryProvider`, `debtRepositoryProvider` | `Provider` | same construction style as `tagRepositoryProvider` (`sqlite`, `fx`, `onWrite`) |
| `budgetsProvider` | `AsyncNotifierProvider.autoDispose<…, List<BudgetProgress>>` | watches `dbRevisionProvider`, `baseCurrencyProvider` |
| `dashboardBudgetsProvider` | `Provider.autoDispose` | top 3 + total count, derived from `budgetsProvider` |
| `walletBudgetsProvider(walletId)` | `Provider.autoDispose.family` | budgets explicitly scoped to the wallet, severity order |
| `budgetDetailsProvider(BudgetDetailsArgs)` | `NotifierProvider.autoDispose.family` | args = id + period offset; paging |
| `budgetFormProvider(BudgetFormArgs)` | `NotifierProvider.autoDispose.family` | |
| `debtsOverviewProvider` | `AsyncNotifierProvider.autoDispose` | watches `dbRevisionProvider` |
| `openDebtsBadgeProvider` | `Provider.autoDispose` | `(count, overdueCount)` for the pill |
| `personBalanceProvider(personId)` | `FutureProvider.autoDispose.family` | Transaction hint |
| `debtDetailsProvider(debtId)` | `FutureProvider.autoDispose.family` | Debt sheet |

Day rollover: when the app resumes on a different local day than the last computation, invalidate `budgetsProvider` and `debtsOverviewProvider` (hook into the existing `didChangeAppLifecycleState` in `app.dart`; do not add a second observer).

### 10.3 Components

Reuse: `UIAppbar`, `UiTotalAmount`, `UiIconTextButton`, `UiTransactionCard` (`badge`, `upcoming`), `UiChip`, `UiTypeActionButton`, `UiPrimaryButton`, `UiTextButton`, `UIInputField`, `UiSectionLabel`, `UiSettingsTile`, `UISwitch`, `UiEmptyState`, `UiSkeletonList`, `UIModalSheet`, `UIAlertDialog`, `AmountNumpadSheet`, `CurrencyPickerSheet`, `WalletPickerSheet`, `DatePickerSheet`, `TagsViewToggle`, `UiCircleColorBadge`, `UIWumbiLook*`.

New (design system): `UiBudgetBar`, `UiBudgetRow`, `UiDebtRow`. Feature-level: the sheets in §10.1.

### 10.4 l10n keys

Prefixes: `budget_*`, `budgets_*`, `debt_*`, `debts_*`, `person_*`. All 7 locales. Plurals at least for: `debts_count`, `budgets_more_count`, `debts_people_count`, `budget_days_left`, `debt_cascade_deleted` (returns count). Amounts and names are always placeholders (never concatenated in Dart), e.g.:

```json
"budget_left": "{amount} left",
"budget_over": "{amount} over",
"budget_spent_of": "Spent {spent} of {limit}",
"budget_per_day": "{amount}/day",
"budget_toast_suffix": "{name}: {amount} left",
"debt_hint_owes_you": "{name} owes you {amount} · GOT counts as a return",
"debt_toast_returned": "{name} returned {amount} · {left} left",
"debt_remind_message": "Hi {name}! Just a reminder about {amount} for {note} ({date}). Thanks!"
```

---

## 11. Implementation plan & acceptance criteria

Vertical slices; the app builds and runs after each.

| M | Scope | Done when |
|---|---|---|
| **M1 Data foundation** | Migration v4 + schema; `SQLiteConfig`; enums (`DebtRole`, `DebtDirection`, `BudgetPeriodType`, `RolloverMode`, `PaymentKind`); freezed models; datasources; pure files (`budget_period`, `budget_metrics`, `debt_resolution`); `BudgetRepository`, `DebtRepository`; `TransactionRepository` debt intent + cascades; analytics exclusions (§3.1); wallet/tag invariants (§4.4) | All §12 unit + repository + migration tests pass; existing tests still pass |
| **M2 Budgets UI** | `UiBudgetBar`, `UiBudgetRow`; Dashboard section; Wallet Details block; Budget form (+ multi pickers, period, rollover, suggestion); details page; budgets page; commit toast | Create "#food €400 monthly from day 25" → dashboard shows it; an expense tagged #food updates bar, per-day and toast; over-limit toast + haptic; dark mode correct |
| **M3 Debts UI** | Person chip + picker; GAVE/GOT; hint; toasts; Debts page; `UiDebtRow`; Debt sheet (full/part/forgive/remind/history/delete); New debt sheet; dashboard pill; debt rows in lists + central routing | Lend €150 to Ahmed in 3 taps + amount; he returns €50 via GOT (hint states it is a return); close the rest with "Returned in full" in 2 taps; Progress/tag totals unchanged by all of it; wallet balances changed correctly |
| **M4 Polish** | 7 ARB translations; gallery entries; empty states; edge cases §13; changelog entries | `flutter analyze` clean; manual checklist §12.4 done |

---

## 12. Testing

Follow `test/features/repositories_test.dart` (ffi in-memory DB through `SQLiteServicesImpl`) and `test/core/*` for pure tests. Inject `now` everywhere.

### 12.1 Unit (pure)
- `budget_period`: monthly start day 31 across Feb/Mar (no drift); start day 25 when today is the 10th (anchor = previous month's 25th); weekly with Monday/Sunday start; DST week; yearly Feb 29; custom before/within/after.
- `budget_metrics`: perDay rounding; daysLeft on the last day = 1; statuses incl. the pace rule boundaries (0.10, 0.25); `L ≤ 0` with rollover `both`; forecast only from day 3.
- Rollover chains: surplus vs both; 12-period cap.
- Limit suggestion rounding (4 → 5, 382 → 390, 1,230 → 1,250).
- `debt_resolution`: all four table rows of §7.2 + "both directions open".

### 12.2 Repository (real SQLite)
- Migration v3 → v4 on a real v3 file (copy the v2 migration test approach): data preserved, new tables/column exist, `wallet_balances` unchanged.
- Budget spent: transfers excluded; upcoming excluded from spent but included in planned; debt-linked excluded; tag ANY counted once (tx with two matching tags); wallet scope; soft-deleted rows excluded; multi-currency with/without cached rate (`incomplete`).
- Planned subscriptions: monthly rule with next occurrence inside/outside the period; daily rule count; paused rule ignored.
- Wallet soft delete removes the budget link and deletes a budget left with no wallets, but keeps one that still has another wallet.
- Tag merge moves `budget_tags`; tag delete removes link / deletes emptied budget.
- Debts: GAVE creates lent debt + principal tx (balance down); GOT partial repayment (FIFO across 2 debts); over-repayment → `ValidationFailure`, nothing written; cross-currency allocation closes the debt with residue ≤ 1; forgiveness closes with reason `forgiven`; principal swipe-delete cascade + restore round-trip (all rows back, statuses correct); repayment delete reopens debt; wallet delete keeps debt and payments.
- Progress and tag sums ignore debt-linked rows.

### 12.3 Notifier
- `TransactionNotifier`: person chip toggling disables Repeat / future dates; GAVE/GOT drafts carry the intent; person reset after commit; budget toast composition (ok / crossed-over).
- `BudgetFormNotifier`: auto name; currency auto-switch only until manual pick; validation.

### 12.4 Manual checklist
Light + dark on a 375×812 device: dashboard with 0 / 1 / 4 budgets; long budget names; BTC budget; offline (no cached rate) budget shows `≈`; RTL sanity in Arabic for the new rows (no clipped amounts); Debt sheet with keyboard (amount sheet) on small screens.

---

## 13. Edge cases

| Situation | Handling |
|---|---|
| Budget currency ≠ some expense currency, no cached rate | skip those rows, `incomplete = true`, caption shows `≈`; never block rendering |
| Budget scoped to a wallet that is later deleted | link removed; budget deleted if it had no other wallet (§4.4); snackbar mentions it |
| Effective limit ≤ 0 (rollover `both`) | bar full in `neg500`, right label "€X over", perDay hidden |
| Custom budget in the future | status `notStarted`, label "Starts Nov 1", planned 0; listed under "Upcoming" on Budgets page, not on Dashboard |
| Expense edited (amount/tags/wallet) or deleted | budgets update automatically via `dbRevisionProvider`; nothing stored to fix |
| Monthly start day 31 | clamped per month, anchored (no drift) |
| Person renamed to an existing person's name | merge (debts move to the surviving person) |
| GAVE to a person I owe, amount > what I owe | validation "You owe Sara only €20" ([A1]) |
| Repayment in a wallet whose currency differs from the debt | FX at write time; rate stored implicitly via `amount_minor` of the payment; offline without cache → `FxUnavailableFailure` toast, nothing written |
| Debt-linked transaction opened from search | Debt sheet (central routing) |
| Debt whose principal wallet was deleted | history row shows "(wallet deleted)"; "Returned in full" defaults to the primary wallet |
| Deleting a person with open debts | refused with message |

---

## 14. Out of scope

Liability wallets (credit cards, loans, mortgages) · budget/debt notifications · recurring debts · shared debts between Wumbi users / bill splitting · refunds reducing budget spent · budget reorder (drag) · historical FX rates · freemium limits on budgets (keep creation behind the repository so a limit can be added later without UI rewrites).

---

## Appendix A — SQL

### A.1 Migration v3 → v4

```sql
-- budgets -------------------------------------------------------------------
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
);
CREATE INDEX idx_budgets_deleted ON budgets(deleted_at);

CREATE TABLE budget_wallets (
  budget_id  TEXT    NOT NULL REFERENCES budgets(id) ON DELETE CASCADE,
  wallet_id  TEXT    NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
  created_at INTEGER NOT NULL,
  PRIMARY KEY (budget_id, wallet_id)
);
CREATE INDEX idx_bw_wallet ON budget_wallets(wallet_id);

CREATE TABLE budget_tags (
  budget_id  TEXT    NOT NULL REFERENCES budgets(id) ON DELETE CASCADE,
  tag_id     TEXT    NOT NULL REFERENCES tags(id)    ON DELETE CASCADE,
  created_at INTEGER NOT NULL,
  PRIMARY KEY (budget_id, tag_id)
);
CREATE INDEX idx_bt_tag ON budget_tags(tag_id);

-- people / debts --------------------------------------------------------------
CREATE TABLE people (
  id              TEXT PRIMARY KEY,
  name            TEXT    NOT NULL,
  normalized_name TEXT    NOT NULL,
  last_used_at    INTEGER,
  created_at      INTEGER NOT NULL,
  updated_at      INTEGER NOT NULL,
  deleted_at      INTEGER,
  sync_status     TEXT    NOT NULL DEFAULT 'pending'
);
CREATE UNIQUE INDEX idx_people_normalized_active ON people(normalized_name) WHERE deleted_at IS NULL;

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
);
CREATE INDEX idx_debts_person ON debts(person_id);
CREATE INDEX idx_debts_open   ON debts(closed_at, due_date);
CREATE UNIQUE INDEX idx_debts_principal_tx ON debts(principal_transaction_id) WHERE principal_transaction_id IS NOT NULL;

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
);
CREATE INDEX idx_dp_debt ON debt_payments(debt_id);
CREATE INDEX idx_dp_tx   ON debt_payments(transaction_id);

-- transactions ----------------------------------------------------------------
ALTER TABLE transactions ADD COLUMN debt_role TEXT CHECK (debt_role IN ('principal','repayment'));
CREATE INDEX idx_tx_debt_role ON transactions(debt_role) WHERE debt_role IS NOT NULL;
```

`SQLiteSchemaV4.statements` must produce the **same final shape** for fresh installs: v3 statements with the `transactions` DDL including `debt_role` inline (define a v4 `transactions` statement rather than running `ALTER` in `onCreate`, the same way v2 inlined `status`), plus the statements above. Add a test asserting fresh-v4 and migrated-v3→v4 databases are equivalent: same table and index names in `sqlite_master`, and the same `PRAGMA table_info(<table>)` (name, type, notnull, default, pk) for every table. Do not compare raw `sql` text: `ALTER TABLE` rewrites it differently from a fresh `CREATE`.

### A.2 Key queries (use `SQLiteConfig` constants in the real code)

**B1 — budget spent / upcoming by currency** (`?1` budget id, `?2` start, `?3` end, `?4` status)
```sql
SELECT t.currency AS currency, SUM(t.amount_minor) AS total
FROM transactions t
WHERE t.deleted_at IS NULL
  AND t.status = ?4
  AND t.type = 'expense'
  AND t.debt_role IS NULL
  AND t.transaction_date >= ?2 AND t.transaction_date < ?3
  AND (NOT EXISTS (SELECT 1 FROM budget_wallets bw WHERE bw.budget_id = ?1)
       OR t.wallet_id IN (SELECT bw.wallet_id FROM budget_wallets bw WHERE bw.budget_id = ?1))
  AND (NOT EXISTS (SELECT 1 FROM budget_tags bt WHERE bt.budget_id = ?1)
       OR EXISTS (SELECT 1 FROM transaction_tags tt
                  JOIN budget_tags bt ON bt.tag_id = tt.tag_id AND bt.budget_id = ?1
                  WHERE tt.transaction_id = t.id))
GROUP BY t.currency;
```

**B2 — rollover / suggestion buckets**: B1 with the `CASE … END AS bucket` expression from `ProgressLocalDatasource.sumsByPeriod`, `status = 'posted'`, grouped by `bucket, currency`.

**B3 — planned subscriptions in scope** (`?1` budget id)
```sql
SELECT r.*
FROM recurring_rules r
WHERE r.deleted_at IS NULL AND r.is_active = 1 AND r.type = 'expense'
  AND (NOT EXISTS (SELECT 1 FROM budget_wallets bw WHERE bw.budget_id = ?1)
       OR r.wallet_id IN (SELECT bw.wallet_id FROM budget_wallets bw WHERE bw.budget_id = ?1))
  AND (NOT EXISTS (SELECT 1 FROM budget_tags bt WHERE bt.budget_id = ?1)
       OR EXISTS (SELECT 1 FROM recurring_rule_tags rt
                  JOIN budget_tags bt ON bt.tag_id = rt.tag_id AND bt.budget_id = ?1
                  WHERE rt.recurring_rule_id = r.id));
```
Occurrences are enumerated in Dart (§5.3).

**B4 — budgets matching a transaction** (`?1` transaction id): live budgets where the wallet scope is empty or contains `t.wallet_id`, and the tag scope is empty or intersects the transaction's tags. Then compute progress only for those.

**D1 — debt remaining**
```sql
SELECT d.*, d.principal_minor - COALESCE(
         (SELECT SUM(p.amount_minor) FROM debt_payments p
          WHERE p.debt_id = d.id AND p.deleted_at IS NULL), 0) AS remaining_minor
FROM debts d
WHERE d.deleted_at IS NULL;
```

**D2 — debt info for a page of transaction rows** (`IN (…)` placeholders like `tagsOfTransactions`)
```sql
SELECT t.id AS tx_id, t.debt_role,
       COALESCE(d1.id, d2.id) AS debt_id,
       pe.name AS person_name
FROM transactions t
LEFT JOIN debts d1 ON d1.principal_transaction_id = t.id
LEFT JOIN debt_payments p ON p.transaction_id = t.id AND p.deleted_at IS NULL
LEFT JOIN debts d2 ON d2.id = p.debt_id
LEFT JOIN people pe ON pe.id = COALESCE(d1.person_id, d2.person_id)
WHERE t.id IN (…) AND t.debt_role IS NOT NULL
GROUP BY t.id;
```

---

## Appendix B — Dart sketches

Sketches, not final code. Follow existing freezed / naming conventions (`fromRow`, `toRow`, `Draft`, `Summary`).

```dart
// features/budget/data/models/budget_model.dart
@freezed
abstract class BudgetModel with _$BudgetModel {
  const factory BudgetModel({
    required String id,
    required String name,
    required int limitMinor,
    required CurrencyType currency,
    required BudgetPeriodType period,      // weekly | monthly | yearly | custom
    required DateTime anchorDate,          // local midnight
    DateTime? endDate,                     // custom only, exclusive
    required RolloverMode rollover,        // none | surplus | both
    required bool includePlanned,
    required int sortOrder,
    @Default(<String>{}) Set<String> walletIds,
    @Default(<String>{}) Set<String> tagIds,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _BudgetModel;
}

enum BudgetStatus { ok, atRisk, over, notStarted, finished }

@freezed
abstract class BudgetProgress with _$BudgetProgress {
  const factory BudgetProgress({
    required BudgetModel budget,
    required BudgetPeriod period,
    required Money limit,        // effective = limit + carry
    required Money carry,
    required Money spent,
    required Money planned,
    required Money remaining,    // limit - spent (may be negative)
    required Money free,         // max(0, limit - spent - planned)
    Money? perDay,
    Money? forecast,
    required int daysLeft,
    required double timeRatio,
    required BudgetStatus status,
    required bool incomplete,    // some currency could not be converted
  }) = _BudgetProgress;
}

// features/debt/data/models/debt_model.dart
enum DebtDirection { lent, borrowed }        // dbValue 'lent' | 'borrowed'
enum PaymentKind { repayment, forgiveness }

@freezed
abstract class DebtSummary with _$DebtSummary {
  const factory DebtSummary({
    required DebtModel debt,
    required PersonModel person,
    required Money principal,
    required Money remaining,
    required bool overdue,
  }) = _DebtSummary;
}

@freezed
abstract class PersonBalance with _$PersonBalance {
  const factory PersonBalance({
    required String personId,
    required Map<CurrencyType, int> owedToMe,   // minor, per currency
    required Map<CurrencyType, int> iOwe,
    Money? owedToMeBase,                        // null when nothing open or unconvertible
    Money? iOweBase,
  }) = _PersonBalance;
}

// features/debt/data/debt_resolution.dart — pure, shared by UI hint and repository
enum DebtFlow { outgoing, incoming }   // GAVE | GOT
sealed class DebtResolution { const DebtResolution(); }
class OpensDebt extends DebtResolution { final DebtDirection direction; const OpensDebt(this.direction); }
class RepaysDebts extends DebtResolution { final DebtDirection direction; const RepaysDebts(this.direction); } // direction of the debts being repaid

DebtResolution resolveDebtFlow(PersonBalance balance, DebtFlow flow) => switch (flow) {
      DebtFlow.outgoing => balance.iOwe.isNotEmpty ? const RepaysDebts(DebtDirection.borrowed) : const OpensDebt(DebtDirection.lent),
      DebtFlow.incoming => balance.owedToMe.isNotEmpty ? const RepaysDebts(DebtDirection.lent) : const OpensDebt(DebtDirection.borrowed),
    };
```

---

## Changelog

- 2026-10-07 — v1.0: initial specification (budgets as standalone entity with wallet/tag scope; personal debts with GAVE/GOT flow).
- *(Claude: append deviations from this spec here, one line each, with the reason.)*
- 2026-10-07 — M1: FX for debt repayments is fetched **before** `db.transaction` opens (`DebtRepository.prepareRates` → `DebtRates` snapshot) instead of inside it (§7.3): `FxServiceImpl` reads/writes its cache on `sqlite.db`, and any non-txn DB access inside a sqflite transaction deadlocks. A pair missing from the snapshot still fails the write with `FxUnavailableFailure`.
- 2026-10-07 — M1: Budget scope SQL (B1/B2/B3) takes explicit wallet/tag id sets instead of `budget_id` subqueries, so the same queries serve the unsaved scope of the budget form (limit suggestion, §5.6). Semantics unchanged (empty set = any, tags ANY via `EXISTS`, counted once).
- 2026-10-07 — M1: `addMonthsClamped` now uses floor division so negative offsets cross years correctly (was `~/`, wrong for months < 0; only positive offsets existed before). Needed for rollover / suggestion look-back. The engine's step is extracted as `nextOccurrenceStep` / `occurrencesFrom` (recurring_schedule.dart) and used by both `RecurringEngine.catchUp` and budget "planned".
- 2026-10-07 — M1: `monthlyAnchor` / `yearlyAnchor` return the latest date ≤ today whose day **is** the chosen start day (skipping months too short for it) rather than a clamped date, so a day-31 budget never degrades to day 28 after February; the running period's clamped edge still comes from `periodAt`.
- 2026-10-07 — M1: status `over` also when the effective limit ≤ 0 (§5.5 table says `S > L`; with L = 0 and S = 0 that would be `atRisk`). Matches §13 ("bar full in neg500, '€X over'").
- 2026-10-07 — M1: `DebtOverpaymentFailure` and `PersonHasDebtsFailure` extend `ValidationFailure` (field `amount` / `person`), satisfying both §7.6 (typed failure, inline message) and §12.2 ("over-repayment → ValidationFailure").
- 2026-10-07 — M1: `TransactionRepository.update` refuses debt-linked rows and drafts with a `DebtIntent` (`ValidationFailure('debt')`), enforcing [A8] at the repository, not only in the UI.
- 2026-10-07 — M1: `people.normalized_name` = trimmed, whitespace-collapsed, lower-case; NFC is deferred exactly like `TagNormalizer` (no normaliser dependency).
- 2026-10-07 — M1: Debt read methods (`overview`, `byId`, `searchPeople`, `personBalance`) take `required CurrencyType base` (base totals need it; providers will pass `baseCurrencyProvider`). Extra enum `DebtCloseReason`. Budget reads are `listProgress({now})` / `progressOf(id, {periodOffset, now})`.
- 2026-10-07 — M1: `impactOf` only returns budgets whose **running** period contains the transaction date (a back-dated expense does not move the current period, so the toast must not claim it did).
- 2026-10-07 — M1: tag co-occurrences (graph edges) also exclude debt-linked rows, alongside `sumsByTag` / `walletsOfTag`.
- 2026-10-07 — M1: `TagRepository.delete` returns the number of budgets removed; `WalletDeleteOutcome.removedBudgets` is populated. The snackbar wording that mentions them ships with M2 (UI + l10n). `TransactionRow` debt fields (§8.6) ship with M3; notifier tests (§12.3) with M2/M3.
- 2026-10-07 — M1: l10n keys added now (all 7 locales) because the new failures need them: `debt_error_owes_you_only`, `debt_error_you_owe_only`, `person_error_has_debts`, `debt_error_closed`.
- 2026-10-07 — M1 fix: pre-existing bug in `WalletLocalDatasource.softDelete` — the rules `UPDATE` mixed `?` and `?1`, so `?1` bound to the first SET value and wallet deletion never paused its rules on device (newer sqlite3 ffi rejects it outright). Rewritten with explicit indexes.
- 2026-10-07 — M2: `UiBudgetRow` takes already-localised strings (design system stays l10n-free); the Wallet Details "Spent X of Y" variant is `BudgetProgressRow(spentOf: true)` building a different caption — no widget fork.
- 2026-10-07 — M2: Dashboard shows "All budgets ›" whenever some live budget is not in the top 3 (spec: only when > 3 live budgets), so not-started / finished one-time budgets stay reachable from the dashboard.
- 2026-10-07 — M2: `BudgetProgress` gained `subscriptionCount` / `subscriptionPlanned` for the details page "2 subscriptions · €45" row; `TransactionRepository.pageForScope` lists the rows a budget counts.
- 2026-10-07 — M2: the period browser is hidden for one-time budgets (single period); editing a budget keeps its anchor while the start settings are unchanged (rollover history is index-based).
- 2026-10-07 — M3: `TagsViewToggle` moved (not copied) to the design system as `UiSegmentedToggle`; the tags page and the Debts page / New debt sheet use it.
- 2026-10-07 — M3: `TransactionRepository.softDelete` resolves with the number of other rows the debt cascade removed (was `void`), for "Loan deleted with 2 returns".
- 2026-10-07 — M3: Debt sheet overflow menu and the due-date "change / remove" choice use `UIAlertDialog.choose` (no popup-menu component exists in the design system).
- 2026-10-07 — M3: `share_plus` is added with `flutter pub add` (latest stable compatible resolved on the developer machine — the build sandbox has no pub.dev access).
