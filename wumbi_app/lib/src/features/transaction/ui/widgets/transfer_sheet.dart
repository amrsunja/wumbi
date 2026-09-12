import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/fx/fx_service.dart';
import '../../../../core/money/amount_input.dart';
import '../../../../core/money/money.dart';
import '../../../../core/providers/data/fx_provider.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';
import '../../../wallet/data/models/wallet_model.dart';

/// Result of the transfer sheet: destination, received amount and the rate used.
class TransferChoice {
  const TransferChoice({required this.target, required this.received, this.rate});

  final WalletSummary target;
  final Money received;

  /// `to` per 1 `from`; null when both wallets share a currency.
  final double? rate;
}

/// D5 — pick the destination wallet; cross-currency shows an editable
/// "Amount received" (inline numpad, target scale) pre-filled from FxService.
abstract class TransferSheet {
  static Future<TransferChoice?> show(
    BuildContext context, {
    required WalletSummary source,
    required Money sent,
    required List<WalletSummary> wallets,
  }) {
    final l10n = context.l10n;
    return UIModalSheet.modalSheet<TransferChoice>(
      context: context,
      title: l10n.transfer_title(sent.format(), source.name),
      height: 0.75,
      child: _TransferBody(source: source, sent: sent, wallets: wallets.where((w) => w.id != source.id).toList()),
    );
  }
}

class _TransferBody extends ConsumerStatefulWidget {
  const _TransferBody({required this.source, required this.sent, required this.wallets});

  final WalletSummary source;
  final Money sent;
  final List<WalletSummary> wallets;

  @override
  ConsumerState<_TransferBody> createState() => _TransferBodyState();
}

class _TransferBodyState extends ConsumerState<_TransferBody> {
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

  void _apply(AmountInputResult r) {
    if (r.rejected) {
      AppVibrations.error();
      return;
    }
    setState(() => _receivedInput = r.value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final target = _target;
    final received = _received;
    final canConfirm = target != null && received != null && received.minor > 0 && !_loadingRate;

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
          if (_crossCurrency) ...[
            Text(l10n.transfer_amount_received, style: context.typo.inter.caption),
            const UISpace.vert(4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${target.currency.symbol} ${AmountInput.display(_receivedInput)}',
                style: context.typo.montserrat.sheetAmount,
              ),
            ),
            const UISpace.vert(4),
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
            const UISpace.vert(8),
            UiNumpad(
              keyHeight: 40,
              dotEnabled: target.currency.scale > 0,
              onDigit: (d) => _apply(AmountInput.digit(_receivedInput, d, target.currency)),
              onDot: () => _apply(AmountInput.dot(_receivedInput, target.currency)),
              onBackspace: () => setState(() => _receivedInput = AmountInput.backspace(_receivedInput)),
              onClear: () => setState(() => _receivedInput = AmountInput.clear()),
            ),
            const UISpace.vert(12),
          ],
          Text(
            '${widget.source.name} −${widget.sent.format()}   →   ${target.name} +${(received ?? Money.zero(target.currency)).format()}',
            textAlign: TextAlign.center,
            maxLines: 2,
            style: context.typo.inter.hint,
          ),
          const UISpace.vert(12),
          UiPrimaryButton(
            label: l10n.transfer_confirm,
            enabled: canConfirm,
            onTap: canConfirm
                ? () => Navigator.of(context).pop(
                      TransferChoice(target: target, received: received!, rate: _effectiveRate),
                    )
                : null,
          ),
          const UISpace.vert(16),
        ],
      ],
    );
  }
}
