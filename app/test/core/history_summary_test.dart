import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/insights/history_summary.dart';
import 'package:kanz/core/data/models/models.dart';

import 'support/fixtures.dart';

void main() {
  final jar = AnalyzeResponse.fromJson(
    fixture('analyze_glass_jar.json'),
  ).analysis;
  final shirt = AnalyzeResponse.fromJson(
    fixture('analyze_tshirt.json'),
  ).analysis;
  final caps = AnalyzeResponse.fromJson(
    fixture('analyze_text_caps.json'),
  ).analysis;

  test('counts scanned items per material over the period', () {
    final summary = buildHistorySummary([jar, jar, shirt]);

    expect(summary.periodDays, 30);
    expect(summary.counts[MaterialCategory.glass], 2);
    expect(summary.counts[MaterialCategory.metal], 2);
    expect(summary.counts[MaterialCategory.textile], shirt.items.length);
  });

  test('ranks the most frequent item names, case-insensitively', () {
    final upper = jar.copyWith(
      items: [jar.items.first.copyWith(name: 'GLASS JAM JAR')],
    );
    final summary = buildHistorySummary([jar, upper, caps], topN: 2);

    expect(summary.topItems.first, 'glass jam jar');
    expect(summary.topItemCounts.first, 2);
    expect(summary.topItems, hasLength(2));
    expect(summary.topItemCounts, hasLength(summary.topItems.length));
  });

  test('empty history gives an empty summary', () {
    final summary = buildHistorySummary(const []);
    expect(summary.isEmpty, isTrue);
  });

  test('the summary matches the swaps request contract', () {
    final json = SwapsRequest(
      materials: const ['plastic bags'],
      history: buildHistorySummary([jar]),
    ).toJson();
    final history = json['history'] as Map<String, dynamic>;
    expect(history['counts'], {'glass': 1, 'metal': 1});
    expect(history['period_days'], 30);
  });
}
