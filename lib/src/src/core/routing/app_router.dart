import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';

import 'app_router.gr.dart';
import 'route_paths.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
	/// General we use this route builder to enable opaque value wich is setted like true by default 
	CustomRoute customRoute({
		required PageInfo page,
		String? path,
		Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)? transitionsBuilder = TransitionsBuilders.slideLeftWithFade,
		int durationInMilliseconds = 300,
		bool initial = false,
	}) => CustomRoute(
		page: page,
		path: path,
		initial: initial,
		transitionsBuilder: transitionsBuilder,
		duration: Duration(milliseconds: durationInMilliseconds)
	);

	final generalSubPages = [
	];

  @override
	List<AutoRoute> get routes => [
		customRoute(
			path: RoutePaths.splash,
			page: SplashRoute.page,
			initial: true,
			transitionsBuilder: (context, anim, secondAnim, child) => FadeTransition(
				opacity: anim,
				child: child,
			),
		),

		AutoRoute(path: RoutePaths.dashboard, page: DashboardRoute.page),
		AutoRoute(path: RoutePaths.settings, page: SettingsRoute.page),
		AutoRoute(path: RoutePaths.appLangSettings, page: AppLanguageSettingsRoute.page),
		AutoRoute(path: RoutePaths.appThemeSettings, page: AppThemeSettingsRoute.page),
		AutoRoute(path: RoutePaths.aboutProject, page: AboutProjectRoute.page),
		AutoRoute(path: RoutePaths.onboarding, page: OnboardingRoute.page),
	];
}
