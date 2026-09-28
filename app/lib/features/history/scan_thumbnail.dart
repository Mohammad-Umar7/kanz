/// Thumbnails for saved scans, used by Home and History. Photos come from
/// the phone (they open offline); scans made from a typed description get a
/// designed text tile instead of a photo.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/data/models/models.dart';
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
import '../../core/state/history_providers.dart';
import '../../l10n/l10n.dart';

/// Decoded width of scan thumbnails: sharp at 3x for the largest tile, and
/// far smaller in memory than the 1600 px photo.
const int scanThumbnailWidth = 480;

/// The image provider for a scan photo on the device. Home and History use
/// the same key, so a photo decoded once shows instantly on the other.
ImageProvider scanPhotoImage(String path) =>
    ResizeImage(FileImage(File(path)), width: scanThumbnailWidth);

/// The line a scan is known by: the analysed item's name, else what the user
/// typed, else "Unfinished scan".
String scanTitle(AppLocalizations l10n, ScanSummary scan) {
  final title = scan.title?.trim();
  if (title != null && title.isNotEmpty) return title;
  final text = scan.inputText?.trim();
  if (text != null && text.isNotEmpty) return text;
  return l10n.homeUnfinishedScan;
}

/// The localized material name of the scan's main item, if analysed.
String? scanMaterial(Vocab vocab, Locale locale, ScanSummary scan) {
  final category = scan.primaryCategory;
  return category == null
      ? null
      : vocab.material(category).label.forLocale(locale);
}

/// "14:05", in Western digits like every other figure in Kanz.
String formatClock(DateTime time) => DateFormat('HH:mm', 'en').format(time);

/// A scan's picture: its photo, a text tile for described items, or a
/// quiet material glyph when neither is there (photo deleted, unfinished).
class ScanThumbnail extends StatelessWidget {
  const ScanThumbnail({
    super.key,
    required this.scan,
    this.large = false,
    this.borderRadius = KanzRadii.inputAll,
  });

  final ScanSummary scan;

  /// Large tiles (Home) show the description itself; small ones a glyph.
  final bool large;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final path = scan.localImagePath;
    final Widget content;
    if (path != null && path.isNotEmpty) {
      content = Image(
        image: scanPhotoImage(path),
        fit: BoxFit.cover,
        gaplessPlayback: true,
        excludeFromSemantics: true,
        frameBuilder: (context, child, frame, sync) {
          if (sync) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: KanzMotion.of(context, KanzMotion.slow),
            curve: KanzMotion.enter,
            child: child,
          );
        },
        errorBuilder: (context, error, stack) => _GlyphTile(scan: scan),
      );
    } else if (scan.source == AnalysisSource.text &&
        (scan.inputText?.trim().isNotEmpty ?? false)) {
      content = large ? _TextTile(scan: scan) : _GlyphTile(scan: scan);
    } else {
      content = _GlyphTile(scan: scan);
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: c.line),
        ),
        child: ColoredBox(color: c.surfaceSunken, child: content),
      ),
    );
  }
}

/// The typed description set like an index card: an opening glyph, the
/// words themselves and a mono label.
class _TextTile extends StatelessWidget {
  const _TextTile({required this.scan});

  final ScanSummary scan;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.all(KanzSpace.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(KanzIcons.describe, size: 20, color: c.inkSecondary),
            const SizedBox(height: KanzSpace.s8),
            Expanded(
              child: Text(
                scan.inputText!.trim(),
                style: t.bodyMedium,
                overflow: TextOverflow.fade,
              ),
            ),
            const SizedBox(height: KanzSpace.s8),
            MonoLabel(context.l10n.homeDescription, maxLines: 1),
          ],
        ),
      ),
    );
  }
}

class _GlyphTile extends StatelessWidget {
  const _GlyphTile({required this.scan});

  final ScanSummary scan;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final category = scan.primaryCategory;
    final glyph = scan.source == AnalysisSource.text
        ? KanzIcons.describe
        : (category == null
              ? KanzIcons.camera
              : KanzIcons.material(category.id));
    return ExcludeSemantics(
      child: Center(child: Icon(glyph, size: 24, color: c.inkSecondary)),
    );
  }
}

/// Material dot and name, e.g. "● Glass", for scan meta lines.
class MaterialTag extends StatelessWidget {
  const MaterialTag({super.key, required this.categoryId, required this.label});

  final String categoryId;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MaterialDot(categoryId),
        const SizedBox(width: KanzSpace.s8),
        Flexible(child: Text(label, style: context.textStyles.labelSmall)),
      ],
    );
  }
}
