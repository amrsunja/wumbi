import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../utils/app_vibrations.dart';
import '../../../app_ui.dart';

typedef TagSuggestions = Future<List<String>> Function(String query);

/// Where [UiTagInput] shows its autocomplete.
enum UiTagSuggestionsStyle {
  /// Up to 5 pills under the field, after the first typed character.
  inline,

  /// A horizontal strip docked on top of the system keyboard while the field
  /// has focus: the most used tags right away, filtered as the user types,
  /// plus a "+ #new" pill when the typed word is not an existing tag.
  keyboardBar,
}

/// Inline tag editor: type words → chips. Tokenises on space, comma or Enter;
/// leading `#` optional; backspace on empty input removes the last chip.
class UiTagInput extends StatefulWidget {
  const UiTagInput({
    super.key,
    required this.tags,
    required this.onChanged,
    this.suggestions,
    this.suggestionsStyle = UiTagSuggestionsStyle.inline,
    this.hintText = '#tags',
    this.maxTags = 10,
    this.maxTagLength = 48,
    this.controller,
    this.focusNode,
    this.onLimitReached,
    this.onSubmitted,
  });

  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final TagSuggestions? suggestions;
  final UiTagSuggestionsStyle suggestionsStyle;
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
  final OverlayPortalController _barController = OverlayPortalController();
  List<String> _suggestions = const [];
  Timer? _debounce;
  int _querySeq = 0;

  bool get _barMode => widget.suggestionsStyle == UiTagSuggestionsStyle.keyboardBar;
  int get _maxSuggestions => _barMode ? 20 : 5;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant UiTagInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A chip was added / removed: the bar must hide picked tags and bring
    // removed ones back.
    if (_barMode && _focusNode.hasFocus && !listEquals(oldWidget.tags, widget.tags)) {
      _querySuggestions(UiTagInput.normalize(_controller.text));
    }
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
    if (!mounted) return;
    if (_focusNode.hasFocus) {
      if (_barMode) {
        _barController.show();
        _querySuggestions(UiTagInput.normalize(_controller.text));
      }
      return;
    }
    if (_barController.isShowing) _barController.hide();
    _commitCurrent();
    setState(() => _suggestions = const []);
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
    // Rebuild for the "+ #new" pill even before the query resolves.
    if (_barMode) setState(() {});
    _querySuggestions(UiTagInput.normalize(text));
  }

  void _querySuggestions(String query) {
    _debounce?.cancel();
    // Inline: nothing until the first character. Bar: top tags right away.
    if (widget.suggestions == null || (query.isEmpty && !_barMode)) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = const []);
      return;
    }
    final seq = ++_querySeq;
    _debounce = Timer(Duration(milliseconds: query.isEmpty ? 0 : 120), () async {
      final result = await widget.suggestions!(query);
      if (!mounted || seq != _querySeq) return;
      final existing = widget.tags.map(UiTagInput.normalize).toSet();
      setState(() => _suggestions = result
          .where((s) => !existing.contains(UiTagInput.normalize(s)))
          .take(_maxSuggestions)
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
    setState(() => _suggestions = _suggestions.where((x) => x != s).toList());
    if (tags != widget.tags) {
      AppVibrations.selection();
      widget.onChanged(tags);
    }
    _focusNode.requestFocus();
  }

  void _createFromQuery() {
    AppVibrations.selection();
    _commitCurrent();
    _focusNode.requestFocus();
  }

  /// "+ #word" when the typed word is neither a suggestion nor already added.
  String? get _newTagLabel {
    final display = UiTagInput.display(_controller.text).replaceAll(RegExp(r'\s+'), '');
    if (display.isEmpty) return null;
    final normalized = display.toLowerCase();
    if (_suggestions.any((s) => UiTagInput.normalize(s) == normalized)) return null;
    if (widget.tags.any((t) => UiTagInput.normalize(t) == normalized)) return null;
    return display.length > widget.maxTagLength ? display.substring(0, widget.maxTagLength) : display;
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
        enableSuggestions: false,
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

    final body = Column(
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
        if (!_barMode && _suggestions.isNotEmpty)
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

    if (!_barMode) return body;
    return OverlayPortal(
      controller: _barController,
      overlayChildBuilder: (context) => _KeyboardDock(
        // Same tap group as the field: tapping a pill does not count as a tap
        // outside, so focus (and the keyboard) stay put.
        child: TextFieldTapRegion(
          child: _TagKeyboardBar(
            suggestions: _suggestions,
            newTag: _newTagLabel,
            onPick: _pickSuggestion,
            onCreate: _createFromQuery,
          ),
        ),
      ),
      child: body,
    );
  }
}

/// Pins its child to the top edge of the system keyboard. Reads the insets
/// from the [View] (not the nearest [MediaQuery]) so it works whether or not
/// the host `Scaffold` resizes for the keyboard; rebuilds on every metrics
/// change, i.e. every frame of the keyboard animation.
class _KeyboardDock extends StatefulWidget {
  const _KeyboardDock({required this.child});

  final Widget child;

  @override
  State<_KeyboardDock> createState() => _KeyboardDockState();
}

class _KeyboardDockState extends State<_KeyboardDock> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final view = View.of(context);
    final inset = view.viewInsets.bottom / view.devicePixelRatio;
    // No soft keyboard (hardware keyboard / simulator): sit above the home
    // indicator instead.
    final bottom = inset > 0 ? inset : view.padding.bottom / view.devicePixelRatio;
    return Positioned(left: 0, right: 0, bottom: bottom, child: widget.child);
  }
}

/// The strip itself: `+ #new` first (when typing an unknown word), then the
/// user's existing tags, most used first.
class _TagKeyboardBar extends StatelessWidget {
  const _TagKeyboardBar({
    required this.suggestions,
    required this.newTag,
    required this.onPick,
    required this.onCreate,
  });

  final List<String> suggestions;
  final String? newTag;
  final ValueChanged<String> onPick;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final hasItems = suggestions.isNotEmpty || newTag != null;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: !hasItems
          ? const SizedBox(width: double.infinity, height: 0)
          : Container(
              key: const ValueKey('tag-bar'),
              height: 46,
              decoration: BoxDecoration(
                color: colors.bgColor,
                border: Border(top: BorderSide(color: colors.dividerColor)),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  if (newTag != null)
                    _BarPill(label: '+ #$newTag', accent: true, onTap: onCreate),
                  for (final s in suggestions) _BarPill(label: '#$s', onTap: () => onPick(s)),
                ],
              ),
            ),
    );
  }
}

class _BarPill extends StatelessWidget {
  const _BarPill({required this.label, required this.onTap, this.accent = false});

  final String label;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: UITap(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: accent ? UIColorToken.blue.withValues(alpha: 0.12) : colors.fgColor,
            border: Border.all(color: accent ? Colors.transparent : colors.dividerColor),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: theme.typo.inter.chip.copyWith(color: accent ? UIColorToken.blue : colors.contentColor),
          ),
        ),
      ),
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
