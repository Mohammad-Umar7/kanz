import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/core/state/dropoff_controller.dart';
import 'package:kanz/core/state/settings_providers.dart';
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

    test('still searches the default categories when the catalog fails, '
        'and a catalog retry does not search again', () async {
      h = await TestHarness.create(prefs: _cityMode);
      h.api.onCategories = () async => throw const ApiException.offline();
      h.container.read(dropoffControllerProvider);
      await waitFor(() => stateOf().results != null);

      expect(stateOf().catalogError?.code, ApiErrorCode.offline);
      expect(h.api.facilitiesRequests.single.categories, [
        'glass',
        'metal',
        'paper',
        'plastic',
      ]);

      h.api.onCategories = () async => FacilityCategoriesResponse.fromJson(
        fixture('facility_categories.json'),
      );
      await h.container.read(dropoffControllerProvider.notifier).loadCatalog();
      expect(stateOf().catalog, isNotEmpty);
      expect(stateOf().catalogError, isNull);
      expect(h.api.facilitiesRequests, hasLength(1));
    });

    test('a location plugin error ends the search with an error', () async {
      h = await TestHarness.create(prefs: {'settings.location_mode': 'gps'});
      h.permissions.statusError = StateError('permission channel unavailable');
      h.container.read(dropoffControllerProvider);
      await waitFor(() => stateOf().error != null);

      expect(stateOf().searching, isFalse);
      expect(stateOf().error?.retryable, isTrue);
      expect(h.api.facilitiesRequests, isEmpty);
    });

    test('a language switch reloads the chips and the results', () async {
      h = await TestHarness.create(prefs: _cityMode);
      // Listened to, as the Drop-off screen does (unlistened providers pause).
      h.container.listen(dropoffControllerProvider, (_, _) {});
      await waitFor(() => stateOf().results != null);

      await h.container
          .read(settingsProvider.notifier)
          .setLocale(LocalePref.ar);
      await waitFor(() => h.api.facilitiesRequests.length == 2);

      expect(h.api.categoryLangs, [Lang.en, Lang.ar]);
      expect(h.api.facilitiesRequests.last.lang, Lang.ar);
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
