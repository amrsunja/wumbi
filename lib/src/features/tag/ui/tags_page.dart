import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/typedefs.dart';
import '../data/models/tag_stats.dart';
import 'tags_notifier.dart';
import 'widgets/tag_graph_view.dart';
import 'widgets/tags_view_toggle.dart';

enum _TagsView { list, map }

/// Tags hub (`/tags`): ranked list with search, or the co-occurrence map.
@RoutePage()
class TagsPage extends HookConsumerWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final state = ref.watch(tagsProvider);
    final view = useState(_TagsView.list);

    void openTag(TagStats tag) => context.router.push(TagDetailsRoute(tagId: tag.id));

    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: colors.bgColor)),
        if (view.value == _TagsView.map) const Positioned.fill(child: UiAmbientBackground(intensity: 0.7)),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: UIAppbar(
            title: l10n.tags_title,
            transparent: true,
            backTap: () => context.router.maybePop(),
          ),
          body: Column(
            children: [
              const UISpace.vert(4),
              TagsViewToggle(
                labels: [l10n.tags_view_list, l10n.tags_view_graph],
                selectedIndex: view.value == _TagsView.list ? 0 : 1,
                onChanged: (i) => view.value = i == 0 ? _TagsView.list : _TagsView.map,
              ),
              const UISpace.vert(8),
              Expanded(
                child: switch (view.value) {
                  _TagsView.list => _TagList(stats: state.stats, onTap: openTag),
                  _TagsView.map => _TagMap(graph: state.graph, onTap: openTag),
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------------------- list

class _TagList extends HookWidget {
  const _TagList({required this.stats, required this.onTap});

  final AsyncValue<List<TagStats>> stats;
  final ValueChanged<TagStats> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = useState('');
    final all = stats.value;

    final Widget body;
    if (all == null) {
      body = const Padding(
        padding: EdgeInsets.fromLTRB(kListHorzPadding, 24, kListHorzPadding, 0),
        child: UiSkeletonList(rows: 6),
      );
    } else if (all.isEmpty) {
      body = UiEmptyState(
        image: AppAssets.images.wumbiOo.path,
        title: l10n.tags_empty_title,
        subtitle: l10n.tags_empty_subtitle,
      );
    } else {
      final q = query.value.trim().toLowerCase().replaceFirst('#', '');
      final rows = q.isEmpty ? all : all.where((t) => t.name.toLowerCase().contains(q)).toList();
      if (rows.isEmpty) {
        body = Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.tags_search_no_results,
            textAlign: TextAlign.center,
            style: context.typo.inter.hint,
          ),
        );
      } else {
        body = ListView.separated(
          padding: const EdgeInsets.fromLTRB(kListHorzPadding, 4, kListHorzPadding, 96),
          itemCount: rows.length,
          separatorBuilder: (_, _) => const UIDivider(),
          itemBuilder: (context, index) {
            final t = rows[index];
            return _TagRow(stats: t, onTap: () => onTap(t));
          },
        );
      }
    }

    return Column(
      children: [
        if (all != null && all.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 8),
            child: UIInputField(
              hintText: l10n.tags_search_placeholder,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.search,
              onChanged: (v) => query.value = v,
            ),
          ),
        Expanded(child: body),
      ],
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({required this.stats, required this.onTap});

  final TagStats stats;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    final hasExpense = stats.expense.minor > 0;
    final hasIncome = stats.income.minor > 0;

    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text(
                    '#${stats.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typo.rowTitle,
                  ),
                  Text(
                    l10n.tags_usage(stats.transactionCount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typo.caption,
                  ),
                ],
              ),
            ),
            const UISpace.horz(12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 2,
              children: [
                // Spent on the main line; an income-only tag shows the
                // earned amount there instead of a meaningless "-0.00".
                if (hasExpense || !hasIncome)
                  Text(
                    '-${stats.expense.format()}',
                    style: typo.rowTitle.copyWith(color: colors.expenseColor),
                  ),
                if (hasIncome)
                  Text(
                    '+${stats.income.format()}',
                    style: (hasExpense ? typo.captionBold : typo.rowTitle).copyWith(color: UIColorToken.blue),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------- map

class _TagMap extends StatelessWidget {
  const _TagMap({required this.graph, required this.onTap});

  final AsyncValue<TagGraphData> graph;
  final ValueChanged<TagStats> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final data = graph.value;

    if (data == null) {
      return const Center(
        child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (data.isEmpty) {
      return UiEmptyState(
        image: AppAssets.images.wumbiOo.path,
        title: l10n.tags_empty_title,
        subtitle: l10n.tags_graph_empty,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(kListHorzPadding, 4, kListHorzPadding, 8),
          child: Text(
            l10n.tags_graph_hint,
            textAlign: TextAlign.center,
            style: context.typo.inter.caption,
          ),
        ),
        Expanded(
          child: ClipRect(
            child: TagGraphView(data: data, onNodeTap: onTap),
          ),
        ),
      ],
    );
  }
}
