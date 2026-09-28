import 'dart:io';

import 'package:share_plus/share_plus.dart';

/// Opens the system share sheet with an optional image (a finished project).
class ShareService {
  Future<void> share({
    required String text,
    String? imagePath,
    String? subject,
  }) async {
    final hasImage = imagePath != null && File(imagePath).existsSync();
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        files: hasImage
            ? [XFile(imagePath, mimeType: mimeTypeFor(imagePath))]
            : null,
      ),
    );
  }
}

/// MIME type of a shared image from its extension (the completion card is PNG,
/// photos and generated images are JPEG).
String mimeTypeFor(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}
