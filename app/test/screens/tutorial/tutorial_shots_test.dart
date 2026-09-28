// Renders every state of the tutorial screen at 360 and 412 dp, light and
// dark, English and Arabic (plus 130 % text for the main pages) into
// test/screenshots/_out/ for design review.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/core/state/connectivity_providers.dart';
import 'package:kanz/core/state/scan_session.dart';
import 'package:kanz/features/tutorial/tutorial_screen.dart';
import 'package:kanz/features/tutorial/widgets/adapt_sheet.dart';
import 'package:kanz/l10n/l10n.dart';

import '../../screenshots/harness.dart';
import 'tutorial_test_support.dart';

/// One screen state to render.
typedef _Scenario = ({
  String name,
  TutorialState Function(Lang lang, ShotPhotos photos) tutorial,
  ScanSessionState Function(Lang lang, ShotPhotos photos)? scan,
  HandsFreeState handsFree,
  BackendStatus backend,
  int? page,
  List<(Duration, TutorialState)> Function(Lang lang, ShotPhotos photos)? later,
  bool openAdaptSheet,
  bool largeText,
  bool tall,
});

_Scenario _scenario(
  String name, {
  required TutorialState Function(Lang lang, ShotPhotos photos) tutorial,
  ScanSessionState Function(Lang lang, ShotPhotos photos)? scan,
  HandsFreeState handsFree = const HandsFreeState(),
  BackendStatus backend = BackendStatus.online,
  int? page,
  List<(Duration, TutorialState)> Function(Lang lang, ShotPhotos photos)? later,
  bool openAdaptSheet = false,
  bool largeText = false,
  bool tall = false,
}) => (
  name: name,
  tutorial: tutorial,
  scan: scan,
  handsFree: handsFree,
  backend: backend,
  page: page,
  later: later,
  openAdaptSheet: openAdaptSheet,
  largeText: largeText,
  tall: tall,
);

/// The jar scan with its photo and the warm stand-in as the makeover.
ScanSessionState _jarScan(Lang lang, ShotPhotos photos) => scanState(
  lang: lang,
  photoPath: photos.photo,
  after: readyImage(photos.after),
);

/// The same scan on a key without image quota: no makeover.
ScanSessionState _jarScanNoImages(Lang lang, ShotPhotos photos) =>
    scanState(lang: lang, photoPath: photos.photo);

Tutorial _adapted(Lang lang) => tutorialFixture(lang).copyWith(
  tutorialId: 'tut_adapted',
  skill: SkillLevel.intermediate,
  adaptedNote: lang == Lang.ar
      ? 'مُعدّ لمستوى متوسط: مثقاب صغير لثقب الغطاء، ومقبض من السلك دون لفّ.'
      : 'Adapted for Intermediate: a small drill for the lid, and a bare wire handle.',
);

final List<_Scenario> _scenarios = [
  // Whole pages in a tall viewport, to review the sections below the fold.
  _scenario(
    'overview_full',
    tall: true,
    scan: _jarScan,
    tutorial: (lang, photos) =>
        readyTutorial(lang: lang, images: allStepImages(photos.after)),
  ),
  _scenario(
    'finish_full',
    tall: true,
    scan: _jarScan,
    tutorial: (lang, photos) => readyTutorial(
      lang: lang,
      images: allStepImages(photos.after),
      current: 5,
      done: {1, 2, 3, 5},
    ),
    page: 6,
  ),
  _scenario(
    'overview',
    largeText: true,
    scan: _jarScan,
    tutorial: (lang, photos) =>
        readyTutorial(lang: lang, images: allStepImages(photos.after)),
  ),
  _scenario(
    'step',
    largeText: true,
    scan: _jarScan,
    tutorial: (lang, photos) => readyTutorial(
      lang: lang,
      images: allStepImages(photos.after),
      current: 2,
      done: {1},
    ),
  ),
  _scenario(
    'step_done',
    scan: _jarScan,
    tutorial: (lang, photos) => readyTutorial(
      lang: lang,
      images: allStepImages(photos.after),
      current: 1,
      done: {1},
    ),
    page: 1,
  ),
  // A tutorial written in English, opened with the app in Arabic (and the
  // other way round): its text keeps its own direction.
  _scenario(
    'step_other_language',
    scan: _jarScan,
    tutorial: (lang, photos) => readyTutorial(
      lang: lang == Lang.ar ? Lang.en : Lang.ar,
      images: allStepImages(photos.after),
      current: 2,
      done: {1},
    ),
  ),
  _scenario(
    'step_drawing',
    scan: _jarScan,
    tutorial: (lang, photos) => readyTutorial(
      lang: lang,
      images: {
        1: readyImage(photos.after),
        2: readyImage(photos.after),
        3: const GeneratedImageState(status: ImageStatus.loading),
      },
      current: 3,
      done: {1, 2},
    ),
  ),
  _scenario(
    'step_queued',
    scan: _jarScan,
    tutorial: (lang, photos) => readyTutorial(
      lang: lang,
      images: {
        1: readyImage(photos.after),
        2: const GeneratedImageState(status: ImageStatus.loading),
      },
      current: 4,
      done: {1, 2, 3},
    ),
  ),
  _scenario(
    'step_paused',
    largeText: true,
    scan: _jarScanNoImages,
    tutorial: (lang, photos) =>
        readyTutorial(lang: lang, images: {1: quotaFailed}, current: 1),
    page: 1,
  ),
  _scenario(
    'step_failed',
    scan: _jarScan,
    tutorial: (lang, photos) => readyTutorial(
      lang: lang,
      images: {
        1: readyImage(photos.after),
        2: const GeneratedImageState(
          status: ImageStatus.failed,
          error: busyError,
        ),
      },
      current: 2,
      done: {1},
    ),
  ),
  _scenario(
    'step_no_photo',
    scan: (lang, photos) => scanState(
      lang: lang,
      source: AnalysisSource.text,
      inputText: 'An empty glass jam jar with a metal lid',
      reference: quotaFailed,
    ),
    tutorial: (lang, photos) =>
        readyTutorial(lang: lang, images: {1: quotaFailed}, current: 3),
  ),
  _scenario(
    'finish',
    largeText: true,
    scan: _jarScan,
    tutorial: (lang, photos) => readyTutorial(
      lang: lang,
      images: allStepImages(photos.after),
      current: 5,
      done: {1, 2, 3, 5},
    ),
    page: 6,
  ),
  _scenario(
    'adapt_sheet',
    scan: _jarScan,
    tutorial: (lang, photos) =>
        readyTutorial(lang: lang, images: allStepImages(photos.after)),
    openAdaptSheet: true,
  ),
  _scenario(
    'adapting',
    scan: _jarScan,
    tutorial: (lang, photos) => readyTutorial(
      lang: lang,
      images: allStepImages(photos.after),
      adapting: true,
    ),
  ),
  _scenario(
    'adapted',
    scan: _jarScan,
    tutorial: (lang, photos) => readyTutorial(
      lang: lang,
      images: allStepImages(photos.after),
      adapting: true,
      current: 2,
      done: {1},
    ),
    later: (lang, photos) => [
      (
        const Duration(milliseconds: 200),
        readyTutorial(lang: lang, tutorial: _adapted(lang)),
      ),
    ],
  ),
  _scenario(
    'adapt_failed',
    scan: _jarScan,
    tutorial: (lang, photos) => readyTutorial(
      lang: lang,
      images: allStepImages(photos.after),
      adaptError: busyError,
    ),
  ),
  _scenario(
    'hands_free',
    scan: _jarScan,
    handsFree: const HandsFreeState(
      enabled: true,
      listening: true,
      lastCommand: VoiceCommand.next,
    ),
    tutorial: (lang, photos) => readyTutorial(
      lang: lang,
      images: allStepImages(photos.after),
      current: 2,
      done: {1},
    ),
  ),
  _scenario(
    'hands_free_limited',
    scan: _jarScan,
    handsFree: const HandsFreeState(
      enabled: true,
      speaking: true,
      voiceUnavailable: true,
    ),
    tutorial: (lang, photos) => readyTutorial(
      lang: lang,
      images: allStepImages(photos.after),
      current: 2,
      done: {1},
    ),
  ),
  _scenario(
    'offline',
    scan: _jarScanNoImages,
    backend: BackendStatus.offline,
    tutorial: (lang, photos) =>
        readyTutorial(lang: lang, images: {1: quotaFailed}, current: 2),
  ),
  _scenario(
    'loading',
    scan: _jarScan,
    tutorial: (lang, photos) => const TutorialState(),
  ),
  _scenario(
    'loading_no_images',
    scan: _jarScanNoImages,
    tutorial: (lang, photos) => const TutorialState(),
  ),
  _scenario(
    'failed',
    scan: _jarScan,
    tutorial: (lang, photos) =>
        const TutorialState(phase: TutorialPhase.failed, error: busyError),
  ),
  _scenario(
    'failed_offline',
    scan: _jarScan,
    tutorial: (lang, photos) =>
        const TutorialState(phase: TutorialPhase.failed, error: offlineError),
  ),
  _scenario(
    'missing',
    scan: _jarScan,
    tutorial: (lang, photos) => const TutorialState(
      phase: TutorialPhase.failed,
      error: ApiException(
        code: ApiErrorCode.notFound,
        message: 'This idea is not part of the scan.',
        retryable: false,
      ),
    ),
  ),
];

void main() {
  setUpAll(loadKanzFonts);

  for (final scenario in _scenarios) {
    final configs = [
      if (scenario.tall)
        ...ShotConfig.matrix(
          sizes: const [Size(360, 2000)],
          textScales: const [1.0, 1.3],
        )
      else
        ...ShotConfig.matrix(),
      if (scenario.largeText) ...[
        const ShotConfig(textScale: 1.3),
        const ShotConfig(locale: Locale('ar'), textScale: 1.3),
      ],
    ];
    for (final config in configs) {
      testWidgets('tutorial ${scenario.name} ${config.id}', (tester) async {
        final photos = await preparePhotos(tester);
        final lang = langOf(config.locale);
        final overrides = await tutorialOverrides(
          tutorial: scenario.tutorial(lang, photos),
          scan: (scenario.scan ?? _jarScan)(lang, photos),
          handsFree: scenario.handsFree,
          backend: scenario.backend,
          later: scenario.later?.call(lang, photos) ?? const [],
        );
        Widget screen = TutorialScreen(
          scanId: scanId,
          ideaId: ideaId,
          initialPage: scenario.page,
        );
        if (scenario.openAdaptSheet) {
          final tutorial = tutorialFixture(lang);
          final vocab = loadVocab();
          final used = [for (final t in tutorial.tools) t.toolId];
          screen = _OpenOnStart(
            open: (context) => showAdaptSheet(
              context: context,
              skill: SkillLevel.beginner,
              tools: const [ToolId.pliers, ToolId.scissors, ToolId.twine],
              offline: false,
              choices: [
                for (final id in used) vocab.tool(id),
                for (final e in vocab.realTools)
                  if (!used.contains(e.id)) e,
              ],
            ),
            child: screen,
          );
        }
        await takeShot(
          tester,
          name: 'tutorial_${scenario.name}',
          config: config,
          precache: [photos.photoImage, photos.afterImage],
          localizationsDelegates: const [AppLocalizations.delegate],
          wrap: (app) => ProviderScope(overrides: overrides, child: app),
          child: screen,
        );
      });
    }
  }
}

/// Opens a sheet over [child] once the first frame is up.
class _OpenOnStart extends StatefulWidget {
  const _OpenOnStart({required this.open, required this.child});

  final void Function(BuildContext context) open;
  final Widget child;

  @override
  State<_OpenOnStart> createState() => _OpenOnStartState();
}

class _OpenOnStartState extends State<_OpenOnStart> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.open(context);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
