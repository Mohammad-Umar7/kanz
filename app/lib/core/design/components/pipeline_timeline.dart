import 'package:flutter/material.dart';

import '../context.dart';
import '../icons.dart';
import '../tokens.dart';
import 'buttons.dart';
import 'data.dart';

enum PipelineStatus { pending, active, done, failed, skipped }

/// One stage of the analysis pipeline, with an honest label such as
/// "Identifying materials" and an optional detail ("4.2 s").
@immutable
class PipelineStage {
  const PipelineStage({
    required this.label,
    required this.status,
    this.detail,
    this.message,
  });

  final String label;
  final PipelineStatus status;

  /// Short mono detail at the row end: a duration or a count.
  final String? detail;

  /// Explanation under a failed or skipped stage.
  final String? message;
}

/// The live pipeline on the results screen: one row per backend stage with
/// pending, active, done, failed and skipped states. When every stage is
/// done (or skipped) it collapses into a single summary line that can be
/// expanded again. A failed stage offers a retry.
class PipelineTimeline extends StatefulWidget {
  const PipelineTimeline({
    super.key,
    required this.stages,
    required this.summary,
    required this.expandLabel,
    required this.collapseLabel,
    this.retryLabel,
    this.onRetry,
    this.collapseWhenDone = true,
  });

  final List<PipelineStage> stages;

  /// One-line summary once complete, for example "Done in 6.1 s · 3 ideas".
  final String summary;
  final String expandLabel;
  final String collapseLabel;
  final String? retryLabel;

  /// Called with the index of the failed stage.
  final ValueChanged<int>? onRetry;
  final bool collapseWhenDone;

  @override
  State<PipelineTimeline> createState() => _PipelineTimelineState();
}

class _PipelineTimelineState extends State<PipelineTimeline> {
  bool _expanded = false;

  bool get _complete => widget.stages.every(
    (s) =>
        s.status == PipelineStatus.done || s.status == PipelineStatus.skipped,
  );

  @override
  Widget build(BuildContext context) {
    final collapsed = widget.collapseWhenDone && _complete && !_expanded;
    return AnimatedSize(
      duration: KanzMotion.of(context, KanzMotion.medium),
      curve: KanzMotion.emphasized,
      alignment: AlignmentDirectional.topStart,
      child: AnimatedSwitcher(
        duration: KanzMotion.of(context, KanzMotion.medium),
        switchInCurve: KanzMotion.enter,
        switchOutCurve: KanzMotion.exit,
        layoutBuilder: (current, previous) => Stack(
          alignment: AlignmentDirectional.topStart,
          children: [...previous, ?current],
        ),
        child: collapsed ? _summary(context) : _list(context),
      ),
    );
  }

  Widget _summary(BuildContext context) {
    final c = context.kanzColors;
    void expand() => setState(() => _expanded = true);
    return Semantics(
      key: const ValueKey('summary'),
      button: true,
      label: widget.summary,
      hint: widget.expandLabel,
      onTap: expand,
      excludeSemantics: true,
      child: InkWell(
        onTap: expand,
        borderRadius: KanzRadii.inputAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: KanzSpace.touchTarget),
          child: Row(
            children: [
              Icon(KanzIcons.checkCircle, size: 20, color: c.ink),
              const SizedBox(width: KanzSpace.s12),
              Expanded(
                child: Text(
                  widget.summary,
                  style: context.textStyles.bodyMedium,
                ),
              ),
              Icon(KanzIcons.chevronDown, size: 18, color: c.inkSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(BuildContext context) {
    final stages = widget.stages;
    return Column(
      key: const ValueKey('list'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < stages.length; i++)
          _StageRow(
            stage: stages[i],
            first: i == 0,
            last: i == stages.length - 1,
            retryLabel: widget.retryLabel,
            onRetry: widget.onRetry == null ? null : () => widget.onRetry!(i),
          ),
        if (_complete && widget.collapseWhenDone)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: KanzButton.tertiary(
              label: widget.collapseLabel,
              icon: KanzIcons.chevronUp,
              onPressed: () => setState(() => _expanded = false),
            ),
          ),
      ],
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.stage,
    required this.first,
    required this.last,
    required this.retryLabel,
    required this.onRetry,
  });

  final PipelineStage stage;
  final bool first;
  final bool last;
  final String? retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    final status = stage.status;
    final labelStyle = switch (status) {
      PipelineStatus.active => t.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      PipelineStatus.done => t.bodyMedium,
      PipelineStatus.failed => t.bodyMedium?.copyWith(
        color: c.danger,
        fontWeight: FontWeight.w600,
      ),
      _ => t.bodyMedium?.copyWith(color: c.inkSecondary),
    };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 1,
                  height: 12,
                  color: first ? Colors.transparent : c.line,
                ),
                _StatusGlyph(status: status),
                Expanded(
                  child: Container(
                    width: 1,
                    color: last ? Colors.transparent : c.line,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: KanzSpace.s12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Semantics(
                          liveRegion: status == PipelineStatus.active,
                          child: Text(stage.label, style: labelStyle),
                        ),
                      ),
                      if (stage.detail != null) ...[
                        const SizedBox(width: KanzSpace.s8),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: MonoLabel(stage.detail!, uppercase: false),
                        ),
                      ],
                    ],
                  ),
                  if (stage.message != null) ...[
                    const SizedBox(height: KanzSpace.s4),
                    Text(stage.message!, style: t.bodySmall),
                  ],
                  if (status == PipelineStatus.failed &&
                      onRetry != null &&
                      retryLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: KanzSpace.s8),
                      child: KanzButton.secondary(
                        label: retryLabel!,
                        icon: KanzIcons.retry,
                        onPressed: onRetry,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusGlyph extends StatelessWidget {
  const _StatusGlyph({required this.status});

  final PipelineStatus status;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    const size = 20.0;
    final Widget glyph = switch (status) {
      PipelineStatus.pending => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: c.lineStrong, width: 1.5),
        ),
      ),
      PipelineStatus.active =>
        context.reduceMotion
            ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.accent,
                ),
              )
            : SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: c.accent,
                  strokeCap: StrokeCap.round,
                ),
              ),
      PipelineStatus.done => Icon(
        KanzIcons.checkCircle,
        size: size,
        color: c.ink,
      ),
      PipelineStatus.failed => Icon(
        KanzIcons.error,
        size: size,
        color: c.danger,
      ),
      PipelineStatus.skipped => Icon(
        KanzIcons.skipped,
        size: size,
        color: c.inkDisabled,
      ),
    };
    return SizedBox.square(
      dimension: size,
      child: Center(child: glyph),
    );
  }
}
