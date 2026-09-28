import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import '../data/repositories/settings_repository.dart';
import 'core_providers.dart';

export '../data/repositories/settings_repository.dart'
    show AppSettings, LocalePref, LocationMode;

/// User settings, persisted on every change. Watch it (or a `select`) for
/// theme, language, skill, tools, location mode, city and backend URL.
final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(settingsRepositoryProvider).load();

  Future<void> _set(AppSettings next) async {
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }

  Future<void> setLocale(LocalePref locale) =>
      _set(state.copyWith(locale: locale));

  Future<void> setThemeMode(ThemeMode mode) =>
      _set(state.copyWith(themeMode: mode));

  Future<void> setSkill(SkillLevel skill) => _set(state.copyWith(skill: skill));

  /// Protective gear is never stored as a tool (it is always recommended).
  Future<void> setTools(Iterable<ToolId> tools) => _set(
    state.copyWith(
      tools: tools.where((t) => !t.isSafetyGear).toSet().toList()
        ..sort((a, b) => a.index.compareTo(b.index)),
    ),
  );

  Future<void> toggleTool(ToolId tool) {
    final tools = {...state.tools};
    if (!tools.remove(tool)) tools.add(tool);
    return setTools(tools);
  }

  Future<void> completeOnboarding() =>
      _set(state.copyWith(onboardingDone: true));

  /// GPS: search around the phone's position. City: always use [city].
  Future<void> setLocationMode(LocationMode? mode) =>
      _set(state.copyWith(locationMode: mode));

  Future<void> setCity(CityId? city) => _set(state.copyWith(city: city));

  /// Picking a city from the city picker also switches to city mode.
  Future<void> useCity(CityId city) =>
      _set(state.copyWith(city: city, locationMode: LocationMode.city));

  /// Null or blank restores the build default (`KANZ_API_BASE`).
  Future<void> setApiBaseUrl(String? url) => _set(
    state.copyWith(
      apiBaseUrl: (url == null || url.trim().isEmpty) ? null : url.trim(),
    ),
  );

  Future<void> setHandsFree({required bool enabled}) =>
      _set(state.copyWith(handsFree: enabled));
}

/// Locale for MaterialApp: null follows the system.
final appLocaleProvider = Provider<Locale?>((ref) {
  return switch (ref.watch(settingsProvider.select((s) => s.locale))) {
    LocalePref.system => null,
    LocalePref.en => const Locale('en'),
    LocalePref.ar => const Locale('ar'),
  };
});

/// The phone's preferred languages, most preferred first. `KanzApp` passes
/// changes in from `didChangeLocales`, so a language switch in the phone's
/// settings reaches the providers below while the app is running.
final systemLocalesProvider = NotifierProvider<SystemLocales, List<Locale>>(
  SystemLocales.new,
);

class SystemLocales extends Notifier<List<Locale>> {
  @override
  List<Locale> build() => PlatformDispatcher.instance.locales;

  void update(List<Locale> locales) => state = locales;
}

/// Language for AI content (`lang` in every request). With the system setting
/// it resolves the phone's languages the way MaterialApp picks the UI locale:
/// the first one that is Arabic or English wins, otherwise English. So the UI
/// and the AI answers are always in the same language.
final contentLangProvider = Provider<Lang>((ref) {
  final locale = ref.watch(appLocaleProvider);
  if (locale != null) return locale.languageCode == 'ar' ? Lang.ar : Lang.en;
  for (final preferred in ref.watch(systemLocalesProvider)) {
    if (preferred.languageCode == 'ar') return Lang.ar;
    if (preferred.languageCode == 'en') return Lang.en;
  }
  return Lang.en;
});

/// The profile sent with recommend and tutorial requests.
final profileProvider = Provider<Profile>((ref) {
  final skill = ref.watch(settingsProvider.select((s) => s.skill));
  final tools = ref.watch(settingsProvider.select((s) => s.tools));
  return Profile(
    skill: skill,
    tools: tools,
    lang: ref.watch(contentLangProvider),
  );
});
