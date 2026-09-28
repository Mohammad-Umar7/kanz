import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../core/state/scan_session.dart';

/// The user's photo for a scan, or null for text scans (and photos that are
/// no longer on the device, which the image widgets draw as a dark frame).
ImageProvider? scanPhoto(ScanSessionState session) {
  final path = session.localImagePath;
  return path == null ? null : FileImage(File(path));
}

/// Hero tag of an idea's after image, shared by its card and the idea screen.
Object afterHeroTag(String scanId, String ideaId) => 'after-$scanId-$ideaId';

/// Whether a failed generated image is worth another try. The free-tier
/// quota never is: every retry would fail the same way.
bool canRetryImage(GeneratedImageState image) {
  if (image.status != ImageStatus.failed) return false;
  final error = image.error;
  return error == null || (error.retryable && !error.isQuotaExhausted);
}

/// Generated images for one screen, one provider per image for as long as
/// its URL stays the same.
///
/// A new image first shows from the backend URL; a moment later the session
/// adds the downloaded copy's path. Switching providers then would decode the
/// image again and replay its fade-in, so the first provider is kept until
/// the URL itself changes (a regenerated image carries a new `?v=`). Images
/// restored from history arrive with both and use the local copy.
class StableImages {
  final Map<String, ({String? url, ImageProvider provider})> _entries = {};

  ImageProvider? resolve(String key, GeneratedImageState image) {
    if (!image.isReady) return null;
    final kept = _entries[key];
    if (kept != null && kept.url == image.url) return kept.provider;
    final local = image.localPath;
    final url = image.url;
    final ImageProvider? provider = local != null
        ? FileImage(File(local))
        : (url != null ? NetworkImage(url) : null);
    if (provider == null) return null;
    _entries[key] = (url: url, provider: provider);
    return provider;
  }

  /// The "before" picture: the user's photo, or for a text scan the
  /// generated photo of the described item when there is one.
  ImageProvider? before(ScanSessionState session) =>
      scanPhoto(session) ?? resolve('reference', session.referenceImage);
}
