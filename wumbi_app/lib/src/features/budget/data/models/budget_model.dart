import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/enums/budget_period_type.dart';
import '../../../../core/utils/enums/rollover_mode.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';
import '../budget_metrics.dart';
import '../budget_period.dart';

part 'budget_model.freezed.dart';

/// A standalone spending limit (spec B&D §1.1). Scope = [walletIds] ∪
/// [tagIds]; an empty set means "any" on that axis. Spent / remaining are
/// never stored — they are derived from transactions for each period.
@freezed
abstract class BudgetModel with _$BudgetModel {
  const BudgetModel._();

  const factory BudgetModel({
    required String id,
    required String name,
    required int limitMinor,
    required CurrencyType currency,
    required BudgetPeriodType period,

    /// Local midnight of the first day of the first period. Monthly: its day
    /// is the start day; weekly: its weekday is the start weekday.
    required DateTime anchorDate,

    /// Custom only: exclusive end (local midnight after the last day).
    DateTime? endDate,
    @Default(RolloverMode.none) RolloverMode rollover,
    @Default(true) bool includePlanned,
    @Default(0) int sortOrder,

    /// Empty = every wallet.
    @Default(<String>{}) Set<String> walletIds,

    /// Empty = any tag (or none). A transaction matches with ANY of them.
    @Default(<String>{}) Set<String> tagIds,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _BudgetModel;

  /// Scope links are not columns: they are loaded from `budget_wallets` /
  /// `budget_tags` by the datasource and attached with `copyWith`.
  factory BudgetModel.fromRow(Map<String, Object?> r) => BudgetModel(
        id: r[SQLiteConfig.id] as String,
        name: r[SQLiteConfig.budgetName] as String,
        limitMinor: r[SQLiteConfig.budgetLimitMinor] as int,
        currency: CurrencyType.fromCode(r[SQLiteConfig.budgetCurrency] as String?),
        period: BudgetPeriodType.fromString(r[SQLiteConfig.budgetPeriod] as String),
        anchorDate: DateTimeExtension.fromEpochMs(r[SQLiteConfig.budgetAnchorDate] as int),
        endDate: r[SQLiteConfig.budgetEndDate] == null
            ? null
            : DateTimeExtension.fromEpochMs(r[SQLiteConfig.budgetEndDate] as int),
        rollover: RolloverMode.fromString(r[SQLiteConfig.budgetRollover] as String?),
        includePlanned: r[SQLiteConfig.budgetIncludePlanned] == 1,
        sortOrder: (r[SQLiteConfig.budgetSortOrder] as int?) ?? 0,
        createdAt: DateTimeExtension.fromEpochMs(r[SQLiteConfig.createdAt] as int),
        updatedAt: DateTimeExtension.fromEpochMs(r[SQLiteConfig.updatedAt] as int),
        deletedAt: r[SQLiteConfig.deletedAt] == null
            ? null
            : DateTimeExtension.fromEpochMs(r[SQLiteConfig.deletedAt] as int),
      );

  Map<String, Object?> toRow() => {
        SQLiteConfig.id: id,
        SQLiteConfig.budgetName: name,
        SQLiteConfig.budgetLimitMinor: limitMinor,
        SQLiteConfig.budgetCurrency: currency.code,
        SQLiteConfig.budgetPeriod: period.dbValue,
        SQLiteConfig.budgetAnchorDate: anchorDate.epochMs,
        SQLiteConfig.budgetEndDate: endDate?.epochMs,
        SQLiteConfig.budgetRollover: rollover.dbValue,
        SQLiteConfig.budgetIncludePlanned: includePlanned ? 1 : 0,
        SQLiteConfig.budgetSortOrder: sortOrder,
        SQLiteConfig.createdAt: createdAt.epochMs,
        SQLiteConfig.updatedAt: updatedAt.epochMs,
        SQLiteConfig.deletedAt: deletedAt?.epochMs,
      };

  Money get limit => Money(limitMinor, currency);
}

/// What the budget form hands to the repository (no ids, no timestamps).
@freezed
abstract class BudgetDraft with _$BudgetDraft {
  const factory BudgetDraft({
    required String name,
    required Money limit,
    required BudgetPeriodType period,
    required DateTime anchorDate,

    /// Custom only, exclusive (chosen last day + 1).
    DateTime? endDate,
    @Default(RolloverMode.none) RolloverMode rollover,
    @Default(true) bool includePlanned,
    @Default(<String>{}) Set<String> walletIds,
    @Default(<String>{}) Set<String> tagIds,
  }) = _BudgetDraft;
}

/// A budget measured over one period (spec B&D §5.5). All money is in the
/// budget currency; amounts in other currencies were converted with cached
/// rates, or skipped and flagged [incomplete].
@freezed
abstract class BudgetProgress with _$BudgetProgress {
  const BudgetProgress._();

  const factory BudgetProgress({
    required BudgetModel budget,
    required BudgetPeriod period,

    /// True when `now` is inside [period].
    required bool isCurrent,

    /// Effective limit = budget limit + [carry].
    required Money limit,
    required Money carry,
    required Money spent,
    required Money planned,

    /// `limit − spent`, may be negative.
    required Money remaining,

    /// `max(0, limit − spent − planned)`.
    required Money free,
    Money? perDay,
    Money? forecast,

    /// `limit × timeRatio − spent`: positive = under pace by that much.
    required Money paceDelta,
    required int daysLeft,
    required double timeRatio,
    required double spentRatio,
    required BudgetStatus status,
    @Default(false) bool incomplete,

    /// Active subscriptions with occurrences left in the running period, and
    /// their share of [planned] (details page: "2 subscriptions · €45").
    @Default(0) int subscriptionCount,
    Money? subscriptionPlanned,
  }) = _BudgetProgress;

  /// Share of the effective limit committed by planned rows (bar segment).
  double get plannedRatio => limit.minor <= 0 ? 0 : (planned.minor / limit.minor).clamp(0.0, 1.0);

  bool get isOver => status == BudgetStatus.over;
}

/// Dashboard / toast ordering: `over` → `atRisk` → `ok` (then not-started /
/// finished), ties by spent ratio, highest first.
int compareBudgetSeverity(BudgetProgress a, BudgetProgress b) {
  final bySeverity = a.status.severity.compareTo(b.status.severity);
  if (bySeverity != 0) return bySeverity;
  return b.spentRatio.compareTo(a.spentRatio);
}
