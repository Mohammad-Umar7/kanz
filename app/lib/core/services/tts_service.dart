import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import '../data/models/vocab_enums.dart';

/// Reads tutorial steps aloud in the content language (hands-free mode).
class TtsService {
  TtsService({FlutterTts? tts}) : _injected = tts;

  final FlutterTts? _injected;

  // Created on first use: the plugin registers a platform channel handler,
  // which needs the Flutter binding.
  late final FlutterTts _tts = _injected ?? FlutterTts();
  Lang? _lang;
  bool _configured = false;

  /// Voice locales to try per language, most specific first.
  static const _voices = {
    Lang.en: ['en-US', 'en-GB', 'en'],
    Lang.ar: ['ar-AE', 'ar-SA', 'ar'],
  };

  /// Speaks [text] and completes when speech ends (or is stopped).
  /// Returns false when no voice for [lang] is installed on the device.
  Future<bool> speak(String text, Lang lang) async {
    if (!_configured) {
      await _tts.awaitSpeakCompletion(true);
      // Slightly slower than default: instructions are heard while working.
      await _tts.setSpeechRate(0.45);
      _configured = true;
    }
    if (_lang != lang) {
      if (!await _selectVoice(lang)) return false;
      _lang = lang;
    }
    await _tts.speak(text);
    return true;
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<bool> _selectVoice(Lang lang) async {
    for (final locale in _voices[lang]!) {
      final Object? available = await _tts.isLanguageAvailable(locale);
      if (available == true || available == 1) {
        await _tts.setLanguage(locale);
        return true;
      }
    }
    return false;
  }
}
