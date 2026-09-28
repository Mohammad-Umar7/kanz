import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/data/db/database.dart';
import '../core/data/insights/impact.dart';
import '../core/data/vocab/vocab_repository.dart';
import '../core/services/app_directories.dart';
import '../core/state/core_providers.dart';

/// Everything that must exist before the first frame: preferences (theme,
/// language, onboarding), the database, the documents directories, the
/// vocabulary and the impact factors. Returned as provider overrides.
Future<List<Override>> bootstrap() async {
  final prefs = SharedPreferences.getInstance();
  final dirs = AppDirectories.resolve();
  final vocab = VocabRepository().load();
  final factors = ImpactFactors.load();
  return [
    sharedPreferencesProvider.overrideWithValue(await prefs),
    appDirectoriesProvider.overrideWithValue(await dirs),
    vocabProvider.overrideWithValue(await vocab),
    impactFactorsProvider.overrideWithValue(await factors),
    // Opening is lazy: drift connects on the first query, off the UI isolate.
    appDatabaseProvider.overrideWithValue(AppDatabase.open()),
  ];
}

/// Adds the bundled fonts' SIL Open Font License texts to the licenses page.
void registerFontLicenses() {
  const fonts = {
    'Fraunces': 'Fraunces-OFL.txt',
    'IBM Plex Sans': 'IBMPlexSans-OFL.txt',
    'IBM Plex Sans Arabic': 'IBMPlexSansArabic-OFL.txt',
    'IBM Plex Mono': 'IBMPlexMono-OFL.txt',
  };
  LicenseRegistry.addLicense(() async* {
    for (final entry in fonts.entries) {
      final text = await rootBundle.loadString(
        'assets/fonts/licenses/${entry.value}',
      );
      yield LicenseEntryWithLineBreaks([entry.key], text);
    }
  });
}
