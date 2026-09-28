// Renders every design gallery section at 360 and 412 dp, light and dark,
// English and Arabic, plus 130 % text, into test/screenshots/_out/.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kanz/features/gallery/gallery_samples.dart';
import 'package:kanz/features/gallery/gallery_screen.dart';
import 'package:kanz/features/gallery/gallery_sections.dart';

import 'harness.dart';

void main() {
  setUpAll(loadKanzFonts);

  Future<GalleryImages> images(WidgetTester tester) async {
    final photo = await loadFixturePhoto(tester, 'glass_jar');
    return GalleryImages(
      photo: photo.image,
      photoSize: photo.size,
      jarBox: const Rect.fromLTRB(0.33, 0.205, 0.665, 0.94),
      lidBox: const Rect.fromLTRB(0.33, 0.205, 0.667, 0.335),
      // Image generation is off on the free tier; the photo stands in for a
      // makeover so the loaded state can be reviewed.
      after: photo.image,
    );
  }

  final configs = [
    ...ShotConfig.matrix(),
    const ShotConfig(textScale: 1.3),
    const ShotConfig(locale: Locale('ar'), textScale: 1.3),
  ];

  for (var index = 0; index < gallerySections.length; index++) {
    for (final config in configs) {
      final title = GallerySamples.en.sections[index];
      testWidgets('gallery ${index + 1} $title ${config.id}', (tester) async {
        final gallery = await images(tester);
        final samples = config.isArabic ? GallerySamples.ar : GallerySamples.en;
        await takeShot(
          tester,
          name: 'gallery_${index + 1}',
          config: config,
          fullPage: true,
          precache: [gallery.photo],
          child: GallerySection(
            number: index + 1,
            title: samples.sections[index],
            child: gallerySections[index](samples, gallery),
          ),
        );
      });
    }
  }

  // The screen itself in a fixed phone viewport with system insets: checks
  // the harness path later agents use for whole screens.
  testWidgets('gallery screen viewport', (tester) async {
    final gallery = await images(tester);
    await takeShot(
      tester,
      name: 'gallery_screen',
      precache: [gallery.photo],
      child: DesignGalleryScreen(images: gallery),
    );
    expect(find.text(GallerySamples.en.title), findsOneWidget);
  });

  // The path screen tests use: a routed screen under a Riverpod scope.
  testWidgets('gallery screen at its route under a provider scope', (
    tester,
  ) async {
    final gallery = await images(tester);
    final router = GoRouter(
      initialLocation: '/gallery',
      routes: [
        GoRoute(
          path: '/gallery',
          builder: (context, state) => DesignGalleryScreen(images: gallery),
        ),
      ],
    );
    addTearDown(router.dispose);
    final file = await takeShot(
      tester,
      name: 'gallery_screen_routed',
      config: const ShotConfig(locale: Locale('ar')),
      precache: [gallery.photo],
      wrap: (app) => ProviderScope(child: app),
      routerConfig: router,
    );
    // The gallery opens in the app's language.
    expect(find.text(GallerySamples.ar.title), findsOneWidget);
    expect(file.lengthSync(), greaterThan(0));
  });
}
