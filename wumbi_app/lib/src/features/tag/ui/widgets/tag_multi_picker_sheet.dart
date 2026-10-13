import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../data/models/tag_model.dart';
import 'tag_chip_selector.dart';

/// Several existing tags at once (budget scope), built on [TagChipSelector].
/// Resolves with the chosen tags on Done (empty = any tag), null when
/// dismissed. At most [maxTags] can be picked.
abstract class TagMultiPickerSheet {
  static Future<List<TagModel>?> show(
    BuildContext context, {
    required List<TagModel> selected,
    required String title,
    required int maxTags,
  }) =>
      UIModalSheet.modalSheet<List<TagModel>>(
        context: context,
        title: title,
        height: 0.7,
        child: _Body(initial: selected, maxTags: maxTags),
      );
}

class _Body extends HookWidget {
  const _Body({required this.initial, required this.maxTags});

  final List<TagModel> initial;
  final int maxTags;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = useState<List<TagModel>>([...initial]);

    void toggle(TagModel tag) {
      final current = selected.value;
      if (current.any((t) => t.id == tag.id)) {
        AppVibrations.light();
        selected.value = current.where((t) => t.id != tag.id).toList();
        return;
      }
      if (current.length >= maxTags) {
        AppVibrations.error();
        return;
      }
      AppVibrations.light();
      selected.value = [...current, tag];
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: TagChipSelector(
                selected: selected.value.map((t) => t.id).toSet(),
                onToggle: toggle,
                emptyText: l10n.wallet_filter_no_tags,
              ),
            ),
          ),
        ),
        Text(l10n.validation_up_to_tags(maxTags), style: context.typo.inter.caption),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: UiTextButton(
                  label: l10n.common_clear,
                  style: UiTextButtonStyle.secondary,
                  fontSize: 16,
                  onTap: () => selected.value = const [],
                ),
              ),
              Expanded(
                flex: 2,
                child: UiPrimaryButton(
                  label: l10n.common_done,
                  onTap: () => Navigator.of(context).pop(selected.value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
