import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';

/// A lock-screen-style notification drawn in the app: the hamster's face for
/// [mood], the app name, [title] and [body]. Shows people what they are
/// switching on (Settings → Notifications, the permission ask).
class NotificationPreviewCard extends StatelessWidget {
  const NotificationPreviewCard({
    super.key,
    required this.mood,
    required this.title,
    required this.body,
    this.time,
  });

  final WumbiMood mood;
  final String title;
  final String body;

  /// Trailing "now" / "9:00" label.
  final String? time;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 14),
      decoration: BoxDecoration(
        color: colors.secondContentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          _Face(mood: mood),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(kAppName, style: typo.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    if (time != null) Text(time!, style: typo.caption),
                  ],
                ),
                AnimatedSwitcher(
                  duration: UIAnim.fast,
                  child: Column(
                    key: ValueKey('$title|$body'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(title, style: typo.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(body, style: typo.caption.copyWith(color: colors.contentColor), maxLines: 3),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The large icon: the same art as the OS notification, in a soft disc.
class _Face extends StatelessWidget {
  const _Face({required this.mood});

  final WumbiMood mood;

  static const double size = 44;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          color: UIColorToken.blue.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: ClipOval(child: UIWumbi(mood, height: size - 4)),
      );
}
