import 'dart:convert';
import 'dart:io' show GZipCodec;
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';

import '../../../core/errors/exceptions/domain/domain_exceptions.dart';
import '../../../core/local/database/sqlite/sqlite_config.dart';

/// One database row as stored in a backup: column → SQLite value
/// (`null`, `int`, `double` or `String`).
typedef BackupRow = Map<String, Object?>;

/// Table name → rows.
typedef BackupTables = Map<String, List<BackupRow>>;

/// The `.wumbi` file format.
///
/// A backup is a UTF-8 JSON envelope:
///
/// ```json
/// {
///   "format": "wumbi-backup",
///   "formatVersion": 1,
///   "createdAt": "2026-11-08T12:00:00.000Z",
///   "appVersion": "1.0.0+0",
///   "schemaVersion": 7,
///   "compression": "gzip",
///   "checksum": { "sha256": "<hex>" },          // plain files only
///   "encryption": null | {
///     "cipher": "AES-256-GCM",
///     "kdf": { "name": "argon2id", "memoryKiB": 19456, "iterations": 2,
///              "parallelism": 1, "salt": "<base64>" },
///     "nonce": "<base64>", "mac": "<base64>"
///   },
///   "payload": "<base64>"
/// }
/// ```
///
/// `payload` is `gzip(JSON {"tables": {name: [row, …]}})`, encrypted when
/// `encryption` is set. Rows are the raw database rows of schema
/// `schemaVersion` — amounts in minor units, UUIDs, epoch-ms timestamps —
/// so nothing is converted or rounded.
///
/// Integrity: a plain file carries a SHA-256 of the payload; an encrypted one
/// is authenticated by AES-GCM, with the header fields bound in as associated
/// data (changing `schemaVersion` or `createdAt` breaks decryption).
abstract class BackupFormat {
  static const String format = 'wumbi-backup';
  static const int formatVersion = 1;
  static const String fileExtension = 'wumbi';
  static const String mimeType = 'application/octet-stream';

  /// Import limits: the file, and the payload once decompressed (guards
  /// against "zip bombs").
  static const int maxFileBytes = 100 * 1024 * 1024;
  static const int maxPayloadBytes = 512 * 1024 * 1024;

  static const int minPasswordLength = 8;

  static const String cipherName = 'AES-256-GCM';
  static const String kdfArgon2id = 'argon2id';

  /// Safety snapshots are encrypted with a random key kept in this
  /// device's secure storage (no password to derive).
  static const String kdfDeviceKey = 'device';
}

/// Argon2id cost. Defaults follow the OWASP minimum (19 MiB, 2 passes,
/// 1 lane). The values are written into the file, so they can be raised
/// later without breaking old backups; reading accepts a bounded range so a
/// crafted file cannot make the app allocate gigabytes.
class BackupKdfParams {
  const BackupKdfParams({this.memoryKiB = 19456, this.iterations = 2, this.parallelism = 1});

  final int memoryKiB;
  final int iterations;
  final int parallelism;

  bool get isWithinLimits =>
      memoryKiB >= 8 &&
      memoryKiB <= 262144 &&
      iterations >= 1 &&
      iterations <= 10 &&
      parallelism >= 1 &&
      parallelism <= 8;
}

/// What unlocks an encrypted backup.
sealed class BackupKey {
  const BackupKey();
}

/// A password typed by the user (Argon2id-derived key).
class BackupPassword extends BackupKey {
  const BackupPassword(this.value);
  final String value;
}

/// A raw 256-bit key (safety snapshots, see [BackupFormat.kdfDeviceKey]).
class BackupDeviceKey extends BackupKey {
  const BackupDeviceKey(this.bytes);
  final List<int> bytes;
}

/// The readable part of a backup, available before it is unlocked.
class BackupEnvelope {
  const BackupEnvelope._({
    required this.createdAt,
    required this.createdAtRaw,
    required this.appVersion,
    required this.schemaVersion,
    required this.encryption,
    required this.checksum,
    required this.payload,
  });

  final DateTime createdAt;

  /// `createdAt` exactly as written — part of the authenticated data.
  final String createdAtRaw;
  final String appVersion;
  final int schemaVersion;
  final Map<String, Object?>? encryption;
  final String? checksum;
  final String payload;

  bool get isEncrypted => encryption != null;

  /// True for a password-protected file (as opposed to a device snapshot).
  bool get needsPassword => (encryption?['kdf'] as Map?)?['name'] == BackupFormat.kdfArgon2id;
}

abstract class BackupCodec {
  static final _identifier = RegExp(r'^[a-z][a-z0-9_]{0,63}$');
  static const _gcmNonceLength = 12;
  static const _saltLength = 16;

  // ------------------------------------------------------------------ write

  /// Serializes [tables] into a `.wumbi` file. With [key], the payload is
  /// encrypted (AES-256-GCM); [kdf] sets the Argon2id cost for a password.
  static Future<Uint8List> encode({
    required BackupTables tables,
    required DateTime createdAt,
    required String appVersion,
    required int schemaVersion,
    BackupKey? key,
    BackupKdfParams kdf = const BackupKdfParams(),
  }) async {
    final json = utf8.encode(jsonEncode({'tables': tables}));
    final compressed = GZipCodec(level: 6).encode(json);
    final createdAtIso = createdAt.toUtc().toIso8601String();

    Object? checksum;
    Object? encryption;
    List<int> payload;

    if (key == null) {
      payload = compressed;
      checksum = {'sha256': crypto.sha256.convert(compressed).toString()};
    } else {
      final random = Random.secure();
      final nonce = List<int>.generate(_gcmNonceLength, (_) => random.nextInt(256));
      final Map<String, Object?> kdfJson;
      final SecretKey secretKey;
      switch (key) {
        case BackupPassword(:final value):
          final salt = List<int>.generate(_saltLength, (_) => random.nextInt(256));
          secretKey = await _deriveFromPassword(value, salt, kdf);
          kdfJson = {
            'name': BackupFormat.kdfArgon2id,
            'memoryKiB': kdf.memoryKiB,
            'iterations': kdf.iterations,
            'parallelism': kdf.parallelism,
            'salt': base64Encode(salt),
          };
        case BackupDeviceKey(:final bytes):
          secretKey = SecretKey(bytes);
          kdfJson = {'name': BackupFormat.kdfDeviceKey};
      }
      final box = await AesGcm.with256bits().encrypt(
        compressed,
        secretKey: secretKey,
        nonce: nonce,
        aad: _aad(createdAtIso, appVersion, schemaVersion),
      );
      payload = box.cipherText;
      encryption = {
        'cipher': BackupFormat.cipherName,
        'kdf': kdfJson,
        'nonce': base64Encode(box.nonce),
        'mac': base64Encode(box.mac.bytes),
      };
    }

    final envelope = <String, Object?>{
      'format': BackupFormat.format,
      'formatVersion': BackupFormat.formatVersion,
      'createdAt': createdAtIso,
      'appVersion': appVersion,
      'schemaVersion': schemaVersion,
      'compression': 'gzip',
      'checksum': checksum,
      'encryption': encryption,
      'payload': base64Encode(payload),
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(envelope)));
  }

  // ------------------------------------------------------------------- read

  /// Reads the envelope (cheap: nothing is decrypted or decompressed).
  /// Throws [BackupException] for anything that is not a usable backup.
  static BackupEnvelope parse(Uint8List bytes, {String? fileName}) {
    if (bytes.length > BackupFormat.maxFileBytes) {
      throw const BackupException(BackupErrorReason.tooLarge);
    }
    if (_looksLikeCsv(bytes, fileName)) {
      throw const BackupException(BackupErrorReason.csvNotRestorable);
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } on FormatException catch (e) {
      // Cut short / damaged, but recognisably one of ours.
      final head = utf8.decode(bytes.sublist(0, min(bytes.length, 64)), allowMalformed: true);
      final ours = head.contains('"format":"${BackupFormat.format}"');
      throw BackupException(ours ? BackupErrorReason.corrupted : BackupErrorReason.notABackup, e);
    }
    if (decoded is! Map<String, Object?> || decoded['format'] != BackupFormat.format) {
      throw const BackupException(BackupErrorReason.notABackup);
    }

    final formatVersion = decoded['formatVersion'];
    if (formatVersion is! int || formatVersion < 1) {
      throw const BackupException(BackupErrorReason.notABackup);
    }
    if (formatVersion > BackupFormat.formatVersion) {
      throw const BackupException(BackupErrorReason.newerVersion);
    }

    final schemaVersion = decoded['schemaVersion'];
    final createdAtRaw = decoded['createdAt'];
    final createdAt = createdAtRaw is String ? DateTime.tryParse(createdAtRaw) : null;
    final appVersion = decoded['appVersion'];
    final payload = decoded['payload'];
    final encryption = decoded['encryption'];
    final checksum = decoded['checksum'];
    if (schemaVersion is! int ||
        schemaVersion < 1 ||
        createdAt == null ||
        appVersion is! String ||
        payload is! String ||
        (encryption != null && encryption is! Map<String, Object?>) ||
        (checksum != null && checksum is! Map<String, Object?>)) {
      throw const BackupException(BackupErrorReason.corrupted);
    }
    if (schemaVersion > SQLiteConfig.dbVersion) {
      throw const BackupException(BackupErrorReason.newerVersion);
    }
    final sha = (checksum as Map<String, Object?>?)?['sha256'];
    if (encryption == null && sha is! String) {
      // A plain file must carry its checksum.
      throw const BackupException(BackupErrorReason.corrupted);
    }

    return BackupEnvelope._(
      createdAt: createdAt.toUtc(),
      createdAtRaw: createdAtRaw as String,
      appVersion: appVersion,
      schemaVersion: schemaVersion,
      encryption: encryption as Map<String, Object?>?,
      checksum: sha as String?,
      payload: payload,
    );
  }

  /// Verifies, decrypts and decompresses the payload, then checks its
  /// shape. [maxPayloadBytes] is only lowered by tests.
  static Future<BackupTables> open(
    BackupEnvelope envelope, {
    BackupKey? key,
    int maxPayloadBytes = BackupFormat.maxPayloadBytes,
  }) async {
    final List<int> raw;
    try {
      raw = base64Decode(envelope.payload);
    } on FormatException catch (e) {
      throw BackupException(BackupErrorReason.corrupted, e);
    }

    final List<int> compressed;
    final encryption = envelope.encryption;
    if (encryption == null) {
      if (crypto.sha256.convert(raw).toString() != envelope.checksum) {
        throw const BackupException(BackupErrorReason.corrupted, 'checksum mismatch');
      }
      compressed = raw;
    } else {
      compressed = await _decrypt(envelope, encryption, raw, key);
    }

    final json = _gunzipBounded(compressed, maxPayloadBytes);
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(json));
    } on FormatException catch (e) {
      throw BackupException(BackupErrorReason.corrupted, e);
    }
    return _validateTables(decoded);
  }

  // --------------------------------------------------------------- internal

  static List<int> _aad(String createdAtIso, String appVersion, int schemaVersion) =>
      utf8.encode('${BackupFormat.format}|${BackupFormat.formatVersion}|$createdAtIso|$appVersion|$schemaVersion');

  static Future<SecretKey> _deriveFromPassword(String password, List<int> salt, BackupKdfParams kdf) => Argon2id(
    parallelism: kdf.parallelism,
    memory: kdf.memoryKiB,
    iterations: kdf.iterations,
    hashLength: 32,
  ).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);

  static Future<List<int>> _decrypt(
    BackupEnvelope envelope,
    Map<String, Object?> encryption,
    List<int> cipherText,
    BackupKey? key,
  ) async {
    final kdf = encryption['kdf'];
    final nonceB64 = encryption['nonce'];
    final macB64 = encryption['mac'];
    if (encryption['cipher'] != BackupFormat.cipherName ||
        kdf is! Map<String, Object?> ||
        nonceB64 is! String ||
        macB64 is! String) {
      throw const BackupException(BackupErrorReason.corrupted, 'bad encryption header');
    }

    final SecretKey secretKey;
    switch (kdf['name']) {
      case BackupFormat.kdfArgon2id:
        if (key == null) throw const BackupException(BackupErrorReason.passwordRequired);
        if (key is! BackupPassword) throw const BackupException(BackupErrorReason.wrongPassword);
        final memory = kdf['memoryKiB'];
        final iterations = kdf['iterations'];
        final parallelism = kdf['parallelism'];
        final saltB64 = kdf['salt'];
        if (memory is! int || iterations is! int || parallelism is! int || saltB64 is! String) {
          throw const BackupException(BackupErrorReason.corrupted, 'bad kdf header');
        }
        final params = BackupKdfParams(memoryKiB: memory, iterations: iterations, parallelism: parallelism);
        if (!params.isWithinLimits) {
          throw const BackupException(BackupErrorReason.corrupted, 'kdf params out of range');
        }
        secretKey = await _deriveFromPassword(key.value, _b64(saltB64), params);
      case BackupFormat.kdfDeviceKey:
        // Snapshots are only ever opened by the app itself, with its key.
        if (key is! BackupDeviceKey) throw const BackupException(BackupErrorReason.notABackup);
        secretKey = SecretKey(key.bytes);
      default:
        throw const BackupException(BackupErrorReason.newerVersion, 'unknown kdf');
    }

    try {
      return await AesGcm.with256bits().decrypt(
        SecretBox(cipherText, nonce: _b64(nonceB64), mac: Mac(_b64(macB64))),
        secretKey: secretKey,
        aad: _aad(envelope.createdAtRaw, envelope.appVersion, envelope.schemaVersion),
      );
    } on SecretBoxAuthenticationError {
      throw const BackupException(BackupErrorReason.wrongPassword);
    } on ArgumentError catch (e) {
      // Wrong nonce / MAC length.
      throw BackupException(BackupErrorReason.corrupted, e);
    }
  }

  static List<int> _b64(String value) {
    try {
      return base64Decode(value);
    } on FormatException catch (e) {
      throw BackupException(BackupErrorReason.corrupted, e);
    }
  }

  /// gzip-decodes [data], refusing to produce more than [limit] bytes.
  static Uint8List _gunzipBounded(List<int> data, int limit) {
    final sink = _BoundedSink(limit);
    try {
      final input = GZipCodec().decoder.startChunkedConversion(sink);
      const chunk = 64 * 1024;
      for (var i = 0; i < data.length; i += chunk) {
        input.add(data.sublist(i, min(i + chunk, data.length)));
      }
      input.close();
    } on BackupException {
      rethrow;
    } catch (e) {
      throw BackupException(BackupErrorReason.corrupted, e);
    }
    return sink.takeBytes();
  }

  /// `{"tables": {name: [{column: scalar}]}}` with SQL-safe identifiers.
  /// Column and table names are later checked against the real schema too;
  /// this is the first line of defence.
  static BackupTables _validateTables(Object? decoded) {
    if (decoded is! Map<String, Object?>) {
      throw const BackupException(BackupErrorReason.corrupted, 'payload is not an object');
    }
    final tables = decoded['tables'];
    if (tables is! Map<String, Object?>) {
      throw const BackupException(BackupErrorReason.corrupted, 'missing tables');
    }
    final result = <String, List<BackupRow>>{};
    for (final MapEntry(key: name, value: rows) in tables.entries) {
      if (!_identifier.hasMatch(name) || rows is! List<Object?>) {
        throw BackupException(BackupErrorReason.corrupted, 'bad table "$name"');
      }
      final list = <BackupRow>[];
      for (final row in rows) {
        if (row is! Map<String, Object?>) {
          throw BackupException(BackupErrorReason.corrupted, 'bad row in "$name"');
        }
        for (final MapEntry(key: column, :value) in row.entries) {
          if (!_identifier.hasMatch(column)) {
            throw BackupException(BackupErrorReason.corrupted, 'bad column "$column"');
          }
          final scalar = value == null || value is int || value is String || (value is double && value.isFinite);
          if (!scalar) {
            throw BackupException(BackupErrorReason.corrupted, 'bad value in $name.$column');
          }
        }
        list.add(row);
      }
      result[name] = list;
    }
    return result;
  }

  /// A Wumbi CSV export (by name, or by content: a UTF-8 BOM / a header
  /// line instead of a JSON object).
  static bool _looksLikeCsv(Uint8List bytes, String? fileName) {
    if (fileName != null && fileName.toLowerCase().endsWith('.csv')) return true;
    var start = 0;
    if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) start = 3;
    final head = utf8.decode(bytes.sublist(start, min(bytes.length, start + 64)), allowMalformed: true);
    return head.startsWith(CsvHeader.first);
  }
}

/// First column of the CSV export — lets the importer recognise one.
abstract class CsvHeader {
  static const String first = 'Date,';
}

class _BoundedSink implements Sink<List<int>> {
  _BoundedSink(this.limit);

  final int limit;
  final _builder = BytesBuilder(copy: false);

  @override
  void add(List<int> data) {
    if (_builder.length + data.length > limit) {
      throw const BackupException(BackupErrorReason.tooLarge, 'payload over the limit');
    }
    _builder.add(data);
  }

  @override
  void close() {}

  Uint8List takeBytes() => _builder.takeBytes();
}
