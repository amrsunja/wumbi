import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/money/currency_type.dart';
import '../../../core/providers/data/db_revision_provider.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../data/models/tag_stats.dart';
import '../data/tag_repository.dart';

/// Tags hub state: ranked stats for the list and the co-occurrence graph for
/// the map. Both are base-currency totals.
class TagsState {
  const TagsState({
    this.stats = const AsyncValue.loading(),
    this.graph = const AsyncValue.loading(),
  });

  final AsyncValue<List<TagStats>> stats;
  final AsyncValue<TagGraphData> graph;

  TagsState copyWith({
    AsyncValue<List<TagStats>>? stats,
    AsyncValue<TagGraphData>? graph,
  }) =>
      TagsState(stats: stats ?? this.stats, graph: graph ?? this.graph);
}

final tagsProvider = NotifierProvider.autoDispose<TagsNotifier, TagsState>(TagsNotifier.new);

class TagsNotifier extends Notifier<TagsState> {
  TagRepository get _tags => ref.read(tagRepositoryProvider);

  @override
  TagsState build() {
    // Re-query after any write and whenever the base currency changes; keep
    // the previous data on screen while the fresh totals load.
    ref.watch(dbRevisionProvider);
    final base = ref.watch(baseCurrencyProvider);
    final previous = stateOrNull;
    Future.microtask(() => _load(base));
    return previous ?? const TagsState();
  }

  Future<void> _load(CurrencyType base) async {
    final statsResult = await _tags.stats(base);
    if (!ref.mounted) return;
    statsResult.when(
      (stats) => state = state.copyWith(stats: AsyncValue.data(stats)),
      (error) => state = state.copyWith(stats: AsyncValue.error(error, StackTrace.current)),
    );

    final graphResult = await _tags.graph(base);
    if (!ref.mounted) return;
    graphResult.when(
      (graph) => state = state.copyWith(graph: AsyncValue.data(graph)),
      (error) => state = state.copyWith(graph: AsyncValue.error(error, StackTrace.current)),
    );
  }
}
