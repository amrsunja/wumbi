import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/failures/failures.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/providers/data/db_revision_provider.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../../transaction/data/transaction_repository.dart';
import '../data/models/tag_model.dart';
import '../data/models/tag_stats.dart';
import '../data/tag_repository.dart';

class TagDetailsState {
  const TagDetailsState({
    this.stats = const AsyncValue.loading(),
    this.wallets = const [],
    this.transactions = const AsyncValue.loading(),
    this.hasMore = true,
    this.isLoadingMore = false,
    this.notFound = false,
  });

  /// Base-currency totals for the tag.
  final AsyncValue<TagStats> stats;

  /// Wallets touched by the tag with sums in each wallet's currency.
  final List<TagWalletSum> wallets;
  final AsyncValue<List<TransactionRow>> transactions;
  final bool hasMore;
  final bool isLoadingMore;

  /// The tag was deleted (or merged away) underneath the page.
  final bool notFound;

  TagDetailsState copyWith({
    AsyncValue<TagStats>? stats,
    List<TagWalletSum>? wallets,
    AsyncValue<List<TransactionRow>>? transactions,
    bool? hasMore,
    bool? isLoadingMore,
    bool? notFound,
  }) =>
      TagDetailsState(
        stats: stats ?? this.stats,
        wallets: wallets ?? this.wallets,
        transactions: transactions ?? this.transactions,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        notFound: notFound ?? this.notFound,
      );
}

final tagDetailsProvider =
    NotifierProvider.autoDispose.family<TagDetailsNotifier, TagDetailsState, String>(TagDetailsNotifier.new);

class TagDetailsNotifier extends Notifier<TagDetailsState> {
  TagDetailsNotifier(this.tagId);

  final String tagId;

  /// Set once this page's tag is gone by its own action (delete / merge):
  /// the follow-up DB refresh must not surface a "not found" on top of the
  /// navigation the page already performs.
  bool _closed = false;

  TagRepository get _tags => ref.read(tagRepositoryProvider);
  TransactionRepository get _transactions => ref.read(transactionRepositoryProvider);

  @override
  TagDetailsState build() {
    ref.watch(dbRevisionProvider);
    final base = ref.watch(baseCurrencyProvider);
    final previous = stateOrNull;
    Future.microtask(() => _load(base));
    return previous ?? const TagDetailsState();
  }

  Future<void> _load(CurrencyType base) async {
    if (_closed) return;
    final statsResult = await _tags.statsOf(tagId, base);
    if (!ref.mounted || _closed) return;
    var missing = false;
    statsResult.when(
      (stats) => state = state.copyWith(stats: AsyncValue.data(stats)),
      (error) {
        if (error is NotFoundFailure) {
          missing = true;
          state = state.copyWith(notFound: true);
        } else {
          state = state.copyWith(stats: AsyncValue.error(error, StackTrace.current));
        }
      },
    );
    if (missing) return;

    final walletsResult = await _tags.walletsOfTag(tagId);
    if (!ref.mounted || _closed) return;
    walletsResult.whenSuccess((wallets) => state = state.copyWith(wallets: wallets));

    // Reload as many rows as are currently shown (at least one page).
    final shown = state.transactions.value?.length ?? 0;
    final limit = shown > kTransactionsPageSize ? shown : kTransactionsPageSize;
    final txResult = await _transactions.pageForTag(tagId, limit: limit, offset: 0);
    if (!ref.mounted || _closed) return;
    txResult.when(
      (rows) => state = state.copyWith(
        transactions: AsyncValue.data(rows),
        hasMore: rows.length >= limit,
        isLoadingMore: false,
      ),
      (error) => state = state.copyWith(transactions: AsyncValue.error(error, StackTrace.current)),
    );
  }

  /// Infinite scroll — next page at 80 % scroll extent.
  Future<void> loadMore() async {
    final current = state.transactions.value;
    if (current == null || !state.hasMore || state.isLoadingMore || _closed) return;
    state = state.copyWith(isLoadingMore: true);
    final result = await _transactions.pageForTag(tagId, offset: current.length);
    if (!ref.mounted) return;
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

  /// Returns the surviving tag (a different id when merged into an existing
  /// tag), or null on error (already surfaced as a toast).
  Future<TagModel?> rename(String newName) async {
    final result = await _tags.rename(tagId, newName);
    if (!ref.mounted) return null;
    TagModel? renamed;
    result.when(
      (tag) {
        renamed = tag;
        if (tag.id != tagId) _closed = true;
      },
      (error) => ref.read(appEventProvider).send(ShowErrorEvent(error)),
    );
    return renamed;
  }

  /// Returns true when the tag was deleted.
  Future<bool> delete() async {
    _closed = true;
    final result = await _tags.delete(tagId);
    if (!ref.mounted) return false;
    var ok = false;
    result.when(
      (_) {
        ok = true;
      },
      (error) {
        _closed = false;
        ref.read(appEventProvider).send(ShowErrorEvent(error));
      },
    );
    return ok;
  }
}
