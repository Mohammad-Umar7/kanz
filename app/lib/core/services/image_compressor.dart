import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

/// A photo prepared for upload and kept on the device for offline history.
class CompressedImage {
  const CompressedImage({required this.bytes, required this.path});

  /// JPEG bytes to send to /v1/analyze.
  final Uint8List bytes;

  /// The same JPEG saved under the documents directory.
  final String path;
}

/// Shrinks photos before upload.
///
/// ~1600 px on the long edge at JPEG quality 85 keeps labels, resin codes and
/// wear readable for the vision model while cutting a 12 MP photo from ~4 MB
/// to ~300 KB, which is most of the upload time on mobile data.
abstract interface class ImageCompressor {
  Future<CompressedImage> compressFile(
    String sourcePath, {
    required String scanId,
  });

  Future<CompressedImage> compressBytes(
    Uint8List source, {
    required String scanId,
  });
}

class FlutterImageCompressor implements ImageCompressor {
  FlutterImageCompressor({required this.outputDir});

  static const longEdge = 1600;
  static const quality = 85;

  final Directory outputDir;

  @override
  Future<CompressedImage> compressFile(
    String sourcePath, {
    required String scanId,
  }) async =>
      compressBytes(await File(sourcePath).readAsBytes(), scanId: scanId);

  @override
  Future<CompressedImage> compressBytes(
    Uint8List source, {
    required String scanId,
  }) async {
    final size = await _decodedSize(source);
    final long = math.max(size.width, size.height);
    final short = math.min(size.width, size.height);
    // flutter_image_compress scales by min(w / minWidth, h / minHeight) and never
    // upscales, so asking for the target short edge on both axes yields a long
    // edge of exactly [longEdge]. Long/short edges do not depend on EXIF rotation.
    final targetShort = long <= longEdge
        ? short
        : (short * longEdge / long).round();
    // Decode at a power-of-two subsample first so a 50 MP photo never has to be
    // held in memory at full size (Android only; iOS ignores it).
    var sample = 1;
    while (long ~/ (sample * 2) >= longEdge) {
      sample *= 2;
    }

    final bytes = await FlutterImageCompress.compressWithList(
      source,
      minWidth: math.max(1, targetShort),
      minHeight: math.max(1, targetShort),
      quality: quality,
      inSampleSize: sample,
      // Bake the EXIF orientation into the pixels, then drop EXIF entirely: the
      // model sees the photo upright and no GPS tag ever leaves the phone.
      autoCorrectionAngle: true,
      keepExif: false,
    );

    await outputDir.create(recursive: true);
    final file = File(p.join(outputDir.path, '$scanId.jpg'));
    await file.writeAsBytes(bytes, flush: true);
    return CompressedImage(bytes: bytes, path: file.path);
  }

  static Future<({int width, int height})> _decodedSize(Uint8List bytes) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final size = (width: descriptor.width, height: descriptor.height);
    descriptor.dispose();
    buffer.dispose();
    return size;
  }
}
