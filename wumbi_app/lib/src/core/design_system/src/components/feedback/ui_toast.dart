import 'package:flutter/material.dart';

import '../../../app_ui.dart';

enum UiToastKind { success, info, error }

/// Top-of-screen toast card: palette colours only (blue = success, bismark =
/// info / error), icon + message, optional action. Drawn by `UiToastOverlay`.
class UiToast extends StatelessWidget {
  const UiToast({
    super.key,
    required this.message,
    required this.kind,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final UiToastKind kind;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final (Color bg, String icon) = switch (kind) {
      UiToastKind.success => (UIColorToken.blue, UIIconToken.icons.general.checkCircle),
      UiToastKind.info => (UIColorToken.bismark, UIIconToken.icons.general.infoCircle),
      UiToastKind.error => (UIColorToken.bismark, UIIconToken.icons.alertsFeedback.alertCircle),
    };

    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: bg.withValues(alpha: 0.28), blurRadius: 24, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            UIIcon(icon, size: 18, color: UIColorToken.white),
            const UISpace.horz(10),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.of(context).typo.inter.labelMedium.copyWith(color: UIColorToken.white),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const UISpace.horz(12),
              UITap(
                onTap: onAction,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    actionLabel!.toUpperCase(),
                    style: AppTheme.of(context).typo.inter.bold.copyWith(
                      color: UIColorToken.white,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Animated wrapper placed in the root [Overlay]: drops in from the top with a
/// spring (`easeOutBack` slide + fade + slight scale), leaves upward, and can
/// be swiped up to dismiss. [onDismissed] fires once the exit animation ends.
class UiToastOverlay extends StatefulWidget {
  const UiToastOverlay({
    super.key,
    required this.child,
    required this.duration,
    required this.onDismissed,
  });

  final Widget child;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<UiToastOverlay> createState() => UiToastOverlayState();
}

class UiToastOverlayState extends State<UiToastOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
      reverseDuration: const Duration(milliseconds: 260),
    );
    _slide = Tween(begin: const Offset(0, -1.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack, reverseCurve: Curves.easeInCubic),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5, curve: Curves.easeOut),
      reverseCurve: const Interval(0.4, 1, curve: Curves.easeIn),
    );
    _scale = Tween(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack, reverseCurve: Curves.easeIn),
    );
    _controller.forward();
    Future.delayed(widget.duration, dismiss);
  }

  /// Plays the exit animation, then reports [onDismissed].
  Future<void> dismiss() async {
    if (_dismissing || !mounted) return;
    _dismissing = true;
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.viewPaddingOf(context).top;
    return Positioned(
      top: top + 8,
      left: 16,
      right: 16,
      child: SafeArea(
        top: false,
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onVerticalDragEnd: (d) {
            if ((d.primaryVelocity ?? 0) < -80) dismiss();
          },
          onVerticalDragUpdate: (d) {
            if (d.primaryDelta != null && d.primaryDelta! < -6) dismiss();
          },
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: ScaleTransition(scale: _scale, alignment: Alignment.topCenter, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}
