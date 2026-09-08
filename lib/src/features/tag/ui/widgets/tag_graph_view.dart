import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../data/models/tag_stats.dart';

/// Obsidian-style tag map: a force-directed graph on a pannable / zoomable
/// canvas. Bigger circles moved more money; lines connect tags that were
/// used on the same transaction.
///
/// Gestures: pinch / drag on the canvas (InteractiveViewer), tap a node to
/// open it, long-press a node and drag to move it.
class TagGraphView extends HookWidget {
  const TagGraphView({super.key, required this.data, required this.onNodeTap});

  final TagGraphData data;
  final ValueChanged<TagStats> onNodeTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    // Keep the previous layout as the seed so a data refresh (new totals
    // after a save) does not scatter the nodes again.
    final previous = useRef<TagGraphSimulation?>(null);
    final sim = useMemoized(() {
      final s = TagGraphSimulation(data, seed: previous.value);
      previous.value = s;
      return s;
    }, [data]);

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

    void wake() {
      sim.wake();
      if (!controller.isAnimating) controller.repeat();
    }

    final dragged = useRef<TagGraphNode?>(null);

    void release() {
      final node = dragged.value;
      if (node == null) return;
      node.pinned = false;
      node.velocity = Offset.zero;
      dragged.value = null;
      wake();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final center = Offset(size.width / 2, size.height / 2);

        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(double.infinity),
          minScale: 0.4,
          maxScale: 3,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                final node = sim.hitTest(details.localPosition - center);
                if (node != null) onNodeTap(node.stats);
              },
              onLongPressStart: (details) {
                final node = sim.hitTest(details.localPosition - center);
                if (node == null) return;
                AppVibrations.light();
                node.pinned = true;
                node.velocity = Offset.zero;
                dragged.value = node;
                wake();
              },
              onLongPressMoveUpdate: (details) {
                final node = dragged.value;
                if (node == null) return;
                node.position = details.localPosition - center;
                wake();
              },
              onLongPressEnd: (_) => release(),
              onLongPressCancel: release,
              child: CustomPaint(
                painter: TagGraphPainter(sim: sim, theme: theme, repaint: controller),
                size: size,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- simulation

class TagGraphNode {
  TagGraphNode({
    required this.stats,
    required this.radius,
    required this.color,
    required this.position,
  });

  final TagStats stats;
  final double radius;
  final Color color;
  Offset position;
  Offset velocity = Offset.zero;

  /// Held by the user's finger — forces do not move it.
  bool pinned = false;

  String get id => stats.id;
  String get label => '#${stats.name}';
}

class TagGraphEdge {
  const TagGraphEdge({required this.a, required this.b, required this.weight});

  /// Indices into [TagGraphSimulation.nodes].
  final int a;
  final int b;

  /// count / max count, 0..1.
  final double weight;
}

/// Force-directed layout in graph space (origin = canvas centre, px units):
/// pairwise repulsion, springs along co-occurrence links (stronger and
/// shorter for higher counts), a weak pull to the centre, velocity damping.
class TagGraphSimulation {
  TagGraphSimulation(this.data, {TagGraphSimulation? seed}) {
    _init(seed);
  }

  final TagGraphData data;
  final List<TagGraphNode> nodes = [];
  final List<TagGraphEdge> edges = [];

  static const double minRadius = 14;
  static const double maxExtraRadius = 22;

  static const double _kRepulsion = 140;
  static const double _kCollide = 0.25;
  static const double _kSpring = 0.012;
  static const double _kCenter = 0.0035;
  static const double _damping = 0.82;
  static const double _maxSpeed = 14;
  static const double _settleSpeed = 0.03;
  static const int _minIterations = 40;
  static const int _maxIterations = 900;

  int _iterations = 0;
  bool _settled = false;

  bool get settled => _settled;

  void _init(TagGraphSimulation? seed) {
    final seedPositions = <String, Offset>{
      if (seed != null)
        for (final n in seed.nodes) n.id: n.position,
    };

    var maxVolume = 0;
    for (final s in data.nodes) {
      if (s.volumeMinor > maxVolume) maxVolume = s.volumeMinor;
    }

    const goldenAngle = 2.399963229728653;
    final indexOf = <String, int>{};
    for (var i = 0; i < data.nodes.length; i++) {
      final s = data.nodes[i];
      final ratio = maxVolume == 0 ? 0.0 : s.volumeMinor / maxVolume;
      final radius = minRadius + maxExtraRadius * math.sqrt(ratio);
      // Sunflower spiral: the biggest (first) nodes start near the centre.
      final angle = i * goldenAngle;
      final dist = 38 * math.sqrt(i.toDouble());
      final start = seedPositions[s.id] ?? Offset(math.cos(angle) * dist, math.sin(angle) * dist);
      indexOf[s.id] = nodes.length;
      nodes.add(
        TagGraphNode(
          stats: s,
          radius: radius,
          color: colorFor(s.tag.normalizedName),
          position: start,
        ),
      );
    }

    var maxCount = 1;
    for (final l in data.links) {
      if (l.count > maxCount) maxCount = l.count;
    }
    for (final l in data.links) {
      final a = indexOf[l.a];
      final b = indexOf[l.b];
      if (a == null || b == null || a == b) continue;
      edges.add(TagGraphEdge(a: a, b: b, weight: l.count / maxCount));
    }
  }

  /// Splash palette — vivid, flat swatches. Deliberately wider than
  /// `UIColorToken` so neighbouring bubbles never read as the same colour.
  static const List<Color> palette = [
    Color(0xffFF5E5B), // coral
    Color(0xffFF9F1C), // tangerine
    Color(0xffFFD166), // saffron
    Color(0xffB8E062), // sprout
    Color(0xff3DD68C), // mint
    Color(0xff00C2A8), // teal
    Color(0xff21B4E8), // sky
    Color(0xff4C6FFF), // cobalt
    Color(0xff7B61FF), // indigo
    Color(0xffB15CFF), // amethyst
    Color(0xffE45CC4), // orchid
    Color(0xffFF6FA5), // rose
    Color(0xffF7735A), // salmon
    Color(0xffD9A441), // ochre
    Color(0xff5FB37A), // moss
    Color(0xff2E8FA6), // lagoon
    Color(0xff8C7CFF), // periwinkle
    Color(0xffFF8A3D), // amber splash
  ];

  /// Stable, fully opaque splash colour from the tag name.
  static Color colorFor(String name) {
    var h = 5381;
    for (final c in name.codeUnits) {
      h = ((h << 5) + h + c) & 0x7fffffff;
    }
    return palette[h % palette.length];
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
        final minDist = ni.radius + nj.radius + 10;
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
      final rest = na.radius + nb.radius + 28 + 90 * (1 - e.weight);
      final f = dir * ((dist - rest) * _kSpring * (0.35 + 0.65 * e.weight));
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

  /// Topmost node under [point] (graph coordinates), if any.
  TagGraphNode? hitTest(Offset point) {
    for (var i = nodes.length - 1; i >= 0; i--) {
      final node = nodes[i];
      final r = math.max(node.radius, 18.0);
      if ((node.position - point).distanceSquared <= r * r) return node;
    }
    return null;
  }
}

// ------------------------------------------------------------------ painter

class TagGraphPainter extends CustomPainter {
  TagGraphPainter({required this.sim, required this.theme, super.repaint});

  final TagGraphSimulation sim;
  final AppThemeData theme;

  /// Label drawn inside the circle from this radius on; smaller nodes get it
  /// underneath.
  static const double _insideLabelRadius = 26;

  /// Net amount shown from this radius on.
  static const double _amountRadius = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = theme.colors;
    final typo = theme.typo.inter;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    // Edges — hairlines. Width and alpha still grow with the co-occurrence
    // count, but stay thin so the bubbles carry the composition.
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final e in sim.edges) {
      final a = sim.nodes[e.a];
      final b = sim.nodes[e.b];
      edgePaint
        ..color = colors.secondContentColor.withValues(alpha: 0.14 + 0.34 * e.weight)
        ..strokeWidth = 0.5 + 0.7 * e.weight;
      canvas.drawLine(a.position, b.position, edgePaint);
    }

    // Nodes (most-moved first, so the small ones end up on top).
    final fill = Paint()..style = PaintingStyle.fill;
    final glow = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final node in sim.nodes) {
      final r = node.radius;
      final p = node.position;
      final base = node.color;

      // Coloured bloom around the bubble — the only lighting, kept outside.
      glow.color = base.withValues(alpha: colors.isDark ? 0.40 : 0.26);
      canvas.drawCircle(p, r * 1.08, glow);

      // Flat splash fill.
      fill.color = base;
      canvas.drawCircle(p, r, fill);

      // Crisp edge, same hue, one notch brighter.
      ring.color = _lighten(base, 0.14).withValues(alpha: 0.75);
      canvas.drawCircle(p, r - 0.5, ring);

      final showAmount = r >= _amountRadius;
      final amount = showAmount ? node.stats.net.format(signed: true, positiveSign: true) : null;

      if (r >= _insideLabelRadius) {
        final labelSize = (r * 0.4).clamp(10.0, 14.0).toDouble();
        final amountSize = (r * 0.3).clamp(8.0, 11.0).toDouble();
        final labelDy = amount == null ? 0.0 : -amountSize * 0.7;
        // Light splashes (saffron, sprout…) need ink, not white.
        final onBubble =
            base.computeLuminance() > 0.5 ? UIColorToken.neu700 : UIColorToken.white;
        _text(
          canvas,
          node.label,
          style: typo.bold.copyWith(fontSize: labelSize, color: onBubble),
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
          style: typo.caption.copyWith(color: colors.contentColor),
          center: p.translate(0, r + 10),
          maxWidth: 120,
        );
        if (amount != null) {
          _text(
            canvas,
            amount,
            style: typo.caption.copyWith(fontSize: 10),
            center: p.translate(0, r + 23),
            maxWidth: 120,
          );
        }
      }
    }

    canvas.restore();
  }

  static Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

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
  bool shouldRepaint(TagGraphPainter old) => old.sim != sim || old.theme != theme;
}
