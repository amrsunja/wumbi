import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';

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
        route: const TagsHelpRoute(),
      ),
    ];

    return Scaffold(
      appBar: UIAppbar(title: l10n.help_title, backTap: () => context.router.maybePop()),
      body: UIScrollEdgeFade(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 48),
          children: [
            const Center(child: UIWumbi(WumbiMood.kindly)),
            const UISpace.vert(14),
            Text(l10n.help_subtitle, textAlign: TextAlign.center, style: typo.paragraph),
            const UISpace.vert(24),
            for (final t in topics)
              UiSettingsTile(
                icon: t.icon,
                title: t.title,
                onTap: () => context.router.push(t.route),
              ),
          ],
        ),
      ),
    );
  }
}

class _HelpTopic {
  const _HelpTopic({required this.icon, required this.title, required this.route});

  final String icon;
  final String title;
  final PageRouteInfo route;
}
