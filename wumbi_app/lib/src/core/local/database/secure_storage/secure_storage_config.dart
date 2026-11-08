abstract class SecureStorageConfig {
  static const String sqfliteDbPasswordKey = 'sqfliteDbPassword';

  /// Random AES-256 key (base64) that encrypts the pre-restore safety
  /// snapshot kept on this device.
  static const String backupSnapshotKey = 'backupSnapshotKey';
}
