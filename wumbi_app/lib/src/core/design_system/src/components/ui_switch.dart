import 'package:flutter/cupertino.dart';

import '../../app_ui.dart';

/// Compact iOS switch: the stock `CupertinoSwitch` scaled down to [height]
/// (default 24 px instead of 31), taps and drags included.
class UISwitch extends StatelessWidget {
  const UISwitch({super.key, required this.value, this.onChanged, this.height = 24});

  final bool value;
  final ValueChanged<bool>? onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return SizedBox(
      height: height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: CupertinoSwitch(
          value: value,
          activeTrackColor: UIColorToken.blue,
          inactiveTrackColor: colors.disabledContentColor,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
