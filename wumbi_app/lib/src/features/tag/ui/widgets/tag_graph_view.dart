import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../data/models/tag_stats.dart';
import '../../data/tag_normalizer.dart';
import 'tag_visuals.dart';

/// What sizes the bubbles.
enum TagGraphMode { all, spending, income }

/// Obsidian-style money map: a force-directed graph on a pannable /
/// zoomable canvas.
///
/// * size = money moved (all / spending only / income only),
/// * ring = share of spending vs income,
/// * solid coloured lines = parent → nested tag, faint lines = tags used on
///   the same transaction,
/// * a family (a tag and its nested tags) shares one hue.
///
/// Tap a bubble to select it (its links light up, the rest fades, a card
/// shows its numbers); tap it again or the card to open it; tap the canvas
/// to clear. Long-press and drag moves a bubble.
class TagGraphView extends HookWidget {
  const TagGraphView({super.key, required this.data, required this.onOpen});

  final TagGraphData data;
  final ValueChanged<TagStats> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.appTheme;
    final mode = useState(TagGraphMode.all);
    final selectedId = useState<String?>(null);

    // Keep the previous layout as the seed so a data refresh / mode switch
    // does not scatter the nodes again.
    final previous = useRef<TagGraphSimulation?>(null);
    final sim = useMemoized(() {
      final s = TagGraphSimulation(data, mode: mode.value, seed: previous.value);
      previous.value = s;
      return s;
    }, [data, mode.value]);

    // Selection survives a refresh only while the tag still exists.
    final selected = selectedId.value == null ? null : sim.nodeById(selectedId.value!);

    // One simulation step per frame until the graph settles; the painter
    // listens to the same controller so it repaints exactly once per step.
    final controller = useAnimationController(duration: const Duration(seconds: 1));
    useEffect(() {
      void tick() {
        sim.step();
        if (sim.settled) controller.stop();
      }

      controller.addListener(tick);
      controller.repeat();
      return () => controller.removeListener(tick);
    }, [sim, controller]);

    final transform = useMemoized(TransformationController.new);
    useEffect(() => transform.dispose, [transform]);

    void wake() {
      sim.wake();
      if (!controller.isAnimating) controller.repeat();
    }

    // ---- gestures --------------------------------------------------------
    // Taps are read from raw pointer events: a GestureDetector tap inside an
    // InteractiveViewer loses the arena to the viewer's pan / scale
    // recognisers as soon as the finger drifts a pixel, which made bubbles
    // "unclickable" now and then.
    final pointers = useRef(0);
    final down = useRef<(Offset, Duration)?>(null);
    final dragged = useRef<TagGraphNode?>(null);

    void release() {
      final node = dragged.value;
      if (node == null) return;
      node.pinned = false;
      node.velocity = Offset.zero;
      dragged.value = null;
      wake();
    }

    void handleTap(Offset graphPoint) {
      final node = sim.hitTest(graphPoint);
      if (node == null) {
        selectedId.value = null;
        return;
      }
      if (selectedId.value == node.id) {
        onOpen(node.stats);
        return;
      }
      AppVibrations.selection();
      selectedId.value = node.id;
    }

    // The canvas fills the whole area; the mode switch and the legend /
    // info card float on top, and the canvas dissolves ("smoke") under
    // them while you drag it — same feel as the dashboard tabs.
    const topFade = 64.0;
    final bottomFade = selected == null ? 110.0 : 210.0;

    return Stack(
      children: [
        Positioned.fill(
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) {
              final h = rect.height <= 0 ? 1.0 : rect.height;
              final top = (topFade / h).clamp(0.0, 0.45).toDouble();
              final bottom = (1 - bottomFade / h).clamp(0.55, 1.0).toDouble();
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [Color(0x00000000), Color(0xFF000000), Color(0xFF000000), Color(0x00000000)],
                stops: [0, top, bottom, 1],
              ).createShader(rect);
            },
            child: ClipRect(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  final center = Offset(size.width / 2, size.height / 2);

                  // Gestures sit *around* the viewer and map points through its
                  // transform, so bubbles panned / zoomed outside the original
                  // canvas rectangle stay tappable.
                  Offset toGraph(Offset viewportPoint) => transform.toScene(viewportPoint) - center;

                  return Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (e) {
                      pointers.value++;
                      down.value = pointers.value == 1 ? (e.localPosition, e.timeStamp) : null;
                    },
                    onPointerMove: (e) {
                      final start = down.value;
                      if (start != null && (e.localPosition - start.$1).distance > 14) down.value = null;
                    },
                    onPointerUp: (e) {
                      pointers.value = math.max(0, pointers.value - 1);
                      final start = down.value;
                      down.value = null;
                      if (start == null || dragged.value != null) return;
                      if (e.timeStamp - start.$2 > const Duration(milliseconds: 450)) return;
                      handleTap(toGraph(e.localPosition));
                    },
                    onPointerCancel: (_) {
                      pointers.value = math.max(0, pointers.value - 1);
                      down.value = null;
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPressStart: (details) {
                        final node = sim.hitTest(toGraph(details.localPosition));
                        if (node == null) return;
                        AppVibrations.light();
                        node.pinned = true;
                        node.velocity = Offset.zero;
                        dragged.value = node;
                        selectedId.value = node.id;
                        wake();
                      },
                      onLongPressMoveUpdate: (details) {
                        final node = dragged.value;
                        if (node == null) return;
                        node.position = toGraph(details.localPosition);
                        wake();
                      },
                      onLongPressEnd: (_) => release(),
                      onLongPressCancel: release,
                      child: InteractiveViewer(
                        transformationController: transform,
                        boundaryMargin: const EdgeInsets.all(double.infinity),
                        minScale: 0.35,
                        maxScale: 3.5,
                        child: SizedBox(
                          width: size.width,
                          height: size.height,
                          child: CustomPaint(
                            painter: TagGraphPainter(
                              sim: sim,
                              theme: theme,
                              mode: mode.value,
                              selectedId: selected?.id,
                              repaint: controller,
                            ),
                            size: size,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 12,
          right: 12,
          child: Row(
            children: [
              const SizedBox(width: 36),
              Expanded(
                child: UiSegmentedToggle(
                  labels: [l10n.tags_graph_mode_all, l10n.tags_graph_mode_spending, l10n.tags_graph_mode_income],
                  selectedIndex: mode.value.index,
                  onChanged: (i) => mode.value = TagGraphMode.values[i],
                ),
              ),
              SizedBox(
                width: 36,
                child: UIIcon(
                  UIIconToken.icons.general.target02,
                  size: 20,
                  color: theme.colors.secondContentColor,
                  onTap: () {
                    transform.value = Matrix4.identity();
                    wake();
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOut,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: selected == null
                ? UISpace.zero()
                : _NodeCard(
                    key: ValueKey(selected.id),
                    node: selected,
                    links: sim.neighbourCount(selected),
                    onOpen: () => onOpen(selected.stats),
                    onClose: () => selectedId.value = null,
                  ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- overlays

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;

    Widget item(Widget icon, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [icon, Text(label, style: typo.caption)],
        );

    Widget line({required Color color, required double width}) => Container(
          width: 18,
          height: width,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(width)),
        );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 6,
              children: [
                item(
                  SizedBox(width: 14, height: 14, child: CustomPaint(painter: _RingIconPainter(colors.expenseColor))),
                  '${l10n.tags_spent} · ${l10n.tags_earned}',
                ),
                item(
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: colors.secondContentColor.withValues(alpha: 0.5), shape: BoxShape.circle),
                  ),
                  l10n.tags_graph_legend_size,
                ),
                item(line(color: colors.secondContentColor.withValues(alpha: 0.8), width: 2), l10n.tags_graph_legend_nested),
                item(line(color: colors.secondContentColor.withValues(alpha: 0.5), width: 1), l10n.tags_graph_legend_together),
              ],
            ),
            const UISpace.vert(8),
            Text(l10n.tags_graph_tap_hint, textAlign: TextAlign.center, style: typo.caption.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _RingIconPainter extends CustomPainter {
  _RingIconPainter(this.expense);

  final Color expense;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.butt;
    final r = rect.deflate(1.5);
    p.color = expense;
    canvas.drawArc(r, -math.pi / 2, math.pi * 1.2, false, p);
    p.color = UIColorToken.blue;
    canvas.drawArc(r, -math.pi / 2 + math.pi * 1.2, math.pi * 0.8, false, p);
  }

  @override
  bool shouldRepaint(_RingIconPainter old) => old.expense != expense;
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({super.key, required this.node, required this.links, required this.onOpen, required this.onClose});

  final TagGraphNode node;
  final int links;
  final VoidCallback onOpen;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    final s = node.stats;
    final net = s.net;

    Widget stat(String label, String value, Color color) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(label.toUpperCase(), maxLines: 1, style: typo.sectionLabel),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(value, maxLines: 1, style: typo.listTitle.copyWith(color: color)),
              ),
            ],
          ),
        );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        child: GestureDetector(
          onTap: onOpen,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 14),
            decoration: BoxDecoration(
              color: colors.fgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.dividerColor),
              boxShadow: UIShadowToken.dropShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          TagPathText(path: s.tag.displayName, style: typo.rowTitle),
                          Text(
                            '${l10n.tags_usage(s.transactionCount)} · ${l10n.tags_graph_linked(links)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typo.caption,
                          ),
                        ],
                      ),
                    ),
                    UITap(
                      onTap: onOpen,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: UIColorToken.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(l10n.tags_graph_open, style: typo.label.copyWith(color: UIColorToken.white)),
                      ),
                    ),
                    UIIcon(UIIconToken.icons.general.xClose, size: 20, color: colors.secondContentColor, onTap: onClose),
                  ],
                ),
                const UISpace.vert(12),
                Row(
                  spacing: 8,
                  children: [
                    stat(l10n.tags_spent, '-${s.expense.format()}', colors.expenseColor),
                    stat(l10n.tags_earned, '+${s.income.format()}', UIColorToken.blue),
                    stat(
                      l10n.tags_net,
                      net.format(signed: true, positiveSign: true),
                      net.isNegative ? colors.expenseColor : (net.isPositive ? UIColorToken.blue : colors.contentColor),
                    ),
                  ],
                ),
                if (s.volumeMinor > 0) ...[
                  const UISpace.vert(10),
                  TagFlowBar(stats: s),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- simulation

class TagGraphNode {
  TagGraphNode({
    required this.stats,
    required this.radius,
    required this.position,
    required this.active,
  });

  final TagStats stats;
  final double radius;
  Offset position;
  Offset velocity = Offset.zero;

  /// False when the current mode's metric is zero (e.g. an expense-only tag
  /// in Income mode) — drawn small and faded.
  final bool active;

  /// Held by the user's finger — forces do not move it.
  bool pinned = false;

  String get id => stats.id;
  String get label => '#${stats.tag.leafName}';

  /// 0..1 share of the money that was spending.
  double get expenseShare {
    final v = stats.volumeMinor;
    return v <= 0 ? 0 : stats.expense.minor / v;
  }
}

enum TagEdgeKind { nested, together }

class TagGraphEdge {
  const TagGraphEdge({required this.a, required this.b, required this.weight, required this.kind});

  /// Indices into [TagGraphSimulation.nodes]. For [TagEdgeKind.nested], [a]
  /// is the parent.
  final int a;
  final int b;

  /// together: count / max count, 0..1; nested: 1.
  final double weight;
  final TagEdgeKind kind;
}

/// Force-directed layout in graph space (origin = canvas centre, px units):
/// pairwise repulsion, springs along links (nested links short and stiff so
/// families cluster; co-occurrence links stronger and shorter for higher
/// counts), a weak pull to the centre, velocity damping.
class TagGraphSimulation {
  TagGraphSimulation(this.data, {this.mode = TagGraphMode.all, TagGraphSimulation? seed}) {
    _init(seed);
  }

  final TagGraphData data;
  final TagGraphMode mode;
  final List<TagGraphNode> nodes = [];
  final List<TagGraphEdge> edges = [];
  final Map<String, int> _indexOf = {};
  final Map<int, Set<int>> _neighbours = {};

  static const double minRadius = 13;
  static const double inactiveRadius = 9;
  static const double maxExtraRadius = 24;

  static const double _kRepulsion = 150;
  static const double _kCollide = 0.25;
  static const double _kSpring = 0.012;
  static const double _kNestedSpring = 0.03;
  static const double _kCenter = 0.0035;
  static const double _damping = 0.82;
  static const double _maxSpeed = 14;
  static const double _settleSpeed = 0.03;
  static const int _minIterations = 40;
  static const int _maxIterations = 900;

  int _iterations = 0;
  bool _settled = false;

  bool get settled => _settled;

  int _metric(TagStats s) => switch (mode) {
        TagGraphMode.all => s.volumeMinor,
        TagGraphMode.spending => s.expense.minor,
        TagGraphMode.income => s.income.minor,
      };

  void _init(TagGraphSimulation? seed) {
    final seedPositions = <String, Offset>{
      if (seed != null)
        for (final n in seed.nodes) n.id: n.position,
    };

    var maxMetric = 0;
    for (final s in data.nodes) {
      final m = _metric(s);
      if (m > maxMetric) maxMetric = m;
    }

    const goldenAngle = 2.399963229728653;
    for (var i = 0; i < data.nodes.length; i++) {
      final s = data.nodes[i];
      final m = _metric(s);
      final active = m > 0 || maxMetric == 0;
      final ratio = maxMetric == 0 ? 0.0 : m / maxMetric;
      final radius = active ? minRadius + maxExtraRadius * math.sqrt(ratio) : inactiveRadius;
      // Sunflower spiral: the biggest (first) nodes start near the centre.
      final angle = i * goldenAngle;
      final dist = 38 * math.sqrt(i.toDouble());
      final start = seedPositions[s.id] ?? Offset(math.cos(angle) * dist, math.sin(angle) * dist);
      _indexOf[s.id] = nodes.length;
      nodes.add(
        TagGraphNode(
          stats: s,
          radius: radius,
          position: start,
          active: active,
        ),
      );
    }

    // Parent → nested tag (nearest ancestor present on the map).
    final byName = <String, int>{
      for (var i = 0; i < nodes.length; i++) nodes[i].stats.tag.normalizedName: i,
    };
    for (var i = 0; i < nodes.length; i++) {
      var path = TagNormalizer.parentOf(nodes[i].stats.tag.normalizedName);
      while (path != null) {
        final p = byName[path];
        if (p != null) {
          _addEdge(TagGraphEdge(a: p, b: i, weight: 1, kind: TagEdgeKind.nested));
          break;
        }
        path = TagNormalizer.parentOf(path);
      }
    }

    // Used on the same transaction — a parent / nested pair is already
    // linked above.
    var maxCount = 1;
    for (final l in data.links) {
      if (l.count > maxCount) maxCount = l.count;
    }
    for (final l in data.links) {
      final a = _indexOf[l.a];
      final b = _indexOf[l.b];
      if (a == null || b == null || a == b) continue;
      final na = nodes[a].stats.tag.normalizedName;
      final nb = nodes[b].stats.tag.normalizedName;
      if (TagNormalizer.isDescendant(na, nb) || TagNormalizer.isDescendant(nb, na)) continue;
      _addEdge(TagGraphEdge(a: a, b: b, weight: l.count / maxCount, kind: TagEdgeKind.together));
    }
  }

  void _addEdge(TagGraphEdge e) {
    edges.add(e);
    _neighbours.putIfAbsent(e.a, () => {}).add(e.b);
    _neighbours.putIfAbsent(e.b, () => {}).add(e.a);
  }

  TagGraphNode? nodeById(String id) {
    final i = _indexOf[id];
    return i == null ? null : nodes[i];
  }

  int neighbourCount(TagGraphNode node) => _neighbours[_indexOf[node.id]]?.length ?? 0;

  /// The node itself and everything linked to it (selection highlight).
  Set<int> focusSet(String id) {
    final i = _indexOf[id];
    if (i == null) return const {};
    return {i, ...?_neighbours[i]};
  }

  /// Restart the ticker loop after a user interaction.
  void wake() {
    _settled = false;
    _iterations = 0;
  }

  /// One integration step. No-op once settled.
  void step() {
    if (_settled) return;
    final n = nodes.length;
    if (n == 0) {
      _settled = true;
      return;
    }
    final forces = List<Offset>.filled(n, Offset.zero);

    // Repulsion + collision between every pair (n ≤ 200 → fine).
    for (var i = 0; i < n; i++) {
      final ni = nodes[i];
      for (var j = i + 1; j < n; j++) {
        final nj = nodes[j];
        var d = nj.position - ni.position;
        var dist = d.distance;
        if (dist < 0.5) {
          // Coincident nodes: nudge deterministically so they separate.
          d = Offset(math.cos(i + j * 0.7), math.sin(i - j * 0.7));
          dist = 1;
        }
        final dir = d / dist;
        final safeDist = math.max(dist, 8.0);
        final rep = _kRepulsion * (ni.radius + nj.radius) / (safeDist * safeDist);
        var push = rep;
        final minDist = ni.radius + nj.radius + 14;
        if (dist < minDist) push += (minDist - dist) * _kCollide;
        final f = dir * push;
        forces[i] -= f;
        forces[j] += f;
      }
    }

    // Springs along links.
    for (final e in edges) {
      final na = nodes[e.a];
      final nb = nodes[e.b];
      final d = nb.position - na.position;
      final dist = math.max(d.distance, 1.0);
      final dir = d / dist;
      final double rest;
      final double k;
      if (e.kind == TagEdgeKind.nested) {
        rest = na.radius + nb.radius + 26;
        k = _kNestedSpring;
      } else {
        rest = na.radius + nb.radius + 34 + 90 * (1 - e.weight);
        k = _kSpring * (0.35 + 0.65 * e.weight);
      }
      final f = dir * ((dist - rest) * k);
      forces[e.a] += f;
      forces[e.b] -= f;
    }

    // Weak pull to the centre + integration.
    var maxSpeed = 0.0;
    var anyPinned = false;
    for (var i = 0; i < n; i++) {
      final node = nodes[i];
      if (node.pinned) {
        anyPinned = true;
        node.velocity = Offset.zero;
        continue;
      }
      final f = forces[i] - node.position * _kCenter;
      var v = (node.velocity + f) * _damping;
      final speed = v.distance;
      if (speed > _maxSpeed) v = v / speed * _maxSpeed;
      node.velocity = v;
      node.position += v;
      if (speed > maxSpeed) maxSpeed = speed;
    }

    _iterations++;
    if (anyPinned) return;
    if ((_iterations >= _minIterations && maxSpeed < _settleSpeed) || _iterations >= _maxIterations) {
      _settled = true;
    }
  }

  /// Node closest to [point] (graph coordinates) within a generous touch
  /// target: the bubble plus a margin, and the label under small bubbles.
  TagGraphNode? hitTest(Offset point) {
    TagGraphNode? best;
    var bestScore = double.infinity;
    for (final node in nodes) {
      final d = node.position - point;
      final dist = d.distance;
      final reach = math.max(node.radius + 10, 26.0);
      var score = double.infinity;
      if (dist <= reach) score = dist - node.radius;
      // Label below a small bubble.
      if (node.radius < TagGraphPainter.insideLabelRadius &&
          point.dy >= node.position.dy &&
          point.dy <= node.position.dy + node.radius + 32 &&
          (point.dx - node.position.dx).abs() <= 52) {
        score = math.min(score, (point.dy - node.position.dy - node.radius).abs());
      }
      if (score < bestScore) {
        bestScore = score;
        best = node;
      }
    }
    return best;
  }
}

// ------------------------------------------------------------------ painter

class TagGraphPainter extends CustomPainter {
  TagGraphPainter({
    required this.sim,
    required this.theme,
    required this.mode,
    this.selectedId,
    super.repaint,
  }) : _focus = selectedId == null ? null : sim.focusSet(selectedId);

  final TagGraphSimulation sim;
  final AppThemeData theme;
  final TagGraphMode mode;
  final String? selectedId;
  final Set<int>? _focus;

  /// Label drawn inside the circle from this radius on; smaller nodes get it
  /// underneath.
  static const double insideLabelRadius = 26;

  /// Net amount shown from this radius on.
  static const double _amountRadius = 24;

  bool _dim(int i) => _focus != null && !_focus.contains(i);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = theme.colors;
    final typo = theme.typo.inter;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Co-occurrence edges first (hairlines), nested edges on top.
    for (final kind in TagEdgeKind.values.reversed) {
      for (final e in sim.edges) {
        if (e.kind != kind) continue;
        final a = sim.nodes[e.a];
        final b = sim.nodes[e.b];
        final faded = _dim(e.a) || _dim(e.b);
        final lit = _focus != null && !faded;
        if (kind == TagEdgeKind.nested) {
          edgePaint
            ..color = (lit ? UIColorToken.blue : colors.secondContentColor)
                .withValues(alpha: faded ? 0.12 : (lit ? 0.9 : 0.75))
            ..strokeWidth = lit ? 2.2 : 1.6;
        } else {
          edgePaint
            ..color = (lit ? UIColorToken.blue : colors.secondContentColor)
                .withValues(alpha: faded ? 0.06 : (lit ? 0.6 : 0.18 + 0.30 * e.weight))
            ..strokeWidth = (lit ? 1.2 : 0.5) + 0.8 * e.weight;
        }
        canvas.drawLine(a.position, b.position, edgePaint);
      }
    }

    final fill = Paint()..style = PaintingStyle.fill;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    final bg = colors.bgColor;

    // Edges are drawn first and every fill below is opaque (faded nodes are
    // blended with the background, not made transparent), so lines always
    // pass *behind* the bubbles.
    Color solid(Color c, double alpha) => Color.lerp(bg, c, alpha)!;

    // Biggest first so the small ones end up on top.
    for (var i = 0; i < sim.nodes.length; i++) {
      final node = sim.nodes[i];
      final r = node.radius;
      final p = node.position;
      final dim = _dim(i);
      final isSelected = node.id == selectedId;
      final alpha = dim ? 0.18 : (node.active ? 1.0 : 0.3);

      // Black = spending, blue = income: the mode's flow, or in "All" the
      // side that moved more money.
      final spending = switch (mode) {
        TagGraphMode.all => node.stats.expense.minor >= node.stats.income.minor,
        TagGraphMode.spending => true,
        TagGraphMode.income => false,
      };
      final base = node.active ? (spending ? colors.expenseColor : UIColorToken.blue) : colors.secondContentColor;

      fill.color = solid(base, alpha);
      canvas.drawCircle(p, r, fill);

      // "All": ring split into the spending (black) / income (blue) share.
      if (mode == TagGraphMode.all && node.stats.volumeMinor > 0) {
        final rect = Rect.fromCircle(center: p, radius: r + 3.5);
        ring.strokeWidth = r >= 20 ? 3 : 2.2;
        final share = node.expenseShare;
        const start = -math.pi / 2;
        if (share > 0) {
          ring.color = solid(colors.expenseColor, alpha);
          canvas.drawArc(rect, start, 2 * math.pi * share, false, ring);
        }
        if (share < 1) {
          ring.color = solid(UIColorToken.blue, alpha);
          canvas.drawArc(rect, start + 2 * math.pi * share, 2 * math.pi * (1 - share), false, ring);
        }
      }

      if (isSelected) {
        ring
          ..strokeWidth = 1.5
          ..color = UIColorToken.blue;
        canvas.drawCircle(p, r + 8, ring);
      }

      final amount = r >= _amountRadius && !dim ? _amountText(node) : null;
      final labelAlpha = dim ? 0.3 : 1.0;

      if (r >= insideLabelRadius) {
        final labelSize = (r * 0.4).clamp(10.0, 14.0).toDouble();
        final amountSize = (r * 0.3).clamp(8.0, 11.0).toDouble();
        final labelDy = amount == null ? 0.0 : -amountSize * 0.7;
        // Dark theme spending bubbles are near-white: ink, not white.
        final onBubble = fill.color.computeLuminance() > 0.5 ? UIColorToken.neu700 : UIColorToken.white;
        _text(
          canvas,
          node.label,
          style: typo.bold.copyWith(fontSize: labelSize, color: onBubble.withValues(alpha: labelAlpha)),
          center: p.translate(0, labelDy),
          maxWidth: 2 * r - 10,
        );
        if (amount != null) {
          _text(
            canvas,
            amount,
            style: typo.semiBold.copyWith(fontSize: amountSize, color: onBubble.withValues(alpha: 0.85)),
            center: p.translate(0, labelSize * 0.75),
            maxWidth: 2 * r - 8,
          );
        }
      } else {
        _text(
          canvas,
          node.label,
          style: typo.caption.copyWith(color: colors.contentColor.withValues(alpha: labelAlpha * (node.active ? 1 : 0.6))),
          center: p.translate(0, r + 12),
          maxWidth: 120,
        );
        if (amount != null) {
          _text(
            canvas,
            amount,
            style: typo.caption.copyWith(fontSize: 10),
            center: p.translate(0, r + 25),
            maxWidth: 120,
          );
        }
      }
    }

    canvas.restore();
  }

  String _amountText(TagGraphNode node) => switch (mode) {
        TagGraphMode.all => node.stats.net.format(signed: true, positiveSign: true),
        TagGraphMode.spending => '-${node.stats.expense.format()}',
        TagGraphMode.income => '+${node.stats.income.format()}',
      };

  static void _text(
    Canvas canvas,
    String text, {
    required TextStyle style,
    required Offset center,
    required double maxWidth,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: math.max(maxWidth, 12));
    painter.paint(canvas, Offset(center.dx - painter.width / 2, center.dy - painter.height / 2));
    painter.dispose();
  }

  @override
  bool shouldRepaint(TagGraphPainter old) =>
      old.sim != sim || old.theme != theme || old.mode != mode || old.selectedId != selectedId;
}
