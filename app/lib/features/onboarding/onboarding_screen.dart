import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/settings_providers.dart';
import '../../l10n/l10n.dart';

/// Onboarding (`/onboarding`): language, skill and tools, skippable. The
/// router keeps the user here until `completeOnboarding()` is called.
///
/// Route scaffolding from App Core; the screen itself is built in Phase 2.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: Center(
      child: FilledButton(
        onPressed: () =>
            ref.read(settingsProvider.notifier).completeOnboarding(),
        child: Text(context.l10n.commonContinue),
      ),
    ),
  );
}
