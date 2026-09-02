import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/design_system/app_ui.dart';
import '../core/utils/extensions/build_context_extensions.dart';
import '../core/utils/typedefs.dart';
import 'settings/ui/state_management/settings_provider.dart';

/// Runs the startup sequence (spec 6.5); minimum 600 ms so the GIF loop
/// does not flash. DB open failures: 3 automatic retries, then an alert.
@RoutePage()
class SplashPage extends HookConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = MediaQuery.sizeOf(context);
    final l10n = context.l10n;
    final initFailed = ref.watch(settingsProvider.select((s) => s.initFailed));

    Future<void> start() async {
      await Future.wait([
        Future<void>.delayed(const Duration(milliseconds: 600)),
        ref.read(settingsProvider.notifier).startUp(),
      ]);
    }

    useEffect(() {
      Future.microtask(start);
      return null;
    }, const []);

    useEffect(() {
      if (!initFailed) return null;
      Future.microtask(() async {
        if (!context.mounted) return;
        final choice = await UIAlertDialog.choose(
          context,
          title: l10n.error_open_db_title,
          message: l10n.error_open_db_message,
          actions: [
            UIDialogAction(label: l10n.common_retry, primary: true),
            UIDialogAction(label: l10n.error_reset_app, destructive: true),
          ],
        );
        if (!context.mounted) return;
        if (choice == 1) {
          // Never silently recreate the DB — only on explicit user request.
          final done = await ref.read(settingsProvider.notifier).resetAllData();
          if (!done) start();
        } else {
          start();
        }
      });
      return null;
    }, [initFailed]);

    return Scaffold(
      backgroundColor: UIColorToken.white,
      body: Center(
        child: SizedBox(
          height: screen.width * 0.7,
          child: Image.asset(AppAssets.images.splash.path),
        ).animate().scale(curve: Curves.fastOutSlowIn, duration: 500.ms),
      ),
    );
  }
}
