import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/providers/data/db_revision_provider.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../transaction/data/models/recurring_rule_model.dart';
import '../../transaction/data/models/transaction_filter.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../../transaction/data/transaction_repository.dart';
import '../data/models/wallet_model.dart';
import '../data/wallet_repository.dart';

part 'wallet_details_notifier.freezed.dart';

@freezed
abstract class WalletDetailsState with _$WalletDetailsState {
  const factory WalletDetailsState({
    required AsyncValue<WalletSummary> wallet,
    required AsyncValue<List<TransactionRow>> transactions,
    /// All non-deleted rules touching this wallet (active first).
    @Default([]) List<RecurringRuleModel> rules,
    @Default(true) bool hasMore,
    @Default(false) bool isLoadingMore,

    /// Current list constraints (toolbar). Both are passed straight to the
    /// datasource; changing either resets paging.
    @Default(TransactionFilter.none) TransactionFilter filter,
    @Default(TransactionSort.dateDesc) TransactionSort sort,
  }) = _WalletDetailsState;
}

final walletDetailsProvider =
    NotifierProvider.autoDispose.family<WalletDetailsNotifier, WalletDetailsState, String>(WalletDetailsNotifier.new);

class WalletDetailsNotifier extends Notifier<WalletDetailsState> {
  WalletDetailsNotifier(this.walletId);

  final String walletId;

  /// Bumped on every transactions query so a slow, stale page (e.g. issued
  /// before a filter change) can never overwrite a newer one.
  int _requestId = 0;

  WalletRepository get _wallets => ref.read(walletRepositoryProvider);
  TransactionRepository get _transactions => ref.read(transactionRepositoryProvider);

  @override
  WalletDetailsState build() {
    // Re-query on every write anywhere in the app; keep the previous rows on
    // screen while the fresh page loads (no loading flash after a save).
    ref.watch(dbRevisionProvider);
    final previous = stateOrNull;
    Future.microtask(_load);
    return previous ??
        const WalletDetailsState(wallet: AsyncValue.loading(), transactions: AsyncValue.loading());
  }

  Future<void> _load() async {
    final walletResult = await _wallets.byId(walletId);
    if (!ref.mounted) return;
    walletResult.when(
      (wallet) => state = state.copyWith(wallet: AsyncValue.data(wallet)),
      (error) => state = state.copyWith(wallet: AsyncValue.error(error, StackTrace.current)),
    );

    final rulesResult = await _transactions.rulesForWallet(walletId);
    if (!ref.mounted) return;
    rulesResult.whenSuccess((rules) => state = state.copyWith(rules: rules));

    // Reload as many rows as are currently shown (at least one page) so an
    // undo / delete does not collapse the list.
    final shown = state.transactions.value?.length ?? 0;
    final limit = shown > kTransactionsPageSize ? shown : kTransactionsPageSize;
    await _loadTransactions(limit: limit);
  }

  /// First page(s) for the current [WalletDetailsState.filter] / `sort`.
  /// The previous rows stay on screen until the result arrives.
  Future<void> _loadTransactions({required int limit}) async {
    final requestId = ++_requestId;
    final filter = state.filter;
    final sort = state.sort;
    final txResult = await _transactions.pageForWallet(
      walletId,
      limit: limit,
      offset: 0,
      filter: filter,
      sort: sort,
    );
    if (!ref.mounted || requestId != _requestId) return;
    txResult.when(
      (rows) => state = state.copyWith(
        transactions: AsyncValue.data(rows),
        hasMore: rows.length >= limit,
        isLoadingMore: false,
      ),
      (error) => state = state.copyWith(
        transactions: AsyncValue.error(error, StackTrace.current),
        isLoadingMore: false,
      ),
    );
  }

  /// Infinite scroll — next page at 80 % scroll extent.
  Future<void> loadMore() async {
    final current = state.transactions.value;
    if (current == null || !state.hasMore || state.isLoadingMore) return;
    final requestId = _requestId;
    state = state.copyWith(isLoadingMore: true);
    final result = await _transactions.pageForWallet(
      walletId,
      offset: current.length,
      filter: state.filter,
      sort: state.sort,
    );
    if (!ref.mounted) return;
    // A filter / sort change happened meanwhile: that reload owns the list.
    if (requestId != _requestId) return;
    result.when(
      (rows) => state = state.copyWith(
        transactions: AsyncValue.data([...current, ...rows]),
        hasMore: rows.length >= kTransactionsPageSize,
        isLoadingMore: false,
      ),
      (error) {
        state = state.copyWith(isLoadingMore: false);
        ref.read(appEventProvider).send(ShowErrorEvent(error));
      },
    );
  }

  // ------------------------------------------------------------ filter/sort

  /// Replace the filter and reload from the first page (rows already on
  /// screen stay until the new page arrives).
  Future<void> setFilter(TransactionFilter filter) async {
    if (filter == state.filter) return;
    state = state.copyWith(filter: filter, hasMore: true, isLoadingMore: false);
    await _loadTransactions(limit: kTransactionsPageSize);
  }

  Future<void> clearFilter() => setFilter(TransactionFilter.none);

  Future<void> setSort(TransactionSort sort) async {
    if (sort == state.sort) return;
    state = state.copyWith(sort: sort, hasMore: true, isLoadingMore: false);
    await _loadTransactions(limit: kTransactionsPageSize);
  }

  // ----------------------------------------------------------------- writes

  /// Swipe-to-delete: soft delete immediately, offer undo for 4 s.
  Future<void> deleteTransaction(TransactionRow row, {required String message, required String undoLabel}) async {
    final current = state.transactions.value ?? const <TransactionRow>[];
    // Optimistic removal so the row animates out before the DB round-trip.
    state = state.copyWith(transactions: AsyncValue.data(current.where((r) => r.id != row.id).toList()));

    final result = await _transactions.softDelete(row.id);
    if (!ref.mounted) return;
    result.when(
      (_) => ref.read(appEventProvider).send(
            ShowUndoEvent(message, actionLabel: undoLabel, onUndo: () => _transactions.restore(row.id)),
          ),
      (error) {
        state = state.copyWith(transactions: AsyncValue.data(current));
        ref.read(appEventProvider).send(ShowErrorEvent(error));
      },
    );
  }

  Future<void> setRuleActive(String ruleId, bool active) async {
    final result = await _transactions.setRuleActive(ruleId, active);
    result.whenError((e) => ref.read(appEventProvider).send(ShowErrorEvent(e)));
  }

  Future<void> deleteRule(String ruleId) async {
    final result = await _transactions.deleteRule(ruleId);
    result.whenError((e) => ref.read(appEventProvider).send(ShowErrorEvent(e)));
  }
}
