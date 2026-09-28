// Shared helpers for the Drop-off, Swaps and Impact screen tests: the real
// vocabulary, a shell-like frame with the navigation bar, and a second
// capture after an interaction (to review sheets opened from the screen).
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/vocab/vocab.dart';
import 'package:kanz/core/design/design.dart';

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

/// Secondary states: both sizes and languages, light and dark.
final List<ShotConfig> stateConfigs = ShotConfig.matrix();

/// Quick states: small phone, both languages and themes.
final List<ShotConfig> compactConfigs = ShotConfig.matrix(
  sizes: const [ShotConfig.compact],
);
