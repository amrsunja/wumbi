import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/money/currency_type.dart';
import '../../../core/providers/data/db_revision_provider.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../data/models/tag_stats.dart';
import '../data/models/tag_tree.dart';
import '../data/tag_repository.dart';

/// Tags hub state: ranked stats for the list (also as a nested tree) and the
/// graph for the map. All base-currency totals, nested tags rolled up.
class TagsState {
  const TagsState({
    this.stats = const AsyncValue.loading(),
    this.tree = const [],
    this.graph = const AsyncValue.loading(),
  });

  final AsyncValue<List<TagStats>> stats;

  /// Top-level tags with their nested tags (empty until [stats] loads).
  final List<TagTreeNode> tree;
  final AsyncValue<TagGraphData> graph;

  TagsState copyWith({
    AsyncValue<List<TagStats>>? stats,
    List<TagTreeNode>? tree,
    AsyncValue<TagGraphData>? graph,
  }) =>
      TagsState(stats: stats ?? this.stats, tree: tree ?? this.tree, graph: graph ?? this.graph);
}

final tagsProvider = NotifierProvider.autoDispose<TagsNotifier, TagsState>(TagsNotifier.new);

class TagsNotifier extends Notifier<TagsState> {
  TagRepository get _tags => ref.read(tagRepositoryProvider);

  /// Parents of nested tags typed before nesting existed are created once
  /// per visit.
  bool _repaired = false;

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
    if (!_repaired) {
      _repaired = true;
      await _tags.repairHierarchy();
      if (!ref.mounted) return;
    }

    final statsResult = await _tags.stats(base);
    if (!ref.mounted) return;
    List<TagStats>? stats;
    statsResult.when(
      (value) {
        stats = value;
        state = state.copyWith(stats: AsyncValue.data(value), tree: TagTree.build(value));
      },
      (error) {
        state = state.copyWith(
          stats: AsyncValue.error(error, StackTrace.current),
          graph: AsyncValue.error(error, StackTrace.current),
        );
      },
    );
    final nodes = stats;
    if (nodes == null) return;

    // The map reuses the stats above; only the edges are queried.
    final linksResult = await _tags.links();
    if (!ref.mounted) return;
    linksResult.when(
      (links) {
        state = state.copyWith(graph: AsyncValue.data(TagGraphData(nodes: nodes, links: links, base: base)));
      },
      (error) {
        state = state.copyWith(graph: AsyncValue.error(error, StackTrace.current));
      },
    );
  }
}
