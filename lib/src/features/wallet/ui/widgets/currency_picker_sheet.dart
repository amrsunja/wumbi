import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/currency_type.dart';

/// Bottom sheet listing every [CurrencyType]; [pinned] currencies come first
/// (wallet currency, then base, then recent).
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
      height: 0.7,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: ordered.length,
        separatorBuilder: (_, _) => const UIDivider(),
        itemBuilder: (context, index) {
          final c = ordered[index];
          return UiListRow(
            leading: _SymbolBadge(symbol: c.symbol),
            title: c.code,
            subtitle: c.displayName,
            selected: c == selected,
            onTap: () => Navigator.of(context).pop(c),
          );
        },
      ),
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
