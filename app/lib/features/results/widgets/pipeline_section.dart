import 'package:flutter/material.dart';

import '../../../core/design/components/pipeline_timeline.dart' as timeline;
import '../../../core/state/scan_session.dart';
import '../../../l10n/l10n.dart';
import '../results_format.dart';
import '../stage_clock.dart';

/// The four honest stages of a scan as a [timeline.PipelineTimeline]:
/// labels from the backend stages, real durations from [StageClock], a
/// retry on each stage that failed for a reason a retry can fix, and one
/// summary line once everything has settled.
class PipelineSection extends StatelessWidget {
  const PipelineSection({
    super.key,
    required this.session,
    required this.clock,
    required this.format,
    required this.onRetry,
  });

  final ScanSessionState session;
  final StageClock clock;
  final ResultsFormat format;
  final ValueChanged<PipelineStage> onRetry;

  /// Makeovers that failed only because the server has no image quota are
  /// shown as paused (skipped), not failed: nothing on the phone fixes them.
  bool get _imagesPaused {
    final makeovers = session.stage(PipelineStage.makeovers);
    return makeovers.isFailed && (makeovers.error?.isQuotaExhausted ?? false);
  }

  bool _retryable(PipelineStage stage) {
    final state = session.stage(stage);
    if (!state.isFailed) return false;
    if (stage == PipelineStage.makeovers && _imagesPaused) return false;
    if (stage == PipelineStage.identifying && session.rejectedPhoto != null) {
      return false;
    }
    return state.error?.retryable ?? true;
  }

  timeline.PipelineStage _row(PipelineStage stage, AppLocalizations l10n) {
    final state = session.stage(stage);
    final label = stageLabel(l10n, stage);
    final elapsed = clock.elapsed(stage, session);
    final detail = elapsed == null
        ? null
        : l10n.resultsSeconds(format.seconds(elapsed));
    final failedMessage = apiErrorMessage(l10n, state.error);
    return switch (state.status) {
      StageStatus.pending => timeline.PipelineStage(
        label: label,
        status: timeline.PipelineStatus.pending,
      ),
      StageStatus.running => timeline.PipelineStage(
        label: label,
        status: timeline.PipelineStatus.active,
      ),
      StageStatus.done => timeline.PipelineStage(
        label: label,
        status: timeline.PipelineStatus.done,
        detail: detail,
      ),
      StageStatus.needsLocation => timeline.PipelineStage(
        label: label,
        status: timeline.PipelineStatus.pending,
        message: l10n.resultsStageNeedsLocation,
      ),
      StageStatus.skipped => timeline.PipelineStage(
        label: label,
        status: timeline.PipelineStatus.skipped,
        message: switch (stage) {
          PipelineStage.dropoff => l10n.resultsStageNoDropoff,
          PipelineStage.makeovers when session.isDisposalOnly =>
            l10n.resultsStageNoMakeoversDisposal,
          PipelineStage.makeovers => l10n.resultsStageNoMakeovers,
          _ => null,
        },
      ),
      StageStatus.failed
          when stage == PipelineStage.makeovers && _imagesPaused =>
        timeline.PipelineStage(
          label: label,
          status: timeline.PipelineStatus.skipped,
          message: l10n.resultsStageImagesPaused,
        ),
      StageStatus.failed => timeline.PipelineStage(
        label: label,
        status: timeline.PipelineStatus.failed,
        detail: detail,
        message:
            stage == PipelineStage.identifying && session.rejectedPhoto != null
            ? photoIssueLabel(l10n, session.rejectedPhoto!.issue)
            : failedMessage,
      ),
    };
  }

  String _summary(AppLocalizations l10n) {
    final parts = [
      l10n.resultsDoneIn(format.seconds(clock.total(session))),
      if (session.isDisposalOnly)
        l10n.resultsSummaryDisposal
      else if (session.stage(PipelineStage.ideas).isDone)
        l10n.resultsSummaryIdeas(session.ideas.length),
      if (session.stage(PipelineStage.dropoff).isDone)
        l10n.resultsSummaryPlaces(session.facilities?.places.length ?? 0),
      if (_imagesPaused) l10n.resultsSummaryImagesPaused,
    ];
    // Each part stays whole when the line wraps ("3 places", never "3" and
    // "places" on two lines): spaces inside a part do not break.
    return [
      for (final part in parts) part.replaceAll(' ', '\u00A0'),
    ].join('  ·  ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final anyRetry = PipelineStage.values.any(_retryable);
    return timeline.PipelineTimeline(
      stages: [for (final s in PipelineStage.values) _row(s, l10n)],
      summary: _summary(l10n),
      expandLabel: l10n.resultsShowSteps,
      collapseLabel: l10n.resultsHideSteps,
      retryLabel: l10n.commonRetry,
      onRetry: anyRetry
          ? (index) {
              final stage = PipelineStage.values[index];
              if (_retryable(stage)) onRetry(stage);
            }
          : null,
    );
  }
}
