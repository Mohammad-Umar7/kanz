// Interaction tests for the Drop-off tab: every control reaches the
// controller (or the link opener) with the right arguments.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/core/services/permission_service.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/core/state/dropoff_controller.dart';
import 'package:kanz/features/dropoff/dropoff_screen.dart';
import 'package:kanz/features/dropoff/external_links.dart';
import 'package:kanz/features/dropoff/place_info.dart';
import 'package:kanz/features/dropoff/places_map.dart';

import '../../core/support/fakes.dart';
import 'dropoff_fixtures.dart';
import 'tab_test_support.dart';

/// The tab's vertical list (the chips scroll sideways).
final _list = find.byWidgetPredicate(
  (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
);

void main() {
  late FakeDropoffController controller;
  late FakePermissions permissions;
  late List<Uri> opened;

  Future<void> pump(
    WidgetTester tester,
    DropoffState state, {
    bool mapAvailable = false,
  }) async {
    controller = FakeDropoffController(state);
    await pumpTab(
      tester,
      overrides: [
        vocabProvider.overrideWithValue(testVocab()),
        dropoffControllerProvider.overrideWith(() => controller),
        permissionServiceProvider.overrideWithValue(permissions),
        externalLinkOpenerProvider.overrideWithValue((uri) async {
          opened.add(uri);
          return true;
        }),
      ],
      child: DropoffScreen(
        mapAvailable: mapAvailable,
        mapBuilder: (context, spec) => const SizedBox.expand(),
      ),
    );
  }

  setUp(() {
    permissions = FakePermissions();
    opened = [];
  });

  testWidgets('shows where it searched and every place', (tester) async {
    await pump(tester, resultsState(ar: false));

    expect(find.text('Near Abu Dhabi'), findsOneWidget);
    // One line when it fits, else one part per line; "15 km" never splits.
    expect(find.textContaining('6 PLACES'), findsOneWidget);
    expect(find.textContaining('WITHIN 15 KM'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Scrap metal yard'),
      200,
      scrollable: _list.first,
    );
    expect(find.text('Scrap metal yard'), findsOneWidget);
    // Attribution the sources require.
    await tester.scrollUntilVisible(
      find.textContaining('© OpenStreetMap contributors'),
      200,
      scrollable: _list.first,
    );
    expect(find.textContaining('© OpenStreetMap contributors'), findsOneWidget);
  });

  testWidgets('a category chip toggles that category', (tester) async {
    await pump(tester, resultsState(ar: false));
    await tester.tap(find.text('Glass recycling'));
    await settle(tester);
    expect(controller.calls, contains('toggleCategory:glass'));
    // The chip order does not jump under the finger.
    final chips = tester.widgetList<KanzChip>(find.byType(KanzChip)).toList();
    expect(chips.first.label, 'Glass recycling');
    expect(chips.first.selected, isFalse);
  });

  testWidgets('Change opens the city list and searches the chosen city', (
    tester,
  ) async {
    await pump(tester, resultsState(ar: false));
    await tester.tap(find.text('Change'));
    await settle(tester);
    expect(find.text('Search near'), findsOneWidget);
    await tester.tap(find.text('Dubai'));
    await settle(tester);
    expect(controller.calls, contains('useCity:dubai'));
  });

  testWidgets('Use my location asks for permission, then searches', (
    tester,
  ) async {
    permissions.location = PermissionState.granted;
    await pump(tester, needsLocationState(ar: false));
    expect(find.text('Find drop-off points near you'), findsOneWidget);
    await tester.tap(find.text('Use my location'));
    await settle(tester);
    expect(controller.calls, contains('useMyLocation'));
  });

  testWidgets('a refused permission explains and offers a city', (
    tester,
  ) async {
    await pump(tester, needsLocationState(ar: false));
    await tester.tap(find.text('Use my location'));
    await settle(tester);
    expect(controller.calls, isNot(contains('useMyLocation')));
    expect(
      find.text('Location wasn\'t allowed. You can choose a city instead.'),
      findsOneWidget,
    );
  });

  testWidgets('blocked location offers Settings and a city', (tester) async {
    permissions.location = PermissionState.permanentlyDenied;
    await pump(tester, needsLocationState(ar: false));
    expect(find.text('Location is off for Kanz'), findsOneWidget);
    expect(find.text('Open settings'), findsOneWidget);
    await tester.tap(find.text('Choose a city'));
    await settle(tester);
    await tester.tap(find.text('Sharjah'));
    await settle(tester);
    expect(controller.calls, contains('useCity:sharjah'));
  });

  testWidgets('a place opens its details with call, website and directions', (
    tester,
  ) async {
    await pump(tester, resultsState(ar: false));
    await tester.tap(find.text('Municipal recycling centre'));
    await settle(tester);

    expect(controller.calls, contains('selectPlace:g:2'));
    expect(find.text('Google Maps'), findsOneWidget);
    expect(find.text('Open now'), findsWidgets);

    await tester.tap(find.widgetWithText(KanzButton, 'Call'));
    await tester.tap(find.widgetWithText(KanzButton, 'Website'));
    await tester.tap(find.widgetWithText(KanzButton, 'Directions'));
    await settle(tester);
    expect(opened.map((u) => u.toString()), [
      'tel:+97120000000',
      'https://example.org',
      'https://www.google.com/maps/search/?api=1&query=24.4402,54.3995',
    ]);

    await tester.tapAt(const Offset(20, 40));
    await settle(tester);
    expect(controller.calls.last, 'selectPlace:null');
  });

  testWidgets('the directions button on a row opens Maps', (tester) async {
    await pump(tester, resultsState(ar: false));
    await tester.tap(
      find.bySemanticsLabel('Directions to Glass collection point'),
    );
    await settle(tester);
    expect(opened.single.toString(), contains('query=24.4612,54.3702'));
  });

  testWidgets('the type filter narrows the list locally', (tester) async {
    await pump(tester, resultsState(ar: false));
    await tester.tap(find.text('All types'));
    await settle(tester);
    await tester.tap(
      find.byWidgetPredicate((w) => w is KanzChip && w.label == 'Scrap metal'),
    );
    await settle(tester);
    expect(controller.calls, contains('toggleType:scrap_metal'));
    await tester.tap(find.text('Done'));
    await settle(tester);
    expect(find.textContaining('1 PLACE'), findsOneWidget);
    expect(find.text('Scrap metal'), findsWidgets);
  });

  testWidgets('a failed search retries', (tester) async {
    await pump(tester, errorState(ar: false, error: placesUnavailable));
    expect(find.text('Drop-off points didn\'t load'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(controller.calls, contains('search'));
  });

  testWidgets('chips that failed to load can be reloaded', (tester) async {
    await pump(tester, catalogErrorState(ar: false));
    expect(find.text('Filters didn\'t load.'), findsOneWidget);
    expect(find.text('Glass collection point'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(controller.calls, contains('loadCatalog'));
  });

  testWidgets('deselecting every material asks for one', (tester) async {
    await pump(tester, oneCategoryState(ar: false));
    await tester.tap(find.text('Glass recycling'));
    await settle(tester);
    expect(find.text('Pick a material'), findsOneWidget);
  });

  testWidgets('before the first search there are loading rows, not a prompt', (
    tester,
  ) async {
    await pump(tester, const DropoffState(catalogLoading: true));
    expect(find.text('Pick a material'), findsNothing);
    expect(find.text('LOOKING FOR DROP-OFF POINTS'), findsOneWidget);
  });

  testWidgets('no places says so and offers another city', (tester) async {
    await pump(tester, emptyState(ar: false));
    expect(find.text('Nothing within 15 km'), findsOneWidget);
    await tester.tap(find.text('Choose another city'));
    await settle(tester);
    expect(find.text('Search near'), findsOneWidget);
  });

  testWidgets('without a map there is no list and map toggle', (tester) async {
    await pump(tester, resultsState(ar: false));
    expect(find.byType(SegmentedTabs), findsNothing);
  });

  testWidgets('with a map the toggle switches to the map view', (tester) async {
    await pump(tester, resultsState(ar: false), mapAvailable: true);
    await tester.tap(find.text('Map'));
    await settle(tester);
    expect(controller.calls, contains('setView:map'));
    expect(find.byType(DraggableScrollableSheet), findsOneWidget);
  });

  testWidgets('the map shows the places it is given', (tester) async {
    PlacesMapSpec? spec;
    controller = FakeDropoffController(
      resultsState(ar: false, view: DropoffView.map),
    );
    await pumpTab(
      tester,
      overrides: [
        vocabProvider.overrideWithValue(testVocab()),
        dropoffControllerProvider.overrideWith(() => controller),
        permissionServiceProvider.overrideWithValue(permissions),
      ],
      child: DropoffScreen(
        mapAvailable: true,
        mapBuilder: (context, s) {
          spec = s;
          return const SizedBox.expand();
        },
      ),
    );
    expect(spec!.places, hasLength(6));
    // A place that lists one material is filled in its color, one that
    // lists several is filled in ink, and one that lists nothing is a
    // ring (in the material's color when it was found for one material).
    expect(
      spec!.pinMarks['osm:node/1'],
      const PinMark(listed: true, materialId: 'glass'),
    );
    expect(spec!.pinMarks['osm:node/3'], const PinMark(listed: true));
    expect(spec!.pinMarks['g:2'], const PinMark(listed: false));
    expect(
      spec!.pinMarks['g:6'],
      const PinMark(listed: false, materialId: 'metal'),
    );
    spec!.onPinTap(spec!.places[1]);
    await settle(tester);
    expect(controller.calls, contains('selectPlace:g:2'));
  });

  testWidgets('Arabic lays out right to left', (tester) async {
    controller = FakeDropoffController(resultsState(ar: true));
    await pumpTab(
      tester,
      locale: const Locale('ar'),
      overrides: [
        vocabProvider.overrideWithValue(testVocab()),
        dropoffControllerProvider.overrideWith(() => controller),
        permissionServiceProvider.overrideWithValue(permissions),
      ],
      child: const DropoffScreen(),
    );
    expect(find.text('بالقرب من أبوظبي'), findsOneWidget);
    final title = tester.getTopRight(find.text('نقاط التسليم'));
    expect(title.dx, closeTo(412 - 20, 1));
  });
}
