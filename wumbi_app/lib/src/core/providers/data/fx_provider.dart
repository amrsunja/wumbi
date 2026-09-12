import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../fx/fx_service.dart';
import '../../fx/fx_service_impl.dart';
import '../local/sqlite_database_provider.dart';

final fxServiceProvider = Provider<FxService>(
  (ref) => FxServiceImpl(sqlite: ref.read(sqliteDataBaseProvider)),
);
