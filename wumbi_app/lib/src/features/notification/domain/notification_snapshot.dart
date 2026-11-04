import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/enums/debt_direction.dart';
import '../../../core/utils/enums/repeat_frequency.dart';
import '../../../core/utils/enums/transaction_type.dart';

/// Everything the planner reads, gathered once when the app goes to the
/// background. Wumbi is local-first: nothing changes in the database until
/// the app is opened again (which re-plans), so texts computed now stay true
/// at delivery. Recurring and upcoming rows — the only things that "happen"
/// on their own — are projected into [moves].
class NotificationSnapshot {
  const NotificationSnapshot({
    required this.now,
    required this.base,
    this.wallets = const [],
    this.moves = const [],
    this.debts = const [],
    this.budgets = const [],
    this.recordTimes = const [],
    this.week,
  });

  final DateTime now;
  final CurrencyType base;
  final List<SnapshotWallet> wallets;

  /// Upcoming rows and rule occurrences of the horizon, any order.
  final List<PlannedMove> moves;

  /// Open debts only.
  final List<SnapshotDebt> debts;

  /// Running budgets only, in their display order.
  final List<SnapshotBudget> budgets;

  /// When the user's own entries were created (last ~30 days): habits,
  /// streak and the learned evening time.
  final List<DateTime> recordTimes;

  /// The current week (Monday start), for the Sunday recap.
  final SnapshotWeek? week;

  SnapshotWallet? wallet(String? id) {
    if (id == null) return null;
    for (final w in wallets) {
      if (w.id == id) return w;
    }
    return null;
  }
}

class SnapshotWallet {
  const SnapshotWallet({required this.id, required this.name, required this.balance});

  final String id;
  final String name;

  /// Posted balance, wallet currency.
  final Money balance;
}

enum PlannedMoveOrigin {
  /// A recurring rule's future occurrence.
  rule,

  /// A one-off row dated in the future (`status = upcoming`).
  upcoming,
}

/// How a planned move changes one wallet, in that wallet's minor units.
class WalletEffect {
  const WalletEffect(this.walletId, this.minor);

  final String walletId;
  final int minor;
}

/// Money expected to move on [date] by itself.
class PlannedMove {
  const PlannedMove({
    required this.id,
    required this.origin,
    required this.type,
    required this.name,
    required this.date,
    required this.amount,
    this.walletId,
    this.frequency,
    this.effects = const [],
  });

  /// Rule id or transaction id.
  final String id;
  final PlannedMoveOrigin origin;
  final TransactionType type;

  /// The description; may be empty.
  final String name;
  final DateTime date;

  /// Positive, in the record's currency.
  final Money amount;

  /// The wallet charged / credited (transfers: the source).
  final String? walletId;

  /// Rules only.
  final RepeatFrequency? frequency;
  final List<WalletEffect> effects;
}

class SnapshotDebt {
  const SnapshotDebt({
    required this.id,
    required this.personName,
    required this.direction,
    required this.remaining,
    required this.openedAt,
    this.dueDate,
  });

  final String id;
  final String personName;
  final DebtDirection direction;

  /// Still to settle, debt currency (positive).
  final Money remaining;
  final DateTime openedAt;
  final DateTime? dueDate;
}

class SnapshotBudget {
  const SnapshotBudget({required this.id, required this.name, required this.free, required this.periodEnd});

  final String id;
  final String name;

  /// `max(0, limit − spent − planned)` of the running period.
  final Money free;

  /// Exclusive: local midnight after the period's last day.
  final DateTime periodEnd;
}

class SnapshotWeek {
  const SnapshotWeek({required this.start, required this.spent, this.previous, this.topTag});

  /// Monday, local midnight.
  final DateTime start;

  /// Expenses so far (base currency), planned ones of the rest of the week
  /// included.
  final Money spent;

  /// Last week's expenses; null without any.
  final Money? previous;

  /// The root tag that took the most.
  final String? topTag;
}
