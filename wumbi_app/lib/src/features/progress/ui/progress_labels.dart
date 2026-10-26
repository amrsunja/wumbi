import 'dart:math' as math;

import 'package:intl/intl.dart';

import '../../../core/locale/l10n.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../data/models/progress_stats.dart';

/// Every string the Progress page derives from the model.
abstract class ProgressLabels {
  /// `October 2026` / `2026`.
  static String period(ProgressGranularity g, DateTime start) => switch (g) {
        ProgressGranularity.month => start.formatMonthYear(hideCurrentYear: false),
        ProgressGranularity.year => '${start.year}',
      };

  /// History axis: `Oct` / `2026`.
  static String periodShort(ProgressGranularity g, DateTime start) => switch (g) {
        ProgressGranularity.month => start.formatMonthShort(),
        ProgressGranularity.year => '${start.year}',
      };

  /// What the comparison is called inside sentences: `September 2026`,
  /// `the 3-month average`.
  static String baseline(AppLocale l10n, ProgressGranularity g, ProgressBaseline b, List<DateTime> starts) =>
      switch (b.kind) {
        ProgressBaselineKind.average => g == ProgressGranularity.month
            ? l10n.progress_average_months(ProgressBaseline.averageSpan)
            : l10n.progress_average_years(ProgressBaseline.averageSpan),
        _ => period(g, starts.first),
      };

  /// Weekday name for a Monday-based index (0 = Monday).
  static String weekday(int mondayIndex, {bool short = false}) {
    // 2024-01-01 was a Monday.
    final date = DateTime(2024, 1, 1 + mondayIndex);
    try {
      return DateFormat(short ? 'E' : 'EEEE', Intl.defaultLocale).format(date);
    } catch (_) {
      return DateFormat(short ? 'E' : 'EEEE', 'en_US').format(date);
    }
  }

  /// `1.2k €` / `600 €` — chart axes only; exact figures live in tooltips
  /// and rows.
  static String compact(double value, CurrencyType c) {
    final symbol = c.formatSuffix;
    final sign = value < 0 ? '-' : '';
    final abs = value.abs();
    if (abs >= 1000000) return '$sign${_short(abs / 1000000)}M$symbol';
    if (abs >= 1000) return '$sign${_short(abs / 1000)}k$symbol';
    return '$sign${_short(abs)}$symbol';
  }

  static String _short(double v) {
    final s = v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  /// Rounds a raw axis interval up to the next 1 / 2 / 2.5 / 5 × 10^n.
  static double niceStep(double raw) {
    if (raw <= 0 || !raw.isFinite) return 1;
    final magnitude = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    for (final m in const [1.0, 2.0, 2.5, 5.0]) {
      if (raw <= m * magnitude) return m * magnitude;
    }
    return 10 * magnitude;
  }

  /// `12%` from `0.12`; anything above 999 % is capped (a near-zero base).
  static String percent(double ratio) {
    final p = (ratio.abs() * 100).round();
    return p > 999 ? '999+%' : '$p%';
  }
}
