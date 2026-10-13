import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../tag/ui/widgets/tag_visuals.dart';

/// `/settings/help/tags` — "How to use tags?": every rule of tags (nested
/// tags included) with a small live example under each one. Opened from
/// Settings › Need help? and from the help button on the Tags page.
@RoutePage()
class TagsHelpPage extends StatelessWidget {
  const TagsHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo.inter;

    // Localised sample names: food › coffee / groceries, travel, restaurant.
    final food = l10n.help_tags_ex_parent;
    final coffee = '$food/${l10n.help_tags_ex_child1}';
    final groceries = '$food/${l10n.help_tags_ex_child2}';
    final travel = l10n.help_tags_ex_travel;
    final restaurant = '$food/${l10n.help_tags_ex_restaurant}';

    final sections = <Widget>[
      _Section(
        step: 1,
        title: l10n.help_tags_add_title,
        body: l10n.help_tags_add_body,
        example: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Chip(path: l10n.help_tags_ex_child1),
            _Chip(path: travel),
            _Chip(path: l10n.help_tags_ex_restaurant),
          ],
        ),
      ),
      _Section(
        step: 2,
        title: l10n.help_tags_nested_title,
        body: l10n.help_tags_nested_body,
        example: _TreeExample(parent: food, children: [coffee, groceries]),
      ),
      _Section(
        step: 3,
        title: l10n.help_tags_parent_title,
        body: l10n.help_tags_parent_body,
        example: _SumExample(
          rows: [(coffee, '-20.00'), (groceries, '-80.00')],
          totalLabel: l10n.help_tags_example_total,
          total: '-100.00',
        ),
      ),
      _Section(
        step: 4,
        title: l10n.help_tags_multi_title,
        body: l10n.help_tags_multi_body,
        example: Row(
          children: [
            _Chip(path: travel),
            Expanded(
              child: Container(
                height: 1.5,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: context.colors.secondContentColor.withValues(alpha: 0.5),
              ),
            ),
            _Chip(path: restaurant),
          ],
        ),
      ),
      _Section(
        step: 5,
        title: l10n.help_tags_manage_title,
        body: l10n.help_tags_manage_body,
        example: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ActionPill(icon: UIIconToken.icons.general.plus, label: l10n.tags_new),
            _ActionPill(icon: UIIconToken.icons.general.edit02, label: l10n.tag_rename),
            _ActionPill(icon: UIIconToken.icons.arrows.cornerDownRight, label: l10n.tag_move),
            _ActionPill(icon: UIIconToken.icons.general.plusCircle, label: l10n.tag_add_nested),
          ],
        ),
      ),
      _Section(
        step: 6,
        title: l10n.help_tags_map_title,
        body: l10n.help_tags_map_body,
        example: SizedBox(
          height: 150,
          child: CustomPaint(
            painter: _MiniMapPainter(
              theme: context.appTheme,
              labels: [food, l10n.help_tags_ex_child1, l10n.help_tags_ex_child2, travel],
            ),
            size: Size.infinite,
          ),
        ),
      ),
      _Tips(
        title: l10n.help_tags_tips_title,
        tips: [l10n.help_tags_tip1, l10n.help_tags_tip2, l10n.help_tags_tip3],
      ),
    ];

    return Scaffold(
      appBar: UIAppbar(title: l10n.tags_title, backTap: () => context.router.maybePop()),
      body: UIStaggerScope(
        child: UIScrollEdgeFade(
          child: ListView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 56),
            children: [
              UIStaggerItem(
                index: 0,
                child: Column(
                  children: [
                    Text(
                      l10n.help_tags_title,
                      textAlign: TextAlign.center,
                      style: typo.headline.copyWith(fontSize: 24),
                    ),
                    const UISpace.vert(10),
                    Text(l10n.help_tags_intro, textAlign: TextAlign.center, style: typo.paragraph),
                    const UISpace.vert(24),
                  ],
                ),
              ),
              for (var i = 0; i < sections.length; i++)
                UIStaggerItem(
                  index: i + 1,
                  child: Padding(padding: const EdgeInsets.only(bottom: 12), child: sections[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- building

class _Section extends StatelessWidget {
  const _Section({required this.step, required this.title, required this.body, required this.example});

  final int step;
  final String title;
  final String body;
  final Widget example;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: colors.fgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: UIColorToken.blue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Text('$step', style: typo.bold.copyWith(fontSize: 13, color: UIColorToken.blue)),
              ),
              const UISpace.horz(10),
              Expanded(child: Text(title, style: typo.rowTitle)),
            ],
          ),
          const UISpace.vert(10),
          Text(body, style: typo.paragraph),
          const UISpace.vert(14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              color: colors.bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.help_tags_example.toUpperCase(), style: typo.sectionLabel),
                const UISpace.vert(10),
                example,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) => TagChip(path: path);
}

class _TreeExample extends StatelessWidget {
  const _TreeExample({required this.parent, required this.children});

  final String parent;
  final List<String> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        _Chip(path: parent),
        for (final c in children)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('└', style: context.typo.inter.bold.copyWith(color: context.colors.secondContentColor, fontSize: 16)),
                const UISpace.horz(8),
                _Chip(path: c),
              ],
            ),
          ),
      ],
    );
  }
}

class _SumExample extends StatelessWidget {
  const _SumExample({required this.rows, required this.totalLabel, required this.total});

  final List<(String, String)> rows;
  final String totalLabel;
  final String total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    return Column(
      spacing: 8,
      children: [
        for (final (path, amount) in rows)
          Row(
            children: [
              Expanded(child: TagPathText(path: path, style: typo.labelMedium)),
              Text(amount, style: typo.label.copyWith(color: colors.expenseColor)),
            ],
          ),
        Container(height: 1, color: colors.dividerColor),
        Row(
          children: [
            Expanded(child: Text(totalLabel, style: typo.label)),
            Text(total, style: typo.rowTitle.copyWith(color: colors.expenseColor)),
          ],
        ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.fgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          UIIcon(icon, size: 14, color: UIColorToken.blue),
          Text(label, style: context.typo.inter.labelMedium),
        ],
      ),
    );
  }
}

class _Tips extends StatelessWidget {
  const _Tips({required this.title, required this.tips});

  final String title;
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UIColorToken.blue.withValues(alpha: colors.isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(title, style: typo.rowTitle.copyWith(color: UIColorToken.blue)),
          for (final tip in tips)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: UIColorToken.blue, shape: BoxShape.circle),
                  ),
                ),
                const UISpace.horz(10),
                Expanded(child: Text(tip, style: typo.paragraph.copyWith(color: colors.contentColor))),
              ],
            ),
        ],
      ),
    );
  }
}

/// Static mini version of the tag map: a parent with two nested tags (solid
/// family lines) and a tag used together with one of them (faint line).
class _MiniMapPainter extends CustomPainter {
  _MiniMapPainter({
    required this.theme,
    required this.labels,
  });

  final AppThemeData theme;

  /// parent, child 1, child 2, other.
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = theme.colors;
    final w = size.width;
    final h = size.height;
    final parent = Offset(w * 0.32, h * 0.46);
    final c1 = Offset(w * 0.17, h * 0.2);
    final c2 = Offset(w * 0.2, h * 0.78);
    final other = Offset(w * 0.78, h * 0.42);

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    line
      ..color = colors.secondContentColor.withValues(alpha: 0.8)
      ..strokeWidth = 1.6;
    canvas.drawLine(parent, c1, line);
    canvas.drawLine(parent, c2, line);
    line
      ..color = colors.secondContentColor.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    canvas.drawLine(c1, other, line);

    void bubble(Offset p, double r, Color color, double expenseShare, String label) {
      canvas.drawCircle(p, r, Paint()..color = color);
      final rect = Rect.fromCircle(center: p, radius: r + 3.5);
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6;
      ring.color = colors.expenseColor.withValues(alpha: 0.8);
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * expenseShare, false, ring);
      ring.color = UIColorToken.blue;
      canvas.drawArc(rect, -math.pi / 2 + 2 * math.pi * expenseShare, 2 * math.pi * (1 - expenseShare), false, ring);
      final tp = TextPainter(
        text: TextSpan(text: '#$label', style: theme.typo.inter.caption.copyWith(color: colors.contentColor)),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: 96);
      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy + r + 6));
      tp.dispose();
    }

    // Black = mostly spending, blue = mostly income.
    bubble(parent, 24, colors.expenseColor, 0.85, labels[0]);
    bubble(c1, 12, colors.expenseColor, 1, labels[1]);
    bubble(c2, 15, colors.expenseColor, 0.7, labels[2]);
    bubble(other, 19, UIColorToken.blue, 0.35, labels[3]);
  }

  @override
  bool shouldRepaint(_MiniMapPainter old) => old.theme != theme || old.labels.join() != labels.join();
}
