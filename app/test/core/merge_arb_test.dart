import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/merge_arb.dart';

void main() {
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('kanz_arb'));
  tearDown(() => dir.delete(recursive: true));

  void write(String name, Map<String, Object?> json) =>
      File('${dir.path}/$name').writeAsStringSync(jsonEncode(json));

  test('merges fragments per locale, sorted, with metadata after its key', () {
    write('results_en.arb', {
      '@@locale': 'en',
      'resultsTitle': 'Results',
      '@resultsTitle': {'description': 'Screen title'},
    });
    write('common_en.arb', {'@@locale': 'en', 'commonRetry': 'Try again'});
    write('common_ar.arb', {'@@locale': 'ar', 'commonRetry': 'حاول مجدداً'});
    write('results_ar.arb', {'@@locale': 'ar', 'resultsTitle': 'النتائج'});

    final merged = mergeArbDirectory(dir);

    expect(merged.locales['en']!.keys.toList(), [
      '@@locale',
      'commonRetry',
      'resultsTitle',
      '@resultsTitle',
    ]);
    expect(merged.locales['ar']!['@@locale'], 'ar');
    expect(merged.locales['ar']!['resultsTitle'], 'النتائج');
    expect(merged.warnings, isEmpty);
  });

  test('fails on a key defined in two fragments', () {
    write('a_en.arb', {'sharedKey': 'A'});
    write('b_en.arb', {'sharedKey': 'B'});

    expect(
      () => mergeArbDirectory(dir),
      throwsA(
        isA<ArbMergeException>().having(
          (e) => e.errors.single,
          'error',
          contains('duplicate key "sharedKey"'),
        ),
      ),
    );
  });

  test('fails on an Arabic key missing from the English template', () {
    write('a_en.arb', {'aTitle': 'Title'});
    write('a_ar.arb', {'aTitle': 'عنوان', 'aExtra': 'زائد'});

    expect(() => mergeArbDirectory(dir), throwsA(isA<ArbMergeException>()));
  });

  test('fails on metadata without its message', () {
    write('a_en.arb', {
      '@aOrphan': {'description': 'no message'},
    });

    expect(() => mergeArbDirectory(dir), throwsA(isA<ArbMergeException>()));
  });

  test('warns about untranslated keys without failing', () {
    write('a_en.arb', {'aTitle': 'Title', 'aBody': 'Body'});
    write('a_ar.arb', {'aTitle': 'عنوان'});

    final merged = mergeArbDirectory(dir);

    expect(merged.warnings.single, contains('"aBody" has no ar translation'));
  });

  test('the committed app ARB files are up to date with the fragments', () {
    final merged = mergeArbDirectory(Directory('lib/l10n/src'));
    for (final entry in merged.locales.entries) {
      expect(
        File('lib/l10n/app_${entry.key}.arb').readAsStringSync(),
        encodeArb(entry.value),
        reason: 'run: dart run tool/merge_arb.dart && flutter gen-l10n',
      );
    }
  });
}
