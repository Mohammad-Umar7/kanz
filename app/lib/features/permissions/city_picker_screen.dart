import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/core_providers.dart';

/// City picker (`/city`): pops with the chosen city's id (`CityId.id`).
///
/// Route scaffolding from App Core; the screen itself is built in Phase 2.
class CityPickerScreen extends ConsumerWidget {
  const CityPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context);
    final cities = ref.watch(vocabProvider).cities;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          for (final city in cities)
            ListTile(
              title: Text(city.label.forLocale(locale)),
              onTap: () => context.pop(city.id.id),
            ),
        ],
      ),
    );
  }
}
