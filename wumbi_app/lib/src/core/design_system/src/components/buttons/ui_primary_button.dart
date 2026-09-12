import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Full-width blue pill button (onboarding "Continue", sheets "Confirm").
class UiPrimaryButton extends StatelessWidget {
  const UiPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.enabled = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading && onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: UITap(
        onTap: active ? onTap : null,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: UIColorToken.blue,
            borderRadius: BorderRadius.circular(16),
            boxShadow: active ? UIShadowToken.buttonBlueShadow : null,
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: UIColorToken.white),
                )
              : Text(
                  label,
                  style: AppTheme.of(context).typo.inter.rowTitle.copyWith(color: UIColorToken.white),
                ),
        ),
      ),
    );
  }
}
