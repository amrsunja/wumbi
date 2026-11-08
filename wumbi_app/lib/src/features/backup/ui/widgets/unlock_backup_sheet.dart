import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/errors/exceptions/domain/domain_exceptions.dart';
import '../../../../core/errors/failures/failures.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/typedefs.dart';
import '../../data/backup_codec.dart';
import '../../data/backup_repository.dart';
import '../backup_controller.dart';

/// Password entry for an encrypted backup. A wrong password stays in the
/// sheet (inline error, try again); any other result closes it. Null when
/// dismissed.
abstract class UnlockBackupSheet {
  static Future<SuccessOrError<BackupPreview>?> show(BuildContext context, BackupEnvelope envelope) =>
      UIModalSheet.modalSheet<SuccessOrError<BackupPreview>>(
        context: context,
        fitContent: true,
        title: context.l10n.backup_unlock_title,
        child: _Body(envelope: envelope),
      );
}

class _Body extends HookConsumerWidget {
  const _Body({required this.envelope});

  final BackupEnvelope envelope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final password = useTextEditingController();
    useListenable(password);
    final obscure = useState(true);
    final working = useState(false);
    final wrong = useState(false);

    Future<void> unlock() async {
      if (password.text.isEmpty || working.value) return;
      working.value = true;
      wrong.value = false;
      final result = await ref.read(backupControllerProvider.notifier).openBackup(envelope, password: password.text);
      if (!context.mounted) return;
      working.value = false;
      if (result == null) return;
      final isWrong = result.when(
        (_) => false,
        (e) => e is BackupFailure && e.reason == BackupErrorReason.wrongPassword,
      );
      if (isWrong) {
        AppVibrations.error();
        wrong.value = true;
        password.selection = TextSelection(baseOffset: 0, extentOffset: password.text.length);
        return;
      }
      Navigator.of(context).pop(result);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(l10n.backup_unlock_desc, style: context.typo.inter.caption, textAlign: TextAlign.center),
          ),
          const UISpace.vert(16),
          UIInputField(
            controller: password,
            autofocus: true,
            enabled: !working.value,
            hintText: l10n.backup_password_hint,
            obscureText: obscure.value,
            fillColor: context.colors.secondContentColor.withValues(alpha: 0.08),
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onChanged: (_) => wrong.value = false,
            onSubmitted: (_) => unlock(),
            suffixIcon: UITap(
              onTap: () => obscure.value = !obscure.value,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UIIcon(
                  obscure.value ? UIIconToken.icons.general.eye : UIIconToken.icons.general.eyeOff,
                  size: 18,
                ),
              ),
            ),
          ),
          const UISpace.vert(8),
          UiFormHint(
            text: wrong.value ? l10n.backup_error_wrong_password : null,
            icon: UIIconToken.icons.alertsFeedback.alertCircle,
            color: UIColorToken.neg500,
          ),
          const UISpace.vert(16),
          UiPrimaryButton(
            label: l10n.backup_unlock_action,
            enabled: password.text.isNotEmpty,
            loading: working.value,
            onTap: unlock,
          ),
        ],
      ),
    );
  }
}
