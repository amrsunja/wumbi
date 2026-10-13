import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/providers/data/db_revision_provider.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../data/debt_repository.dart';
import '../data/models/debt_model.dart';
import '../data/models/person_model.dart';

/// Debts page model. Re-queried after every write anywhere and on base
/// currency change; `App` invalidates it when the app resumes on a new day
/// (overdue flags).
final debtsOverviewProvider =
    AsyncNotifierProvider.autoDispose<DebtsOverviewNotifier, DebtsOverview>(DebtsOverviewNotifier.new);

class DebtsOverviewNotifier extends AsyncNotifier<DebtsOverview> {
  @override
  Future<DebtsOverview> build() async {
    ref.watch(dbRevisionProvider);
    final base = ref.watch(baseCurrencyProvider);
    final result = await ref.read(debtRepositoryProvider).overview(base: base);
    return result.when((o) => o, (error) => throw error);
  }
}

/// Dashboard pill: open debts and how many are overdue.
final openDebtsBadgeProvider = Provider.autoDispose<({int count, int overdueCount})>((ref) {
  final o = ref.watch(debtsOverviewProvider).value;
  if (o == null) return (count: 0, overdueCount: 0);
  return (count: o.openCount, overdueCount: o.overdueCount);
});

/// Dashboard "Debts" tab: every open debt of both sides — overdue first, then
/// due soonest, then newest — and whether any debt exists at all (settled
/// included) for "All debts ›".
typedef DashboardDebts = ({List<DebtSummary> open, bool hasAny});

final dashboardDebtsProvider = Provider.autoDispose<DashboardDebts?>((ref) {
  final o = ref.watch(debtsOverviewProvider).value;
  if (o == null) return null;
  final open = [...o.openLent, ...o.openBorrowed]..sort(_compareOpenDebts);
  return (
    open: open,
    hasAny: open.isNotEmpty || o.settledLent.isNotEmpty || o.settledBorrowed.isNotEmpty,
  );
});

int _compareOpenDebts(DebtSummary a, DebtSummary b) {
  if (a.overdue != b.overdue) return a.overdue ? -1 : 1;
  final ad = a.debt.dueDate;
  final bd = b.debt.dueDate;
  if (ad != null && bd != null) {
    final byDue = ad.compareTo(bd);
    if (byDue != 0) return byDue;
  } else if (ad != null) {
    return -1;
  } else if (bd != null) {
    return 1;
  }
  return b.debt.openedAt.compareTo(a.debt.openedAt);
}

/// Open balance with one person (Transaction screen hint, picker rows).
final personBalanceProvider = FutureProvider.autoDispose.family<PersonBalance, String>((ref, personId) async {
  ref.watch(dbRevisionProvider);
  final base = ref.watch(baseCurrencyProvider);
  final result = await ref.read(debtRepositoryProvider).personBalance(personId, base: base);
  return result.when((b) => b, (error) => throw error);
});

/// Debt sheet model (closed debts too).
final debtDetailsProvider = FutureProvider.autoDispose.family<DebtDetails, String>((ref, debtId) async {
  ref.watch(dbRevisionProvider);
  final base = ref.watch(baseCurrencyProvider);
  final result = await ref.read(debtRepositoryProvider).byId(debtId, base: base);
  return result.when((d) => d, (error) => throw error);
});
