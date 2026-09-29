// The pure helpers behind the Drop-off tab: how a place is marked on the
// plot and the map, and how lists read in each language.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/features/dropoff/place_info.dart';
import 'package:kanz/l10n/l10n.dart';

import 'dropoff_fixtures.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  group('pinMarkOf', () {
    final catalog = {for (final c in catalogFor(ar: false)) c.key: c};
    final places = {for (final p in mixedResults(ar: false).places) p.id: p};
    final general = selectedMaterialIds(const [
      'glass',
      'plastic',
      'paper',
      'metal',
    ], catalog);

    test('the selected chips name their materials', () {
      expect(general, {'glass', 'plastic', 'paper', 'metal'});
      // Without the chip catalog, keys that name a material still count.
      expect(selectedMaterialIds(const ['glass', 'nope'], const {}), {'glass'});
    });

    test('one listed material fills the dot in its color', () {
      expect(
        pinMarkOf(places['osm:node/1']!, catalog, selected: general),
        const PinMark(listed: true, materialIds: ['glass']),
      );
    });

    test('several matching materials split the dot, never ink', () {
      expect(
        pinMarkOf(places['osm:node/3']!, catalog, selected: general),
        const PinMark(listed: true, materialIds: ['glass', 'plastic']),
      );
      expect(
        pinMarkOf(places['osm:node/5']!, catalog, selected: general),
        const PinMark(listed: true, materialIds: ['metal', 'plastic']),
      );
    });

    test('only the materials the user picked color a listed dot', () {
      expect(
        pinMarkOf(places['osm:node/3']!, catalog, selected: const {'paper'}),
        const PinMark(listed: true, materialIds: ['paper']),
      );
      // None of them picked: the listing's first material.
      expect(
        pinMarkOf(places['osm:node/5']!, catalog, selected: const {'glass'}),
        const PinMark(listed: true, materialIds: ['metal']),
      );
    });

    test('nothing listed draws a ring, colored when found for one', () {
      expect(pinMarkOf(places['g:2']!, catalog), const PinMark(listed: false));
      expect(
        pinMarkOf(places['g:6']!, catalog),
        const PinMark(listed: false, materialIds: ['metal']),
      );
      // Without the chip catalog, category keys that name a material still
      // count.
      expect(
        pinMarkOf(places['g:6']!, const {}),
        const PinMark(listed: false, materialIds: ['metal']),
      );
    });

    test('the key shows the nearest listed place\'s own mark', () {
      final list = mixedResults(ar: false).places;
      final marks = {
        for (final p in list) p.id: pinMarkOf(p, catalog, selected: general),
      };
      expect(
        keyListedMark(list, marks),
        const PinMark(listed: true, materialIds: ['glass']),
      );
      expect(keyListedMark([places['g:2']!], marks), isNull);
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
}
