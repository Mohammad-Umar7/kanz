import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/project_repository.dart';
import '../data/repositories/scan_repository.dart';
import 'core_providers.dart';
import 'scan_session.dart';

export '../data/repositories/project_repository.dart' show ProjectRecord;
export '../data/repositories/scan_repository.dart' show ScanSummary;

/// Every scan, newest first, with local thumbnails (works offline).
final scanHistoryProvider = StreamProvider<List<ScanSummary>>(
  (ref) => ref.watch(scanRepositoryProvider).watchAll(),
);

/// Every project (in progress and completed), most recently touched first.
final projectsProvider = StreamProvider<List<ProjectRecord>>(
  (ref) => ref.watch(projectRepositoryProvider).watchAll(),
);

/// One project, e.g. for the completion screen.
final projectProvider = StreamProvider.family<ProjectRecord?, String>(
  (ref, projectId) => ref.watch(projectRepositoryProvider).watch(projectId),
);

/// History actions that change stored data.
final historyActionsProvider = Provider<HistoryActions>(HistoryActions.new);

class HistoryActions {
  HistoryActions(this._ref);

  final Ref _ref;

  /// Removes a scan, its projects and its photo from the device.
  Future<void> deleteScan(String scanId) async {
    await _ref.read(scanRepositoryProvider).delete(scanId);
    _ref.invalidate(scanSessionProvider(scanId));
  }
}
