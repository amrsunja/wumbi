import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wumbi/src/features/backup/data/backup_database.dart';

/// Fresh in-memory ffi database for staging (no SQLCipher in tests).
BackupDatabase ffiBackupDatabase() => BackupDatabase(
      openStaging: () => databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      ),
    );

const t0 = 1767225600000; // 2026-01-01T00:00:00Z
const day = 86400000;

/// One row in every backed-up table of the current schema, including a
/// soft-deleted wallet still referenced by a transaction, a transfer, a
/// recurring rule with generated rows, a budget scope, a debt with a
/// repayment, unicode text and a REAL exchange rate.
Future<void> seedEverything(Database db) async {
  await db.update('settings', {
    'language_code': 'ru',
    'country_code': null,
    'theme_mode': 'dark',
    'show_onboarding': 0,
    'base_currency': 'EUR',
    'notifications_enabled': 1,
    'show_mascot': 1,
    'last_recurring_run_at': t0 + 40 * day,
    'mascot_talks': 0,
    'notification_prefs': '{"recaps":false}',
  });

  Map<String, Object?> wallet(String id, String name, String currency, {bool primary = false, int? deletedAt}) => {
        'id': id,
        'name': name,
        'currency': currency,
        'initial_balance_minor': 123456,
        'color': 'violet',
        'is_primary': primary ? 1 : 0,
        'sort_order': 0,
        'created_at': t0,
        'updated_at': t0,
        'deleted_at': deletedAt,
        'sync_status': 'pending',
        'include_in_total': deletedAt == null ? 1 : 0,
      };
  await db.insert('wallets', wallet('w-eur', 'Карта 💳', 'EUR', primary: true));
  await db.insert('wallets', wallet('w-jpy', 'Tokyo, "cash"', 'JPY'));
  await db.insert('wallets', wallet('w-old', 'Closed', 'USD', deletedAt: t0 + day));

  Map<String, Object?> tag(String id, String name) => {
        'id': id,
        'normalized_name': name.toLowerCase(),
        'display_name': name,
        'usage_count': 2,
        'last_used_at': t0,
        'created_at': t0,
        'updated_at': t0,
        'deleted_at': null,
        'sync_status': 'pending',
      };
  await db.insert('tags', tag('g-food', 'Food'));
  await db.insert('tags', tag('g-fun', '=Fun'));

  await db.insert('people', {
    'id': 'p-ann',
    'name': 'Ann',
    'normalized_name': 'ann',
    'last_used_at': t0,
    'created_at': t0,
    'updated_at': t0,
    'deleted_at': null,
    'sync_status': 'pending',
  });

  await db.insert('recurring_rules', {
    'id': 'r-rent',
    'type': 'expense',
    'wallet_id': 'w-eur',
    'amount_minor': 90000,
    'currency': 'EUR',
    'description': 'Rent',
    'frequency': 'monthly',
    'interval': 1,
    'start_date': t0,
    'next_occurrence': t0 + 31 * day,
    'occurrence_count': 1,
    'end_date': null,
    'is_active': 1,
    'created_at': t0,
    'updated_at': t0,
    'deleted_at': null,
    'sync_status': 'pending',
  });

  Map<String, Object?> tx(String id, Map<String, Object?> fields) => {
        'id': id,
        'currency': 'EUR',
        'description': '',
        'transaction_date': t0,
        'status': 'posted',
        'created_at': t0,
        'updated_at': t0,
        'sync_status': 'pending',
        ...fields,
      };
  await db.insert('transactions', tx('t-rent', {'type': 'expense', 'wallet_id': 'w-eur', 'amount_minor': 90000, 'recurring_rule_id': 'r-rent', 'description': 'Rent'}));
  await db.insert('transactions', tx('t-salary', {'type': 'income', 'wallet_id': 'w-eur', 'amount_minor': 300000, 'description': 'Salary, March "bonus"\nline 2', 'transaction_date': t0 + day}));
  await db.insert('transactions', tx('t-fx', {
    'type': 'transfer',
    'from_wallet_id': 'w-eur',
    'to_wallet_id': 'w-jpy',
    'from_amount_minor': 10000,
    'to_amount_minor': 16250,
    'exchange_rate': 162.5,
    'transaction_date': t0 + 2 * day,
  }));
  await db.insert('transactions', tx('t-old', {'type': 'expense', 'wallet_id': 'w-old', 'amount_minor': 500, 'currency': 'USD', 'description': '@old', 'transaction_date': t0 + 3 * day}));
  await db.insert('transactions', tx('t-lend', {'type': 'expense', 'wallet_id': 'w-eur', 'amount_minor': 2000, 'debt_role': 'principal', 'transaction_date': t0 + 4 * day}));
  await db.insert('transactions', tx('t-back', {'type': 'income', 'wallet_id': 'w-eur', 'amount_minor': 500, 'debt_role': 'repayment', 'transaction_date': t0 + 5 * day}));
  await db.insert('transactions', tx('t-soon', {'type': 'expense', 'wallet_id': 'w-eur', 'amount_minor': 100, 'status': 'upcoming', 'original_amount_minor': 120, 'original_currency': 'USD', 'transaction_date': t0 + 60 * day}));
  await db.insert('transactions', tx('t-gone', {'type': 'expense', 'wallet_id': 'w-eur', 'amount_minor': 1, 'deleted_at': t0 + day}));

  await db.insert('transaction_tags', {'transaction_id': 't-rent', 'tag_id': 'g-food', 'created_at': t0});
  await db.insert('transaction_tags', {'transaction_id': 't-rent', 'tag_id': 'g-fun', 'created_at': t0});
  await db.insert('recurring_rule_tags', {'recurring_rule_id': 'r-rent', 'tag_id': 'g-food', 'created_at': t0});

  await db.insert('budgets', {
    'id': 'b-food',
    'name': 'Food',
    'limit_minor': 40000,
    'currency': 'EUR',
    'period': 'monthly',
    'anchor_date': t0,
    'end_date': null,
    'rollover': 'surplus',
    'include_planned': 1,
    'sort_order': 0,
    'created_at': t0,
    'updated_at': t0,
    'deleted_at': null,
    'sync_status': 'pending',
  });
  await db.insert('budget_wallets', {'budget_id': 'b-food', 'wallet_id': 'w-eur', 'created_at': t0});
  await db.insert('budget_tags', {'budget_id': 'b-food', 'tag_id': 'g-food', 'created_at': t0});

  await db.insert('debts', {
    'id': 'd-ann',
    'person_id': 'p-ann',
    'direction': 'lent',
    'principal_minor': 2000,
    'currency': 'EUR',
    'description': 'Lunch',
    'opened_at': t0 + 4 * day,
    'due_date': t0 + 30 * day,
    'principal_transaction_id': 't-lend',
    'closed_at': null,
    'close_reason': null,
    'created_at': t0,
    'updated_at': t0,
    'deleted_at': null,
    'sync_status': 'pending',
  });
  await db.insert('debt_payments', {
    'id': 'dp-1',
    'debt_id': 'd-ann',
    'transaction_id': 't-back',
    'kind': 'repayment',
    'amount_minor': 500,
    'paid_at': t0 + 5 * day,
    'created_at': t0,
    'updated_at': t0,
    'deleted_at': null,
    'sync_status': 'pending',
  });

  await db.insert('mascot_memory', {'key': 'visits', 'value': '{"count":12}', 'updated_at': t0});
  await db.insert('exchange_rates', {'base_currency': 'EUR', 'quote_currency': 'JPY', 'rate': 162.5, 'fetched_at': t0});
}

/// Different, smaller data — what the target device had before a restore.
Future<void> seedOtherDevice(Database db) async {
  await db.update('settings', {'language_code': 'en', 'theme_mode': 'light', 'notifications_enabled': 0, 'show_onboarding': 0});
  await db.insert('wallets', {
    'id': 'w-local',
    'name': 'Local',
    'currency': 'USD',
    'initial_balance_minor': 0,
    'color': 'blue',
    'is_primary': 1,
    'sort_order': 0,
    'created_at': t0,
    'updated_at': t0,
    'sync_status': 'pending',
  });
  await db.insert('transactions', {
    'id': 't-local',
    'type': 'expense',
    'wallet_id': 'w-local',
    'amount_minor': 700,
    'currency': 'USD',
    'description': 'Coffee',
    'transaction_date': t0,
    'created_at': t0,
    'updated_at': t0,
    'sync_status': 'pending',
  });
}
