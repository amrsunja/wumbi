import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  DateTime onlyDate() => DateTime(year, month, day);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool get isToday => isSameDay(DateTime.now());

  bool get isYesterday =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// Lists: `Oct 28, 09:00 AM` (same year), `Oct 28, 2025` (other years).
  String formatListDate() {
    final local = toLocal();
    final now = DateTime.now();
    if (local.year == now.year) {
      return DateFormat('MMM d, hh:mm a', 'en_US').format(local);
    }
    return DateFormat('MMM d, yyyy', 'en_US').format(local);
  }

  /// Date chip: `Oct 28, 2026`, with "Today" / "Yesterday" shortcuts.
  String formatChipDate({String today = 'Today', String yesterday = 'Yesterday'}) {
    final local = toLocal();
    if (local.isToday) return today;
    if (local.isYesterday) return yesterday;
    return DateFormat('MMM d, yyyy', 'en_US').format(local);
  }

  /// `Nov 1`
  String formatShortDate() => DateFormat('MMM d', 'en_US').format(toLocal());

  /// Epoch millis in UTC — the storage format for every timestamp.
  int get epochMs => toUtc().millisecondsSinceEpoch;

  static DateTime fromEpochMs(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
}
