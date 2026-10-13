import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/money/money.dart';
import '../../../../core/providers/data/fx_provider.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../wallet/data/models/wallet_model.dart';

/// Where the money of a debt movement goes: a wallet, or "Not in a wallet"
/// (settled in cash outside Wumbi). Resolves with `(wallet: …)` — a null
/// wallet means "Not in a wallet" — or null when dismissed.
///
/// Two modes:
/// * picker (New debt): tapping a row picks it and closes;
/// * payment (Debt Details, [delta] set): an [explanation] on top, every
///   wallet shows its balance after the move ("€120.00 → €160.00"; other
///   currencies converted with cached rates, "≈"), a row only *selects*, and
///   the button at the bottom confirms ("Pay from Card" / "Add to Card").
abstract class DebtWalletSheet {
  static Future<({WalletSummary? wallet})?> show(
    BuildContext context, {
    required List<WalletSummary> wallets,
    required String? selectedId,
    String? title,
    String? explanation,

    /// Signed debt amount: + money comes in (lent), − goes out (borrowed).
    Money? delta,
  }) {
    return UIModalSheet.modalSheet<({WalletSummary? wallet})>(
      context: context,
      title: title ?? context.l10n.debt_money_moved,
      fitContent: wallets.length <= 5,
      height: 0.8,
      child: _Body(
        wallets: wallets,
        selectedId: selectedId,
        explanation: explanation,
        delta: delta,
        fit: wallets.length <= 5,
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({
    required this.wallets,
    required this.selectedId,
    required this.explanation,
    required this.delta,
    required this.fit,
  });

  final List<WalletSummary> wallets;
  final String? selectedId;
  final String? explanation;
  final Money? delta;
  final bool fit;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  late String? _selectedId = widget.selectedId;

  /// The movement in each other wallet currency (cached rates, read path).
  final Map<CurrencyType, Money?> _converted = {};

  bool get _confirmMode => widget.delta != null;

  @override
  void initState() {
    super.initState();
    _convert();
  }

  Future<void> _convert() async {
    final d = widget.delta;
    if (d == null) return;
    final fx = ref.read(fxServiceProvider);
    final currencies = widget.wallets.map((w) => w.currency).where((c) => c != d.currency).toSet();
    for (final c in currencies) {
      final rate = await fx.cachedRate(d.currency, c);
      if (!mounted) return;
      setState(() => _converted[c] = rate == null ? null : convertMoney(d, c, rate.rate));
    }
  }

  /// "€120.00 → €160.00" ("≈" when converted); just the balance when the
  /// rate is unknown.
  String _preview(WalletSummary w) {
    final d = widget.delta!;
    final now = w.balance.format(signed: true);
    if (d.currency == w.currency) return '$now → ${(w.balance + d).format(signed: true)}';
    final converted = _converted[w.currency];
    if (converted == null) return now;
    return '$now → ≈ ${(w.balance + converted).format(signed: true)}';
  }

  void _tap(WalletSummary? w) {
    if (!_confirmMode) {
      Navigator.of(context).pop((wallet: w));
      return;
    }
    AppVibrations.selection();
    setState(() => _selectedId = w?.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final explanation = widget.explanation;
    final selected = widget.wallets.where((w) => w.id == _selectedId).firstOrNull;
    final incoming = widget.delta?.isPositive ?? false;

    final list = ListView(
      shrinkWrap: widget.fit,
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        if (explanation != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Text(explanation, style: typo.body.copyWith(color: context.colors.secondContentColor)),
          ),
        for (final w in widget.wallets) ...[
          UiListRow(
            leading: UiCircleColorBadge(color: w.color.color),
            title: w.name,
            subtitle: _confirmMode ? _preview(w) : w.currency.code,
            trailingText: _confirmMode ? null : w.balance.format(signed: true),
            selected: w.id == _selectedId,
            onTap: () => _tap(w),
          ),
          const UIDivider(),
        ],
        UiListRow(
          leading: UIIcon(UIIconToken.icons.financeEcommerce.coinsHand, size: 18),
          title: l10n.debt_not_in_wallet,
          subtitle: _confirmMode ? l10n.debt_wallet_only_debt : null,
          selected: _selectedId == null,
          onTap: () => _tap(null),
        ),
      ],
    );

    if (!_confirmMode) return Padding(padding: const EdgeInsets.only(bottom: 8), child: list);

    final confirm = selected == null
        ? l10n.debt_wallet_confirm_none
        : (incoming ? l10n.debt_wallet_confirm_in(selected.name) : l10n.debt_wallet_confirm_out(selected.name));

    return Column(
      mainAxisSize: widget.fit ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (widget.fit) list else Expanded(child: list),
        const UISpace.vert(8),
        UiPrimaryButton(label: confirm, onTap: () => Navigator.of(context).pop((wallet: selected))),
        const UISpace.vert(16),
      ],
    );
  }
}
