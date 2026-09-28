// Shared helpers for the Drop-off, Swaps and Impact screen tests: the real
// vocabulary, a shell-like frame with the navigation bar, and a second
// capture after an interaction (to review sheets opened from the screen).
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kanz/core/data/vocab/vocab.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/l10n/l10n.dart';

import '../../screenshots/harness.dart';

Vocab? _vocab;

/// The app's vocabulary (labels, cities, materials), read once.
Vocab testVocab() => _vocab ??= Vocab.fromJson(
  jsonDecode(File('assets/config/vocab.json').readAsStringSync())
      as Map<String, dynamic>,
);

/// Reads a JSON file relative to `app/`.
Map<String, dynamic> readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

/// A stand-in for the app shell (built by another team): the screen above
/// the Kanz navigation bar, so screenshots show the real bottom edge.
Widget inShell(Widget screen, {required int tab, required bool arabic}) {
  final labels = arabic
      ? const ['الرئيسية', 'التسليم', 'البدائل', 'الأثر']
      : const ['Home', 'Drop-off', 'Swaps', 'Impact'];
  const icons = [
    KanzIcons.home,
    KanzIcons.dropOff,
    KanzIcons.swaps,
    KanzIcons.impact,
  ];
  return Scaffold(
    body: screen,
    bottomNavigationBar: KanzNavBar(
      destinations: [
        for (var i = 0; i < 4; i++)
          KanzNavDestination(icon: icons[i], label: labels[i]),
      ],
      selectedIndex: tab,
      onSelected: (_) {},
      scanLabel: arabic ? 'صوّر غرضًا' : 'Scan an item',
      onScan: () {},
    ),
  );
}

/// Key of a boundary placed around the whole app (pass [withCaptureBoundary]
/// as the outermost `wrap`), so a sheet opened after [takeShot] can be
/// captured with [captureAgain].
final GlobalKey captureBoundaryKey = GlobalKey(debugLabel: 'tabs-capture');

Widget withCaptureBoundary(Widget app) =>
    RepaintBoundary(key: captureBoundaryKey, child: app);

/// Pumps [frames] 100 ms frames and writes `_out/<name>_<config.id>.png`.
Future<void> captureAgain(
  WidgetTester tester, {
  required String name,
  required ShotConfig config,
  int frames = 8,
}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(captureBoundaryKey),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  final out = File('test/screenshots/_out/${name}_${config.id}.png');
  out.parent.createSync(recursive: true);
  out.writeAsBytesSync(bytes!);
}

/// The main content state also renders at 130 % text in both languages.
final List<ShotConfig> contentConfigs = [
  ...ShotConfig.matrix(),
  const ShotConfig(textScale: 1.3),
  const ShotConfig(locale: Locale('ar'), textScale: 1.3),
];

/// 130 % text on the small phone in both languages: every state must lay
/// out without overflow at this size too.
const List<ShotConfig> largeTextConfigs = [
  ShotConfig(textScale: 1.3),
  ShotConfig(locale: Locale('ar'), textScale: 1.3),
];

/// Secondary states: both sizes and languages, light and dark, plus 130 %.
final List<ShotConfig> stateConfigs = [
  ...ShotConfig.matrix(),
  ...largeTextConfigs,
];

/// Quick states: small phone, both languages and themes, plus 130 %.
final List<ShotConfig> compactConfigs = [
  ...ShotConfig.matrix(sizes: const [ShotConfig.compact]),
  ...largeTextConfigs,
];

/// Pumps [child] (or [router]) on a 412 x 915 phone under a provider scope,
/// with the Kanz theme and the app's localizations, for interaction tests.
Future<void> pumpTab(
  WidgetTester tester, {
  Widget? child,
  GoRouter? router,
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
}) async {
  tester.view
    ..devicePixelRatio = 2
    ..physicalSize = const Size(412, 915) * 2;
  addTearDown(tester.view.reset);
  const delegates = [
    ...AppLocalizations.localizationsDelegates,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  final theme = KanzTheme.light(locale: locale);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: router == null
          ? MaterialApp(
              theme: theme,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: delegates,
              home: child,
            )
          : MaterialApp.router(
              theme: theme,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: delegates,
              routerConfig: router,
            ),
    ),
  );
  await settle(tester);
}

/// Pumps frames for [ms] milliseconds (skeletons and spinners never settle).
Future<void> settle(WidgetTester tester, {int ms = 800}) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
