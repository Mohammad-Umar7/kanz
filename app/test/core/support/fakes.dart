import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanz/core/data/db/database.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/data/vocab/vocab.dart';
import 'package:kanz/core/network/api_client.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/core/services/app_directories.dart';
import 'package:kanz/core/services/image_compressor.dart';
import 'package:kanz/core/services/location_service.dart';
import 'package:kanz/core/services/permission_service.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';
import 'test_db.dart';

/// An [ApiClient] that answers from contract fixtures and records every call.
/// Set a field to change an answer; throw an [ApiException] to fail it.
class FakeApi implements ApiClient {
  final List<String> calls = [];
  final List<RecommendRequest> recommendRequests = [];
  final List<TutorialRequest> tutorialRequests = [];
  final List<FacilitiesRequest> facilitiesRequests = [];
  final List<AfterImageRequest> afterRequests = [];
  final List<StepImageRequest> stepRequests = [];
  final List<Lang> categoryLangs = [];
  final List<String> analyzedTexts = [];

  Future<AnalyzeResponse> Function() onAnalyze = () async =>
      AnalyzeResponse.fromJson(fixture('analyze_glass_jar.json'));
  Future<RecommendResponse> Function() onRecommend = () async =>
      RecommendResponse.fromJson(fixture('recommend_glass_jar.json'));
  Future<FacilitiesResponse> Function() onFacilities = () async =>
      FacilitiesResponse.fromJson(fixture('facilities_glass.json'));
  Future<FacilityCategoriesResponse> Function() onCategories = () async =>
      FacilityCategoriesResponse.fromJson(fixture('facility_categories.json'));
  Future<TutorialResponse> Function(TutorialRequest) onTutorial = (req) async =>
      TutorialResponse.fromJson(fixture('tutorial_jar_lantern.json'));
  Future<ImageResponse> Function(AfterImageRequest) onAfter = (req) async =>
      ImageResponse.fromJson(fixture('image_after.json')).copyWith(
        url: '/static/generated/${req.imageId}/after_${req.idea.id}.jpg',
        key: '${req.imageId}:after:${req.idea.id}',
      );
  Future<ImageResponse> Function(StepImageRequest) onStep = (req) async =>
      ImageResponse.fromJson(fixture('image_step.json')).copyWith(
        url:
            '/static/generated/${req.imageId}/step_${req.tutorialId}_${req.step}.jpg',
        key: '${req.tutorialId}:step:${req.step}',
        step: req.step,
      );

  @override
  String get baseUrl => 'http://kanz.test';

  @override
  Duration get retryDelay => Duration.zero;

  @override
  String resolveUrl(String pathOrUrl) =>
      pathOrUrl.startsWith('http') ? pathOrUrl : '$baseUrl$pathOrUrl';

  @override
  Future<HealthResponse> health({CancelToken? cancelToken}) async {
    calls.add('health');
    return HealthResponse.fromJson(fixture('health.json'));
  }

  @override
  Future<AnalyzeResponse> analyzePhoto(
    Uint8List jpegBytes, {
    required Lang lang,
    String filename = 'scan.jpg',
    CancelToken? cancelToken,
  }) {
    calls.add('analyze');
    return onAnalyze();
  }

  @override
  Future<AnalyzeResponse> analyzeText(
    String text, {
    required Lang lang,
    CancelToken? cancelToken,
  }) {
    calls.add('analyze');
    analyzedTexts.add(text);
    return onAnalyze();
  }

  @override
  Future<RecommendResponse> recommend(
    RecommendRequest request, {
    CancelToken? cancelToken,
  }) {
    calls.add('recommend');
    recommendRequests.add(request);
    return onRecommend();
  }

  @override
  Future<TutorialResponse> tutorial(
    TutorialRequest request, {
    CancelToken? cancelToken,
  }) {
    calls.add('tutorial');
    tutorialRequests.add(request);
    return onTutorial(request);
  }

  @override
  Future<ImageResponse> afterImage(
    AfterImageRequest request, {
    CancelToken? cancelToken,
  }) {
    calls.add('after');
    afterRequests.add(request);
    return onAfter(request);
  }

  @override
  Future<ImageResponse> stepImage(
    StepImageRequest request, {
    CancelToken? cancelToken,
  }) {
    calls.add('step:${request.step}');
    stepRequests.add(request);
    return onStep(request);
  }

  @override
  Future<ImageResponse> binImage(
    BinImageRequest request, {
    CancelToken? cancelToken,
  }) async => throw UnimplementedError();

  @override
  Future<FacilitiesResponse> facilities(
    FacilitiesRequest request, {
    CancelToken? cancelToken,
  }) {
    calls.add('facilities');
    facilitiesRequests.add(request);
    return onFacilities();
  }

  @override
  Future<FacilityCategoriesResponse> facilityCategories({
    required Lang lang,
    CancelToken? cancelToken,
  }) {
    calls.add('categories');
    categoryLangs.add(lang);
    return onCategories();
  }

  @override
  Future<SwapsResponse> swaps(
    SwapsRequest request, {
    CancelToken? cancelToken,
  }) async {
    calls.add('swaps');
    return SwapsResponse.fromJson(fixture('swaps_plastic.json'));
  }

  @override
  Future<Uint8List> downloadBytes(
    String pathOrUrl, {
    CancelToken? cancelToken,
  }) async => Uint8List.fromList(utf8.encode(pathOrUrl));
}

/// Writes the input bytes as the "compressed" photo.
class FakeCompressor implements ImageCompressor {
  FakeCompressor(this.dir);

  final Directory dir;

  @override
  Future<CompressedImage> compressBytes(
    Uint8List source, {
    required String scanId,
  }) async {
    final file = File('${dir.path}/$scanId.jpg')..writeAsBytesSync(source);
    return CompressedImage(bytes: source, path: file.path);
  }

  @override
  Future<CompressedImage> compressFile(
    String sourcePath, {
    required String scanId,
  }) async => compressBytes(File(sourcePath).readAsBytesSync(), scanId: scanId);
}

class FakePermissions implements PermissionService {
  PermissionState location = PermissionState.denied;

  /// Thrown by [status] when set, like a platform channel failure.
  Object? statusError;

  @override
  Future<PermissionState> status(AppPermission permission) async {
    if (statusError case final error?) throw error;
    return permission == AppPermission.location
        ? location
        : PermissionState.granted;
  }

  @override
  Future<PermissionState> request(AppPermission permission) =>
      status(permission);

  @override
  Future<bool> openSettings() async => true;
}

class FakeLocation implements LocationService {
  LocationFix? fix;

  @override
  Future<LocationFix?> current() async => fix;
}

/// Everything a controller test needs, wired like the real app.
class TestHarness {
  TestHarness._(
    this.container,
    this.api,
    this.db,
    this.dir,
    this.permissions,
    this.location,
  );

  final ProviderContainer container;
  final FakeApi api;
  final AppDatabase db;
  final Directory dir;
  final FakePermissions permissions;
  final FakeLocation location;

  /// [prefs] seeds shared preferences, e.g. {'settings.location_mode': 'city'}.
  static Future<TestHarness> create({
    Map<String, Object> prefs = const {},
    FakeApi? api,
    AppDatabase? db,
    Directory? dir,
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final preferences = await SharedPreferences.getInstance();
    final fakeApi = api ?? FakeApi();
    final database = db ?? memoryDatabase();
    final directory = dir ?? await Directory.systemTemp.createTemp('kanz_test');
    final permissions = FakePermissions();
    final location = FakeLocation();
    final vocab = Vocab.fromJson(
      jsonDecode(File('assets/config/vocab.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appDatabaseProvider.overrideWithValue(database),
        appDirectoriesProvider.overrideWithValue(AppDirectories(directory)),
        vocabProvider.overrideWithValue(vocab),
        apiClientProvider.overrideWithValue(fakeApi),
        imageCompressorProvider.overrideWithValue(FakeCompressor(directory)),
        permissionServiceProvider.overrideWithValue(permissions),
        locationServiceProvider.overrideWithValue(location),
      ],
      retry: (count, error) => null,
    );
    return TestHarness._(
      container,
      fakeApi,
      database,
      directory,
      permissions,
      location,
    );
  }

  Future<void> dispose({bool keepDatabase = false}) async {
    container.dispose();
    if (!keepDatabase) {
      await db.close();
      if (dir.existsSync()) await dir.delete(recursive: true);
    }
  }
}

/// Lets queued futures, timers and file IO run until [done] holds.
Future<void> waitFor(
  bool Function() done, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final watch = Stopwatch()..start();
  while (!done()) {
    if (watch.elapsed > timeout) {
      throw TimeoutException('Condition not met in $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}
