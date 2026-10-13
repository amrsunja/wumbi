import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/failures/failures.dart';
import '../../../core/providers/data/db_revision_provider.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../../core/utils/typedefs.dart';
import '../../tag/data/models/tag_model.dart';
import '../../tag/data/tag_repository.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../../transaction/data/transaction_repository.dart';
import '../data/budget_repository.dart';
import '../data/models/budget_model.dart';

part 'budget_details_notifier.freezed.dart';

/// One budget over one period: [periodOffset] 0 = running, −1 = previous …
class BudgetDetailsArgs {
  const BudgetDetailsArgs({required this.budgetId, this.periodOffset = 0});

  final String budgetId;
  final int periodOffset;

  @override
  bool operator ==(Object other) =>
      other is BudgetDetailsArgs && other.budgetId == budgetId && other.periodOffset == periodOffset;

  @override
  int get hashCode => Object.hash(budgetId, periodOffset);
}

@freezed
abstract class BudgetDetailsState with _$BudgetDetailsState {
  const factory BudgetDetailsState({
    required AsyncValue<BudgetProgress> progress,
    required AsyncValue<List<TransactionRow>> rows,

    /// Scope tags that still exist, in the budget's order.
    @Default(<TagModel>[]) List<TagModel> tags,
    @Default(true) bool hasMore,
    @Default(false) bool isLoadingMore,

    /// Deleted underneath us (form, undo on another screen…): the page leaves.
    @Default(false) bool notFound,
  }) = _BudgetDetailsState;
}

final budgetDetailsProvider = NotifierProvider.autoDispose
    .family<BudgetDetailsNotifier, BudgetDetailsState, BudgetDetailsArgs>(BudgetDetailsNotifier.new);

/// Budget details (spec B&D §6.7): progress of the chosen period plus the
/// rows it counts, paged like Wallet Details (50 per page).
class BudgetDetailsNotifier extends Notifier<BudgetDetailsState> {
  BudgetDetailsNotifier(this.args);

  final BudgetDetailsArgs args;
  int _requestId = 0;

  BudgetRepository get _budgets => ref.read(budgetRepositoryProvider);
  TransactionRepository get _transactions => ref.read(transactionRepositoryProvider);

  @override
  BudgetDetailsState build() {
    // Any write anywhere can change spent / planned: re-query, keeping the
    // previous content on screen meanwhile.
    ref.watch(dbRevisionProvider);
    final previous = stateOrNull;
    Future.microtask(_load);
    return previous ?? const BudgetDetailsState(progress: AsyncValue.loading(), rows: AsyncValue.loading());
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    final result = await _budgets.progressOf(args.budgetId, periodOffset: args.periodOffset);
    if (!ref.mounted || requestId != _requestId) return;
    final progress = result.tryGetSuccess();
    if (progress == null) {
      final error = result.tryGetError();
      if (error is NotFoundFailure) {
        state = state.copyWith(notFound: true);
      } else {
        state = state.copyWith(progress: AsyncValue.error(error ?? const UnknownFailure(), StackTrace.current));
      }
      return;
    }
    state = state.copyWith(progress: AsyncValue.data(progress));

    final tags = ref.read(tagRepositoryProvider);
    final scopeTags = <TagModel>[];
    for (final id in progress.budget.tagIds) {
      final t = (await tags.byId(id)).tryGetSuccess();
      if (t != null) scopeTags.add(t);
    }
    if (!ref.mounted || requestId != _requestId) return;
    state = state.copyWith(tags: scopeTags);

    final shown = state.rows.value?.length ?? 0;
    final limit = shown > kTransactionsPageSize ? shown : kTransactionsPageSize;
    final rows = await _page(progress, offset: 0, limit: limit);
    if (!ref.mounted || requestId != _requestId) return;
    rows.when(
      (list) => state = state.copyWith(rows: AsyncValue.data(list), hasMore: list.length >= limit),
      (error) => state = state.copyWith(rows: AsyncValue.error(error, StackTrace.current)),
    );
  }

  Future<SuccessOrError<List<TransactionRow>>> _page(BudgetProgress p, {required int offset, required int limit}) =>
      _transactions.pageForScope(
        walletIds: p.budget.walletIds,
        tagIds: p.budget.tagIds,
        start: p.period.start,
        end: p.period.end,
        limit: limit,
        offset: offset,
      );

  /// Infinite scroll — next page at 80 % scroll extent.
  Future<void> loadMore() async {
    final progress = state.progress.value;
    final current = state.rows.value;
    if (progress == null || current == null || !state.hasMore || state.isLoadingMore) return;
    final requestId = _requestId;
    state = state.copyWith(isLoadingMore: true);
    final result = await _transactions.pageForScope(
      walletIds: progress.budget.walletIds,
      tagIds: progress.budget.tagIds,
      start: progress.period.start,
      end: progress.period.end,
      offset: current.length,
    );
    if (!ref.mounted || requestId != _requestId) return;
    result.when(
      (rows) => state = state.copyWith(
        rows: AsyncValue.data([...current, ...rows]),
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
