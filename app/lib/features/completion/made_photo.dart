import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/services/image_compressor.dart';
import '../../core/state/core_providers.dart';

/// Photos the user took of what they made, one `<projectId>.jpg` per
/// project in the documents directory, next to the scan photos. When the
/// server cannot draw a makeover, this photo is the "after" side of the
/// completion slider and of the share card.
class MadePhotoStore {
  MadePhotoStore({required this.directory, ImageCompressor? compressor})
    : _compressor = compressor ?? FlutterImageCompressor(outputDir: directory);

  final Directory directory;
  final ImageCompressor _compressor;

  File fileFor(String projectId) =>
      File(p.join(directory.path, '$projectId.jpg'));

  /// The saved photo of [projectId], or null when there is none.
  Future<String?> find(String projectId) async {
    final file = fileFor(projectId);
    return await file.exists() ? file.path : null;
  }

  /// Saves the photo at [sourcePath] for [projectId], replacing an earlier
  /// one: shrunk like a scan photo (1600 px, EXIF applied, then dropped, so
  /// no location tag is kept or shared).
  Future<String> save(String projectId, String sourcePath) async {
    // The compressor names its file after the id it is given.
    final saved = await _compressor.compressFile(sourcePath, scanId: projectId);
    // Same path as a replaced photo: drop the old picture from the cache.
    await FileImage(File(saved.path)).evict();
    return saved.path;
  }
}

final madePhotoStoreProvider = Provider<MadePhotoStore>(
  (ref) => MadePhotoStore(
    directory: Directory(
      p.join(ref.watch(appDirectoriesProvider).documents.path, 'projects'),
    ),
  ),
);

/// The path of the photo the user took of [projectId]'s result, if any.
final madePhotoProvider = FutureProvider.autoDispose.family<String?, String>(
  (ref, projectId) => ref.watch(madePhotoStoreProvider).find(projectId),
);
