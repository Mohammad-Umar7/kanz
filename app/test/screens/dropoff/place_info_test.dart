// The pure helpers behind the Drop-off tab: how a place is marked on the
// plot and the map, how lists read in each language, and what support sees.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/features/dropoff/place_info.dart';
import 'package:kanz/l10n/l10n.dart';

import 'dropoff_fixtures.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  group('pinMarkOf', () {
    final catalog = {for (final c in catalogFor(ar: false)) c.key: c};
    final places = {for (final p in mixedResults(ar: false).places) p.id: p};

    test('one listed material fills the dot in its color', () {
      expect(
        pinMarkOf(places['osm:node/1']!, catalog),
        const PinMark(listed: true, materialId: 'glass'),
      );
    });

    test('several listed materials fill it in ink', () {
      expect(
        pinMarkOf(places['osm:node/3']!, catalog),
        const PinMark(listed: true),
      );
    });

    test('nothing listed draws a ring, colored when found for one', () {
      expect(pinMarkOf(places['g:2']!, catalog), const PinMark(listed: false));
      expect(
        pinMarkOf(places['g:6']!, catalog),
        const PinMark(listed: false, materialId: 'metal'),
      );
      // Without the chip catalog, category keys that name a material still
      // count.
      expect(
        pinMarkOf(places['g:6']!, const {}),
        const PinMark(listed: false, materialId: 'metal'),
      );
    });

    test('the real OpenStreetMap answer is mostly rings', () {
      final marks = [
        for (final p in osmDubai(ar: false).places) pinMarkOf(p, catalog),
      ];
      expect(marks.where((m) => !m.listed), hasLength(9));
      expect(marks.where((m) => m.listed), hasLength(3));
    });
  });

  group('formatList', () {
    test('uses each language\'s comma', () {
      expect(
        formatList(en, ['Recycling center', 'E-waste']),
        'Recycling center, E-waste',
      );
      expect(
        formatList(ar, ['مركز إعادة تدوير', 'نفايات إلكترونية']),
        'مركز إعادة تدوير، نفايات إلكترونية',
      );
    });

    test('joins the last item as a sentence reads it', () {
      expect(formatList(en, ['glass'], sentence: true), 'glass');
      expect(
        formatList(en, ['glass', 'paper'], sentence: true),
        'glass and paper',
      );
      expect(
        formatList(en, ['glass', 'paper', 'metal'], sentence: true),
        'glass, paper and metal',
      );
      expect(
        formatList(ar, ['الزجاج', 'الورق'], sentence: true),
        'الزجاج والورق',
      );
      expect(
        formatList(ar, ['الزجاج', 'الورق', 'المعادن'], sentence: true),
        'الزجاج، الورق، والمعادن',
      );
    });

    test('skips empty entries', () {
      expect(formatList(en, ['glass', ' ', 'paper']), 'glass, paper');
    });
  });

  group('supportCode', () {
    test('shows the request id, with the wire code in debug builds', () {
      expect(
        supportCode(placesUnavailable),
        'places_unavailable · req_85b6e682',
      );
    });

    test('is empty when there is nothing to look up', () {
      expect(supportCode(const ApiException.offline()), isNull);
    });
  });
}
