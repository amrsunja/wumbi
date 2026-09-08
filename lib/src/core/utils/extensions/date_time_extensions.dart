import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  DateTime onlyDate() => DateTime(year, month, day);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool isSameMonth(DateTime other) => year == other.year && month == other.month;

  bool get isToday => isSameDay(DateTime.now());

  bool get isYesterday =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// First instant of this month (local).
  DateTime get monthStart => DateTime(year, month);

  /// Lists: `Oct 28, 09:00 AM` (same year), `Oct 28, 2025` (other years).
  String formatListDate() {
    final local = toLocal();
    final now = DateTime.now();
    if (local.year == now.year) {
      return _format('MMM d, hh:mm a', local);
    }
    return _format('MMM d, yyyy', local);
  }

  /// Date chip: `Oct 28, 2026`, with "Today" / "Yesterday" shortcuts.
  String formatChipDate({String today = 'Today', String yesterday = 'Yesterday'}) {
    final local = toLocal();
    if (local.isToday) return today;
    if (local.isYesterday) return yesterday;
    return _format('MMM d, yyyy', local);
  }

  /// `Nov 1`
  String formatShortDate() => _format('MMM d', toLocal());

  /// Chart axis label: `Nov`.
  String formatMonthShort() => _format('MMM', toLocal());

  /// `Nov 1, 2026`
  String formatMediumDate() => _format('MMM d, yyyy', toLocal());

  /// Month divider: `September 2026` (current year → `September`).
  String formatMonthYear({bool hideCurrentYear = true}) {
    final local = toLocal();
    if (hideCurrentYear && local.year == DateTime.now().year) return _format('MMMM', local);
    return _format('MMMM yyyy', local);
  }

  /// Epoch millis in UTC — the storage format for every timestamp.
  int get epochMs => toUtc().millisecondsSinceEpoch;

  static DateTime fromEpochMs(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();

  /// Formats in the app locale (`Intl.defaultLocale`, set by `App` from the
  /// selected language); falls back to `en_US` if that locale's date symbols
  /// are not loaded yet.
  static String _format(String pattern, DateTime value) {
    try {
      return DateFormat(pattern, Intl.defaultLocale).format(value);
    } catch (_) {
      return DateFormat(pattern, 'en_US').format(value);
    }
  }
}
