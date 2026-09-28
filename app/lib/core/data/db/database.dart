/// Local SQLite database (drift): everything History, Projects and Impact need
/// to work offline.
///
/// * `scans`: one row per scan with the full analyze/recommend/facilities
///   responses as JSON, so a scan reopens with all its results without network.
/// * `projects`: an idea the user started, with its tutorial and step progress.
/// * `impact_events`: one row per item recycled, donated, disposed of or
///   upcycled; the Impact tab aggregates these.
/// * `image_cache`: generated images downloaded to the documents directory,
///   keyed by the backend's image cache key.
///
/// API responses are stored as raw JSON text and decoded by the repositories
/// with a guard, so a row written by an older app version can never crash the
/// History screen.
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Lifecycle of a started project.
enum ProjectStatus { inProgress, completed }

/// What happened to an item, for the Impact tab.
enum ImpactKind { recycled, donated, disposed, upcycled }

@TableIndex(name: 'scans_created_at', columns: {#createdAt})
class Scans extends Table {
  /// App-generated id (uuid v4), known before the backend answers.
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// 'image' or 'text' (AnalysisSource wire id).
  TextColumn get source => text()();

  /// Content language the scan was analyzed in ('en' | 'ar').
  TextColumn get lang => text()();

  /// The description, for text scans.
  TextColumn get inputText => text().nullable()();

  /// Compressed photo in the documents directory (thumbnail and offline hero).
  TextColumn get localImagePath => text().nullable()();

  /// Backend upload id ('img_...' / 'txt_...') once analyze succeeded.
  TextColumn get imageId => text().nullable()();
  TextColumn get imageUrl => text().nullable()();

  /// Primary item name and category, denormalized for the history list.
  TextColumn get title => text().nullable()();
  TextColumn get primaryCategory => text().nullable()();
  IntColumn get itemCount => integer().withDefault(const Constant(0))();

  TextColumn get analysisJson => text().nullable()();
  TextColumn get recommendationJson => text().nullable()();
  TextColumn get facilitiesJson => text().nullable()();

  /// Pipeline stage -> status name, e.g. {"identifying": "done"}.
  TextColumn get stagesJson => text().withDefault(const Constant('{}'))();
  TextColumn get focusItemId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'projects_scan_id', columns: {#scanId})
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get scanId =>
      text().references(Scans, #id, onDelete: KeyAction.cascade)();
  TextColumn get ideaId => text()();
  TextColumn get title => text()();

  /// The UpcycleIdea the project was started from.
  TextColumn get ideaJson => text()();

  /// The latest tutorial (after any adaptation) and the profile it was made for.
  TextColumn get tutorialId => text().nullable()();
  TextColumn get tutorialJson => text().nullable()();
  TextColumn get skill => text().nullable()();

  /// Comma-separated ToolId wire ids the tutorial was adapted to.
  TextColumn get tools => text().withDefault(const Constant(''))();

  IntColumn get totalSteps => integer().withDefault(const Constant(0))();

  /// 1-based step the user is looking at.
  IntColumn get currentStep => integer().withDefault(const Constant(1))();

  /// Comma-separated 1-based step numbers marked done.
  TextColumn get completedSteps => text().withDefault(const Constant(''))();
  TextColumn get status => textEnum<ProjectStatus>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {scanId, ideaId},
  ];
}

@TableIndex(name: 'impact_events_created_at', columns: {#createdAt})
class ImpactEvents extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `kind:scanOrProject:item`, so marking the same item twice counts once.
  TextColumn get dedupeKey => text().unique()();
  TextColumn get kind => textEnum<ImpactKind>()();

  /// MaterialCategory wire id.
  TextColumn get material => text()();
  TextColumn get itemName => text()();

  /// Quantity as analyzed ('1 pcs', '0.5 kg'); feeds the CO2e estimate.
  RealColumn get quantity => real().withDefault(const Constant(1))();
  TextColumn get unit => text().withDefault(const Constant('pcs'))();

  /// No foreign keys: impact stays when a scan is removed from history.
  TextColumn get scanId => text().nullable()();
  TextColumn get projectId => text().nullable()();
  TextColumn get itemId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('ImageCacheEntry')
@TableIndex(name: 'image_cache_scan', columns: {#scanId, #ideaId})
@TableIndex(name: 'image_cache_step', columns: {#tutorialId, #step})
class ImageCache extends Table {
  /// Backend cache key (ImageResponse.key).
  TextColumn get key => text()();
  TextColumn get remoteUrl => text()();
  TextColumn get localPath => text()();

  /// ImageKind wire id: 'after', 'step' or 'bin'.
  TextColumn get kind => text()();
  TextColumn get scanId => text().nullable()();
  TextColumn get ideaId => text().nullable()();
  TextColumn get tutorialId => text().nullable()();
  IntColumn get step => integer().nullable()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get byteSize => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  String get tableName => 'image_cache';

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [Scans, Projects, ImpactEvents, ImageCache])
class AppDatabase extends _$AppDatabase {
  /// Opens the on-device database file `kanz.sqlite`.
  AppDatabase.open() : super(driftDatabase(name: 'kanz'));

  /// For tests: `AppDatabase(NativeDatabase.memory())`.
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Each schema bump adds one explicit step here (drift `stepByStep`), so
      // user history always survives an app update. Version 1 is the first
      // shipped schema, so reaching this point means a step is missing.
      throw StateError('No migration from schema $from to $to');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
