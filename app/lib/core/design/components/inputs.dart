import 'package:flutter/material.dart';

import '../context.dart';
import '../tokens.dart';

/// A text field with its label above (not floating inside), so the label
/// stays readable while typing and at large text sizes. The helper or error
/// line and the character count sit under the field on the same gutter as
/// the label, not indented to the text inside the box.
///
/// URLs, numbers and codes read left to right in Arabic too: pass
/// `textDirection: TextDirection.ltr` (and, if needed, `textAlign`) for
/// them; the hint follows the same direction.
class KanzTextField extends StatefulWidget {
  const KanzTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.error,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.maxLength,
    this.textDirection,
    this.textAlign,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final String? error;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;
  final int? maxLength;

  /// Direction of the text being typed; null follows the UI.
  final TextDirection? textDirection;

  /// Alignment of the text being typed; null starts it at the reading
  /// start of [textDirection].
  final TextAlign? textAlign;
  final bool autocorrect;
  final bool enableSuggestions;

  @override
  State<KanzTextField> createState() => _KanzTextFieldState();
}

class _KanzTextFieldState extends State<KanzTextField> {
  TextEditingController? _own;

  TextEditingController get _controller =>
      widget.controller ?? (_own ??= TextEditingController());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    final error = widget.error;
    final note = error ?? widget.helper;
    final maxLength = widget.maxLength;
    // Merging the visible label with the field makes it the field's
    // accessible name.
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.label, style: t.labelMedium),
          const SizedBox(height: KanzSpace.s8),
          TextField(
            controller: _controller,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: maxLength,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            textDirection: widget.textDirection,
            textAlign: widget.textAlign ?? TextAlign.start,
            autocorrect: widget.autocorrect,
            enableSuggestions: widget.enableSuggestions,
            style: t.bodyLarge,
            decoration: InputDecoration(
              // The count is drawn under the field, beside the helper.
              counterText: '',
              semanticCounterText: '',
              hintText: widget.hint,
              hintTextDirection: widget.textDirection,
              hintMaxLines: 3,
              // An empty error widget keeps the error border; the message
              // itself is drawn under the field on the gutter.
              error: error == null ? null : const SizedBox.shrink(),
              prefixIcon: widget.prefixIcon == null
                  ? null
                  : Icon(widget.prefixIcon, size: 20),
              suffixIcon: widget.suffix,
            ),
          ),
          if (note != null || maxLength != null)
            Padding(
              padding: const EdgeInsets.only(top: KanzSpace.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: note == null
                        ? const SizedBox.shrink()
                        : Text(
                            note,
                            style: error == null
                                ? t.bodySmall
                                : t.bodySmall?.copyWith(color: c.danger),
                          ),
                  ),
                  if (maxLength != null) ...[
                    const SizedBox(width: KanzSpace.s12),
                    ExcludeSemantics(
                      child: ListenableBuilder(
                        listenable: _controller,
                        builder: (context, _) => Text(
                          '${_controller.text.characters.length}/$maxLength',
                          style: t.bodySmall,
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A settings row with a switch; the whole row toggles.
class KanzSwitchTile extends StatelessWidget {
  const KanzSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.divider = false,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    final tile = MergeSemantics(
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsetsDirectional.fromSTEB(
            KanzSpace.gutter,
            KanzSpace.s12,
            KanzSpace.s16,
            KanzSpace.s12,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.bodyLarge),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: t.bodySmall),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: KanzSpace.s12),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
    if (!divider) return tile;
    // The hairline sits inside the gutters on both sides, like every other
    // rule in Kanz, so rows read as one list.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        Padding(
          padding: KanzSpace.page,
          child: Divider(height: 1, color: c.line),
        ),
      ],
    );
  }
}
