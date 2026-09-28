import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/design/design.dart';
import '../../core/state/core_providers.dart';
import '../../l10n/l10n.dart';

/// The gallery path of the scan screen: opens the system photo picker at
/// once. A pick starts the scan, a cancel goes back. On the first build it
/// also collects a photo picked just before Android stopped the app.
class GalleryPickView extends ConsumerStatefulWidget {
  const GalleryPickView({
    super.key,
    required this.onPhoto,
    required this.onCancel,
    required this.onDescribe,
  });

  final ValueChanged<String> onPhoto;
  final VoidCallback onCancel;
  final VoidCallback onDescribe;

  @override
  ConsumerState<GalleryPickView> createState() => _GalleryPickViewState();
}

class _GalleryPickViewState extends ConsumerState<GalleryPickView> {
  bool _failed = false;
  bool _firstPick = true;

  @override
  void initState() {
    super.initState();
    // After the first frame, so the "Opening your photos" page is what shows
    // behind the picker and on the way back.
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_pick()));
  }

  Future<void> _pick() async {
    if (_failed) setState(() => _failed = false);
    final picker = ref.read(galleryPickerProvider);
    XFile? file;
    if (_firstPick) {
      _firstPick = false;
      try {
        file = await picker.recoverLost();
      } on Object {
        // Only Android keeps lost picks; elsewhere there is nothing to recover.
      }
    }
    try {
      file ??= await picker.pick();
    } on Object {
      if (mounted) setState(() => _failed = true);
      return;
    }
    if (!mounted) return;
    if (file == null) {
      widget.onCancel();
    } else {
      widget.onPhoto(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    ref.watch(galleryPickerProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: KanzIconButton(
          icon: KanzIcons.close,
          semanticsLabel: l10n.commonClose,
          onPressed: widget.onCancel,
        ),
      ),
      body: SafeArea(
        top: false,
        child: _failed
            ? ListView(
                children: [
                  ErrorState(
                    icon: KanzIcons.gallery,
                    title: l10n.scanGalleryErrorTitle,
                    message: l10n.scanGalleryErrorBody,
                    retryLabel: l10n.commonRetry,
                    onRetry: () => unawaited(_pick()),
                  ),
                  Padding(
                    padding: KanzSpace.page,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: KanzButton.secondary(
                        label: l10n.scanDescribeInstead,
                        icon: KanzIcons.describe,
                        onPressed: widget.onDescribe,
                      ),
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  KanzSpace.gutter,
                  KanzSpace.s24,
                  KanzSpace.gutter,
                  0,
                ),
                child: Semantics(
                  liveRegion: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: SizedBox.square(
                          dimension: 16,
                          child: context.reduceMotion
                              ? Icon(
                                  KanzIcons.gallery,
                                  size: 16,
                                  color: c.inkSecondary,
                                )
                              : CircularProgressIndicator(
                                  strokeWidth: 1.75,
                                  color: c.inkSecondary,
                                ),
                        ),
                      ),
                      const SizedBox(width: KanzSpace.s12),
                      Expanded(
                        child: Text(
                          l10n.scanOpeningGallery,
                          style: context.textStyles.bodyLarge?.copyWith(
                            color: c.inkSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
