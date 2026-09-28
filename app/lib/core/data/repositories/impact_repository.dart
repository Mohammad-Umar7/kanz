import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models/models.dart';

export '../db/database.dart' show ImpactEvent, ImpactKind;

/// Records what the user did with each item; the Impact tab aggregates it.
class ImpactRepository {
  ImpactRepository(this._db, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  /// Records [kind] for [item]. Idempotent per (kind, scan or project, item):
  /// tapping "I recycled it" twice still counts one item.
  Future<void> record({
    required ImpactKind kind,
    required Item item,
    String? scanId,
    String? projectId,
  }) async {
    final owner = projectId ?? scanId ?? '-';
    await _db
        .into(_db.impactEvents)
        .insert(
          ImpactEventsCompanion.insert(
            dedupeKey: '${kind.name}:$owner:${item.id}',
            kind: kind,
            material: item.category.id,
            itemName: item.name,
            quantity: Value(item.quantity.value),
            unit: Value(item.quantity.unit),
            scanId: Value(scanId),
            projectId: Value(projectId),
            itemId: Value(item.id),
            createdAt: _now(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Oldest first.
  Stream<List<ImpactEvent>> watchAll() {
    final query = _db.select(_db.impactEvents)
      ..orderBy([(e) => OrderingTerm.asc(e.createdAt)]);
    return query.watch();
  }

  Future<List<ImpactEvent>> all() => _db.select(_db.impactEvents).get();

  /// Item ids of a scan already marked with [kind] (to show a checked state).
  Stream<Set<String>> watchMarked(String scanId, ImpactKind kind) {
    final query = _db.select(_db.impactEvents)
      ..where((e) => e.scanId.equals(scanId) & e.kind.equalsValue(kind));
    return query.watch().map(
      (rows) => {
        for (final r in rows)
          if (r.itemId != null) r.itemId!,
      },
    );
  }
}
