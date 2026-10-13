import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/enums/debt_direction.dart';
import 'models/person_model.dart';

/// Direction of the money on the Transaction screen with a person selected.
enum DebtFlow {
  /// GAVE — money left the user's wallet (an expense draft).
  outgoing,

  /// GOT — money came into the user's wallet (an income draft).
  incoming;

  /// The debt direction a *new* debt gets for this flow.
  DebtDirection get opensDirection => this == outgoing ? DebtDirection.lent : DebtDirection.borrowed;

  /// The debt direction this flow pays back.
  DebtDirection get repaysDirection => this == outgoing ? DebtDirection.borrowed : DebtDirection.lent;

  /// True when [direction] is the side this flow can open or repay
  /// (lent: opened by GAVE, repaid by GOT; borrowed: the opposite).
  bool canOpen(DebtDirection direction) => direction == opensDirection;
  bool canRepay(DebtDirection direction) => direction == repaysDirection;
}

/// Outcome of a GAVE / GOT with a person (spec B&D §7.2).
sealed class DebtResolution {
  const DebtResolution();
}

/// No debt to pay back on that side: the money opens a new debt.
class OpensDebt extends DebtResolution {
  const OpensDebt(this.direction);
  final DebtDirection direction;

  @override
  bool operator ==(Object other) => other is OpensDebt && other.direction == direction;

  @override
  int get hashCode => Object.hash(OpensDebt, direction);

  @override
  String toString() => 'OpensDebt(${direction.name})';
}

/// The money pays back open debts of [direction] (FIFO, [A3]).
class RepaysDebts extends DebtResolution {
  const RepaysDebts(this.direction);
  final DebtDirection direction;

  @override
  bool operator ==(Object other) => other is RepaysDebts && other.direction == direction;

  @override
  int get hashCode => Object.hash(RepaysDebts, direction);

  @override
  String toString() => 'RepaysDebts(${direction.name})';
}

/// The single decision rule shared by the Transaction screen hint (before
/// commit) and `DebtRepository` (inside the write, against fresh data), so
/// the hint can never promise something the write does not do.
///
/// | flow | person has open…        | result                 |
/// |------|-------------------------|------------------------|
/// | GAVE | debts I owe them        | repay my debts (FIFO)  |
/// | GAVE | none of those           | new `lent` debt        |
/// | GOT  | debts they owe me       | repay theirs (FIFO)    |
/// | GOT  | none of those           | new `borrowed` debt    |
DebtResolution resolveDebtFlow(PersonBalance balance, DebtFlow flow) => switch (flow) {
      DebtFlow.outgoing =>
        balance.iOwe.isNotEmpty ? const RepaysDebts(DebtDirection.borrowed) : const OpensDebt(DebtDirection.lent),
      DebtFlow.incoming =>
        balance.owedToMe.isNotEmpty ? const RepaysDebts(DebtDirection.lent) : const OpensDebt(DebtDirection.borrowed),
    };

// ------------------------------------------------------------------ allocation

/// An open debt a repayment may go to, already in FIFO order.
class RepaymentTarget {
  const RepaymentTarget({required this.debtId, required this.remaining});
  final String debtId;

  /// Remaining in the debt's own currency (> 0).
  final Money remaining;
}

/// Share of a repayment assigned to one debt.
class RepaymentShare {
  const RepaymentShare({required this.debtId, required this.amount, required this.walletAmountMinor});
  final String debtId;

  /// In the debt's currency — what is stored in `debt_payments.amount_minor`.
  final Money amount;

  /// The part of the wallet amount it consumed.
  final int walletAmountMinor;

  @override
  String toString() => 'RepaymentShare($debtId, $amount, w=$walletAmountMinor)';
}

/// Rate lookup `to per 1 from`; throws `FxUnavailableException` when missing.
typedef RateLookup = double Function(CurrencyType from, CurrencyType to);

/// The repayment does not fit: [maxRemaining] is all that is open on the
/// targeted side, in [maxRemaining]'s currency ([A1] — never auto-creates an
/// opposite debt).
class OverRepayment implements Exception {
  const OverRepayment(this.maxRemaining);
  final Money maxRemaining;

  @override
  String toString() => 'OverRepayment(max: $maxRemaining)';
}

/// Splits a wallet amount over open debts, oldest first (spec B&D §7.3).
///
/// * same currency → exact integer arithmetic, no FX;
/// * cross currency → one conversion per debt with [rate]; a residue of at
///   most one minor unit in the debt currency is absorbed by the payment so a
///   "full" cross-currency repayment never leaves a 0.01 debt open;
/// * when the user typed the amount in the debt's own currency ([original])
///   and there is a single target, that typed amount is used verbatim.
///
/// Throws [OverRepayment] when money would be left over. Pure: no I/O.
List<RepaymentShare> allocateRepayment({
  required Money walletAmount,
  Money? original,
  required List<RepaymentTarget> targets,
  required RateLookup rate,
}) {
  if (targets.isEmpty) throw OverRepayment(Money.zero(walletAmount.currency));
  final w = walletAmount.currency;

  // Exact path: typed in the debt currency, one debt.
  if (targets.length == 1 && original != null && original.currency == targets.single.remaining.currency) {
    final t = targets.single;
    if (original.minor > t.remaining.minor) throw OverRepayment(t.remaining);
    return [RepaymentShare(debtId: t.debtId, amount: original, walletAmountMinor: walletAmount.minor)];
  }

  final shares = <RepaymentShare>[];
  var left = walletAmount.minor;
  for (final t in targets) {
    if (left <= 0) break;
    final d = t.remaining.currency;
    final remD = t.remaining.minor;
    int takeW;
    int takeD;
    if (d == w) {
      takeW = left < remD ? left : remD;
      takeD = takeW;
    } else {
      final remW = convertMinor(remD, d, w, rate(d, w));
      takeW = left < remW ? left : remW;
      if (takeW == remW) {
        takeD = remD;
      } else {
        takeD = convertMinor(takeW, w, d, rate(w, d));
        // Rounding residue ≤ 1 minor unit closes the debt.
        if (remD - takeD <= 1) takeD = remD;
        if (takeD > remD) takeD = remD;
      }
    }
    if (takeD > 0) {
      shares.add(RepaymentShare(debtId: t.debtId, amount: Money(takeD, d), walletAmountMinor: takeW));
    }
    left -= takeW;
  }
  if (left > 0) throw OverRepayment(_maxRemaining(targets, w, rate));
  return shares;
}

/// All that can be repaid: in the debts' currency when they share one,
/// otherwise in the wallet currency.
Money _maxRemaining(List<RepaymentTarget> targets, CurrencyType w, RateLookup rate) {
  final currencies = targets.map((t) => t.remaining.currency).toSet();
  if (currencies.length == 1) {
    final c = currencies.single;
    return Money(targets.fold(0, (sum, t) => sum + t.remaining.minor), c);
  }
  var total = 0;
  for (final t in targets) {
    final c = t.remaining.currency;
    total += c == w ? t.remaining.minor : convertMinor(t.remaining.minor, c, w, rate(c, w));
  }
  return Money(total, w);
}
