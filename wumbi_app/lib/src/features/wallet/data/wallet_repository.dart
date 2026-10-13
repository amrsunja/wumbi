import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/exceptions/domain/domain_exceptions.dart';
import '../../../core/errors/failures/failures.dart';
import '../../../core/local/database/sqlite/sqlite_services.dart';
import '../../../core/providers/data/db_revision_provider.dart';
import '../../../core/providers/local/sqlite_database_provider.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/typedefs.dart';
import '../../budget/data/budget_local_datasource.dart';
import 'models/wallet_model.dart';
import 'wallet_local_datasource.dart';

final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => WalletRepository(
    sqlite: ref.read(sqliteDataBaseProvider),
    onWrite: ref.read(dbRevisionBumperProvider),
  ),
);

/// Result of a wallet soft delete (for the snackbar text).
class WalletDeleteOutcome {
  const WalletDeleteOutcome({required this.pausedRules, this.removedBudgets = 0});
  final int pausedRules;

  /// Budgets scoped only to this wallet, deleted with it (spec B&D §4.4).
  final int removedBudgets;
}

/// Invariants (spec 5.10):
/// - exactly one primary among non-deleted wallets;
/// - currency locked once the wallet has transactions ([A3]);
/// - soft delete cascades to income/expense transactions and pauses rules,
///   removes the wallet from budget scopes and deletes budgets left with no
///   wallet. Debts are untouched: an obligation does not vanish with a wallet.
class WalletRepository {
  WalletRepository({
    required this.sqlite,
    required this.onWrite,
    this.datasource = const WalletLocalDatasource(),
    this.budgets = const BudgetLocalDatasource(),
  });

  final SQLiteServices sqlite;
  final WalletLocalDatasource datasource;
  final BudgetLocalDatasource budgets;

  /// Bumps `dbRevisionProvider`.
  final void Function() onWrite;

  Future<SuccessOrError<List<WalletSummary>>> listActive() =>
      Failure.exceptionsCatcher(() => datasource.listActive(sqlite.db));

  Future<SuccessOrError<WalletSummary>> byId(String id) =>
      Failure.exceptionsCatcher(() async {
        final wallet = await datasource.byId(sqlite.db, id);
        if (wallet == null) throw const NotFoundException('wallet');
        return wallet;
      });

  /// Name of any wallet, deleted or not (transfer titles).
  Future<SuccessOrError<WalletModel?>> rawById(String id) =>
      Failure.exceptionsCatcher(() => datasource.rawById(sqlite.db, id));

  Future<SuccessOrError<WalletModel?>> primary() =>
      Failure.exceptionsCatcher(() => datasource.primary(sqlite.db));

  Future<SuccessOrError<bool>> hasTransactions(String id) =>
      Failure.exceptionsCatcher(() => datasource.hasTransactions(sqlite.db, id));

  Future<SuccessOrError<WalletModel>> create(WalletDraft draft) =>
      Failure.exceptionsCatcher(() async {
        _validate(draft);
        final now = DateTime.now();
        late WalletModel wallet;
        await sqlite.db.transaction((txn) async {
          final count = await datasource.countActive(txn);
          // The first wallet is primary regardless of the toggle.
          final isPrimary = count == 0 || draft.isPrimary;
          if (isPrimary) await datasource.clearPrimary(txn, now.epochMs);
          wallet = WalletModel(
            id: newId(),
            name: draft.name.trim(),
            currency: draft.currency,
            initialBalanceMinor: draft.initialBalanceMinor,
            color: draft.color,
            isPrimary: isPrimary,
            includeInTotal: draft.includeInTotal,
            sortOrder: await datasource.nextSortOrder(txn),
            createdAt: now,
            updatedAt: now,
          );
          await datasource.insert(txn, wallet);
        });
        onWrite();
        return wallet;
      });

  Future<SuccessOrError<WalletModel>> update(String id, WalletDraft draft) =>
      Failure.exceptionsCatcher(() async {
        _validate(draft);
        final now = DateTime.now();
        late WalletModel updated;
        await sqlite.db.transaction((txn) async {
          final existing = await datasource.rawById(txn, id);
          if (existing == null || existing.deletedAt != null) {
            throw const NotFoundException('wallet');
          }
          if (existing.currency != draft.currency && await datasource.hasTransactions(txn, id)) {
            throw const WalletHasTransactionsException();
          }
          // Turning the primary flag off on the current primary is refused —
          // the UI snaps the switch back; here we simply keep it on.
          final isPrimary = existing.isPrimary || draft.isPrimary;
          if (isPrimary && !existing.isPrimary) await datasource.clearPrimary(txn, now.epochMs);
          updated = existing.copyWith(
            name: draft.name.trim(),
            currency: draft.currency,
            initialBalanceMinor: draft.initialBalanceMinor,
            color: draft.color,
            isPrimary: isPrimary,
            includeInTotal: draft.includeInTotal,
            updatedAt: now,
          );
          await datasource.update(txn, updated);
        });
        onWrite();
        return updated;
      });

  Future<SuccessOrError<void>> setPrimary(String id) =>
      Failure.exceptionsCatcher(() async {
        final now = nowMs();
        await sqlite.db.transaction((txn) async {
          await datasource.clearPrimary(txn, now);
          await datasource.setPrimary(txn, id, now);
        });
        onWrite();
      });

  /// Dashboard drag & drop: persists the new order and makes the first
  /// wallet primary (exactly one primary is kept).
  Future<SuccessOrError<void>> reorder(List<String> orderedIds) =>
      Failure.exceptionsCatcher(() async {
        if (orderedIds.isEmpty) return;
        final now = nowMs();
        await sqlite.db.transaction((txn) async {
          for (var i = 0; i < orderedIds.length; i++) {
            await datasource.setSortOrder(txn, orderedIds[i], i, now);
          }
          await datasource.clearPrimary(txn, now);
          await datasource.setPrimary(txn, orderedIds.first, now);
        });
        onWrite();
      });

  /// D13: soft delete + cascade; promotes a new primary when needed.
  Future<SuccessOrError<WalletDeleteOutcome>> softDelete(String id) =>
      Failure.exceptionsCatcher(() async {
        final now = nowMs();
        var paused = 0;
        var removedBudgets = 0;
        await sqlite.db.transaction((txn) async {
          paused = await datasource.softDelete(txn, id, now);
          await datasource.promotePrimaryIfNeeded(txn, now);
          // A budget must never silently widen to "all wallets".
          final scoped = await budgets.unlinkWallet(txn, id);
          removedBudgets = await budgets.softDeleteWithoutWallets(txn, scoped, now);
        });
        onWrite();
        return WalletDeleteOutcome(pausedRules: paused, removedBudgets: removedBudgets);
      });

  void _validate(WalletDraft draft) {
    final name = draft.name.trim();
    if (name.isEmpty || name.length > kMaxWalletNameLength) {
      throw const ValidationException('name');
    }
  }
}
