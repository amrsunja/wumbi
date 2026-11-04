import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../mascot/data/mascot_repository.dart';
import '../notification_enable_flow.dart';
import '../notification_providers.dart';
import 'notification_permission_sheet.dart';

/// Invisible: once the user has a few entries (they get what Wumbi is for)
/// and notifications are still off, the hamster asks — once, ever. Drop it
/// anywhere in a screen that is shown often (the dashboard).
class NotificationAskOnce extends HookConsumerWidget {
  const NotificationAskOnce({super.key});

  /// Entries before asking: the first launch is too early to be convincing.
  static const int minRecords = 3;

  static const Duration delay = Duration(milliseconds: 1500);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asked = ref.watch(notificationPrefsProvider.select((p) => p.askedAt != null));
    final enabled = ref.watch(notificationsEnabledProvider);

    useEffect(() {
      if (asked || enabled) return null;
      var cancelled = false;
      Future(() async {
        await Future<void>.delayed(delay);
        if (cancelled || !context.mounted) return;
        final activity = await ref.read(mascotRepositoryProvider).activity();
        if (cancelled || !context.mounted || activity.recordCount < minRecords) return;
        // Only on top: never over a sheet or a pushed page.
        if (ModalRoute.of(context)?.isCurrent != true) return;
        final controller = ref.read(notificationsControllerProvider);
        await controller.markAsked();
        if (!context.mounted) return;
        final allow = await NotificationPermissionSheet.show(context);
        if (allow && context.mounted) await NotificationEnableFlow.run(context, ref);
      });
      return () => cancelled = true;
    }, [asked, enabled]);

    return const SizedBox.shrink();
  }
}
