import 'dart:convert';
import 'dart:typed_data';

import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/money/currency_type.dart';

/// Transactions as a CSV for spreadsheets (Excel, Numbers, Google Sheets).
///
/// Export only — a CSV cannot hold wallets, budgets, debts, recurring rules
/// or settings, so it is never a backup (the importer recognises and refuses
/// it). Format choices:
///
/// * RFC 4180: comma-separated, `"`-quoted when needed, CRLF line ends.
/// * UTF-8 with a BOM, so Excel shows Cyrillic / Arabic / emoji correctly.
/// * Amounts as plain decimals with a dot (`-12.50`), signed: expenses and
///   money leaving a wallet are negative.
/// * Dates in the device's local time, `yyyy-MM-dd HH:mm`.
/// * Text cells starting with `= + - @` (or a tab / CR) get a leading `'`
///   so a spreadsheet never runs them as a formula ("CSV injection").
/// * Soft-deleted rows are left out.
class CsvExporter {
  const CsvExporter();

  static const String mimeType = 'text/csv';

  static const List<String> header = [
    'Date',
    'Type',
    'Status',
    'Wallet',
    'Amount',
    'Currency',
    'To wallet',
    'To amount',
    'To currency',
    'Original amount',
    'Original currency',
    'Description',
    'Tags',
    'Debt',
    'Recurring',
    'ID',
  ];

  Future<Uint8List> export(DatabaseExecutor db) async {
    final rows = await db.rawQuery('''
      SELECT
        t.id, t.type, t.status, t.transaction_date, t.amount_minor, t.currency,
        t.from_amount_minor, t.to_amount_minor,
        t.original_amount_minor, t.original_currency,
        t.description, t.debt_role, t.recurring_rule_id,
        w.name  AS wallet_name,
        fw.name AS from_name, fw.currency AS from_currency,
        tw.name AS to_name,   tw.currency AS to_currency,
        (SELECT group_concat(display_name, '; ') FROM (
           SELECT g.display_name FROM transaction_tags tt
           JOIN tags g ON g.id = tt.tag_id
           WHERE tt.transaction_id = t.id AND g.deleted_at IS NULL
           ORDER BY g.display_name COLLATE NOCASE
        )) AS tags
      FROM transactions t
      LEFT JOIN wallets w  ON w.id  = t.wallet_id
      LEFT JOIN wallets fw ON fw.id = t.from_wallet_id
      LEFT JOIN wallets tw ON tw.id = t.to_wallet_id
      WHERE t.deleted_at IS NULL
      ORDER BY t.transaction_date, t.created_at
    ''');

    final out = StringBuffer()..write(_line(header));
    for (final r in rows) {
      final type = r['type']! as String;
      final isTransfer = type == 'transfer';
      final currency = (isTransfer ? r['from_currency'] : r['currency']) as String? ?? '';
      final toCurrency = isTransfer ? r['to_currency'] as String? ?? '' : '';
      final amountMinor = (isTransfer ? r['from_amount_minor'] : r['amount_minor']) as int? ?? 0;
      final signed = type == 'income' ? amountMinor : -amountMinor;
      final originalCurrency = r['original_currency'] as String?;

      out.write(
        _line([
          _date(r['transaction_date']! as int),
          type,
          r['status'] as String? ?? 'posted',
          _text((isTransfer ? r['from_name'] : r['wallet_name']) as String? ?? ''),
          _amount(signed, currency),
          currency,
          isTransfer ? _text(r['to_name'] as String? ?? '') : '',
          isTransfer ? _amount(r['to_amount_minor'] as int? ?? 0, toCurrency) : '',
          toCurrency,
          originalCurrency == null ? '' : _amount(r['original_amount_minor'] as int? ?? 0, originalCurrency),
          originalCurrency ?? '',
          _text(r['description'] as String? ?? ''),
          _text(r['tags'] as String? ?? ''),
          r['debt_role'] as String? ?? '',
          r['recurring_rule_id'] == null ? '' : 'yes',
          r['id']! as String,
        ]),
      );
    }

    return Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(out.toString())]);
  }

  /// `1234` minor units of USD → `12.34`; JPY → `1234`.
  static String _amount(int minor, String currencyCode) {
    final scale = CurrencyType.tryFromCode(currencyCode)?.scale ?? 2;
    final negative = minor < 0;
    final digits = minor.abs().toString();
    if (scale == 0) return '${negative ? '-' : ''}$digits';
    final padded = digits.padLeft(scale + 1, '0');
    final whole = padded.substring(0, padded.length - scale);
    final fraction = padded.substring(padded.length - scale);
    return '${negative ? '-' : ''}$whole.$fraction';
  }

  static String _date(int epochMs) {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true).toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  /// Neutralises spreadsheet formulas in user text.
  static String _text(String value) {
    if (value.isEmpty) return value;
    const triggers = {'=', '+', '-', '@', '\t', '\r'};
    return triggers.contains(value[0]) ? "'$value" : value;
  }

  static String _line(List<String> cells) => '${cells.map(_quote).join(',')}\r\n';

  static String _quote(String cell) {
    final needsQuotes = cell.contains(',') || cell.contains('"') || cell.contains('\n') || cell.contains('\r');
    return needsQuotes ? '"${cell.replaceAll('"', '""')}"' : cell;
  }
}
