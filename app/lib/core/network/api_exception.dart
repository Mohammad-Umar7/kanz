import 'package:flutter/foundation.dart';

import '../data/models/common.dart';

/// Every failure the app can show for a network call.
///
/// The first group mirrors the backend's `ErrorCode` (docs/API.md); the second
/// group is produced on the device when no usable response arrived.
enum ApiErrorCode {
  badRequest,
  imageInvalid,
  imageTooLarge,
  notFound,
  rateLimited,
  aiUnavailable,
  aiTimeout,
  aiInvalidOutput,
  aiQuotaExhausted,
  placesUnavailable,
  internal,

  /// No network, DNS failure or the backend refused the connection.
  offline,

  /// The request exceeded the app's per-endpoint timeout.
  timeout,

  /// The request was cancelled because a newer one replaced it.
  cancelled,

  /// The backend answered with something that is not the contract shape.
  badResponse,

  /// A step was still running when the app was closed; restored from history.
  interrupted;

  /// The code as the API writes it ("places_unavailable"), shown for support.
  String get wireId =>
      name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

  static ApiErrorCode fromServer(ErrorCode code) => switch (code) {
    ErrorCode.badRequest => badRequest,
    ErrorCode.imageInvalid => imageInvalid,
    ErrorCode.imageTooLarge => imageTooLarge,
    ErrorCode.notFound => notFound,
    ErrorCode.rateLimited => rateLimited,
    ErrorCode.aiUnavailable => aiUnavailable,
    ErrorCode.aiTimeout => aiTimeout,
    ErrorCode.aiInvalidOutput => aiInvalidOutput,
    ErrorCode.aiQuotaExhausted => aiQuotaExhausted,
    ErrorCode.placesUnavailable => placesUnavailable,
    ErrorCode.internal => internal,
  };
}

/// A failed API call, ready for the UI: map [code] to a localized message with
/// `apiErrorMessage` (lib/l10n/l10n.dart) and offer a retry when [retryable].
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    required this.retryable,
    this.requestId,
    this.statusCode,
  });

  /// Maps a backend `ErrorResponse` body.
  factory ApiException.fromErrorBody(ErrorBody body, {int? statusCode}) =>
      ApiException(
        code: ApiErrorCode.fromServer(body.code),
        message: body.message,
        retryable: body.retryable,
        requestId: body.requestId,
        statusCode: statusCode,
      );

  const ApiException.offline([String message = 'No connection to Kanz.'])
    : this(code: ApiErrorCode.offline, message: message, retryable: true);

  const ApiException.timeout([String message = 'The request took too long.'])
    : this(code: ApiErrorCode.timeout, message: message, retryable: true);

  const ApiException.cancelled()
    : this(
        code: ApiErrorCode.cancelled,
        message: 'Cancelled.',
        retryable: true,
      );

  const ApiException.interrupted()
    : this(
        code: ApiErrorCode.interrupted,
        message: 'This step did not finish.',
        retryable: true,
      );

  /// Wraps any failure for the UI. Errors outside the network layer (storage
  /// full, a corrupt local file) become a retryable `internal` error, so a
  /// stage ends visibly instead of spinning forever.
  factory ApiException.from(Object error) {
    if (error is ApiException) return error;
    debugPrint('Unexpected failure: $error');
    return ApiException(
      code: ApiErrorCode.internal,
      message: '$error',
      retryable: true,
    );
  }

  final ApiErrorCode code;

  /// Server message (English) or a short developer-facing reason. The UI shows
  /// the localized text for [code] instead.
  final String message;
  final bool retryable;

  /// `X-Request-ID` of the failed call, for support and log correlation.
  final String? requestId;
  final int? statusCode;

  bool get isOffline => code == ApiErrorCode.offline;
  bool get isCancelled => code == ApiErrorCode.cancelled;

  /// Image models on a free-tier key: retrying will not help until billing changes.
  bool get isQuotaExhausted => code == ApiErrorCode.aiQuotaExhausted;

  @override
  bool operator ==(Object other) =>
      other is ApiException &&
      other.code == code &&
      other.message == message &&
      other.retryable == retryable &&
      other.requestId == requestId &&
      other.statusCode == statusCode;

  @override
  int get hashCode =>
      Object.hash(code, message, retryable, requestId, statusCode);

  @override
  String toString() =>
      'ApiException(${code.name}, $statusCode, $requestId): $message';
}
