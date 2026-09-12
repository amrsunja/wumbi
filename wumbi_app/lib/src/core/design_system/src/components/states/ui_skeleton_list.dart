import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app_ui.dart';

/// Shimmer placeholder rows for the first load.
class UiSkeletonList extends StatelessWidget {
  const UiSkeletonList({super.key, this.rows = 4, this.rowHeight = 44, this.spacing = 24});

  final int rows;
  final double rowHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    final base = colors.secondContentColor.withValues(alpha: 0.25);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: colors.secondContentColor.withValues(alpha: 0.08),
      child: Column(
        spacing: spacing,
        children: [
          for (var i = 0; i < rows; i++)
            Row(
              spacing: 18,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: base, shape: BoxShape.circle)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Container(width: 120, height: 14, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(7))),
                      Container(width: 48, height: 10, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(5))),
                    ],
                  ),
                ),
                Container(width: 90, height: 16, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(8))),
              ],
            ),
        ],
      ),
    );
  }
}
