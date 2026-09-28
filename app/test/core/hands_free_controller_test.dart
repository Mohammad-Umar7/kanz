import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/services/tts_service.dart';
import 'package:kanz/core/services/voice_command_service.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/core/state/hands_free_controller.dart';
import 'package:kanz/core/state/tutorial_controller.dart';

import 'support/fakes.dart';
import 'support/fixtures.dart';

const TutorialKey _key = (scanId: 'scan_1', ideaId: 'idea_9f2c41aa');

/// Speech that lasts until the test finishes it (or `stop()` cuts it off).
class _FakeTts implements TtsService {
  final List<String> spoken = [];
  Completer<void>? _current;

  bool get isSpeaking => _current != null && !_current!.isCompleted;

  void finish() => _current?.complete();

  @override
  Future<bool> speak(String text, Lang lang) async {
    spoken.add(text);
    final done = _current = Completer<void>();
    await done.future;
    return true;
  }

  @override
  Future<void> stop() async {
    if (isSpeaking) _current!.complete();
  }
}

/// Records whether the microphone is open and lets the test say a command.
class _FakeVoice implements VoiceCommandService {
  void Function(VoiceCommand)? _onCommand;
  bool active = false;
  bool paused = false;
  int resumes = 0;

  bool get micOpen => active && !paused;

  void say(VoiceCommand command) => _onCommand?.call(command);

  @override
  Future<bool> start({
    required Lang lang,
    required void Function(VoiceCommand command) onCommand,
    void Function(bool listening)? onListening,
  }) async {
    _onCommand = onCommand;
    active = true;
    paused = false;
    return true;
  }

  @override
  Future<void> pause() async => paused = true;

  @override
  Future<void> resume() async {
    resumes++;
    paused = false;
  }

  @override
  Future<void> stop() async => active = false;

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late TestHarness h;
  late _FakeTts tts;
  late _FakeVoice voice;

  setUp(() async {
    tts = _FakeTts();
    voice = _FakeVoice();
    h = await TestHarness.create(tts: tts, voice: voice);
    final scans = h.container.read(scanRepositoryProvider);
    await scans.create(
      id: 'scan_1',
      source: AnalysisSource.image,
      lang: Lang.en,
    );
    await scans.saveAnalysis(
      'scan_1',
      AnalyzeResponse.fromJson(fixture('analyze_glass_jar.json')),
    );
    await scans.saveRecommendation(
      'scan_1',
      RecommendResponse.fromJson(fixture('recommend_glass_jar.json')),
    );
    // Listened to, as the tutorial screen does.
    h.container
      ..listen(tutorialControllerProvider(_key), (_, _) {})
      ..listen(handsFreeProvider(_key), (_, _) {});
    // Let the step image chain finish so teardown closes an idle database.
    await waitFor(() {
      final t = h.container.read(tutorialControllerProvider(_key));
      return t.phase == TutorialPhase.ready &&
          t.stepImages.length == t.stepCount &&
          t.stepImages.values.every((i) => i.localPath != null);
    });
  });

  tearDown(() => h.dispose());

  HandsFreeController handsFree() =>
      h.container.read(handsFreeProvider(_key).notifier);
  int currentStep() =>
      h.container.read(tutorialControllerProvider(_key)).currentStep;

  test('reads the step aloud with the mic closed, then listens', () async {
    unawaited(handsFree().enable());
    await waitFor(() => tts.isSpeaking);

    expect(tts.spoken.single, startsWith('Step 1.'));
    expect(voice.micOpen, isFalse, reason: 'Kanz must not hear itself');
    expect(h.container.read(handsFreeProvider(_key)).speaking, isTrue);

    tts.finish();
    await waitFor(() => voice.micOpen);
    expect(h.container.read(handsFreeProvider(_key)).speaking, isFalse);
  });

  test('"next" moves on and reads the new step', () async {
    unawaited(handsFree().enable());
    await waitFor(() => tts.isSpeaking);
    tts.finish();
    await waitFor(() => voice.micOpen);

    voice.say(VoiceCommand.next);
    await waitFor(() => currentStep() == 2 && tts.spoken.length == 2);

    expect(tts.spoken.last, startsWith('Step 2.'));
    expect(
      h.container.read(handsFreeProvider(_key)).lastCommand,
      VoiceCommand.next,
    );
  });

  test('a step change mid-sentence keeps the mic closed until the new step '
      'has been read', () async {
    unawaited(handsFree().enable());
    await waitFor(() => tts.isSpeaking);

    // Tapping "next" while step 1 is still being read interrupts it.
    await h.container.read(tutorialControllerProvider(_key).notifier).next();
    await waitFor(() => tts.spoken.length == 2 && tts.isSpeaking);

    expect(tts.spoken.last, startsWith('Step 2.'));
    expect(voice.micOpen, isFalse);
    expect(voice.resumes, 0, reason: 'the cut-off sentence must not reopen it');
    expect(h.container.read(handsFreeProvider(_key)).speaking, isTrue);

    tts.finish();
    await waitFor(() => voice.micOpen);
    expect(voice.resumes, 1);
  });

  test('disable stops listening and speaking', () async {
    unawaited(handsFree().enable());
    await waitFor(() => tts.isSpeaking);

    await handsFree().disable();

    expect(voice.active, isFalse);
    expect(tts.isSpeaking, isFalse);
    expect(h.container.read(handsFreeProvider(_key)).enabled, isFalse);
  });
}
