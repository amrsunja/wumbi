import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wumbi/src/features/backup/data/backup_codec.dart';
import 'package:wumbi/src/features/backup/data/csv_exporter.dart';

import '../../helpers/test_db.dart';
import 'backup_fixtures.dart';

/// Minimal RFC 4180 reader for assertions.
List<List<String>> _parse(String text) {
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var quoted = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (quoted) {
      if (c == '"' && i + 1 < text.length && text[i + 1] == '"') {
        cell.write('"');
        i++;
      } else if (c == '"') {
        quoted = false;
      } else {
        cell.write(c);
      }
    } else if (c == '"') {
      quoted = true;
    } else if (c == ',') {
      row.add(cell.toString());
      cell.clear();
    } else if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') {
      row.add(cell.toString());
      cell.clear();
      rows.add(row);
      row = <String>[];
      i++;
    } else {
      cell.write(c);
    }
  }
  return rows;
}

void main() {
  setUpAll(sqfliteFfiInit);

  test('transactions export as a spreadsheet-safe CSV', () async {
    final services = ffiSqlite(inMemoryDatabasePath);
    await services.initDatabase();
    addTearDown(services.close);
    await seedEverything(services.db);

    final bytes = await const CsvExporter().export(services.db);
    expect(bytes.sublist(0, 3), [0xEF, 0xBB, 0xBF], reason: 'UTF-8 BOM for Excel');

    final text = utf8.decode(bytes.sublist(3));
    expect(text, startsWith(CsvHeader.first), reason: 'the importer recognises it');
    final table = _parse(text);
    final header = table.first;
    expect(header, CsvExporter.header);
    Map<String, String> byId(String id) {
      final row = table.firstWhere((r) => r.last == id);
      return {for (var i = 0; i < header.length; i++) header[i]: row[i]};
    }

    // 7 live rows; the soft-deleted one is left out.
    expect(table, hasLength(1 + 7));
    expect(table.any((r) => r.last == 't-gone'), isFalse);

    final rent = byId('t-rent');
    expect(rent['Type'], 'expense');
    expect(rent['Amount'], '-900.00');
    expect(rent['Currency'], 'EUR');
    expect(rent['Wallet'], 'Карта 💳');
    expect(rent['Tags'], "'=Fun; Food", reason: 'formula-like text is neutralised, tags sorted');
    expect(rent['Recurring'], 'yes');

    final salary = byId('t-salary');
    expect(salary['Amount'], '3000.00');
    expect(salary['Description'], 'Salary, March "bonus"\nline 2', reason: 'quotes, commas, newlines survive');

    final fx = byId('t-fx');
    expect(fx['Type'], 'transfer');
    expect(fx['Wallet'], 'Карта 💳');
    expect(fx['Amount'], '-100.00');
    expect(fx['To wallet'], 'Tokyo, "cash"');
    expect(fx['To amount'], '16250', reason: 'JPY has no decimals');
    expect(fx['To currency'], 'JPY');

    expect(byId('t-old')['Description'], "'@old");
    expect(byId('t-lend')['Debt'], 'principal');
    final soon = byId('t-soon');
    expect(soon['Status'], 'upcoming');
    expect(soon['Original amount'], '1.20');
    expect(soon['Original currency'], 'USD');
    expect(RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$').hasMatch(rent['Date']!), isTrue);
  });

  test('an empty database exports just the header', () async {
    final services = ffiSqlite(inMemoryDatabasePath);
    await services.initDatabase();
    addTearDown(services.close);
    final text = utf8.decode((await const CsvExporter().export(services.db)).sublist(3));
    expect(_parse(text), [CsvExporter.header]);
  });
}
