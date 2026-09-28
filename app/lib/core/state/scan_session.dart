import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/db/database.dart' show ImpactKind;
import '../data/models/models.dart';
import '../data/repositories/scan_repository.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../services/image_compressor.dart';
import 'core_providers.dart';
import 'generated_image.dart';
import 'location_resolver.dart';
import 'scan_session_state.dart';
import 'settings_providers.dart';

export 'generated_image.dart';
export 'scan_session_state.dart';

/// A new id for a scan, created by the scan screen before navigating to
/// `/results/:scanId`.
String newScanId() => const Uuid().v4();

/// One scan's whole pipeline, keyed by scan id. Kept alive for the app run so
/// results, idea and tutorial screens share it; reopening an id from History
/// restores it from the database (works offline).
final scanSessionProvider =
    NotifierProvider.family<ScanSession, ScanSessionState, String>(
      ScanSession.new,
    );

/// Runs analyze -> recommend -> (drop-off || 3 after images) and persists every
/// stage so the scan can be reopened later.
///
/// Every chain of calls carries a generation number and a cancel token: a
/// correction or retry starts a new generation and late answers from the old
/// one are dropped instead of overwriting newer results.
class ScanSession extends Notifier<ScanSessionState> {
  ScanSession(this.scanId);

  final String scanId;

  int _chain = 0;
  CancelToken? _chainToken;
  int _dropoffRun = 0;
  CancelToken? _dropoffToken;
  final Map<String, int> _imageRuns = {};
  bool _started = false;
  Uint8List? _photo;

  ApiClient get _api => ref.read(apiClientProvider);
  ScanRepository get _scans => ref.read(scanRepositoryProvider);

  @override
  ScanSessionState build() {
    ref.onDispose(() {
      _chainToken?.cancel();
      _dropoffToken?.cancel();
    });
    scheduleMicrotask(_restore);
    return ScanSessionState(scanId: scanId);
  }

  // ------------------------------------------------------------------ start

  /// Starts a photo scan from a camera or gallery file ([path]) or raw [bytes].
  Future<void> startFromPhoto({String? path, Uint8List? bytes}) async {
    assert(path != null || bytes != null, 'Pass a path or bytes');
    _started = true;
    final lang = ref.read(contentLangProvider);
    state = ScanSessionState(
      scanId: scanId,
      origin: ScanOrigin.live,
      lang: lang,
      stages: {
        PipelineStage.identifying: const StageState(
          status: StageStatus.running,
        ),
      },
    );
    final CompressedImage image;
    try {
      final compressor = ref.read(imageCompressorProvider);
      image = path != null
          ? await compressor.compressFile(path, scanId: scanId)
          : await compressor.compressBytes(bytes!, scanId: scanId);
    } on Object catch (e) {
      // Not a decodable image: the same outcome the backend would report.
      _setStage(
        PipelineStage.identifying,
        StageStatus.failed,
        error: ApiException(
          code: ApiErrorCode.imageInvalid,
          message: '$e',
          retryable: false,
        ),
      );
      return;
    }
    _photo = image.bytes;
    if (!ref.mounted) return;
    state = state.copyWith(localImagePath: image.path);
    await _save(
      () => _scans.create(
        id: scanId,
        source: AnalysisSource.image,
        lang: lang,
        localImagePath: image.path,
      ),
    );
    await _analyze();
  }

  /// Longest description the Material Analyst reads; the backend ignores the
  /// rest. Use it as the text field's `maxLength` on the scan screen.
  static const maxDescriptionLength = 600;

  /// Starts a scan from a description such as "a pile of old denim jeans".
  Future<void> startFromText(String text) async {
    _started = true;
    final lang = ref.read(contentLangProvider);
    var description = text.trim();
    if (description.length > maxDescriptionLength) {
      description = description.substring(0, maxDescriptionLength).trim();
    }
    state = ScanSessionState(
      scanId: scanId,
      origin: ScanOrigin.live,
      source: AnalysisSource.text,
      lang: lang,
      inputText: description,
    );
    await _save(
      () => _scans.create(
        id: scanId,
        source: AnalysisSource.text,
        lang: lang,
        inputText: description,
      ),
    );
    await _analyze();
  }

  // ---------------------------------------------------------------- actions

  /// Retries one failed stage (and whatever depends on it).
  Future<void> retry(PipelineStage stage) => switch (stage) {
    PipelineStage.identifying => _analyze(),
    PipelineStage.ideas => _recommend(_newChain()),
    PipelineStage.dropoff => _dropoff(),
    PipelineStage.makeovers => _retryFailedImages(),
  };

  /// Continues the drop-off stage after the user granted location or picked
  /// a city (status was [StageStatus.needsLocation]).
  Future<void> resumeDropoff() => _dropoff();

  /// Applies the user's correction to an item, marks it `user_corrected` and
  /// re-runs recommend, drop-off and makeovers with the corrected analysis.
  Future<void> correctItem(String itemId, ItemCorrection changes) async {
    final response = state.analysis;
    if (response == null) return;
    final vocab = ref.read(vocabProvider);
    final corrected = response.copyWith(
      analysis: response.analysis.copyWith(
        items: [
          for (final item in response.analysis.items)
            item.id == itemId
                ? changes.applyTo(item, vocab: vocab, lang: state.lang)
                : item,
        ],
      ),
    );
    state = state.copyWith(analysis: corrected);
    await _save(() => _scans.saveAnalysis(scanId, corrected));
    await _recommend(_newChain());
  }

  /// Focuses the ideas on another item of a multi-item photo.
  Future<void> focusItem(String itemId) async {
    if (itemId == state.focusItemId) return;
    state = state.copyWith(focusItemId: itemId);
    await _save(() => _scans.saveFocus(scanId, itemId));
    await _recommend(_newChain());
  }

  /// Asks for a new after image for one idea.
  Future<void> regenerateAfterImage(String ideaId) async {
    final idea = state.recommendation?.ideaById(ideaId);
    if (idea == null) return;
    _setStage(PipelineStage.makeovers, StageStatus.running);
    await _afterImage(idea, _chain, regenerate: true);
    _settleMakeovers(_chain);
    await _persistStages();
  }

  Future<void> markRecycled(Iterable<String> itemIds) =>
      _mark(ImpactKind.recycled, itemIds);

  Future<void> markDonated(Iterable<String> itemIds) =>
      _mark(ImpactKind.donated, itemIds);

  /// For hazardous items handed in at a collection point.
  Future<void> markDisposed(Iterable<String> itemIds) =>
      _mark(ImpactKind.disposed, itemIds);

  // --------------------------------------------------------------- pipeline

  int _newChain() {
    _chainToken?.cancel();
    _chainToken = CancelToken();
    _dropoffToken?.cancel();
    _dropoffRun++;
    return ++_chain;
  }

  bool _current(int chain) => ref.mounted && chain == _chain;

  Future<void> _analyze() async {
    final chain = _newChain();
    state = state.copyWith(
      rejectedPhoto: null,
      recommendation: null,
      facilities: null,
      afterImages: const {},
      stages: {
        PipelineStage.identifying: const StageState(
          status: StageStatus.running,
        ),
      },
    );
    await _persistStages();
    try {
      final AnalyzeResponse response;
      if (state.source == AnalysisSource.text) {
        response = await _api.analyzeText(
          state.inputText ?? '',
          lang: state.lang,
          cancelToken: _chainToken,
        );
      } else {
        final photo = _photo ??= await _readLocalPhoto();
        response = await _api.analyzePhoto(
          photo,
          lang: state.lang,
          cancelToken: _chainToken,
        );
      }
      if (!_current(chain)) return;
      await _save(() => _scans.saveAnalysis(scanId, response));
      final photo = response.analysis.photo;
      if (!photo.usable || response.analysis.items.isEmpty) {
        // The model says it cannot see anything useful: ask for a retake
        // instead of inventing items from a bad photo.
        state = state.copyWith(
          analysis: response,
          rejectedPhoto: photo.usable
              ? photo.copyWith(usable: false, issue: PhotoIssue.noItems)
              : photo,
        );
        _setStage(PipelineStage.identifying, StageStatus.failed);
        await _persistStages();
        return;
      }
      state = state.copyWith(analysis: response);
      _setStage(PipelineStage.identifying, StageStatus.done);
      // Later stages use the backend's image id, not the bytes; a retake or a
      // re-analysis reads the photo back from the device.
      _photo = null;
      await _recommend(chain);
    } on Object catch (error) {
      final e = ApiException.from(error);
      if (!_current(chain) || e.isCancelled) return;
      _setStage(PipelineStage.identifying, StageStatus.failed, error: e);
      await _persistStages();
    }
  }

  Future<void> _recommend(int chain) async {
    final analysis = state.analysis;
    if (analysis == null) return;
    state = state.copyWith(
      recommendation: null,
      facilities: null,
      afterImages: const {},
      stages: {
        ...state.stages,
        PipelineStage.ideas: const StageState(status: StageStatus.running),
        PipelineStage.dropoff: const StageState(),
        PipelineStage.makeovers: const StageState(),
      },
    );
    await _persistStages();
    try {
      final profile = ref.read(profileProvider).copyWith(lang: state.lang);
      final response = await _api.recommend(
        RecommendRequest(
          imageId: analysis.imageId,
          analysis: analysis.analysis,
          profile: profile,
          focusItemId: state.focusItemId,
        ),
        cancelToken: _chainToken,
      );
      if (!_current(chain)) return;
      await _save(() => _scans.saveRecommendation(scanId, response));
      state = state.copyWith(recommendation: response);
      _setStage(PipelineStage.ideas, StageStatus.done);
      await _persistStages();
    } on Object catch (error) {
      final e = ApiException.from(error);
      if (!_current(chain) || e.isCancelled) return;
      _setStage(PipelineStage.ideas, StageStatus.failed, error: e);
      await _persistStages();
      return;
    }
    // Drop-off points and makeovers are independent: run them side by side
    // so places appear without waiting for image generation. Each one ends
    // its own stage, so a failure there never marks the ideas as failed.
    await Future.wait([_dropoff(), _makeovers(chain)]);
  }

  Future<void> _dropoff() async {
    final recommendation = state.recommendation;
    if (recommendation == null) return;
    _dropoffToken?.cancel();
    final token = _dropoffToken = CancelToken();
    final run = ++_dropoffRun;
    bool current() => ref.mounted && run == _dropoffRun;

    final categories = [
      for (final c in recommendation.facilityCategories) c.key,
    ];
    if (categories.isEmpty) {
      _setStage(PipelineStage.dropoff, StageStatus.skipped);
      await _persistStages();
      return;
    }
    _setStage(PipelineStage.dropoff, StageStatus.running);
    try {
      // Inside the try: a permission or GPS plugin error must end this stage,
      // not leave it running.
      final location = await ref
          .read(locationResolverProvider)
          .resolve(ref.read(settingsProvider));
      if (!current()) return;
      if (location == null) {
        _setStage(PipelineStage.dropoff, StageStatus.needsLocation);
        await _persistStages();
        return;
      }
      state = state.copyWith(dropoffLocation: location);
      final response = await _api.facilities(
        location.toRequest(categories, state.lang),
        cancelToken: token,
      );
      if (!current()) return;
      await _save(() => _scans.saveFacilities(scanId, response));
      state = state.copyWith(facilities: response);
      _setStage(PipelineStage.dropoff, StageStatus.done);
    } on Object catch (error) {
      final e = ApiException.from(error);
      if (!current() || e.isCancelled) return;
      _setStage(PipelineStage.dropoff, StageStatus.failed, error: e);
    }
    await _persistStages();
  }

  Future<void> _makeovers(int chain) async {
    final recommendation = state.recommendation;
    if (recommendation == null) return;
    if (recommendation.routing.mode == RoutingMode.disposalOnly ||
        recommendation.upcycle.isEmpty) {
      // Hazardous items get no DIY ideas, so there is nothing to render.
      _setStage(PipelineStage.makeovers, StageStatus.skipped);
      await _persistStages();
      return;
    }
    _setStage(PipelineStage.makeovers, StageStatus.running);
    await Future.wait([
      if (state.source == AnalysisSource.text) _referenceImage(chain),
      for (final idea in recommendation.upcycle) _afterImage(idea, chain),
    ]);
    if (!_current(chain)) return;
    _settleMakeovers(chain);
    await _persistStages();
  }

  Future<void> _retryFailedImages() async {
    final chain = _chain;
    // Images still loading keep their request; only finished failures retry.
    final failed = [
      for (final idea in state.ideas)
        if (state.afterImage(idea.id).status == ImageStatus.failed) idea,
    ];
    if (failed.isEmpty) return;
    _setStage(PipelineStage.makeovers, StageStatus.running);
    await Future.wait([for (final idea in failed) _afterImage(idea, chain)]);
    if (!_current(chain)) return;
    _settleMakeovers(chain);
    await _persistStages();
  }

  /// Text scans have no photo: the backend renders one of the described item,
  /// which becomes the "before" picture. It never fails the makeovers stage;
  /// the slider falls back to the description when it is missing.
  Future<void> _referenceImage(int chain) async {
    final analysis = state.analysis;
    if (analysis == null) return;
    final cache = ref.read(imageCacheRepositoryProvider);
    void set(GeneratedImageState image) {
      if (ref.mounted && _current(chain)) {
        state = state.copyWith(referenceImage: image);
      }
    }

    set(const GeneratedImageState(status: ImageStatus.loading));
    try {
      final cached = await cache.referenceImage(scanId);
      if (cached != null) {
        set(
          GeneratedImageState(
            status: ImageStatus.ready,
            url: _api.resolveUrl(cached.remoteUrl),
            localPath: cached.localPath,
          ),
        );
        return;
      }
      final image = await _api.referenceImage(
        ReferenceImageRequest(imageId: analysis.imageId),
        cancelToken: _chainToken,
      );
      final ready = GeneratedImageState(
        status: ImageStatus.ready,
        url: _api.resolveUrl(image.url),
      );
      set(ready);
      try {
        final entry = await cache.store(image, scanId: scanId);
        set(ready.copyWith(localPath: entry.localPath));
      } on Object catch (e) {
        debugPrint('Reference image not cached: $e');
      }
    } on Object catch (error) {
      final e = ApiException.from(error);
      if (e.isCancelled) return;
      set(GeneratedImageState(status: ImageStatus.failed, error: e));
    }
  }

  /// Loads one after image: the offline copy if there is one, otherwise the
  /// backend renders it. The remote URL is shown at once and the download to
  /// the device happens behind it.
  Future<void> _afterImage(
    UpcycleIdea idea,
    int chain, {
    bool regenerate = false,
  }) async {
    final run = (_imageRuns[idea.id] ?? 0) + 1;
    _imageRuns[idea.id] = run;
    bool current() => _current(chain) && _imageRuns[idea.id] == run;
    final analysis = state.analysis;
    if (analysis == null) return;
    final cache = ref.read(imageCacheRepositoryProvider);

    _setImage(idea.id, const GeneratedImageState(status: ImageStatus.loading));
    try {
      if (!regenerate) {
        final cached = await cache.afterImage(scanId, idea.id);
        if (!current()) return;
        if (cached != null) {
          _setImage(
            idea.id,
            GeneratedImageState(
              status: ImageStatus.ready,
              url: _api.resolveUrl(cached.remoteUrl),
              localPath: cached.localPath,
            ),
          );
          return;
        }
      }
      final image = await _api.afterImage(
        AfterImageRequest(
          imageId: analysis.imageId,
          idea: idea,
          regenerate: regenerate,
        ),
        cancelToken: _chainToken,
      );
      if (!current()) return;
      final ready = GeneratedImageState(
        status: ImageStatus.ready,
        url: _api.resolveUrl(image.url),
      );
      _setImage(idea.id, ready);
      try {
        final entry = await cache.store(
          image,
          scanId: scanId,
          ideaId: idea.id,
          force: regenerate,
        );
        if (current()) {
          _setImage(idea.id, ready.copyWith(localPath: entry.localPath));
        }
      } on Object catch (e) {
        // The image still shows from the backend; only offline history misses it.
        debugPrint('After image not cached: $e');
      }
    } on Object catch (error) {
      final e = ApiException.from(error);
      if (!current() || e.isCancelled) return;
      _setImage(
        idea.id,
        GeneratedImageState(status: ImageStatus.failed, error: e),
      );
    }
  }

  /// Makeovers are "done" when at least one image arrived (the others show
  /// their own error and regenerate button) and "failed" when none did.
  void _settleMakeovers(int chain) {
    if (!_current(chain)) return;
    final images = [for (final idea in state.ideas) state.afterImage(idea.id)];
    if (images.any((i) => i.isLoading)) return;
    if (images.any((i) => i.isReady)) {
      _setStage(PipelineStage.makeovers, StageStatus.done);
    } else {
      _setStage(
        PipelineStage.makeovers,
        StageStatus.failed,
        error: images.map((i) => i.error).nonNulls.firstOrNull,
      );
    }
  }

  // ----------------------------------------------------------------- restore

  /// Reopens a scan from History. Stages that were still running when the app
  /// closed are shown as failed ("did not finish") with a retry.
  Future<void> _restore() async {
    final StoredScan? stored;
    try {
      stored = await _scans.get(scanId);
    } on Object catch (e) {
      debugPrint('Scan $scanId could not be restored: $e');
      if (!_started && ref.mounted) {
        state = state.copyWith(origin: ScanOrigin.missing);
      }
      return;
    }
    if (_started || !ref.mounted) return;
    if (stored == null) {
      state = state.copyWith(origin: ScanOrigin.missing);
      return;
    }

    final analysis = stored.analysis;
    final photo = analysis?.analysis.photo;
    final rejected =
        analysis != null &&
        (!(photo?.usable ?? true) || analysis.analysis.items.isEmpty);
    final stages = <PipelineStage, StageState>{};
    for (final stage in PipelineStage.values) {
      stages[stage] = _restoredStage(stage, stored, rejected: rejected);
    }

    final images = <String, GeneratedImageState>{};
    final cache = ref.read(imageCacheRepositoryProvider);
    for (final idea
        in stored.recommendation?.upcycle ?? const <UpcycleIdea>[]) {
      final cached = await cache.afterImage(scanId, idea.id);
      images[idea.id] = cached == null
          ? const GeneratedImageState(
              status: ImageStatus.failed,
              error: ApiException.interrupted(),
            )
          : GeneratedImageState(
              status: ImageStatus.ready,
              url: _api.resolveUrl(cached.remoteUrl),
              localPath: cached.localPath,
            );
    }
    final reference = stored.source == AnalysisSource.text
        ? await cache.referenceImage(scanId)
        : null;
    if (_started || !ref.mounted) return;

    state = ScanSessionState(
      scanId: scanId,
      origin: ScanOrigin.restored,
      source: stored.source,
      lang: stored.lang,
      inputText: stored.inputText,
      localImagePath: stored.localImagePath,
      stages: stages,
      analysis: analysis,
      rejectedPhoto: rejected
          ? (photo!.usable
                ? photo.copyWith(usable: false, issue: PhotoIssue.noItems)
                : photo)
          : null,
      recommendation: stored.recommendation,
      facilities: stored.facilities,
      afterImages: images,
      referenceImage: reference == null
          ? const GeneratedImageState()
          : GeneratedImageState(
              status: ImageStatus.ready,
              url: _api.resolveUrl(reference.remoteUrl),
              localPath: reference.localPath,
            ),
      focusItemId: stored.focusItemId,
    );
    if (stages[PipelineStage.makeovers]!.status == StageStatus.done) {
      _settleMakeovers(_chain);
    }
  }

  StageState _restoredStage(
    PipelineStage stage,
    StoredScan stored, {
    required bool rejected,
  }) {
    final hasData = switch (stage) {
      PipelineStage.identifying => stored.analysis != null && !rejected,
      PipelineStage.ideas => stored.recommendation != null,
      PipelineStage.dropoff => stored.facilities != null,
      PipelineStage.makeovers => false,
    };
    if (hasData) return const StageState(status: StageStatus.done);
    if (stage == PipelineStage.identifying && rejected) {
      return const StageState(status: StageStatus.failed);
    }
    final saved = StageStatus.values
        .where((s) => s.name == stored.stages[stage.name])
        .firstOrNull;
    return switch (saved) {
      StageStatus.skipped => const StageState(status: StageStatus.skipped),
      StageStatus.needsLocation => const StageState(
        status: StageStatus.needsLocation,
      ),
      StageStatus.done => const StageState(status: StageStatus.done),
      // Still running when the app closed: say so, and offer a retry.
      StageStatus.running => const StageState(
        status: StageStatus.failed,
        error: ApiException.interrupted(),
      ),
      StageStatus.failed => const StageState(status: StageStatus.failed),
      StageStatus.pending || null => const StageState(),
    };
  }

  // ----------------------------------------------------------------- helpers

  Future<Uint8List> _readLocalPhoto() async {
    final path = state.localImagePath;
    if (path == null || !File(path).existsSync()) {
      throw const ApiException(
        code: ApiErrorCode.imageInvalid,
        message: 'The scan photo is no longer on the device.',
        retryable: false,
      );
    }
    return File(path).readAsBytes();
  }

  void _setStage(
    PipelineStage stage,
    StageStatus status, {
    ApiException? error,
  }) {
    if (!ref.mounted) return;
    state = state.copyWith(
      stages: {
        ...state.stages,
        stage: StageState(status: status, error: error),
      },
    );
  }

  void _setImage(String ideaId, GeneratedImageState image) {
    if (!ref.mounted) return;
    state = state.copyWith(afterImages: {...state.afterImages, ideaId: image});
  }

  /// History writes are best effort: a failed write (storage full) must not
  /// fail a stage whose result the user can already see.
  Future<void> _save(Future<void> Function() write) async {
    try {
      await write();
    } on Object catch (e) {
      debugPrint('Scan $scanId not saved to history: $e');
    }
  }

  Future<void> _persistStages() async {
    if (!ref.mounted) return;
    final stages = {
      for (final e in state.stages.entries) e.key.name: e.value.status.name,
    };
    await _save(() => _scans.saveStages(scanId, stages));
  }

  Future<void> _mark(ImpactKind kind, Iterable<String> itemIds) async {
    final repo = ref.read(impactRepositoryProvider);
    for (final id in itemIds) {
      final item = state.itemById(id);
      if (item != null) {
        await repo.record(kind: kind, item: item, scanId: scanId);
      }
    }
  }
}

/// Item ids of a scan already marked recycled / donated / disposed, for
/// checked states on the results screen.
final markedItemsProvider =
    StreamProvider.family<Set<String>, ({String scanId, ImpactKind kind})>(
      (ref, key) =>
          ref.watch(impactRepositoryProvider).watchMarked(key.scanId, key.kind),
    );
