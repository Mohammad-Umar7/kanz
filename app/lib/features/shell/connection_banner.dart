import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design/design.dart';
import '../../core/state/connectivity_providers.dart';
import '../../l10n/l10n.dart';

/// The offline notice at the top of the screen, running under the status
/// bar: "offline" when the phone has no network, "can't reach the server"
/// when the network is up but the backend does not answer, and a quiet
/// "checking" while a retry runs (so the notice does not flicker away and
/// back).
class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({
    super.key,
    required this.problem,
    required this.checking,
    required this.onRetry,
  });

  /// [BackendStatus.offline] or [BackendStatus.unreachable].
  final BackendStatus problem;

  /// A re-check is in flight.
  final bool checking;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final message = checking
        ? l10n.shellChecking
        : (problem == BackendStatus.offline
              ? l10n.shellOffline
              : l10n.shellUnreachable);
    // The banner is an inverse surface: light status bar glyphs on the dark
    // ink banner in the light theme, dark ones in the dark theme.
    final lightGlyphs = c.inverse.computeLuminance() < 0.5;
    final overlay =
        (lightGlyphs ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(statusBarColor: Colors.transparent);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: ColoredBox(
        color: c.inverse,
        child: SafeArea(
          bottom: false,
          child: OfflineBanner(
            message: message,
            actionLabel: checking ? null : l10n.shellRetry,
            onAction: checking ? null : onRetry,
          ),
        ),
      ),
    );
  }
}
