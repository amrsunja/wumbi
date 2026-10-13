import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../data/models/tag_model.dart';
import '../../data/tag_repository.dart';

/// Every live tag as a wrap of toggleable `#tag` pills (most used first).
/// Shared by the wallet transaction filter and the budget tag picker so the
/// two selectors look and behave the same.
class TagChipSelector extends HookConsumerWidget {
  const TagChipSelector({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.emptyText,
  });

  /// Selected tag ids.
  final Set<String> selected;
  final ValueChanged<TagModel> onToggle;

  /// Shown when the user has no tag yet.
  final String emptyText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsFuture = useMemoized(() => ref.read(tagRepositoryProvider).listAll());
    final snapshot = useFuture(tagsFuture);
    final List<TagModel>? tags =
        snapshot.hasData ? snapshot.data!.when((list) => list, (_) => const <TagModel>[]) : null;

    if (tags == null) return const SizedBox(height: 28);
    if (tags.isEmpty) return Text(emptyText, style: context.typo.inter.hint);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tag in tags)
          SelectChip(
            label: '#${tag.displayName}',
            selected: selected.contains(tag.id),
            onTap: () => onToggle(tag),
          ),
      ],
    );
  }
}

/// Selectable pill (date presets, tags): blue 12 % fill + blue text when
/// selected, outlined and muted otherwise — same look as the card's tag pills.
class SelectChip extends StatelessWidget {
  const SelectChip({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return UITap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? UIColorToken.blue.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(color: selected ? Colors.transparent : colors.dividerColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: context.typo.inter.chip.copyWith(color: selected ? UIColorToken.blue : colors.secondContentColor),
        ),
      ),
    );
  }
}
