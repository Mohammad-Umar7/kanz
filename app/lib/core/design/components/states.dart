import 'package:flutter/material.dart';

import '../context.dart';
import '../icons.dart';
import '../tokens.dart';
import 'buttons.dart';
import 'data.dart';

/// Nothing here yet: a glyph in a hairline circle, a Fraunces title, one
/// sentence and at most one action. Start-aligned like the rest of Kanz.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: KanzSpace.gutter,
        vertical: KanzSpace.s32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.lineStrong),
            ),
            child: Icon(icon, size: 24, color: c.ink),
          ),
          const SizedBox(height: KanzSpace.s20),
          Semantics(header: true, child: Text(title, style: t.headlineSmall)),
          const SizedBox(height: KanzSpace.s8),
          Text(message, style: t.bodyMedium?.copyWith(color: c.inkSecondary)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: KanzSpace.s24),
            KanzButton.secondary(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

/// Something failed: what happened in plain words, a retry, and optionally
/// the error code in mono for support.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    this.code,
    this.icon = KanzIcons.error,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  /// For example "ai_unavailable · req_5f3c2a1b".
  final String? code;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: KanzSpace.gutter,
          vertical: KanzSpace.s24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: c.danger),
            const SizedBox(height: KanzSpace.s12),
            Text(title, style: t.titleLarge),
            const SizedBox(height: KanzSpace.s4),
            Text(message, style: t.bodyMedium?.copyWith(color: c.inkSecondary)),
            const SizedBox(height: KanzSpace.s20),
            KanzButton.secondary(
              label: retryLabel,
              icon: KanzIcons.retry,
              onPressed: onRetry,
            ),
            if (code != null) ...[
              const SizedBox(height: KanzSpace.s16),
              MonoLabel(code!, uppercase: false),
            ],
          ],
        ),
      ),
    );
  }
}

/// A thin notice at the top of a screen while the device is offline.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  /// For example "You're offline. Saved scans still open."
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.fromSTEB(
          KanzSpace.gutter,
          KanzSpace.s8,
          KanzSpace.s8,
          KanzSpace.s8,
        ),
        decoration: BoxDecoration(color: c.inverse),
        child: Row(
          children: [
            Icon(KanzIcons.offline, size: 18, color: c.onInverse),
            const SizedBox(width: KanzSpace.s12),
            Expanded(
              child: Text(
                message,
                style: context.textStyles.bodySmall?.copyWith(
                  color: c.onInverse,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(foregroundColor: c.onInverse),
                child: Text(actionLabel!),
              )
            else
              const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
