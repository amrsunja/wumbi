import '../tag_normalizer.dart';
import 'tag_stats.dart';

/// One tag in the nested-tag tree (Obsidian style: `food` › `food/coffee`).
/// Stats are already rolled up — a parent's totals include its children.
class TagTreeNode {
  TagTreeNode(this.stats);

  final TagStats stats;
  final List<TagTreeNode> children = [];
  TagTreeNode? parent;

  String get id => stats.id;
  String get normalizedName => stats.tag.normalizedName;

  /// Distance from the top level (0 = root).
  int get depth => parent == null ? 0 : parent!.depth + 1;

  /// Top-level ancestor (itself for a root) — the family the tag belongs to,
  /// which picks its colour.
  TagTreeNode get root => parent == null ? this : parent!.root;

  bool get hasChildren => children.isNotEmpty;

  /// Every tag nested inside, at any depth.
  int get descendantCount => children.fold(0, (n, c) => n + 1 + c.descendantCount);

  /// Self + descendants, depth first.
  Iterable<TagTreeNode> get subtree sync* {
    yield this;
    for (final c in children) {
      yield* c.subtree;
    }
  }
}

abstract class TagTree {
  /// Builds the forest from flat [stats], keeping their order (most money
  /// moved first) inside every level. A tag whose parent row is missing
  /// hangs from its nearest existing ancestor, or becomes a root.
  static List<TagTreeNode> build(List<TagStats> stats) {
    final byName = <String, TagTreeNode>{
      for (final s in stats) s.tag.normalizedName: TagTreeNode(s),
    };
    final roots = <TagTreeNode>[];
    for (final s in stats) {
      final node = byName[s.tag.normalizedName]!;
      TagTreeNode? parent;
      var path = TagNormalizer.parentOf(s.tag.normalizedName);
      while (path != null && parent == null) {
        parent = byName[path];
        path = TagNormalizer.parentOf(path);
      }
      if (parent == null) {
        roots.add(node);
      } else {
        node.parent = parent;
        parent.children.add(node);
      }
    }
    return roots;
  }

  /// Visible rows: depth-first, skipping the children of [collapsed] ids.
  static List<TagTreeNode> visible(List<TagTreeNode> roots, Set<String> collapsed) {
    final out = <TagTreeNode>[];
    void walk(TagTreeNode n) {
      out.add(n);
      if (collapsed.contains(n.id)) return;
      for (final c in n.children) {
        walk(c);
      }
    }

    for (final r in roots) {
      walk(r);
    }
    return out;
  }
}
