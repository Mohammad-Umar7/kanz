import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/db/database.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/core/services/location_service.dart';
import 'package:kanz/core/services/permission_service.dart';
import 'package:kanz/core/state/location_resolver.dart';
import 'package:kanz/core/state/scan_session.dart';
import 'package:kanz/core/state/settings_providers.dart';

import 'support/fakes.dart';
import 'support/fixtures.dart';

const _cityMode = {
  'settings.location_mode': 'city',
  'settings.city': 'abu_dhabi',
};

final _photo = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);

void main() {
  late TestHarness h;

  tearDown(() => h.dispose());

  ScanSessionState stateOf(String id) =>
      h.container.read(scanSessionProvider(id));

  bool settled(String id) {
    final s = stateOf(id);
    // Images count as settled once they are on the device (or failed).
    return !s.isBusy &&
        s.afterImages.values.every(
          (i) => i.status == ImageStatus.failed || i.localPath != null,
        );
  }

  test(
    'photo scan runs every stage in order and requests three makeovers',
    () async {
      h = await TestHarness.create(prefs: _cityMode);
      final id = newScanId();
      final transitions = <String>[];
      h.container.listen<ScanSessionState>(scanSessionProvider(id), (
        prev,
        next,
      ) {
        for (final stage in PipelineStage.values) {
          final before = prev?.stage(stage).status;
          final after = next.stage(stage).status;
          if (before != after) transitions.add('${stage.name}:${after.name}');
        }
      });

      await h.container
          .read(scanSessionProvider(id).notifier)
          .startFromPhoto(bytes: _photo);
      await waitFor(() => settled(id));

      // Each stage starts only after the one it depends on finished.
      expect(transitions.indexOf('identifying:running'), 0);
      expect(
        transitions.indexOf('identifying:done'),
        lessThan(transitions.indexOf('ideas:running')),
      );
      expect(
        transitions.indexOf('ideas:done'),
        lessThan(transitions.indexOf('dropoff:running')),
      );
      expect(
        transitions.indexOf('ideas:done'),
        lessThan(transitions.indexOf('makeovers:running')),
      );

      final s = stateOf(id);
      for (final stage in PipelineStage.values) {
        expect(s.stage(stage).status, StageStatus.done, reason: stage.name);
      }
      expect(h.api.calls.where((c) => c == 'after'), hasLength(3));
      expect(
        h.api.calls.indexOf('recommend'),
        lessThan(h.api.calls.indexOf('after')),
      );
      expect(
        h.api.afterRequests.map((r) => r.idea.id).toSet(),
        s.ideas.map((i) => i.id).toSet(),
      );
      expect(
        s.afterImages.values.every((i) => i.isReady && i.localPath != null),
        isTrue,
      );
      expect(h.api.facilitiesRequests.single.city, CityId.abuDhabi);
      expect(h.api.facilitiesRequests.single.categories, ['glass', 'metal']);
      expect(s.facilities!.places, hasLength(3));
      expect(s.localImagePath, isNotNull);
    },
  );

  test(
    'a correction marks the item and re-runs recommend, drop-off and images',
    () async {
      h = await TestHarness.create(prefs: _cityMode);
      final id = newScanId();
      final session = h.container.read(scanSessionProvider(id).notifier);
      await session.startFromPhoto(bytes: _photo);
      await waitFor(() => settled(id));

      await session.correctItem(
        'item_1',
        const ItemCorrection(name: 'Glass pasta sauce jar', qualityScore: 5),
      );
      await waitFor(() => settled(id));

      expect(h.api.recommendRequests, hasLength(2));
      final corrected = h.api.recommendRequests.last.analysis.itemById(
        'item_1',
      )!;
      expect(corrected.userCorrected, isTrue);
      expect(corrected.name, 'Glass pasta sauce jar');
      expect(corrected.quality.label, 'Like new');
      expect(h.api.calls.where((c) => c == 'facilities'), hasLength(2));
      // After images are cached per (scan, idea), so re-running recommend with
      // the same ideas reuses them instead of spending image quota again.
      expect(h.api.calls.where((c) => c == 'after'), hasLength(3));
      expect(
        stateOf(id).stage(PipelineStage.makeovers).status,
        StageStatus.done,
      );
    },
  );

  test('disposal-only items request no makeovers', () async {
    h = await TestHarness.create(prefs: _cityMode);
    h.api.onAnalyze = () async =>
        AnalyzeResponse.fromJson(fixture('analyze_battery.json'));
    h.api.onRecommend = () async =>
        RecommendResponse.fromJson(fixture('recommend_battery.json'));
    final id = newScanId();

    await h.container
        .read(scanSessionProvider(id).notifier)
        .startFromPhoto(bytes: _photo);
    await waitFor(() => settled(id));

    final s = stateOf(id);
    expect(s.isDisposalOnly, isTrue);
    expect(s.stage(PipelineStage.makeovers).status, StageStatus.skipped);
    expect(h.api.calls, isNot(contains('after')));
    expect(s.stage(PipelineStage.dropoff).status, StageStatus.done);
  });

  test('an unusable photo fails identifying with the retake tip', () async {
    h = await TestHarness.create(prefs: _cityMode);
    h.api.onAnalyze = () async =>
        AnalyzeResponse.fromJson(fixture('analyze_unclear.json'));
    final id = newScanId();

    await h.container
        .read(scanSessionProvider(id).notifier)
        .startFromPhoto(bytes: _photo);
    await waitFor(() => settled(id));

    final s = stateOf(id);
    expect(s.stage(PipelineStage.identifying).status, StageStatus.failed);
    expect(s.rejectedPhoto?.retakeTip, isNotEmpty);
    expect(h.api.calls, ['analyze']);
  });

  test('an API failure fails only its stage and retry recovers', () async {
    h = await TestHarness.create(prefs: _cityMode);
    var fail = true;
    h.api.onFacilities = () async {
      if (fail) {
        throw const ApiException(
          code: ApiErrorCode.placesUnavailable,
          message: 'down',
          retryable: true,
        );
      }
      return FacilitiesResponse.fromJson(fixture('facilities_glass.json'));
    };
    final id = newScanId();
    final session = h.container.read(scanSessionProvider(id).notifier);

    await session.startFromPhoto(bytes: _photo);
    await waitFor(() => settled(id));
    expect(
      stateOf(id).stage(PipelineStage.dropoff).error?.code,
      ApiErrorCode.placesUnavailable,
    );
    expect(stateOf(id).stage(PipelineStage.makeovers).status, StageStatus.done);

    fail = false;
    await session.retry(PipelineStage.dropoff);
    expect(stateOf(id).stage(PipelineStage.dropoff).status, StageStatus.done);
    expect(h.api.calls.where((c) => c == 'recommend'), hasLength(1));
  });

  test('an unexpected failure ends the stage instead of spinning', () async {
    h = await TestHarness.create(prefs: _cityMode);
    h.api.onRecommend = () async => throw StateError('disk full');
    final id = newScanId();

    await h.container
        .read(scanSessionProvider(id).notifier)
        .startFromPhoto(bytes: _photo);
    await waitFor(() => settled(id));

    final ideas = stateOf(id).stage(PipelineStage.ideas);
    expect(ideas.status, StageStatus.failed);
    expect(ideas.error?.code, ApiErrorCode.internal);
    expect(ideas.error?.retryable, isTrue);
  });

  test(
    'a location plugin error fails drop-off only, and retry recovers',
    () async {
      h = await TestHarness.create(prefs: {'settings.location_mode': 'gps'});
      h.permissions.statusError = StateError('permission channel unavailable');
      final id = newScanId();
      final session = h.container.read(scanSessionProvider(id).notifier);

      await session.startFromPhoto(bytes: _photo);
      await waitFor(() => settled(id));

      final s = stateOf(id);
      expect(s.stage(PipelineStage.ideas).status, StageStatus.done);
      expect(s.stage(PipelineStage.dropoff).status, StageStatus.failed);
      expect(s.stage(PipelineStage.dropoff).error?.retryable, isTrue);
      expect(s.stage(PipelineStage.makeovers).status, StageStatus.done);

      h.permissions
        ..statusError = null
        ..location = PermissionState.granted;
      h.location.fix = LocationFix(
        lat: 24.45,
        lng: 54.38,
        accuracyM: 20,
        timestamp: DateTime.now(),
        isWeak: false,
      );
      await session.retry(PipelineStage.dropoff);
      expect(stateOf(id).stage(PipelineStage.dropoff).status, StageStatus.done);
      expect(h.api.facilitiesRequests.single.lat, 24.45);
      expect(stateOf(id).dropoffLocation?.source, SearchLocationSource.gps);
    },
  );

  test('drop-off waits for a location decision, then resumes', () async {
    h = await TestHarness.create();
    final id = newScanId();
    final session = h.container.read(scanSessionProvider(id).notifier);

    await session.startFromPhoto(bytes: _photo);
    await waitFor(() => settled(id));
    expect(
      stateOf(id).stage(PipelineStage.dropoff).status,
      StageStatus.needsLocation,
    );
    expect(h.api.calls, isNot(contains('facilities')));

    await h.container.read(settingsProvider.notifier).useCity(CityId.dubai);
    await session.resumeDropoff();
    expect(stateOf(id).stage(PipelineStage.dropoff).status, StageStatus.done);
    expect(h.api.facilitiesRequests.single.city, CityId.dubai);
  });

  test('a weak GPS fix falls back to the nearest city', () async {
    h = await TestHarness.create(prefs: {'settings.location_mode': 'gps'});
    h.permissions.location = PermissionState.granted;
    h.location.fix = LocationFix(
      lat: 25.21,
      lng: 55.28,
      accuracyM: 4000,
      timestamp: DateTime.now(),
      isWeak: true,
    );
    final id = newScanId();

    await h.container
        .read(scanSessionProvider(id).notifier)
        .startFromPhoto(bytes: _photo);
    await waitFor(() => settled(id));

    final request = h.api.facilitiesRequests.single;
    expect(request.city, CityId.dubai);
    expect(request.lat, isNull);
  });

  test('a scan reopens from history with its results, offline', () async {
    h = await TestHarness.create(prefs: _cityMode);
    final id = newScanId();
    await h.container
        .read(scanSessionProvider(id).notifier)
        .startFromPhoto(bytes: _photo);
    await waitFor(() => settled(id));
    final db = h.db;
    final dir = h.dir;
    await h.dispose(keepDatabase: true);

    h = await TestHarness.create(prefs: _cityMode, db: db, dir: dir);
    h.container.read(scanSessionProvider(id));
    await waitFor(() => stateOf(id).origin != ScanOrigin.loading);

    final s = stateOf(id);
    expect(s.origin, ScanOrigin.restored);
    expect(s.analysis?.analysis.items, hasLength(2));
    expect(s.ideas, hasLength(3));
    expect(s.facilities?.places, hasLength(3));
    expect(s.afterImages.values.every((i) => i.localPath != null), isTrue);
    for (final stage in PipelineStage.values) {
      expect(s.stage(stage).status, StageStatus.done, reason: stage.name);
    }
    expect(h.api.calls, isEmpty, reason: 'restoring must not call the API');
  });

  test('an unknown scan id is reported missing', () async {
    h = await TestHarness.create();
    h.container.read(scanSessionProvider('nope'));
    await waitFor(() => stateOf('nope').origin != ScanOrigin.loading);
    expect(stateOf('nope').origin, ScanOrigin.missing);
  });

  test('marking items records impact once per item', () async {
    h = await TestHarness.create(prefs: _cityMode);
    final id = newScanId();
    final session = h.container.read(scanSessionProvider(id).notifier);
    await session.startFromPhoto(bytes: _photo);
    await waitFor(() => settled(id));

    await session.markRecycled(['item_1', 'item_2']);
    await session.markRecycled(['item_1']);

    // Stream providers only run while listened to (as a screen would).
    final provider = markedItemsProvider((
      scanId: id,
      kind: ImpactKind.recycled,
    ));
    h.container.listen(provider, (_, _) {});
    final marked = await h.container.read(provider.future);
    expect(marked, {'item_1', 'item_2'});
  });
}
