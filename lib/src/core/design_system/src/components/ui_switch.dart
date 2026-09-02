import 'package:flutter/cupertino.dart';

import '../../app_ui.dart';

class UISwitch extends StatelessWidget {
  const UISwitch({super.key, required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return CupertinoSwitch(
      value: value,
      activeTrackColor: UIColorToken.blue,
      inactiveTrackColor: colors.disabledContentColor,
      onChanged: onChanged,
    );
  }
}
