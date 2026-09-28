/// Impact tab numbers computed from local history.
///
/// Item counts and streaks are facts from the user's own actions. The CO2e
/// figure is an estimate from `assets/config/impact_factors.json`; it is always
/// returned together with the file's disclaimer and must be shown as an
/// estimate, never as a measured saving.
library;

import 'dart:convert';

import 'package:flutter/services.dart';

import '../db/database.dart';
import '../models/vocab_enums.dart';
import '../repositories/project_repository.dart';

class MaterialFactor {
  const MaterialFactor({
    required this.kgCo2ePerKg,
    required this.typicalItemKg,
    required this.note,
  });

  final double kgCo2ePerKg;

  /// Mass assumed for one piece when the analysis counted pieces, not weight.
  final double typicalItemKg;
  final String note;
}

/// Per-material estimate factors (see the file's `_comment`).
class ImpactFactors {
  const ImpactFactors({required this.disclaimer, required this.materials});

  factory ImpactFactors.fromJson(Map<String, dynamic> json) {
    final materials = <MaterialCategory, MaterialFactor>{};
    final raw = json['materials'] as Map<String, dynamic>;
    for (final entry in raw.entries) {
      final category = MaterialCategory.tryFromId(entry.key);
      if (category == null) continue;
      final m = entry.value as Map<String, dynamic>;
      materials[category] = MaterialFactor(
        kgCo2ePerKg: (m['kg_co2e_per_kg'] as num).toDouble(),
        typicalItemKg: (m['typical_item_kg'] as num).toDouble(),
        note: m['note'] as String,
      );
    }
    return ImpactFactors(
      disclaimer: json['disclaimer'] as String,
      materials: materials,
    );
  }

  static const assetPath = 'assets/config/impact_factors.json';

  static Future<ImpactFactors> load({AssetBundle? bundle}) async {
    final raw = await (bundle ?? rootBundle).loadString(assetPath);
    return ImpactFactors.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// "Estimate, verify before quoting."
  final String disclaimer;
  final Map<MaterialCategory, MaterialFactor> materials;

  MaterialFactor factor(MaterialCategory m) =>
      materials[m] ??
      const MaterialFactor(kgCo2ePerKg: 0, typicalItemKg: 0.1, note: '');

  /// Mass in kg for a stored quantity, using the typical item mass for counts
  /// and for units that carry no weight ('pcs', 'handful', 'bag', 'm').
  double massKg(MaterialCategory m, double quantity, String unit) =>
      switch (unit.toLowerCase()) {
        'kg' => quantity,
        'g' => quantity / 1000,
        _ => quantity * factor(m).typicalItemKg,
      };
}

class ImpactSummary {
  const ImpactSummary({
    required this.itemsByMaterial,
    required this.itemsByKind,
    required this.projectsCompleted,
    required this.streakDays,
    required this.activeToday,
    required this.estimatedMassKg,
    required this.co2eKgEstimate,
    required this.co2eDisclaimer,
  });

  static const empty = ImpactSummary(
    itemsByMaterial: {},
    itemsByKind: {},
    projectsCompleted: 0,
    streakDays: 0,
    activeToday: false,
    estimatedMassKg: 0,
    co2eKgEstimate: 0,
    co2eDisclaimer: '',
  );

  /// Items recycled, donated, disposed of safely or upcycled, per material.
  final Map<MaterialCategory, int> itemsByMaterial;
  final Map<ImpactKind, int> itemsByKind;
  final int projectsCompleted;

  /// Consecutive days with at least one scan, marked item or finished project,
  /// ending today (or yesterday, so the streak survives until the day ends).
  final int streakDays;
  final bool activeToday;

  /// Estimated mass kept out of landfill (estimate: counts use typical masses).
  final double estimatedMassKg;

  /// Estimated CO2e avoided. Always show with [co2eDisclaimer].
  final double co2eKgEstimate;
  final String co2eDisclaimer;

  int get totalItems => itemsByKind.values.fold(0, (a, b) => a + b);
}

/// Aggregates impact from local history. [now] is injectable for tests.
ImpactSummary computeImpact({
  required List<ImpactEvent> events,
  required List<ProjectRecord> projects,
  required List<DateTime> scanDates,
  required ImpactFactors factors,
  required DateTime now,
}) {
  final byMaterial = <MaterialCategory, int>{};
  final byKind = <ImpactKind, int>{};
  var massKg = 0.0;
  var co2e = 0.0;

  for (final e in events) {
    final material =
        MaterialCategory.tryFromId(e.material) ?? MaterialCategory.other;
    byMaterial[material] = (byMaterial[material] ?? 0) + 1;
    byKind[e.kind] = (byKind[e.kind] ?? 0) + 1;
    // Hazardous items handed in safely are counted as items, not as mass
    // diverted or carbon avoided.
    if (e.kind == ImpactKind.disposed) continue;
    final kg = factors.massKg(material, e.quantity, e.unit);
    massKg += kg;
    co2e += kg * factors.factor(material).kgCo2ePerKg;
  }

  final completed = projects.where((p) => p.isCompleted).toList();
  final activeDays = <DateTime>{
    for (final e in events) _day(e.createdAt),
    for (final d in scanDates) _day(d),
    for (final p in completed)
      if (p.completedAt != null) _day(p.completedAt!),
  };

  final today = _day(now);
  final activeToday = activeDays.contains(today);
  var cursor = activeToday ? today : _addDays(today, -1);
  var streak = 0;
  while (activeDays.contains(cursor)) {
    streak++;
    cursor = _addDays(cursor, -1);
  }

  return ImpactSummary(
    itemsByMaterial: byMaterial,
    itemsByKind: byKind,
    projectsCompleted: completed.length,
    streakDays: streak,
    activeToday: activeToday,
    estimatedMassKg: massKg,
    co2eKgEstimate: co2e,
    co2eDisclaimer: factors.disclaimer,
  );
}

DateTime _day(DateTime t) {
  final local = t.toLocal();
  return DateTime(local.year, local.month, local.day);
}

// Calendar arithmetic (not Duration) so daylight-saving changes never skip a day.
DateTime _addDays(DateTime day, int days) =>
    DateTime(day.year, day.month, day.day + days);
