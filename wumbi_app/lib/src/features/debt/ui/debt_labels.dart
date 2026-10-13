import '../../../core/locale/l10n.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/enums/debt_close_reason.dart';
import '../../../core/utils/enums/debt_direction.dart';
import '../../../core/utils/enums/debt_role.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../data/debt_resolution.dart';
import '../data/models/debt_model.dart';
import '../data/models/person_model.dart';

/// Every user-visible debt string is built here, once, so the Transaction
/// screen, Debt Details, the Debts page and the transaction lists agree.
abstract class DebtLabels {
  /// One side of a balance: the exact amount when a single currency is open,
  /// else the base total (≈ when some currency could not be converted).
  static String side(Map<CurrencyType, int> side, Money? base, {bool incomplete = false}) {
    if (side.length == 1) return Money(side.values.single, side.keys.single).format();
    final b = base;
    if (b == null) return '—';
    return incomplete ? '≈ ${b.format()}' : b.format();
  }

  /// Hint above the numpad with a person selected (spec B&D §8.1). Built
  /// from [resolveDebtFlow] for both flows — the very rule the write uses.
  static String hint(AppLocale l10n, String name, PersonBalance? balance) {
    final b = balance ?? PersonBalance(personId: '');
    final got = resolveDebtFlow(b, DebtFlow.incoming);
    final gave = resolveDebtFlow(b, DebtFlow.outgoing);
    final owed = side(b.owedToMe, b.owedToMeBase, incomplete: b.incomplete);
    final owe = side(b.iOwe, b.iOweBase, incomplete: b.incomplete);
    if (got is RepaysDebts && gave is RepaysDebts) return l10n.debt_hint_both(name, owed, owe);
    if (got is RepaysDebts) return l10n.debt_hint_owes_you(name, owed);
    if (gave is RepaysDebts) return l10n.debt_hint_you_owe(name, owe);
    return l10n.debt_hint_none(name);
  }

  /// Toast after a debt-linked commit (spec B&D §8.1).
  static String commitToast(AppLocale l10n, DebtCommitSummary s) {
    final amount = s.amount.format();
    final left = s.leftAfter;
    return switch (s.kind) {
      DebtCommitKind.openedLent => l10n.debt_toast_lent(amount, s.personName),
      DebtCommitKind.openedBorrowed => l10n.debt_toast_borrowed(amount, s.personName),
      DebtCommitKind.repaidIn => left == null
          ? l10n.debt_toast_returned_settled(s.personName, amount)
          : l10n.debt_toast_returned(s.personName, amount, left.format()),
      DebtCommitKind.repaidOut => left == null
          ? l10n.debt_toast_paid_back_settled(amount, s.personName)
          : l10n.debt_toast_paid_back(amount, s.personName, left.format()),
    };
  }

  /// "Loan" / "Return" pill on debt-linked list rows.
  static String? rowBadge(AppLocale l10n, TransactionRow row) => switch (row.debtRole) {
        DebtRole.principal => l10n.debt_badge_loan,
        DebtRole.repayment => l10n.debt_badge_return,
        null => null,
      };

  /// Title for a debt-linked row without description: "Lent to Ahmed",
  /// "Borrowed from Ahmed", "Ahmed paid back", "Paid back Ahmed".
  static String? rowTitle(AppLocale l10n, TransactionRow row) {
    final name = row.personName;
    final role = row.debtRole;
    if (name == null || role == null) return null;
    final incoming = row.transaction.type == TransactionType.income;
    return switch (role) {
      DebtRole.principal => incoming ? l10n.debt_title_borrowed_from(name) : l10n.debt_title_lent_to(name),
      DebtRole.repayment => incoming ? l10n.debt_title_paid_back_by(name) : l10n.debt_title_paid_back_to(name),
    };
  }

  /// "€100 left" for an open debt, "Settled" / "Forgiven" otherwise.
  static String remaining(AppLocale l10n, DebtSummary s) {
    if (s.isOpen) return l10n.debt_left(s.remaining.format());
    return s.debt.closeReason == DebtCloseReason.forgiven ? l10n.debt_forgiven_label : l10n.debt_settled_label;
  }

  /// "Ahmed owes you €130" / "You owe Sara €20" for a direction.
  static String owes(AppLocale l10n, DebtDirection direction, String name, String amount) =>
      direction == DebtDirection.lent ? l10n.debt_owes_you(name, amount) : l10n.debt_you_owe(name, amount);
}
