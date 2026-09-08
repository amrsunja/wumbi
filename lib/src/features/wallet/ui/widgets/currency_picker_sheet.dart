import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';

/// Bottom sheet listing every [CurrencyType]; [pinned] currencies come first
/// (wallet currency, then base, then recent). The list is long, so it opens
/// with a search field matching code or name.
abstract class CurrencyPickerSheet {
  static Future<CurrencyType?> show(
    BuildContext context, {
    required String title,
    CurrencyType? selected,
    List<CurrencyType> pinned = const [],
  }) {
    final ordered = <CurrencyType>[
      ...pinned.toSet(),
      ...CurrencyType.values.where((c) => !pinned.contains(c)),
    ];
    return UIModalSheet.modalSheet<CurrencyType>(
      context: context,
      title: title,
      height: 0.75,
      child: _CurrencyList(ordered: ordered, selected: selected),
    );
  }
}

class _CurrencyList extends HookWidget {
  const _CurrencyList({required this.ordered, required this.selected});

  final List<CurrencyType> ordered;
  final CurrencyType? selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = useState('');

    final q = query.value.trim().toLowerCase();
    final items = q.isEmpty
        ? ordered
        : ordered
            .where((c) => c.code.toLowerCase().contains(q) || c.displayName.toLowerCase().contains(q))
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: UIInputField(
            hintText: l10n.common_search,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.search,
            onChanged: (v) => query.value = v,
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(child: Text(l10n.currency_no_results, style: context.typo.inter.hint))
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const UIDivider(),
                  itemBuilder: (context, index) {
                    final c = items[index];
                    return UiListRow(
                      leading: _SymbolBadge(symbol: c.symbol),
                      title: c.code,
                      subtitle: c.displayName,
                      selected: c == selected,
                      onTap: () => Navigator.of(context).pop(c),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SymbolBadge extends StatelessWidget {
  const _SymbolBadge({required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FittedBox(
        child: Text(
          symbol,
          style: AppTheme.of(context).typo.inter.label,
        ),
      ),
    );
  }
}
