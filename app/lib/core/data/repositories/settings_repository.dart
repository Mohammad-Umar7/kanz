import 'package:flutter/material.dart' show ThemeMode;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vocab_enums.dart';

part 'settings_repository.freezed.dart';

/// App language choice. [system] follows the phone (Arabic if the phone is
/// Arabic, English otherwise).
enum LocalePref { system, en, ar }

/// How the drop-off search finds the user. Null in [AppSettings.locationMode]
/// means the user has not decided yet, so the screen shows the rationale.
enum LocationMode { gps, city }

/// Everything the user sets in onboarding and Settings.
@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(LocalePref.system) LocalePref locale,
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(SkillLevel.beginner) SkillLevel skill,
    @Default(<ToolId>[]) List<ToolId> tools,
    @Default(false) bool onboardingDone,
    LocationMode? locationMode,
    CityId? city,

    /// Runtime backend URL override from Settings; null uses the build default.
    String? apiBaseUrl,

    /// Start tutorials in hands-free mode.
    @Default(false) bool handsFree,
  }) = _AppSettings;
}

/// Reads and writes [AppSettings] in shared preferences, one key per field.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _locale = 'settings.locale';
  static const _theme = 'settings.theme_mode';
  static const _skill = 'settings.skill';
  static const _tools = 'settings.tools';
  static const _onboarding = 'settings.onboarding_done';
  static const _locationMode = 'settings.location_mode';
  static const _city = 'settings.city';
  static const _apiBase = 'settings.api_base_url';
  static const _handsFree = 'settings.hands_free';

  AppSettings load() => AppSettings(
    locale:
        _enum(LocalePref.values, _prefs.getString(_locale)) ??
        LocalePref.system,
    themeMode:
        _enum(ThemeMode.values, _prefs.getString(_theme)) ?? ThemeMode.system,
    skill:
        SkillLevel.tryFromId(_prefs.getString(_skill)) ?? SkillLevel.beginner,
    tools: [
      for (final id in _prefs.getStringList(_tools) ?? const <String>[])
        ?ToolId.tryFromId(id),
    ],
    onboardingDone: _prefs.getBool(_onboarding) ?? false,
    locationMode: _enum(LocationMode.values, _prefs.getString(_locationMode)),
    city: CityId.tryFromId(_prefs.getString(_city)),
    apiBaseUrl: _prefs.getString(_apiBase),
    handsFree: _prefs.getBool(_handsFree) ?? false,
  );

  Future<void> save(AppSettings s) async {
    await Future.wait([
      _prefs.setString(_locale, s.locale.name),
      _prefs.setString(_theme, s.themeMode.name),
      _prefs.setString(_skill, s.skill.id),
      _prefs.setStringList(_tools, [for (final t in s.tools) t.id]),
      _prefs.setBool(_onboarding, s.onboardingDone),
      _setOrRemove(_locationMode, s.locationMode?.name),
      _setOrRemove(_city, s.city?.id),
      _setOrRemove(_apiBase, s.apiBaseUrl),
      _prefs.setBool(_handsFree, s.handsFree),
    ]);
  }

  Future<bool> _setOrRemove(String key, String? value) =>
      value == null ? _prefs.remove(key) : _prefs.setString(key, value);

  static T? _enum<T extends Enum>(List<T> values, String? name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }
}
