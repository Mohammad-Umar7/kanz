// Impact test data, computed the way the app computes it: impact events and
// projects run through `computeImpact` with the real estimate factors.
import 'dart:convert';
import 'dart:io';

import 'package:kanz/core/data/db/database.dart';
import 'package:kanz/core/data/insights/impact.dart';
import 'package:kanz/core/data/repositories/project_repository.dart';

final DateTime now = DateTime.now();

ImpactFactors _factors() => ImpactFactors.fromJson(
  jsonDecode(File('assets/config/impact_factors.json').readAsStringSync())
      as Map<String, dynamic>,
);

ImpactEvent _event(
  int id,
  ImpactKind kind,
  String material,
  int daysAgo, {
  double quantity = 1,
  String unit = 'pcs',
}) => ImpactEvent(
  id: id,
  dedupeKey: 'e$id',
  kind: kind,
  material: material,
  itemName: material,
  quantity: quantity,
  unit: unit,
  createdAt: now.subtract(Duration(days: daysAgo)),
);

ProjectRecord _project(String id, int daysAgo) {
  final at = now.subtract(Duration(days: daysAgo));
  return ProjectRecord(
    id: id,
    scanId: 's$id',
    ideaId: 'i$id',
    title: 'Project $id',
    idea: null,
    status: ProjectStatus.completed,
    currentStep: 5,
    completedSteps: const {1, 2, 3, 4, 5},
    totalSteps: 5,
    createdAt: at,
    updatedAt: at,
    completedAt: at,
  );
}

/// Four weeks of use: jars upcycled, bottles and cans recycled, clothes
/// donated, batteries handed in, three finished projects, a 4-day streak.
ImpactSummary richSummary({bool activeToday = true}) {
  final offset = activeToday ? 0 : 1;
  var id = 0;
  final events = [
    for (final (kind, material, days, qty) in [
      (ImpactKind.upcycled, 'glass', 0, 1.0),
      (ImpactKind.upcycled, 'glass', 2, 1.0),
      (ImpactKind.upcycled, 'wood', 9, 1.0),
      (ImpactKind.recycled, 'glass', 1, 3.0),
      (ImpactKind.recycled, 'glass', 3, 2.0),
      (ImpactKind.recycled, 'plastic', 1, 6.0),
      (ImpactKind.recycled, 'plastic', 5, 4.0),
      (ImpactKind.recycled, 'plastic', 12, 2.0),
      (ImpactKind.recycled, 'paper', 3, 1.0),
      (ImpactKind.recycled, 'paper', 20, 1.0),
      (ImpactKind.recycled, 'metal', 2, 4.0),
      (ImpactKind.donated, 'textile', 6, 3.0),
      (ImpactKind.donated, 'textile', 14, 2.0),
      (ImpactKind.disposed, 'hazardous', 4, 4.0),
      (ImpactKind.disposed, 'electronics', 25, 1.0),
    ])
      _event(++id, kind, material, days + offset, quantity: qty),
  ];
  return computeImpact(
    events: events,
    projects: [_project('a', 0 + offset), _project('b', 2), _project('c', 9)],
    scanDates: [
      for (var d = offset; d < 4 + offset; d++) now.subtract(Duration(days: d)),
    ],
    factors: _factors(),
    now: now,
  );
}

/// Scanned yesterday but has not marked anything yet.
ImpactSummary scannedOnlySummary() => computeImpact(
  events: const [],
  projects: const [],
  scanDates: [now.subtract(const Duration(days: 1))],
  factors: _factors(),
  now: now,
);

/// A fresh install.
ImpactSummary newSummary() => computeImpact(
  events: const [],
  projects: const [],
  scanDates: const [],
  factors: _factors(),
  now: now,
);
