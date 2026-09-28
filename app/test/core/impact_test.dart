import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/db/database.dart';
import 'package:kanz/core/data/insights/impact.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/data/repositories/project_repository.dart';

ImpactEvent _event(
  ImpactKind kind,
  String material,
  DateTime at, {
  double quantity = 1,
  String unit = 'pcs',
  int id = 0,
}) => ImpactEvent(
  id: id,
  dedupeKey: '$kind:$id',
  kind: kind,
  material: material,
  itemName: material,
  quantity: quantity,
  unit: unit,
  createdAt: at,
);

ProjectRecord _project(DateTime? completedAt) => ProjectRecord(
  id: 'p',
  scanId: 's',
  ideaId: 'i',
  title: 't',
  idea: null,
  status: completedAt == null
      ? ProjectStatus.inProgress
      : ProjectStatus.completed,
  currentStep: 1,
  completedSteps: const {},
  totalSteps: 5,
  createdAt: DateTime(2026, 9, 1),
  updatedAt: DateTime(2026, 9, 1),
  completedAt: completedAt,
);

void main() {
  late ImpactFactors factors;

  setUpAll(() {
    factors = ImpactFactors.fromJson(
      jsonDecode(File('assets/config/impact_factors.json').readAsStringSync())
          as Map<String, dynamic>,
    );
  });

  final now = DateTime(2026, 9, 28, 18);

  test('the factors file covers every material and is marked an estimate', () {
    expect(factors.materials.keys.toSet(), MaterialCategory.values.toSet());
    expect(factors.disclaimer.toLowerCase(), contains('estimate'));
  });

  test('counts items by material and kind, and estimates CO2e', () {
    final summary = computeImpact(
      events: [
        _event(ImpactKind.recycled, 'glass', now, id: 1),
        _event(ImpactKind.donated, 'textile', now, id: 2),
        _event(
          ImpactKind.recycled,
          'plastic',
          now,
          quantity: 500,
          unit: 'g',
          id: 3,
        ),
        _event(ImpactKind.disposed, 'hazardous', now, id: 4),
      ],
      projects: [_project(now), _project(null)],
      scanDates: const [],
      factors: factors,
      now: now,
    );

    expect(summary.totalItems, 4);
    expect(summary.itemsByMaterial[MaterialCategory.glass], 1);
    expect(summary.itemsByKind[ImpactKind.recycled], 2);
    expect(summary.projectsCompleted, 1);

    // glass 1 pc (0.25 kg) + textile 1 pc (0.3 kg) + plastic 0.5 kg; the
    // safely disposed battery adds no mass or carbon.
    final glass = factors.factor(MaterialCategory.glass);
    final textile = factors.factor(MaterialCategory.textile);
    final plastic = factors.factor(MaterialCategory.plastic);
    final mass = glass.typicalItemKg + textile.typicalItemKg + 0.5;
    final co2e =
        glass.typicalItemKg * glass.kgCo2ePerKg +
        textile.typicalItemKg * textile.kgCo2ePerKg +
        0.5 * plastic.kgCo2ePerKg;
    expect(summary.estimatedMassKg, closeTo(mass, 1e-9));
    expect(summary.co2eKgEstimate, closeTo(co2e, 1e-9));
    expect(summary.co2eDisclaimer, factors.disclaimer);
  });

  group('streak', () {
    ImpactSummary streakFor(List<DateTime> days) => computeImpact(
      events: const [],
      projects: const [],
      scanDates: days,
      factors: factors,
      now: now,
    );

    test('counts consecutive days ending today', () {
      final s = streakFor([
        DateTime(2026, 9, 28, 9),
        DateTime(2026, 9, 27, 22),
        DateTime(2026, 9, 26, 7),
        DateTime(2026, 9, 24, 12),
      ]);
      expect(s.streakDays, 3);
      expect(s.activeToday, isTrue);
    });

    test('survives until the end of today when yesterday was active', () {
      final s = streakFor([DateTime(2026, 9, 27), DateTime(2026, 9, 26)]);
      expect(s.streakDays, 2);
      expect(s.activeToday, isFalse);
    });

    test('is zero after a missed day', () {
      expect(streakFor([DateTime(2026, 9, 25)]).streakDays, 0);
      expect(streakFor(const []).streakDays, 0);
    });

    test('several activities on one day count once', () {
      final s = computeImpact(
        events: [_event(ImpactKind.recycled, 'glass', now, id: 1)],
        projects: [_project(now)],
        scanDates: [now],
        factors: factors,
        now: now,
      );
      expect(s.streakDays, 1);
    });
  });
}
