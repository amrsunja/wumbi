import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/design_system/app_ui.dart';
import 'core/locale/l10n.dart';
import 'core/providers/data/app_state_keep_alive.dart';
import 'core/providers/routing/navigation_services_provider.dart';
import 'core/providers/widgets/scaffold_messenger_provider.dart';
import 'core/providers/widgets/snackbar_provider.dart';
import 'core/recurring/recurring_engine.dart';
import 'core/utils/constants/constants.dart';
import 'core/utils/enums/app_theme_type.dart';
import 'core/utils/extensions/build_context_extensions.dart';
import 'core/utils/state_management/app_events.dart';
import 'core/utils/state_management/single_events.dart';
import 'features/settings/ui/state_management/settings_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  StreamSubscription<Object?>? _eventsSub;
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _eventsSub = ref.read(appEventProvider).singleEvents.listen(_onEvent);
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Re-evaluate the `system` theme when the OS switches light/dark.
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      // Catch-up of recurring rules when returning to foreground after ≥ 1 h.
      final pausedAt = _pausedAt;
      _pausedAt = null;
      if (pausedAt != null && DateTime.now().difference(pausedAt) >= const Duration(hours: 1)) {
        ref.read(recurringEngineProvider).catchUpIfPossible();
      }
    }
  }

  void _onEvent(Object? event) {
    if (!mounted) return;
    final router = ref.read(navigationServicesProvider);
    final snackbar = ref.read(snackbarProvider);

    switch (event) {
      case ShowErrorEvent():
        snackbar.showError(event.message(ref.read(l10nProvider)));
      case ShowSuccessMessageEvent():
        snackbar.showSuccess(event.message);
      case ShowInfoMessageEvent():
        snackbar.showInfo(event.message);
      case ShowUndoEvent():
        snackbar.showUndo(event.message, actionLabel: event.actionLabel, onUndo: event.onUndo);
      case NavigateRouteEvent():
        router.navigatePath(event.routePath);
      case PushRouteEvent():
        router.pushPath(event.routePath);
      case ReplaceRouteEvent():
        router.replacePath(event.routePath);
      case PushRouteInfoEvent():
        router.push(event.route);
      case ReplaceAllRoutesEvent():
        router.replaceAll(event.routes);
      case PopRouteEvent():
        for (var i = 0; i < event.times; i++) {
          router.pop();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    keepAppStateAlive(ref);
    final appSettings = ref.watch(settingsProvider).data;
    final appRouter = ref.read(navigationServicesProvider);

    final AppThemeData theme;
    switch (appSettings?.themeMode) {
      case AppThemeType.light:
        theme = AppThemeData.light();
      case AppThemeType.dark:
        theme = AppThemeData.dark();
      case AppThemeType.system:
      case null:
        theme = context.isDarkMode ? AppThemeData.dark() : AppThemeData.light();
    }

    final colors = theme.colors;

    return AppTheme(
      data: theme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: theme.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: MaterialApp.router(
          theme: ThemeData(
            brightness: theme.keyboardTheme,
            scaffoldBackgroundColor: colors.bgColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: UIColorToken.blue,
              brightness: theme.keyboardTheme,
              surface: colors.bgColor,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              titleSpacing: 0,
              scrolledUnderElevation: 0,
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: UIColorToken.blue,
              selectionColor: UIColorToken.blue.withValues(alpha: 0.25),
              selectionHandleColor: UIColorToken.blue,
            ),
          ),
          title: kAppName,
          debugShowCheckedModeBanner: false,
          supportedLocales: L10n.all,
          locale: appSettings?.locale,
          localizationsDelegates: AppLocale.localizationsDelegates,
          scaffoldMessengerKey: ref.read(scaffoldMessengerProvider),
          routerConfig: appRouter.router.config(),
        ),
      ),
    );
  }
}
