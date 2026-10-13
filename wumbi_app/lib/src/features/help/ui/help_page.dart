import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/typedefs.dart';

/// `/settings/help` — "Need help?": a list of short guides. Each topic is a
/// nested page; add new ones to the `topics` list below.
@RoutePage()
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo.inter;

    final topics = <_HelpTopic>[
      _HelpTopic(
        icon: UIIconToken.icons.general.hash01,
        title: l10n.help_tags_title,
        subtitle: l10n.help_tags_subtitle,
        route: const TagsHelpRoute(),
      ),
    ];

    return Scaffold(
      appBar: UIAppbar(title: l10n.help_title, backTap: () => context.router.maybePop()),
      body: UIScrollEdgeFade(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 48),
          children: [
            Center(child: Image.asset(AppAssets.images.wumbiHello.path, height: 110)),
            const UISpace.vert(14),
            Text(l10n.help_subtitle, textAlign: TextAlign.center, style: typo.paragraph),
            const UISpace.vert(24),
            for (final t in topics) ...[
              _TopicCard(topic: t),
              const UISpace.vert(10),
            ],
          ],
        ),
      ),
    );
  }
}

class _HelpTopic {
  const _HelpTopic({required this.icon, required this.title, required this.subtitle, required this.route});

  final String icon;
  final String title;
  final String subtitle;
  final PageRouteInfo route;
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});

  final _HelpTopic topic;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    return Container(
      decoration: BoxDecoration(
        color: colors.fgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: UITap(
        onTap: () => context.router.push(topic.route),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: UIColorToken.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: UIIcon(topic.icon, size: 20, color: UIColorToken.blue),
              ),
              const UISpace.horz(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(topic.title, style: typo.rowTitle),
                    Text(topic.subtitle, style: typo.caption),
                  ],
                ),
              ),
              UIIcon(UIIconToken.icons.arrows.chevronRight, size: 18, color: colors.secondContentColor),
            ],
          ),
        ),
      ),
    );
  }
}
