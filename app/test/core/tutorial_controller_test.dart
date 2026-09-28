import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/db/database.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/core/state/tutorial_controller.dart';

import 'support/fakes.dart';
import 'support/fixtures.dart';

const _scanId = 'scan_1';
const _ideaId = 'idea_9f2c41aa';
const TutorialKey _key = (scanId: _scanId, ideaId: _ideaId);

final _tutorial = TutorialResponse.fromJson(
  fixture('tutorial_jar_lantern.json'),
);

Future<void> _seedScan(TestHarness h) async {
  final scans = h.container.read(scanRepositoryProvider);
  await scans.create(id: _scanId, source: AnalysisSource.image, lang: Lang.en);
  await scans.saveAnalysis(
    _scanId,
    AnalyzeResponse.fromJson(fixture('analyze_glass_jar.json')),
  );
  await scans.saveRecommendation(
    _scanId,
    RecommendResponse.fromJson(fixture('recommend_glass_jar.json')),
  );
}

void main() {
  late TestHarness h;

  tearDown(() => h.dispose());

  TutorialState stateOf() => h.container.read(tutorialControllerProvider(_key));
  TutorialController controller() =>
      h.container.read(tutorialControllerProvider(_key).notifier);

  bool imagesSettled() {
    final s = stateOf();
    return s.phase != TutorialPhase.loading &&
        s.stepImages.values.every(
          (i) => i.status == ImageStatus.failed || i.localPath != null,
        ) &&
        !s.adapting;
  }

  test(
    'loads the tutorial for the profile and fetches step images one at a time',
    () async {
      h = await TestHarness.create(
        prefs: {
          'settings.skill': 'beginner',
          'settings.tools': ['scissors', 'pliers', 'twine'],
        },
      );
      await _seedScan(h);
      var inFlight = 0;
      var maxInFlight = 0;
      final defaultStep = h.api.onStep;
      h.api.onStep = (req) async {
        inFlight++;
        maxInFlight = inFlight > maxInFlight ? inFlight : maxInFlight;
        await Future<void>.delayed(const Duration(milliseconds: 5));
        inFlight--;
        return defaultStep(req);
      };

      controller();
      await waitFor(() => stateOf().phase == TutorialPhase.ready);
      await waitFor(() => stateOf().stepImages.length == 5 && imagesSettled());

      final request = h.api.tutorialRequests.single;
      expect(request.profile.skill, SkillLevel.beginner);
      expect(request.profile.tools, [
        ToolId.scissors,
        ToolId.pliers,
        ToolId.twine,
      ]);
      expect(request.items.map((i) => i.id), ['item_1']);
      expect(h.api.calls.where((c) => c.startsWith('step:')), [
        'step:1',
        'step:2',
        'step:3',
        'step:4',
        'step:5',
      ]);
      expect(maxInFlight, 1, reason: 'each step image edits the previous one');
      expect(stateOf().stepImages.values.every((i) => i.isReady), isTrue);
      expect(stateOf().project, isNotNull);
    },
  );

  test(
    'adapt refetches for the new skill and tools and exposes the note',
    () async {
      h = await TestHarness.create();
      await _seedScan(h);
      h.api.onTutorial = (req) async => req.profile.skill == SkillLevel.advanced
          ? _tutorial.copyWith(
              tutorial: _tutorial.tutorial.copyWith(
                tutorialId: 'tut_advanced',
                skill: SkillLevel.advanced,
                adaptedNote: 'Adapted for Advanced: drill the lid for hanging.',
              ),
            )
          : _tutorial;

      controller();
      await waitFor(
        () => stateOf().phase == TutorialPhase.ready && imagesSettled(),
      );
      await controller().markStepDone(1);

      await controller().adapt(
        skill: SkillLevel.advanced,
        tools: const [ToolId.drill],
      );
      await waitFor(imagesSettled);

      final s = stateOf();
      expect(h.api.tutorialRequests, hasLength(2));
      expect(h.api.tutorialRequests.last.profile.tools, [ToolId.drill]);
      expect(s.tutorial?.tutorialId, 'tut_advanced');
      expect(s.adaptedNote, startsWith('Adapted for Advanced'));
      expect(s.skill, SkillLevel.advanced);
      expect(s.completedSteps, isEmpty, reason: 'new steps restart progress');
      expect(
        h.api.stepRequests.where((r) => r.tutorialId == 'tut_advanced'),
        hasLength(5),
      );
    },
  );

  test(
    'a failed adapt keeps the current tutorial and reports the error',
    () async {
      h = await TestHarness.create();
      await _seedScan(h);
      controller();
      await waitFor(
        () => stateOf().phase == TutorialPhase.ready && imagesSettled(),
      );
      h.api.onTutorial = (req) async => throw const ApiException.timeout();

      await controller().adapt(skill: SkillLevel.advanced, tools: const []);

      expect(stateOf().adaptError?.code, ApiErrorCode.timeout);
      expect(stateOf().tutorial?.tutorialId, _tutorial.tutorial.tutorialId);
      expect(stateOf().adapting, isFalse);
    },
  );

  test('step progress is persisted and the tutorial reopens offline', () async {
    h = await TestHarness.create();
    await _seedScan(h);
    controller();
    await waitFor(
      () => stateOf().phase == TutorialPhase.ready && imagesSettled(),
    );
    await controller().markStepDone(1);
    await controller().markStepDone(2);
    await controller().goToStep(3);
    final db = h.db;
    final dir = h.dir;
    await h.dispose(keepDatabase: true);

    h = await TestHarness.create(db: db, dir: dir);
    controller();
    await waitFor(
      () => stateOf().phase == TutorialPhase.ready && imagesSettled(),
    );

    expect(stateOf().completedSteps, {1, 2});
    expect(stateOf().currentStep, 3);
    expect(
      stateOf().stepImages.values.every((i) => i.localPath != null),
      isTrue,
    );
    expect(
      h.api.calls,
      isEmpty,
      reason: 'tutorial and images come from the device',
    );
  });

  test(
    'the chain stops at a failed step and resumes after regenerate',
    () async {
      h = await TestHarness.create();
      await _seedScan(h);
      var quota = true;
      final defaultStep = h.api.onStep;
      h.api.onStep = (req) async {
        if (req.step == 2 && quota) {
          throw const ApiException(
            code: ApiErrorCode.aiQuotaExhausted,
            message: 'limit: 0',
            retryable: false,
          );
        }
        return defaultStep(req);
      };

      controller();
      await waitFor(() => stateOf().phase == TutorialPhase.ready);
      await waitFor(() => stateOf().stepImage(2).status == ImageStatus.failed);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(stateOf().stepImage(2).error?.isQuotaExhausted, isTrue);
      expect(stateOf().stepImage(3).status, ImageStatus.idle);
      expect(h.api.calls.where((c) => c.startsWith('step:')), [
        'step:1',
        'step:2',
      ]);

      quota = false;
      await controller().regenerateStep(2);
      await waitFor(() => stateOf().stepImage(5).isReady && imagesSettled());
      expect(
        h.api.stepRequests.firstWhere((r) => r.step == 2 && r.regenerate),
        isNotNull,
      );
    },
  );

  test('complete saves the project and records the upcycled item', () async {
    h = await TestHarness.create();
    await _seedScan(h);
    controller();
    await waitFor(
      () => stateOf().phase == TutorialPhase.ready && imagesSettled(),
    );

    final projectId = await controller().complete();

    expect(projectId, stateOf().project?.id);
    expect(stateOf().completed, isTrue);
    expect(stateOf().project?.isCompleted, isTrue);
    final events = await h.container.read(impactRepositoryProvider).all();
    expect(events.single.kind, ImpactKind.upcycled);
    expect(events.single.itemId, 'item_1');
  });

  test('an idea that is not in the scan fails with not found', () async {
    h = await TestHarness.create();
    await _seedScan(h);
    const missing = (scanId: _scanId, ideaId: 'idea_missing');
    h.container.read(tutorialControllerProvider(missing));
    await waitFor(
      () =>
          h.container.read(tutorialControllerProvider(missing)).phase !=
          TutorialPhase.loading,
    );
    expect(
      h.container.read(tutorialControllerProvider(missing)).error?.code,
      ApiErrorCode.notFound,
    );
  });
}
