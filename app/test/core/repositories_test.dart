import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/db/database.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/data/repositories/image_cache_repository.dart';
import 'package:kanz/core/data/repositories/impact_repository.dart';
import 'package:kanz/core/data/repositories/project_repository.dart';
import 'package:kanz/core/data/repositories/scan_repository.dart';

import 'support/fixtures.dart';
import 'support/test_db.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  final analysis = AnalyzeResponse.fromJson(fixture('analyze_glass_jar.json'));
  final recommendation = RecommendResponse.fromJson(
    fixture('recommend_glass_jar.json'),
  );
  final tutorial = TutorialResponse.fromJson(
    fixture('tutorial_jar_lantern.json'),
  ).tutorial;

  group('ScanRepository', () {
    test('stores every stage and reopens the full results', () async {
      final repo = ScanRepository(db);
      await repo.create(
        id: 's1',
        source: AnalysisSource.image,
        lang: Lang.en,
        localImagePath: '/photos/s1.jpg',
      );
      await repo.saveAnalysis('s1', analysis);
      await repo.saveRecommendation('s1', recommendation);
      await repo.saveStages('s1', {'identifying': 'done', 'ideas': 'done'});

      final stored = await repo.get('s1');
      expect(stored!.analysis, analysis);
      expect(stored.recommendation, recommendation);
      expect(stored.stages['ideas'], 'done');

      final list = await repo.watchAll().first;
      expect(list.single.title, 'Glass jam jar');
      expect(list.single.primaryCategory, MaterialCategory.glass);
      expect(list.single.itemCount, 2);
      expect(list.single.hasRecommendation, isTrue);
    });

    test(
      'a corrupt stored response decodes to null instead of throwing',
      () async {
        final repo = ScanRepository(db);
        await repo.create(id: 's2', source: AnalysisSource.text, lang: Lang.en);
        await db.customStatement(
          "UPDATE scans SET analysis_json = '{\"broken\": true}' WHERE id = 's2'",
        );
        final stored = await repo.get('s2');
        expect(stored, isNotNull);
        expect(stored!.analysis, isNull);
      },
    );
  });

  group('ProjectRepository', () {
    test('creates once per idea and tracks step progress', () async {
      await ScanRepository(
        db,
      ).create(id: 's1', source: AnalysisSource.image, lang: Lang.en);
      final repo = ProjectRepository(db);
      final idea = recommendation.upcycle.first;

      final a = await repo.getOrCreate(scanId: 's1', idea: idea);
      final b = await repo.getOrCreate(scanId: 's1', idea: idea);
      expect(b.id, a.id);

      await repo.saveTutorial(a.id, tutorial, tools: [ToolId.pliers]);
      await repo.setStepDone(a.id, 1);
      await repo.setStepDone(a.id, 2);
      await repo.setStepDone(a.id, 2, done: false);
      await repo.setCurrentStep(a.id, 2);

      final p = (await repo.get(a.id))!;
      expect(p.totalSteps, 5);
      expect(p.completedSteps, {1});
      expect(p.currentStep, 2);
      expect(p.tools, [ToolId.pliers]);
      expect(p.progress, closeTo(0.2, 1e-9));

      // An adapted tutorial has different steps, so progress restarts.
      await repo.saveTutorial(
        a.id,
        tutorial.copyWith(tutorialId: 'tut_other'),
        tools: const [],
      );
      final adapted = (await repo.get(a.id))!;
      expect(adapted.completedSteps, isEmpty);
      expect(adapted.currentStep, 1);

      await repo.complete(a.id);
      expect((await repo.get(a.id))!.isCompleted, isTrue);
    });
  });

  group('ImpactRepository', () {
    test('marking the same item twice counts once', () async {
      final repo = ImpactRepository(db);
      final item = analysis.analysis.items.first;
      await repo.record(kind: ImpactKind.recycled, item: item, scanId: 's1');
      await repo.record(kind: ImpactKind.recycled, item: item, scanId: 's1');
      await repo.record(kind: ImpactKind.donated, item: item, scanId: 's1');

      final events = await repo.all();
      expect(events, hasLength(2));
      expect(await repo.watchMarked('s1', ImpactKind.recycled).first, {
        'item_1',
      });
    });
  });

  group('ImageCacheRepository', () {
    test('downloads once, then serves the local file', () async {
      final dir = await Directory.systemTemp.createTemp('kanz_img');
      addTearDown(() => dir.delete(recursive: true));
      var downloads = 0;
      final repo = ImageCacheRepository(
        db: db,
        directory: dir,
        download: (url) async {
          downloads++;
          return Uint8List.fromList([1, 2, 3]);
        },
      );
      final image = ImageResponse.fromJson(fixture('image_after.json'));

      final first = await repo.store(
        image,
        scanId: 's1',
        ideaId: 'idea_9f2c41aa',
      );
      final second = await repo.store(
        image,
        scanId: 's1',
        ideaId: 'idea_9f2c41aa',
      );
      expect(downloads, 1);
      expect(second.localPath, first.localPath);
      expect(File(first.localPath).readAsBytesSync(), [1, 2, 3]);
      expect(
        (await repo.afterImage('s1', 'idea_9f2c41aa'))?.localPath,
        first.localPath,
      );

      final regenerated = await repo.store(
        image,
        scanId: 's1',
        ideaId: 'idea_9f2c41aa',
        force: true,
      );
      expect(downloads, 2);
      expect(File(first.localPath).existsSync(), isFalse);
      expect(File(regenerated.localPath).existsSync(), isTrue);
    });
  });
}
