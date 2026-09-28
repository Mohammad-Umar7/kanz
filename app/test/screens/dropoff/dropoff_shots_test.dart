// Renders every Drop-off state at 360 and 412 dp, light and dark, English
// and Arabic (plus 130 % text for the results) into test/screenshots/_out/.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/core/services/permission_service.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/core/state/dropoff_controller.dart';
import 'package:kanz/core/state/location_resolver.dart';
import 'package:kanz/features/dropoff/dropoff_screen.dart';
import 'package:kanz/features/dropoff/external_links.dart';
import 'package:kanz/features/dropoff/places_map.dart';
import 'package:kanz/features/dropoff/places_plot.dart';
import 'package:kanz/l10n/l10n.dart';

import '../../core/support/fakes.dart';
import '../../screenshots/harness.dart';
import 'dropoff_fixtures.dart';
import 'tab_test_support.dart';

/// A drawn stand-in for the Google map (platform views do not render in
/// tests), so the map layout and its sheet can be reviewed.
Widget _fakeMap(BuildContext context, PlacesMapSpec spec) => ColoredBox(
  color: context.kanzColors.surfaceSunken,
  child: Padding(
    padding: EdgeInsets.only(bottom: spec.bottomPadding),
    child: PlacesPlot(
      center: spec.center,
      places: spec.places,
      pinMaterials: spec.pinMaterials,
      selectedId: spec.selectedId,
      northLabel: 'N',
      semanticsLabel: spec.semanticsLabel,
    ),
  ),
);

Future<void> _shot(
  WidgetTester tester, {
  required String name,
  required ShotConfig config,
  required DropoffState Function(bool ar) state,
  PermissionState permission = PermissionState.denied,
  bool mapAvailable = false,
}) async {
  final permissions = FakePermissions()..location = permission;
  await takeShot(
    tester,
    name: name,
    config: config,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    wrap: (app) => withCaptureBoundary(
      ProviderScope(
        overrides: [
          vocabProvider.overrideWithValue(testVocab()),
          dropoffControllerProvider.overrideWith(
            () => FakeDropoffController(state(config.isArabic)),
          ),
          permissionServiceProvider.overrideWithValue(permissions),
          externalLinkOpenerProvider.overrideWithValue((uri) async => true),
        ],
        child: app,
      ),
    ),
    child: inShell(
      DropoffScreen(mapAvailable: mapAvailable, mapBuilder: _fakeMap),
      tab: 1,
      arabic: config.isArabic,
    ),
  );
}

void main() {
  setUpAll(loadKanzFonts);

  for (final config in contentConfigs) {
    testWidgets('dropoff results ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'dropoff_results',
        config: config,
        state: (ar) => resultsState(ar: ar),
      );
    });
  }

  for (final config in stateConfigs) {
    testWidgets('dropoff real osm ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'dropoff_osm',
        config: config,
        state: (ar) => resultsState(
          ar: ar,
          results: osmDubai(ar: ar),
          location: const SearchLocation.city(CityId.dubai),
        ),
      );
    });

    testWidgets('dropoff searching ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'dropoff_searching',
        config: config,
        state: (ar) => searchingState(ar: ar),
      );
    });

    testWidgets('dropoff needs location ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'dropoff_needs_location',
        config: config,
        state: (ar) => needsLocationState(ar: ar),
      );
    });

    testWidgets('dropoff empty ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'dropoff_empty',
        config: config,
        state: (ar) => emptyState(ar: ar),
      );
    });

    testWidgets('dropoff error ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'dropoff_error',
        config: config,
        state: (ar) => errorState(ar: ar, error: placesUnavailable),
      );
    });

    testWidgets('dropoff map ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'dropoff_map',
        config: config,
        mapAvailable: true,
        state: (ar) => resultsState(ar: ar, view: DropoffView.map),
      );
    });

    testWidgets('dropoff details ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'dropoff_base',
        config: config,
        state: (ar) => resultsState(ar: ar),
      );
      await tester.tap(
        find.text(
          config.isArabic
              ? 'مركز إعادة التدوير البلدي'
              : 'Municipal recycling centre',
        ),
      );
      await captureAgain(tester, name: 'dropoff_details', config: config);
    });
  }

  for (final config in compactConfigs) {
    testWidgets('dropoff location blocked ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'dropoff_location_blocked',
        config: config,
        permission: PermissionState.permanentlyDenied,
        state: (ar) => needsLocationState(ar: ar),
      );
    });

    testWidgets('dropoff offline ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'dropoff_offline',
        config: config,
        state: (ar) => errorState(ar: ar, error: const ApiException.offline()),
      );
    });

    testWidgets('dropoff no category ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'dropoff_no_category',
        config: config,
        state: (ar) => noCategoryState(ar: ar),
      );
    });

    testWidgets('dropoff type filtered empty ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'dropoff_type_empty',
        config: config,
        state: (ar) =>
            resultsState(ar: ar, typeFilter: const {FacilityType.eWaste}),
      );
    });

    testWidgets('dropoff catalog error ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'dropoff_catalog_error',
        config: config,
        state: (ar) => catalogErrorState(ar: ar),
      );
    });

    testWidgets('dropoff refreshing ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'dropoff_refreshing',
        config: config,
        state: (ar) => resultsState(ar: ar, searching: true),
      );
    });

    testWidgets('dropoff sheets ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'dropoff_base',
        config: config,
        state: (ar) => resultsState(ar: ar),
      );
      await tester.tap(find.text(config.isArabic ? 'تغيير' : 'Change'));
      await captureAgain(
        tester,
        name: 'dropoff_location_sheet',
        config: config,
      );
      await tester.tapAt(const Offset(20, 60));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text(config.isArabic ? 'كل الأنواع' : 'All types'));
      await captureAgain(tester, name: 'dropoff_type_sheet', config: config);
    });
  }
}
