// Interactions on the completion screen: sharing the before/after card,
// the next actions, and the share card rendered to a real PNG.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kanz/app/routes.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/core/services/permission_service.dart';
import 'package:kanz/core/state/scan_session.dart';
import 'package:kanz/features/completion/completion_screen.dart';
import 'package:kanz/features/completion/share_card.dart';
import 'package:kanz/l10n/l10n.dart';

import '../../screenshots/harness.dart' show loadKanzFonts;
import 'completion_test_support.dart';

Future<GoRouter> _pump(
  WidgetTester tester, {
  required ScanSessionState scan,
  ProjectLoad load = ProjectLoad.ready,
  FakeShare? share,
  ShareCardRenderer? renderer,
  FakeMadePhotoStore? photos,
  FakeCameraPermission? permissions,
  FakeGalleryPicker? gallery,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  final overrides = await completionOverrides(
    project: projectRecord(Lang.en),
    scan: scan,
    load: load,
    share: share,
    renderer: renderer,
    photos: photos,
    permissions: permissions,
    gallery: gallery,
  );
  final router = GoRouter(
    initialLocation: AppRoutes.completion(projectId),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const Text('home')),
      GoRoute(path: '/scan', builder: (context, state) => const Text('scan')),
      GoRoute(
        path: '/history',
        builder: (context, state) => const Text('history'),
      ),
      GoRoute(
        path: '/projects/:projectId/done',
        builder: (context, state) =>
            CompletionScreen(projectId: state.pathParameters['projectId']!),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        theme: KanzTheme.light(),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

/// A scan with no pictures at all (no file images to decode in tests).
ScanSessionState _noPictures() => scanState(lang: Lang.en);

/// The share control: a full button with a picture to share, a quiet link
/// hugging its label without one.
Finder _shareAction() => find
    .descendant(
      of: find.byKey(const ValueKey('share-project')),
      matching: find.byType(InkWell),
    )
    .first;

void main() {
  setUpAll(loadKanzFonts);

  testWidgets('names the project and shows what changed', (tester) async {
    await _pump(tester, scan: _noPictures());
    expect(find.text('Hanging jar lantern'), findsOneWidget);
    expect(find.text('Glass jam jar'), findsOneWidget);
    // This project's own number leads, then the all-time totals.
    expect(find.text('What this project changed'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('item kept out of the bin'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('Days in a row'), findsOneWidget);
  });

  testWidgets('share renders the card and shares it with the text', (
    tester,
  ) async {
    final share = FakeShare();
    final renderer = FakeRenderer();
    await _pump(tester, scan: _noPictures(), share: share, renderer: renderer);

    await tester.tap(_shareAction());
    await tester.pumpAndSettle();

    expect(renderer.rendered.single.title, 'Hanging jar lantern');
    expect(renderer.rendered.single.madeFrom, 'Made from Glass jam jar');
    expect(share.shared.single.imagePath, '/tmp/kanz_share_project_1.png');
    expect(
      share.shared.single.text,
      'Hanging jar lantern, made from something I nearly threw away. '
      'Planned with Kanz.',
    );
  });

  testWidgets('when the card cannot be drawn the text is still shared', (
    tester,
  ) async {
    final share = FakeShare();
    await _pump(
      tester,
      scan: _noPictures(),
      share: share,
      renderer: FakeRenderer(result: null),
    );
    await tester.tap(_shareAction());
    await tester.pumpAndSettle();
    expect(share.shared.single.imagePath, isNull);
    expect(share.shared.single.text, contains('Hanging jar lantern'));
  });

  testWidgets('close goes home', (tester) async {
    final router = await _pump(tester, scan: _noPictures());
    await tester.tap(find.byKey(const ValueKey('completion-close')));
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, '/');
  });

  testWidgets('scan something else opens the scanner over home', (
    tester,
  ) async {
    final router = await _pump(tester, scan: _noPictures());
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('scan-again')),
      200,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('scan-again')));
    await tester.pumpAndSettle();
    expect(find.text('scan'), findsOneWidget);
    expect(router.state.uri.toString(), AppRoutes.scan(ScanMode.camera));
    // Back from the scanner lands on Home, not outside the app.
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('see my projects opens History over home', (tester) async {
    final router = await _pump(tester, scan: _noPictures());
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('see-projects')),
      200,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('see-projects')));
    await tester.pumpAndSettle();
    expect(find.text('history'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('a text scan without pictures shows the description', (
    tester,
  ) async {
    await _pump(
      tester,
      scan: scanState(
        lang: Lang.en,
        source: AnalysisSource.text,
        inputText: 'An empty glass jam jar',
        reference: quotaFailed,
      ),
    );
    expect(find.text('An empty glass jam jar'), findsOneWidget);
    expect(find.text('Share this project'), findsOneWidget);
    expect(find.byType(BeforeAfterSlider), findsNothing);
  });

  testWidgets('without a makeover the user can add a photo of the result', (
    tester,
  ) async {
    final photos = FakeMadePhotoStore();
    final share = FakeShare();
    final renderer = FakeRenderer();
    await _pump(
      tester,
      scan: _noPictures(),
      photos: photos,
      share: share,
      renderer: renderer,
      // The camera is off in Settings: the gallery is the way forward.
      permissions: FakeCameraPermission(PermissionState.permanentlyDenied),
      gallery: FakeGalleryPicker('/photos/lantern.jpg'),
    );
    expect(find.byKey(const ValueKey('replace-made-photo')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('add-made-photo')));
    await tester.pumpAndSettle();

    expect(find.text("The camera isn't available"), findsOneWidget);
    expect(find.text('Open settings'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('made-photo-gallery')));
    await tester.pumpAndSettle();

    // Back on the project, the photo is saved and becomes the result.
    expect(photos.saved, [(projectId, '/photos/lantern.jpg')]);
    expect(find.byKey(const ValueKey('add-made-photo')), findsNothing);
    expect(find.byKey(const ValueKey('replace-made-photo')), findsOneWidget);
    await tester.tap(_shareAction());
    await tester.pumpAndSettle();
    expect(renderer.rendered.single.after, isA<FileImage>());
  });

  testWidgets('closing the camera keeps the project as it was', (tester) async {
    final photos = FakeMadePhotoStore();
    await _pump(
      tester,
      scan: _noPictures(),
      photos: photos,
      permissions: FakeCameraPermission(PermissionState.restricted),
    );
    await tester.tap(find.byKey(const ValueKey('add-made-photo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(photos.saved, isEmpty);
    expect(find.byKey(const ValueKey('add-made-photo')), findsOneWidget);
  });

  testWidgets('a missing project points to History', (tester) async {
    await _pump(tester, scan: _noPictures(), load: ProjectLoad.missing);
    expect(find.text("This project isn't on this phone"), findsOneWidget);
    await tester.tap(find.text('See my projects'));
    await tester.pumpAndSettle();
    expect(find.text('history'), findsOneWidget);
  });

  testWidgets('the share card captures to a PNG file', (tester) async {
    tester.view
      ..physicalSize = const Size(1200, 2000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: KanzTheme.light(),
        home: Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(
            key: key,
            child: const ShareCard(
              data: ShareCardData(
                id: projectId,
                title: 'Hanging jar lantern',
                madeFrom: 'Made from Glass jam jar',
                beforeLabel: 'Before',
                afterLabel: 'After',
              ),
            ),
          ),
        ),
      ),
    );
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final dir = Directory.systemTemp.createTempSync('kanz_share_test');
    addTearDown(() => dir.deleteSync(recursive: true));
    final path = await tester.runAsync(
      () => ShareCardRenderer.capture(boundary, File('${dir.path}/card.png')),
    );
    final bytes = File(path!).readAsBytesSync();
    // PNG signature, and twice the logical width.
    expect(bytes.sublist(1, 4), 'PNG'.codeUnits);
    final width =
        (bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19];
    expect(width, (ShareCard.width * ShareCardRenderer.pixelRatio).round());
  });
}
