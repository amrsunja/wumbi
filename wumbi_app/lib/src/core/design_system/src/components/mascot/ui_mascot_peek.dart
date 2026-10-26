import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// The hamster's home on every screen: its head peeking up from the
/// bottom-start corner (opposite the FAB). Place it with
/// `PositionedDirectional(start: …, bottom: 0)`; it adds the bottom safe
/// area itself, so the head always clears the home indicator.
///
/// - slides up [enterDelay] after mounting, and again each time [replay]
///   changes (the page came back on top);
/// - [hidden] sinks it (while the hamster is out on the stage);
/// - [raised] shows more of it (a reaction is playing);
/// - [badge]: a small dot — something worth hearing.
class UiMascotPeek extends StatefulWidget {
  const UiMascotPeek({
    super.key,
    required this.mood,
    this.onTap,
    this.badge = false,
    this.raised = false,
    this.hidden = false,
    this.replay = 0,
    this.semanticLabel,
  });

  final WumbiMood mood;
  final VoidCallback? onTap;
  final bool badge;
  final bool raised;
  final bool hidden;
  final int replay;
  final String? semanticLabel;

  /// Full height of the hamster; [peekFraction] of it shows at rest.
  static const double size = 104;
  static const double peekFraction = 0.5;
  static const double raisedFraction = 0.82;
  static const Duration enterDelay = Duration(milliseconds: 320);

  @override
  State<UiMascotPeek> createState() => _UiMascotPeekState();
}

class _UiMascotPeekState extends State<UiMascotPeek> with TickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
    reverseDuration: const Duration(milliseconds: 220),
  );
  late final AnimationController _lift = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
    value: widget.raised ? 1 : 0,
  );
  late final Animation<double> _enterCurve = CurvedAnimation(
    parent: _enter,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInCubic,
  );
  late final Animation<double> _liftCurve = CurvedAnimation(parent: _lift, curve: Curves.easeOutBack);
  int _run = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.hidden) _enterLater();
  }

  /// Slides in after [UiMascotPeek.enterDelay] (lets a page transition land).
  void _enterLater() {
    final run = ++_run;
    _enter.value = 0;
    Future<void>.delayed(UiMascotPeek.enterDelay, () {
      if (mounted && run == _run && !widget.hidden) _enter.forward();
    });
  }

  @override
  void didUpdateWidget(UiMascotPeek old) {
    super.didUpdateWidget(old);
    if (widget.hidden != old.hidden) {
      if (widget.hidden) {
        _run++;
        _enter.reverse();
      } else {
        _enterLater();
      }
    } else if (widget.replay != old.replay && !widget.hidden) {
      _enterLater();
    }
    if (widget.raised != old.raised) _lift.animateTo(widget.raised ? 1 : 0);
  }

  @override
  void dispose() {
    _enter.dispose();
    _lift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = UiMascotPeek.size;
    final inset = MediaQuery.paddingOf(context).bottom;
    final width = size * UIWumbi.widthFactor;
    final art = UIWumbi(widget.mood, height: size);

    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_enter, _lift]),
          child: art,
          builder: (context, child) {
            final fraction = UiMascotPeek.peekFraction +
                (UiMascotPeek.raisedFraction - UiMascotPeek.peekFraction) * _liftCurve.value;
            final shown = size * fraction + inset;
            // Out of sight (below the edge) → peeking.
            final drop = (1 - _enterCurve.value) * (shown + 8);
            return SizedBox(
              width: width + 12,
              height: shown + 12,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Clipped at the screen edge only (props may stick out above).
                  Positioned(
                    left: 6,
                    right: 6,
                    top: 0,
                    bottom: 0,
                    child: ClipRect(
                      clipper: const _BottomEdgeClipper(),
                      child: Transform.translate(
                        offset: Offset(0, 12 + drop),
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          minHeight: 0,
                          maxHeight: double.infinity,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                  if (widget.badge)
                    PositionedDirectional(
                      end: 10,
                      top: 14 + drop,
                      child: const _Badge(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Clips only what goes below the bottom edge; ears and sparkles above the
/// box stay visible.
class _BottomEdgeClipper extends CustomClipper<Rect> {
  const _BottomEdgeClipper();

  @override
  Rect getClip(Size size) => Rect.fromLTRB(-size.width, -size.height, size.width * 2, size.height);

  @override
  bool shouldReclip(_BottomEdgeClipper oldClipper) => false;
}

/// 9 px blue dot with a ground-coloured ring.
class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: UIColorToken.blue,
        shape: BoxShape.circle,
        border: Border.all(color: colors.bgColor, width: 2),
      ),
    );
  }
}
