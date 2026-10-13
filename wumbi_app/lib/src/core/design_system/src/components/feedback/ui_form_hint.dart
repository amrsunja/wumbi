import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// One-line (max 2) blue caption with a leading icon, shown under the chips
/// row of the entry forms (Transaction / Budget / Debt). A null [text]
/// collapses it; changes animate so the numpad below never jumps.
class UiFormHint extends StatelessWidget {
  const UiFormHint({super.key, required this.text, required this.icon, this.color = UIColorToken.blue});

  final String? text;
  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = text;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: t == null
            ? const SizedBox(width: double.infinity, height: 0)
            : Padding(
                key: ValueKey('hint-$t'),
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    UIIcon(icon, size: 12, color: color),
                    Flexible(
                      child: Text(
                        t,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTheme.of(context).typo.inter.caption.copyWith(color: color),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
