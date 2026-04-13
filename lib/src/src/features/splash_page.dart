import 'package:auto_route/auto_route.dart';
import 'package:fiin/src/src/core/design_system/app_ui.dart';
import 'package:fiin/src/src/core/utils/typedefs.dart';
import 'package:fiin/src/src/features/settings/ui/state_management/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class SplashPage extends HookConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = MediaQuery.of(context).size;
    //final theme = AppTheme.of(context);
    //final defLangCode = Localizations.localeOf(context).languageCode;

    useEffect(() {
      Future.microtask(() async {
        await Future.delayed(Duration(milliseconds: 1200));
        await ref.read(settingsProvider.notifier).initDatabase();
        await ref.read(settingsProvider.notifier).initLocalSettings();
      });
      return;
    }, []);

    return Scaffold(
      backgroundColor: UIColorToken.white,
      body: Center(
        child: SizedBox(
          height: screen.width * 0.7,
          child: Image.asset(AppAssets.images.splash.path),
        ).animate()
          ..scale(
            curve: Curves.fastOutSlowIn,
          )
      ),
    );
  }
}
