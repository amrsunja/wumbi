import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/fx/fx_service.dart';
import '../../../../core/money/amount_input.dart';
import '../../../../core/money/money.dart';
import '../../../../core/providers/data/fx_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/enums/debt_direction.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../debt/data/models/debt_intent.dart';
import '../../../debt/data/models/debt_model.dart';
import '../../../debt/ui/debt_labels.dart';
import '../../../debt/ui/debts_provider.dart';
import '../../../debt/ui/person_pick.dart';
import '../../../debt/ui/widgets/person_picker_sheet.dart';
import '../../../wallet/data/models/wallet_model.dart';
import 'amount_entry_display.dart';

/// What the transfer sheet resolved to: another wallet, or a debt.
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

/// Wallet → debt: the money leaves the wallet as an expense that pays back
/// one debt I owe ([DebtIntent.repay]) or lends to a person
/// ([DebtIntent.open], lent).
class DebtTransferChoice extends TransferResult {
  const DebtTransferChoice({required this.intent});

  final DebtIntent intent;
}

/// D5 — where the money goes, in two tabs:
/// * Wallets — pick the destination wallet; cross-currency shows an
///   editable "Amount received" (inline numpad, target scale) pre-filled
///   from FxService;
/// * Debts — pay back a debt I owe, or lend to someone (new "owed to me"
///   debt). Locked while the draft repeats or is future-dated ([A4]).
abstract class TransferSheet {
  static Future<TransferResult?> show(
    BuildContext context, {
    required WalletSummary source,
    required Money sent,
    required List<WalletSummary> wallets,
    required bool debtsAllowed,
  }) {
    final l10n = context.l10n;
    final others = wallets.where((w) => w.id != source.id).toList();
    return UIModalSheet.modalSheet<TransferResult>(
      context: context,
      title: l10n.transfer_title(sent.format(), source.name),
      height: 0.8,
      child: _TransferBody(source: source, sent: sent, wallets: others, debtsAllowed: debtsAllowed),
    );
  }
}

class _TransferBody extends StatefulWidget {
  const _TransferBody({required this.source, required this.sent, required this.wallets, required this.debtsAllowed});

  final WalletSummary source;
  final Money sent;
  final List<WalletSummary> wallets;
  final bool debtsAllowed;

  @override
  State<_TransferBody> createState() => _TransferBodyState();
}

class _TransferBodyState extends State<_TransferBody> {
  // No other wallet yet → start on Debts (Wallets explains how to add one).
  late int _tab = widget.wallets.isEmpty && widget.debtsAllowed ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiSegmentedToggle(
          expanded: true,
          labels: [l10n.dashboard_wallets, l10n.debts_title],
          selectedIndex: _tab,
          onChanged: (i) {
            if (i == _tab) return;
            AppVibrations.selection();
            setState(() => _tab = i);
          },
        ),
        const UISpace.vert(8),
        Expanded(
          child: AnimatedSwitcher(
            duration: UIAnim.fast,
            switchInCurve: UIAnim.easeOut,
            switchOutCurve: UIAnim.easeOut,
            child: _tab == 0
                ? _WalletsPane(key: const ValueKey('wallets'), source: widget.source, sent: widget.sent, wallets: widget.wallets)
                : _DebtsPane(key: const ValueKey('debts'), source: widget.source, sent: widget.sent, allowed: widget.debtsAllowed),
          ),
        ),
      ],
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

    if (widget.wallets.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: UiEmptyState(
          image: AppAssets.images.wumbiOo.path,
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
          if (_crossCurrency) ...[
            Text(l10n.transfer_amount_received, style: context.typo.inter.caption),
            const UISpace.vert(4),
            AmountEntryDisplay(input: _receivedInput, prefix: '${target.currency.symbol} '),
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

// -------------------------------------------------------------------- debts

/// Picked debt destination.
sealed class _DebtTarget {
  const _DebtTarget(this.name);
  final String name;
}

/// Pay back exactly this debt I owe.
class _RepayTarget extends _DebtTarget {
  _RepayTarget(this.debt) : super(debt.person.name);
  final DebtSummary debt;
}

/// Lend to a person: a new "owed to me" debt.
class _LendTarget extends _DebtTarget {
  const _LendTarget(super.name, this.person);
  final PersonRef person;
}

/// "Pay back" — open debts I owe (oldest first), each with what is left and
/// refused when the amount is more than that; "Lend" — people who already
/// owe me, then "Lend to someone…" (person picker).
class _DebtsPane extends ConsumerStatefulWidget {
  const _DebtsPane({super.key, required this.source, required this.sent, required this.allowed});

  final WalletSummary source;
  final Money sent;
  final bool allowed;

  @override
  ConsumerState<_DebtsPane> createState() => _DebtsPaneState();
}

class _DebtsPaneState extends ConsumerState<_DebtsPane> {
  _DebtTarget? _target;

  Future<void> _pickPerson() async {
    final picked = await PersonPickerSheet.show(context);
    if (!mounted || picked == null) return;
    final target = switch (picked) {
      PickedPerson(:final person) => _LendTarget(person.name, PersonRef.existing(person.id)),
      NewPerson(:final name) => _LendTarget(name, PersonRef.create(name)),
      NoPerson() => null,
    };
    if (target != null) setState(() => _target = target);
  }

  /// Same-currency debts can be checked here; cross-currency ones are checked
  /// by the write (it converts with the day's rate).
  String? _tooMuch(DebtSummary d) {
    if (d.remaining.currency != widget.sent.currency) return null;
    return widget.sent.minor > d.remaining.minor ? context.l10n.transfer_debt_only_left(d.remaining.format()) : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final overview = ref.watch(debtsOverviewProvider).value;
    final target = _target;

    if (!widget.allowed) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: UiEmptyState(image: AppAssets.images.wumbiOo.path, title: l10n.transfer_debt_locked),
      );
    }
    if (overview == null) {
      return const Padding(padding: EdgeInsets.only(top: 16), child: UiSkeletonList(rows: 3));
    }

    // Oldest first: the order money is usually paid back in.
    final owe = [...overview.openBorrowed]..sort((a, b) => a.debt.openedAt.compareTo(b.debt.openedAt));
    final lentTo = <String, DebtSummary>{};
    for (final d in overview.openLent) {
      lentTo.putIfAbsent(d.person.id, () => d);
    }

    bool isRepay(DebtSummary d) => target is _RepayTarget && target.debt.debt.id == d.debt.id;
    bool isLend(String personId) => switch (target) {
          _LendTarget(person: ExistingPersonRef(:final id)) => id == personId,
          _ => false,
        };

    final summary = switch (target) {
      _RepayTarget(:final name) => l10n.transfer_debt_summary_repay(widget.source.name, widget.sent.format(), name),
      _LendTarget(:final name) => l10n.transfer_debt_summary_lend(widget.source.name, widget.sent.format(), name),
      null => null,
    };

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 8),
            children: [
              if (owe.isNotEmpty) ...[
                UiSectionLabel(text: l10n.transfer_debt_pay_back, padding: const EdgeInsets.fromLTRB(4, 12, 4, 0)),
                for (var i = 0; i < owe.length; i++) ...[
                  if (i > 0) const UIDivider(),
                  UiListRow(
                    leading: _Initial(name: owe[i].person.name),
                    title: owe[i].person.name,
                    subtitle: [
                      if (owe[i].debt.description.isNotEmpty) owe[i].debt.description,
                      owe[i].debt.openedAt.formatShortDate(),
                    ].join(' · '),
                    trailingText: DebtLabels.remaining(l10n, owe[i]),
                    selected: isRepay(owe[i]),
                    disabledReason: _tooMuch(owe[i]),
                    onTap: () => setState(() => _target = _RepayTarget(owe[i])),
                  ),
                ],
              ],
              UiSectionLabel(text: l10n.transfer_debt_lend, padding: const EdgeInsets.fromLTRB(4, 20, 4, 0)),
              for (final d in lentTo.values) ...[
                UiListRow(
                  leading: _Initial(name: d.person.name),
                  title: l10n.transfer_debt_lend_to(d.person.name),
                  subtitle: DebtLabels.owes(l10n, DebtDirection.lent, d.person.name, d.remaining.format()),
                  selected: isLend(d.person.id),
                  onTap: () => setState(() => _target = _LendTarget(d.person.name, PersonRef.existing(d.person.id))),
                ),
                const UIDivider(),
              ],
              UiListRow(
                leading: UIIcon(UIIconToken.icons.users.userPlus01, size: 20, color: UIColorToken.blue),
                title: target is _LendTarget && target.person is NewPersonRef
                    ? l10n.transfer_debt_lend_to(target.name)
                    : l10n.transfer_debt_lend_someone,
                selected: target is _LendTarget && !lentTo.values.any((d) => isLend(d.person.id)),
                onTap: _pickPerson,
              ),
            ],
          ),
        ),
        if (summary != null) ...[
          const UIDivider(),
          const UISpace.vert(12),
          _ConfirmBar(
            summary: summary,
            enabled: true,
            onConfirm: () => Navigator.of(context).pop(
              DebtTransferChoice(
                intent: switch (target!) {
                  _RepayTarget(:final debt) => DebtIntent.repay(debtId: debt.debt.id),
                  _LendTarget(:final person) => DebtIntent.open(person: person, direction: DebtDirection.lent),
                },
              ),
            ),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(l10n.debts_empty_hint, textAlign: TextAlign.center, style: typo.hint),
          ),
      ],
    );
  }
}

/// Initial in a tinted circle (people have no colour of their own).
class _Initial extends StatelessWidget {
  const _Initial({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final letter = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: UIColorToken.blue.withValues(alpha: 0.12), shape: BoxShape.circle),
      child: Text(letter, style: context.typo.inter.label.copyWith(color: UIColorToken.blue)),
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
