import 'package:collection/collection.dart';

import '../../../../core/utils/enums/transaction_type.dart';

/// Sort order for a wallet's transaction list. Upcoming rows always come
/// first, whatever the sort (they form their own group in the UI).
enum TransactionSort {
  dateDesc,
  dateAsc,
  amountDesc,
  amountAsc;

  bool get isDefault => this == dateDesc;
  bool get byAmount => this == amountDesc || this == amountAsc;
}

/// Filter for a wallet's transaction list. Empty sets / null bounds = no
/// constraint. Plain immutable class (no codegen) — it lives in UI state and
/// is passed straight to the datasource.
class TransactionFilter {
  const TransactionFilter({
    this.types = const {},
    this.from,
    this.to,
    this.tagIds = const {},
    this.upcomingOnly = false,
  });

  static const none = TransactionFilter();

  /// Empty = every type.
  final Set<TransactionType> types;

  /// Inclusive day bounds (date part only; time is ignored).
  final DateTime? from;
  final DateTime? to;

  /// Match transactions carrying ANY of these tags. Empty = no tag filter.
  final Set<String> tagIds;

  /// Only rows with `status = 'upcoming'`.
  final bool upcomingOnly;

  bool get isEmpty => types.isEmpty && from == null && to == null && tagIds.isEmpty && !upcomingOnly;
  bool get isNotEmpty => !isEmpty;

  /// Number of active constraints (badge on the filter button).
  int get activeCount =>
      (types.isEmpty ? 0 : 1) + (from == null && to == null ? 0 : 1) + (tagIds.isEmpty ? 0 : 1) + (upcomingOnly ? 1 : 0);

  TransactionFilter copyWith({
    Set<TransactionType>? types,
    DateTime? from,
    DateTime? to,
    bool clearFrom = false,
    bool clearTo = false,
    Set<String>? tagIds,
    bool? upcomingOnly,
  }) =>
      TransactionFilter(
        types: types ?? this.types,
        from: clearFrom ? null : (from ?? this.from),
        to: clearTo ? null : (to ?? this.to),
        tagIds: tagIds ?? this.tagIds,
        upcomingOnly: upcomingOnly ?? this.upcomingOnly,
      );

  @override
  bool operator ==(Object other) =>
      other is TransactionFilter &&
      const SetEquality<TransactionType>().equals(other.types, types) &&
      other.from == from &&
      other.to == to &&
      const SetEquality<String>().equals(other.tagIds, tagIds) &&
      other.upcomingOnly == upcomingOnly;

  @override
  int get hashCode => Object.hash(
        const SetEquality<TransactionType>().hash(types),
        from,
        to,
        const SetEquality<String>().hash(tagIds),
        upcomingOnly,
      );
}
