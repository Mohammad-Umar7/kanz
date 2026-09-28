import 'package:flutter/material.dart';

import '../../../core/design/design.dart';
import '../../../core/state/hands_free_controller.dart';
import '../../../l10n/l10n.dart';

/// Aligns the second line of a strip with the text after its 18 dp glyph.
const double _indent = 18 + KanzSpace.s8;

/// Hands-free status under the app bar: what the phone is doing (listening
/// in clay, reading a step aloud), the commands it understands, the last one
/// it heard, and one plain line when voice or speech is not available.
class HandsFreeStrip extends StatelessWidget {
  const HandsFreeStrip({
    super.key,
    required this.state,
    required this.currentStep,
  });

  final HandsFreeState state;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final noVoice = state.voiceUnavailable;
    final noSpeech = state.speechUnavailable;

    final (IconData icon, Color tint, String status) = switch (state) {
      HandsFreeState(speaking: true) => (
        KanzIcons.speaker,
        c.ink,
        l10n.tutorialSpeaking(currentStep),
      ),
      HandsFreeState(listening: true) => (
        KanzIcons.microphone,
        c.accent,
        l10n.tutorialListening,
      ),
      _ when noVoice => (
        KanzIcons.speaker,
        c.inkSecondary,
        l10n.tutorialHandsFreeOn,
      ),
      _ => (
        KanzIcons.microphone,
        c.inkSecondary,
        l10n.tutorialHandsFreeStarting,
      ),
    };
    final command = switch (state.lastCommand) {
      VoiceCommand.next => l10n.tutorialCommandNext,
      VoiceCommand.back => l10n.tutorialCommandBack,
      VoiceCommand.repeat => l10n.tutorialCommandRepeat,
      null => null,
    };
    final String? note = noVoice && noSpeech
        ? l10n.tutorialNoHandsFree
        : noVoice
        ? l10n.tutorialNoVoice
        : noSpeech
        ? l10n.tutorialNoSpeech
        : null;

    return Container(
      key: const ValueKey('hands-free-strip'),
      width: double.infinity,
      color: c.surfaceSunken,
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s8,
        KanzSpace.gutter,
        KanzSpace.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            liveRegion: true,
            container: true,
            child: Row(
              children: [
                Icon(icon, size: 18, color: tint),
                const SizedBox(width: KanzSpace.s8),
                Expanded(
                  child: Wrap(
                    spacing: KanzSpace.s12,
                    runSpacing: KanzSpace.s2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(status, style: t.labelLarge),
                      if (command != null)
                        Text(
                          l10n.tutorialHeard(command),
                          style: t.labelMedium?.copyWith(color: c.inkSecondary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!noVoice) ...[
            const SizedBox(height: KanzSpace.s2),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: _indent),
              child: Text(l10n.tutorialVoiceHint, style: t.bodySmall),
            ),
          ],
          if (note != null) ...[
            const SizedBox(height: KanzSpace.s4),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: _indent),
              child: Text(note, style: t.bodySmall),
            ),
          ],
        ],
      ),
    );
  }
}

/// While a new version of the tutorial is being written: a thin progress
/// line and one sentence saying what is happening. The old steps stay.
class AdaptingStrip extends StatelessWidget {
  const AdaptingStrip({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Semantics(
      liveRegion: true,
      container: true,
      child: ColoredBox(
        color: c.surfaceSunken,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // With reduced motion the sentence alone says what is happening.
            if (context.reduceMotion)
              SizedBox(height: 2, child: ColoredBox(color: c.track))
            else
              LinearProgressIndicator(
                minHeight: 2,
                borderRadius: BorderRadius.zero,
                color: c.ink,
                backgroundColor: c.track,
              ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                KanzSpace.gutter,
                KanzSpace.s8,
                KanzSpace.gutter,
                KanzSpace.s12,
              ),
              child: Text(
                message,
                style: context.textStyles.bodySmall?.copyWith(color: c.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Adapting failed: what happened, a retry when it can help, and a way to
/// put the note away. The current tutorial is untouched.
class AdaptErrorStrip extends StatelessWidget {
  const AdaptErrorStrip({
    super.key,
    required this.message,
    required this.retryLabel,
    required this.dismissLabel,
    required this.onRetry,
    required this.onDismiss,
  });

  final String message;
  final String retryLabel;
  final String dismissLabel;
  final VoidCallback? onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        color: c.surfaceSunken,
        padding: const EdgeInsetsDirectional.fromSTEB(
          KanzSpace.gutter,
          KanzSpace.s4,
          KanzSpace.s4,
          KanzSpace.s4,
        ),
        child: Row(
          children: [
            Icon(KanzIcons.error, size: 18, color: c.danger),
            const SizedBox(width: KanzSpace.s8),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: KanzSpace.s8,
                ),
                child: Text(
                  message,
                  style: context.textStyles.bodySmall?.copyWith(color: c.ink),
                ),
              ),
            ),
            if (onRetry != null)
              KanzButton.tertiary(label: retryLabel, onPressed: onRetry),
            KanzIconButton(
              icon: KanzIcons.close,
              semanticsLabel: dismissLabel,
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
