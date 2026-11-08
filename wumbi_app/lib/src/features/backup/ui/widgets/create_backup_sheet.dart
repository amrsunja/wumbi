import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/state_management/app_events.dart';
import '../../../../core/utils/state_management/single_events.dart';
import '../../data/backup_codec.dart';
import '../backup_controller.dart';
import '../backup_file_delivery.dart';

enum _Delivery { save, share }

/// Settings → Backup → Create backup: optional password, then the file goes
/// to the system "save" dialog or the share sheet.
abstract class CreateBackupSheet {
  static Future<void> show(BuildContext context) => UIModalSheet.modalSheet<void>(
    context: context,
    fitContent: true,
    title: context.l10n.backup_sheet_title,
    child: const _Body(),
  );
}

class _Body extends HookConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final protect = useState(true);
    final obscure = useState(true);
    final password = useTextEditingController();
    final confirm = useTextEditingController();
    useListenable(password);
    useListenable(confirm);
    final submitted = useState(false);
    final working = useState<_Delivery?>(null);

    final pw = password.text;
    final tooShort = pw.length < BackupFormat.minPasswordLength;
    final mismatch = confirm.text != pw;
    final valid = !protect.value || (!tooShort && !mismatch);

    // Errors appear once the user tried, or once both fields are filled.
    final showErrors = submitted.value || (pw.isNotEmpty && confirm.text.isNotEmpty);
    final String? error = !protect.value || !showErrors
        ? null
        : tooShort
        ? l10n.backup_password_too_short(BackupFormat.minPasswordLength)
        : mismatch
        ? l10n.backup_password_mismatch
        : null;

    Future<void> run(_Delivery delivery) async {
      submitted.value = true;
      if (!valid || working.value != null) {
        if (!valid) AppVibrations.error();
        return;
      }
      FocusScope.of(context).unfocus();
      final box = context.findRenderObject() as RenderBox?;
      final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
      working.value = delivery;
      try {
        final result = await ref
            .read(backupControllerProvider.notifier)
            .createBackup(password: protect.value ? password.text : null);
        if (result == null || !context.mounted) return;
        final file = result.when((f) => f, (e) {
          ref.read(appEventProvider).send(ShowErrorEvent(e));
          return null;
        });
        if (file == null) return;

        switch (delivery) {
          case _Delivery.save:
            if (await BackupFileDelivery.save(file)) {
              ref.read(appEventProvider).send(ShowSuccessMessageEvent(l10n.backup_saved));
              if (context.mounted) Navigator.of(context).pop();
            }
          case _Delivery.share:
            await BackupFileDelivery.share(file, origin: origin);
            if (context.mounted) Navigator.of(context).pop();
        }
      } catch (_) {
        ref.read(appEventProvider).send(ShowErrorEvent(null, defaultMessage: l10n.error_unknown));
      } finally {
        if (context.mounted) working.value = null;
      }
    }

    final eye = UITap(
      onTap: () => obscure.value = !obscure.value,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: UIIcon(obscure.value ? UIIconToken.icons.general.eye : UIIconToken.icons.general.eyeOff, size: 18),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(l10n.backup_create_desc, style: typo.caption, textAlign: TextAlign.center),
          ),
          const UISpace.vert(16),
          UiGroupCard(
            children: [
              UiToggleRow(
                title: l10n.backup_password_toggle,
                description: l10n.backup_password_toggle_desc,
                value: protect.value,
                onChanged: (on) {
                  AppVibrations.selection();
                  protect.value = on;
                  submitted.value = false;
                },
              ),
            ],
          ),
          AnimatedSize(
            duration: UIAnim.fast,
            alignment: Alignment.topCenter,
            child: protect.value
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const UISpace.vert(12),
                      UIInputField(
                        controller: password,
                        hintText: l10n.backup_password_hint,
                        obscureText: obscure.value,
                        fillColor: context.colors.secondContentColor.withValues(alpha: 0.08),
                        autofillHints: const [AutofillHints.newPassword],
                        textInputAction: TextInputAction.next,
                        suffixIcon: eye,
                      ),
                      const UISpace.vert(8),
                      UIInputField(
                        controller: confirm,
                        hintText: l10n.backup_password_confirm_hint,
                        obscureText: obscure.value,
                        fillColor: context.colors.secondContentColor.withValues(alpha: 0.08),
                        autofillHints: const [AutofillHints.newPassword],
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => run(_Delivery.save),
                      ),
                      const UISpace.vert(8),
                      UiFormHint(
                        text: error ?? l10n.backup_password_warning,
                        icon: error == null
                            ? UIIconToken.icons.security.lock01
                            : UIIconToken.icons.alertsFeedback.alertCircle,
                        color: error == null ? UIColorToken.casperDark : UIColorToken.neg500,
                        maxLines: 3,
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: UiFormHint(
                      text: l10n.backup_no_password_warning,
                      icon: UIIconToken.icons.alertsFeedback.alertTriangle,
                      color: UIColorToken.buttercup,
                      maxLines: 3,
                    ),
                  ),
          ),
          const UISpace.vert(20),
          UiPrimaryButton(
            label: l10n.backup_save_to_device,
            enabled: valid || !submitted.value,
            loading: working.value == _Delivery.save,
            onTap: working.value == null ? () => run(_Delivery.save) : null,
          ),
          const UISpace.vert(4),
          working.value == _Delivery.share
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: UIColorToken.blue),
                    ),
                  ),
                )
              : Center(
                  child: UiTextButton(
                    label: l10n.backup_share,
                    fontSize: 16,
                    enabled: working.value == null,
                    onTap: () => run(_Delivery.share),
                  ),
                ),
        ],
      ),
    );
  }
}
