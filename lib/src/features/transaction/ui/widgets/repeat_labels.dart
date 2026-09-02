import '../../../../core/locale/l10n.dart';
import '../../../../core/utils/enums/repeat_frequency.dart';

/// "Monthly" etc. (chip / list labels).
String repeatShortLabel(AppLocale l10n, RepeatFrequency f) => switch (f) {
      RepeatFrequency.never => l10n.transaction_repeat,
      RepeatFrequency.daily => l10n.repeat_daily,
      RepeatFrequency.weekly => l10n.repeat_weekly,
      RepeatFrequency.monthly => l10n.repeat_monthly,
      RepeatFrequency.yearly => l10n.repeat_yearly,
    };

/// "Every month" etc. (picker rows).
String repeatLongLabel(AppLocale l10n, RepeatFrequency f) => switch (f) {
      RepeatFrequency.never => l10n.repeat_never,
      RepeatFrequency.daily => l10n.repeat_every_day,
      RepeatFrequency.weekly => l10n.repeat_every_week,
      RepeatFrequency.monthly => l10n.repeat_every_month,
      RepeatFrequency.yearly => l10n.repeat_every_year,
    };
