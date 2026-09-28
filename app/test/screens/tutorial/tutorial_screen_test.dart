// Interactions on the tutorial screen: pager and controller stay in step,
// marking a step done (with its haptic), adapting, hands-free, finishing.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/features/tutorial/tutorial_screen.dart';
import 'package:kanz/l10n/l10n.dart';

import '../../screenshots/harness.dart' show loadKanzFonts;
import 'tutorial_test_support.dart';

/// No generated pictures anywhere: every step shows its static fallback, so
/// the tree has no endless spinner and `pumpAndSettle` settles.
TutorialState _ready({int current = 1, Set<int> done = const {}}) =>
    readyTutorial(
      lang: Lang.en,
      images: {1: quotaFailed},
      current: current,
      done: done,
    );

class _Rig {
  FakeTutorialController? tutorial;
  FakeHandsFree? handsFree;
  final List<MethodCall> platformCalls = [];
}

Future<_Rig> _pump(
  WidgetTester tester, {
  required TutorialState state,
  HandsFreeState handsFree = const HandsFreeState(),
  Map<String, Object> prefs = const {},
  Locale locale = const Locale('en'),
  int? initialPage,
  bool reduceMotion = false,
}) async {
  final rig = _Rig();
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      rig.platformCalls.add(call);
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  final List<Override> overrides = await tutorialOverrides(
    tutorial: state,
    scan: scanState(lang: Lang.en),
    handsFree: handsFree,
    prefs: prefs,
    onController: (c) => rig.tutorial = c,
    onHandsFree: (c) => rig.handsFree = c,
  );
  final router = GoRouter(
    initialLocation: '/tutorial',
    routes: [
      GoRoute(
        path: '/tutorial',
        builder: (context, state) => TutorialScreen(
          scanId: scanId,
          ideaId: ideaId,
          initialPage: initialPage,
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/done',
        builder: (context, state) =>
            Text('done ${state.pathParameters['projectId']}'),
      ),
      GoRoute(
        path: '/results/:scanId',
        builder: (context, state) =>
            Text('results ${state.pathParameters['scanId']}'),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        theme: KanzTheme.light(locale: locale),
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reduceMotion),
          child: child!,
        ),
      ),
    ),
  );
  // Fixed frames: an adapting tutorial shows an endless progress line.
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  return rig;
}

String _numeral(WidgetTester tester) {
  final numeral = tester.widget<StepNumeral>(
    find.byType(StepNumeral).hitTestable(),
  );
  return '${numeral.current}/${numeral.total}';
}

void main() {
  setUpAll(loadKanzFonts);

  testWidgets('opens on the overview and starts at step 1', (tester) async {
    final rig = await _pump(tester, state: _ready());
    expect(find.text('Hanging jar lantern'), findsOneWidget);
    expect(find.text('Start step 1'), findsOneWidget);

    await tester.tap(find.text('Start step 1'));
    await tester.pumpAndSettle();
    expect(_numeral(tester), '1/5');
    expect(rig.tutorial!.calls, isNot(contains('goToStep:1')));
  });

  testWidgets('resumes at the saved step', (tester) async {
    await _pump(tester, state: _ready(current: 3, done: {1, 2}));
    expect(_numeral(tester), '3/5');
    expect(find.text('Add the handle'), findsOneWidget);
  });

  testWidgets('mark step done saves it, fires the step haptic and moves on', (
    tester,
  ) async {
    final rig = await _pump(tester, state: _ready(current: 2, done: {1}));
    await tester.tap(find.byKey(const ValueKey('mark-done')));
    await tester.pumpAndSettle();

    expect(rig.tutorial!.calls, contains('markStepDone:2:true'));
    expect(
      rig.platformCalls.map((c) => c.arguments),
      contains('HapticFeedbackType.lightImpact'),
    );
    expect(_numeral(tester), '3/5');
    expect(rig.tutorial!.calls, contains('goToStep:3'));

    // Back on a done step, the button undoes it.
    await tester.tap(find.byKey(const ValueKey('previous-step')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('step-done')));
    await tester.pumpAndSettle();
    expect(rig.tutorial!.calls, contains('markStepDone:2:false'));
  });

  testWidgets('with reduced motion the pager jumps without animating', (
    tester,
  ) async {
    await _pump(
      tester,
      state: _ready(current: 2, done: {1}),
      reduceMotion: true,
    );
    await tester.tap(find.byKey(const ValueKey('next-step')));
    await tester.pump();
    // One frame later the pager is already there: no page animation.
    expect(_numeral(tester), '3/5');
  });

  testWidgets('icon-only controls are named and the toggle reports its state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, state: _ready(current: 2, done: {1}));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Hands-free mode')),
      matchesSemantics(
        label: 'Hands-free mode',
        isButton: true,
        hasSelectedState: true,
        isSelected: false,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(find.bySemanticsLabel('Adapt to your skill and tools'), findsOne);
    expect(find.bySemanticsLabel('Next step'), findsOne);
    expect(find.bySemanticsLabel('Previous step'), findsOne);
    expect(find.bySemanticsLabel('Step 2 of 5'), findsOne);
    handle.dispose();
  });

  testWidgets('swiping moves the saved step', (tester) async {
    final rig = await _pump(tester, state: _ready(current: 2, done: {1}));
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(_numeral(tester), '3/5');
    expect(rig.tutorial!.calls, contains('goToStep:3'));
  });

  testWidgets('in Arabic the next step is a swipe to the right', (
    tester,
  ) async {
    final rig = await _pump(
      tester,
      state: _ready(current: 2, done: {1}),
      locale: const Locale('ar'),
    );
    await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
    await tester.pumpAndSettle();
    expect(rig.tutorial!.calls, contains('goToStep:3'));
  });

  testWidgets('a step change from a voice command moves the pager', (
    tester,
  ) async {
    final rig = await _pump(tester, state: _ready(current: 2, done: {1}));
    await rig.tutorial!.next();
    await tester.pumpAndSettle();
    expect(_numeral(tester), '3/5');
  });

  testWidgets('the hands-free toggle drives the hands-free controller', (
    tester,
  ) async {
    final rig = await _pump(tester, state: _ready(current: 2, done: {1}));
    expect(find.byKey(const ValueKey('hands-free-strip')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('hands-free-toggle')));
    await tester.pump();
    expect(rig.handsFree!.toggles, 1);
    expect(find.byKey(const ValueKey('hands-free-strip')), findsOneWidget);
    expect(find.text('Listening'), findsOneWidget);
  });

  testWidgets('hands-free starts on its own when the setting is on', (
    tester,
  ) async {
    final rig = await _pump(
      tester,
      state: _ready(current: 2, done: {1}),
      prefs: {'settings.hands_free': true},
    );
    expect(rig.handsFree!.enables, 1);
    expect(find.byKey(const ValueKey('hands-free-strip')), findsOneWidget);
  });

  testWidgets('the adapt sheet rewrites for the chosen skill and tools', (
    tester,
  ) async {
    final rig = await _pump(tester, state: _ready());
    await tester.tap(find.byKey(const ValueKey('adapt-action')));
    await tester.pumpAndSettle();
    expect(find.text('Adapt this tutorial'), findsOneWidget);

    await tester.tap(find.text('Intermediate'));
    await tester.tap(find.byKey(const ValueKey('adapt-tool-craft_wire')));
    await tester.pump();
    await tester.tap(find.text('Rewrite the steps'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      rig.tutorial!.calls,
      contains('adapt:intermediate:pliers,scissors,twine,craft_wire'),
    );
    // The old tutorial stays while a progress line says what is happening.
    expect(find.textContaining('Rewriting for Intermediate'), findsOneWidget);
    expect(find.text('Hanging jar lantern'), findsOneWidget);
  });

  testWidgets('an unchanged adapt sheet cannot submit', (tester) async {
    await _pump(tester, state: _ready());
    await tester.tap(find.byKey(const ValueKey('adapt-action')));
    await tester.pumpAndSettle();
    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Rewrite the steps'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('a finished adapt highlights the new note on the overview', (
    tester,
  ) async {
    final adapted = tutorialFixture(Lang.en).copyWith(
      tutorialId: 'tut_2',
      adaptedNote: 'Adapted for Advanced: drill the lid.',
    );
    await _pump(
      tester,
      state: _ready(current: 3, done: {1, 2}).copyWith(adapting: true),
    );
    expect(_numeral(tester), '3/5');

    final container = ProviderScope.containerOf(
      tester.element(find.byType(TutorialScreen)),
    );
    final controller = container.read(
      tutorialControllerProvider(tutorialKey).notifier,
    );
    // The fake exposes state; this is what adapt() leaves behind.
    (controller as FakeTutorialController).debugSet(
      readyTutorial(lang: Lang.en, tutorial: adapted, images: {1: quotaFailed}),
    );
    await tester.pumpAndSettle();
    expect(find.text('Adapted for Advanced: drill the lid.'), findsOneWidget);
    expect(find.text('UPDATED'), findsOneWidget);
    expect(find.text('Start step 1'), findsOneWidget);
  });

  testWidgets('finish completes the project and opens the completion', (
    tester,
  ) async {
    final rig = await _pump(
      tester,
      state: _ready(current: 5, done: {1, 2, 3, 4, 5}),
      initialPage: 6,
    );
    expect(find.text('Finishing and care'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('finish-project')));
    await tester.pumpAndSettle();
    expect(rig.tutorial!.calls, contains('complete'));
    expect(find.text('done project_1'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    final rig = await _pump(
      tester,
      state: const TutorialState(
        phase: TutorialPhase.failed,
        error: ApiException(
          code: ApiErrorCode.aiUnavailable,
          message: 'busy',
          retryable: true,
        ),
      ),
    );
    expect(find.text("The tutorial didn't load"), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(rig.tutorial!.calls, contains('retry'));
  });

  testWidgets('a failed step picture retries that step', (tester) async {
    final rig = await _pump(
      tester,
      state: readyTutorial(
        lang: Lang.en,
        images: {1: const GeneratedImageState(status: ImageStatus.failed)},
        current: 1,
      ),
      initialPage: 1,
    );
    expect(find.text("This step's image didn't load"), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(rig.tutorial!.calls, contains('regenerateStep:1'));
  });

  testWidgets('no retry when the server has no image quota', (tester) async {
    await _pump(tester, state: _ready(), initialPage: 1);
    expect(
      find.text('Image generation is paused on this server'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsNothing);
    expect(find.bySemanticsLabel('Redraw picture'), findsNothing);
  });

  testWidgets('a finished picture is redrawn from the link under it', (
    tester,
  ) async {
    final rig = await _pump(
      tester,
      state: readyTutorial(
        lang: Lang.en,
        images: {1: readyImage('/missing/step_1.png')},
        current: 1,
      ),
      initialPage: 1,
      reduceMotion: true,
    );
    // Nothing sits on the picture itself.
    expect(find.byTooltip('Try another image'), findsNothing);
    await tester.tap(find.text('Redraw picture'));
    await tester.pump();
    expect(rig.tutorial!.calls, contains('regenerateStep:1'));
  });

  testWidgets('a rewrite that failed can always be tried again', (
    tester,
  ) async {
    // Reopened after the failure: the request itself is gone, so trying
    // again opens the sheet to choose once more.
    await _pump(
      tester,
      state: readyTutorial(
        lang: Lang.en,
        images: {1: quotaFailed},
        adaptError: busyError,
      ),
    );
    expect(
      find.textContaining("Couldn't rewrite the tutorial"),
      findsOneWidget,
    );
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Adapt this tutorial'), findsOneWidget);
  });

  testWidgets('while rewriting, the adapt row stays and says so', (
    tester,
  ) async {
    await _pump(
      tester,
      state: readyTutorial(
        lang: Lang.en,
        images: {1: quotaFailed},
        adapting: true,
      ),
    );
    expect(find.text('Adapting to your tools'), findsOneWidget);
    expect(find.text('Change skill or tools'), findsNothing);
  });

  testWidgets('an idea that is gone leads back to the ideas', (tester) async {
    await _pump(
      tester,
      state: const TutorialState(
        phase: TutorialPhase.failed,
        error: ApiException(
          code: ApiErrorCode.notFound,
          message: 'gone',
          retryable: false,
        ),
      ),
    );
    await tester.tap(find.text('Back to the ideas'));
    await tester.pumpAndSettle();
    expect(find.text('results $scanId'), findsOneWidget);
  });
}
