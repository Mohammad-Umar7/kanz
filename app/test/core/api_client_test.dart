import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/network/api_client.dart';
import 'package:kanz/core/network/api_exception.dart';

import 'support/fixtures.dart';

/// Answers each request with the next queued reply and records what was sent.
class _FakeAdapter implements HttpClientAdapter {
  final List<Object Function(RequestOptions)> replies = [];
  final List<RequestOptions> requests = [];

  void reply(int status, Object body, {String requestId = 'req_test'}) {
    replies.add(
      (_) => ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          'x-request-id': [requestId],
        },
      ),
    );
  }

  void fail(DioException Function(RequestOptions) error) => replies.add(error);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final next = replies.removeAt(0)(options);
    if (next is DioException) throw next;
    return next as ResponseBody;
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _FakeAdapter adapter;
  late ApiClient api;

  setUp(() {
    adapter = _FakeAdapter();
    api = ApiClient(
      baseUrl: 'http://kanz.test:8000/',
      dio: Dio()..httpClientAdapter = adapter,
      retryDelay: Duration.zero,
    );
  });

  test('parses a successful response into the contract model', () async {
    adapter.reply(200, fixture('recommend_glass_jar.json'));
    final request = RecommendRequest.fromJson(
      fixture('recommend_request_glass_jar.json'),
    );

    final res = await api.recommend(request);

    expect(res.upcycle, hasLength(3));
    final sent = adapter.requests.single;
    expect(sent.path, '/v1/recommend');
    expect(sent.receiveTimeout, ApiTimeouts.recommend);
    expect((sent.data as Map<String, dynamic>)['image_id'], request.imageId);
  });

  test('analyzePhoto sends multipart image and lang', () async {
    adapter.reply(200, fixture('analyze_glass_jar.json'));

    final res = await api.analyzePhoto(
      Uint8List.fromList([0xFF, 0xD8, 0xFF]),
      lang: Lang.ar,
    );

    expect(res.imageId, startsWith('img_'));
    final form = adapter.requests.single.data as FormData;
    expect(form.fields.map((f) => (f.key, f.value)), contains(('lang', 'ar')));
    expect(form.files.single.key, 'image');
    expect(adapter.requests.single.receiveTimeout, ApiTimeouts.analyze);
  });

  test('maps an ErrorResponse body to ApiException', () async {
    adapter.reply(503, fixture('error_ai_unavailable.json'));

    await expectLater(
      api.health(),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', ApiErrorCode.aiUnavailable)
            .having((e) => e.retryable, 'retryable', isTrue)
            .having((e) => e.requestId, 'requestId', 'req_5f3c2a1b')
            .having((e) => e.statusCode, 'statusCode', 503),
      ),
    );
  });

  test('a non-contract error body is classified by status', () async {
    adapter.reply(429, {'detail': 'slow down'});

    await expectLater(
      api.health(),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', ApiErrorCode.rateLimited)
            .having((e) => e.retryable, 'retryable', isTrue),
      ),
    );
  });

  test('a receive timeout becomes a retryable timeout', () async {
    adapter.fail(
      (o) => DioException.receiveTimeout(
        timeout: ApiTimeouts.health,
        requestOptions: o,
      ),
    );

    await expectLater(
      api.health(),
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', ApiErrorCode.timeout),
      ),
    );
    expect(adapter.requests, hasLength(1), reason: 'timeouts are not retried');
  });

  test('a connection error is retried once, then reported offline', () async {
    DioException refused(RequestOptions o) => DioException.connectionError(
      requestOptions: o,
      reason: 'refused',
      error: const SocketException('Connection refused'),
    );
    adapter
      ..fail(refused)
      ..fail(refused);

    await expectLater(
      api.health(),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', ApiErrorCode.offline)
            .having((e) => e.isOffline, 'isOffline', isTrue),
      ),
    );
    expect(adapter.requests, hasLength(2));
  });

  test('a connection error followed by success returns the result', () async {
    adapter.fail(
      (o) => DioException.connectionError(requestOptions: o, reason: 'reset'),
    );
    adapter.reply(200, fixture('health.json'));

    final health = await api.health();

    expect(health.status, HealthStatus.ok);
    expect(adapter.requests, hasLength(2));
  });

  test('a 2xx body that breaks the contract is a badResponse', () async {
    adapter.reply(200, {'status': 'ok'});

    await expectLater(
      api.health(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiErrorCode.badResponse,
        ),
      ),
    );
  });

  test('resolveUrl joins backend paths with the base URL', () {
    expect(
      api.resolveUrl('/static/generated/a.jpg'),
      'http://kanz.test:8000/static/generated/a.jpg',
    );
    expect(api.resolveUrl('https://cdn.test/a.jpg'), 'https://cdn.test/a.jpg');
  });
}
