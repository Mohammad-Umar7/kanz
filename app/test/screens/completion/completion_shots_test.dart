// Renders every state of the completion screen, and the share card, at 360
// and 412 dp, light and dark, English and Arabic (plus 130 % text for the
// main state) into test/screenshots/_out/ for design review.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/state/scan_session.dart';
import 'package:kanz/features/completion/completion_screen.dart';
import 'package:kanz/features/completion/made_photo_capture.dart';
import 'package:kanz/features/completion/share_card.dart';
import 'package:kanz/l10n/l10n.dart';

import '../../screenshots/harness.dart';
import 'completion_test_support.dart';

typedef _Scenario = ({
  String name,
  ScanSessionState Function(Lang lang, ShotPhotos photos) scan,
  ProjectLoad load,
  bool largeText,
  bool tall,
  bool ownPhoto,
});

_Scenario _scenario(
  String name, {
  required ScanSessionState Function(Lang lang, ShotPhotos photos) scan,
  ProjectLoad load = ProjectLoad.ready,
  bool largeText = false,
  bool tall = false,
  bool ownPhoto = false,
}) => (
  name: name,
  scan: scan,
  load: load,
  largeText: largeText,
  tall: tall,
  ownPhoto: ownPhoto,
);

ScanSessionState _withMakeover(Lang lang, ShotPhotos photos) => scanState(
  lang: lang,
  photoPath: photos.photo,
  after: readyImage(photos.after),
);

final List<_Scenario> _scenarios = [
  _scenario('completion', scan: _withMakeover, largeText: true),
  _scenario('completion_full', scan: _withMakeover, tall: true),
  _scenario(
    'completion_photo_only',
    scan: (lang, photos) => scanState(lang: lang, photoPath: photos.photo),
  ),
  // No makeover on this server, and the user photographed their lantern
  // (the warm stand-in plays their photo).
  _scenario(
    'completion_own_photo',
    scan: (lang, photos) => scanState(lang: lang, photoPath: photos.photo),
    ownPhoto: true,
  ),
  _scenario(
    'completion_text_scan',
    scan: (lang, photos) => scanState(
      lang: lang,
      source: AnalysisSource.text,
      inputText: lang == Lang.ar
          ? 'برطمان مربى زجاجي فارغ بغطاء معدني'
          : 'An empty glass jam jar with a metal lid',
      reference: quotaFailed,
    ),
  ),
  _scenario(
    'completion_loading',
    scan: _withMakeover,
    load: ProjectLoad.loading,
  ),
  _scenario(
    'completion_missing',
    scan: _withMakeover,
    load: ProjectLoad.missing,
  ),
  _scenario('completion_error', scan: _withMakeover, load: ProjectLoad.error),
];

void main() {
  setUpAll(loadKanzFonts);

  for (final scenario in _scenarios) {
    final configs = [
      if (scenario.tall)
        ...ShotConfig.matrix(sizes: const [Size(360, 1700)])
      else
        ...ShotConfig.matrix(),
      if (scenario.largeText) ...[
        const ShotConfig(textScale: 1.3),
        const ShotConfig(locale: Locale('ar'), textScale: 1.3),
      ],
    ];
    for (final config in configs) {
      testWidgets('${scenario.name} ${config.id}', (tester) async {
        final photos = await preparePhotos(tester);
        final lang = langOf(config.locale);
        final overrides = await completionOverrides(
          project: projectRecord(lang),
          scan: scenario.scan(lang, photos),
          load: scenario.load,
          photos: FakeMadePhotoStore(
            photo: scenario.ownPhoto ? photos.after : null,
          ),
        );
        await takeShot(
          tester,
          name: scenario.name,
          config: config,
          precache: [photos.photoImage, photos.afterImage],
          localizationsDelegates: const [AppLocalizations.delegate],
          wrap: (app) => ProviderScope(overrides: overrides, child: app),
          child: const CompletionScreen(projectId: projectId),
        );
      });
    }
  }

  // The camera for the photo of the finished project, with the jar photo in
  // place of the live preview, and the page shown when the camera is off.
  for (final config in ShotConfig.matrix(sizes: const [ShotConfig.compact])) {
    testWidgets('made photo camera ${config.id}', (tester) async {
      final photos = await preparePhotos(tester);
      await takeShot(
        tester,
        name: 'completion_camera',
        config: config,
        precache: [photos.photoImage],
        localizationsDelegates: const [AppLocalizations.delegate],
        child: Builder(
          builder: (context) {
            final l10n = context.l10n;
            return MadePhotoViewfinder(
              preview: Image(image: photos.afterImage, fit: BoxFit.cover),
              guidance: l10n.completionCaptureGuidance,
              closeLabel: l10n.commonClose,
              shutterLabel: l10n.completionCaptureShutter,
              galleryLabel: l10n.completionCaptureGalleryShort,
              gallerySemantics: l10n.completionCaptureGallery,
              onShutter: () {},
              onGallery: () {},
              onClose: () {},
            );
          },
        ),
      );
    });
  }
  for (final phase in const [
    MadePhotoCameraPhase.denied,
    MadePhotoCameraPhase.blocked,
  ]) {
    for (final config in ShotConfig.matrix(sizes: const [ShotConfig.compact])) {
      testWidgets('made photo camera ${phase.name} ${config.id}', (
        tester,
      ) async {
        await takeShot(
          tester,
          name: 'completion_camera_${phase.name}',
          config: config,
          localizationsDelegates: const [AppLocalizations.delegate],
          child: MadePhotoCameraProblem(
            phase: phase,
            onGallery: () {},
            onAllow: () {},
            onOpenSettings: () {},
            onClose: () {},
          ),
        );
      });
    }
  }

  // The picture that is shared: both images, one image, none.
  for (final variant in ['pair', 'single', 'text']) {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      testWidgets('share card $variant ${locale.languageCode}', (tester) async {
        final photos = await preparePhotos(tester);
        final lang = langOf(locale);
        final ar = lang == Lang.ar;
        await takeShot(
          tester,
          name: 'completion_share_card_$variant',
          config: ShotConfig(
            size: const Size(ShareCard.width, 900),
            locale: locale,
          ),
          fullPage: true,
          precache: [photos.photoImage, photos.afterImage],
          child: ShareCard(
            data: ShareCardData(
              id: projectId,
              title: tutorialFixture(lang).title,
              madeFrom: ar
                  ? 'مصنوع من برطمان مربى زجاجي'
                  : 'Made from Glass jam jar',
              before: variant == 'text' ? null : photos.photoImage,
              after: variant == 'pair' ? photos.afterImage : null,
              beforeLabel: ar ? 'قبل' : 'Before',
              afterLabel: ar ? 'بعد' : 'After',
            ),
          ),
        );
      });
    }
  }
}
