import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorageServices {
  Future<String?> readData(String key);
  Future<void> writeData(String key, String? value);
  Future<void> deleteData(String key);
}

class SecureStorageServicesImpl implements SecureStorageServices {
  const SecureStorageServicesImpl();

  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> readData(String key) => _storage.read(key: key);

  @override
  Future<void> writeData(String key, String? value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> deleteData(String key) => _storage.delete(key: key);
}
