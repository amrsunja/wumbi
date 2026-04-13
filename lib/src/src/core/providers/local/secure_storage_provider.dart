import 'package:fiin/src/src/core/local/database/secure_storage/secure_storage_services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final secureStorageServicesProvider = Provider(
	(ref) => SecureStorageServicesImpl()
);
