import '../models/models.dart';

/// Builds the on-device scan summary the Swap Advisor personalizes with
/// ("You scanned 6 plastic bottles this month").
///
/// Counts one per scanned item (not per piece) by material, and the most
/// frequent item names, compared case-insensitively.
HistorySummary buildHistorySummary(
  List<Analysis> analyses, {
  int periodDays = 30,
  int topN = 5,
}) {
  final counts = <MaterialCategory, int>{};
  final names = <String, int>{};

  for (final analysis in analyses) {
    for (final item in analysis.items) {
      counts[item.category] = (counts[item.category] ?? 0) + 1;
      final key = item.name.trim().toLowerCase();
      if (key.isEmpty) continue;
      names[key] = (names[key] ?? 0) + 1;
    }
  }

  final top = names.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount != 0 ? byCount : a.key.compareTo(b.key);
    });
  final picked = top.take(topN).toList();

  return HistorySummary(
    periodDays: periodDays,
    counts: counts,
    topItems: [for (final e in picked) e.key],
    topItemCounts: [for (final e in picked) e.value],
  );
}
