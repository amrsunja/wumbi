import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app_ui.dart';

/// 52 px blue circle with a white `+`, optional scale-in on page enter (200 ms).
/// With [label] it becomes an extended pill: `+ New tag`.
///
/// [heroTag] is *armed on tap only*: the button becomes a [Hero] right before
/// [onTap] pushes the next route (so it flies into that page) and is disarmed
/// once the pushed route has been popped. Between taps it is a plain widget,
/// so two pages that both show a FAB (dashboard → wallet details) never fly
/// their buttons into each other.
class UiFab extends StatefulWidget {
  const UiFab({super.key, required this.onTap, this.animateIn = true, this.heroTag, this.label});

  /// Return the `push` future so the Hero stays armed until the route pops.
  final FutureOr<void> Function() onTap;
  final bool animateIn;
  final Object? heroTag;

  /// Text after the `+` (extended FAB); null = round icon-only button.
  final String? label;

  @override
  State<UiFab> createState() => _UiFabState();
}

class _UiFabState extends State<UiFab> {
  bool _armed = false;

  Future<void> _handleTap() async {
    if (widget.heroTag == null) {
      await widget.onTap();
      return;
    }
    if (mounted) setState(() => _armed = true);
    try {
      await widget.onTap();
    } finally {
      // The pop flight is collected one frame after the pop; keep the Hero
      // alive through the return transition, then drop it.
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (mounted) setState(() => _armed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget button = UITap(
      onTap: _handleTap,
      child: widget.label == null
          ? Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: UIColorToken.blue,
                shape: BoxShape.circle,
                boxShadow: UIShadowToken.buttonBlueShadow,
              ),
              child: Center(
                child: UIIcon(UIIconToken.icons.general.plus, color: UIColorToken.white, size: 26),
              ),
            )
          : Container(
              height: 52,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 22, 0),
              decoration: BoxDecoration(
                color: UIColorToken.blue,
                borderRadius: BorderRadius.circular(26),
                boxShadow: UIShadowToken.buttonBlueShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  UIIcon(UIIconToken.icons.general.plus, color: UIColorToken.white, size: 22),
                  Text(
                    widget.label!,
                    style: AppTheme.of(context).typo.inter.rowTitle.copyWith(color: UIColorToken.white),
                  ),
                ],
              ),
            ),
    );
    final tag = widget.heroTag;
    if (tag != null && _armed) {
      button = UiHero(tag: tag, child: button);
    }
    if (!widget.animateIn) return button;
    return button.animate().scale(
          duration: 200.ms,
          curve: Curves.easeOutBack,
          begin: const Offset(0.6, 0.6),
          end: const Offset(1, 1),
        );
  }
}
