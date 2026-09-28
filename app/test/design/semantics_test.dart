// What a screen reader gets from the interactive components: every control
// is one node with a readable name and an action the reader can invoke.
// Several components replace their children's semantics with one clean
// label (excludeSemantics), which also drops the InkWell's tap action, so
// these tests activate each control through the semantics tree the way
// TalkBack and VoiceOver do.
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/design/design.dart';

Widget _app(Widget child) => MaterialApp(
  theme: KanzTheme.light(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 360, child: child)),
  ),
);

/// Taps the semantics node labelled [label], as TalkBack or VoiceOver
/// would. Throws if the node offers no tap action.
Future<void> _tap(WidgetTester tester, String label) async {
  tester.semantics.tap(find.semantics.byLabel(label));
  await tester.pump();
}

void main() {
  late SemanticsHandle handle;
  setUp(() => handle = SemanticsBinding.instance.ensureSemantics());
  tearDown(() => handle.dispose());

  testWidgets('the scan action and the shutter can be activated', (
    tester,
  ) async {
    var scans = 0;
    var shots = 0;
    await tester.pumpWidget(
      _app(
        Row(
          children: [
            ScanActionButton(semanticsLabel: 'Scan', onPressed: () => scans++),
            ShutterButton(
              semanticsLabel: 'Take photo',
              onPressed: () => shots++,
              haptics: false,
            ),
          ],
        ),
      ),
    );
    await _tap(tester, 'Scan');
    await _tap(tester, 'Take photo');
    expect((scans, shots), (1, 1));
  });

  testWidgets('a busy shutter offers no action', (tester) async {
    await tester.pumpWidget(
      _app(
        ShutterButton(
          semanticsLabel: 'Take photo',
          onPressed: () {},
          busy: true,
          haptics: false,
        ),
      ),
    );
    final data = tester
        .getSemantics(find.bySemanticsLabel('Take photo'))
        .getSemanticsData();
    expect(data.hasAction(SemanticsAction.tap), isFalse);
    expect(data.flagsCollection.isEnabled, Tristate.isFalse);
  });

  testWidgets('chips toggle and report selection with their count', (
    tester,
  ) async {
    bool? toggledTo;
    await tester.pumpWidget(
      _app(
        KanzChip(
          label: 'Glass',
          count: '2',
          selected: true,
          onSelected: (v) => toggledTo = v,
        ),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Glass, 2')),
      matchesSemantics(
        label: 'Glass, 2',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        isEnabled: true,
        hasEnabledState: true,
        hasTapAction: true,
      ),
    );
    await _tap(tester, 'Glass, 2');
    expect(toggledTo, isFalse);
  });

  testWidgets('segmented tabs and nav items switch by semantics', (
    tester,
  ) async {
    int? tab;
    int? destination;
    var scans = 0;
    await tester.pumpWidget(
      _app(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedTabs(
              selectedIndex: 0,
              onChanged: (i) => tab = i,
              tabs: const [
                SegmentedTab(label: 'Upcycle'),
                SegmentedTab(label: 'Recycle'),
                SegmentedTab(label: 'Donate'),
              ],
            ),
            KanzNavBar(
              selectedIndex: 0,
              onSelected: (i) => destination = i,
              scanLabel: 'Scan an item',
              onScan: () => scans++,
              destinations: const [
                KanzNavDestination(icon: KanzIcons.home, label: 'Home'),
                KanzNavDestination(icon: KanzIcons.dropOff, label: 'Drop-off'),
                KanzNavDestination(icon: KanzIcons.swaps, label: 'Swaps'),
                KanzNavDestination(icon: KanzIcons.impact, label: 'Impact'),
              ],
            ),
          ],
        ),
      ),
    );
    await _tap(tester, 'Donate');
    await _tap(tester, 'Swaps');
    await _tap(tester, 'Scan an item');
    expect((tab, destination, scans), (2, 2, 1));
  });

  testWidgets('icon buttons carry their name once and are toggles only '
      'when given a state', (tester) async {
    await tester.pumpWidget(
      _app(
        Row(
          children: [
            KanzIconButton(
              icon: KanzIcons.share,
              semanticsLabel: 'Share',
              onPressed: () {},
            ),
            KanzIconButton(
              icon: KanzIcons.speaker,
              semanticsLabel: 'Read aloud',
              selected: true,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
    final share = tester
        .getSemantics(find.bySemanticsLabel('Share'))
        .getSemanticsData();
    expect(share.label, 'Share');
    expect(share.tooltip, isEmpty);
    expect(share.flagsCollection.isSelected, Tristate.none);

    final speaker = tester
        .getSemantics(find.bySemanticsLabel('Read aloud'))
        .getSemanticsData();
    expect(speaker.flagsCollection.isSelected, Tristate.isTrue);
  });

  testWidgets('a loading button is one disabled node named by its '
      'loading label', (tester) async {
    await tester.pumpWidget(
      _app(
        KanzButton(
          label: 'Save',
          loading: true,
          loadingLabel: 'Saving',
          onPressed: () {},
        ),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Saving')),
      matchesSemantics(
        label: 'Saving',
        isButton: true,
        hasEnabledState: true,
        isLiveRegion: true,
      ),
    );
    expect(find.bySemanticsLabel('Save'), findsNothing);
  });

  testWidgets('the collapsed pipeline expands from its summary', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const PipelineTimeline(
          summary: 'Done in 6.1 s',
          expandLabel: 'Show steps',
          collapseLabel: 'Hide steps',
          stages: [
            PipelineStage(
              label: 'Identifying materials',
              status: PipelineStatus.done,
            ),
          ],
        ),
      ),
    );
    expect(find.text('Identifying materials'), findsNothing);
    await _tap(tester, 'Done in 6.1 s');
    await tester.pumpAndSettle();
    expect(find.text('Identifying materials'), findsOneWidget);
  });

  testWidgets('a place row reads as one node that opens the place', (
    tester,
  ) async {
    var opened = 0;
    var directions = 0;
    await tester.pumpWidget(
      _app(
        PlaceRow(
          name: 'Municipal recycling centre',
          distance: '950 m',
          openState: OpenState.open,
          openLabel: 'Open now',
          materialIds: const ['glass', 'metal'],
          materialsLabel: 'Accepts glass and metal',
          directionsLabel: 'Directions',
          onTap: () => opened++,
          onDirections: () => directions++,
        ),
      ),
    );
    final label = tester
        .getSemantics(find.bySemanticsLabel(RegExp('Municipal')))
        .label;
    // Distance keeps its case for speech: "950 m", not "950 M".
    expect(
      label,
      'Municipal recycling centre\n950 m\nOpen now\nAccepts glass and metal',
    );
    await _tap(tester, label);
    await _tap(tester, 'Directions');
    expect((opened, directions), (1, 1));
  });

  testWidgets('mono labels show uppercase but read the original text', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const MonoLabel('3 pcs')));
    expect(find.text('3 PCS'), findsOneWidget);
    expect(find.bySemanticsLabel('3 pcs'), findsOneWidget);
  });
}
