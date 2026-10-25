import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/repeat_frequency.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/hooks/use_swipe_tabs.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../transaction/data/models/recurring_rule_model.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/ui/wallets_provider.dart';
import 'subscriptions_provider.dart';
import 'widgets/subscription_row.dart';

/// Room under each tab list so the last row clears the floating button.
const double _kListBottomInset = 96;

enum _SubscriptionTab { active, paused }

/// `/subscriptions` — same anatomy as Tag Details: a fixed header (wallet
/// scope, counts, monthly spend, Active | Paused tabs) and one scrollable tab
/// body (swipe or tap to switch tabs). Tap a row to open it on the Transaction page ("Edit subscription",
/// where it can also be stopped); the switch pauses / resumes it, moving it
/// to the other tab. The "New Subscription" FAB opens the Transaction page
/// preset to a monthly repeat on the scoped wallet (the primary one for
/// "All wallets").
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
    final tabs = useSwipeTabs();

    final rules = ref.watch(subscriptionsProvider).value;
    final tagsByRule = ref.watch(subscriptionTagsProvider).value ?? const <String, List<String>>{};
    final wallets = ref.watch(walletsProvider).value ?? const <WalletSummary>[];
    final monthly = ref.watch(monthlySubscriptionTotalProvider(scopeId)).value;
    final base = ref.watch(baseCurrencyProvider);
    final showMascot = ref.watch(showMascotProvider);

    final walletsById = <String, WalletSummary>{for (final w in wallets) w.id: w};
    final scopeWallet = scopeId == null ? null : walletsById[scopeId];

    final scoped = rules == null
        ? null
        : scopeId == null
            ? rules
            : rules.where((r) => ruleTouchesWallet(r, scopeId)).toList();
    final active = scoped?.where((r) => r.isActive).toList();
    final paused = scoped?.where((r) => !r.isActive).toList();

    Future<void> pickScope() async {
      final picked = await _WalletScopeSheet.show(context, wallets: wallets, selectedId: scopeId);
      if (picked == null) return;
      scope.value = picked.walletId;
    }

    // Null wallet → the Transaction page picks the primary (default) wallet.
    Future<void> create() =>
        context.router.push(TransactionRoute(walletId: scopeId, repeat: RepeatFrequency.monthly));

    Widget row(RecurringRuleModel r) => SubscriptionRow(
          key: ValueKey('rule-${r.id}'),
          rule: r,
          walletsById: walletsById,
          tags: tagsByRule[r.id] ?? const [],
          showWallet: scopeId == null,
          onTap: () => context.router.push(TransactionRoute(ruleId: r.id)),
          onToggle: (v) => ref.read(subscriptionsProvider.notifier).setActive(r.id, v),
        );

    final hasAny = scoped?.isNotEmpty ?? false;

    return Scaffold(
      appBar: UIAppbar(
        title: l10n.subscriptions_title,
        backTap: () => context.router.maybePop(),
      ),
      floatingActionButton: wallets.isEmpty ? null : UiFab(onTap: create, label: l10n.subscriptions_new),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixed header: scope, counts, monthly spend, tabs.
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(kListHorzPadding, 8, kListHorzPadding, 15),
                child: Column(
                  children: [
                    // Currency follows the scope (not editable) | wallet scope.
                    UiWalletInfoMenu(
                      name: scopeWallet?.name ?? l10n.subscriptions_all_wallets,
                      color: scopeWallet?.color.color ?? context.colors.secondContentColor,
                      currencyType: scopeWallet?.currency ?? base,
                      onSelectWallet: wallets.isEmpty ? null : pickScope,
                    ),
                    const UISpace.vert(22),
                    if (monthly == null)
                      const SizedBox(height: 54)
                    else
                      UiTotalAmount(money: monthly, animated: true),
                    const UISpace.vert(6),
                    Text(
                      active == null || paused == null || !hasAny
                          ? ''
                          : '${l10n.subscriptions_active_count(active.length)} · '
                              '${l10n.subscriptions_paused_count(paused.length)}',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typo.caption,
                    ),
                    const UISpace.vert(24),
                    UiSegmentedToggle(
                      expanded: true,
                      labels: [l10n.subscriptions_active, l10n.subscriptions_paused],
                      counts: [active?.length, paused?.length],
                      selectedIndex: tabs.index,
                      onChanged: tabs.onTabTap,
                    ),
                  ],
                ),
              ),
              if (showMascot)
                const Positioned(
                  right: 8,
                  top: 4,
                  child: UIWumbiLook(key: ValueKey('wumbi-subscriptions')),
                ),
            ],
          ),
          // Swipeable tab bodies (only they scroll). Pages are not kept
          // alive, so the cascade replays on every switch; the scope in the
          // key remounts them when the wallet scope changes.
          Expanded(
            child: PageView(
              controller: tabs.controller,
              onPageChanged: tabs.onPageChanged,
              children: [
                for (final t in _SubscriptionTab.values)
                  _RulesTab(
                    key: ValueKey('${scopeId ?? 'all'}-${t.name}'),
                    rules: switch (t) {
                      _SubscriptionTab.active => active,
                      _SubscriptionTab.paused => paused,
                    },
                    // Nothing at all in this scope → explain how subscriptions
                    // appear; otherwise just "none in this tab".
                    emptyTitle: !hasAny
                        ? l10n.subscriptions_empty_title
                        : switch (t) {
                            _SubscriptionTab.active => l10n.subscriptions_active_empty,
                            _SubscriptionTab.paused => l10n.subscriptions_paused_empty,
                          },
                    emptySubtitle: hasAny ? null : l10n.subscriptions_empty_subtitle,
                    rowBuilder: row,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One tab body: skeleton → empty state | rule list. Smoke edges + one-shot
/// cascade, like the Tag Details tabs.
class _RulesTab extends StatelessWidget {
  const _RulesTab({
    super.key,
    required this.rules,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.rowBuilder,
  });

  final List<RecurringRuleModel>? rules;
  final String emptyTitle;
  final String? emptySubtitle;
  final Widget Function(RecurringRuleModel) rowBuilder;

  @override
  Widget build(BuildContext context) {
    final list = rules;
    return UIStaggerScope(
      key: ValueKey(list != null),
      child: UIScrollEdgeFade(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            const SliverToBoxAdapter(child: UISpace.vert(4)),
            if (list == null)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(kListHorzPadding, 16, kListHorzPadding, 0),
                  child: UiSkeletonList(rows: 4),
                ),
              )
            else if (list.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: UIStaggerItem(
                  index: 0,
                  child: UiEmptyState(
                    mood: WumbiMood.sleep,
                    title: emptyTitle,
                    subtitle: emptySubtitle,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
                sliver: SliverList.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const UIDivider(),
                  itemBuilder: (context, i) => UIStaggerItem(index: i, child: rowBuilder(list[i])),
                ),
              ),
            const SliverToBoxAdapter(child: UISpace.vert(_kListBottomInset)),
          ],
        ),
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
