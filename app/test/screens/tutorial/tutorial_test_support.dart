// Fixture data, fakes and provider overrides for the tutorial and completion
// screen tests (screenshots and interactions).
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/data/vocab/vocab.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/core/state/connectivity_providers.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/core/state/hands_free_controller.dart';
import 'package:kanz/core/state/scan_session.dart';
import 'package:kanz/core/state/tutorial_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/support/fixtures.dart';

export 'package:kanz/core/state/hands_free_controller.dart'
    show HandsFreeState, VoiceCommand;
export 'package:kanz/core/state/tutorial_controller.dart';

const scanId = 'scan_1';
const ideaId = 'idea_9f2c41aa';
const TutorialKey tutorialKey = (scanId: scanId, ideaId: ideaId);

Lang langOf(Locale locale) => locale.languageCode == 'ar' ? Lang.ar : Lang.en;

Tutorial tutorialFixture(Lang lang) => TutorialResponse.fromJson(
  fixture(
    lang == Lang.ar
        ? 'tutorial_jar_lantern_ar.json'
        : 'tutorial_jar_lantern.json',
  ),
).tutorial;

AnalyzeResponse analysisFixture(Lang lang) => AnalyzeResponse.fromJson(
  fixture(
    lang == Lang.ar ? 'analyze_glass_jar_ar.json' : 'analyze_glass_jar.json',
  ),
);

RecommendResponse recommendFixture(Lang lang) => RecommendResponse.fromJson(
  fixture(
    lang == Lang.ar
        ? 'recommend_glass_jar_ar.json'
        : 'recommend_glass_jar.json',
  ),
);

Vocab loadVocab() => Vocab.fromJson(
  jsonDecode(File('assets/config/vocab.json').readAsStringSync())
      as Map<String, dynamic>,
);

const quotaError = ApiException(
  code: ApiErrorCode.aiQuotaExhausted,
  message: 'Image generation quota used up.',
  retryable: false,
  requestId: 'req_5f3c2a1b',
);

const busyError = ApiException(
  code: ApiErrorCode.aiUnavailable,
  message: 'The model is busy.',
  retryable: true,
  requestId: 'req_7a21c9e0',
);

const offlineError = ApiException.offline();

const quotaFailed = GeneratedImageState(
  status: ImageStatus.failed,
  error: quotaError,
);

GeneratedImageState readyImage(String path) => GeneratedImageState(
  status: ImageStatus.ready,
  url: 'http://kanz.test/static/generated/step.jpg?v=1',
  localPath: path,
);

/// Photos on disk for the screens' file images: the committed jar photo,
/// and a warm-toned copy that stands in for a generated makeover (image
/// generation needs a billed key; the screens render any image the same).
class ShotPhotos {
  const ShotPhotos(this.photo, this.after);

  final String photo;
  final String after;

  ImageProvider get photoImage => FileImage(File(photo));
  ImageProvider get afterImage => FileImage(File(after));
}

Future<ShotPhotos> preparePhotos(WidgetTester tester) async {
  final photo = File('test/screenshots/fixtures/glass_jar.jpg').absolute;
  final after = File(
    '${Directory.systemTemp.path}/kanz_screen_shots/glass_jar_warm.png',
  );
  if (!after.existsSync()) {
    await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(
        photo.readAsBytesSync(),
        targetWidth: 800,
      );
      final frame = await codec.getNextFrame();
      final source = frame.image;
      final size = Size(source.width.toDouble(), source.height.toDouble());
      final recorder = ui.PictureRecorder();
      Canvas(recorder)
        ..drawImage(
          source,
          Offset.zero,
          Paint()
            ..colorFilter = const ColorFilter.matrix([
              1.10, 0.10, 0.00, 0, 12, //
              0.04, 0.92, 0.04, 0, 0, //
              0.00, 0.06, 0.70, 0, -12, //
              0, 0, 0, 1, 0, //
            ]),
        )
        ..drawRect(
          Offset.zero & size,
          Paint()
            ..shader = ui.Gradient.radial(
              size.center(Offset(0, size.height * 0.12)),
              size.width * 0.6,
              [const Color(0x40FFB060), const Color(0x00000000)],
            ),
        );
      final image = await recorder.endRecording().toImage(
        source.width,
        source.height,
      );
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      after.parent.createSync(recursive: true);
      after.writeAsBytesSync(png!.buffer.asUint8List());
      image.dispose();
      source.dispose();
      codec.dispose();
    });
  }
  final photos = ShotPhotos(photo.path, after.path);
  await warmImages(tester, [photos.photoImage, photos.afterImage]);
  return photos;
}

/// Decodes [images] into the image cache with real async before a screen
/// asks for them. File images started inside the test's fake-async zone never
/// finish loading, so the screen must find them already cached.
Future<void> warmImages(WidgetTester tester, List<ImageProvider> images) async {
  await tester.runAsync(() async {
    for (final image in images) {
      final done = Completer<void>();
      final stream = image.resolve(ImageConfiguration.empty);
      late final ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, sync) {
          if (!done.isCompleted) done.complete();
        },
        onError: (error, stack) {
          if (!done.isCompleted) done.complete();
        },
      );
      stream.addListener(listener);
      await done.future;
      stream.removeListener(listener);
    }
  });
}

// ------------------------------------------------------------------- fakes

/// A tutorial controller with fixed state that records the actions called.
/// [later] replaces the state after a delay (an adapt finishing, say).
class FakeTutorialController extends TutorialController {
  FakeTutorialController(
    super.key,
    this.initial, {
    this.later = const [],
    this.completeResult = 'project_1',
  });

  final TutorialState initial;
  final List<(Duration, TutorialState)> later;
  final String? completeResult;
  final List<String> calls = [];

  @override
  TutorialState build() {
    for (final (delay, next) in later) {
      unawaited(
        Future<void>.delayed(delay, () {
          if (ref.mounted) state = next;
        }),
      );
    }
    return initial;
  }

  /// Replaces the state, as the real controller does when work finishes.
  void debugSet(TutorialState next) => state = next;

  @override
  Future<void> retry() async => calls.add('retry');

  @override
  Future<void> adapt({
    required SkillLevel skill,
    required List<ToolId> tools,
  }) async {
    calls.add('adapt:${skill.id}:${tools.map((t) => t.id).join(',')}');
    state = state.copyWith(adapting: true);
  }

  @override
  Future<void> goToStep(int number) async {
    calls.add('goToStep:$number');
    state = state.copyWith(currentStep: number);
  }

  @override
  Future<void> next() => goToStep(state.currentStep + 1);

  @override
  Future<void> previous() => goToStep(state.currentStep - 1);

  @override
  Future<void> markStepDone(int number, {bool done = true}) async {
    calls.add('markStepDone:$number:$done');
    final steps = {...state.completedSteps};
    done ? steps.add(number) : steps.remove(number);
    state = state.copyWith(completedSteps: steps);
  }

  @override
  Future<void> regenerateStep(int number) async =>
      calls.add('regenerateStep:$number');

  @override
  Future<String?> complete() async {
    calls.add('complete');
    return completeResult;
  }
}

/// Hands-free with fixed state; toggles flip it without any speech.
class FakeHandsFree extends HandsFreeController {
  FakeHandsFree(super.key, this.initial);

  final HandsFreeState initial;
  int enables = 0;
  int toggles = 0;

  @override
  HandsFreeState build() => initial;

  @override
  Future<void> enable() async {
    enables++;
    state = state.copyWith(enabled: true, listening: true);
  }

  @override
  Future<void> disable() async =>
      state = state.copyWith(enabled: false, listening: false);

  @override
  Future<void> toggle() async {
    toggles++;
    state.enabled ? await disable() : await enable();
  }

  @override
  Future<void> speakCurrentStep() async {}
}

class FakeScanSession extends ScanSession {
  FakeScanSession(super.scanId, this.initial);

  final ScanSessionState initial;

  @override
  ScanSessionState build() => initial;
}

// ------------------------------------------------------------------ states

ScanSessionState scanState({
  required Lang lang,
  String? photoPath,
  GeneratedImageState after = quotaFailed,
  AnalysisSource source = AnalysisSource.image,
  String? inputText,
  GeneratedImageState reference = const GeneratedImageState(),
}) {
  return ScanSessionState(
    scanId: scanId,
    origin: ScanOrigin.restored,
    source: source,
    lang: lang,
    inputText: inputText,
    localImagePath: photoPath,
    analysis: analysisFixture(lang),
    recommendation: recommendFixture(lang),
    afterImages: {ideaId: after},
    referenceImage: reference,
  );
}

TutorialState readyTutorial({
  required Lang lang,
  Map<int, GeneratedImageState> images = const {},
  int current = 1,
  Set<int> done = const {},
  bool adapting = false,
  ApiException? adaptError,
  Tutorial? tutorial,
}) {
  final t = tutorial ?? tutorialFixture(lang);
  return TutorialState(
    phase: TutorialPhase.ready,
    tutorial: t,
    idea: recommendFixture(lang).ideaById(ideaId),
    skill: t.skill,
    tools: const [ToolId.pliers, ToolId.scissors, ToolId.twine],
    stepImages: images,
    currentStep: current,
    completedSteps: done,
    adapting: adapting,
    adaptError: adaptError,
  );
}

/// Every step picture ready (the warm stand-in).
Map<int, GeneratedImageState> allStepImages(String path) => {
  for (var n = 1; n <= 5; n++) n: readyImage(path),
};

// --------------------------------------------------------------- overrides

/// Overrides for the tutorial screen: the fakes above plus settings,
/// vocabulary and connection status.
Future<List<Override>> tutorialOverrides({
  required TutorialState tutorial,
  required ScanSessionState scan,
  HandsFreeState handsFree = const HandsFreeState(),
  BackendStatus backend = BackendStatus.online,
  Map<String, Object> prefs = const {},
  List<(Duration, TutorialState)> later = const [],
  void Function(FakeTutorialController)? onController,
  void Function(FakeHandsFree)? onHandsFree,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final preferences = await SharedPreferences.getInstance();
  return [
    sharedPreferencesProvider.overrideWithValue(preferences),
    vocabProvider.overrideWithValue(loadVocab()),
    backendStatusProvider.overrideWithValue(backend),
    tutorialControllerProvider.overrideWith2((key) {
      final controller = FakeTutorialController(key, tutorial, later: later);
      onController?.call(controller);
      return controller;
    }),
    handsFreeProvider.overrideWith2((key) {
      final controller = FakeHandsFree(key, handsFree);
      onHandsFree?.call(controller);
      return controller;
    }),
    scanSessionProvider.overrideWith2((id) => FakeScanSession(id, scan)),
  ];
}
