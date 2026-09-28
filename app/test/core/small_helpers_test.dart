import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/core/services/share_service.dart';

void main() {
  test('error codes print as the API writes them', () {
    expect(ApiErrorCode.placesUnavailable.wireId, 'places_unavailable');
    expect(ApiErrorCode.aiQuotaExhausted.wireId, 'ai_quota_exhausted');
    expect(ApiErrorCode.internal.wireId, 'internal');
  });

  test('shared images carry the MIME type of their file', () {
    expect(mimeTypeFor('/tmp/kanz_share.png'), 'image/png');
    expect(mimeTypeFor('/tmp/after.JPG'), 'image/jpeg');
    expect(mimeTypeFor('/tmp/step.webp'), 'image/webp');
  });
}
