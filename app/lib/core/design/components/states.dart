import 'package:flutter/material.dart';

import '../context.dart';
import '../icons.dart';
import '../tokens.dart';
import 'buttons.dart';
import 'data.dart';

/// Nothing here yet: a glyph in a hairline circle, a Fraunces title, one
/// sentence and at most one full-width action. Start-aligned like the rest
/// of Kanz, and always as wide as its parent, so it sits on the start
/// gutter in both directions even under a loose parent.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.primaryAction = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Leads the action's label.
  final IconData? actionIcon;

  /// Draw the action as the primary (ink) button: use it when it is the
  /// only way forward from this screen ("New scan" for a missing scan).
  final bool primaryAction;

  @override
  Widget build(BuildContext context) {
    return _StateBlock(
      icon: icon,
      title: title,
      message: message,
      action: actionLabel != null && onAction != null
          ? KanzButton(
              label: actionLabel!,
              icon: actionIcon,
              onPressed: onAction,
              variant: primaryAction
                  ? KanzButtonVariant.primary
                  : KanzButtonVariant.secondary,
              expand: true,
            )
          : null,
    );
  }
}

/// Something failed: the same anatomy as [EmptyState] with the glyph and
/// its circle in the danger color, what happened in plain words, a
/// full-width retry, and the support code last.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    this.code,
    this.codeLabel,
    this.icon = KanzIcons.error,
    this.primaryAction = false,
  });

  final String title;

  /// The cause and what still works ("No connection. Saved scans and
  /// tutorials still open."). The button alone says "Try again".
  final String message;
  final String retryLabel;

  /// Null hides the retry (the error is final).
  final VoidCallback? onRetry;

  /// For support, for example "req_5f3c2a1b" (with the wire code in debug
  /// builds: "ai_unavailable · req_5f3c2a1b").
  final String? code;

  /// Mono label over [code], for example "Support code".
  final String? codeLabel;
  final IconData icon;

  /// Draw the retry as the primary (ink) button: use it when retrying is
  /// the only way forward from this screen.
  final bool primaryAction;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final code = this.code;
    return Semantics(
      liveRegion: true,
      container: true,
      child: _StateBlock(
        icon: icon,
        tone: c.danger,
        title: title,
        message: message,
        action: onRetry == null
            ? null
            : KanzButton(
                label: retryLabel,
                icon: KanzIcons.retry,
                onPressed: onRetry,
                variant: primaryAction
                    ? KanzButtonVariant.primary
                    : KanzButtonVariant.secondary,
                expand: true,
              ),
        footer: code == null || code.isEmpty
            ? null
            : _SupportCode(label: codeLabel, code: code),
      ),
    );
  }
}

/// The shared anatomy of [EmptyState] and [ErrorState].
class _StateBlock extends StatelessWidget {
  const _StateBlock({
    required this.icon,
    required this.title,
    required this.message,
    this.tone,
    this.action,
    this.footer,
  });

  final IconData icon;
  final String title;
  final String message;

  /// Glyph and circle color; ink with a strong hairline when null.
  final Color? tone;
  final Widget? action;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    // Full width and start-aligned, whatever the parent: a loose parent
    // (a centered Stack, a scroll view) would otherwise shrink the block to
    // its text and float it off the start gutter in Arabic.
    return SizedBox(
      width: double.infinity,
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: KanzSpace.gutter,
            vertical: KanzSpace.s24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: tone ?? c.lineStrong),
                  ),
                  child: Icon(icon, size: 24, color: tone ?? c.ink),
                ),
              ),
              const SizedBox(height: KanzSpace.s20),
              Semantics(
                header: true,
                child: Text(title, style: t.headlineSmall),
              ),
              const SizedBox(height: KanzSpace.s8),
              Text(
                message,
                style: t.bodyMedium?.copyWith(color: c.inkSecondary),
              ),
              if (action != null) ...[
                const SizedBox(height: KanzSpace.s24),
                action!,
              ],
              if (footer != null) ...[
                const SizedBox(height: KanzSpace.s20),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "SUPPORT CODE" over the request id, quiet and case-preserving.
class _SupportCode extends StatelessWidget {
  const _SupportCode({required this.label, required this.code});

  final String? label;
  final String code;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            MonoLabel(label!),
            const SizedBox(height: KanzSpace.s2),
          ],
          // Ids read left to right in Arabic too, and keep their case.
          Text(
            code,
            style: context.kanzType.data.copyWith(color: c.inkSecondary),
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}

/// A thin notice at the top of a screen while the device is offline or the
/// server cannot be reached. A quiet sunken strip with a hairline under it,
/// so it never outshines the content: a caution glyph (or a small spinner
/// while [checking]), the message and an optional action.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.checking = false,
  });

  /// For example "You're offline. Saved scans still open."
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// A re-check is in flight: a spinner replaces the glyph.
  final bool checking;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: KanzSpace.touchTarget),
        padding: const EdgeInsetsDirectional.fromSTEB(
          KanzSpace.gutter,
          KanzSpace.s4,
          KanzSpace.s8,
          KanzSpace.s4,
        ),
        decoration: BoxDecoration(
          color: c.surfaceSunken,
          border: Border(bottom: BorderSide(color: c.line)),
        ),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 18,
              child: Center(
                child: checking
                    ? SizedBox.square(
                        dimension: 14,
                        child: context.reduceMotion
                            ? Icon(KanzIcons.clock, size: 14, color: c.ink)
                            : CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: c.ink,
                              ),
                      )
                    : Icon(KanzIcons.offline, size: 18, color: c.caution),
              ),
            ),
            const SizedBox(width: KanzSpace.s12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: KanzSpace.s8),
                child: Text(
                  message,
                  style: context.textStyles.bodySmall?.copyWith(color: c.ink),
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              KanzButton.tertiary(label: actionLabel!, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}
