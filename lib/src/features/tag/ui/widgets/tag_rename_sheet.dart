import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';

/// Bottom sheet with a single prefilled name field. Resolves with the new
/// name, or null when dismissed / unchanged.
abstract class TagRenameSheet {
  static Future<String?> show(BuildContext context, {required String initialName}) {
    return UIModalSheet.modalSheet<String>(
      context: context,
      fitContent: true,
      title: context.l10n.tag_rename,
      child: _RenameBody(initialName: initialName),
    );
  }
}

class _RenameBody extends HookWidget {
  const _RenameBody({required this.initialName});

  final String initialName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = useTextEditingController(text: initialName);
    final text = useState(initialName);

    String cleaned() => text.value.trim().replaceFirst(RegExp(r'^#+'), '').trim();
    final canSave = cleaned().isNotEmpty && cleaned() != initialName;

    void submit() {
      if (!canSave) return;
      Navigator.of(context).pop(cleaned());
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UIInputField(
            controller: controller,
            autofocus: true,
            hintText: l10n.tag_name_placeholder,
            maxLength: kMaxTagLength,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.done,
            onChanged: (v) => text.value = v,
            onSubmitted: (_) => submit(),
          ),
          const UISpace.vert(16),
          UiPrimaryButton(
            label: l10n.common_save,
            enabled: canSave,
            onTap: submit,
          ),
        ],
      ),
    );
  }
}
