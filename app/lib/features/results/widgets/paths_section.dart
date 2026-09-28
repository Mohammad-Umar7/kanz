import 'package:flutter/material.dart';

import '../../../core/data/models/models.dart';
import '../../../core/design/design.dart' hide PipelineStage;
import '../../../core/state/scan_session.dart';
import '../../../l10n/l10n.dart';
import '../results_format.dart';
import '../scan_images.dart';
import 'disposal_advice.dart';
import 'recycle_donate_advice.dart';
import 'upcycle_ideas.dart';

/// The three paths for what was found: Upcycle / Recycle / Donate. For
/// hazardous items the first path is "Dispose" and has no DIY at all.
class PathsSection extends StatelessWidget {
  const PathsSection({
    super.key,
    required this.scanId,
    required this.session,
    required this.images,
    required this.format,
    required this.tab,
    required this.onTab,
    required this.ownedTools,
    required this.recycled,
    required this.donated,
    required this.disposed,
    required this.onOpenIdea,
    required this.onRetryImage,
    required this.onRetryIdeas,
    required this.onMarkRecycled,
    required this.onMarkDonated,
    required this.onMarkDisposed,
  });

  final String scanId;
  final ScanSessionState session;
  final StableImages images;
  final ResultsFormat format;
  final int tab;
  final ValueChanged<int> onTab;
  final List<ToolId> ownedTools;
  final Set<String> recycled;
  final Set<String> donated;
  final Set<String> disposed;
  final ValueChanged<UpcycleIdea> onOpenIdea;
  final ValueChanged<UpcycleIdea> onRetryImage;
  final VoidCallback onRetryIdeas;
  final Future<void> Function(String itemId) onMarkRecycled;
  final Future<void> Function(String itemId) onMarkDonated;
  final Future<void> Function(String itemId) onMarkDisposed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ideasStage = session.stage(PipelineStage.ideas);
    final recommendation = session.recommendation;
    final ready = ideasStage.isDone && recommendation != null;
    final disposalOnly = session.isDisposalOnly;
    // Counts appear once known, and only when there is something to count.
    String? count(int n) => ready && n > 0 ? '$n' : null;

    final tabs = [
      disposalOnly
          ? SegmentedTab(label: l10n.resultsTabDispose, icon: KanzIcons.safety)
          : SegmentedTab(
              label: l10n.resultsTabUpcycle,
              icon: KanzIcons.upcycle,
              count: count(session.ideas.length),
            ),
      SegmentedTab(
        label: l10n.resultsTabRecycle,
        icon: KanzIcons.recycle,
        count: count(recommendation?.recycle.instructions.length ?? 0),
      ),
      SegmentedTab(
        label: l10n.resultsTabDonate,
        icon: KanzIcons.donate,
        count: count(
          recommendation?.donate.options.where((o) => o.suitable).length ?? 0,
        ),
      ),
    ];

    final Widget content;
    if (ideasStage.isFailed) {
      content = ErrorState(
        title: l10n.resultsIdeasErrorTitle,
        message: apiErrorMessage(l10n, ideasStage.error),
        retryLabel: l10n.commonRetry,
        onRetry: (ideasStage.error?.retryable ?? true) ? onRetryIdeas : null,
        code: _code(ideasStage.error?.code.name, ideasStage.error?.requestId),
      );
    } else if (!ready) {
      content = Padding(
        padding: KanzSpace.page,
        child: Semantics(
          liveRegion: true,
          label: l10n.resultsFindingIdeas,
          child: ExcludeSemantics(
            child: Column(
              children: [
                IdeaSkeleton(label: l10n.resultsFindingIdeas),
                const SizedBox(height: KanzSpace.s16),
                IdeaSkeleton(label: l10n.resultsFindingIdeas),
              ],
            ),
          ),
        ),
      );
    } else {
      content = switch (tab) {
        0 when disposalOnly => DisposalAdvice(
          recommendation: recommendation,
          items: session.items,
          format: format,
          disposed: disposed,
          onMarkDisposed: onMarkDisposed,
        ),
        0 => UpcycleIdeas(
          scanId: scanId,
          session: session,
          images: images,
          format: format,
          ownedTools: ownedTools,
          disposed: disposed,
          onOpen: onOpenIdea,
          onRetryImage: onRetryImage,
          onMarkDisposed: onMarkDisposed,
        ),
        1 => RecycleAdvice(
          session: session,
          format: format,
          recycled: recycled,
          onMark: onMarkRecycled,
        ),
        _ => DonateAdvice(
          session: session,
          format: format,
          donated: donated,
          onMark: onMarkDonated,
        ),
      };
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: disposalOnly
              ? l10n.resultsPathsTitleDisposal
              : l10n.resultsPathsTitle,
        ),
        const SizedBox(height: KanzSpace.s16),
        Padding(
          padding: KanzSpace.page,
          child: SegmentedTabs(
            tabs: tabs,
            selectedIndex: tab,
            onChanged: onTab,
          ),
        ),
        const SizedBox(height: KanzSpace.s16),
        // Each path pads itself: ErrorState and EmptyState carry the gutter.
        KeyedSubtree(key: ValueKey('path-$tab'), child: content),
      ],
    );
  }
}

/// "ai_unavailable · req_5f3c2a1b", for support.
String? _code(String? code, String? requestId) =>
    code == null ? null : [code, ?requestId].join(' · ');
