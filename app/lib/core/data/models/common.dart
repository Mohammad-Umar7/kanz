/// Shared building blocks of the API (mirror of `backend/app/schemas/common.py`).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'vocab_enums.dart';

part 'common.freezed.dart';
part 'common.g.dart';

/// Stage name -> milliseconds, present on every AI response.
typedef Timings = Map<String, int>;

/// What the user told us in onboarding; tailors ideas and tutorials.
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    @Default(SkillLevel.beginner) SkillLevel skill,
    @Default(<ToolId>[]) List<ToolId> tools,
    @Default(Lang.en) Lang lang,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

/// Kind of knowledge-base document behind a recommendation.
enum SourceKind {
  @JsonValue('project')
  project,
  @JsonValue('material_guide')
  materialGuide,
  @JsonValue('safety')
  safety,
  @JsonValue('swap')
  swap,
}

/// A knowledge-base document that grounded a recommendation (shown as a source chip).
@freezed
abstract class SourceRef with _$SourceRef {
  const factory SourceRef({
    required String id,
    required String title,
    required SourceKind kind,
  }) = _SourceRef;

  factory SourceRef.fromJson(Map<String, dynamic> json) =>
      _$SourceRefFromJson(json);
}

/// A coordinate (Pydantic `LatLng`). Named GeoPoint so it never clashes with
/// `LatLng` from google_maps_flutter in the map screens.
@freezed
abstract class GeoPoint with _$GeoPoint {
  const factory GeoPoint({required double lat, required double lng}) =
      _GeoPoint;

  factory GeoPoint.fromJson(Map<String, dynamic> json) =>
      _$GeoPointFromJson(json);
}

/// Error codes returned by the backend in [ErrorBody.code].
enum ErrorCode {
  @JsonValue('bad_request')
  badRequest,
  @JsonValue('image_invalid')
  imageInvalid,
  @JsonValue('image_too_large')
  imageTooLarge,
  @JsonValue('not_found')
  notFound,
  @JsonValue('rate_limited')
  rateLimited,
  @JsonValue('ai_unavailable')
  aiUnavailable,
  @JsonValue('ai_timeout')
  aiTimeout,
  @JsonValue('ai_invalid_output')
  aiInvalidOutput,
  @JsonValue('ai_quota_exhausted')
  aiQuotaExhausted,
  @JsonValue('places_unavailable')
  placesUnavailable,
  @JsonValue('internal')
  internal,
}

@freezed
abstract class ErrorBody with _$ErrorBody {
  const factory ErrorBody({
    required ErrorCode code,
    required String message,
    required bool retryable,
    required String requestId,
  }) = _ErrorBody;

  factory ErrorBody.fromJson(Map<String, dynamic> json) =>
      _$ErrorBodyFromJson(json);
}

/// Body of every non-2xx response.
@freezed
abstract class ErrorResponse with _$ErrorResponse {
  const factory ErrorResponse({required ErrorBody error}) = _ErrorResponse;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);
}
