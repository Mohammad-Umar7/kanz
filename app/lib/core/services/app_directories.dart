import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Where the app keeps files that must survive offline: scan photos and
/// downloaded generated images. Both live in the documents directory so the
/// OS does not purge them like a cache.
class AppDirectories {
  const AppDirectories(this.documents);

  final Directory documents;

  /// Compressed scan photos, one `<scanId>.jpg` per scan.
  Directory get scans => Directory(p.join(documents.path, 'scans'));

  /// Generated after, step and bin images.
  Directory get images => Directory(p.join(documents.path, 'images'));

  static Future<AppDirectories> resolve() async {
    final dirs = AppDirectories(await getApplicationDocumentsDirectory());
    await dirs.scans.create(recursive: true);
    await dirs.images.create(recursive: true);
    return dirs;
  }
}
