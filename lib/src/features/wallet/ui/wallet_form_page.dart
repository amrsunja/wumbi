import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import 'wallet_form_notifier.dart';
import 'widgets/wallet_form_body.dart';

/// Create (no `walletId`) / Edit wallet. Slide-up modal.
@RoutePage()
class WalletFormPage extends ConsumerWidget {
  const WalletFormPage({super.key, @QueryParam('walletId') this.walletId});

  final String? walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final args = WalletFormArgs(walletId: walletId);
    final state = ref.watch(walletFormProvider(args));
    final notifier = ref.read(walletFormProvider(args).notifier);

    Future<void> save() async {
      final saved = await notifier.save();
      if (saved == null || !context.mounted) return;
      AppVibrations.medium();
      context.router.maybePop(saved.id);
    }

    Future<void> delete() async {
      final name = state.existing?.name ?? state.name;
      final ok = await UIAlertDialog.confirm(
        context,
        title: l10n.wallet_delete_title(name),
        message: l10n.wallet_delete_message,
        confirmLabel: l10n.common_delete,
        cancelLabel: l10n.common_cancel,
        destructive: true,
      );
      if (!ok) return;
      final paused = await notifier.delete();
      if (paused == null || !context.mounted) return;
      AppVibrations.heavy();
      ref.read(appEventProvider).send(
            ShowInfoMessageEvent(paused > 0 ? l10n.wallet_deleted_paused_rules(paused) : l10n.wallet_deleted),
          );
      // Pop twice (form + details) back to the Dashboard.
      context.router.popUntilRouteWithName(DashboardRoute.name);
    }

    return Scaffold(
      appBar: UIAppbar(backTap: () => context.router.maybePop()),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
                child: WalletFormBody(args: args),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (state.isEdit)
                    UiTextButton(
                      label: l10n.common_delete,
                      style: UiTextButtonStyle.secondary,
                      enabled: !state.isSaving && !state.isLoading,
                      onTap: delete,
                    )
                  else
                    const UISpace.horz(1),
                  UiTextButton(label: l10n.common_save, enabled: state.canSave, onTap: save),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
