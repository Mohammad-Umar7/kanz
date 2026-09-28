import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../db/database.dart';
import '../models/models.dart';

export '../db/database.dart' show ImageCacheEntry;

/// Fetches the bytes of a generated image (ApiClient.downloadBytes in the app).
typedef ImageDownloader = Future<Uint8List> Function(String pathOrUrl);

/// Keeps generated images (after, step, bin) on the device so History and
/// Projects show them offline. The backend's image cache key maps to a local
/// file under `<documents>/images/`.
class ImageCacheRepository {
  ImageCacheRepository({
    required AppDatabase db,
    required ImageDownloader download,
    required Directory directory,
    DateTime Function()? clock,
  }) : _db = db,
       _download = download,
       _dir = directory,
       _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final ImageDownloader _download;
  final Directory _dir;
  final DateTime Function() _now;

  /// Downloads [image] unless the same URL is already cached, and returns the
  /// entry with its local path. [force] re-downloads (after a regenerate).
  Future<ImageCacheEntry> store(
    ImageResponse image, {
    String? scanId,
    String? ideaId,
    String? tutorialId,
    bool force = false,
  }) async {
    final existing = await entry(image.key);
    if (!force &&
        existing != null &&
        existing.remoteUrl == image.url &&
        File(existing.localPath).existsSync()) {
      return existing;
    }

    final bytes = await _download(image.url);
    if (!_dir.existsSync()) await _dir.create(recursive: true);
    // The file name hashes key and time: a regenerated image never overwrites a
    // file a widget may still be showing.
    final stamp = _now().microsecondsSinceEpoch;
    final name = sha1.convert(utf8.encode('${image.key}|$stamp')).toString();
    final file = File(p.join(_dir.path, '$name.jpg'));
    await file.writeAsBytes(bytes, flush: true);

    final row = ImageCacheCompanion.insert(
      key: image.key,
      remoteUrl: image.url,
      localPath: file.path,
      kind: _kindId(image.kind),
      scanId: Value(scanId),
      ideaId: Value(ideaId),
      tutorialId: Value(tutorialId),
      step: Value(image.step),
      width: Value(image.width),
      height: Value(image.height),
      byteSize: bytes.length,
      createdAt: _now(),
    );
    await _db.into(_db.imageCache).insertOnConflictUpdate(row);

    if (existing != null && existing.localPath != file.path) {
      final old = File(existing.localPath);
      if (old.existsSync()) await old.delete();
    }
    return (await entry(image.key))!;
  }

  Future<ImageCacheEntry?> entry(String key) => (_db.select(
    _db.imageCache,
  )..where((e) => e.key.equals(key))).getSingleOrNull();

  /// The cached after image of an idea in a scan, if it is still on disk.
  Future<ImageCacheEntry?> afterImage(String scanId, String ideaId) async {
    final rows =
        await (_db.select(_db.imageCache)
              ..where(
                (e) =>
                    e.scanId.equals(scanId) &
                    e.ideaId.equals(ideaId) &
                    e.kind.equals('after'),
              )
              ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
              ..limit(1))
            .get();
    return _onDisk(rows.firstOrNull);
  }

  /// The cached "before" picture of a text scan, if it is still on disk.
  Future<ImageCacheEntry?> referenceImage(String scanId) async {
    final rows =
        await (_db.select(_db.imageCache)
              ..where(
                (e) => e.scanId.equals(scanId) & e.kind.equals('reference'),
              )
              ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
              ..limit(1))
            .get();
    return _onDisk(rows.firstOrNull);
  }

  /// The cached image of one tutorial step, if it is still on disk.
  Future<ImageCacheEntry?> stepImage(String tutorialId, int step) async {
    final rows =
        await (_db.select(_db.imageCache)
              ..where(
                (e) => e.tutorialId.equals(tutorialId) & e.step.equals(step),
              )
              ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
              ..limit(1))
            .get();
    return _onDisk(rows.firstOrNull);
  }

  /// Removes every image downloaded for [scanId] (after and step images) and
  /// its files, when the scan is deleted from History.
  Future<void> deleteForScan(String scanId) async {
    final rows = await (_db.select(
      _db.imageCache,
    )..where((e) => e.scanId.equals(scanId))).get();
    await (_db.delete(
      _db.imageCache,
    )..where((e) => e.scanId.equals(scanId))).go();
    for (final row in rows) {
      final file = File(row.localPath);
      if (file.existsSync()) await file.delete();
    }
  }

  ImageCacheEntry? _onDisk(ImageCacheEntry? e) =>
      e != null && File(e.localPath).existsSync() ? e : null;

  static String _kindId(ImageKind kind) => switch (kind) {
    ImageKind.after => 'after',
    ImageKind.step => 'step',
    ImageKind.bin => 'bin',
    ImageKind.reference => 'reference',
  };
}
