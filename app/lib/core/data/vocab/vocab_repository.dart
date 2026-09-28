import 'dart:convert';

import 'package:flutter/services.dart';

import 'vocab.dart';

/// Loads the bundled vocabulary once at startup (see `main.dart`).
class VocabRepository {
  VocabRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const assetPath = 'assets/config/vocab.json';

  final AssetBundle _bundle;

  Future<Vocab> load() async {
    final raw = await _bundle.loadString(assetPath);
    return Vocab.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
