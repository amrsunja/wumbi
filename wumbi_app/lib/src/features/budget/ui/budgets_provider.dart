import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/providers/data/db_revision_provider.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../data/budget_metrics.dart';
import '../data/budget_repository.dart';
import '../data/models/budget_model.dart';

/// Every live budget measured over its running period (custom budgets: their
/// single period). Re-queried after every write anywhere (`dbRevisionProvider`)
/// and when the base currency changes; `App` invalidates it when the app
/// resumes on a new local day so "per day" and periods roll over.
final budgetsProvider =
    AsyncNotifierProvider.autoDispose<BudgetsNotifier, List<BudgetProgress>>(BudgetsNotifier.new);

class BudgetsNotifier extends AsyncNotifier<List<BudgetProgress>> {
  @override
  Future<List<BudgetProgress>> build() async {
    ref.watch(dbRevisionProvider);
    ref.watch(baseCurrencyProvider);
    final result = await ref.read(budgetRepositoryProvider).listProgress();
    return result.when((list) => list, (error) => throw error);
  }
}

/// True for budgets that belong on the Dashboard / Wallet Details: running
/// now. Custom budgets that have not started or already ended live on the
/// Budgets page only.
bool isRunningBudget(BudgetProgress p) =>
    p.status != BudgetStatus.notStarted && p.status != BudgetStatus.finished;

/// Dashboard "Budgets" tab: every running budget, most urgent first, and how
/// many live budgets exist (for "All budgets ›" when some are not running).
typedef DashboardBudgets = ({List<BudgetProgress> running, int total});

final dashboardBudgetsProvider = Provider.autoDispose<DashboardBudgets?>((ref) {
  final all = ref.watch(budgetsProvider).value;
  if (all == null) return null;
  final running = all.where(isRunningBudget).toList()..sort(compareBudgetSeverity);
  return (running: running, total: all.length);
});

/// Running budgets explicitly scoped to [walletId] (its `budget_wallets`
/// contains it), most urgent first. "All wallets" budgets are not listed here:
/// they would show on every wallet.
final walletBudgetsProvider = Provider.autoDispose.family<List<BudgetProgress>, String>((ref, walletId) {
  final all = ref.watch(budgetsProvider).value ?? const <BudgetProgress>[];
  return all.where((p) => isRunningBudget(p) && p.budget.walletIds.contains(walletId)).toList()
    ..sort(compareBudgetSeverity);
});
