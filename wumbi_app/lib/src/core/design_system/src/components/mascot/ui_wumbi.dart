import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wumbi/gen/assets.gen.dart';

/// Wumbi the hamster — one vector illustration per emotion (spec
/// HAMSTER_COMPANION §2). Static SVGs; motion is Flutter-only.
///
/// Every file keeps the generator's pixel scale, so the body is drawn at the
/// same size when the art is scaled by its viewBox height against [_refHeight]
/// (idle). Props (confetti, the wheel) may stick out of the box; the feet
/// always sit on its bottom edge, so swapping emotions never makes the
/// hamster "jump".
enum WumbiMood {
  idle(852, 1150),
  wave(980, 1150),
  happy(932, 1150),

  /// Reserve ≥ goal: the pouch stuffed with seeds (s1#1).
  reserveFull(958, 1162),

  /// Reaction to a big income: cheeks stuffed (s2#6).
  cheeksStuffed(936, 1138),
  celebrate(1214, 1240),
  victory(1098, 1192),
  proud(1062, 1188),
  thumbsUp(844, 1150),
  calm(860, 1134),

  /// Putting seeds away: a saving wallet grows.
  saving(854, 1160),
  catching(842, 1154),

  /// An expense was recorded — neutral, never sad.
  tossing(1194, 1146),
  handing(1028, 1138),
  sorting(1138, 1168),
  counting(1068, 1104),
  calendar(848, 1146),

  /// Subscriptions spinning every month.
  wheel(1186, 1140),
  thinking(1044, 1170),

  /// Offers a seed: advice / call to action.
  kindly(996, 1144),
  searching(974, 1138),
  confused(962, 1138),
  shrug(1168, 1132),
  nervous(824, 1134),
  stop(956, 1140),
  alert(1170, 1142),
  sigh(1098, 1144),
  pouchOpen(832, 1140),
  dusting(1030, 1144),
  love(1076, 1134),
  sleep(1068, 1090),

  /// Psst — a secret saving trick (and a future privacy mode).
  hush(828, 1144),

  /// Missed the user: an evening visit after a whole day away.
  sad(808, 1132),

  /// "I've been waiting for you all day!" — opens the evening story.
  impatient(1078, 1142);

  const WumbiMood(this.viewBoxWidth, this.viewBoxHeight);

  final double viewBoxWidth;
  final double viewBoxHeight;

  String get asset => switch (this) {
    WumbiMood.idle => Assets.mascot.wumbiIdle,
    WumbiMood.wave => Assets.mascot.wumbiWave,
    WumbiMood.happy => Assets.mascot.wumbiHappy,
    WumbiMood.reserveFull => Assets.mascot.wumbiHappyStash,
    WumbiMood.cheeksStuffed => Assets.mascot.wumbiCheeksFull,
    WumbiMood.celebrate => Assets.mascot.wumbiCelebrate,
    WumbiMood.victory => Assets.mascot.wumbiVictory,
    WumbiMood.proud => Assets.mascot.wumbiProud,
    WumbiMood.thumbsUp => Assets.mascot.wumbiThumbsUp,
    WumbiMood.calm => Assets.mascot.wumbiCalm,
    WumbiMood.saving => Assets.mascot.wumbiSavingSeeds,
    WumbiMood.catching => Assets.mascot.wumbiCatching,
    WumbiMood.tossing => Assets.mascot.wumbiTossing,
    WumbiMood.handing => Assets.mascot.wumbiHanding,
    WumbiMood.sorting => Assets.mascot.wumbiSorting,
    WumbiMood.counting => Assets.mascot.wumbiCounting,
    WumbiMood.calendar => Assets.mascot.wumbiCalendar,
    WumbiMood.wheel => Assets.mascot.wumbiHamsterWheel,
    WumbiMood.thinking => Assets.mascot.wumbiThinking,
    WumbiMood.kindly => Assets.mascot.wumbiKindly,
    WumbiMood.searching => Assets.mascot.wumbiSearching,
    WumbiMood.confused => Assets.mascot.wumbiConfused,
    WumbiMood.shrug => Assets.mascot.wumbiShrug,
    WumbiMood.nervous => Assets.mascot.wumbiNervous,
    WumbiMood.stop => Assets.mascot.wumbiStop,
    WumbiMood.alert => Assets.mascot.wumbiAlert,
    WumbiMood.sigh => Assets.mascot.wumbiSigh,
    WumbiMood.pouchOpen => Assets.mascot.wumbiPouchOpen,
    WumbiMood.dusting => Assets.mascot.wumbiDusting,
    WumbiMood.love => Assets.mascot.wumbiLove,
    WumbiMood.sleep => Assets.mascot.wumbiSleep,
    WumbiMood.hush => Assets.mascot.wumbiSecret,
    WumbiMood.sad => Assets.mascot.wumbiSad,
    WumbiMood.impatient => Assets.mascot.wumbiImpatient,
  };

  /// Parses every mood into flutter_svg's cache so the first paint of a
  /// mascot (and every emotion swap) never shows an empty frame.
  static Future<void> precacheAll() => Future.wait(
    values.map((mood) {
      final loader = SvgAssetLoader(mood.asset);
      return svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
    }),
  );
}

/// Mascot illustration in a fixed [height] × `height · 0.8` box, feet on the
/// bottom edge. A mood change cross-fades with a light pop (180 ms, scale
/// 0.94 → 1); pass `animated: false` for a hard swap.
class UIWumbi extends StatelessWidget {
  const UIWumbi(this.mood, {super.key, this.height = 130, this.animated = true});

  final WumbiMood mood;
  final double height;
  final bool animated;

  /// viewBox height of the idle pose: the body's reference scale.
  static const double _refHeight = 1150;

  /// Box width relative to [height] (the body; props may overflow).
  static const double widthFactor = 0.8;

  static const Duration swapDuration = Duration(milliseconds: 180);

  Widget _art(WumbiMood m) => OverflowBox(
    key: ValueKey(m),
    alignment: Alignment.bottomCenter,
    minWidth: 0,
    minHeight: 0,
    maxWidth: double.infinity,
    maxHeight: double.infinity,
    child: SvgPicture.asset(
      m.asset,
      width: height * m.viewBoxWidth / _refHeight,
      height: height * m.viewBoxHeight / _refHeight,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * widthFactor,
      height: height,
      child: !animated
          ? _art(mood)
          : AnimatedSwitcher(
              duration: swapDuration,
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.94, end: 1).animate(animation),
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              ),
              child: _art(mood),
            ),
    );
  }
}
