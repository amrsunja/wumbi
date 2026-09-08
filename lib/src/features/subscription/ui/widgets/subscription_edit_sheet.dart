import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/errors/failures/failures.dart';
import '../../../../core/money/amount_input.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/enums/repeat_frequency.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/state_management/app_events.dart';
import '../../../../core/utils/state_management/single_events.dart';
import '../../../tag/data/tag_repository.dart';
import '../../../transaction/data/models/recurring_rule_model.dart';
import '../../../transaction/data/transaction_repository.dart';
import '../../../transaction/ui/widgets/repeat_labels.dart';
import '../../../wallet/data/models/wallet_model.dart';
import '../../../wallet/ui/wallets_provider.dart';
import '../../../wallet/ui/widgets/wallet_picker_sheet.dart';

/// Edit a recurring rule in place: amount, description, frequency, wallet(s)
/// and tags. The type is fixed. Saves through `updateRule`; existing
/// occurrences never change.
abstract class SubscriptionEditSheet {
  static Future<void> show(BuildContext context, {required String ruleId}) {
    final l10n = context.l10n;
    return UIModalSheet.modalSheet<void>(
      context: context,
      title: l10n.subscriptions_edit_title,
      height: 0.85,
      child: _EditForm(ruleId: ruleId),
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.ruleId});

  final String ruleId;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  final _amountCtrl = TextEditingController();
  final _receivedCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  RecurringRuleModel? _rule;
  RepeatFrequency _frequency = RepeatFrequency.monthly;
  String? _walletId;
  String? _fromWalletId;
  String? _toWalletId;
  List<String> _tags = const [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _receivedCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await ref.read(transactionRepositoryProvider).ruleById(widget.ruleId);
    if (!mounted) return;
    result.when(
      (data) {
        final r = data.rule;
        final sentMinor = r.isTransfer ? (r.fromAmountMinor ?? 0) : (r.amountMinor ?? 0);
        _amountCtrl.text = sentMinor == 0 ? '' : Money(sentMinor, r.currency).toPlainString();
        final toCurrency = _currencyOf(r.toWalletId) ?? r.currency;
        final receivedMinor = r.toAmountMinor ?? 0;
        _receivedCtrl.text = receivedMinor == 0 ? '' : Money(receivedMinor, toCurrency).toPlainString();
        _descriptionCtrl.text = r.description;
        setState(() {
          _rule = r;
          _frequency = r.frequency.isNever ? RepeatFrequency.monthly : r.frequency;
          _walletId = r.walletId;
          _fromWalletId = r.fromWalletId;
          _toWalletId = r.toWalletId;
          _tags = List.of(data.tags);
        });
      },
      (error) {
        ref.read(appEventProvider).send(ShowErrorEvent(error));
        Navigator.of(context).pop();
      },
    );
  }

  List<WalletSummary> get _wallets => ref.read(walletsProvider).value ?? const <WalletSummary>[];

  WalletSummary? _wallet(String? id) {
    if (id == null) return null;
    for (final w in _wallets) {
      if (w.id == id) return w;
    }
    return null;
  }

  CurrencyType? _currencyOf(String? walletId) => _wallet(walletId)?.currency;

  Future<List<String>> _suggestTags(String query) => ref.read(tagRepositoryProvider).suggest(query);

  Future<void> _pickFrequency() async {
    final picked = await _FrequencyPickerSheet.show(context, selected: _frequency);
    if (picked == null || !mounted) return;
    setState(() => _frequency = picked);
  }

  Future<void> _pickWallet() async {
    final rule = _rule;
    if (rule == null) return;
    final picked = await WalletPickerSheet.show(
      context,
      wallets: _wallets,
      title: context.l10n.subscriptions_wallet,
      selectedId: _walletId,
      requireCurrency: rule.currency,
    );
    if (picked == null || !mounted) return;
    setState(() => _walletId = picked.id);
  }

  Future<void> _pickFromWallet() async {
    final rule = _rule;
    if (rule == null) return;
    final picked = await WalletPickerSheet.show(
      context,
      wallets: _wallets,
      title: context.l10n.subscriptions_from_wallet,
      selectedId: _fromWalletId,
      excludeId: _toWalletId,
      requireCurrency: rule.currency,
    );
    if (picked == null || !mounted) return;
    setState(() => _fromWalletId = picked.id);
  }

  Future<void> _pickToWallet() async {
    final rule = _rule;
    if (rule == null) return;
    final picked = await WalletPickerSheet.show(
      context,
      wallets: _wallets,
      title: context.l10n.subscriptions_to_wallet,
      selectedId: _toWalletId,
      excludeId: _fromWalletId,
    );
    if (picked == null || !mounted) return;
    final previousCurrency = _currencyOf(_toWalletId);
    setState(() => _toWalletId = picked.id);
    // Same currency on both sides: the received amount mirrors the sent one.
    if (picked.currency == rule.currency) {
      _receivedCtrl.text = _amountCtrl.text;
    } else if (previousCurrency != picked.currency) {
      _receivedCtrl.text = AmountInput.reScale(_receivedCtrl.text, picked.currency);
    }
  }

  bool get _crossCurrency {
    final rule = _rule;
    if (rule == null || !rule.isTransfer) return false;
    final toCurrency = _currencyOf(_toWalletId);
    return toCurrency != null && toCurrency != rule.currency;
  }

  Future<void> _save() async {
    final rule = _rule;
    if (rule == null || _saving) return;
    final events = ref.read(appEventProvider);
    FocusManager.instance.primaryFocus?.unfocus();

    final sent = AmountInput.toMoney(_amountCtrl.text, rule.currency);
    if (sent == null || sent.minor <= 0) {
      events.send(const ShowErrorEvent(ValidationFailure(field: 'amount')));
      return;
    }

    int? receivedMinor;
    double? exchangeRate;
    if (rule.isTransfer) {
      if (_fromWalletId == _toWalletId) {
        events.send(const ShowErrorEvent(ValidationFailure(field: 'toWalletId')));
        return;
      }
      if (_crossCurrency) {
        final toCurrency = _currencyOf(_toWalletId)!;
        final received = AmountInput.toMoney(_receivedCtrl.text, toCurrency);
        if (received == null || received.minor <= 0) {
          events.send(const ShowErrorEvent(ValidationFailure(field: 'amount')));
          return;
        }
        receivedMinor = received.minor;
        final sentMajor = sent.minor / math.pow(10, rule.currency.scale);
        final receivedMajor = received.minor / math.pow(10, toCurrency.scale);
        exchangeRate = receivedMajor / sentMajor;
      } else {
        receivedMinor = sent.minor;
      }
    }

    setState(() => _saving = true);
    final result = await ref.read(transactionRepositoryProvider).updateRule(
          rule.id,
          RecurringRuleDraft(
            amountMinor: sent.minor,
            receivedAmountMinor: receivedMinor,
            exchangeRate: exchangeRate,
            description: _descriptionCtrl.text.trim(),
            frequency: _frequency,
            walletId: rule.isTransfer ? null : _walletId,
            fromWalletId: rule.isTransfer ? _fromWalletId : null,
            toWalletId: rule.isTransfer ? _toWalletId : null,
            tags: _tags,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    result.when(
      (_) {
        events.send(ShowInfoMessageEvent(context.l10n.subscriptions_saved));
        Navigator.of(context).pop();
      },
      (error) => events.send(ShowErrorEvent(error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final rule = _rule;
    // Rebuild when wallets change (names / currencies in the rows).
    ref.watch(walletsProvider);

    if (rule == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 24),
        child: UiSkeletonList(rows: 4),
      );
    }

    final toCurrency = _currencyOf(_toWalletId) ?? rule.currency;
    final walletName = _wallet(_walletId)?.name ?? l10n.wallet_deleted_suffix;
    final fromName = _wallet(_fromWalletId)?.name ?? l10n.wallet_deleted_suffix;
    final toName = _wallet(_toWalletId)?.name ?? l10n.wallet_deleted_suffix;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            children: [
              _FieldLabel(l10n.subscriptions_amount),
              _AmountField(controller: _amountCtrl, currency: rule.currency),
              if (_crossCurrency) ...[
                const UISpace.vert(8),
                _AmountField(controller: _receivedCtrl, currency: toCurrency),
              ],
              const UISpace.vert(16),
              _FieldLabel(l10n.subscriptions_description),
              UIInputField(
                controller: _descriptionCtrl,
                hintText: l10n.subscriptions_description,
                maxLength: kMaxDescriptionLength,
                textInputAction: TextInputAction.done,
              ),
              const UISpace.vert(8),
              _PickerRow(
                title: l10n.subscriptions_frequency,
                value: repeatLongLabel(l10n, _frequency),
                onTap: _pickFrequency,
              ),
              const UIDivider(),
              if (rule.isTransfer) ...[
                _PickerRow(title: l10n.subscriptions_from_wallet, value: fromName, onTap: _pickFromWallet),
                const UIDivider(),
                _PickerRow(title: l10n.subscriptions_to_wallet, value: toName, onTap: _pickToWallet),
              ] else
                _PickerRow(title: l10n.subscriptions_wallet, value: walletName, onTap: _pickWallet),
              const UIDivider(),
              const UISpace.vert(16),
              _FieldLabel(l10n.subscriptions_tags),
              UiTagInput(
                tags: _tags,
                hintText: l10n.transaction_tags_placeholder,
                maxTags: kMaxTagsPerTransaction,
                maxTagLength: kMaxTagLength,
                suggestions: _suggestTags,
                onChanged: (tags) => setState(() => _tags = tags),
                onSubmitted: () => FocusManager.instance.primaryFocus?.unfocus(),
              ),
              const UISpace.vert(20),
              Text(
                l10n.subscriptions_type_hint,
                textAlign: TextAlign.center,
                style: typo.caption,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: UiPrimaryButton(
            label: l10n.common_save,
            loading: _saving,
            onTap: _save,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 6),
      child: Text(text, style: context.typo.inter.captionBold),
    );
  }
}

/// Boxed numeric field with the currency code at its end.
class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller, required this.currency});

  final TextEditingController controller;
  final CurrencyType currency;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: UIInputField(
            controller: controller,
            hintText: '0',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.none,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          ),
        ),
        Text(currency.code, style: context.typo.inter.label),
      ],
    );
  }
}

/// Title at the start, current value + chevron at the end.
class _PickerRow extends StatelessWidget {
  const _PickerRow({required this.title, required this.value, required this.onTap});

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    return UiListRow(
      title: title,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.labelMedium.copyWith(color: UIColorToken.blue),
            ),
          ),
          UIIcon(UIIconToken.icons.arrows.chevronRight, size: 16),
        ],
      ),
    );
  }
}

/// Same rows as `RepeatPickerSheet`, minus "Never" (a subscription always repeats).
abstract class _FrequencyPickerSheet {
  static Future<RepeatFrequency?> show(BuildContext context, {required RepeatFrequency selected}) {
    final l10n = context.l10n;
    final options = RepeatFrequency.values.where((f) => !f.isNever).toList();
    return UIModalSheet.modalSheet<RepeatFrequency>(
      context: context,
      title: l10n.subscriptions_frequency,
      fitContent: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final f in options) ...[
              UiRadioRow(
                label: repeatLongLabel(l10n, f),
                selected: f == selected,
                onTap: () => Navigator.of(context).pop(f),
              ),
              if (f != options.last) const UIDivider(),
            ],
          ],
        ),
      ),
    );
  }
}
