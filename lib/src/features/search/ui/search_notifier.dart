import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/providers/data/db_revision_provider.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../../transaction/data/transaction_repository.dart';

/// Global search state. An empty [query] is the resting state — no request is
/// issued and the page shows its hint instead of "no results".
class SearchState {
  const SearchState({
    this.query = '',
    this.results = const AsyncValue.data([]),
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final String query;
  final AsyncValue<List<TransactionRow>> results;
  final bool hasMore;
  final bool isLoadingMore;

  bool get isIdle => query.trim().isEmpty;

  SearchState copyWith({
    String? query,
    AsyncValue<List<TransactionRow>>? results,
    bool? hasMore,
    bool? isLoadingMore,
  }) =>
      SearchState(
        query: query ?? this.query,
        results: results ?? this.results,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

final searchProvider = NotifierProvider.autoDispose<SearchNotifier, SearchState>(SearchNotifier.new);

class SearchNotifier extends Notifier<SearchState> {
  static const _debounce = Duration(milliseconds: 250);

  Timer? _timer;

  /// Guards against a slow request for an older query overwriting a newer one.
  int _requestId = 0;

  TransactionRepository get _transactions => ref.read(transactionRepositoryProvider);

  @override
  SearchState build() {
    // Re-run the current query after any write (delete, undo, edit).
    ref.watch(dbRevisionProvider);
    final previous = stateOrNull;
    ref.onDispose(() => _timer?.cancel());
    if (previous != null && !previous.isIdle) {
      Future.microtask(() => _run(previous.query));
    }
    return previous ?? const SearchState();
  }

  /// Typing: debounced so a fast typist issues one query, not eight.
  void onQueryChanged(String value) {
    _timer?.cancel();
    if (value.trim().isEmpty) {
      _requestId++;
      state = const SearchState();
      return;
    }
    state = state.copyWith(query: value, results: const AsyncValue.loading());
    _timer = Timer(_debounce, () => _run(value));
  }

  /// Keyboard "search" action — skip the debounce.
  void submit(String value) {
    _timer?.cancel();
    if (value.trim().isEmpty) return;
    state = state.copyWith(query: value, results: const AsyncValue.loading());
    _run(value);
  }

  void clear() {
    _timer?.cancel();
    _requestId++;
    state = const SearchState();
  }

  Future<void> _run(String query) async {
    final id = ++_requestId;
    final result = await _transactions.search(query);
    if (!ref.mounted || id != _requestId) return;
    result.when(
      (rows) => state = state.copyWith(
        results: AsyncValue.data(rows),
        hasMore: rows.length >= kTransactionsPageSize,
        isLoadingMore: false,
      ),
      (error) => state = state.copyWith(results: AsyncValue.error(error, StackTrace.current)),
    );
  }

  /// Infinite scroll — next page at 80 % scroll extent.
  Future<void> loadMore() async {
    final current = state.results.value;
    if (current == null || state.isIdle || !state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final id = _requestId;
    final result = await _transactions.search(state.query, offset: current.length);
    if (!ref.mounted || id != _requestId) return;
    result.when(
      (rows) => state = state.copyWith(
        results: AsyncValue.data([...current, ...rows]),
        hasMore: rows.length >= kTransactionsPageSize,
        isLoadingMore: false,
      ),
      (error) {
        state = state.copyWith(isLoadingMore: false);
        ref.read(appEventProvider).send(ShowErrorEvent(error));
      },
    );
  }
}
