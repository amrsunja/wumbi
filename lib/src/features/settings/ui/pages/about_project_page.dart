import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/typedefs.dart';

@RoutePage()
class AboutProjectPage extends ConsumerWidget {
  const AboutProjectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: UIAppbar(title: l10n.about, backTap: () => context.router.maybePop()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const UISpace.vert(32),
            Image.asset(AppAssets.images.wumbiHello.path, height: 140),
            const UISpace.vert(24),
            Text(
              kAppName,
              style: context.typo.inter.headline.copyWith(fontSize: 22),
            ),
            const UISpace.vert(12),
            Text(
              l10n.about_text,
              textAlign: TextAlign.center,
              style: context.typo.inter.paragraph,
            ),
            const UISpace.vert(24),
            UiIconTextButton(
              icon: UIIconToken.icons.communication.mail01,
              title: l10n.about_support,
              onTap: () => launchUrl(Uri.parse(kSupportUrl)),
            ),
          ],
        ),
      ),
    );
  }
}
