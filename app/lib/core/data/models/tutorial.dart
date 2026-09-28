/// POST /v1/tutorial: chosen idea + profile -> step-by-step tutorial
/// (mirror of `backend/app/schemas/tutorial.py`).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'analysis.dart';
import 'common.dart';
import 'recommend.dart';
import 'vocab_enums.dart';

part 'tutorial.freezed.dart';
part 'tutorial.g.dart';

@freezed
abstract class TutorialRequest with _$TutorialRequest {
  const factory TutorialRequest({
    required String imageId,
    required UpcycleIdea idea,

    /// The scan items the idea uses; their material and state shape the steps.
    required List<Item> items,
    @Default(Profile()) Profile profile,
  }) = _TutorialRequest;

  factory TutorialRequest.fromJson(Map<String, dynamic> json) =>
      _$TutorialRequestFromJson(json);
}

@freezed
abstract class TutorialMaterial with _$TutorialMaterial {
  const factory TutorialMaterial({
    required String name,
    String? quantity,

    /// True if it is (part of) a scanned item.
    required bool fromScan,
    String? itemId,
  }) = _TutorialMaterial;

  factory TutorialMaterial.fromJson(Map<String, dynamic> json) =>
      _$TutorialMaterialFromJson(json);
}

@freezed
abstract class TutorialTool with _$TutorialTool {
  const factory TutorialTool({
    required ToolId toolId,
    required bool have,

    /// Localized substitute when the user lacks the tool.
    String? alternative,
  }) = _TutorialTool;

  factory TutorialTool.fromJson(Map<String, dynamic> json) =>
      _$TutorialToolFromJson(json);
}

@freezed
abstract class TutorialStep with _$TutorialStep {
  const factory TutorialStep({
    /// 1-based.
    required int number,
    required String title,
    required String instruction,
    String? tip,
    String? warning,
    required int durationMinutes,

    /// English: what the object looks like right after this step (drives the step image).
    required String imagePrompt,
  }) = _TutorialStep;

  factory TutorialStep.fromJson(Map<String, dynamic> json) =>
      _$TutorialStepFromJson(json);
}

@freezed
abstract class Tutorial with _$Tutorial {
  const factory Tutorial({
    /// 'tut_<hash>' of (image_id, idea.id, skill, tools, lang).
    required String tutorialId,
    required String ideaId,
    required String imageId,
    required String title,

    /// Localized: 'Adapted for Beginner, no drill needed'.
    required String adaptedNote,
    required SkillLevel skill,
    required int totalMinutes,
    required List<TutorialMaterial> materials,
    required List<TutorialTool> tools,
    required List<String> safety,

    /// 5 to 8 steps.
    required List<TutorialStep> steps,
    @Default(<String>[]) List<String> finishing,
    @Default(<String>[]) List<String> care,
    @Default(<SourceRef>[]) List<SourceRef> sources,
    required Lang lang,
  }) = _Tutorial;

  factory Tutorial.fromJson(Map<String, dynamic> json) =>
      _$TutorialFromJson(json);
}

@freezed
abstract class TutorialResponse with _$TutorialResponse {
  const factory TutorialResponse({
    required Tutorial tutorial,
    @Default(<String, int>{}) Timings timingsMs,
  }) = _TutorialResponse;

  factory TutorialResponse.fromJson(Map<String, dynamic> json) =>
      _$TutorialResponseFromJson(json);
}
