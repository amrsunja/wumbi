import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Big amount being typed. When a character is appended it pops in with an
/// elastic scale (0.3 → 1, `elasticOut`, 520 ms); edits elsewhere (backspace,
/// clear, prefill) render instantly.
class UiAmountText extends StatefulWidget {
  const UiAmountText({super.key, required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  State<UiAmountText> createState() => _UiAmountTextState();
}

class _UiAmountTextState extends State<UiAmountText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    // Eager: a `late` controller first touched in dispose() breaks Hero shuttles.
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 520), value: 1);
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _controller, curve: const Interval(0, 0.35));
  }

  @override
  void didUpdateWidget(covariant UiAmountText old) {
    super.didUpdateWidget(old);
    final appended = widget.text.length == old.text.length + 1 && widget.text.startsWith(old.text);
    if (appended) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    if (text.isEmpty) return Text('', style: widget.style);

    final head = text.substring(0, text.length - 1);
    final last = text.substring(text.length - 1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (head.isNotEmpty) Text(head, style: widget.style),
        AnimatedBuilder(
          animation: _controller,
          builder: (_, child) => Opacity(
            opacity: _fade.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.3 + 0.7 * _scale.value,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
          child: Text(last, style: widget.style),
        ),
      ],
    );
  }
}
