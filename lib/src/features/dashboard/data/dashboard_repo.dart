import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/fx/fx_service.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/providers/data/fx_provider.dart';
import '../../wallet/data/models/wallet_model.dart';

final dashboardRepoProvider = Provider<DashboardRepo>(
  (ref) => DashboardRepo(fx: ref.read(fxServiceProvider)),
);

class DashboardData {
  const DashboardData({
    required this.total,
    required this.walletCount,
    required this.wallets,
    required this.unconvertible,
    required this.ratesStale,
  });

  /// Net worth in the base currency (wallets without a rate excluded).
  final Money total;

  /// [A5] all non-deleted wallets.
  final int walletCount;
  final List<WalletSummary> wallets;

  /// Currencies excluded from the total because no rate is cached.
  final List<CurrencyType> unconvertible;

  /// Any rate older than 24 h.
  final bool ratesStale;

  bool get isEmpty => wallets.isEmpty;
}

/// Computes the dashboard total from cached rates only — the UI never waits
/// on the network. `warmUp` runs separately.
class DashboardRepo {
  DashboardRepo({required this.fx});

  final FxService fx;

  Future<DashboardData> build(List<WalletSummary> wallets, CurrencyType base) async {
    var total = 0;
    final unconvertible = <CurrencyType>{};
    var stale = false;
    final rates = <CurrencyType, FxRate?>{};

    for (final w in wallets) {
      if (w.currency == base) {
        total += w.balance.minor;
        continue;
      }
      final rate = rates.containsKey(w.currency)
          ? rates[w.currency]
          : rates[w.currency] = await fx.cachedRate(w.currency, base);
      if (rate == null) {
        unconvertible.add(w.currency);
        continue;
      }
      if (rate.isStale) stale = true;
      total += convertMinor(w.balance.minor, w.currency, base, rate.rate);
    }

    return DashboardData(
      total: Money(total, base),
      walletCount: wallets.length,
      wallets: wallets,
      unconvertible: unconvertible.toList(),
      ratesStale: stale,
    );
  }
}
