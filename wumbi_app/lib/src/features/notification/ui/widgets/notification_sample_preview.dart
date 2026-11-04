import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../settings/ui/state_management/settings_provider.dart';
import '../notification_copy.dart';
import '../notification_samples.dart';
import 'notification_preview_card.dart';

/// [NotificationPreviewCard] fed with real copy: tap to flip through the
/// sample situations (and the hamster's faces).
class NotificationSamplePreview extends HookConsumerWidget {
  const NotificationSamplePreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final base = ref.watch(baseCurrencyProvider);
    final samples = useMemoized(
      () => NotificationSamples.of(base, person: l10n.notif_sample_person),
      [base, l10n.localeName],
    );
    final index = useState(0);
    final message = samples[index.value % samples.length];
    final text = NotificationCopy.message(l10n, message);

    return UITap(
      onTap: () {
        AppVibrations.selection();
        index.value++;
      },
      child: NotificationPreviewCard(
        mood: message.mood,
        title: text.title,
        body: text.body,
        time: l10n.notif_preview_now,
      ),
    );
  }
}
