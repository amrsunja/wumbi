import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../utils/app_vibrations.dart';
import '../../../app_ui.dart';

/// X-style side menu. The page slides toward the trailing edge — its
/// menu-side corners rounding in — and pulls the menu in, glued to its
/// leading edge. While a finger drags, menu and page
/// follow it 1:1 from the touch-down point; on release they settle open or
/// closed with the finger's velocity.
///
/// Opens by
/// - a toward-trailing swipe anywhere on the page that no inner horizontal
///   scrollable claims (app bar, header, empty state);
/// - a toward-trailing swipe inside a [UiSideMenuDragArea] — put one around
///   the first page of an inner `PageView`: it takes only toward-trailing
///   swipes, so the `PageView` still pages forward;
/// - [UiSideMenu.of] `.open()` (menu button).
///
/// Closes by a toward-leading swipe on the menu or on the dimmed page, a tap
/// on the dimmed page, the system back, or [UiSideMenuState.close].
/// RTL-aware: with `ar` it opens from the right.
class UiSideMenu extends StatefulWidget {
  const UiSideMenu({
    super.key,
    required this.menu,
    required this.child,
    this.closeLabel,
    this.maxMenuWidth = 320,
  });

  /// Menu content. Built only while the menu is (partly) visible.
  final Widget menu;

  /// The page.
  final Widget child;

  /// Screen-reader label of the dimmed page (tap = close).
  final String? closeLabel;

  /// Menu width = 82 % of the screen, at most this.
  final double maxMenuWidth;

  static UiSideMenuState of(BuildContext context) => maybeOf(context)!;

  static UiSideMenuState? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_UiSideMenuScope>()?.state;

  @override
  State<UiSideMenu> createState() => UiSideMenuState();
}

class UiSideMenuState extends State<UiSideMenu> with SingleTickerProviderStateMixin {
  /// 0 = closed, 1 = open; drives every transform.
  late final AnimationController _progress = AnimationController(vsync: this)..addStatusListener(_onStatus);

  double _menuWidth = 1;
  AnimationStatus _lastStatus = AnimationStatus.dismissed;

  /// 0..1 open fraction (e.g. to fade something with the menu).
  Animation<double> get progress => _progress.view;

  bool get isOpen => _progress.value > 0;

  /// +1: opens by a left → right swipe; −1 in RTL.
  double get _openSign => Directionality.of(context) == TextDirection.rtl ? -1 : 1;

  void open() {
    _progress.animateTo(1, duration: UIAnim.page, curve: UIAnim.emphasized);
  }

  TickerFuture close() => _progress.animateBack(0, duration: UIAnim.fast, curve: UIAnim.easeOut);

  /// Runs [action] (a push from a menu item) right away — no waiting for the
  /// menu to close. The next route slides in over the open menu; once it
  /// fully covers this page the menu snaps shut unseen, so going back lands
  /// on the plain page. If nothing covers the page (the push didn't happen),
  /// the menu just closes.
  void navigate(VoidCallback action) {
    action();
    final covered = ModalRoute.of(context)?.secondaryAnimation;
    if (covered == null) {
      close();
      return;
    }

    var done = false;
    late final AnimationStatusListener onCovered;
    void finish({required bool snap}) {
      if (done) return;
      done = true;
      covered.removeStatusListener(onCovered);
      if (!mounted) return;
      if (snap) {
        _progress.value = 0;
      } else {
        close();
      }
    }

    onCovered = (status) {
      if (status == AnimationStatus.completed) finish(snap: true);
    };
    covered.addStatusListener(onCovered);
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!done && !covered.isCompleted) finish(snap: false);
    });
  }

  void _onStatus(AnimationStatus status) {
    // A light tap once the menu lands open (drag release, fling or ☰).
    // `selectionClick` was too faint to notice on most devices.
    if (status == AnimationStatus.completed && _lastStatus != AnimationStatus.completed) {
      AppVibrations.light();
    }
    // `canPop` and the page's hit-testing depend on "fully closed".
    if ((status == AnimationStatus.dismissed) != (_lastStatus == AnimationStatus.dismissed)) {
      setState(() {});
    }
    _lastStatus = status;
  }

  // ---------------------------------------------------------------- drag

  void _dragStart(DragStartDetails _) => _progress.stop();

  void _dragUpdate(DragUpdateDetails d) {
    _progress.value += (d.primaryDelta ?? 0) * _openSign / _menuWidth;
  }

  void _dragEnd(DragEndDetails d) {
    // Progress units per second, positive = toward open.
    final velocity = (d.primaryVelocity ?? 0) * _openSign / _menuWidth;
    final shouldOpen = velocity.abs() >= _kFlingVelocity ? velocity > 0 : _progress.value >= 0.5;
    if (_progress.value == (shouldOpen ? 1 : 0)) return; // already there
    // Spring from the finger's speed; at least 1 so a slow release still
    // settles briskly. Overshoot is clamped at the bound: a hard stop.
    _progress.fling(velocity: shouldOpen ? math.max(velocity, 1) : math.min(velocity, -1));
  }

  void _dragCancel() {
    final v = _progress.value;
    if (v == 0 || v == 1) return;
    _progress.fling(velocity: v >= 0.5 ? 1 : -1);
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    final sign = _openSign;
    final closed = _progress.isDismissed;
    final scrim = colors.isDark ? UIColorToken.black.withValues(alpha: 0.5) : UIColorToken.bismark.withValues(alpha: 0.22);

    return PopScope(
      canPop: closed,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) close();
      },
      child: _UiSideMenuScope(
        state: this,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = _menuWidth = math.min(constraints.maxWidth * 0.82, widget.maxMenuWidth);

            return AnimatedBuilder(
              animation: _progress,
              // Same instance every frame: only the transforms repaint, the
              // page never rebuilds because of the drag.
              child: IgnorePointer(
                ignoring: !closed,
                child: ExcludeSemantics(
                  excluding: !closed,
                  child: UiSideMenuDragArea(behavior: HitTestBehavior.translucent, child: widget.child),
                ),
              ),
              builder: (context, page) {
                final t = _progress.value;
                final dx = width * t * sign;
                // The page's menu-side corners round in with the drag, like
                // a card lifted aside (X).
                final corner = Radius.circular(_kPageCornerRadius * t);
                final radius = sign > 0 ? BorderRadius.horizontal(left: corner) : BorderRadius.horizontal(right: corner);

                return Stack(
                  children: [
                    // Ground showing through the rounded corners: the menu's
                    // colour, so the page reads as a card lying on it.
                    Positioned.fill(child: t > 0 ? ColoredBox(color: colors.bgColor) : const SizedBox.shrink()),
                    // Menu glued to the page's leading edge, painted *under*
                    // the page: whatever pokes out of it (the peeking mascot)
                    // hides behind the page and shows through its corners.
                    // Always present so the page keeps its index (and state).
                    PositionedDirectional(
                      top: 0,
                      bottom: 0,
                      start: 0,
                      width: width,
                      child: t > 0
                          ? Transform.translate(
                              offset: Offset(dx - width * sign, 0),
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                dragStartBehavior: DragStartBehavior.down,
                                onHorizontalDragStart: _dragStart,
                                onHorizontalDragUpdate: _dragUpdate,
                                onHorizontalDragEnd: _dragEnd,
                                onHorizontalDragCancel: _dragCancel,
                                child: ColoredBox(color: colors.bgColor, child: widget.menu),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    Transform.translate(
                      offset: Offset(dx, 0),
                      child: ClipRRect(
                        borderRadius: radius,
                        clipBehavior: t > 0 ? Clip.antiAlias : Clip.none,
                        child: Stack(
                          children: [
                            page!,
                            if (t > 0)
                              // Dimmed page: tap or swipe back to close.
                              Positioned.fill(
                                child: Semantics(
                                  button: true,
                                  label: widget.closeLabel,
                                  onTap: close,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    dragStartBehavior: DragStartBehavior.down,
                                    onTap: close,
                                    onHorizontalDragStart: _dragStart,
                                    onHorizontalDragUpdate: _dragUpdate,
                                    onHorizontalDragEnd: _dragEnd,
                                    onHorizontalDragCancel: _dragCancel,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: scrim.withValues(alpha: scrim.a * t),
                                        borderRadius: radius,
                                        border: Border.all(color: colors.dividerColor.withValues(alpha: colors.dividerColor.a * t)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Corner radius of the page's menu-side edge when fully open (≈ a phone's
/// screen corner).
const double _kPageCornerRadius = 40;

/// A release faster than this (menu widths per second) decides by direction
/// alone, whatever the position.
const double _kFlingVelocity = 1.2;

/// Moving this far the closing way before the drag slop rejects the swipe,
/// leaving it to an inner `PageView` / scrollable.
const double _kWrongWaySlop = 6;

class _UiSideMenuScope extends InheritedWidget {
  const _UiSideMenuScope({required this.state, required super.child});

  final UiSideMenuState state;

  @override
  bool updateShouldNotify(_UiSideMenuScope oldWidget) => state != oldWidget.state;
}

/// Opens the nearest [UiSideMenu] by a toward-trailing swipe that follows
/// the finger. Toward-leading swipes are left to whatever else is under the
/// finger, so wrapping the first page of a `PageView` keeps its paging.
/// Does nothing outside a [UiSideMenu].
class UiSideMenuDragArea extends StatelessWidget {
  const UiSideMenuDragArea({super.key, required this.child, this.behavior = HitTestBehavior.translucent});

  final Widget child;
  final HitTestBehavior behavior;

  @override
  Widget build(BuildContext context) {
    final menu = UiSideMenu.maybeOf(context);
    if (menu == null) return child;
    final sign = Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0;

    return RawGestureDetector(
      behavior: behavior,
      gestures: {
        _OpenSwipeRecognizer: GestureRecognizerFactoryWithHandlers<_OpenSwipeRecognizer>(
          () => _OpenSwipeRecognizer(debugOwner: this),
          (r) => r
            ..openSign = sign
            ..dragStartBehavior = DragStartBehavior.down
            ..onlyAcceptDragOnThreshold = true
            ..onStart = menu._dragStart
            ..onUpdate = menu._dragUpdate
            ..onEnd = menu._dragEnd
            ..onCancel = menu._dragCancel,
        ),
      },
      child: child,
    );
  }
}

/// Horizontal drag that bows out as soon as the finger heads the closing
/// way. Placed inside a horizontal scrollable it is asked first (inner
/// recognizers see each move first), so it wins toward-trailing swipes and
/// hands toward-leading ones to the scrollable before its slop is reached.
class _OpenSwipeRecognizer extends HorizontalDragGestureRecognizer {
  _OpenSwipeRecognizer({super.debugOwner});

  /// +1: opening = finger moves right (LTR); −1 in RTL.
  double openSign = 1;

  final Map<int, Offset> _origins = {};
  bool _won = false;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    _origins[event.pointer] = event.position;
  }

  @override
  void handleEvent(PointerEvent event) {
    final origin = _origins[event.pointer];
    if (!_won && origin != null && event is PointerMoveEvent) {
      final d = event.position - origin;
      if (d.dx * openSign <= -_kWrongWaySlop && d.dx.abs() >= d.dy.abs()) {
        _origins.remove(event.pointer);
        resolvePointer(event.pointer, GestureDisposition.rejected);
        return;
      }
    }
    super.handleEvent(event);
  }

  @override
  void acceptGesture(int pointer) {
    _won = true;
    super.acceptGesture(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _won = false;
    _origins.clear();
    super.didStopTrackingLastPointer(pointer);
  }
}
