import '../../core/state/scan_session.dart';

/// Measures how long each pipeline stage really took, as the user waited
/// for it: from the moment a stage starts running to the moment it ends
/// (done, failed, skipped or waiting for a location). A retry or a
/// correction runs the stage again and measures it again.
///
/// Stages this screen never saw running (a scan reopened from History) fall
/// back to the backend's own `timings_ms`, so the durations stay honest
/// either way. Makeovers have no server timing and then show none.
class StageClock {
  StageClock({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final Map<PipelineStage, DateTime> _started = {};
  final Map<PipelineStage, Duration> _measured = {};

  /// Call with every new session state (and once with the first one: a
  /// stage already running when the screen opened starts counting then).
  void observe(ScanSessionState session) {
    final now = _now();
    for (final stage in PipelineStage.values) {
      final status = session.stage(stage).status;
      final running = status == StageStatus.running;
      if (running) {
        // A new run: the previous measurement no longer describes it.
        if (!_started.containsKey(stage) || _measured.containsKey(stage)) {
          _started[stage] = now;
          _measured.remove(stage);
        }
      } else if (_started.containsKey(stage) &&
          !_measured.containsKey(stage) &&
          status != StageStatus.pending) {
        _measured[stage] = now.difference(_started[stage]!);
      } else if (status == StageStatus.pending) {
        _started.remove(stage);
        _measured.remove(stage);
      }
    }
  }

  /// How long [stage] took, or null when it has not finished (or is unknown).
  Duration? elapsed(PipelineStage stage, ScanSessionState session) {
    final measured = _measured[stage];
    if (measured != null) return measured;
    if (_started.containsKey(stage)) return null;
    if (session.stage(stage).status != StageStatus.done) return null;
    final ms = switch (stage) {
      PipelineStage.identifying => session.analysis?.timingsMs['total'],
      PipelineStage.ideas => session.recommendation?.timingsMs['total'],
      PipelineStage.dropoff => session.facilities?.timingsMs['total'],
      PipelineStage.makeovers => null,
    };
    return ms == null ? null : Duration(milliseconds: ms);
  }

  /// The whole run as the user experienced it: identifying, then ideas,
  /// then drop-off and makeovers side by side (the longer of the two).
  Duration total(ScanSessionState session) {
    Duration of(PipelineStage s) => elapsed(s, session) ?? Duration.zero;
    final dropoff = of(PipelineStage.dropoff);
    final makeovers = of(PipelineStage.makeovers);
    return of(PipelineStage.identifying) +
        of(PipelineStage.ideas) +
        (dropoff > makeovers ? dropoff : makeovers);
  }
}
