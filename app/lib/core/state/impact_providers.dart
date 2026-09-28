import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart' show ImpactEvent;
import '../data/insights/impact.dart';
import 'core_providers.dart';
import 'history_providers.dart';

export '../data/insights/impact.dart' show ImpactSummary;

/// Raw impact events (recycled, donated, disposed, upcycled), oldest first.
final impactEventsProvider = StreamProvider<List<ImpactEvent>>(
  (ref) => ref.watch(impactRepositoryProvider).watchAll(),
);

/// Impact tab numbers, updated live as items are marked and projects finish.
///
/// Counts and the streak are facts; `co2eKgEstimate` is an estimate and must
/// be shown with `l10n.commonCo2eDisclaimer`.
final impactProvider = Provider<AsyncValue<ImpactSummary>>((ref) {
  final events = ref.watch(impactEventsProvider);
  final projects = ref.watch(projectsProvider);
  final scans = ref.watch(scanHistoryProvider);

  final error = [events, projects, scans].where((v) => v.hasError).firstOrNull;
  if (error != null) {
    return AsyncError(error.error!, error.stackTrace ?? StackTrace.current);
  }
  if (!events.hasValue || !projects.hasValue || !scans.hasValue) {
    return const AsyncLoading();
  }
  return AsyncData(
    computeImpact(
      events: events.requireValue,
      projects: projects.requireValue,
      scanDates: [for (final s in scans.requireValue) s.createdAt],
      factors: ref.watch(impactFactorsProvider),
      now: DateTime.now(),
    ),
  );
});
