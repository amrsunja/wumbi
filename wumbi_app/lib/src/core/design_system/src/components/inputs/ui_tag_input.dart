import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app_ui.dart';

typedef TagSuggestions = Future<List<String>> Function(String query);

/// Inline tag editor: type words → chips. Tokenises on space, comma or Enter;
/// leading `#` optional; backspace on empty input removes the last chip.
/// Autocomplete (after 1 char) shows up to 5 suggestions under the field.
class UiTagInput extends StatefulWidget {
  const UiTagInput({
    super.key,
    required this.tags,
    required this.onChanged,
    this.suggestions,
    this.hintText = '#tags',
    this.maxTags = 10,
    this.maxTagLength = 30,
    this.controller,
    this.focusNode,
    this.onLimitReached,
    this.onSubmitted,
  });

  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final TagSuggestions? suggestions;
  final String hintText;
  final int maxTags;
  final int maxTagLength;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onLimitReached;

  /// Keyboard "done": the pending word is committed, then this fires (the
  /// caller usually drops focus). Without it the field keeps focus.
  final VoidCallback? onSubmitted;

  /// `Food`, `#food`, `food ` → `food`.
  static String normalize(String raw) {
    var s = raw.trim();
    while (s.startsWith('#')) {
      s = s.substring(1);
    }
    return s.trim().toLowerCase();
  }

  static String display(String raw) {
    var s = raw.trim();
    while (s.startsWith('#')) {
      s = s.substring(1);
    }
    return s.trim();
  }

  @override
  State<UiTagInput> createState() => _UiTagInputState();
}

class _UiTagInputState extends State<UiTagInput> {
  late final TextEditingController _controller = widget.controller ?? TextEditingController();
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  List<String> _suggestions = const [];
  Timer? _debounce;
  int _querySeq = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _commitCurrent();
      setState(() => _suggestions = const []);
    }
  }

  void _onTextChanged() {
    final text = _controller.text;
    if (text.contains(' ') || text.contains(',')) {
      final parts = text.split(RegExp(r'[ ,]+'));
      final last = text.endsWith(' ') || text.endsWith(',') ? '' : parts.removeLast();
      var tags = List<String>.from(widget.tags);
      for (final part in parts) {
        tags = _add(tags, part);
      }
      _controller.value = TextEditingValue(
        text: last,
        selection: TextSelection.collapsed(offset: last.length),
      );
      widget.onChanged(tags);
      return;
    }
    _querySuggestions(UiTagInput.normalize(text));
  }

  void _querySuggestions(String query) {
    _debounce?.cancel();
    if (widget.suggestions == null || query.isEmpty) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = const []);
      return;
    }
    final seq = ++_querySeq;
    _debounce = Timer(const Duration(milliseconds: 120), () async {
      final result = await widget.suggestions!(query);
      if (!mounted || seq != _querySeq) return;
      final existing = widget.tags.map(UiTagInput.normalize).toSet();
      setState(() => _suggestions = result
          .where((s) => !existing.contains(UiTagInput.normalize(s)))
          .take(5)
          .toList());
    });
  }

  List<String> _add(List<String> tags, String raw) {
    var display = UiTagInput.display(raw).replaceAll(RegExp(r'\s+'), '');
    if (display.isEmpty) return tags;
    if (display.length > widget.maxTagLength) display = display.substring(0, widget.maxTagLength);
    final normalized = display.toLowerCase();
    if (tags.any((t) => UiTagInput.normalize(t) == normalized)) return tags;
    if (tags.length >= widget.maxTags) {
      widget.onLimitReached?.call();
      return tags;
    }
    return [...tags, display];
  }

  void _commitCurrent() {
    final text = _controller.text;
    if (text.trim().isEmpty) {
      if (text.isNotEmpty) _controller.clear();
      return;
    }
    final tags = _add(widget.tags, text);
    _controller.clear();
    if (tags != widget.tags) widget.onChanged(tags);
  }

  void _remove(int index) {
    final tags = List<String>.from(widget.tags)..removeAt(index);
    widget.onChanged(tags);
  }

  void _pickSuggestion(String s) {
    final tags = _add(widget.tags, s);
    _controller.clear();
    setState(() => _suggestions = const []);
    if (tags != widget.tags) widget.onChanged(tags);
    _focusNode.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controller.text.isEmpty &&
        widget.tags.isNotEmpty) {
      _remove(widget.tags.length - 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    final hasTags = widget.tags.isNotEmpty;

    final field = Focus(
      onKeyEvent: _onKey,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textAlign: hasTags ? TextAlign.start : TextAlign.center,
        textInputAction: TextInputAction.done,
        textCapitalization: TextCapitalization.none,
        autocorrect: false,
        cursorColor: UIColorToken.blue,
        inputFormatters: [LengthLimitingTextInputFormatter(widget.maxTagLength + 1)],
        onSubmitted: (_) {
          _commitCurrent();
          if (widget.onSubmitted != null) {
            widget.onSubmitted!();
          } else {
            _focusNode.requestFocus();
          }
        },
        style: AppTheme.of(context).typo.inter.labelMedium,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: hasTags ? '' : widget.hintText,
          hintStyle: AppTheme.of(context).typo.inter.subtitle,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        UITap(
          onTap: _focusNode.requestFocus,
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < widget.tags.length; i++)
                _TagChip(label: widget.tags[i], onRemove: () => _remove(i)),
              SizedBox(width: hasTags ? 120 : 200, child: field),
            ],
          ),
        ),
        if (_suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in _suggestions)
                  UITap(
                    onTap: () => _pickSuggestion(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.dividerColor),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '#$s',
                        style: AppTheme.of(context).typo.inter.caption,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
      decoration: BoxDecoration(
        color: UIColorToken.blue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Text(
            '#$label',
            style: AppTheme.of(context).typo.inter.semiBold.copyWith(fontSize: 12, color: UIColorToken.blue),
          ),
          UIIcon(UIIconToken.icons.general.xClose, size: 14, color: UIColorToken.blue, onTap: onRemove),
        ],
      ),
    );
  }
}
