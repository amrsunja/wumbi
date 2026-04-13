import 'package:fiin/src/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:fiin/src/src/core/providers/local/secure_storage_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final sqliteDataBaseProvider = Provider<SQLiteServices>(
	(ref) => SQLiteServicesImpl(
    secureStorage: ref.read(secureStorageServicesProvider)
  )
);
