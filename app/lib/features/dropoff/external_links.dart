import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a link outside the app (Maps for directions, the dialer, a
/// website). Returns false when nothing could handle it.
typedef ExternalLinkOpener = Future<bool> Function(Uri uri);

/// The drop-off screen's way out to Maps, the phone and the web. A provider
/// so widget tests can record the links instead of launching them.
final externalLinkOpenerProvider = Provider<ExternalLinkOpener>(
  (ref) => (uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  },
);

/// `tel:` link for a listed phone number (spaces and dashes removed).
Uri phoneUri(String phone) =>
    Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[\s\-()]'), ''));

/// A website link; listings sometimes omit the scheme.
Uri? websiteUri(String website) {
  final trimmed = website.trim();
  if (trimmed.isEmpty) return null;
  return Uri.tryParse(
    trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed',
  );
}
