import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/design/design.dart';

/// What goes on the shared picture.
@immutable
class ShareCardData {
  const ShareCardData({
    required this.id,
    required this.title,
    required this.beforeLabel,
    required this.afterLabel,
    this.madeFrom,
    this.before,
    this.after,
  });

  /// Names the file (the project id).
  final String id;
  final String title;

  /// "Made from Glass jam jar", set in mono above the title.
  final String? madeFrom;
  final ImageProvider? before;
  final ImageProvider? after;
  final String beforeLabel;
  final String afterLabel;
}

/// The before and after side by side, the project title and a small Kanz
/// wordmark: a plain record of the makeover, always on light paper so it
/// reads the same wherever it is posted. The before picture sits on the
/// reading-start side. With one picture it spans the width; with none the
/// card is the title alone.
class ShareCard extends StatelessWidget {
  const ShareCard({super.key, required this.data});

  /// Logical width; the PNG is rendered at twice this.
  static const double width = 540;

  final ShareCardData data;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    // The picture is the same whatever the phone's text size.
    return MediaQuery.withNoTextScaling(
      child: Theme(
        data: KanzTheme.light(locale: locale),
        child: Builder(
          builder: (context) {
            final c = context.kanzColors;
            final t = context.textStyles;
            final before = data.before;
            final after = data.after;
            return Container(
              width: width,
              color: c.background,
              padding: const EdgeInsetsDirectional.all(KanzSpace.s32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (before != null && after != null)
                    Row(
                      children: [
                        Expanded(
                          child: _Picture(
                            image: before,
                            label: data.beforeLabel,
                          ),
                        ),
                        const SizedBox(width: KanzSpace.s12),
                        Expanded(
                          child: _Picture(image: after, label: data.afterLabel),
                        ),
                      ],
                    )
                  else if (before != null || after != null)
                    _Picture(
                      image: (after ?? before)!,
                      label: after != null ? data.afterLabel : null,
                      aspectRatio: 3 / 2,
                    ),
                  if (before != null || after != null)
                    const SizedBox(height: KanzSpace.s32),
                  if (data.madeFrom != null) ...[
                    MonoLabel(data.madeFrom!),
                    const SizedBox(height: KanzSpace.s8),
                  ],
                  Text(data.title, style: t.displaySmall),
                  const SizedBox(height: KanzSpace.s32),
                  Divider(height: 1, thickness: 1, color: c.line),
                  const SizedBox(height: KanzSpace.s16),
                  const BrandLockup(markSize: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Picture extends StatelessWidget {
  const _Picture({required this.image, this.label, this.aspectRatio = 1});

  final ImageProvider image;
  final String? label;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: KanzRadii.inputAll,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: c.photoBackdrop),
            Image(
              image: image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => const SizedBox.expand(),
            ),
            if (label != null)
              PositionedDirectional(
                top: KanzSpace.s12,
                start: KanzSpace.s12,
                child: Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: KanzSpace.s8,
                    vertical: KanzSpace.s2,
                  ),
                  decoration: const BoxDecoration(
                    color: KanzPhotoColors.tag,
                    borderRadius: KanzRadii.tagAll,
                  ),
                  child: MonoLabel(label!, color: KanzPhotoColors.ink),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Renders a [ShareCard] off screen to a PNG in the temporary directory and
/// returns its path. The card is laid out in the app's overlay (outside the
/// visible area), so it uses the app's fonts and direction, then removed.
class ShareCardRenderer {
  const ShareCardRenderer();

  static const double pixelRatio = 2;

  Future<String?> render(BuildContext context, ShareCardData data) async {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return null;
    for (final image in [data.before, data.after].nonNulls) {
      // A picture that cannot load is left out rather than failing the share.
      await precacheImage(image, context, onError: (error, stack) {});
    }
    final key = GlobalKey(debugLabel: 'share-card');
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: -ShareCard.width * 4,
        top: 0,
        child: ExcludeSemantics(
          child: RepaintBoundary(
            key: key,
            child: ShareCard(data: data),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    try {
      // One frame to lay the card out, one more for images that finish
      // decoding during the first.
      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;
      final boundary = key.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary) return null;
      final file = File(
        p.join(Directory.systemTemp.path, 'kanz_share_${data.id}.png'),
      );
      return await capture(boundary, file);
    } finally {
      entry.remove();
    }
  }

  /// Writes [boundary] as a PNG to [file]; returns its path.
  static Future<String> capture(
    RenderRepaintBoundary boundary,
    File file,
  ) async {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(data!.buffer.asUint8List(), flush: true);
      return file.path;
    } finally {
      image.dispose();
    }
  }
}

/// The share card renderer; tests replace it.
final shareCardRendererProvider = Provider<ShareCardRenderer>(
  (ref) => const ShareCardRenderer(),
);
