import 'package:flutter/widgets.dart';

import '../../../core/data/models/models.dart';

/// Text the AI wrote (titles, steps, notes) keeps the direction of the
/// language it was written in. A tutorial made in English and reopened with
/// the app in Arabic reads left to right, with its full stops at the end,
/// while the layout around it follows the app.
TextDirection contentDirection(Lang lang) =>
    lang == Lang.ar ? TextDirection.rtl : TextDirection.ltr;

/// [text] ready for a shared component that lays out its own paragraph (a
/// callout, a source tag): when the content direction differs from the
/// app's, each line is wrapped in a Unicode directional isolate so its
/// punctuation and numbers stay in place. Unchanged otherwise.
String isolateContent(BuildContext context, String text, Lang lang) {
  final direction = contentDirection(lang);
  if (Directionality.of(context) == direction) return text;
  final open = direction == TextDirection.ltr
      ? _leftToRightIsolate
      : _rightToLeftIsolate;
  return text.split('\n').map((line) => '$open$line$_popIsolate').join('\n');
}

// Unicode directional isolates (LRI, RLI and PDI), built from their code
// points so the source shows no invisible characters.
final String _leftToRightIsolate = String.fromCharCode(0x2066);
final String _rightToLeftIsolate = String.fromCharCode(0x2067);
final String _popIsolate = String.fromCharCode(0x2069);
