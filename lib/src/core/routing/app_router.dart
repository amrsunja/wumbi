import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import 'app_router.gr.dart';
import 'route_paths.dart';

export 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  CustomRoute customRoute({
    required PageInfo page,
    required String path,
    RouteTransitionsBuilder? transitionsBuilder = TransitionsBuilders.slideLeft,
    int durationInMilliseconds = 300,
    bool initial = false,
    bool fullscreenDialog = false,
  }) =>
      CustomRoute(
        page: page,
        path: path,
        initial: initial,
        fullscreenDialog: fullscreenDialog,
        transitionsBuilder: transitionsBuilder,
        duration: Duration(milliseconds: durationInMilliseconds),
      );

  @override
  List<AutoRoute> get routes => [
        customRoute(
          path: RoutePaths.splash,
          page: SplashRoute.page,
          initial: true,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        customRoute(
          path: RoutePaths.onboarding,
          page: OnboardingRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        customRoute(
          path: RoutePaths.dashboard,
          page: DashboardRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        customRoute(path: RoutePaths.walletForm, page: WalletFormRoute.page, transitionsBuilder: TransitionsBuilders.slideBottom, fullscreenDialog: true),
        customRoute(path: RoutePaths.walletDetails, page: WalletDetailsRoute.page),
        customRoute(path: RoutePaths.transaction, page: TransactionRoute.page, transitionsBuilder: TransitionsBuilders.slideBottom, fullscreenDialog: true),
        customRoute(path: RoutePaths.settings, page: SettingsRoute.page),
        customRoute(path: RoutePaths.baseCurrencySettings, page: BaseCurrencyRoute.page),
        customRoute(path: RoutePaths.aboutProject, page: AboutProjectRoute.page),
        customRoute(path: RoutePaths.appLangSettings, page: AppLanguageSettingsRoute.page),
      ];
}
