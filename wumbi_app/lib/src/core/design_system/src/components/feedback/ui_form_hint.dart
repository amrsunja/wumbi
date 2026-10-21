import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// One-line (max 2) muted caption with a leading icon, shown under the chips
/// row of the entry forms (Transaction / Budget / Debt). A null [text]
/// collapses it; changes animate so the numpad below never jumps.
class UiFormHint extends StatelessWidget {
  const UiFormHint({super.key, required this.text, required this.icon, this.color = UIColorToken.casper});

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
                // Icon inline with the text: it sits 4 px before the first
                // word and on the first line, however the text wraps.
                child: Text.rich(
                  TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 4),
                          child: UIIcon(icon, size: 12, color: color),
                        ),
                      ),
                      TextSpan(text: t),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTheme.of(context).typo.inter.caption.copyWith(color: color),
                ),
              ),
      ),
    );
  }
}
