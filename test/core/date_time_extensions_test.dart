import 'package:wumbi/src/core/utils/extensions/date_time_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('list date format (same year)', () {
    final now = DateTime.now();
    final d = DateTime(now.year, 10, 28, 9, 0);
    expect(d.formatListDate(), 'Oct 28, 09:00 AM');
  });

  test('list date format (other year)', () {
    expect(DateTime(2001, 10, 28, 9, 0).formatListDate(), 'Oct 28, 2001');
  });

  test('chip date', () {
    expect(DateTime.now().formatChipDate(), 'Today');
    expect(DateTime.now().subtract(const Duration(days: 1)).formatChipDate(), 'Yesterday');
    expect(DateTime(2026, 10, 28).formatChipDate(), 'Oct 28, 2026');
  });

  test('epoch round trip', () {
    final d = DateTime(2026, 5, 6, 7, 8, 9);
    expect(DateTimeExtension.fromEpochMs(d.epochMs), d);
  });
}
