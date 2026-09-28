import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/app/router.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/state/settings_providers.dart';
import 'package:kanz/features/onboarding/onboarding_screen.dart';

import '../shell/foundation_support.dart';

void main() {
  Future<(ProviderContainer, List<String>)> pumpOnboarding(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
  }) async {
    final log = <String>[];
    final overrides = await foundationOverrides(tester, prefs: prefs);
    final container = await pumpRouted(
      tester,
      screenRouter(
        path: AppRoutes.onboarding,
        builder: (_) => const OnboardingScreen(),
        log: log,
      ),
      overrides,
    );
    return (container, log);
  }

  AppSettings settingsOf(ProviderContainer c) => c.read(settingsProvider);

  testWidgets('each step saves its choice and the last one finishes', (
    tester,
  ) async {
    final (container, _) = await pumpOnboarding(tester);
    expect(find.text('Find the treasure in what you throw away.'), findsOne);

    await tester.tap(find.text('Get started'));
    await settle(tester);
    expect(find.text('Choose your language'), findsOneWidget);

    await tester.tap(find.text('العربية'));
    await settle(tester);
    expect(settingsOf(container).locale, LocalePref.ar);

    await tester.tap(find.text('Continue'));
    await settle(tester);
    await tester.tap(find.text('Advanced'));
    await settle(tester);
    expect(settingsOf(container).skill, SkillLevel.advanced);

    await tester.tap(find.text('Continue'));
    await settle(tester);
    expect(find.text('No tools selected'), findsOneWidget);
    await tester.tap(find.text('Scissors'));
    await tester.ensureVisible(find.text('Pliers'));
    await tester.tap(find.text('Pliers'));
    await settle(tester);
    expect(settingsOf(container).tools, [ToolId.scissors, ToolId.pliers]);
    await tester.ensureVisible(find.text('2 tools selected'));
    expect(find.text('2 tools selected'), findsOneWidget);

    await tester.tap(find.text('Start using Kanz'));
    await settle(tester);
    expect(settingsOf(container).onboardingDone, isTrue);
  });

  testWidgets('skip keeps the defaults and finishes', (tester) async {
    final (container, _) = await pumpOnboarding(tester);

    await tester.tap(find.text('Skip'));
    await settle(tester);

    final settings = settingsOf(container);
    expect(settings.onboardingDone, isTrue);
    expect(settings.skill, SkillLevel.beginner);
    expect(settings.tools, isEmpty);
    expect(settings.locale, LocalePref.system);
  });

  testWidgets('back returns to the previous step, also from the system', (
    tester,
  ) async {
    await pumpOnboarding(tester);
    await tester.tap(find.text('Get started'));
    await settle(tester);
    await tester.tap(find.text('Continue'));
    await settle(tester);
    expect(find.text('How much have you made before?'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await settle(tester);
    expect(find.text('Choose your language'), findsOneWidget);

    // The Android back gesture steps back too instead of leaving.
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.text('Find the treasure in what you throw away.'), findsOne);
  });

  testWidgets('the tools step lists real tools only, never safety gear', (
    tester,
  ) async {
    await pumpOnboarding(tester);
    for (final label in ['Get started', 'Continue', 'Continue']) {
      await tester.tap(find.text(label));
      await settle(tester);
    }
    expect(find.text('Work gloves'), findsNothing);
    expect(find.text('Safety glasses'), findsNothing);
    await tester.ensureVisible(find.text('Sewing machine'));
    expect(find.text('Sewing machine'), findsOneWidget);
  });
}
