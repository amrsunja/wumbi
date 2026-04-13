import 'package:fiin/src/src/core/design_system/app_ui.dart';
import 'package:flutter/material.dart';


class UIInputField extends StatelessWidget {
  const UIInputField({
    super.key,
    this.controller,
    this.hintText,
    this.label
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return TextField(
      controller: controller,
      keyboardType: .number,
      cursorColor: UIColorToken.blue,
      style: UITextStyleToken.interMedium.copyWith(
        color: theme.colors.contentColor,
      ),
      decoration: InputDecoration(
        label: Text(
          label ?? '',
        ),
        hintText: hintText,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: UIColorToken.blue),
          borderRadius: .circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: .circular(12),
        )
      ),
      
    );
  }
}
