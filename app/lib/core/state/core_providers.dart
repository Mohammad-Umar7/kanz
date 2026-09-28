/// Dependency providers: storage, services, repositories and the API client.
///
/// The first group is created once in `main.dart` (async setup) and injected
/// with `overrideWithValue`; tests override the same providers with fakes.
/// Screens never read these directly; they use the controllers in this folder.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/env.dart';
import '../data/db/database.dart';
import '../data/insights/impact.dart';
import '../data/repositories/image_cache_repository.dart';
import '../data/repositories/impact_repository.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/scan_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/vocab/vocab.dart';
import '../network/api_client.dart';
import '../services/app_directories.dart';
import '../services/camera_service.dart';
import '../services/connectivity_service.dart';
import '../services/gallery_picker.dart';
import '../services/image_compressor.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import '../services/share_service.dart';
import '../services/tts_service.dart';
import '../services/voice_command_service.dart';
import 'settings_providers.dart';

// ------------------------------------------------ created at startup (main.dart)

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Overridden in main.dart'),
);

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Overridden in main.dart'),
);

final appDirectoriesProvider = Provider<AppDirectories>(
  (ref) => throw UnimplementedError('Overridden in main.dart'),
);

/// Localized vocabularies (materials, tools, states, hazards, cities...).
final vocabProvider = Provider<Vocab>(
  (ref) => throw UnimplementedError('Overridden in main.dart'),
);

/// Estimate-only CO2e factors for the Impact tab.
final impactFactorsProvider = Provider<ImpactFactors>(
  (ref) => throw UnimplementedError('Overridden in main.dart'),
);

// ------------------------------------------------------------------- network

/// Settings override (runtime) wins over the `KANZ_API_BASE` build default.
final apiBaseUrlProvider = Provider<String>((ref) {
  final override = ref.watch(settingsProvider.select((s) => s.apiBaseUrl));
  return (override == null || override.trim().isEmpty)
      ? Env.apiBase
      : override.trim();
});

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(baseUrl: ref.watch(apiBaseUrlProvider)),
);

// -------------------------------------------------------------- repositories

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

final scanRepositoryProvider = Provider<ScanRepository>(
  (ref) => ScanRepository(ref.watch(appDatabaseProvider)),
);

final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => ProjectRepository(ref.watch(appDatabaseProvider)),
);

final impactRepositoryProvider = Provider<ImpactRepository>(
  (ref) => ImpactRepository(ref.watch(appDatabaseProvider)),
);

final imageCacheRepositoryProvider = Provider<ImageCacheRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return ImageCacheRepository(
    db: ref.watch(appDatabaseProvider),
    directory: ref.watch(appDirectoriesProvider).images,
    download: api.downloadBytes,
  );
});

// ------------------------------------------------------------------ services

final imageCompressorProvider = Provider<ImageCompressor>(
  (ref) => FlutterImageCompressor(
    outputDir: ref.watch(appDirectoriesProvider).scans,
  ),
);

/// One camera owner for the viewfinder (see CameraService docs for lifecycle).
final cameraServiceProvider = Provider<CameraService>((ref) {
  final service = CameraService();
  ref.onDispose(service.stop);
  return service;
});

final galleryPickerProvider = Provider<GalleryPicker>((ref) => GalleryPicker());

final permissionServiceProvider = Provider<PermissionService>(
  (ref) => PermissionService(),
);

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(),
);

final ttsServiceProvider = Provider<TtsService>((ref) {
  final tts = TtsService();
  ref.onDispose(tts.stop);
  return tts;
});

final voiceCommandServiceProvider = Provider<VoiceCommandService>((ref) {
  final voice = VoiceCommandService();
  ref.onDispose(voice.stop);
  return voice;
});

final shareServiceProvider = Provider<ShareService>((ref) => ShareService());
