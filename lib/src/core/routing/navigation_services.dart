import 'package:auto_route/auto_route.dart';

import 'app_router.dart';

abstract class NavigationServices {
  Future<bool> pop<T extends Object?>([T? result]);
  void popUntilRoot();
  void popUntilRouteWithName(String name);

  Future<void> pushPath(String path);
  Future<void> navigatePath(String path);
  Future<void> replacePath(String path);

  Future<T?> push<T extends Object?>(PageRouteInfo<Object?> route);
  Future<void> navigate(PageRouteInfo<Object?> route);
  Future<T?> replace<T extends Object?>(PageRouteInfo<Object?> route);
  Future<void> replaceAll(List<PageRouteInfo<Object?>> routes);
}

class NavigationServicesImpl implements NavigationServices {
  NavigationServicesImpl({required this.router});

  final AppRouter router;

  @override
  Future<bool> pop<T extends Object?>([T? result]) => router.maybePop<T>(result);

  @override
  void popUntilRoot() => router.popUntilRoot();

  @override
  void popUntilRouteWithName(String name) => router.popUntilRouteWithName(name);

  @override
  Future<void> navigatePath(String path) => router.navigatePath(path);

  @override
  Future<void> pushPath(String path) => router.pushPath(path);

  @override
  Future<void> replacePath(String path) => router.replacePath(path);

  @override
  Future<void> navigate(PageRouteInfo<Object?> route) => router.navigate(route);

  @override
  Future<T?> push<T extends Object?>(PageRouteInfo<Object?> route) => router.push<T>(route);

  @override
  Future<T?> replace<T extends Object?>(PageRouteInfo<Object?> route) => router.replace<T>(route);

  @override
  Future<void> replaceAll(List<PageRouteInfo<Object?>> routes) => router.replaceAll(routes);
}
