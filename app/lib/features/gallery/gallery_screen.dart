/// The design gallery (route `/gallery`, debug builds only): every Kanz
/// component in its states, with toggles for theme, direction (Arabic,
/// right to left) and a 130 % text size. Used for design review and by
/// the screenshot harness (test/screenshots/gallery_test.dart).
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/design/design.dart';
import 'gallery_samples.dart';
import 'gallery_sections.dart';

class DesignGalleryScreen extends StatefulWidget {
  const DesignGalleryScreen({super.key, this.images});

  /// Sample images. When null the gallery paints a simple still life so it
  /// works without bundling a photo in the app.
  final GalleryImages? images;

  @override
  State<DesignGalleryScreen> createState() => _DesignGalleryScreenState();
}

class _DesignGalleryScreenState extends State<DesignGalleryScreen> {
  bool _dark = false;
  bool _rtl = false;
  bool _largeText = false;
  GalleryImages? _painted;

  @override
  void initState() {
    super.initState();
    if (widget.images == null) {
      paintedGalleryImages().then((images) {
        if (mounted) setState(() => _painted = images);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Locale(_rtl ? 'ar' : 'en');
    final samples = _rtl ? GallerySamples.ar : GallerySamples.en;
    final theme = _dark
        ? KanzTheme.dark(locale: locale)
        : KanzTheme.light(locale: locale);
    final images = widget.images ?? _painted;
    final media = MediaQuery.of(context);
    return Theme(
      data: theme,
      child: Directionality(
        textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
        child: MediaQuery(
          data: media.copyWith(
            textScaler: _largeText
                ? const TextScaler.linear(1.3)
                : media.textScaler,
          ),
          child: Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text(samples.title)),
              body: images == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.only(bottom: KanzSpace.s64),
                      children: [
                        _Toggles(
                          samples: samples,
                          dark: _dark,
                          rtl: _rtl,
                          largeText: _largeText,
                          onDark: (v) => setState(() => _dark = v),
                          onRtl: (v) => setState(() => _rtl = v),
                          onLargeText: (v) => setState(() => _largeText = v),
                        ),
                        for (var i = 0; i < gallerySections.length; i++)
                          GallerySection(
                            number: i + 1,
                            title: samples.sections[i],
                            child: gallerySections[i](samples, images),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Toggles extends StatelessWidget {
  const _Toggles({
    required this.samples,
    required this.dark,
    required this.rtl,
    required this.largeText,
    required this.onDark,
    required this.onRtl,
    required this.onLargeText,
  });

  final GallerySamples samples;
  final bool dark;
  final bool rtl;
  final bool largeText;
  final ValueChanged<bool> onDark;
  final ValueChanged<bool> onRtl;
  final ValueChanged<bool> onLargeText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: KanzSpace.page,
      child: Wrap(
        spacing: KanzSpace.s8,
        children: [
          KanzChip(
            label: samples.darkToggle,
            icon: KanzIcons.darkMode,
            selected: dark,
            onSelected: onDark,
          ),
          KanzChip(
            label: samples.rtlToggle,
            icon: KanzIcons.language,
            selected: rtl,
            onSelected: onRtl,
          ),
          KanzChip(
            label: samples.textToggle,
            icon: KanzIcons.describe,
            selected: largeText,
            onSelected: onLargeText,
          ),
        ],
      ),
    );
  }
}

/// Paints a plain still life (a jar with a metal lid on a counter) so the
/// gallery has a photo-like subject without shipping a photo in the app.
Future<GalleryImages> paintedGalleryImages() async {
  const size = Size(1200, 900);
  Future<ImageProvider> paint({required bool lit}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final wall = lit ? const Color(0xFF3A342C) : const Color(0xFFE9E1D6);
    final counter = lit ? const Color(0xFF4A4036) : const Color(0xFFD9CDBE);
    canvas.drawRect(Offset.zero & size, Paint()..color = wall);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.38),
      Paint()..color = counter,
    );
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(460, 290, 280, 440),
      const Radius.circular(48),
    );
    canvas.drawRRect(
      body,
      Paint()..color = const Color(0xFFBFD3CF).withValues(alpha: 0.75),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = const Color(0xFF8FAAA5),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(470, 200, 260, 90),
        const Radius.circular(14),
      ),
      Paint()..color = const Color(0xFF9EA4A8),
    );
    if (lit) {
      canvas.drawCircle(
        const Offset(600, 600),
        26,
        Paint()..color = const Color(0xFFF2C46B),
      );
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return MemoryImage(bytes!.buffer.asUint8List());
  }

  return GalleryImages(
    photo: await paint(lit: false),
    photoSize: size,
    jarBox: const Rect.fromLTRB(0.375, 0.21, 0.63, 0.82),
    lidBox: const Rect.fromLTRB(0.385, 0.21, 0.615, 0.33),
    after: await paint(lit: true),
  );
}
