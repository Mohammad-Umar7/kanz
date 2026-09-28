import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design.dart';
import '../../core/state/connectivity_providers.dart';
import '../../core/state/scan_session.dart';
import '../../l10n/l10n.dart';

/// The text path of the scan screen: describe the item in a sentence, or
/// start from one of a few examples, then identify its materials.
class DescribeView extends ConsumerStatefulWidget {
  const DescribeView({
    super.key,
    required this.onSubmit,
    required this.onClose,
    this.backToCamera = false,
    this.initialText,
  });

  final ValueChanged<String> onSubmit;
  final VoidCallback onClose;

  /// Opened from the viewfinder: the leading button goes back to it.
  final bool backToCamera;
  final String? initialText;

  @override
  ConsumerState<DescribeView> createState() => _DescribeViewState();
}

class _DescribeViewState extends ConsumerState<DescribeView> {
  late final TextEditingController _text = TextEditingController(
    text: widget.initialText,
  )..addListener(_changed);

  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _canSubmit = _text.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _changed() {
    final can = _text.text.trim().isNotEmpty;
    if (can != _canSubmit) setState(() => _canSubmit = can);
  }

  void _useExample(String example) {
    _text.value = TextEditingValue(
      text: example,
      selection: TextSelection.collapsed(offset: example.length),
    );
  }

  void _submit() {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    widget.onSubmit(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final offline = ref.watch(backendStatusProvider) == BackendStatus.offline;
    final examples = [
      l10n.scanExampleBatteries,
      l10n.scanExampleJeans,
      l10n.scanExampleJars,
      l10n.scanExampleBox,
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.backToCamera
            ? KanzIconButton(
                icon: KanzIcons.back,
                semanticsLabel: l10n.scanBackToCamera,
                onPressed: widget.onClose,
              )
            : KanzIconButton(
                icon: KanzIcons.close,
                semanticsLabel: l10n.commonClose,
                onPressed: widget.onClose,
              ),
      ),
      body: Column(
        children: [
          if (offline) OfflineBanner(message: l10n.scanOffline),
          Expanded(
            child: ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(
                KanzSpace.gutter,
                KanzSpace.s8,
                KanzSpace.gutter,
                KanzSpace.s32,
              ),
              children: [
                Row(
                  children: [
                    Icon(KanzIcons.describe, size: 16, color: c.inkSecondary),
                    const SizedBox(width: KanzSpace.s8),
                    MonoLabel(l10n.scanTextScan),
                  ],
                ),
                const SizedBox(height: KanzSpace.s12),
                Semantics(
                  header: true,
                  child: Text(l10n.scanDescribeTitle, style: t.headlineLarge),
                ),
                const SizedBox(height: KanzSpace.s8),
                Text(
                  l10n.scanDescribeBody,
                  style: t.bodyMedium?.copyWith(color: c.inkSecondary),
                ),
                const SizedBox(height: KanzSpace.s24),
                KanzTextField(
                  label: l10n.scanDescribeLabel,
                  controller: _text,
                  hint: l10n.scanDescribeHint,
                  minLines: 4,
                  maxLines: 8,
                  maxLength: ScanSession.maxDescriptionLength,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: KanzSpace.s24),
                MonoLabel(l10n.scanExamplesTitle),
                const SizedBox(height: KanzSpace.s4),
                Wrap(
                  spacing: KanzSpace.s8,
                  children: [
                    for (final example in examples)
                      Semantics(
                        label: l10n.scanExampleSemantics(example),
                        excludeSemantics: true,
                        button: true,
                        onTap: () => _useExample(example),
                        child: KanzChip(
                          label: example,
                          selected: false,
                          onSelected: (_) => _useExample(example),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: c.background,
              border: Border(top: BorderSide(color: c.line)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  KanzSpace.gutter,
                  KanzSpace.s12,
                  KanzSpace.gutter,
                  KanzSpace.s12,
                ),
                child: KanzButton(
                  label: l10n.scanDescribeStart,
                  trailingIcon: KanzIcons.forward,
                  onPressed: _canSubmit ? _submit : null,
                  expand: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
