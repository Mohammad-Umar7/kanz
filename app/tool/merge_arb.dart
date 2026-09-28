// Merges the per-feature ARB fragments into the two files `flutter gen-l10n`
// reads.
//
//   dart run tool/merge_arb.dart     (from app/)
//   flutter gen-l10n
//
// Every feature owns `lib/l10n/src/<feature>_{en,ar}.arb` with keys prefixed by
// the feature name, so four screen teams can add strings without editing one
// shared file. This tool joins them into `lib/l10n/app_en.arb` and
// `lib/l10n/app_ar.arb`: keys sorted, each `@key` metadata block kept right
// after its message, and a hard failure on any key defined twice or on an
// Arabic key with no English template.
import 'dart:convert';
import 'dart:io';

/// Result of merging one directory of fragments.
class ArbMerge {
  ArbMerge(this.locales, this.warnings);

  /// Locale -> merged ARB map (already sorted, with `@@locale` first).
  final Map<String, Map<String, Object?>> locales;

  /// Non-fatal findings, such as English keys with no Arabic translation yet.
  final List<String> warnings;
}

class ArbMergeException implements Exception {
  ArbMergeException(this.errors);

  final List<String> errors;

  @override
  String toString() => 'ARB merge failed:\n  ${errors.join('\n  ')}';
}

final _fragmentName = RegExp(r'^([a-z0-9_]+)_([a-z]{2})\.arb$');

/// Reads every `<name>_<locale>.arb` in [dir] and merges them per locale.
/// Throws [ArbMergeException] listing every problem found.
ArbMerge mergeArbDirectory(Directory dir, {String templateLocale = 'en'}) {
  final errors = <String>[];
  final warnings = <String>[];
  final messages = <String, Map<String, Object?>>{};
  final metadata = <String, Map<String, Object?>>{};
  final origin = <String, Map<String, String>>{};

  final files =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.arb'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final name = file.uri.pathSegments.last;
    final match = _fragmentName.firstMatch(name);
    if (match == null) {
      errors.add('$name: expected <feature>_<locale>.arb');
      continue;
    }
    final locale = match.group(2)!;
    final Map<String, Object?> json;
    try {
      json = (jsonDecode(file.readAsStringSync()) as Map)
          .cast<String, Object?>();
    } on FormatException catch (e) {
      errors.add('$name: invalid JSON (${e.message})');
      continue;
    }

    final localeMessages = messages.putIfAbsent(locale, () => {});
    final localeMetadata = metadata.putIfAbsent(locale, () => {});
    final localeOrigin = origin.putIfAbsent(locale, () => {});

    for (final entry in json.entries) {
      final key = entry.key;
      // File-level attributes such as @@locale are rewritten on output.
      if (key.startsWith('@@')) continue;
      if (key.startsWith('@')) {
        final target = key.substring(1);
        if (!json.containsKey(target)) {
          errors.add('$name: metadata "$key" has no message "$target"');
        }
        localeMetadata[target] = entry.value;
        continue;
      }
      final previous = localeOrigin[key];
      if (previous != null) {
        errors.add('duplicate key "$key" in $previous and $name');
        continue;
      }
      localeOrigin[key] = name;
      localeMessages[key] = entry.value;
    }
  }

  final template = messages[templateLocale] ?? const {};
  for (final locale in messages.keys.where((l) => l != templateLocale)) {
    for (final key in messages[locale]!.keys) {
      if (!template.containsKey(key)) {
        errors.add(
          '"$key" exists in $locale but not in the $templateLocale template',
        );
      }
    }
    for (final key in template.keys) {
      if (!messages[locale]!.containsKey(key)) {
        warnings.add('"$key" has no $locale translation yet');
      }
    }
  }

  if (errors.isNotEmpty) throw ArbMergeException(errors);

  final merged = <String, Map<String, Object?>>{};
  for (final locale in messages.keys) {
    final out = <String, Object?>{'@@locale': locale};
    final keys = messages[locale]!.keys.toList()..sort();
    for (final key in keys) {
      out[key] = messages[locale]![key];
      final meta = metadata[locale]![key];
      if (meta != null) out['@$key'] = meta;
    }
    merged[locale] = out;
  }
  return ArbMerge(merged, warnings);
}

/// Two-space indented JSON with a trailing newline, as gen-l10n writes it.
String encodeArb(Map<String, Object?> arb) =>
    '${const JsonEncoder.withIndent('  ').convert(arb)}\n';

void main(List<String> args) {
  final root = args.isNotEmpty ? args.first : 'lib/l10n';
  final source = Directory('$root/src');
  if (!source.existsSync()) {
    stderr.writeln('No fragments directory at ${source.path}');
    exitCode = 2;
    return;
  }
  try {
    final result = mergeArbDirectory(source);
    for (final entry in result.locales.entries) {
      final out = File('$root/app_${entry.key}.arb');
      out.writeAsStringSync(encodeArb(entry.value));
      final count = entry.value.keys.where((k) => !k.startsWith('@')).length;
      stdout.writeln('wrote ${out.path} ($count messages)');
    }
    for (final warning in result.warnings) {
      stdout.writeln('warning: $warning');
    }
  } on ArbMergeException catch (e) {
    stderr.writeln(e);
    exitCode = 1;
  }
}
