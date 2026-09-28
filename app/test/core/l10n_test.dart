import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/l10n/l10n.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  test('every API error code has a message in both languages', () {
    for (final code in ApiErrorCode.values) {
      final error = ApiException(code: code, message: '', retryable: false);
      expect(apiErrorMessage(en, error), isNotEmpty, reason: code.name);
      expect(apiErrorMessage(ar, error), isNotEmpty, reason: code.name);
    }
    expect(apiErrorMessage(en, null), en.commonErrorGeneric);
  });

  test('distances keep Western digits in Arabic', () {
    expect(formatDistance(en, 948), '950 m');
    expect(formatDistance(en, 2700), '2.7 km');
    expect(formatDistance(en, 18400), '18 km');
    expect(formatDistance(ar, 2700), '2.7 كم');
  });

  test('relative times', () {
    final now = DateTime(2026, 9, 28, 18);
    expect(
      formatRelative(en, now.subtract(const Duration(seconds: 20)), now: now),
      'Just now',
    );
    expect(
      formatRelative(en, now.subtract(const Duration(minutes: 5)), now: now),
      '5 min ago',
    );
    expect(
      formatRelative(en, DateTime(2026, 9, 28, 9), now: now),
      '9 hours ago',
    );
    expect(
      formatRelative(en, DateTime(2026, 9, 27, 23), now: now),
      'Yesterday',
    );
    expect(
      formatRelative(ar, DateTime(2026, 9, 25, 12), now: now),
      'قبل 3 أيام',
    );
    expect(
      formatRelative(ar, DateTime(2026, 9, 26, 12), now: now),
      'قبل يومين',
    );
  });

  test('CO2e is formatted with one decimal below 10 kg', () {
    expect(formatCo2e(en, 1.234), '1.2 kg CO2e');
    expect(en.commonCo2eDisclaimer, contains('Estimate'));
  });
}
