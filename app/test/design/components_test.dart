// Every component builds in light and dark, left-to-right and Arabic
// right-to-left, at 130 % text on a narrow 320 dp column, with the real
// fonts and no layout overflow. The gallery sections are the fixture: they
// exercise every component in its states.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/features/gallery/gallery_samples.dart';
import 'package:kanz/features/gallery/gallery_sections.dart';

import '../screenshots/harness.dart';

void main() {
  setUpAll(loadKanzFonts);

  for (final dark in [false, true]) {
    for (final rtl in [false, true]) {
      final label = '${dark ? 'dark' : 'light'} ${rtl ? 'rtl' : 'ltr'}';
      testWidgets('all components lay out at 130% text, $label', (
        tester,
      ) async {
        tester.view
          ..devicePixelRatio = 1
          ..physicalSize = const Size(320, 20000);
        addTearDown(tester.view.reset);

        final photo = await loadFixturePhoto(tester, 'glass_jar');
        final images = GalleryImages(
          photo: photo.image,
          photoSize: photo.size,
          jarBox: const Rect.fromLTRB(0.33, 0.2, 0.67, 0.94),
          lidBox: const Rect.fromLTRB(0.33, 0.2, 0.67, 0.34),
          after: photo.image,
        );
        final locale = Locale(rtl ? 'ar' : 'en');
        final samples = rtl ? GallerySamples.ar : GallerySamples.en;

        await tester.pumpWidget(
          MaterialApp(
            theme: dark
                ? KanzTheme.dark(locale: locale)
                : KanzTheme.light(locale: locale),
            locale: locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 20000),
                textScaler: TextScaler.linear(1.3),
              ),
              child: Material(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
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
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(tester.takeException(), isNull);
        expect(
          Directionality.of(tester.element(find.byType(SpecimenCard).first)),
          rtl ? TextDirection.rtl : TextDirection.ltr,
        );
      });
    }
  }
}
