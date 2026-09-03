import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../state_management/settings_provider.dart';

/// Settings → Currency: list of [CurrencyType] with a check on the current one.
@RoutePage()
class BaseCurrencyPage extends ConsumerWidget {
  const BaseCurrencyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(baseCurrencyProvider);

    return Scaffold(
      appBar: UIAppbar(title: l10n.currency_base_title, backTap: () => context.router.maybePop()),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 32),
        itemCount: CurrencyType.values.length + 1,
        separatorBuilder: (_, index) => index == 0 ? const UISpace.vert(8) : const UIDivider(),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.currency_base_hint, style: context.typo.inter.caption),
            );
          }
          final c = CurrencyType.values[index - 1];
          return UiListRow(
            title: c.code,
            subtitle: c.displayName,
            trailingText: c.symbol,
            selected: c == current,
            onTap: () async {
              await ref.read(settingsProvider.notifier).changeBaseCurrency(c);
              if (context.mounted) context.router.maybePop();
            },
          );
        },
      ),
    );
  }
}
