import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/hooks/use_swipe_tabs.dart';
import '../data/models/tag_stats.dart';
import '../data/models/tag_tree.dart';
import 'tags_notifier.dart';
import 'widgets/tag_create_sheet.dart';
import 'widgets/tag_graph_view.dart';
import 'widgets/tag_visuals.dart';

enum _TagsView { list, map }

/// Tags hub (`/tags`): nested tag cards with search, or the money map.
@RoutePage()
class TagsPage extends HookConsumerWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final state = ref.watch(tagsProvider);
    final tabs = useSwipeTabs();
    final view = _TagsView.values[tabs.index];
    // The map pans / zooms horizontally too: once it has settled on screen
    // the pager stops taking drags (tap "List" to go back). Updated only at
    // scroll end so the physics never change mid-swipe.
    final mapSettled = useState(false);

    void openTag(TagStats tag) => context.router.push(TagDetailsRoute(tagId: tag.id));
    Future<void> create() => createTagFlow(context, ref);

    final hasTags = state.stats.value?.isNotEmpty ?? false;

    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: colors.bgColor)),
        if (view == _TagsView.map) const Positioned.fill(child: UiAmbientBackground(intensity: 0.7)),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: UIAppbar(
            title: l10n.tags_title,
            transparent: true,
            backTap: () => context.router.maybePop(),
            // Not `UIIcon`: it mirrors icons in Arabic, and a mirrored "?"
            // reads wrong.
            action: Semantics(
              button: true,
              label: l10n.tags_help,
              child: UITap(
                onTap: () => context.router.push(const TagsHelpRoute()),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: UIIconToken.toIcon(
                    UIIconToken.icons.general.helpCircle,
                    size: 22,
                    color: colors.contentColor,
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: view == _TagsView.list && hasTags ? UiFab(onTap: create, label: l10n.tags_new) : null,
          body: Column(
            children: [
              const UISpace.vert(4),
              UiSegmentedToggle(
                labels: [l10n.tags_view_list, l10n.tags_view_graph],
                selectedIndex: tabs.index,
                onChanged: tabs.onTabTap,
              ),
              const UISpace.vert(8),
              Expanded(
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: (n) {
                    // depth 0 = the pager itself, not the tag list inside it.
                    if (n.depth == 0) {
                      mapSettled.value = (tabs.controller.page ?? 0).round() == _TagsView.map.index;
                    }
                    return false;
                  },
                  child: PageView(
                    controller: tabs.controller,
                    onPageChanged: tabs.onPageChanged,
                    physics: mapSettled.value ? const NeverScrollableScrollPhysics() : null,
                    children: [
                      _TagList(
                        stats: state.stats,
                        tree: state.tree,
                        onTap: openTag,
                        onCreate: create,
                      ),
                      _TagMap(graph: state.graph, onOpen: openTag),
                    ],
                  ),
                ),
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
  const _TagList({required this.stats, required this.tree, required this.onTap, required this.onCreate});

  final AsyncValue<List<TagStats>> stats;
  final List<TagTreeNode> tree;
  final ValueChanged<TagStats> onTap;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = useState('');
    final collapsed = useState<Set<String>>(const {});
    final all = stats.value;

    void toggle(String id) {
      final next = Set<String>.of(collapsed.value);
      if (!next.remove(id)) next.add(id);
      collapsed.value = next;
    }

    if (all == null) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(kListHorzPadding, 24, kListHorzPadding, 0),
        child: UiSkeletonList(rows: 6),
      );
    }
    if (all.isEmpty) {
      return UiEmptyState(
        mood: WumbiMood.sleep,
        title: l10n.tags_empty_title,
        subtitle: l10n.tags_empty_subtitle,
        action: SizedBox(
          width: 200,
          child: UiPrimaryButton(label: l10n.tags_new, onTap: onCreate),
        ),
      );
    }

    final q = query.value.trim().toLowerCase().replaceFirst('#', '');
    final Widget body;
    if (q.isNotEmpty) {
      // Search: flat list, full paths, every level that matches.
      final rows = all.where((t) => t.tag.normalizedName.contains(q)).toList();
      body = rows.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(32),
              child: Text(l10n.tags_search_no_results, textAlign: TextAlign.center, style: context.typo.inter.hint),
            )
          : _scroll([
              for (final t in rows) _TagRow(stats: t, depth: 0, showPath: true, onTap: () => onTap(t)),
            ]);
    } else {
      body = _scroll([
        for (final node in TagTree.visible(tree, collapsed.value))
          _TagRow(
            stats: node.stats,
            depth: node.depth,
            nestedCount: node.descendantCount,
            collapsed: collapsed.value.contains(node.id),
            onToggle: node.hasChildren ? () => toggle(node.id) : null,
            onTap: () => onTap(node.stats),
          ),
      ]);
    }

    return Column(
      children: [
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

  /// Smoke edges like the dashboard tabs: rows dissolve under the search
  /// field instead of being cut.
  Widget _scroll(List<Widget> rows) {
    return UIScrollEdgeFade(
      child: ListView.separated(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(kListHorzPadding, 4, kListHorzPadding, 110),
        itemCount: rows.length,
        separatorBuilder: (_, _) => const UIDivider(),
        itemBuilder: (_, i) => rows[i],
      ),
    );
  }
}

/// Same anatomy as a transaction row: name + caption on the left, amounts
/// on the right. Nested tags are indented under their parent.
class _TagRow extends StatelessWidget {
  const _TagRow({
    required this.stats,
    required this.depth,
    required this.onTap,
    this.nestedCount = 0,
    this.collapsed = false,
    this.onToggle,
    this.showPath = false,
  });

  final TagStats stats;
  final int depth;
  final VoidCallback onTap;
  final int nestedCount;
  final bool collapsed;

  /// Null = no nested tags (no chevron).
  final VoidCallback? onToggle;

  /// Search results: full `food/coffee` path instead of the last level.
  final bool showPath;

  static const double _indent = 20;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    final isRoot = depth == 0;

    return UITap(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: (depth - 1).clamp(0, 8) * _indent, top: 14, bottom: 14),
        child: Row(
          children: [
            if (!isRoot) ...[
              _Elbow(color: colors.secondContentColor),
              const UISpace.horz(8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 3,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: TagPathText(
                          path: stats.tag.displayName,
                          showParents: showPath,
                          style: isRoot ? typo.rowTitle : typo.listTitle,
                        ),
                      ),
                      if (nestedCount > 0) ...[
                        const UISpace.horz(6),
                        TagCountPill(label: l10n.tags_nested_count(nestedCount)),
                      ],
                    ],
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
            TagAmounts(stats: stats, compact: !isRoot),
            if (onToggle != null)
              UITap(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 0, 10),
                  child: AnimatedRotation(
                    turns: collapsed ? -0.25 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: UIIcon(UIIconToken.icons.arrows.chevronDown, size: 18, color: colors.secondContentColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// `└` connector in front of a nested tag.
class _Elbow extends StatelessWidget {
  const _Elbow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 24,
      child: CustomPaint(painter: _ElbowPainter(color.withValues(alpha: 0.7))),
    );
  }
}

class _ElbowPainter extends CustomPainter {
  _ElbowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(1, 0)
      ..lineTo(1, size.height / 2 - 4)
      ..quadraticBezierTo(1, size.height / 2, 5, size.height / 2)
      ..lineTo(size.width, size.height / 2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ElbowPainter old) => old.color != color;
}

// ---------------------------------------------------------------------- map

class _TagMap extends StatelessWidget {
  const _TagMap({required this.graph, required this.onOpen});

  final AsyncValue<TagGraphData> graph;
  final ValueChanged<TagStats> onOpen;

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
        mood: WumbiMood.sleep,
        title: l10n.tags_empty_title,
        subtitle: l10n.tags_graph_empty,
      );
    }
    return TagGraphView(data: data, onOpen: onOpen);
  }
}
