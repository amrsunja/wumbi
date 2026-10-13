import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../data/models/wallet_model.dart';

/// Several wallets at once (budget scope). The first row, [allLabel], means
/// "no restriction" and clears the selection. Resolves with the chosen ids
/// on Done (empty = all wallets), null when dismissed.
abstract class WalletMultiPickerSheet {
  static Future<Set<String>?> show(
    BuildContext context, {
    required List<WalletSummary> wallets,
    required Set<String> selected,
    required String title,
    required String allLabel,
  }) =>
      UIModalSheet.modalSheet<Set<String>>(
        context: context,
        title: title,
        fitContent: wallets.length <= 6,
        height: 0.7,
        child: _Body(wallets: wallets, initial: selected, allLabel: allLabel),
      );
}

class _Body extends HookWidget {
  const _Body({required this.wallets, required this.initial, required this.allLabel});

  final List<WalletSummary> wallets;
  final Set<String> initial;
  final String allLabel;

  @override
  Widget build(BuildContext context) {
    final selected = useState<Set<String>>({...initial});

    void toggle(String id) {
      AppVibrations.light();
      final next = {...selected.value};
      if (!next.remove(id)) next.add(id);
      selected.value = next;
    }

    final list = ListView(
      shrinkWrap: wallets.length <= 6,
      padding: EdgeInsets.zero,
      children: [
        UiListRow(
          leading: UIIcon(UIIconToken.icons.financeEcommerce.wallet02, size: 18),
          title: allLabel,
          selected: selected.value.isEmpty,
          onTap: () {
            AppVibrations.light();
            selected.value = {};
          },
        ),
        for (final w in wallets) ...[
          const UIDivider(),
          UiListRow(
            leading: UiCircleColorBadge(color: w.color.color),
            title: w.name,
            subtitle: w.currency.code,
            selected: selected.value.contains(w.id),
            onTap: () => toggle(w.id),
          ),
        ],
      ],
    );

    return Column(
      mainAxisSize: wallets.length <= 6 ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (wallets.length <= 6) list else Expanded(child: list),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: UiPrimaryButton(
            label: context.l10n.common_done,
            onTap: () => Navigator.of(context).pop(selected.value),
          ),
        ),
      ],
    );
  }
}
