import 'package:flutter/material.dart';

import '../../../core/data/models/models.dart';
import '../../../core/design/design.dart';
import '../../../core/state/scan_session.dart';
import '../../../l10n/l10n.dart';
import '../results_format.dart';
import '../scan_images.dart';
import 'disposal_advice.dart';

/// The three upcycling ideas: makeover cards that fill in as each after
/// image lands, the tools the user already has, and the knowledge the ideas
/// came from. On a mixed photo the hazardous items are named as held back,
/// with their safe disposal after the ideas.
class UpcycleIdeas extends StatelessWidget {
  const UpcycleIdeas({
    super.key,
    required this.scanId,
    required this.session,
    required this.images,
    required this.format,
    required this.ownedTools,
    required this.disposed,
    required this.onOpen,
    required this.onRetryImage,
    required this.onMarkDisposed,
  });

  final String scanId;
  final ScanSessionState session;
  final StableImages images;
  final ResultsFormat format;
  final List<ToolId> ownedTools;
  final Set<String> disposed;
  final ValueChanged<UpcycleIdea> onOpen;
  final ValueChanged<UpcycleIdea> onRetryImage;
  final Future<void> Function(String itemId) onMarkDisposed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final recommendation = session.recommendation!;
    final ideas = recommendation.upcycle;
    final heldBack = recommendation.routing.mode == RoutingMode.mixed
        ? [
            for (final id in recommendation.routing.hazardousItemIds)
              ?session.itemById(id)?.name,
          ]
        : const <String>[];
    final before = images.before(session);
    final sources = format.sourceTitles([
      for (final idea in ideas) ...idea.sources,
    ]);
    // The server has no image quota: no makeover can be made on it. The
    // ideas then read as a numbered list under one note, instead of three
    // copies of the same photo. The first quota answer is enough (the other
    // requests go to the same spent quota), so the cards do not flash
    // through a failed picture and two skeletons on the way; a makeover
    // that did arrive keeps the cards.
    final paused =
        ideas.any(
          (i) => session.afterImage(i.id).error?.isQuotaExhausted ?? false,
        ) &&
        !ideas.any((i) => session.afterImage(i.id).isReady);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (heldBack.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              KanzSpace.gutter,
              0,
              KanzSpace.gutter,
              KanzSpace.s16,
            ),
            child: Callout(
              variant: CalloutVariant.safety,
              title: l10n.resultsHeldBackTitle,
              // The backend's reason when it gave one, and where the safe
              // disposal is when there is some.
              message: [
                if (recommendation.routing.reason case final reason?)
                  format.ai(reason)
                else
                  l10n.resultsHeldBackBody(format.list(heldBack)),
                if (recommendation.disposal.isNotEmpty)
                  l10n.resultsHeldBackPointer,
              ].join(' '),
            ),
          ),
        // EmptyState carries the gutter itself.
        if (ideas.isEmpty)
          EmptyState(
            icon: KanzIcons.upcycle,
            title: l10n.resultsNoIdeasTitle,
            message: l10n.resultsNoIdeasBody,
          ),
        Padding(
          padding: KanzSpace.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (paused) ...[
                Callout(
                  variant: CalloutVariant.tip,
                  icon: KanzIcons.pause,
                  title: l10n.resultsImagesPausedTitle,
                  message: l10n.resultsImagesPausedBody,
                ),
                const SizedBox(height: KanzSpace.s16),
              ],
              for (var i = 0; i < ideas.length; i++) ...[
                if (i > 0)
                  SizedBox(height: paused ? KanzSpace.s12 : KanzSpace.s16),
                FadeUp.staggered(
                  index: i,
                  child: _Idea(
                    scanId: scanId,
                    index: i + 1,
                    idea: ideas[i],
                    image: session.afterImage(ideas[i].id),
                    before: before,
                    pictureless: paused,
                    images: images,
                    format: format,
                    ownedTools: ownedTools,
                    onOpen: () => onOpen(ideas[i]),
                    onRetryImage: () => onRetryImage(ideas[i]),
                  ),
                ),
              ],
              if (sources.isNotEmpty) ...[
                const SizedBox(height: KanzSpace.s24),
                SourceChips(title: l10n.resultsBasedOn, sources: sources),
              ],
              if (heldBack.isNotEmpty &&
                  recommendation.disposal.isNotEmpty) ...[
                const SizedBox(height: KanzSpace.s32),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.resultsSafeDisposalTitle,
                    style: context.textStyles.titleLarge,
                  ),
                ),
                for (final guidance in recommendation.disposal) ...[
                  const SizedBox(height: KanzSpace.s12),
                  DisposalGuideCard(
                    guidance: guidance,
                    item: session.itemById(guidance.itemId),
                    format: format,
                    disposed: disposed.contains(guidance.itemId),
                    onMark: () => onMarkDisposed(guidance.itemId),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Idea extends StatelessWidget {
  const _Idea({
    required this.scanId,
    required this.index,
    required this.idea,
    required this.image,
    required this.before,
    required this.pictureless,
    required this.images,
    required this.format,
    required this.ownedTools,
    required this.onOpen,
    required this.onRetryImage,
  });

  final String scanId;

  /// Position in the list, from 1.
  final int index;
  final UpcycleIdea idea;
  final GeneratedImageState image;
  final ImageProvider? before;

  /// No makeover can be drawn for any idea (the image quota is spent): the
  /// idea reads as a numbered entry.
  final bool pictureless;
  final StableImages images;
  final ResultsFormat format;
  final List<ToolId> ownedTools;
  final VoidCallback onOpen;
  final VoidCallback onRetryImage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final failed = image.status == ImageStatus.failed;
    final paused = image.error?.isQuotaExhausted ?? false;
    final meta = [
      difficultyLabel(l10n, idea.difficulty),
      l10n.commonMinutes(idea.timeMinutes),
    ];
    final toolMatch = format.toolMatch(idea, ownedTools).badge();
    final retry = canRetryImage(image)
        ? Align(
            alignment: AlignmentDirectional.centerStart,
            child: KanzButton.tertiary(
              label: l10n.resultsIdeaImageRetry,
              icon: KanzIcons.retry,
              onPressed: onRetryImage,
            ),
          )
        : null;

    // Nothing to picture: images are paused on this server, or a text scan
    // whose makeover could not be made has neither a photo nor an after
    // image. The idea then reads as a numbered entry, not an empty frame.
    if (pictureless || (failed && before == null)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IdeaEntry(
            number: format.index(index),
            title: format.ai(idea.title),
            pitch: format.ai(idea.pitch),
            meta: meta,
            toolMatch: toolMatch,
            onTap: onOpen,
          ),
          ?retry,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IdeaCard(
          title: format.ai(idea.title),
          pitch: format.ai(idea.pitch),
          original: before,
          after: images.resolve(idea.id, image),
          failed: failed,
          pendingLabel: l10n.resultsIdeaRendering,
          errorLabel: paused
              ? l10n.resultsIdeaImagePaused
              : l10n.resultsIdeaImageFailed,
          beforeLabel: l10n.resultsIdeaBefore,
          meta: meta,
          toolMatch: toolMatch,
          heroTag: afterHeroTag(scanId, idea.id),
          onTap: onOpen,
        ),
        ?retry,
      ],
    );
  }
}

/// An idea without a picture: a Fraunces number, the title and pitch, and
/// the same mono meta and tool match as the makeover cards. A chevron at the
/// end of the title line says the entry opens, like a row in a list.
class _IdeaEntry extends StatelessWidget {
  const _IdeaEntry({
    required this.number,
    required this.title,
    required this.pitch,
    required this.meta,
    required this.toolMatch,
    required this.onTap,
  });

  final String number;
  final String title;
  final String pitch;
  final List<String> meta;
  final Widget toolMatch;
  final VoidCallback onTap;

  /// Room for a two-digit Fraunces numeral and the gap after it.
  static const double numeralColumn = 36;

  /// The end column that holds the chevron.
  static const double chevronColumn = 24;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    return KanzCard(
      onTap: onTap,
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.s16,
        KanzSpace.s16,
        KanzSpace.s16,
        KanzSpace.s20,
      ),
      // The numeral hugs the start edge in either direction and sits on the
      // title's baseline; its column has one width, so every title starts on
      // the same line whatever the digits.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          ExcludeSemantics(
            child: SizedBox(
              width: _IdeaEntry.numeralColumn,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  number,
                  style: context.kanzType.numeralSmall.copyWith(
                    color: c.inkSecondary,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The chevron shares the title's first baseline, which
                // centers it on that line; the numeral beside this column
                // keeps sitting on the same baseline.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(child: Text(title, style: t.headlineSmall)),
                    const SizedBox(width: KanzSpace.s8),
                    SizedBox(
                      width: _IdeaEntry.chevronColumn,
                      child: Icon(
                        KanzIcons.chevronForward,
                        size: 20,
                        color: c.inkSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KanzSpace.s4),
                Text(
                  pitch,
                  style: t.bodyMedium?.copyWith(color: c.inkSecondary),
                ),
                const SizedBox(height: KanzSpace.s12),
                Wrap(
                  spacing: KanzSpace.s16,
                  runSpacing: KanzSpace.s8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    MonoLabel(meta.join(' · '), color: c.ink),
                    toolMatch,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Idea cards before the ideas exist: the card's shape, with the stage named
/// on the image area.
class IdeaSkeleton extends StatelessWidget {
  const IdeaSkeleton({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: KanzRadii.cardAll,
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Skeleton(
                  height: double.infinity,
                  borderRadius: BorderRadius.zero,
                ),
                PositionedDirectional(
                  top: KanzSpace.s16,
                  start: KanzSpace.s16,
                  end: KanzSpace.s16,
                  child: Row(
                    children: [
                      SizedBox.square(
                        dimension: 12,
                        child: context.reduceMotion
                            ? Icon(
                                KanzIcons.clock,
                                size: 12,
                                color: c.inkSecondary,
                              )
                            : CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: c.inkSecondary,
                              ),
                      ),
                      const SizedBox(width: KanzSpace.s8),
                      Flexible(child: MonoLabel(label)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsetsDirectional.all(KanzSpace.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 0.55,
                  child: Skeleton(height: 20),
                ),
                SizedBox(height: KanzSpace.s12),
                Skeleton(height: 12),
                SizedBox(height: KanzSpace.s8),
                FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 0.7,
                  child: Skeleton(height: 12),
                ),
                SizedBox(height: KanzSpace.s16),
                FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 0.45,
                  child: Skeleton(height: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
