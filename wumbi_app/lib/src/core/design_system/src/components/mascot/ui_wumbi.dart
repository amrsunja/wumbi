import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wumbi/gen/assets.gen.dart';

/// Wumbi the wombat — one vector illustration per mood.
///
/// Peek moods are cropped flush on the edge they peek from, so they can be
/// positioned at `left: 0` / `right: 0` without a visible cut.
enum WumbiMood {
  idle,
  wave,
  celebrate,
  confused,
  searching,
  sleep,
  pouchOpen,
  nervous,
  panic,
  peekLeft,
  peekRight;

  String get asset => switch (this) {
    WumbiMood.idle => Assets.images.wumbiIdle,
    WumbiMood.wave => Assets.images.wumbiWave,
    WumbiMood.celebrate => Assets.images.wumbiCelebrate,
    WumbiMood.confused => Assets.images.wumbiConfused,
    WumbiMood.searching => Assets.images.wumbiSearching,
    WumbiMood.sleep => Assets.images.wumbiSleep,
    WumbiMood.pouchOpen => Assets.images.wumbiPouchOpen,
    WumbiMood.nervous => Assets.images.wumbiNervous,
    WumbiMood.panic => Assets.images.wumbiPanic,
    WumbiMood.peekLeft => Assets.images.wumbiPeekLeft,
    WumbiMood.peekRight => Assets.images.wumbiPeekRight,
  };

  /// Parses every mood into flutter_svg's cache so the first paint of a
  /// mascot (empty states, peek animations) never shows an empty frame.
  static Future<void> precacheAll() => Future.wait(
    values.map((mood) {
      final loader = SvgAssetLoader(mood.asset);
      return svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
    }),
  );
}

/// Static mascot illustration. Wrap with `flutter_animate` at the call site
/// for entrance / idle motion.
class UIWumbi extends StatelessWidget {
  const UIWumbi(this.mood, {super.key, this.height = 130});

  final WumbiMood mood;
  final double height;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    mood.asset,
    height: height,
    fit: BoxFit.contain,
    excludeFromSemantics: true,
  );
}
