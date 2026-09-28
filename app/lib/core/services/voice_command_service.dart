import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

import '../data/models/vocab_enums.dart';

/// Hands-free tutorial commands.
enum VoiceCommand { next, back, repeat }

/// Words that trigger each command, already normalized (see [normalizeSpeech]).
/// Matching is per word, so "ساعد" (help) never triggers "اعد" (repeat).
const _commandWords = <VoiceCommand, Set<String>>{
  VoiceCommand.next: {
    'next',
    'forward',
    'continue',
    'التالي',
    'تالي',
    'التاليه',
  },
  VoiceCommand.back: {'back', 'previous', 'السابق', 'سابق', 'رجوع', 'ارجع'},
  VoiceCommand.repeat: {
    'repeat',
    'again',
    'كرر',
    'كررها',
    'اعد',
    'اعده',
    'اعاده',
  },
};

final _diacritics = RegExp('[ً-ْٰـ]');
final _alefForms = RegExp('[آأإ]');
final _punctuation = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
final _spaces = RegExp(r'\s+');

/// Lowercases, strips punctuation, Arabic diacritics and tatweel, and unifies
/// alef, taa marbuta and alef maqsura forms, so recognizer spelling variants
/// such as "أعد" / "اعد" or "التالية" / "التاليه" match the same word.
String normalizeSpeech(String input) => input
    .toLowerCase()
    .replaceAll(_diacritics, '')
    .replaceAll(_alefForms, 'ا')
    .replaceAll('ة', 'ه')
    .replaceAll('ى', 'ي')
    .replaceAll(_punctuation, ' ')
    .replaceAll(_spaces, ' ')
    .trim();

/// The command in [words], or null. When several are said, the last one wins
/// ("next, no, go back" -> back).
VoiceCommand? parseVoiceCommand(String words) {
  final tokens = normalizeSpeech(words).split(' ');
  for (final token in tokens.reversed) {
    for (final entry in _commandWords.entries) {
      if (entry.value.contains(token)) return entry.key;
    }
  }
  return null;
}

/// Listens for [VoiceCommand]s in English or Arabic.
///
/// Android's recognizer stops after a few seconds of silence, so the service
/// restarts listening until [stop] is called. Call [pause] while text-to-speech
/// is talking so Kanz does not hear itself.
class VoiceCommandService {
  VoiceCommandService({SpeechToText? speech})
    : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  bool _ready = false;
  bool _active = false;
  bool _paused = false;
  bool _firedThisSession = false;
  Lang _lang = Lang.en;
  void Function(VoiceCommand)? _onCommand;
  void Function(bool listening)? _onListening;
  Timer? _restart;

  /// Asks for microphone and speech permission on first use. False when
  /// speech recognition is unavailable or denied.
  Future<bool> init() async {
    if (_ready) return true;
    try {
      _ready = await _speech.initialize(
        onStatus: _onStatus,
        onError: (_) => _scheduleRestart(),
      );
    } on Exception {
      _ready = false;
    }
    return _ready;
  }

  bool get isListening => _speech.isListening;

  Future<void> start({
    required Lang lang,
    required void Function(VoiceCommand command) onCommand,
    void Function(bool listening)? onListening,
  }) async {
    if (!await init()) return;
    _lang = lang;
    _onCommand = onCommand;
    _onListening = onListening;
    _active = true;
    _paused = false;
    await _listen();
  }

  /// Stops listening temporarily (while speaking).
  Future<void> pause() async {
    _paused = true;
    _restart?.cancel();
    if (_speech.isListening) await _speech.stop();
  }

  Future<void> resume() async {
    if (!_active) return;
    _paused = false;
    await _listen();
  }

  Future<void> stop() async {
    _active = false;
    _restart?.cancel();
    if (_speech.isListening) await _speech.cancel();
    _onListening?.call(false);
  }

  Future<void> _listen() async {
    if (!_active || _paused || _speech.isListening) return;
    _firedThisSession = false;
    try {
      await _speech.listen(
        onResult: (result) {
          if (_firedThisSession) return;
          final command = parseVoiceCommand(result.recognizedWords);
          if (command != null) {
            _firedThisSession = true;
            _onCommand?.call(command);
          }
        },
        listenOptions: SpeechListenOptions(
          localeId: _lang == Lang.ar ? 'ar_AE' : 'en_US',
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 4),
          // React to the command word as soon as it is heard.
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.confirmation,
          // Biases the recognizer toward the command words (Android 13+, iOS).
          contextualPhrases: [
            for (final words in _commandWords.values) ...words,
          ],
        ),
      );
      _onListening?.call(true);
    } on Exception {
      _scheduleRestart();
    }
  }

  void _onStatus(String status) {
    if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      _onListening?.call(false);
      _scheduleRestart();
    }
  }

  void _scheduleRestart() {
    if (!_active || _paused) return;
    _restart?.cancel();
    _restart = Timer(const Duration(milliseconds: 400), _listen);
  }
}
