import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/budget/ui/budgets_provider.dart';
import '../../../features/dashboard/ui/dashboard_notifier.dart';
import '../../../features/debt/ui/debts_provider.dart';
import '../../../features/wallet/ui/wallets_provider.dart';

/// Riverpod 3 pauses a provider as soon as every listener is paused — and a
/// `Consumer` is paused whenever its route is covered by another one
/// (`TickerMode` off). A pushed form therefore leaves the dashboard's
/// providers frozen; the DB write bumps `dbRevisionProvider` but the
/// re-query is deferred until the route is popped, and the screen comes back
/// stale for a frame or more.
///
/// Subscribing from the root widget (always visible) keeps these providers
/// active so every write is reflected immediately, wherever it comes from.
/// Budgets and debts are here too: the Dashboard tabs only build the active
/// list, and an auto-disposed source would otherwise re-query the DB on
/// every tab switch.
void keepAppStateAlive(WidgetRef ref) {
  ref.listen(walletsProvider, (_, __) {});
  ref.listen(dashboardProvider, (_, __) {});
  ref.listen(budgetsProvider, (_, __) {});
  ref.listen(debtsOverviewProvider, (_, __) {});
}
