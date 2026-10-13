import 'package:flutter/painting.dart';

import '../data/tag_normalizer.dart';

/// Splash palette for tags — vivid, flat swatches. Deliberately wider than
/// `UIColorToken` so neighbouring bubbles never read as the same colour, and
/// deliberately not `WalletColor` (that rainbow repeats too soon).
///
/// Lives outside the graph widget so the tag map and the progress pie give
/// the same tag the same colour.
abstract class TagPalette {
  static const List<Color> colors = [
    Color(0xffFF5E5B), // coral
    Color(0xffFF9F1C), // tangerine
    Color(0xffFFD166), // saffron
    Color(0xffB8E062), // sprout
    Color(0xff3DD68C), // mint
    Color(0xff00C2A8), // teal
    Color(0xff21B4E8), // sky
    Color(0xff4C6FFF), // cobalt
    Color(0xff7B61FF), // indigo
    Color(0xffB15CFF), // amethyst
    Color(0xffE45CC4), // orchid
    Color(0xffFF6FA5), // rose
    Color(0xffF7735A), // salmon
    Color(0xffD9A441), // ochre
    Color(0xff5FB37A), // moss
    Color(0xff2E8FA6), // lagoon
    Color(0xff8C7CFF), // periwinkle
    Color(0xffFF8A3D), // amber splash
  ];

  /// Stable, fully opaque splash colour from the tag's normalized name
  /// (djb2 — same input must always give the same swatch).
  static Color of(String normalizedName) {
    var h = 5381;
    for (final c in normalizedName.codeUnits) {
      h = ((h << 5) + h + c) & 0x7fffffff;
    }
    return colors[h % colors.length];
  }

  /// Family colour for nested tags: every tag inside `food` shares `food`'s
  /// hue, a notch lighter per level, so a family reads as one group in the
  /// list, the map and the progress pie.
  static Color forTag(String normalizedName) {
    final parts = TagNormalizer.segments(normalizedName);
    final base = of(parts.isEmpty ? normalizedName : parts.first);
    return shade(base, parts.length <= 1 ? 0 : parts.length - 1);
  }

  /// [base] lightened by [depth] levels (0 = unchanged).
  static Color shade(Color base, int depth) {
    if (depth <= 0) return base;
    final hsl = HSLColor.fromColor(base);
    final lightness = (hsl.lightness + 0.09 * depth).clamp(0.0, 0.82).toDouble();
    final saturation = (hsl.saturation - 0.06 * depth).clamp(0.25, 1.0).toDouble();
    return hsl.withLightness(lightness).withSaturation(saturation).toColor();
  }
}
