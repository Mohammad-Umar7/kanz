// Contract test: every JSON fixture generated from the Pydantic schemas
// (contracts/fixtures, built by backend/scripts/make_fixtures.py) must parse into
// its Dart model and serialize back to equivalent JSON.
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/models/models.dart';

typedef _Parser = Map<String, dynamic> Function(Map<String, dynamic> json);

/// Fixture file prefix -> parser that returns `model.toJson()`.
/// Longer prefixes win, so `recommend_request_` is matched before `recommend_`.
final Map<String, _Parser> _parsers = {
  'analyze_': (j) => AnalyzeResponse.fromJson(j).toJson(),
  'error_': (j) => ErrorResponse.fromJson(j).toJson(),
  'facilities_': (j) => FacilitiesResponse.fromJson(j).toJson(),
  'facility_categories': (j) => FacilityCategoriesResponse.fromJson(j).toJson(),
  'health': (j) => HealthResponse.fromJson(j).toJson(),
  'image_': (j) => ImageResponse.fromJson(j).toJson(),
  'recommend_request_': (j) => RecommendRequest.fromJson(j).toJson(),
  'recommend_': (j) => RecommendResponse.fromJson(j).toJson(),
  'swaps_request': (j) => SwapsRequest.fromJson(j).toJson(),
  'swaps_': (j) => SwapsResponse.fromJson(j).toJson(),
  'tutorial_request_': (j) => TutorialRequest.fromJson(j).toJson(),
  'tutorial_': (j) => TutorialResponse.fromJson(j).toJson(),
};

_Parser? _parserFor(String fileName) {
  final prefixes = _parsers.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  final prefix = prefixes.firstWhereOrNull(fileName.startsWith);
  return prefix == null ? null : _parsers[prefix];
}

/// Normalizes through a JSON encode/decode so enums, maps and numbers compare
/// the way they appear on the wire.
Object? _wire(Object? value) => jsonDecode(jsonEncode(value));

void main() {
  final dir = Directory('../contracts/fixtures');
  final fixtures =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  test('fixtures directory is present and not empty', () {
    expect(
      dir.existsSync(),
      isTrue,
      reason: 'run tests from the app/ directory',
    );
    expect(fixtures, isNotEmpty);
  });

  for (final file in fixtures) {
    final name = file.uri.pathSegments.last;
    test('$name parses and round-trips', () {
      final parse = _parserFor(name);
      expect(
        parse,
        isNotNull,
        reason: 'no Dart model is mapped to fixture $name',
      );
      final original =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final roundTrip = _wire(parse!(original));
      expect(
        const DeepCollectionEquality().equals(roundTrip, original),
        isTrue,
        reason:
            'toJson() of $name differs from the fixture:\n${jsonEncode(roundTrip)}',
      );
    });
  }

  group('model helpers', () {
    Map<String, dynamic> load(String name) =>
        jsonDecode(File('../contracts/fixtures/$name').readAsStringSync())
            as Map<String, dynamic>;

    test('battery analysis is disposal-only', () {
      final res = AnalyzeResponse.fromJson(load('analyze_battery.json'));
      expect(res.analysis.items.every((i) => i.isDisposalOnly), isTrue);
    });

    test('primary item falls back to the first item', () {
      final res = AnalyzeResponse.fromJson(load('analyze_glass_jar.json'));
      expect(res.analysis.primaryItem?.id, 'item_1');
      expect(
        res.analysis.copyWith(primaryItemId: null).primaryItem?.id,
        'item_1',
      );
    });

    test('unclear photo is flagged as unusable with a tip', () {
      final res = AnalyzeResponse.fromJson(load('analyze_unclear.json'));
      expect(res.analysis.photo.usable, isFalse);
      expect(res.analysis.photo.retakeTip, isNotEmpty);
    });

    test('recommend for glass jar has three ideas', () {
      final res = RecommendResponse.fromJson(load('recommend_glass_jar.json'));
      expect(res.upcycle, hasLength(3));
      expect(res.ideaById('idea_9f2c41aa')?.title, 'Hanging jar lantern');
    });

    test('safety gear is not counted as a tool', () {
      expect(ToolId.gloves.isSafetyGear, isTrue);
      expect(ToolId.drill.isSafetyGear, isFalse);
    });
  });
}
