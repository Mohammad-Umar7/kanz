import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/state/generated_image.dart';

/// The picture for a generated image that is ready: the copy on the device
/// when there is one (works offline, no flash on rebuild), otherwise the
/// versioned URL the providers resolved. Null while it is not ready.
ImageProvider? generatedImageProvider(GeneratedImageState image) {
  if (!image.isReady) return null;
  final path = image.localPath;
  if (path != null && path.isNotEmpty) return FileImage(File(path));
  final url = image.url;
  if (url != null && url.isNotEmpty) return CachedNetworkImageProvider(url);
  return null;
}

/// The scan photo on the device, or null for text scans.
ImageProvider? localPhotoProvider(String? path) =>
    path == null || path.isEmpty ? null : FileImage(File(path));

/// Whether a failed generated image failed because the server has no image
/// quota. That is not the user's to fix and retrying cannot help, so the
/// screens say so quietly and hide every "try again" for it.
bool isQuotaPaused(GeneratedImageState image) =>
    image.status == ImageStatus.failed &&
    image.error?.code == ApiErrorCode.aiQuotaExhausted;
