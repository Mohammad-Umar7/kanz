import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/models.dart';
import 'api_exception.dart';

/// Per-endpoint time budgets. They sit above the backend's own stage timeouts
/// (analysis < 6 s, ideas < 8 s, tutorial < 10 s on a good day) with room for
/// retries and fallback models on the server, so the backend's `ai_timeout`
/// normally arrives before the app gives up.
abstract final class ApiTimeouts {
  static const health = Duration(seconds: 5);
  static const analyze = Duration(seconds: 40);
  static const recommend = Duration(seconds: 45);
  static const tutorial = Duration(seconds: 50);
  static const images = Duration(seconds: 120);
  static const facilities = Duration(seconds: 25);
  static const swaps = Duration(seconds: 35);
  static const connect = Duration(seconds: 8);
}

/// Typed client for every endpoint in docs/API.md.
///
/// All failures surface as [ApiException]: backend `ErrorResponse` bodies keep
/// their code and request id, and transport failures become `offline`,
/// `timeout` or `cancelled`. Connection errors (not timeouts, not HTTP errors)
/// are retried exactly once, because a phone waking its radio or a backend
/// restarting commonly refuses the first connection.
class ApiClient {
  ApiClient({
    required String baseUrl,
    Dio? dio,
    this.retryDelay = const Duration(milliseconds: 700),
  }) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = _trimSlash(baseUrl)
      ..connectTimeout = ApiTimeouts.connect
      ..responseType = ResponseType.json
      ..headers['Accept'] = 'application/json';
    if (kDebugMode) _dio.interceptors.add(_RequestLogInterceptor());
  }

  final Dio _dio;

  /// Pause before the single automatic retry of a connection error.
  final Duration retryDelay;

  String get baseUrl => _dio.options.baseUrl;

  /// Joins a backend path such as `/static/generated/...` with the base URL.
  /// Absolute URLs are returned unchanged.
  String resolveUrl(String pathOrUrl) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return pathOrUrl;
    }
    final path = pathOrUrl.startsWith('/') ? pathOrUrl : '/$pathOrUrl';
    return '$baseUrl$path';
  }

  // ---------------------------------------------------------------- endpoints

  /// GET /health: warms the backend on launch and feeds Settings > Backend status.
  Future<HealthResponse> health({CancelToken? cancelToken}) => _call(
    () => _dio.get<Object?>(
      '/health',
      options: _options(ApiTimeouts.health),
      cancelToken: cancelToken,
    ),
    HealthResponse.fromJson,
  );

  /// POST /v1/analyze with a photo (JPEG bytes from the image compressor).
  Future<AnalyzeResponse> analyzePhoto(
    Uint8List jpegBytes, {
    required Lang lang,
    String filename = 'scan.jpg',
    CancelToken? cancelToken,
  }) => _call(
    // FormData is single-use, so it is rebuilt if the call is retried.
    () => _dio.post<Object?>(
      '/v1/analyze',
      data: FormData.fromMap({
        'image': MultipartFile.fromBytes(
          jpegBytes,
          filename: filename,
          contentType: DioMediaType('image', 'jpeg'),
        ),
        'lang': lang.id,
      }),
      options: _options(ApiTimeouts.analyze, sends: true),
      cancelToken: cancelToken,
    ),
    AnalyzeResponse.fromJson,
  );

  /// POST /v1/analyze with a text description instead of a photo.
  Future<AnalyzeResponse> analyzeText(
    String text, {
    required Lang lang,
    CancelToken? cancelToken,
  }) => _call(
    () => _dio.post<Object?>(
      '/v1/analyze',
      data: FormData.fromMap({'text': text, 'lang': lang.id}),
      options: _options(ApiTimeouts.analyze, sends: true),
      cancelToken: cancelToken,
    ),
    AnalyzeResponse.fromJson,
  );

  Future<RecommendResponse> recommend(
    RecommendRequest request, {
    CancelToken? cancelToken,
  }) => _postJson(
    '/v1/recommend',
    request.toJson(),
    ApiTimeouts.recommend,
    RecommendResponse.fromJson,
    cancelToken,
  );

  Future<TutorialResponse> tutorial(
    TutorialRequest request, {
    CancelToken? cancelToken,
  }) => _postJson(
    '/v1/tutorial',
    request.toJson(),
    ApiTimeouts.tutorial,
    TutorialResponse.fromJson,
    cancelToken,
  );

  Future<ImageResponse> afterImage(
    AfterImageRequest request, {
    CancelToken? cancelToken,
  }) => _postJson(
    '/v1/images/after',
    request.toJson(),
    ApiTimeouts.images,
    ImageResponse.fromJson,
    cancelToken,
  );

  Future<ImageResponse> stepImage(
    StepImageRequest request, {
    CancelToken? cancelToken,
  }) => _postJson(
    '/v1/images/step',
    request.toJson(),
    ApiTimeouts.images,
    ImageResponse.fromJson,
    cancelToken,
  );

  Future<ImageResponse> binImage(
    BinImageRequest request, {
    CancelToken? cancelToken,
  }) => _postJson(
    '/v1/images/bin',
    request.toJson(),
    ApiTimeouts.images,
    ImageResponse.fromJson,
    cancelToken,
  );

  Future<FacilitiesResponse> facilities(
    FacilitiesRequest request, {
    CancelToken? cancelToken,
  }) => _postJson(
    '/v1/facilities',
    request.toJson(),
    ApiTimeouts.facilities,
    FacilitiesResponse.fromJson,
    cancelToken,
  );

  /// GET /v1/facilities/categories: the Drop-off tab's filter chips.
  Future<FacilityCategoriesResponse> facilityCategories({
    required Lang lang,
    CancelToken? cancelToken,
  }) => _call(
    () => _dio.get<Object?>(
      '/v1/facilities/categories',
      queryParameters: {'lang': lang.id},
      options: _options(ApiTimeouts.facilities),
      cancelToken: cancelToken,
    ),
    FacilityCategoriesResponse.fromJson,
  );

  Future<SwapsResponse> swaps(
    SwapsRequest request, {
    CancelToken? cancelToken,
  }) => _postJson(
    '/v1/swaps',
    request.toJson(),
    ApiTimeouts.swaps,
    SwapsResponse.fromJson,
    cancelToken,
  );

  /// Downloads a generated image (path or absolute URL) for the offline cache.
  Future<Uint8List> downloadBytes(
    String pathOrUrl, {
    CancelToken? cancelToken,
  }) async {
    final response = await _send(
      () => _dio.get<List<int>>(
        resolveUrl(pathOrUrl),
        options: _options(
          ApiTimeouts.images,
        ).copyWith(responseType: ResponseType.bytes),
        cancelToken: cancelToken,
      ),
    );
    final data = response.data;
    if (data == null || data.isEmpty) {
      throw const ApiException(
        code: ApiErrorCode.badResponse,
        message: 'Empty image download.',
        retryable: true,
      );
    }
    return data is Uint8List ? data : Uint8List.fromList(data);
  }

  // ---------------------------------------------------------------- plumbing

  Options _options(Duration timeout, {bool sends = false}) =>
      Options(receiveTimeout: timeout, sendTimeout: sends ? timeout : null);

  Future<T> _postJson<T>(
    String path,
    Map<String, dynamic> body,
    Duration timeout,
    T Function(Map<String, dynamic>) parse,
    CancelToken? cancelToken,
  ) => _call(
    () => _dio.post<Object?>(
      path,
      data: body,
      options: _options(
        timeout,
        sends: true,
      ).copyWith(contentType: Headers.jsonContentType),
      cancelToken: cancelToken,
    ),
    parse,
  );

  Future<T> _call<T>(
    Future<Response<Object?>> Function() request,
    T Function(Map<String, dynamic>) parse,
  ) async {
    final response = await _send(request);
    try {
      return parse(_asJsonMap(response.data));
    } on Object catch (e) {
      // A 2xx body that does not match the contract: report it, never crash.
      throw ApiException(
        code: ApiErrorCode.badResponse,
        message: 'Unexpected response from ${response.requestOptions.path}: $e',
        retryable: true,
        requestId: response.headers.value(_requestIdHeader),
        statusCode: response.statusCode,
      );
    }
  }

  Future<Response<R>> _send<R>(Future<Response<R>> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        await Future<void>.delayed(retryDelay);
        try {
          return await request();
        } on DioException catch (retryError) {
          throw mapDioException(retryError);
        }
      }
      throw mapDioException(e);
    }
  }
}

const _requestIdHeader = 'x-request-id';

/// Maps a dio failure to an [ApiException] (public for tests and for callers
/// that use dio directly, such as the image cache).
ApiException mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const ApiException.timeout();
    case DioExceptionType.cancel:
      return const ApiException.cancelled();
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
      return ApiException.offline(e.message ?? 'Connection failed.');
    case DioExceptionType.badResponse:
      return _fromErrorResponse(e.response);
    case DioExceptionType.unknown:
      if (e.error is SocketException || e.error is HttpException) {
        return ApiException.offline(e.message ?? '${e.error}');
      }
      return ApiException(
        code: ApiErrorCode.internal,
        message: '${e.error ?? e.message}',
        retryable: false,
      );
  }
}

ApiException _fromErrorResponse(Response<Object?>? response) {
  final status = response?.statusCode;
  final requestId = response?.headers.value(_requestIdHeader);
  try {
    final body = ErrorResponse.fromJson(_asJsonMap(response?.data));
    return ApiException.fromErrorBody(body.error, statusCode: status);
  } on Object {
    // Not an ErrorResponse (a proxy page, a crash before the handler): classify
    // by status so the UI can still say something sensible.
    final code = switch (status) {
      429 => ApiErrorCode.rateLimited,
      502 || 503 => ApiErrorCode.aiUnavailable,
      504 => ApiErrorCode.timeout,
      404 => ApiErrorCode.notFound,
      _ when status != null && status >= 400 && status < 500 =>
        ApiErrorCode.badRequest,
      _ => ApiErrorCode.internal,
    };
    return ApiException(
      code: code,
      message: 'HTTP $status',
      retryable:
          code == ApiErrorCode.rateLimited ||
          code == ApiErrorCode.aiUnavailable ||
          code == ApiErrorCode.timeout,
      requestId: requestId,
      statusCode: status,
    );
  }
}

Map<String, dynamic> _asJsonMap(Object? data) {
  final decoded = data is String ? jsonDecode(data) : data;
  if (decoded is Map<String, dynamic>) return decoded;
  throw const FormatException('Expected a JSON object');
}

String _trimSlash(String url) =>
    url.endsWith('/') ? url.substring(0, url.length - 1) : url;

/// Debug-only log line per call: method, path, status, latency and the
/// backend's X-Request-ID, so a slow or failed call can be found in server logs.
class _RequestLogInterceptor extends Interceptor {
  static const _startKey = 'kanz_started_at';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log(response.requestOptions, response.statusCode, response.headers);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      err.requestOptions,
      err.response?.statusCode,
      err.response?.headers,
      error: err.type.name,
    );
    handler.next(err);
  }

  void _log(
    RequestOptions options,
    int? status,
    Headers? headers, {
    String? error,
  }) {
    final started = options.extra[_startKey] as int?;
    final ms = started == null
        ? '?'
        : '${DateTime.now().millisecondsSinceEpoch - started}';
    final requestId = headers?.value(_requestIdHeader) ?? '-';
    developer.log(
      '${options.method} ${options.path} -> ${status ?? error} in $ms ms [$requestId]',
      name: 'kanz.api',
    );
  }
}
