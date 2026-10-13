import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/repeat_frequency.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/typedefs.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../transaction/data/models/recurring_rule_model.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/ui/wallets_provider.dart';
import 'subscriptions_provider.dart';
import 'widgets/subscription_row.dart';

/// Every recurring rule, scoped to one wallet or all of them. Active rules
/// first, paused below; tap a row to open it on the Transaction page
/// ("Edit subscription", where it can also be stopped), switch to pause.
/// "⊕ New Subscription" opens the Transaction page preset to a monthly
/// repeat on the scoped wallet (the primary one for "All wallets").
@RoutePage()
class SubscriptionsPage extends HookConsumerWidget {
  const SubscriptionsPage({super.key, this.walletId});

  final String? walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final typo = context.typo.inter;

    final scope = useState<String?>(walletId);
    final scopeId = scope.value;

    final rulesAsync = ref.watch(subscriptionsProvider);
    final rules = rulesAsync.value;
    final tagsByRule = ref.watch(subscriptionTagsProvider).value ?? const <String, List<String>>{};
    final wallets = ref.watch(walletsProvider).value ?? const <WalletSummary>[];
    final monthly = ref.watch(monthlySubscriptionTotalProvider(scopeId)).value;
    final base = ref.watch(baseCurrencyProvider);

    final walletsById = <String, WalletSummary>{for (final w in wallets) w.id: w};
    final scopeWallet = scopeId == null ? null : walletsById[scopeId];

    final scoped = rules == null
        ? null
        : scopeId == null
            ? rules
            : rules.where((r) => ruleTouchesWallet(r, scopeId)).toList();
    final active = scoped?.where((r) => r.isActive).toList() ?? const <RecurringRuleModel>[];
    final paused = scoped?.where((r) => !r.isActive).toList() ?? const <RecurringRuleModel>[];

    Future<void> pickScope() async {
      final picked = await _WalletScopeSheet.show(context, wallets: wallets, selectedId: scopeId);
      if (picked == null) return;
      scope.value = picked.walletId;
    }

    Widget row(RecurringRuleModel r) => SubscriptionRow(
          rule: r,
          walletsById: walletsById,
          tags: tagsByRule[r.id] ?? const [],
          onTap: () => context.router.push(TransactionRoute(ruleId: r.id)),
          onToggle: (v) => ref.read(subscriptionsProvider.notifier).setActive(r.id, v),
        );

    // Null wallet → the Transaction page picks the primary (default) wallet.
    void create() => context.router.push(TransactionRoute(walletId: scopeId, repeat: RepeatFrequency.monthly));

    final counts = <(String, Color?)>[
      if (scoped != null && scoped.isNotEmpty) ...[
        (l10n.subscriptions_active_count(active.length), active.isEmpty ? null : UIColorToken.blue),
        (l10n.subscriptions_paused_count(paused.length), null),
      ],
    ];

    return Scaffold(
      appBar: UIAppbar(
        title: l10n.subscriptions_title,
        backTap: () => context.router.maybePop(),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 0),
              child: Column(
                children: [
                  // Same header as the Transaction screen: currency (follows
                  // the scope, not editable) | wallet scope.
                  UiWalletInfoMenu(
                    name: scopeWallet?.name ?? l10n.subscriptions_all_wallets,
                    color: scopeWallet?.color.color ?? context.colors.secondContentColor,
                    currencyType: scopeWallet?.currency ?? base,
                    onSelectWallet: wallets.isEmpty ? null : pickScope,
                  ),
                  if (monthly != null && !monthly.isZero) ...[
                    const UISpace.vert(16),
                    Text(
                      l10n.subscriptions_monthly_total(monthly.format()),
                      textAlign: TextAlign.center,
                      style: typo.subtitle,
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Counts (left) + "⊕ New Subscription" (right), as on the Dashboard.
          // The button carries 4 px of tap padding: its edge lines up with
          // the rows' trailing edge.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(kListHorzPadding, 20, kListHorzPadding - 4, 0),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: UIAnim.fast,
                      child: Text.rich(
                        key: ValueKey('${active.length}-${paused.length}'),
                        TextSpan(
                          children: [
                            for (var i = 0; i < counts.length; i++) ...[
                              if (i > 0) const TextSpan(text: '  ·  '),
                              TextSpan(
                                text: counts[i].$1.toUpperCase(),
                                style: counts[i].$2 == null ? null : TextStyle(color: counts[i].$2),
                              ),
                            ],
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typo.sectionLabel,
                      ),
                    ),
                  ),
                  const UISpace.horz(12),
                  UiIconTextButton(
                    icon: UIIconToken.icons.general.plusCircle,
                    title: l10n.subscriptions_new,
                    color: UIColorToken.blue,
                    onTap: wallets.isEmpty ? null : create,
                  ),
                ],
              ),
            ),
          ),
          if (scoped == null)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(kListHorzPadding, 32, kListHorzPadding, 0),
                child: UiSkeletonList(rows: 5),
              ),
            )
          else if (scoped.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: UiEmptyState(
                image: AppAssets.images.wumbiOo.path,
                title: l10n.subscriptions_empty_title,
                subtitle: l10n.subscriptions_empty_subtitle,
              ).uiFadeSlideIn(offset: 0.06),
            )
          else ...[
            if (active.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: UiSectionLabel(
                  text: l10n.subscriptions_active,
                  padding: const EdgeInsets.fromLTRB(kListHorzPadding, 16, kListHorzPadding, 4),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
                sliver: SliverList.separated(
                  itemCount: active.length,
                  separatorBuilder: (_, _) => const UIDivider(),
                  itemBuilder: (context, index) => row(active[index]),
                ),
              ),
            ],
            if (paused.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: UiSectionLabel(
                  text: l10n.subscriptions_paused,
                  padding: const EdgeInsets.fromLTRB(kListHorzPadding, 24, kListHorzPadding, 4),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
                sliver: SliverList.separated(
                  itemCount: paused.length,
                  separatorBuilder: (_, _) => const UIDivider(),
                  itemBuilder: (context, index) => row(paused[index]),
                ),
              ),
            ],
          ],
          const SliverToBoxAdapter(child: UISpace.vert(48)),
        ],
      ),
    );
  }
}

/// Result of the scope picker: `walletId == null` means "all wallets".
class _ScopeChoice {
  const _ScopeChoice(this.walletId);

  final String? walletId;
}

/// "All wallets" + one row per wallet (badge, name, currency).
abstract class _WalletScopeSheet {
  static Future<_ScopeChoice?> show(
    BuildContext context, {
    required List<WalletSummary> wallets,
    required String? selectedId,
  }) {
    final l10n = context.l10n;
    final fit = wallets.length <= 5;
    return UIModalSheet.modalSheet<_ScopeChoice>(
      context: context,
      title: l10n.subscriptions_title,
      fitContent: fit,
      height: 0.6,
      child: ListView.separated(
        shrinkWrap: fit,
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: wallets.length + 1,
        separatorBuilder: (_, _) => const UIDivider(),
        itemBuilder: (context, index) {
          if (index == 0) {
            return UiListRow(
              leading: UIIcon(UIIconToken.icons.financeEcommerce.wallet02, size: 18),
              title: l10n.subscriptions_all_wallets,
              selected: selectedId == null,
              onTap: () => Navigator.of(context).pop(const _ScopeChoice(null)),
            );
          }
          final w = wallets[index - 1];
          return UiListRow(
            leading: UiCircleColorBadge(color: w.color.color),
            title: w.name,
            subtitle: w.currency.code,
            selected: w.id == selectedId,
            onTap: () => Navigator.of(context).pop(_ScopeChoice(w.id)),
          );
        },
      ),
    );
  }
}
