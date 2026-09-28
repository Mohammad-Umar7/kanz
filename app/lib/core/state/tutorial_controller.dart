import 'dart:async';

import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/db/database.dart' show ImpactKind;
import '../data/models/models.dart';
import '../data/repositories/project_repository.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import 'core_providers.dart';
import 'generated_image.dart';
import 'settings_providers.dart';

export 'generated_image.dart';

part 'tutorial_controller.freezed.dart';

/// Identifies a tutorial: one idea of one scan.
typedef TutorialKey = ({String scanId, String ideaId});

enum TutorialPhase {
  /// Loading the project, or fetching the first tutorial.
  loading,
  ready,

  /// See [TutorialState.error]; offer `retry()`.
  failed,
}

@freezed
abstract class TutorialState with _$TutorialState {
  const factory TutorialState({
    @Default(TutorialPhase.loading) TutorialPhase phase,
    ApiException? error,
    ProjectRecord? project,
    UpcycleIdea? idea,
    Tutorial? tutorial,

    /// Skill and tools the current tutorial was written for.
    @Default(SkillLevel.beginner) SkillLevel skill,
    @Default(<ToolId>[]) List<ToolId> tools,

    /// True while `adapt()` fetches a tutorial for a new skill or tool set; the
    /// previous tutorial stays on screen until the new one arrives.
    @Default(false) bool adapting,
    ApiException? adaptError,

    /// Step number (1-based) -> step image.
    @Default(<int, GeneratedImageState>{})
    Map<int, GeneratedImageState> stepImages,

    /// 1-based step on screen.
    @Default(1) int currentStep,
    @Default(<int>{}) Set<int> completedSteps,
    @Default(false) bool completed,
  }) = _TutorialState;

  const TutorialState._();

  List<TutorialStep> get steps => tutorial?.steps ?? const [];
  int get stepCount => steps.length;
  bool get isFirstStep => currentStep <= 1;
  bool get isLastStep => currentStep >= stepCount;
  bool get allStepsDone => stepCount > 0 && completedSteps.length >= stepCount;

  /// "Adapted for Beginner: pliers instead of a drill" from the backend.
  String? get adaptedNote => tutorial?.adaptedNote;

  TutorialStep? step(int number) =>
      steps.where((s) => s.number == number).firstOrNull;

  GeneratedImageState stepImage(int number) =>
      stepImages[number] ?? const GeneratedImageState();
}

/// The tutorial for one idea, with its project progress and step image chain.
final tutorialControllerProvider =
    NotifierProvider.family<TutorialController, TutorialState, TutorialKey>(
      TutorialController.new,
    );

/// Loads or creates the project, fetches the tutorial for the user's profile,
/// then fetches step images in order: step 1 at once, the rest one after the
/// other in the background, because each step image is an edit of the
/// previous one (the backend's image chain keeps the same object throughout).
class TutorialController extends Notifier<TutorialState> {
  TutorialController(this.key);

  final TutorialKey key;

  int _generation = 0;
  CancelToken? _token;

  /// Tutorial whose step chain is currently being walked (one walker at a time).
  String? _chainFor;

  ApiClient get _api => ref.read(apiClientProvider);
  ProjectRepository get _projects => ref.read(projectRepositoryProvider);

  @override
  TutorialState build() {
    ref.onDispose(() => _token?.cancel());
    scheduleMicrotask(_load);
    final settings = ref.read(settingsProvider);
    return TutorialState(skill: settings.skill, tools: settings.tools);
  }

  // ---------------------------------------------------------------- actions

  /// Reloads after a failure.
  Future<void> retry() => _load();

  /// Re-writes the tutorial for another skill level or tool set. The backend
  /// returns a new tutorial id (and adapted steps); progress restarts because
  /// the steps changed.
  Future<void> adapt({
    required SkillLevel skill,
    required List<ToolId> tools,
  }) async {
    final idea = state.idea;
    final project = state.project;
    if (idea == null || project == null) return;
    state = state.copyWith(adapting: true, adaptError: null);
    try {
      final tutorial = await _fetchTutorial(idea, skill: skill, tools: tools);
      if (!ref.mounted) return;
      await _projects.saveTutorial(project.id, tutorial, tools: tools);
      final saved = await _projects.get(project.id);
      if (!ref.mounted) return;
      state = state.copyWith(
        adapting: false,
        tutorial: tutorial,
        project: saved,
        skill: skill,
        tools: tools,
        currentStep: saved?.currentStep ?? 1,
        completedSteps: saved?.completedSteps ?? const {},
        stepImages: const {},
      );
      unawaited(_loadStepImages());
    } on ApiException catch (e) {
      if (!ref.mounted || e.isCancelled) return;
      state = state.copyWith(adapting: false, adaptError: e);
    }
  }

  Future<void> goToStep(int number) async {
    if (number < 1 || number > state.stepCount) return;
    state = state.copyWith(currentStep: number);
    final project = state.project;
    if (project != null) await _projects.setCurrentStep(project.id, number);
  }

  Future<void> next() => goToStep(state.currentStep + 1);

  Future<void> previous() => goToStep(state.currentStep - 1);

  /// Marks a step done (or not) and saves it.
  Future<void> markStepDone(int number, {bool done = true}) async {
    final project = state.project;
    if (project == null) return;
    final steps = {...state.completedSteps};
    if (done) {
      steps.add(number);
    } else {
      steps.remove(number);
    }
    state = state.copyWith(completedSteps: steps);
    await _projects.setStepDone(project.id, number, done: done);
  }

  /// Finishes the project: saves it as completed and records one "upcycled"
  /// impact event per scanned item the idea used. Returns the project id for
  /// `/projects/:projectId/done`.
  Future<String?> complete() async {
    final project = state.project;
    final idea = state.idea;
    if (project == null || idea == null) return null;
    await _projects.complete(project.id);
    final scan = await ref.read(scanRepositoryProvider).get(key.scanId);
    final items = scan?.analysis?.analysis.items ?? const <Item>[];
    final impact = ref.read(impactRepositoryProvider);
    for (final item in items.where((i) => idea.usesItemIds.contains(i.id))) {
      await impact.record(
        kind: ImpactKind.upcycled,
        item: item,
        scanId: key.scanId,
        projectId: project.id,
      );
    }
    if (ref.mounted) {
      state = state.copyWith(
        completed: true,
        project: await _projects.get(project.id),
      );
    }
    return project.id;
  }

  /// Asks for a new image for one step, then continues the chain if later
  /// steps were waiting on it.
  Future<void> regenerateStep(int number) async {
    final tutorial = state.tutorial;
    if (tutorial == null) return;
    final ok = await _stepImage(
      tutorial,
      number,
      _generation,
      regenerate: true,
    );
    if (ok) unawaited(_loadStepImages(from: number + 1));
  }

  // ------------------------------------------------------------------ loading

  Future<void> _load() async {
    final generation = ++_generation;
    _token?.cancel();
    _token = CancelToken();
    state = state.copyWith(phase: TutorialPhase.loading, error: null);
    try {
      final idea = await _findIdea();
      if (!_current(generation)) return;
      if (idea == null) {
        state = state.copyWith(
          phase: TutorialPhase.failed,
          error: const ApiException(
            code: ApiErrorCode.notFound,
            message: 'This idea is not part of the scan.',
            retryable: false,
          ),
        );
        return;
      }
      var project = await _projects.getOrCreate(scanId: key.scanId, idea: idea);
      // Offline-first: a project keeps the tutorial it was following, with the
      // skill and tools it was adapted to. New projects use the profile.
      var tutorial = project.tutorial;
      var tools = project.tools;
      if (tutorial == null) {
        tools = state.tools;
        tutorial = await _fetchTutorial(idea, skill: state.skill, tools: tools);
        if (!_current(generation)) return;
        await _projects.saveTutorial(project.id, tutorial, tools: tools);
        project = (await _projects.get(project.id))!;
      }
      final skill = tutorial.skill;
      if (!_current(generation)) return;
      state = state.copyWith(
        phase: TutorialPhase.ready,
        idea: idea,
        project: project,
        tutorial: tutorial,
        skill: skill,
        tools: tools,
        currentStep: project.currentStep.clamp(1, tutorial.steps.length),
        completedSteps: project.completedSteps,
        completed: project.isCompleted,
      );
      unawaited(_loadStepImages());
    } on ApiException catch (e) {
      if (!_current(generation) || e.isCancelled) return;
      state = state.copyWith(phase: TutorialPhase.failed, error: e);
    }
  }

  bool _current(int generation) => ref.mounted && generation == _generation;

  /// The idea from the scan (in memory or in the database), or from an
  /// existing project when the scan's recommendation is gone.
  Future<UpcycleIdea?> _findIdea() async {
    final scan = await ref.read(scanRepositoryProvider).get(key.scanId);
    final idea = scan?.recommendation?.ideaById(key.ideaId);
    if (idea != null) return idea;
    final project = await _projects.getByIdea(key.scanId, key.ideaId);
    return project?.idea;
  }

  Future<Tutorial> _fetchTutorial(
    UpcycleIdea idea, {
    required SkillLevel skill,
    required List<ToolId> tools,
  }) async {
    final scan = await ref.read(scanRepositoryProvider).get(key.scanId);
    final analysis = scan?.analysis;
    if (analysis == null) {
      throw const ApiException(
        code: ApiErrorCode.notFound,
        message: 'The scan for this tutorial is missing.',
        retryable: false,
      );
    }
    final response = await _api.tutorial(
      TutorialRequest(
        imageId: analysis.imageId,
        idea: idea,
        items: [
          for (final item in analysis.analysis.items)
            if (idea.usesItemIds.contains(item.id)) item,
        ],
        profile: Profile(skill: skill, tools: tools, lang: scan!.lang),
      ),
      cancelToken: _token,
    );
    return response.tutorial;
  }

  /// Walks the step chain from [from]: cached images come from the device,
  /// missing ones are generated one at a time. Stops at the first failure so a
  /// quota or outage costs one failed call, not one per step.
  Future<void> _loadStepImages({int from = 1}) async {
    final tutorial = state.tutorial;
    if (tutorial == null) return;
    final generation = _generation;
    final tutorialId = tutorial.tutorialId;
    if (_chainFor == tutorialId) return;
    _chainFor = tutorialId;
    try {
      for (final step in tutorial.steps.where((s) => s.number >= from)) {
        if (!_current(generation) || state.tutorial?.tutorialId != tutorialId) {
          return;
        }
        if (state.stepImage(step.number).isReady) continue;
        final ok = await _stepImage(tutorial, step.number, generation);
        if (!ok) return;
      }
    } finally {
      if (_chainFor == tutorialId) _chainFor = null;
    }
  }

  Future<bool> _stepImage(
    Tutorial tutorial,
    int number,
    int generation, {
    bool regenerate = false,
  }) async {
    bool current() =>
        _current(generation) &&
        state.tutorial?.tutorialId == tutorial.tutorialId;
    final cache = ref.read(imageCacheRepositoryProvider);
    _setStepImage(
      number,
      const GeneratedImageState(status: ImageStatus.loading),
    );
    try {
      if (!regenerate) {
        final cached = await cache.stepImage(tutorial.tutorialId, number);
        if (!current()) return false;
        if (cached != null) {
          _setStepImage(
            number,
            GeneratedImageState(
              status: ImageStatus.ready,
              url: _api.resolveUrl(cached.remoteUrl),
              localPath: cached.localPath,
            ),
          );
          return true;
        }
      }
      final image = await _api.stepImage(
        StepImageRequest(
          imageId: tutorial.imageId,
          tutorialId: tutorial.tutorialId,
          step: number,
          regenerate: regenerate,
        ),
        cancelToken: _token,
      );
      if (!current()) return false;
      final ready = GeneratedImageState(
        status: ImageStatus.ready,
        url: _api.resolveUrl(image.url),
      );
      _setStepImage(number, ready);
      try {
        final entry = await cache.store(
          image,
          scanId: key.scanId,
          ideaId: key.ideaId,
          tutorialId: tutorial.tutorialId,
          force: regenerate,
        );
        if (current()) {
          _setStepImage(number, ready.copyWith(localPath: entry.localPath));
        }
      } on Object catch (e) {
        debugPrint('Step image not cached: $e');
      }
      return true;
    } on ApiException catch (e) {
      if (!current() || e.isCancelled) return false;
      _setStepImage(
        number,
        GeneratedImageState(status: ImageStatus.failed, error: e),
      );
      return false;
    }
  }

  void _setStepImage(int number, GeneratedImageState image) {
    if (!ref.mounted) return;
    state = state.copyWith(stepImages: {...state.stepImages, number: image});
  }
}
