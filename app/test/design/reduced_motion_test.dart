// With the platform's "remove animations" setting on
// (MediaQuery.disableAnimations), Kanz shows final states at once: no
// pulsing skeletons, no fade-ups, no scan line or box draw-in, and a static
// dot for the active pipeline stage instead of a spinner.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/design/design.dart';

Widget _app(Widget child, {required bool reduced}) {
  return MaterialApp(
    theme: KanzTheme.light(),
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
      child: app!,
    ),
    home: Scaffold(
      body: Center(child: SizedBox(width: 300, child: child)),
    ),
  );
}

int _tickers() => SchedulerBinding.instance.transientCallbackCount;

void main() {
  testWidgets('skeletons pulse only when motion is allowed', (tester) async {
    await tester.pumpWidget(_app(const Skeleton(), reduced: false));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_tickers(), greaterThan(0));

    await tester.pumpWidget(_app(const Skeleton(), reduced: true));
    await tester.pump();
    expect(_tickers(), 0);
  });

  testWidgets('fade-up shows its child at once', (tester) async {
    await tester.pumpWidget(
      _app(
        FadeUp.staggered(index: 3, child: const Text('Idea')),
        reduced: true,
      ),
    );
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('Idea'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 1);
    expect(_tickers(), 0);
  });

  testWidgets('bounding boxes appear without the scan line', (tester) async {
    final photo = MemoryImage(
      File('test/screenshots/fixtures/glass_jar.jpg').readAsBytesSync(),
    );
    await tester.pumpWidget(
      _app(
        SizedBox.square(
          dimension: 300,
          child: BoundingBoxOverlay(
            image: photo,
            imageSize: const Size(1000, 1000),
            semanticsLabel: 'Your photo',
            boxes: const [
              DetectionBox(
                id: 'jar',
                rect: Rect.fromLTRB(0.3, 0.2, 0.7, 0.9),
                categoryId: 'glass',
                label: 'Jar · 93%',
              ),
            ],
          ),
        ),
        reduced: true,
      ),
    );
    final tag = tester.widget<Opacity>(
      find.ancestor(of: find.text('JAR · 93%'), matching: find.byType(Opacity)),
    );
    expect(tag.opacity, closeTo(1, 1e-9));
  });

  testWidgets('the active pipeline stage is a still dot', (tester) async {
    const timeline = PipelineTimeline(
      summary: 'Done',
      expandLabel: 'Show steps',
      collapseLabel: 'Hide steps',
      stages: [
        PipelineStage(label: 'Finding ideas', status: PipelineStatus.active),
      ],
    );
    await tester.pumpWidget(_app(timeline, reduced: false));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(_app(timeline, reduced: true));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(_tickers(), 0);
  });
}
