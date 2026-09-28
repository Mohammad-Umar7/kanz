import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../models/models.dart';
import 'json_codec.dart';

/// A started upcycling project with its decoded idea, tutorial and progress.
class ProjectRecord {
  const ProjectRecord({
    required this.id,
    required this.scanId,
    required this.ideaId,
    required this.title,
    required this.idea,
    required this.status,
    required this.currentStep,
    required this.completedSteps,
    required this.totalSteps,
    required this.createdAt,
    required this.updatedAt,
    this.tutorial,
    this.skill,
    this.tools = const [],
    this.completedAt,
  });

  final String id;
  final String scanId;
  final String ideaId;
  final String title;

  /// Null only if the stored idea can no longer be decoded.
  final UpcycleIdea? idea;
  final Tutorial? tutorial;
  final SkillLevel? skill;
  final List<ToolId> tools;
  final ProjectStatus status;

  /// 1-based step the user is on.
  final int currentStep;
  final Set<int> completedSteps;
  final int totalSteps;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  bool get isCompleted => status == ProjectStatus.completed;

  /// 0..1 share of steps marked done.
  double get progress =>
      totalSteps == 0 ? 0 : (completedSteps.length / totalSteps).clamp(0, 1);
}

/// Projects and their step progress.
class ProjectRepository {
  ProjectRepository(this._db, {DateTime Function()? clock, Uuid? uuid})
    : _now = clock ?? DateTime.now,
      _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final DateTime Function() _now;
  final Uuid _uuid;

  /// The project for ([scanId], idea), created on first open.
  Future<ProjectRecord> getOrCreate({
    required String scanId,
    required UpcycleIdea idea,
  }) async {
    final existing = await getByIdea(scanId, idea.id);
    if (existing != null) return existing;
    final now = _now();
    final id = _uuid.v4();
    await _db
        .into(_db.projects)
        .insert(
          ProjectsCompanion.insert(
            id: id,
            scanId: scanId,
            ideaId: idea.id,
            title: idea.title,
            ideaJson: encodeStored(idea.toJson()),
            status: ProjectStatus.inProgress,
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return (await getByIdea(scanId, idea.id))!;
  }

  Future<ProjectRecord?> get(String id) async {
    final row = await (_db.select(
      _db.projects,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toRecord(row);
  }

  Future<ProjectRecord?> getByIdea(String scanId, String ideaId) async {
    final row =
        await (_db.select(_db.projects)
              ..where((p) => p.scanId.equals(scanId) & p.ideaId.equals(ideaId)))
            .getSingleOrNull();
    return row == null ? null : _toRecord(row);
  }

  Stream<ProjectRecord?> watch(String id) =>
      (_db.select(_db.projects)..where((p) => p.id.equals(id)))
          .watchSingleOrNull()
          .map((row) => row == null ? null : _toRecord(row));

  /// Newest activity first.
  Stream<List<ProjectRecord>> watchAll() {
    final query = _db.select(_db.projects)
      ..orderBy([(p) => OrderingTerm.desc(p.updatedAt)]);
    return query.watch().map((rows) => rows.map(_toRecord).toList());
  }

  /// Stores the tutorial the user is following. A different tutorial id (the
  /// user adapted skill or tools) has different steps, so progress restarts.
  Future<void> saveTutorial(
    String projectId,
    Tutorial tutorial, {
    required List<ToolId> tools,
  }) async {
    final current = await get(projectId);
    final changed = current?.tutorial?.tutorialId != tutorial.tutorialId;
    await _write(
      projectId,
      ProjectsCompanion(
        tutorialId: Value(tutorial.tutorialId),
        tutorialJson: Value(encodeStored(tutorial.toJson())),
        skill: Value(tutorial.skill.id),
        tools: Value(tools.map((t) => t.id).join(',')),
        totalSteps: Value(tutorial.steps.length),
        currentStep: changed && current?.tutorial != null
            ? const Value(1)
            : const Value.absent(),
        completedSteps: changed && current?.tutorial != null
            ? const Value('')
            : const Value.absent(),
      ),
    );
  }

  Future<void> setStepDone(
    String projectId,
    int step, {
    bool done = true,
  }) async {
    final current = await get(projectId);
    if (current == null) return;
    final steps = {...current.completedSteps};
    if (done) {
      steps.add(step);
    } else {
      steps.remove(step);
    }
    await _write(
      projectId,
      ProjectsCompanion(completedSteps: Value(encodeIntSet(steps))),
    );
  }

  Future<void> setCurrentStep(String projectId, int step) =>
      _write(projectId, ProjectsCompanion(currentStep: Value(step)));

  Future<void> complete(String projectId) {
    final now = _now();
    return _write(
      projectId,
      ProjectsCompanion(
        status: const Value(ProjectStatus.completed),
        completedAt: Value(now),
      ),
    );
  }

  Future<void> _write(String id, ProjectsCompanion changes) =>
      (_db.update(_db.projects)..where((p) => p.id.equals(id))).write(
        changes.copyWith(updatedAt: Value(_now())),
      );

  ProjectRecord _toRecord(Project row) => ProjectRecord(
    id: row.id,
    scanId: row.scanId,
    ideaId: row.ideaId,
    title: row.title,
    idea: decodeStored(row.ideaJson, UpcycleIdea.fromJson, what: 'idea'),
    tutorial: decodeStored(
      row.tutorialJson,
      Tutorial.fromJson,
      what: 'tutorial',
    ),
    skill: SkillLevel.tryFromId(row.skill),
    tools: [for (final id in row.tools.split(',')) ?ToolId.tryFromId(id)],
    status: row.status,
    currentStep: row.currentStep,
    completedSteps: decodeIntSet(row.completedSteps),
    totalSteps: row.totalSteps,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    completedAt: row.completedAt,
  );
}
