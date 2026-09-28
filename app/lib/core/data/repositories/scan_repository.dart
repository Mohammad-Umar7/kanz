import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models/models.dart';
import 'json_codec.dart';

/// A scan as stored on the device, with its API responses decoded.
class StoredScan {
  const StoredScan({
    required this.id,
    required this.createdAt,
    required this.source,
    required this.lang,
    this.inputText,
    this.localImagePath,
    this.analysis,
    this.recommendation,
    this.facilities,
    this.stages = const {},
    this.focusItemId,
  });

  final String id;
  final DateTime createdAt;
  final AnalysisSource source;
  final Lang lang;
  final String? inputText;
  final String? localImagePath;
  final AnalyzeResponse? analysis;
  final RecommendResponse? recommendation;
  final FacilitiesResponse? facilities;

  /// Pipeline stage name -> status name as last persisted.
  final Map<String, String> stages;
  final String? focusItemId;
}

/// One row of the History list: enough to render without decoding responses.
class ScanSummary {
  const ScanSummary({
    required this.id,
    required this.createdAt,
    required this.source,
    required this.itemCount,
    required this.hasRecommendation,
    this.title,
    this.primaryCategory,
    this.localImagePath,
    this.inputText,
  });

  final String id;
  final DateTime createdAt;
  final AnalysisSource source;

  /// Primary item name, null until analysis finished.
  final String? title;
  final MaterialCategory? primaryCategory;
  final int itemCount;

  /// Local photo for the thumbnail (null for text scans).
  final String? localImagePath;
  final String? inputText;
  final bool hasRecommendation;
}

/// Persists every stage of a scan so History can reopen it offline.
class ScanRepository {
  ScanRepository(this._db, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Future<void> create({
    required String id,
    required AnalysisSource source,
    required Lang lang,
    String? inputText,
    String? localImagePath,
  }) async {
    final now = _now();
    await _db
        .into(_db.scans)
        .insertOnConflictUpdate(
          ScansCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            source: source == AnalysisSource.image ? 'image' : 'text',
            lang: lang.id,
            inputText: Value(inputText),
            localImagePath: Value(localImagePath),
          ),
        );
  }

  Future<void> saveAnalysis(String id, AnalyzeResponse response) {
    final primary = response.analysis.primaryItem;
    return _update(
      id,
      ScansCompanion(
        imageId: Value(response.imageId),
        imageUrl: Value(response.imageUrl),
        title: Value(primary?.name),
        primaryCategory: Value(primary?.category.id),
        itemCount: Value(response.analysis.items.length),
        analysisJson: Value(encodeStored(response.toJson())),
      ),
    );
  }

  Future<void> saveRecommendation(String id, RecommendResponse? response) =>
      _update(
        id,
        ScansCompanion(
          recommendationJson: Value(
            response == null ? null : encodeStored(response.toJson()),
          ),
        ),
      );

  Future<void> saveFacilities(String id, FacilitiesResponse? response) =>
      _update(
        id,
        ScansCompanion(
          facilitiesJson: Value(
            response == null ? null : encodeStored(response.toJson()),
          ),
        ),
      );

  Future<void> saveStages(String id, Map<String, String> stages) =>
      _update(id, ScansCompanion(stagesJson: Value(jsonEncode(stages))));

  Future<void> saveFocus(String id, String? itemId) =>
      _update(id, ScansCompanion(focusItemId: Value(itemId)));

  Future<StoredScan?> get(String id) async {
    final row = await (_db.select(
      _db.scans,
    )..where((s) => s.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toStored(row);
  }

  /// Newest first.
  Stream<List<ScanSummary>> watchAll() {
    final query = _db.select(_db.scans)
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    return query.watch().map((rows) => rows.map(_toSummary).toList());
  }

  /// Analyses of scans made since [since], for the swaps history summary.
  Future<List<Analysis>> analysesSince(DateTime since) async {
    final rows =
        await (_db.select(_db.scans)..where(
              (s) =>
                  s.createdAt.isBiggerOrEqualValue(since) &
                  s.analysisJson.isNotNull(),
            ))
            .get();
    return [
      for (final row in rows)
        if (decodeStored(
              row.analysisJson,
              AnalyzeResponse.fromJson,
              what: 'analysis',
            )
            case final response?)
          response.analysis,
    ];
  }

  /// Days on which at least one scan was made (local dates), for the streak.
  Future<List<DateTime>> scanDates() async {
    final rows = await (_db.selectOnly(
      _db.scans,
    )..addColumns([_db.scans.createdAt])).get();
    return [for (final r in rows) r.read(_db.scans.createdAt)!];
  }

  /// Removes a scan, its projects (cascade) and its local photo.
  Future<void> delete(String id) async {
    final row = await (_db.select(
      _db.scans,
    )..where((s) => s.id.equals(id))).getSingleOrNull();
    await (_db.delete(_db.scans)..where((s) => s.id.equals(id))).go();
    final path = row?.localImagePath;
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    }
  }

  Future<void> _update(String id, ScansCompanion changes) =>
      (_db.update(_db.scans)..where((s) => s.id.equals(id))).write(
        changes.copyWith(updatedAt: Value(_now())),
      );

  StoredScan _toStored(Scan row) {
    Map<String, String> stages = const {};
    try {
      stages = (jsonDecode(row.stagesJson) as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v as String),
      );
    } on Object {
      // A malformed stage map only loses the progress indicator, not results.
    }
    return StoredScan(
      id: row.id,
      createdAt: row.createdAt,
      source: row.source == 'text' ? AnalysisSource.text : AnalysisSource.image,
      lang: Lang.fromId(row.lang),
      inputText: row.inputText,
      localImagePath: row.localImagePath,
      analysis: decodeStored(
        row.analysisJson,
        AnalyzeResponse.fromJson,
        what: 'analysis',
      ),
      recommendation: decodeStored(
        row.recommendationJson,
        RecommendResponse.fromJson,
        what: 'recommendation',
      ),
      facilities: decodeStored(
        row.facilitiesJson,
        FacilitiesResponse.fromJson,
        what: 'facilities',
      ),
      stages: stages,
      focusItemId: row.focusItemId,
    );
  }

  ScanSummary _toSummary(Scan row) => ScanSummary(
    id: row.id,
    createdAt: row.createdAt,
    source: row.source == 'text' ? AnalysisSource.text : AnalysisSource.image,
    title: row.title,
    primaryCategory: MaterialCategory.tryFromId(row.primaryCategory),
    itemCount: row.itemCount,
    localImagePath: row.localImagePath,
    inputText: row.inputText,
    hasRecommendation: row.recommendationJson != null,
  );
}
