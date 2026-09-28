import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/core/state/dropoff_controller.dart';
import 'package:kanz/core/state/swaps_controller.dart';

import 'support/fakes.dart';
import 'support/fixtures.dart';

const _cityMode = {
  'settings.location_mode': 'city',
  'settings.city': 'sharjah',
};

void main() {
  late TestHarness h;

  tearDown(() => h.dispose());

  group('DropoffController', () {
    DropoffState stateOf() => h.container.read(dropoffControllerProvider);

    test(
      'starts with general categories and searches around the city',
      () async {
        h = await TestHarness.create(prefs: _cityMode);
        h.container.read(dropoffControllerProvider);
        await waitFor(() => stateOf().results != null);

        expect(stateOf().catalog, isNotEmpty);
        expect(stateOf().selectedCategories, {
          'glass',
          'plastic',
          'paper',
          'metal',
        });
        final request = h.api.facilitiesRequests.single;
        expect(request.city, CityId.sharjah);
        expect(request.categories, ['glass', 'metal', 'paper', 'plastic']);
      },
    );

    test('prefers the latest scan categories', () async {
      h = await TestHarness.create(prefs: _cityMode);
      final scans = h.container.read(scanRepositoryProvider);
      await scans.create(id: 's', source: AnalysisSource.image, lang: Lang.en);
      await scans.saveRecommendation(
        's',
        RecommendResponse.fromJson(fixture('recommend_battery.json')),
      );
      h.container.read(dropoffControllerProvider);
      await waitFor(() => stateOf().results != null);

      expect(stateOf().selectedCategories, {
        for (final c in RecommendResponse.fromJson(
          fixture('recommend_battery.json'),
        ).facilityCategories)
          c.key,
      });
    });

    test('filters places by facility type without a new search', () async {
      h = await TestHarness.create(prefs: _cityMode);
      h.container.read(dropoffControllerProvider);
      await waitFor(() => stateOf().results != null);

      h.container
          .read(dropoffControllerProvider.notifier)
          .toggleType(FacilityType.recyclingCenter);

      expect(stateOf().visiblePlaces.map((p) => p.id), ['g:FIXTURE_PLACE_B']);
      expect(h.api.facilitiesRequests, hasLength(1));
    });

    test('asks for a location when none was chosen', () async {
      h = await TestHarness.create();
      h.container.read(dropoffControllerProvider);
      await waitFor(() => stateOf().needsLocation);
      expect(h.api.facilitiesRequests, isEmpty);

      await h.container
          .read(dropoffControllerProvider.notifier)
          .useCity(CityId.ajman);
      expect(stateOf().needsLocation, isFalse);
      expect(h.api.facilitiesRequests.single.city, CityId.ajman);
    });
  });

  group('SwapsController', () {
    test('sends chips, free text and the scan history', () async {
      h = await TestHarness.create();
      final scans = h.container.read(scanRepositoryProvider);
      await scans.create(id: 's', source: AnalysisSource.image, lang: Lang.en);
      await scans.saveAnalysis(
        's',
        AnalyzeResponse.fromJson(fixture('analyze_glass_jar.json')),
      );
      final swaps = h.container.read(swapsControllerProvider.notifier)
        ..toggleChip('plastic')
        ..setFreeText('cling film، paper cups');

      await swaps.submit();

      final state = h.container.read(swapsControllerProvider);
      expect(state.requestMaterials, ['plastic', 'cling film', 'paper cups']);
      expect(state.history?.counts[MaterialCategory.glass], 1);
      expect(state.results?.swaps, isNotEmpty);
      expect(h.api.calls, ['swaps']);
    });

    test('does nothing without input or history', () async {
      h = await TestHarness.create();
      await h.container.read(swapsControllerProvider.notifier).submit();
      expect(h.api.calls, isEmpty);
    });
  });
}
