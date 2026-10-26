import '../../../core/money/money.dart';

enum MascotReactionKind { income, expense, transfer, lent, debtClosed, debtForgiven, firstWallet, budgetCreated }

/// A just-done action the hamster reacts to (2.5 s) on the screen the user
/// comes back to (spec §1.4).
class MascotReaction {
  const MascotReaction(this.kind, {this.amount, required this.at});

  final MascotReactionKind kind;

  /// Income: in the base currency when a rate was cached (big-income check).
  final Money? amount;
  final DateTime at;

  /// Older reactions are dropped instead of played.
  static const Duration freshFor = Duration(minutes: 10);

  static const Duration playFor = Duration(milliseconds: 2500);

  bool isFresh(DateTime now) => now.difference(at) < freshFor;
}
