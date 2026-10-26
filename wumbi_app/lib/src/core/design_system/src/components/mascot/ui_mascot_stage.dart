import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app_ui.dart';

/// One message of the little chat with the hamster.
@immutable
class UiMascotLine {
  const UiMascotLine({
    required this.id,
    this.text = '',
    this.fromUser = false,
    this.typing = false,
    this.actionLabel,
    this.onAction,
  });

  /// Stable per conversation: new ids animate in.
  final int id;
  final String text;

  /// The user's question (right, blue) instead of the hamster (left).
  final bool fromUser;

  /// "…" while the hamster thinks.
  final bool typing;
  final String? actionLabel;
  final VoidCallback? onAction;
}

/// A quick reply — something the user can ask.
@immutable
class UiMascotReply {
  const UiMascotReply({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;
}

/// Everything the stage shows: the hamster's current emotion (it changes
/// with what it says, never on a tap), the chat and the quick replies.
@immutable
class UiMascotStageState {
  const UiMascotStageState({required this.mood, this.lines = const [], this.replies = const []});

  final WumbiMood mood;
  final List<UiMascotLine> lines;
  final List<UiMascotReply> replies;
}

/// Controls a stage opened with [UiMascotStage.show].
class UiMascotStageHandle {
  UiMascotStageHandle._(this._entry, this._key, this._onClosed);

  final OverlayEntry _entry;
  final GlobalKey<_StageViewState> _key;
  final VoidCallback _onClosed;
  bool _closed = false;

  bool get isOpen => !_closed;

  /// Animates the hamster back into its corner, then removes the stage.
  /// [immediately]: no animation (the page is going away).
  void close({bool immediately = false}) {
    if (_closed) return;
    final state = _key.currentState;
    if (immediately || state == null || !state.mounted) {
      _finish();
    } else {
      state._dismiss().then((_) => _finish());
    }
  }

  void _finish() {
    if (_closed) return;
    _closed = true;
    _entry.remove();
    _onClosed();
  }
}

/// The hamster stepping out of its corner over everything (root overlay):
/// the page dims, it rises at the bottom-start, its messages stack above
/// it, and the user's quick replies wait on its right. Tap outside → back
/// into the corner.
abstract class UiMascotStage {
  static const double mascotSize = 150;

  static UiMascotStageHandle show(
    BuildContext context, {
    required ValueListenable<UiMascotStageState> state,
    required VoidCallback onClosed,
    String? dismissLabel,
  }) {
    final key = GlobalKey<_StageViewState>();
    late final UiMascotStageHandle handle;
    final entry = OverlayEntry(
      builder: (_) => _StageView(
        key: key,
        state: state,
        dismissLabel: dismissLabel,
        onDismiss: () => handle.close(),
      ),
    );
    handle = UiMascotStageHandle._(entry, key, onClosed);
    Overlay.of(context, rootOverlay: true).insert(entry);
    return handle;
  }
}

class _StageView extends StatefulWidget {
  const _StageView({super.key, required this.state, required this.onDismiss, this.dismissLabel});

  final ValueListenable<UiMascotStageState> state;
  final VoidCallback onDismiss;
  final String? dismissLabel;

  @override
  State<_StageView> createState() => _StageViewState();
}

class _StageViewState extends State<_StageView> with TickerProviderStateMixin {
  late final AnimationController _show = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
    reverseDuration: const Duration(milliseconds: 260),
  )..forward();
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late final Animation<double> _rise = CurvedAnimation(
    parent: _show,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInCubic,
  );
  late final Animation<double> _content = CurvedAnimation(
    parent: _show,
    curve: const Interval(0.45, 1, curve: Curves.easeOut),
    reverseCurve: const Interval(0, 0.5, curve: Curves.easeIn),
  );

  Future<void> _dismiss() => _show.reverse().orCancel.catchError((Object _) {});

  /// A tap on the hamster: a little hop, the emotion stays.
  void _hop() {
    HapticFeedback.selectionClick();
    _bounce.forward(from: 0);
  }

  @override
  void dispose() {
    _show.dispose();
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    final media = MediaQuery.of(context);
    final inset = media.padding;
    const size = UiMascotStage.mascotSize;
    const width = size * UIWumbi.widthFactor;
    final scrim = UIColorToken.neu700.withValues(alpha: colors.isDark ? 0.55 : 0.28);
    final bottom = inset.bottom + 8;

    return Material(
      type: MaterialType.transparency,
      child: ValueListenableBuilder<UiMascotStageState>(
        valueListenable: widget.state,
        builder: (context, s, _) {
          return Stack(
            children: [
              // Tap outside the hamster, its chat and the replies → back to
              // the corner.
              Positioned.fill(
                child: Semantics(
                  button: true,
                  label: widget.dismissLabel,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onDismiss,
                    child: FadeTransition(opacity: _show, child: ColoredBox(color: scrim)),
                  ),
                ),
              ),
              // The hamster.
              PositionedDirectional(
                start: 12,
                bottom: bottom,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_rise, _bounce]),
                  builder: (context, child) {
                    final b = _bounce.value;
                    final hop = -10 * (b < 0.5 ? b * 2 : (1 - b) * 2);
                    return Transform.translate(
                      offset: Offset(0, (1 - _rise.value) * (size + bottom + 24) + hop),
                      child: child,
                    );
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _hop,
                    child: UIWumbi(s.mood, height: size),
                  ),
                ),
              ),
              // Quick replies on its right.
              if (s.replies.isNotEmpty)
                PositionedDirectional(
                  start: 12 + width + 12,
                  end: 16,
                  bottom: bottom,
                  child: FadeTransition(
                    opacity: _content,
                    child: _Replies(replies: s.replies),
                  ),
                ),
              // The chat, above the hamster.
              if (s.lines.isNotEmpty)
                PositionedDirectional(
                  start: 16,
                  end: 16,
                  bottom: bottom + size + 12,
                  child: FadeTransition(
                    opacity: _content,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: media.size.height * 0.46),
                      child: _Chat(lines: s.lines),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Newest message at the bottom, older ones scroll up.
class _Chat extends StatelessWidget {
  const _Chat({required this.lines});

  final List<UiMascotLine> lines;

  @override
  Widget build(BuildContext context) {
    final reversed = lines.reversed.toList();
    return ListView.builder(
      reverse: true,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      itemCount: reversed.length,
      itemBuilder: (context, i) {
        final line = reversed[i];
        return Padding(
          key: ValueKey(line.id),
          padding: const EdgeInsets.only(top: 8),
          child: _Appear(
            child: Align(
              alignment: line.fromUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                // Taps on the chat never close the stage.
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: line.fromUser
                      ? _UserBubble(text: line.text)
                      : line.typing
                          ? const _TypingBubble()
                          : UiMascotBubble(
                              text: line.text,
                              actionLabel: line.actionLabel,
                              onAction: line.onAction,
                              tail: i == 0 ? UiBubbleTail.bottomStart : UiBubbleTail.none,
                              floating: true,
                              maxLines: 6,
                            ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Fades and slides a new message in once.
class _Appear extends StatelessWidget {
  const _Appear({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}

/// The user's question: blue, sharp bottom-end corner.
class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final typo = AppTheme.of(context).typo.inter;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 10),
      decoration: const BoxDecoration(
        color: UIColorToken.blue,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(16),
          topEnd: Radius.circular(16),
          bottomStart: Radius.circular(16),
          bottomEnd: Radius.circular(4),
        ),
      ),
      child: Text(text, style: typo.labelMedium.copyWith(color: UIColorToken.white, height: 1.35)),
    );
  }
}

/// Three dots breathing while the hamster thinks.
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.fgColor,
        border: Border.all(color: colors.dividerColor),
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(16),
          topEnd: Radius.circular(16),
          bottomStart: Radius.circular(4),
          bottomEnd: Radius.circular(16),
        ),
      ),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: [
            for (var i = 0; i < 3; i++)
              Opacity(
                opacity: 0.3 + 0.7 * (1 - ((_c.value * 3 - i) % 3).clamp(0.0, 1.0)),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: colors.secondContentColor, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Quick replies stacked at the bottom-end, next to the hamster.
class _Replies extends StatelessWidget {
  const _Replies({required this.replies});

  final List<UiMascotReply> replies;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 8,
      children: [
        for (final r in replies)
          _Appear(
            key: ValueKey(r.label),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                r.onTap();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: colors.fgColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: UIColorToken.blue.withValues(alpha: 0.35)),
                ),
                child: Text(
                  r.label,
                  textAlign: TextAlign.end,
                  style: theme.typo.inter.label.copyWith(color: UIColorToken.blue, fontSize: 13),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
