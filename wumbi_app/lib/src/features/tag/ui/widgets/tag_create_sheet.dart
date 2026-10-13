import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/state_management/app_events.dart';
import '../../../../core/utils/state_management/single_events.dart';
import '../../data/models/tag_model.dart';
import '../../data/tag_normalizer.dart';
import '../../data/tag_repository.dart';
import 'tag_visuals.dart';

/// "New tag" flow shared by the tags hub (+) and a tag's page ("Add nested
/// tag"): sheet → create (`food/coffee` also creates `food`) → toast with an
/// Open action. Resolves with the created / existing tag, or null.
Future<TagModel?> createTagFlow(BuildContext context, WidgetRef ref, {String? parentPath}) async {
  final l10n = context.l10n;
  final path = await TagCreateSheet.show(context, parentPath: parentPath);
  if (path == null || !context.mounted) return null;
  final result = await ref.read(tagRepositoryProvider).create(path);
  if (!context.mounted) return null;
  final events = ref.read(appEventProvider);
  TagModel? out;
  result.when(
    (value) {
      out = value.tag;
      if (value.created) AppVibrations.light();
      final router = context.router;
      events.send(
        ShowInfoMessageEvent(
          value.created ? l10n.tags_created(value.tag.displayName) : l10n.tags_exists(value.tag.displayName),
          actionLabel: l10n.tags_graph_open,
          onAction: () => router.push(TagDetailsRoute(tagId: value.tag.id)),
        ),
      );
    },
    (error) {
      events.send(ShowErrorEvent(error));
    },
  );
  return out;
}

/// Name field + parent picker + live `#parent/name` preview. Resolves with
/// the full path, or null when dismissed.
abstract class TagCreateSheet {
  static Future<String?> show(BuildContext context, {String? parentPath}) {
    return UIModalSheet.modalSheet<String>(
      context: context,
      fitContent: true,
      title: context.l10n.tags_new,
      child: _CreateBody(initialParent: parentPath),
    );
  }
}

class _CreateBody extends HookConsumerWidget {
  const _CreateBody({this.initialParent});

  final String? initialParent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final text = useState('');
    final parent = useState<String?>(initialParent);
    final tagsFuture = useMemoized(() => ref.read(tagRepositoryProvider).listAll());
    final tags = useFuture(tagsFuture).data?.tryGetSuccess() ?? const <TagModel>[];

    final name = TagNormalizer.display(text.value);
    final path = name.isEmpty
        ? ''
        : parent.value == null
            ? name
            : '${parent.value}${TagNormalizer.separator}$name';
    final canSave = name.isNotEmpty && path.length <= kMaxTagLength;

    void submit() {
      if (!canSave) return;
      Navigator.of(context).pop(path);
    }

    // Scrolls when the keyboard leaves less room than the content needs.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UIInputField(
            autofocus: true,
            hintText: l10n.tags_name_hint,
            maxLength: kMaxTagLength,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.done,
            onChanged: (v) => text.value = v,
            onSubmitted: (_) => submit(),
          ),
          const UISpace.vert(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(l10n.tags_create_tip, style: typo.caption),
          ),
          if (tags.isNotEmpty) ...[
            UiSectionLabel(text: l10n.tags_parent, padding: const EdgeInsets.fromLTRB(4, 20, 4, 8)),
            TagParentChips(
              tags: tags,
              selected: parent.value,
              onSelected: (p) => parent.value = p,
            ),
          ],
          const UISpace.vert(20),
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: path.isEmpty ? 0.35 : 1,
              child: TagChip(
                path: path.isEmpty ? (parent.value == null ? '…' : '${parent.value}/…') : path,
              ),
            ),
          ),
          const UISpace.vert(20),
          UiPrimaryButton(label: l10n.tags_create, enabled: canSave, onTap: submit),
        ],
      ),
    );
  }
}

/// "No parent" + every tag as a selectable chip, in a short scroll box.
/// [exclude]: normalized path whose subtree cannot be picked (moving a tag
/// inside itself).
class TagParentChips extends StatelessWidget {
  const TagParentChips({
    super.key,
    required this.tags,
    required this.selected,
    required this.onSelected,
    this.exclude,
    this.noneLabel,
  });

  final List<TagModel> tags;

  /// Display path of the chosen parent; null = none / top level.
  final String? selected;
  final ValueChanged<String?> onSelected;
  final String? exclude;
  final String? noneLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = [
      for (final t in tags)
        if (exclude == null || !TagNormalizer.isSelfOrDescendant(t.normalizedName, exclude!)) t,
    ]..sort((a, b) => a.normalizedName.compareTo(b.normalizedName));
    final selectedNormalized = selected == null ? null : TagNormalizer.normalize(selected!);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 132),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _NoneChip(
              label: noneLabel ?? l10n.tags_parent_none,
              selected: selected == null,
              onTap: () => onSelected(null),
            ),
            for (final t in options)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(t.displayName),
                child: TagChip(path: t.displayName, selected: t.normalizedName == selectedNormalized),
              ),
          ],
        ),
      ),
    );
  }
}

/// "No parent" / "Top level" option: neutral outline, blue when chosen.
class _NoneChip extends StatelessWidget {
  const _NoneChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? UIColorToken.blue.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? UIColorToken.blue : colors.dividerColor, width: 1.2),
        ),
        child: Text(
          label,
          style: context.typo.inter.semiBold.copyWith(
            fontSize: 13,
            color: selected ? UIColorToken.blue : colors.secondContentColor,
          ),
        ),
      ),
    );
  }
}

/// Pick a new parent for a tag (or the top level). Resolves with a record:
/// `(parent: null)` = top level; null = dismissed / unchanged.
abstract class TagMoveSheet {
  static Future<({String? parent})?> show(BuildContext context, {required TagModel tag}) {
    return UIModalSheet.modalSheet<({String? parent})>(
      context: context,
      fitContent: true,
      title: context.l10n.tag_move_title(tag.leafName),
      child: _MoveBody(tag: tag),
    );
  }
}

class _MoveBody extends HookConsumerWidget {
  const _MoveBody({required this.tag});

  final TagModel tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentParent = TagNormalizer.parentOf(tag.displayName);
    final parent = useState<String?>(currentParent);
    final tagsFuture = useMemoized(() => ref.read(tagRepositoryProvider).listAll());
    final tags = useFuture(tagsFuture).data?.tryGetSuccess() ?? const <TagModel>[];

    final changed = (parent.value == null ? null : TagNormalizer.normalize(parent.value!)) !=
        (currentParent == null ? null : TagNormalizer.normalize(currentParent));
    final preview = parent.value == null ? tag.leafName : '${parent.value}${TagNormalizer.separator}${tag.leafName}';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TagParentChips(
            tags: tags,
            selected: parent.value,
            exclude: tag.normalizedName,
            noneLabel: l10n.tag_top_level,
            onSelected: (p) => parent.value = p,
          ),
          const UISpace.vert(20),
          Center(child: TagChip(path: preview)),
          const UISpace.vert(20),
          UiPrimaryButton(
            label: l10n.common_save,
            enabled: changed && preview.length <= kMaxTagLength,
            onTap: () => Navigator.of(context).pop((parent: parent.value)),
          ),
        ],
      ),
    );
  }
}
