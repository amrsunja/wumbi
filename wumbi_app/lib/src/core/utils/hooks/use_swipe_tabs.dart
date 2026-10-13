import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../design_system/app_ui.dart';
import '../app_vibrations.dart';

/// Tab bar ⇄ [PageView] sync, same behaviour as the Dashboard money tabs:
/// swiping a page selects its tab (haptic tick), tapping a tab slides to a
/// neighbour or jumps straight to a farther one (no flash of the page in
/// between).
///
/// ```dart
/// final tabs = useSwipeTabs();
/// UiSegmentedToggle(selectedIndex: tabs.index, onChanged: tabs.onTabTap, …);
/// PageView(controller: tabs.controller, onPageChanged: tabs.onPageChanged, …);
/// ```
SwipeTabs useSwipeTabs({int initialIndex = 0}) {
  final controller = usePageController(initialPage: initialIndex);
  final index = useState(initialIndex);

  void select(int i) {
    if (i == index.value) return;
    AppVibrations.selection();
    index.value = i;
  }

  void tap(int i) {
    if (i == index.value) return;
    final from = index.value;
    select(i);
    if (!controller.hasClients) return;
    if ((i - from).abs() == 1) {
      controller.animateToPage(i, duration: UIAnim.page, curve: UIAnim.pageCurve);
    } else {
      controller.jumpToPage(i);
    }
  }

  return SwipeTabs._(index.value, controller, select, tap);
}

class SwipeTabs {
  const SwipeTabs._(this.index, this.controller, this.onPageChanged, this.onTabTap);

  /// Selected tab (flips half-way through a swipe).
  final int index;
  final PageController controller;

  /// `PageView.onPageChanged`.
  final ValueChanged<int> onPageChanged;

  /// `UiSegmentedToggle.onChanged`.
  final ValueChanged<int> onTabTap;
}
