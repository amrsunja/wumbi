// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:fiin/src/src/core/design_system/app_ui.dart';
import 'package:fiin/src/src/core/locale/l10n.dart';
import 'package:fiin/src/src/core/providers/routing/navigation_services_provider.dart';
import 'package:fiin/src/src/core/providers/widgets/scaffold_messenger_provider.dart';
import 'package:fiin/src/src/core/providers/widgets/snackbar_provider.dart';
import 'package:fiin/src/src/core/utils/constants/constants.dart';
import 'package:fiin/src/src/core/utils/enums/app_theme_type.dart';
import 'package:fiin/src/src/core/utils/extensions/build_context_extensions.dart';
import 'package:fiin/src/src/core/utils/state_management/app_events.dart';
import 'package:fiin/src/src/core/utils/state_management/single_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'features/settings/ui/state_management/settings_provider.dart';


class App extends StatefulHookConsumerWidget {
	const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {

	@override
	void initState() {
		super.initState();

		WidgetsBinding.instance.addObserver(this);
	}

	@override
  void didChangeAppLifecycleState(AppLifecycleState state) {
		// Send firebase messaging device token after all resuming of app
		if (state == AppLifecycleState.resumed) {
			// remove app icon badge
			//AppBadgePlus.updateBadge(0);
		}
    super.didChangeAppLifecycleState(state);
  }


	@override
	Widget build(BuildContext context) {
		final appSettings = ref.watch(settingsProvider).data;
		final appRouter = ref.read(navigationServicesProvider);

		useEffect(() {
			// Listen to App Events (Navigation, Showing Error etc...)
			final appEvents = ref.read(appEventProvider);

			appEvents.singleEvents.listen((event) {
				if (!context.mounted) return;

				if (event is ShowErrorEvent)
					ref.read(snackbarProvider).showError(event.message(
						ref.read(l10nProvider)
					));
				else if (event is ShowSuccessMessageEvent)
					ref.read(snackbarProvider).showSuccess(event.message);
				else if (event is ShowInfoMessageEvent)
					ref.read(snackbarProvider).showInfo(event.message);
				// Navigation check
				else if (event is NavigateRouteEvent) {
					appRouter.navigatePath(event.routePath);
				}
				else if (event is PushRouteEvent)
					appRouter.pushPath(event.routePath);
				else if (event is ReplaceRouteEvent)
					appRouter.replacePath(event.routePath);
			});
			return null;
		}, []);


    final getThemeData = useCallback(() {
			final systemTheme = context.isDarkMode ? AppThemeData.dark() : AppThemeData.light();

			if (appSettings == null) return systemTheme;


			switch (appSettings.themeMode) {
			  case AppThemeType.light:
					return AppThemeData.light();
			  case AppThemeType.dark:
					return AppThemeData.dark();
        default: 
					return systemTheme;
			}
		}, [appSettings?.themeMode]);

		final theme = getThemeData();


		return AppTheme(
			data: theme,
			child: MaterialApp.router(
				theme: ThemeData(
					scaffoldBackgroundColor: theme.colors.bgColor,
					appBarTheme: AppBarTheme(
						backgroundColor: Colors.transparent,
						shadowColor: Colors.transparent,
						surfaceTintColor: UIColorToken.white,
						elevation: 0,
						titleSpacing: 0,
						scrolledUnderElevation: 0.0,
					),
					// Change splash effect colors
					splashColor: Colors.transparent,
					highlightColor: Colors.transparent,
					hoverColor: Colors.transparent,
				),
				title: kAppName,
			  debugShowCheckedModeBanner: false,
				supportedLocales: L10n.all,
		  	locale: appSettings?.locale,
				localizationsDelegates: AppLocale.localizationsDelegates,
			  scaffoldMessengerKey: ref.read(scaffoldMessengerProvider),
				routerConfig: appRouter.router.config(),
			),
		);
	}
}
