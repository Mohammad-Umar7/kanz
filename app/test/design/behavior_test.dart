// Behavior of the interactive and data components: the before/after
// slider's semantics, keyboard and RTL handling, quality segments, bounding
// box mapping, step progress and icon mirroring.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/design/design.dart';

Widget _app(Widget child, {TextDirection direction = TextDirection.ltr}) {
  return MaterialApp(
    theme: KanzTheme.light(),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: Center(child: SizedBox(width: 300, child: child)),
      ),
    ),
  );
}

final _photo = MemoryImage(
  File('test/screenshots/fixtures/glass_jar.jpg').readAsBytesSync(),
);

BeforeAfterSlider _slider({ValueChanged<double>? onChanged}) {
  return BeforeAfterSlider(
    before: _photo,
    after: _photo,
    beforeLabel: 'Before',
    afterLabel: 'After',
    semanticsLabel: 'Compare before and after',
    initialValue: 0.5,
    onChanged: onChanged,
  );
}

void main() {
  group('BeforeAfterSlider', () {
    testWidgets('is a semantic slider with increase and decrease', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(_slider()));

      final node = find.bySemanticsLabel('Compare before and after');
      expect(
        tester.getSemantics(node),
        matchesSemantics(
          label: 'Compare before and after',
          value: '50%',
          increasedValue: '60%',
          decreasedValue: '40%',
          isSlider: true,
          hasIncreaseAction: true,
          hasDecreaseAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );

      // What a screen reader's "increase" gesture invokes.
      final slider = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && (w.properties.slider ?? false),
        ),
      );
      slider.properties.onIncrease!();
      await tester.pump();
      expect(tester.getSemantics(node).value, '60%');
      handle.dispose();
    });

    testWidgets('dragging toward the end reveals less of the before image '
        'in LTR and more in RTL', (tester) async {
      var ltrValue = 0.5;
      await tester.pumpWidget(_app(_slider(onChanged: (v) => ltrValue = v)));
      await tester.drag(find.byType(BeforeAfterSlider), const Offset(60, 0));
      expect(ltrValue, greaterThan(0.5));

      var rtlValue = 0.5;
      await tester.pumpWidget(
        _app(
          _slider(onChanged: (v) => rtlValue = v),
          direction: TextDirection.rtl,
        ),
      );
      await tester.drag(find.byType(BeforeAfterSlider), const Offset(60, 0));
      expect(rtlValue, lessThan(0.5));
    });

    testWidgets('arrow keys move it by one step', (tester) async {
      var value = 0.5;
      await tester.pumpWidget(_app(_slider(onChanged: (v) => value = v)));
      // Tapping moves the handle and focuses the control.
      await tester.tap(find.byType(BeforeAfterSlider));
      await tester.pump();
      final afterTap = value;
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(value, closeTo(afterTap + BeforeAfterSlider.step, 1e-9));
    });
  });

  group('QualityBar', () {
    for (final score in [0, 1, 4, 5]) {
      testWidgets('fills $score of 5 segments', (tester) async {
        await tester.pumpWidget(
          _app(QualityBar(score: score, semanticsLabel: 'Quality $score of 5')),
        );
        const c = KanzColors.light;
        var filled = 0;
        for (var i = 0; i < QualityBar.segments; i++) {
          final box = tester.widget<Container>(
            find.byKey(ValueKey('quality-segment-$i')),
          );
          final color = (box.decoration! as BoxDecoration).color;
          if (color == c.ink) filled++;
          expect(color, i < score ? c.ink : c.track);
        }
        expect(filled, score);
        expect(find.bySemanticsLabel('Quality $score of 5'), findsOneWidget);
      });
    }
  });

  group('BoundingBoxOverlay.mapBox', () {
    const image = Size(1000, 500);

    test('contain letterboxes and keeps boxes on the image', () {
      final r = BoundingBoxOverlay.mapBox(
        const Rect.fromLTWH(0, 0, 1, 1),
        imageSize: image,
        viewport: const Size(400, 400),
        fit: BoxFit.contain,
      );
      expect(r, const Rect.fromLTWH(0, 100, 400, 200));
    });

    test('cover crops the sides and scales boxes with the crop', () {
      final r = BoundingBoxOverlay.mapBox(
        const Rect.fromLTWH(0.25, 0, 0.5, 1),
        imageSize: image,
        viewport: const Size(400, 400),
        fit: BoxFit.cover,
      );
      // Cover scales the 1000x500 image to 800x400 and centers it, so the
      // middle half of the image spans the whole 400 px viewport.
      expect(r.left, closeTo(0, 1e-9));
      expect(r.right, closeTo(400, 1e-9));
      expect(r.top, closeTo(0, 1e-9));
      expect(r.bottom, closeTo(400, 1e-9));
    });
  });

  group('StepProgressBar', () {
    testWidgets('marks done, current and upcoming steps', (tester) async {
      await tester.pumpWidget(
        _app(
          const StepProgressBar(
            total: 4,
            current: 1,
            semanticsLabel: 'Step 2 of 4',
          ),
        ),
      );
      await tester.pumpAndSettle();
      Color colorOf(int i) {
        final box = tester.widget<AnimatedContainer>(
          find.byKey(ValueKey('step-segment-$i')),
        );
        return (box.decoration! as BoxDecoration).color!;
      }

      const c = KanzColors.light;
      expect(colorOf(0), c.ink);
      expect(colorOf(1), c.accent);
      expect(colorOf(2), c.track);
      expect(find.bySemanticsLabel('Step 2 of 4'), findsOneWidget);
    });
  });

  group('KanzIcons', () {
    test('directional glyphs mirror in RTL, others do not', () {
      for (final icon in [
        KanzIcons.forward,
        KanzIcons.back,
        KanzIcons.chevronForward,
        KanzIcons.chevronBack,
        KanzIcons.undo,
        KanzIcons.send,
      ]) {
        expect(icon.matchTextDirection, isTrue);
      }
      for (final icon in [
        KanzIcons.camera,
        KanzIcons.scan,
        KanzIcons.leaf,
        KanzIcons.question,
        KanzIcons.chevronDown,
      ]) {
        expect(icon.matchTextDirection, isFalse);
      }
      expect(KanzIcons.camera.fontPackage, 'phosphor_flutter');
      expect(KanzIcons.material('textile'), KanzIcons.textile);
      expect(KanzIcons.material('nonsense'), KanzIcons.other);
    });
  });

  group('KanzButton', () {
    testWidgets('loading keeps the label and ignores taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          KanzButton(
            label: 'Save',
            loading: true,
            loadingLabel: 'Saving',
            onPressed: () => taps++,
          ),
        ),
      );
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Save'), warnIfMissed: false);
      expect(taps, 0);
    });
  });
}
