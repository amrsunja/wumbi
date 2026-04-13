import 'package:fiin/src/src/core/routing/app_router.dart';
import 'package:fiin/src/src/core/routing/navigation_services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


final navigationServicesProvider = Provider((ref) => NavigationServicesImpl(
	router: AppRouter() 
));
