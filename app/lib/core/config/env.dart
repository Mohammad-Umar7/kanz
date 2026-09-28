/// Build-time configuration passed with `--dart-define`.
///
/// ```
/// flutter run --dart-define=KANZ_API_BASE=http://192.168.1.20:8000 --dart-define=KANZ_MAPS=1
/// ```
///
/// The backend URL can also be changed at runtime in Settings; that override is
/// stored in preferences and wins over [Env.apiBase].
abstract final class Env {
  /// Backend base URL. The default reaches the host machine from the Android emulator.
  static const String apiBase = String.fromEnvironment(
    'KANZ_API_BASE',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// True when the Android Maps SDK key is configured, so the map view can render.
  /// Without it the drop-off screens show the list view only.
  static const bool mapsEnabled =
      String.fromEnvironment('KANZ_MAPS', defaultValue: '0') == '1';
}
