import 'package:flutter/material.dart';

import '../context.dart';
import '../tokens.dart';

/// A text field with its label above (not floating inside), so the label
/// stays readable while typing and at large text sizes.
class KanzTextField extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    // Merging the visible label with the field makes it the field's
    // accessible name.
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: t.labelMedium),
          const SizedBox(height: KanzSpace.s8),
          TextField(
            controller: controller,
            enabled: enabled,
            autofocus: autofocus,
            maxLines: maxLines,
            minLines: minLines,
            maxLength: maxLength,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: t.bodyLarge,
            decoration: InputDecoration(
              semanticCounterText: '',
              hintText: hint,
              helperText: helper,
              errorText: error,
              hintMaxLines: 3,
              helperMaxLines: 3,
              errorMaxLines: 3,
              prefixIcon: prefixIcon == null
                  ? null
                  : Icon(prefixIcon, size: 20),
              suffixIcon: suffix,
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
    // The hairline starts at the gutter so rows read as one list.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        Padding(
          padding: const EdgeInsetsDirectional.only(start: KanzSpace.gutter),
          child: Divider(height: 1, color: c.line),
        ),
      ],
    );
  }
}
