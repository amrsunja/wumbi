import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../wallet/ui/wallet_form_notifier.dart';
import '../../../wallet/ui/widgets/wallet_form_body.dart';

/// Embedded wallet form: no Delete, Primary hidden and forced on.
class WalletStep extends StatelessWidget {
  const WalletStep({super.key, required this.args});

  final WalletFormArgs args;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
      child: Column(
        children: [
          Text(
            l10n.onboarding_wallet_title,
            style: UITextStyleToken.interSemiBold.copyWith(fontSize: 26, color: colors.contentColor),
          ),
          const UISpace.vert(8),
          Text(
            l10n.onboarding_wallet_subtitle,
            textAlign: TextAlign.center,
            style: UITextStyleToken.interRegular.copyWith(fontSize: 15, color: colors.secondContentColor, height: 1.5),
          ),
          WalletFormBody(args: args, showPrimaryToggle: false, autofocusName: false),
        ],
      ),
    );
  }
}
