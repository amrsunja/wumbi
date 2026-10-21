import 'package:flutter/material.dart';

import '../../app_ui.dart';

/// Period browser shared by Budget Details and Progress:
///
/// ```
/// (‹)        October 2026         (›)
///          vs September 2026 ⌄
///             Back to today
/// ```
/// Round 40 px arrows on the card colour (dimmed when there is nowhere to
/// go), the label and caption slide in the browsing direction, and a blue
/// "back" link shows away from the running period. [onCaptionTap] turns the
/// caption into a picker (chevron).
class UiPeriodNavigator extends StatefulWidget {
  const UiPeriodNavigator({
    super.key,
    required this.label,
    required this.position,
    this.caption,
    this.onCaptionTap,
    this.onPrevious,
    this.onNext,
    this.backLabel,
    this.onBackToCurrent,
    this.showArrows = true,
  });

  final String label;

  /// Ordinal of the shown period (bigger = later): drives the slide direction.
  final int position;
  final String? caption;
  final VoidCallback? onCaptionTap;

  /// Null = dimmed arrow.
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  /// Link back to the running period; hidden while null.
  final String? backLabel;
  final VoidCallback? onBackToCurrent;

  /// False for single-period ranges (one-time budget).
  final bool showArrows;

  @override
  State<UiPeriodNavigator> createState() => _UiPeriodNavigatorState();
}

class _UiPeriodNavigatorState extends State<UiPeriodNavigator> {
  /// +1 = forward in time (slide from the right), −1 = back.
  int _direction = 1;

  @override
  void didUpdateWidget(UiPeriodNavigator old) {
    super.didUpdateWidget(old);
    if (widget.position != old.position) _direction = widget.position > old.position ? 1 : -1;
  }

  Widget _slide(Widget child, Object key) => AnimatedSwitcher(
        duration: UIAnim.fast,
        switchInCurve: UIAnim.easeOut,
        switchOutCurve: UIAnim.easeOut,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.center,
          children: [...previous, ?current],
        ),
        transitionBuilder: (child, animation) {
          final incoming = child.key == ValueKey(key);
          final dx = (incoming ? 0.25 : -0.25) * _direction;
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: Offset(dx, 0), end: Offset.zero).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(key: ValueKey(key), child: child),
      );

  @override
  Widget build(BuildContext context) {
    final typo = AppTheme.of(context).typo.inter;
    final caption = widget.caption;
    final back = widget.backLabel;

    final center = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _slide(
          Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: typo.rowTitle,
          ),
          widget.label,
        ),
        if (caption != null)
          widget.onCaptionTap != null
              ? UiSelectButton(title: caption, style: typo.caption, onTap: widget.onCaptionTap)
              : Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: _slide(
                    Text(
                      caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: typo.caption,
                    ),
                    caption,
                  ),
                ),
        AnimatedSize(
          duration: UIAnim.fast,
          curve: UIAnim.easeOut,
          child: back == null
              ? const SizedBox(width: double.infinity)
              : UITap(
                  onTap: widget.onBackToCurrent,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(back, style: typo.captionBold.copyWith(color: UIColorToken.blue)),
                  ),
                ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: !widget.showArrows
          ? center
          : Row(
              children: [
                _NavButton(icon: UIIconToken.icons.arrows.chevronLeft, onTap: widget.onPrevious),
                Expanded(child: center),
                _NavButton(icon: UIIconToken.icons.arrows.chevronRight, onTap: widget.onNext),
              ],
            ),
    );
  }
}

/// Round 40 px arrow on the card colour; dimmed when there is nowhere to go.
class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return AnimatedOpacity(
      duration: UIAnim.fast,
      opacity: onTap == null ? 0.3 : 1,
      child: UITap(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: colors.fgColor, shape: BoxShape.circle),
          child: UIIcon(icon, size: 20),
        ),
      ),
    );
  }
}
