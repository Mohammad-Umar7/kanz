/// GET /health: liveness plus what the backend has configured
/// (mirror of `backend/app/schemas/health.py`).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'health.freezed.dart';
part 'health.g.dart';

enum HealthStatus {
  @JsonValue('ok')
  ok,
  @JsonValue('degraded')
  degraded,
}

@freezed
abstract class HealthResponse with _$HealthResponse {
  const factory HealthResponse({
    required HealthStatus status,
    required String appName,
    required String version,

    /// Role -> model id, e.g. {'vision': 'gemini-3.6-flash'}.
    required Map<String, String> models,
    required bool aiConfigured,
    required int knowledgeDocs,
    required bool ragReady,
    required bool placesGoogle,
    required bool placesOsm,
    required int uptimeS,
  }) = _HealthResponse;

  factory HealthResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthResponseFromJson(json);
}
