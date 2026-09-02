import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/tag/data/tag_repository.dart';
import '../../features/transaction/data/models/transaction_model.dart';
import '../../features/transaction/data/recurring_rule_local_datasource.dart';
import '../../features/transaction/data/transaction_local_datasource.dart';
import '../local/database/sqlite/sqlite_services.dart';
import '../providers/data/db_revision_provider.dart';
import '../providers/local/sqlite_database_provider.dart';
import '../utils/debug_print.dart';
import '../utils/extensions/date_time_extensions.dart';
import '../utils/id_generator.dart';
import 'recurring_schedule.dart';

export 'recurring_schedule.dart';

final recurringEngineProvider = Provider<RecurringEngine>(
  (ref) => RecurringEngine(
    sqlite: ref.read(sqliteDataBaseProvider),
    tags: ref.read(tagRepositoryProvider),
    settings: ref.read(settingsLocalDataProvider),
    onWrite: ref.read(dbRevisionBumperProvider),
  ),
);

/// Catch-up generation of recurring occurrences (spec 9.2). Runs at startup
/// and when the app returns to foreground after ≥ 1 h.
class RecurringEngine {
  RecurringEngine({
    required this.sqlite,
    required this.tags,
    required this.settings,
    required this.onWrite,
    this.rules = const RecurringRuleLocalDatasource(),
    this.transactions = const TransactionLocalDatasource(),
  });

  final SQLiteServices sqlite;
  final TagRepository tags;
  final SettingsLocalDatasource settings;
  final RecurringRuleLocalDatasource rules;
  final TransactionLocalDatasource transactions;
  final void Function() onWrite;

  /// Safety cap per rule per run (daily rule untouched for > 1 year).
  static const int maxPerRule = 400;

  bool _running = false;

  /// Foreground re-entry: ignore when the DB is not open yet (splash owns it).
  Future<void> catchUpIfPossible() async {
    if (!sqlite.isOpen) return;
    await catchUp(DateTime.now());
  }

  /// Returns the number of occurrences generated.
  Future<int> catchUp(DateTime now) async {
    if (_running) return 0;
    _running = true;
    var generated = 0;
    try {
      final db = sqlite.db;
      final nowMillis = now.epochMs;
      final due = await rules.due(db, nowMillis);

      for (final rule in due) {
        // One SQLite transaction per rule.
        await db.transaction((txn) async {
          var r = rule;
          var count = 0;
          while (!r.nextOccurrence.isAfter(now)) {
            final occurrenceId = newId();
            final inserted = await transactions.insertIgnore(
              txn,
              TransactionModel(
                id: occurrenceId,
                type: r.type,
                walletId: r.walletId,
                amountMinor: r.amountMinor,
                currency: r.currency,
                fromWalletId: r.fromWalletId,
                toWalletId: r.toWalletId,
                fromAmountMinor: r.fromAmountMinor,
                toAmountMinor: r.toAmountMinor,
                exchangeRate: r.isTransfer ? r.exchangeRate : null,
                description: r.description,
                transactionDate: r.nextOccurrence,
                recurringRuleId: r.id,
                createdAt: now,
                updatedAt: now,
              ),
            );
            if (inserted) {
              await tags.copyRuleTagsToTransaction(txn, r.id, occurrenceId, nowMillis);
              generated++;
            }
            final nextCount = r.occurrenceCount + 1;
            r = r.copyWith(
              occurrenceCount: nextCount,
              nextOccurrence: advance(r.startDate, r.frequency, nextCount),
              updatedAt: now,
            );
            if (++count >= maxPerRule) break;
          }
          if (r.endDate != null && r.nextOccurrence.isAfter(r.endDate!)) {
            r = r.copyWith(isActive: false);
          }
          await rules.update(txn, r);
        });
      }

      await settings.setLastRecurringRunAt(nowMillis);
      if (generated > 0) onWrite();
      debugPrint('Recurring catch-up: $generated occurrence(s) from ${due.length} rule(s)');
    } catch (e) {
      debugPrint('Recurring catch-up failed: $e');
    } finally {
      _running = false;
    }
    return generated;
  }
}
