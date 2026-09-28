import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design/design.dart';

/// The user's photo at the top of the results, with the detected items
/// outlined. It shows as soon as the photo is on the device (the Hero from
/// the viewfinder lands here); the scan line and outlines play once when
/// the detections arrive.
///
/// The frame takes the photo's own shape, kept between 4:5 and 4:3 so a
/// panorama or a tall screenshot does not take over the screen.
class ResultsPhoto extends StatefulWidget {
  const ResultsPhoto({
    super.key,
    required this.image,
    required this.boxes,
    required this.semanticsLabel,
    this.imageSize,
    this.selectedId,
    this.onSelect,
    this.heroTag,
  });

  final ImageProvider image;

  /// Pixel size from the analysis; until it arrives the photo is measured.
  final Size? imageSize;
  final List<DetectionBox> boxes;
  final String semanticsLabel;
  final String? selectedId;
  final ValueChanged<String>? onSelect;
  final Object? heroTag;

  static const double minAspect = 4 / 5;
  static const double maxAspect = 4 / 3;

  @override
  State<ResultsPhoto> createState() => _ResultsPhotoState();
}

class _ResultsPhotoState extends State<ResultsPhoto> {
  Size? _measured;
  ImageStream? _stream;
  late final ImageStreamListener _listener = ImageStreamListener((info, _) {
    final size = Size(
      info.image.width.toDouble(),
      info.image.height.toDouble(),
    );
    info.dispose();
    if (mounted && size != _measured) setState(() => _measured = size);
  }, onError: (_, _) {});

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(ResultsPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) _resolve();
  }

  void _resolve() {
    if (widget.imageSize != null) return;
    final stream = widget.image.resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _stream = stream..addListener(_listener);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.imageSize ?? _measured ?? Size.zero;
    final aspect = size.isEmpty
        ? ResultsPhoto.minAspect
        : math.min(
            ResultsPhoto.maxAspect,
            math.max(ResultsPhoto.minAspect, size.aspectRatio),
          );
    return AspectRatio(
      aspectRatio: aspect,
      child: BoundingBoxOverlay(
        image: widget.image,
        imageSize: size,
        boxes: widget.boxes,
        semanticsLabel: widget.semanticsLabel,
        selectedId: widget.selectedId,
        onSelect: widget.onSelect,
        heroTag: widget.heroTag,
      ),
    );
  }
}

/// Stands in for the photo on a text scan: the user's own words, set like a
/// quotation in a field guide, under a quiet TEXT SCAN label.
class TextScanHeader extends StatelessWidget {
  const TextScanHeader({
    super.key,
    required this.label,
    required this.description,
  });

  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.s20,
        KanzSpace.s20,
        KanzSpace.s20,
        KanzSpace.s24,
      ),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: KanzRadii.cardAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(KanzIcons.describe, size: 16, color: c.inkSecondary),
              const SizedBox(width: KanzSpace.s8),
              MonoLabel(label),
            ],
          ),
          const SizedBox(height: KanzSpace.s16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 2, color: c.ink),
                const SizedBox(width: KanzSpace.s16),
                Expanded(
                  child: Text(
                    description,
                    style: context.textStyles.headlineMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
