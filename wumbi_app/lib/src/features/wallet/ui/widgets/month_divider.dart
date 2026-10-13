import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';

/// Group header inside a transaction list: uppercase overline label centred
/// between two hairlines (`──── SEPTEMBER 2026 ────`), optionally a centred
/// caption under it (the upcoming hint). Usually the pinned header of a
/// [SliverStickySection].
class MonthDivider extends StatelessWidget {
  const MonthDivider({super.key, required this.label, this.caption});

  final String label;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(child: UIDivider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(label.toUpperCase(), maxLines: 1, style: typo.overline),
              ),
              const Expanded(child: UIDivider()),
            ],
          ),
          if (caption != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(caption!, style: typo.caption, textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }
}

/// Telegram-style section of a transaction list: [header] pins to the top of
/// the scroll view (right under the filters bar / tab bar) while any of the
/// section's rows are on screen, then the next section's header pushes it
/// out. The header gets the page background so rows slide under it, and
/// while it is pinned a "smoke" tail under it dissolves the rows like
/// `UIScrollEdgeFade` does on other lists. The horizontal list padding is
/// applied here (header background stays full-width).
///
/// Use as a direct sliver of the `CustomScrollView` — don't nest sections
/// inside another `SliverMainAxisGroup`.
class SliverStickySection extends StatelessWidget {
  const SliverStickySection({super.key, required this.header, required this.sliver});

  final Widget header;

  /// The section's rows (a `SliverList`).
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        // scrollOffset > 0 ⇔ the list has scrolled past the header's own
        // slot, i.e. it is pinned (or being pushed out).
        SliverLayoutBuilder(
          builder: (context, constraints) => PinnedHeaderSliver(
            child: _StickyHeader(pinned: constraints.scrollOffset > 0, child: header),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
          sliver: sliver,
        ),
      ],
    );
  }
}

/// Opaque header + the smoke tail painted below its box (outside its layout,
/// so it never adds height). The group paints its first child last, so the
/// tail lies over the rows.
class _StickyHeader extends StatelessWidget {
  const _StickyHeader({required this.pinned, required this.child});

  static const double _smoke = 28;

  final bool pinned;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bg = context.colors.bgColor;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ColoredBox(
          color: bg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
            child: child,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -_smoke,
          height: _smoke,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: pinned ? 1 : 0,
              duration: UIAnim.fast,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [bg, bg.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
