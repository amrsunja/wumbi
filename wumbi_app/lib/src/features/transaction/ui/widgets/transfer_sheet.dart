import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wumbi/gen/assets.gen.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/fx/fx_service.dart';
import '../../../../core/money/amount_input.dart';
import '../../../../core/money/money.dart';
import '../../../../core/providers/data/fx_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';
import '../../../wallet/data/models/wallet_model.dart';
import 'amount_numpad_sheet.dart';

/// What the transfer sheet resolved to: another wallet.
sealed class TransferResult {
  const TransferResult();
}

/// Wallet → wallet: destination, received amount and the rate used.
class TransferChoice extends TransferResult {
  const TransferChoice({required this.target, required this.received, this.rate});

  final WalletSummary target;
  final Money received;

  /// `to` per 1 `from`; null when both wallets share a currency.
  final double? rate;
}

/// Where the money goes (45% sheet): pick the destination wallet;
/// cross-currency shows an "Amount received" row pre-filled from FxService,
/// editable on the numpad sheet (target scale).
abstract class TransferSheet {
  static Future<TransferResult?> show(
    BuildContext context, {
    required WalletSummary source,
    required Money sent,
    required List<WalletSummary> wallets,
  }) {
    final l10n = context.l10n;
    final others = wallets.where((w) => w.id != source.id).toList();
    return UIModalSheet.modalSheet<TransferResult>(
      context: context,
      title: l10n.transfer_title(sent.format(), source.name),
      titleTopSpacing: 24,
      height: 0.45,
      child: _WalletsPane(source: source, sent: sent, wallets: others),
    );
  }
}

// ------------------------------------------------------------------ wallets

class _WalletsPane extends ConsumerStatefulWidget {
  const _WalletsPane({super.key, required this.source, required this.sent, required this.wallets});

  final WalletSummary source;
  final Money sent;
  final List<WalletSummary> wallets;

  @override
  ConsumerState<_WalletsPane> createState() => _WalletsPaneState();
}

class _WalletsPaneState extends ConsumerState<_WalletsPane> {
  WalletSummary? _target;
  String _receivedInput = '';
  FxRate? _rate;
  bool _loadingRate = false;
  bool _rateError = false;
  int _request = 0;

  bool get _crossCurrency => _target != null && _target!.currency != widget.source.currency;

  Money? get _received {
    final t = _target;
    if (t == null) return null;
    if (!_crossCurrency) return Money(widget.sent.minor, t.currency);
    return AmountInput.toMoney(_receivedInput, t.currency);
  }

  /// Effective rate: recomputed as received / sent when the user overrides.
  double? get _effectiveRate {
    final r = _received;
    if (!_crossCurrency || r == null || widget.sent.minor == 0) return null;
    final sentValue = widget.sent.minor / _pow10(widget.sent.currency.scale);
    final receivedValue = r.minor / _pow10(r.currency.scale);
    return receivedValue / sentValue;
  }

  static num _pow10(int n) {
    var v = 1;
    for (var i = 0; i < n; i++) {
      v *= 10;
    }
    return v;
  }

  Future<void> _select(WalletSummary w) async {
    setState(() {
      _target = w;
      _receivedInput = '';
      _rate = null;
      _rateError = false;
    });
    if (w.currency == widget.source.currency) return;

    final request = ++_request;
    setState(() => _loadingRate = true);
    try {
      final rate = await ref.read(fxServiceProvider).rate(widget.source.currency, w.currency);
      if (!mounted || request != _request) return;
      final converted = convertMoney(widget.sent, w.currency, rate.rate);
      setState(() {
        _rate = rate;
        _receivedInput = converted.toPlainString();
        _loadingRate = false;
      });
    } catch (_) {
      if (!mounted || request != _request) return;
      setState(() {
        _loadingRate = false;
        _rateError = true;
      });
    }
  }

  /// Override the pre-filled received amount (numpad sheet, target scale).
  Future<void> _editReceived() async {
    final target = _target;
    if (target == null) return;
    final raw = await AmountNumpadSheet.show(
      context,
      title: context.l10n.transfer_amount_received,
      currency: target.currency,
      initial: _receivedInput,
    );
    if (raw == null || !mounted) return;
    setState(() => _receivedInput = AmountInput.reScale(raw, target.currency));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final target = _target;
    final received = _received;
    final canConfirm = target != null && received != null && received.minor > 0 && !_loadingRate;

    if (widget.wallets.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: UiEmptyState(
          image: Assets.images.wumbiOo.path,
          title: l10n.transaction_need_second_wallet_title,
          subtitle: l10n.transaction_need_second_wallet_message,
          action: UiIconTextButton(
            icon: UIIconToken.icons.general.plusCircle,
            title: l10n.dashboard_new_wallet,
            onTap: () {
              final router = context.router;
              Navigator.of(context).pop();
              router.push(WalletFormRoute());
            },
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: widget.wallets.length,
            separatorBuilder: (_, _) => const UIDivider(),
            itemBuilder: (context, index) {
              final w = widget.wallets[index];
              return UiListRow(
                leading: UiCircleColorBadge(color: w.color.color),
                title: w.name,
                subtitle: w.currency.code,
                trailingText: w.balance.format(signed: true),
                selected: w.id == target?.id,
                onTap: () => _select(w),
              );
            },
          ),
        ),
        if (target != null) ...[
          const UIDivider(),
          const UISpace.vert(12),
          // Cross-currency: the received amount, pre-filled from the day's
          // rate; tap to override. Kept to one row so the 45% sheet fits.
          if (_crossCurrency) ...[
            UiFormRow(
              label: l10n.transfer_amount_received,
              value: _loadingRate || received == null ? '…' : received.format(),
              muted: _loadingRate || received == null,
              onTap: _loadingRate ? null : _editReceived,
            ),
            if (_loadingRate)
              const UiConversionHint(text: '', state: UiConversionHintState.loading)
            else if (_rateError && _receivedInput.isEmpty)
              UiConversionHint(
                text: l10n.transaction_rate_unavailable,
                state: UiConversionHintState.error,
                onTap: () => _select(target),
              )
            else if (_effectiveRate != null)
              UiConversionHint(
                text: formatRate(_effectiveRate!, widget.source.currency, target.currency) +
                    (_rate?.isStale == true ? ' · ${l10n.transaction_hint_stale(_rate!.fetchedAt.formatShortDate())}' : ''),
                state: _rate?.isStale == true ? UiConversionHintState.stale : UiConversionHintState.ok,
              ),
            const UISpace.vert(12),
          ],
          _ConfirmBar(
            summary:
                '${widget.source.name} −${widget.sent.format()}   →   ${target.name} +${(received ?? Money.zero(target.currency)).format()}',
            enabled: canConfirm,
            onConfirm: () => Navigator.of(context).pop(
              TransferChoice(target: target, received: received!, rate: _effectiveRate),
            ),
          ),
        ],
      ],
    );
  }
}

/// "Card −€50 → …" and the confirm button.
class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar({required this.summary, required this.enabled, required this.onConfirm});

  final String summary;
  final bool enabled;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(summary, textAlign: TextAlign.center, maxLines: 2, style: context.typo.inter.hint),
        const UISpace.vert(12),
        UiPrimaryButton(label: context.l10n.transfer_confirm, enabled: enabled, onTap: enabled ? onConfirm : null),
        const UISpace.vert(16),
      ],
    );
  }
}
