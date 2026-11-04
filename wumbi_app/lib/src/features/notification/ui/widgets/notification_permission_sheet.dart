import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import 'notification_sample_preview.dart';

/// The hamster asks before the system dialog does (a "no" to the system
/// dialog is final on iOS, a "not now" here is not). Resolves true for
/// "Sure", false / null otherwise.
abstract class NotificationPermissionSheet {
  static Future<bool> show(BuildContext context) async {
    final allow = await UIModalSheet.modalSheet<bool>(
      context: context,
      fitContent: true,
      child: const _Body(),
    );
    return allow ?? false;
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const UIWumbi(WumbiMood.kindly, height: 120),
          const UISpace.vert(12),
          Text(l10n.notif_ask_title, style: typo.title, textAlign: TextAlign.center),
          const UISpace.vert(8),
          Text(l10n.notif_ask_body, style: typo.paragraph, textAlign: TextAlign.center),
          const UISpace.vert(20),
          const NotificationSamplePreview(),
          const UISpace.vert(24),
          UiPrimaryButton(label: l10n.notif_ask_allow, onTap: () => Navigator.of(context).pop(true)),
          const UISpace.vert(8),
          UiTextButton(
            label: l10n.notif_ask_later,
            style: UiTextButtonStyle.secondary,
            fontSize: 16,
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
