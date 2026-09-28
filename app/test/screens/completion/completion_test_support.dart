// Fixture data, fakes and provider overrides for the completion screen.
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart' show XFile;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:kanz/core/data/db/database.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/services/gallery_picker.dart';
import 'package:kanz/core/services/permission_service.dart';
import 'package:kanz/core/services/share_service.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/core/state/history_providers.dart';
import 'package:kanz/core/state/impact_providers.dart';
import 'package:kanz/core/state/scan_session.dart';
import 'package:kanz/features/completion/made_photo.dart';
import 'package:kanz/features/completion/share_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../tutorial/tutorial_test_support.dart';

export '../tutorial/tutorial_test_support.dart';

const projectId = 'project_1';

ProjectRecord projectRecord(Lang lang, {bool completed = true}) {
  final tutorial = tutorialFixture(lang);
  final now = DateTime.now();
  return ProjectRecord(
    id: projectId,
    scanId: scanId,
    ideaId: ideaId,
    title: tutorial.title,
    idea: recommendFixture(lang).ideaById(ideaId),
    tutorial: tutorial,
    skill: tutorial.skill,
    tools: const [ToolId.pliers, ToolId.scissors, ToolId.twine],
    status: completed ? ProjectStatus.completed : ProjectStatus.inProgress,
    currentStep: 5,
    completedSteps: completed ? {1, 2, 3, 4, 5} : {1, 2},
    totalSteps: 5,
    createdAt: now.subtract(const Duration(hours: 1)),
    updatedAt: now,
    completedAt: completed ? now : null,
  );
}

const impactSummary = ImpactSummary(
  itemsByMaterial: {MaterialCategory.glass: 4, MaterialCategory.plastic: 3},
  itemsByKind: {
    ImpactKind.upcycled: 2,
    ImpactKind.recycled: 4,
    ImpactKind.donated: 1,
  },
  projectsCompleted: 2,
  streakDays: 3,
  activeToday: true,
  estimatedMassKg: 1.4,
  co2eKgEstimate: 0.9,
  co2eDisclaimer: 'Estimate',
);

ImpactEvent projectEvent() => ImpactEvent(
  id: 1,
  dedupeKey: 'upcycled:$projectId:item_1',
  kind: ImpactKind.upcycled,
  material: 'glass',
  itemName: 'Glass jam jar',
  quantity: 1,
  unit: 'pcs',
  scanId: scanId,
  projectId: projectId,
  itemId: 'item_1',
  createdAt: DateTime.now(),
);

class FakeShare implements ShareService {
  final List<({String text, String? imagePath})> shared = [];

  @override
  Future<void> share({
    required String text,
    String? imagePath,
    String? subject,
  }) async => shared.add((text: text, imagePath: imagePath));
}

class FakeRenderer extends ShareCardRenderer {
  FakeRenderer({this.result = '/tmp/kanz_share_project_1.png'});

  final String? result;
  final List<ShareCardData> rendered = [];

  @override
  Future<String?> render(BuildContext context, ShareCardData data) async {
    rendered.add(data);
    if (result == null) throw StateError('render failed');
    return result;
  }
}

/// Photos of finished projects kept in memory; records what was saved.
class FakeMadePhotoStore extends MadePhotoStore {
  FakeMadePhotoStore({this.photo})
    : super(directory: Directory.systemTemp.createTempSync('kanz_made'));

  /// The saved photo of the project, if any.
  String? photo;
  final List<(String, String)> saved = [];

  @override
  Future<String?> find(String projectId) async => photo;

  @override
  Future<String> save(String projectId, String sourcePath) async {
    saved.add((projectId, sourcePath));
    return photo = sourcePath;
  }
}

/// Camera permission fixed at [camera]; asking changes nothing.
class FakeCameraPermission implements PermissionService {
  FakeCameraPermission(this.camera);

  PermissionState camera;
  int settingsOpened = 0;

  @override
  Future<PermissionState> status(AppPermission permission) async => camera;

  @override
  Future<PermissionState> request(AppPermission permission) async => camera;

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }
}

/// Hands back [path] as the picked photo (null: the user cancelled).
class FakeGalleryPicker extends GalleryPicker {
  FakeGalleryPicker(this.path);

  final String? path;

  @override
  Future<XFile?> pick() async => path == null ? null : XFile(path!);
}

/// How the project stream behaves.
enum ProjectLoad { ready, loading, missing, error }

Future<List<Override>> completionOverrides({
  required ProjectRecord project,
  required ScanSessionState scan,
  ProjectLoad load = ProjectLoad.ready,
  FakeShare? share,
  ShareCardRenderer? renderer,
  MadePhotoStore? photos,
  PermissionService? permissions,
  GalleryPicker? gallery,
}) async {
  SharedPreferences.setMockInitialValues(const {});
  final preferences = await SharedPreferences.getInstance();
  return [
    sharedPreferencesProvider.overrideWithValue(preferences),
    vocabProvider.overrideWithValue(loadVocab()),
    projectProvider.overrideWith(
      (ref, id) => switch (load) {
        ProjectLoad.ready => Stream.value(project),
        ProjectLoad.missing => Stream<ProjectRecord?>.value(null),
        ProjectLoad.error => Stream<ProjectRecord?>.error(
          StateError('database closed'),
        ),
        // Never emits: the screen stays in its loading state.
        ProjectLoad.loading => StreamController<ProjectRecord?>().stream,
      },
    ),
    impactProvider.overrideWithValue(const AsyncData(impactSummary)),
    impactEventsProvider.overrideWith((ref) => Stream.value([projectEvent()])),
    scanSessionProvider.overrideWith2((id) => FakeScanSession(id, scan)),
    shareServiceProvider.overrideWithValue(share ?? FakeShare()),
    shareCardRendererProvider.overrideWithValue(renderer ?? FakeRenderer()),
    madePhotoStoreProvider.overrideWithValue(photos ?? FakeMadePhotoStore()),
    permissionServiceProvider.overrideWithValue(
      permissions ?? FakeCameraPermission(PermissionState.permanentlyDenied),
    ),
    galleryPickerProvider.overrideWithValue(gallery ?? FakeGalleryPicker(null)),
  ];
}
