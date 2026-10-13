import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';

/// One prefilled text field in a sheet (debt note, person rename). Resolves
/// with the trimmed text, or null when dismissed / unchanged. [allowEmpty]
/// lets a note be cleared.
abstract class TextEntrySheet {
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String initial,
    required int maxLength,
    String? hint,
    bool allowEmpty = false,
  }) =>
      UIModalSheet.modalSheet<String>(
        context: context,
        fitContent: true,
        title: title,
        child: _Body(initial: initial, maxLength: maxLength, hint: hint, allowEmpty: allowEmpty),
      );
}

class _Body extends HookWidget {
  const _Body({required this.initial, required this.maxLength, this.hint, required this.allowEmpty});

  final String initial;
  final int maxLength;
  final String? hint;
  final bool allowEmpty;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: initial);
    final text = useState(initial);
    final value = text.value.trim();
    final canSave = value != initial.trim() && (allowEmpty || value.isNotEmpty);

    void submit() {
      if (canSave) Navigator.of(context).pop(value);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UIInputField(
            controller: controller,
            autofocus: true,
            hintText: hint,
            maxLength: maxLength,
            textInputAction: TextInputAction.done,
            onChanged: (v) => text.value = v,
            onSubmitted: (_) => submit(),
          ),
          const UISpace.vert(16),
          UiPrimaryButton(label: context.l10n.common_save, enabled: canSave, onTap: submit),
        ],
      ),
    );
  }
}
