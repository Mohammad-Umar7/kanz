// Onboarding: welcome, language, skill and tools (with and without tools
// chosen), across the screenshot matrix and at 130 % text.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/features/onboarding/onboarding_screen.dart';

import '../../screenshots/harness.dart';
import '../shell/foundation_support.dart';

void main() {
  setUpAll(loadKanzFonts);

  const someTools = <String, Object>{
    'settings.skill': 'intermediate',
    'settings.tools': [
      'scissors',
      'craft_knife',
      'twine',
      'pliers',
      'paintbrush',
      'acrylic_paint',
      'sewing_kit',
    ],
  };

  Future<void> shot(
    WidgetTester tester,
    ShotConfig config,
    String name,
    int step, {
    Map<String, Object> prefs = const {},
  }) async {
    final overrides = await foundationOverrides(tester, prefs: prefs);
    await takeShot(
      tester,
      name: 'onboarding_$name',
      config: config,
      wrap: scoped(overrides),
      localizationsDelegates: l10nDelegates,
      child: OnboardingScreen(initialStep: step),
    );
  }

  for (final config in shotConfigs(largeText: true)) {
    testWidgets('onboarding welcome ${config.id}', (tester) async {
      await shot(tester, config, '1_welcome', 0);
    });
    testWidgets('onboarding tools ${config.id}', (tester) async {
      await shot(tester, config, '4_tools', 3, prefs: someTools);
    });
  }

  for (final config in shotConfigs()) {
    testWidgets('onboarding language ${config.id}', (tester) async {
      await shot(tester, config, '2_language', 1);
    });
    testWidgets('onboarding skill ${config.id}', (tester) async {
      await shot(tester, config, '3_skill', 2, prefs: someTools);
    });
  }

  for (final config in [
    const ShotConfig(),
    const ShotConfig(locale: Locale('ar'), brightness: Brightness.dark),
  ]) {
    testWidgets('onboarding tools, none chosen ${config.id}', (tester) async {
      await shot(tester, config, '4_tools_empty', 3);
    });
    testWidgets('onboarding skill at 130 % ${config.id}', (tester) async {
      await shot(
        tester,
        ShotConfig(
          brightness: config.brightness,
          locale: config.locale,
          textScale: 1.3,
        ),
        '3_skill',
        2,
        prefs: someTools,
      );
    });
  }
}
