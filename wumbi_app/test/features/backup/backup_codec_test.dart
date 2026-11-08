import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wumbi/src/core/errors/exceptions/domain/domain_exceptions.dart';
import 'package:wumbi/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:wumbi/src/features/backup/data/backup_codec.dart';

const _fastKdf = BackupKdfParams(memoryKiB: 64, iterations: 1);

final BackupTables _tables = {
  'settings': [
    {'id': 1, 'language_code': 'ru', 'theme_mode': 'dark', 'base_currency': 'EUR', 'last_recurring_run_at': null},
  ],
  'wallets': [
    {'id': 'w-1', 'name': 'Карта 💳 "main"', 'initial_balance_minor': 9007199254740993, 'is_primary': 1},
  ],
  'transactions': [
    {'id': 't-1', 'exchange_rate': 162.5, 'amount_minor': 0, 'description': ''},
  ],
};

Future<Uint8List> _encode({BackupKey? key, int schemaVersion = SQLiteConfig.dbVersion}) => BackupCodec.encode(
      tables: _tables,
      createdAt: DateTime.utc(2026, 11, 8, 12),
      appVersion: '1.0.0+0',
      schemaVersion: schemaVersion,
      key: key,
      kdf: _fastKdf,
    );

Map<String, Object?> _json(Uint8List bytes) => jsonDecode(utf8.decode(bytes)) as Map<String, Object?>;
Uint8List _bytes(Map<String, Object?> json) => Uint8List.fromList(utf8.encode(jsonEncode(json)));

Matcher _fails(BackupErrorReason reason) =>
    throwsA(isA<BackupException>().having((e) => e.reason, 'reason', reason));

void main() {
  group('plain backups', () {
    test('round-trip keeps every value and type exactly', () async {
      final bytes = await _encode();
      final envelope = BackupCodec.parse(bytes, fileName: 'wumbi-backup.wumbi');

      expect(envelope.isEncrypted, isFalse);
      expect(envelope.schemaVersion, SQLiteConfig.dbVersion);
      expect(envelope.appVersion, '1.0.0+0');
      expect(envelope.createdAt, DateTime.utc(2026, 11, 8, 12));

      final tables = await BackupCodec.open(envelope);
      expect(tables, _tables);
      expect(tables['wallets']!.single['initial_balance_minor'], 9007199254740993); // > 2^53, still exact
      expect(tables['transactions']!.single['exchange_rate'], isA<double>());
      expect(tables['transactions']!.single['amount_minor'], isA<int>());
    });

    test('envelope is readable JSON with format, versions and a checksum', () async {
      final json = _json(await _encode());
      expect(json['format'], 'wumbi-backup');
      expect(json['formatVersion'], 1);
      expect(json['encryption'], isNull);
      expect((json['checksum']! as Map)['sha256'], hasLength(64));
    });

    test('a changed payload byte fails the checksum', () async {
      final json = _json(await _encode());
      final payload = base64Decode(json['payload']! as String);
      payload[payload.length ~/ 2] ^= 0x01;
      json['payload'] = base64Encode(payload);
      final envelope = BackupCodec.parse(_bytes(json));
      await expectLater(BackupCodec.open(envelope), _fails(BackupErrorReason.corrupted));
    });

    test('a plain file without checksum is refused', () async {
      final json = _json(await _encode())..remove('checksum');
      expect(() => BackupCodec.parse(_bytes(json)), _fails(BackupErrorReason.corrupted));
    });

    test('a truncated backup is reported as damaged', () async {
      final bytes = await _encode();
      expect(() => BackupCodec.parse(Uint8List.sublistView(bytes, 0, bytes.length ~/ 2)), _fails(BackupErrorReason.corrupted));
    });
  });

  group('encrypted backups', () {
    test('round-trip with the right password; the payload is not readable', () async {
      final bytes = await _encode(key: const BackupPassword('correct horse'));
      final json = _json(bytes);
      expect(json['checksum'], isNull);
      expect(utf8.decode(bytes, allowMalformed: true), isNot(contains('Карта')));

      final envelope = BackupCodec.parse(bytes);
      expect(envelope.isEncrypted, isTrue);
      expect(envelope.needsPassword, isTrue);
      expect(await BackupCodec.open(envelope, key: const BackupPassword('correct horse')), _tables);
    });

    test('wrong or missing password', () async {
      final envelope = BackupCodec.parse(await _encode(key: const BackupPassword('correct horse')));
      await expectLater(BackupCodec.open(envelope, key: const BackupPassword('wrong')), _fails(BackupErrorReason.wrongPassword));
      await expectLater(BackupCodec.open(envelope), _fails(BackupErrorReason.passwordRequired));
    });

    test('header fields are authenticated: changing schemaVersion breaks decryption', () async {
      final json = _json(await _encode(key: const BackupPassword('pw-pw-pw-pw'), schemaVersion: 6));
      json['schemaVersion'] = 7;
      final envelope = BackupCodec.parse(_bytes(json));
      await expectLater(
        BackupCodec.open(envelope, key: const BackupPassword('pw-pw-pw-pw')),
        _fails(BackupErrorReason.wrongPassword),
      );
    });

    test('a crafted file cannot request an absurd Argon2 cost', () async {
      final json = _json(await _encode(key: const BackupPassword('pw-pw-pw-pw')));
      ((json['encryption']! as Map)['kdf'] as Map)['memoryKiB'] = 1 << 30;
      final envelope = BackupCodec.parse(_bytes(json));
      await expectLater(
        BackupCodec.open(envelope, key: const BackupPassword('pw-pw-pw-pw')),
        _fails(BackupErrorReason.corrupted),
      );
    });

    test('default (production) Argon2id parameters work', () async {
      final bytes = await BackupCodec.encode(
        tables: _tables,
        createdAt: DateTime.utc(2026),
        appVersion: '1',
        schemaVersion: SQLiteConfig.dbVersion,
        key: const BackupPassword('production-cost'),
      );
      final kdf = ((_json(bytes)['encryption']! as Map)['kdf'] as Map);
      expect(kdf['name'], 'argon2id');
      expect(kdf['memoryKiB'], 19456);
      expect(await BackupCodec.open(BackupCodec.parse(bytes), key: const BackupPassword('production-cost')), _tables);
    });

    test('device-key snapshots open only with the device key', () async {
      final key = BackupDeviceKey(List<int>.generate(32, (i) => i));
      final envelope = BackupCodec.parse(await _encode(key: key));
      expect(envelope.needsPassword, isFalse);
      expect(await BackupCodec.open(envelope, key: key), _tables);
      await expectLater(
        BackupCodec.open(envelope, key: BackupDeviceKey(List<int>.filled(32, 7))),
        _fails(BackupErrorReason.wrongPassword),
      );
      await expectLater(BackupCodec.open(envelope, key: const BackupPassword('x')), _fails(BackupErrorReason.notABackup));
    });
  });

  group('recognising files', () {
    test('a CSV export is refused with its own reason, by name or content', () {
      final csv = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode('Date,Type,Status\r\n')]);
      expect(() => BackupCodec.parse(csv), _fails(BackupErrorReason.csvNotRestorable));
      expect(() => BackupCodec.parse(Uint8List.fromList(utf8.encode('{}')), fileName: 'x.CSV'),
          _fails(BackupErrorReason.csvNotRestorable));
    });

    test('random files and other JSON are not backups', () {
      expect(() => BackupCodec.parse(Uint8List.fromList([0x89, 0x50, 0x4E, 0x47])), _fails(BackupErrorReason.notABackup));
      expect(() => BackupCodec.parse(_bytes({'format': 'other'})), _fails(BackupErrorReason.notABackup));
      expect(() => BackupCodec.parse(Uint8List.fromList(utf8.encode('[1,2]'))), _fails(BackupErrorReason.notABackup));
    });

    test('newer format or schema asks for an app update', () async {
      final newerFormat = _json(await _encode())..['formatVersion'] = BackupFormat.formatVersion + 1;
      expect(() => BackupCodec.parse(_bytes(newerFormat)), _fails(BackupErrorReason.newerVersion));
      final newerSchema = _json(await _encode())..['schemaVersion'] = SQLiteConfig.dbVersion + 1;
      expect(() => BackupCodec.parse(_bytes(newerSchema)), _fails(BackupErrorReason.newerVersion));
    });

    test('files over the size limit are refused before parsing', () {
      expect(() => BackupCodec.parse(Uint8List(BackupFormat.maxFileBytes + 1)), _fails(BackupErrorReason.tooLarge));
    });
  });

  group('payload validation', () {
    Future<BackupEnvelope> withTables(Object? tables) async {
      final compressed = GZipCodec().encode(utf8.encode(jsonEncode({'tables': tables})));
      final json = _json(await _encode());
      json['payload'] = base64Encode(compressed);
      json['checksum'] = {'sha256': _sha256Hex(compressed)};
      return BackupCodec.parse(_bytes(json));
    }

    test('SQL in a column or table name is refused', () async {
      await expectLater(
        BackupCodec.open(await withTables({
          'wallets': [
            {'id': 'x', 'name) VALUES (1); DROP TABLE wallets; --': 1},
          ],
        })),
        _fails(BackupErrorReason.corrupted),
      );
      await expectLater(
        BackupCodec.open(await withTables({'wallets; DROP TABLE x': []})),
        _fails(BackupErrorReason.corrupted),
      );
    });

    test('nested values and booleans are refused', () async {
      for (final value in [
        {'a': 1},
        [1],
        true,
      ]) {
        await expectLater(
          BackupCodec.open(await withTables({
            'wallets': [
              {'id': value},
            ],
          })),
          _fails(BackupErrorReason.corrupted),
        );
      }
    });

    test('a decompression bomb stops at the limit', () async {
      final envelope = await withTables({
        'mascot_memory': [
          {'key': 'k', 'value': 'x' * 200000},
        ],
      });
      await expectLater(BackupCodec.open(envelope, maxPayloadBytes: 10000), _fails(BackupErrorReason.tooLarge));
    });
  });
}

String _sha256Hex(List<int> bytes) => sha256.convert(bytes).toString();
