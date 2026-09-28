import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/design/design.dart';
import '../../../core/network/api_exception.dart';
import '../../../l10n/l10n.dart';
import 'page_parts.dart';

/// The tutorial is being written: the idea's picture and title when they are
/// known, a line saying what is happening, and skeletons in the shape of the
/// overview (the note, the spec grid, the materials list).
class TutorialLoadingView extends StatelessWidget {
  const TutorialLoadingView({super.key, this.hero, this.title});

  final ImageProvider? hero;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s8,
        KanzSpace.gutter,
        KanzSpace.s32,
      ),
      children: [
        if (hero != null)
          HeroPicture(image: hero!)
        else
          const AspectRatio(
            aspectRatio: 3 / 2,
            child: Skeleton(
              height: double.infinity,
              borderRadius: KanzRadii.cardAll,
            ),
          ),
        const SizedBox(height: KanzSpace.s24),
        Semantics(
          liveRegion: true,
          container: true,
          child: Row(
            children: [
              SizedBox.square(
                dimension: 14,
                child: context.reduceMotion
                    ? Icon(KanzIcons.clock, size: 14, color: c.inkSecondary)
                    : CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: c.inkSecondary,
                      ),
              ),
              const SizedBox(width: KanzSpace.s8),
              Expanded(child: MonoLabel(l10n.tutorialLoadingTitle)),
            ],
          ),
        ),
        const SizedBox(height: KanzSpace.s8),
        if (title != null)
          Text(title!, style: t.headlineLarge)
        else
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: Skeleton(width: 220, height: 28),
          ),
        const SizedBox(height: KanzSpace.s8),
        Text(
          l10n.tutorialLoadingBody,
          style: t.bodyMedium?.copyWith(color: c.inkSecondary),
        ),
        const SizedBox(height: KanzSpace.s20),
        const Skeleton(height: 96, borderRadius: KanzRadii.inputAll),
        const SizedBox(height: KanzSpace.s24),
        for (var row = 0; row < 2; row++) ...[
          Divider(height: 1, thickness: 1, color: c.line),
          const Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: KanzSpace.s12),
            child: Row(
              children: [
                Expanded(child: _Cell()),
                SizedBox(width: KanzSpace.s16),
                Expanded(child: _Cell()),
              ],
            ),
          ),
        ],
        const SizedBox(height: KanzSpace.s32),
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: Skeleton(width: 120, height: 20),
        ),
        const SizedBox(height: KanzSpace.s12),
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) Divider(height: 1, thickness: 1, color: c.line),
          const Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: KanzSpace.s12),
            child: Row(
              children: [
                Skeleton(width: 10, height: 10),
                SizedBox(width: KanzSpace.s12),
                Expanded(child: Skeleton(height: 16)),
                SizedBox(width: KanzSpace.s48),
                Skeleton(width: 40, height: 14),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Skeleton(width: 48, height: 10),
        SizedBox(height: KanzSpace.s8),
        FractionallySizedBox(widthFactor: 0.7, child: Skeleton(height: 14)),
      ],
    );
  }
}

/// The tutorial could not be loaded. Offline and "this idea is gone" get
/// their own words; anything retryable offers a retry.
class TutorialFailedView extends StatelessWidget {
  const TutorialFailedView({
    super.key,
    this.hero,
    required this.error,
    required this.onRetry,
    required this.onBackToIdeas,
  });

  /// The idea's picture, kept on screen so the failure stays in context.
  final ImageProvider? hero;
  final ApiException? error;
  final VoidCallback onRetry;

  /// Leaves for the scan's ideas when this idea is gone.
  final VoidCallback onBackToIdeas;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = this.error;
    final offline = error?.code == ApiErrorCode.offline;
    final retryable = error?.retryable ?? true;
    final Widget content;
    if (!retryable) {
      content = EmptyState(
        icon: KanzIcons.question,
        title: l10n.tutorialMissingTitle,
        message: error?.code == ApiErrorCode.notFound
            ? l10n.tutorialMissingBody
            : apiErrorMessage(l10n, error),
        actionLabel: l10n.tutorialMissingAction,
        onAction: onBackToIdeas,
      );
    } else {
      content = ErrorState(
        icon: offline ? KanzIcons.noWifi : KanzIcons.error,
        title: offline ? l10n.tutorialOfflineTitle : l10n.tutorialErrorTitle,
        message: offline
            ? l10n.tutorialOfflineBody
            : apiErrorMessage(l10n, error),
        retryLabel: l10n.commonRetry,
        onRetry: onRetry,
        code: supportCode(error),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.only(top: KanzSpace.s8),
      child: Column(
        // Stretch, so the state block spans the width and starts on the
        // gutter in both directions instead of shrinking to its text.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hero != null && retryable)
            Padding(
              padding: KanzSpace.page,
              child: HeroPicture(image: hero!),
            )
          else
            const SizedBox(height: KanzSpace.s16),
          content,
        ],
      ),
    );
  }
}

/// What support needs to find a failure: the request id, and the error code
/// as the backend spells it ("ai_unavailable") in debug builds. Null when
/// there is nothing to look up (a phone with no connection, say).
String? supportCode(ApiException? error) {
  if (error == null) return null;
  final parts = [if (kDebugMode) error.code.wireId, ?error.requestId];
  return error.requestId == null ? null : parts.join(' · ');
}
