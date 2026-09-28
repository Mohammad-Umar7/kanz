/// POST /v1/images/after, /v1/images/step, /v1/images/bin
/// (mirror of `backend/app/schemas/images.py`).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'analysis.dart';
import 'common.dart';
import 'recommend.dart';
import 'vocab_enums.dart';

part 'images.freezed.dart';
part 'images.g.dart';

/// The user's photo edited into the finished project.
@freezed
abstract class AfterImageRequest with _$AfterImageRequest {
  const factory AfterImageRequest({
    required String imageId,
    required UpcycleIdea idea,
    @Default(false) bool regenerate,
  }) = _AfterImageRequest;

  factory AfterImageRequest.fromJson(Map<String, dynamic> json) =>
      _$AfterImageRequestFromJson(json);
}

/// One link of the step chain: step N edits step N-1's image.
@freezed
abstract class StepImageRequest with _$StepImageRequest {
  const factory StepImageRequest({
    required String imageId,
    required String tutorialId,

    /// 1-based; earlier steps are generated first if missing.
    required int step,
    @Default(false) bool regenerate,
  }) = _StepImageRequest;

  factory StepImageRequest.fromJson(Map<String, dynamic> json) =>
      _$StepImageRequestFromJson(json);
}

/// The item shown correctly prepared for its bin (rinsed, cap off, flattened).
@freezed
abstract class BinImageRequest with _$BinImageRequest {
  const factory BinImageRequest({
    required String imageId,
    required Item item,
    @Default(<String>[]) List<String> prepSteps,
    @Default(false) bool regenerate,
  }) = _BinImageRequest;

  factory BinImageRequest.fromJson(Map<String, dynamic> json) =>
      _$BinImageRequestFromJson(json);
}

enum ImageKind {
  @JsonValue('after')
  after,
  @JsonValue('step')
  step,
  @JsonValue('bin')
  bin,
  @JsonValue('reference')
  reference,
}

@freezed
abstract class ImageResponse with _$ImageResponse {
  const factory ImageResponse({
    /// Path under the API base URL: '/static/generated/img_ab12/after_idea_9f.jpg'.
    required String url,
    required int width,
    required int height,
    required ImageKind kind,

    /// Cache key: identical requests return the same image.
    required String key,
    required bool cached,
    int? step,
    SkillLevel? skill,
    @Default(<String, int>{}) Timings timingsMs,
  }) = _ImageResponse;

  factory ImageResponse.fromJson(Map<String, dynamic> json) =>
      _$ImageResponseFromJson(json);
}
