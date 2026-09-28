import 'dart:async';
import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../l10n/app_localizations.dart';
import '../data/models/models.dart';
import '../services/tts_service.dart';
import '../services/voice_command_service.dart';
import 'core_providers.dart';
import 'tutorial_controller.dart';

export '../services/voice_command_service.dart' show VoiceCommand;

part 'hands_free_controller.freezed.dart';

@freezed
abstract class HandsFreeState with _$HandsFreeState {
  const factory HandsFreeState({
    @Default(false) bool enabled,

    /// The microphone is open for "next", "back" or "repeat".
    @Default(false) bool listening,

    /// A step is being read aloud (listening pauses meanwhile).
    @Default(false) bool speaking,

    /// The last command heard, for a brief on-screen confirmation.
    VoiceCommand? lastCommand,

    /// Speech recognition is unavailable or the microphone was denied:
    /// steps are still read aloud, navigation stays on the buttons.
    @Default(false) bool voiceUnavailable,

    /// No text-to-speech voice for the tutorial language on this phone.
    @Default(false) bool speechUnavailable,
  }) = _HandsFreeState;
}

/// Hands-free mode for one tutorial: reads each step aloud and moves through
/// the steps on voice commands. Auto-disposed with the tutorial screen, which
/// stops the microphone and speech.
final handsFreeProvider = NotifierProvider.autoDispose
    .family<HandsFreeController, HandsFreeState, TutorialKey>(
      HandsFreeController.new,
    );

class HandsFreeController extends Notifier<HandsFreeState> {
  HandsFreeController(this.key);

  final TutorialKey key;

  /// Increments per utterance. Only the latest one may reopen the microphone:
  /// an interrupted utterance finishes after its replacement has started.
  int _utterance = 0;

  TtsService get _tts => ref.read(ttsServiceProvider);
  VoiceCommandService get _voice => ref.read(voiceCommandServiceProvider);
  TutorialController get _tutorial =>
      ref.read(tutorialControllerProvider(key).notifier);

  @override
  HandsFreeState build() {
    // Captured here: Riverpod forbids reading providers while disposing.
    final voice = _voice;
    final tts = _tts;
    ref.onDispose(() {
      _utterance++;
      unawaited(voice.stop());
      unawaited(tts.stop());
    });
    // Any step change (voice or tap) is read aloud while hands-free is on.
    ref.listen(tutorialControllerProvider(key).select((s) => s.currentStep), (
      previous,
      next,
    ) {
      if (state.enabled && previous != next) unawaited(speakCurrentStep());
    });
    return const HandsFreeState();
  }

  Future<void> toggle() => state.enabled ? disable() : enable();

  /// Starts listening and reads the current step.
  Future<void> enable() async {
    if (state.enabled) return;
    state = state.copyWith(enabled: true, lastCommand: null);
    final listening = await _voice.start(
      lang: _lang,
      onCommand: _onCommand,
      onListening: (listening) {
        if (ref.mounted) state = state.copyWith(listening: listening);
      },
    );
    if (!ref.mounted) return;
    state = state.copyWith(voiceUnavailable: !listening);
    await speakCurrentStep();
  }

  Future<void> disable() async {
    _utterance++;
    state = state.copyWith(enabled: false, listening: false, speaking: false);
    await _voice.stop();
    await _tts.stop();
  }

  /// Reads the current step: number, title, instruction, then any warning
  /// and tip. The microphone pauses so Kanz does not hear itself.
  Future<void> speakCurrentStep() async {
    final tutorialState = ref.read(tutorialControllerProvider(key));
    final step = tutorialState.step(tutorialState.currentStep);
    if (step == null) return;
    final l10n = lookupAppLocalizations(Locale(_lang.id));
    final text = [
      '${l10n.commonStepNumber(step.number)}. ${step.title}.',
      step.instruction,
      if (step.warning != null) '${l10n.commonSpeechCareful}: ${step.warning}',
      if (step.tip != null) '${l10n.commonSpeechTip}: ${step.tip}',
    ].join(' ');

    final utterance = ++_utterance;
    await _tts.stop();
    await _voice.pause();
    if (!ref.mounted || utterance != _utterance) return;
    state = state.copyWith(speaking: true);
    final spoken = await _tts.speak(text, _lang);
    if (!ref.mounted || utterance != _utterance) return;
    state = state.copyWith(speaking: false, speechUnavailable: !spoken);
    if (state.enabled) await _voice.resume();
  }

  void _onCommand(VoiceCommand command) {
    if (!ref.mounted || !state.enabled) return;
    state = state.copyWith(lastCommand: command);
    final tutorial = ref.read(tutorialControllerProvider(key));
    switch (command) {
      case VoiceCommand.next:
        if (tutorial.isLastStep) {
          unawaited(speakCurrentStep());
        } else {
          unawaited(_tutorial.next());
        }
      case VoiceCommand.back:
        if (tutorial.isFirstStep) {
          unawaited(speakCurrentStep());
        } else {
          unawaited(_tutorial.previous());
        }
      case VoiceCommand.repeat:
        unawaited(speakCurrentStep());
    }
  }

  /// Tutorials are read in the language they were written in.
  Lang get _lang =>
      ref.read(tutorialControllerProvider(key)).tutorial?.lang ?? Lang.en;
}
