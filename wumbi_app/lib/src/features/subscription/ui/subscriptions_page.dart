import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/money/money.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../../core/utils/typedefs.dart';
import '../../transaction/data/models/recurring_rule_model.dart';
import '../../transaction/ui/widgets/repeat_labels.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/ui/wallets_provider.dart';
import 'subscriptions_provider.dart';

/// Every recurring rule, scoped to one wallet or all of them. Active rules
/// first, paused below; tap a row to open it on the Transaction page
/// ("Edit subscription"), switch to pause, trash to stop.
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
    final wallets = ref.watch(walletsProvider).value ?? const <WalletSummary>[];
    final monthly = ref.watch(monthlySubscriptionTotalProvider(scopeId)).value;

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

    Future<void> onDelete(RecurringRuleModel r) async {
      final ok = await UIAlertDialog.confirm(
        context,
        title: l10n.repeat_delete_title,
        message: l10n.repeat_delete_message,
        confirmLabel: l10n.subscriptions_stop,
        cancelLabel: l10n.common_cancel,
        destructive: true,
      );
      if (!ok) return;
      await ref.read(subscriptionsProvider.notifier).delete(r.id, message: l10n.subscriptions_stopped);
    }

    Widget row(RecurringRuleModel r) => _SubscriptionRow(
          rule: r,
          walletsById: walletsById,
          onTap: () => context.router.push(TransactionRoute(ruleId: r.id)),
          onToggle: (v) => ref.read(subscriptionsProvider.notifier).setActive(r.id, v),
          onDelete: () => onDelete(r),
        );

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
                  _ScopePill(
                    label: scopeWallet?.name ?? l10n.subscriptions_all_wallets,
                    onTap: wallets.isEmpty ? null : pickScope,
                  ),
                  if (monthly != null && !monthly.isZero) ...[
                    const UISpace.vert(10),
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
              ),
            )
          else ...[
            if (active.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: UiSectionLabel(
                  text: l10n.subscriptions_active,
                  padding: const EdgeInsets.fromLTRB(kListHorzPadding, 24, kListHorzPadding, 4),
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

/// Outlined pill: wallet icon · "All wallets" / wallet name · chevron.
class _ScopePill extends StatelessWidget {
  const _ScopePill({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return UITap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: colors.dividerColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            UIIcon(UIIconToken.icons.financeEcommerce.wallet02, size: 14),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typo.inter.captionBold,
              ),
            ),
            if (onTap != null) UIIcon(UIIconToken.icons.arrows.chevronDown, size: 14),
          ],
        ),
      ),
    );
  }
}

/// List row with two caption lines (schedule, wallet names) and a trailing
/// amount · switch · trash. Mirrors `UiListRow` spacing.
class _SubscriptionRow extends StatelessWidget {
  const _SubscriptionRow({
    required this.rule,
    required this.walletsById,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final RecurringRuleModel rule;
  final Map<String, WalletSummary> walletsById;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  String _walletName(BuildContext context, String? id) =>
      (id == null ? null : walletsById[id]?.name) ?? context.l10n.wallet_deleted_suffix;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    final r = rule;

    final title = r.description.isNotEmpty
        ? r.description
        : switch (r.type) {
            TransactionType.income => l10n.common_income,
            TransactionType.expense => l10n.common_expense,
            TransactionType.transfer => l10n.common_transfer,
          };

    final schedule = r.isActive
        ? '${repeatShortLabel(l10n, r.frequency)} · ${l10n.repeat_next(r.nextOccurrence.formatShortDate())}'
        : '${repeatShortLabel(l10n, r.frequency)} · ${l10n.repeat_paused}';

    final walletLine = r.isTransfer
        ? '${_walletName(context, r.fromWalletId)} → ${_walletName(context, r.toWalletId)}'
        : _walletName(context, r.walletId);

    final Money amount;
    final Color? amountColor;
    switch (r.type) {
      case TransactionType.income:
        amount = Money(r.amountMinor ?? 0, r.currency);
        amountColor = UIColorToken.blue;
      case TransactionType.expense:
        amount = Money(-(r.amountMinor ?? 0), r.currency);
        amountColor = colors.expenseColor;
      case TransactionType.transfer:
        amount = Money(r.fromAmountMinor ?? 0, r.currency);
        amountColor = null;
    }
    final amountText = r.isTransfer ? amount.format() : amount.format(signed: true, positiveSign: true);

    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.listTitle),
                  Text(schedule, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.caption),
                  Text(walletLine, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.caption),
                ],
              ),
            ),
            const UISpace.horz(12),
            Text(
              amountText,
              style: amountColor == null ? typo.label : typo.label.copyWith(color: amountColor),
            ),
            const UISpace.horz(8),
            UISwitch(value: r.isActive, onChanged: onToggle),
            const UISpace.horz(8),
            UIIcon(
              UIIconToken.icons.general.trash01,
              size: 20,
              color: UIColorToken.neg500,
              onTap: onDelete,
            ),
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
