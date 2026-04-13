import 'package:auto_route/auto_route.dart';

import 'app_router.dart';

abstract class NavigationServices {
	void pop();

	void pushPath(String path);
	void navigatePath(String path);
	void replacePath(String path);

	void push(PageRouteInfo<Object?> route);
	void navigate(PageRouteInfo<Object?> route);
	void replace(PageRouteInfo<Object?> route);
}

class NavigationServicesImpl implements NavigationServices {
	final AppRouter router;

	NavigationServicesImpl({
		required this.router
	});

  @override
  void pop() => router.pop();

  @override
  void navigatePath(String path) {
		router.navigatePath(path);
  }

  @override
  void pushPath(String path) {
		router.pushPath(path);
  }

  @override
  void replacePath(String path) {
		router.replacePath(path);
  }

  @override
  void navigate(route) {
		router.navigate(route);
  }

  @override
  void push(route) {
		router.push(route);
  }

  @override
  void replace(route) {
		router.replace(route);
  }
}
