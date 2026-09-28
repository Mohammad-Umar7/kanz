/// Route paths (PLAN.md section 6). Screens navigate with these helpers
/// instead of string literals: `context.push(AppRoutes.results(scanId))`.
abstract final class AppRoutes {
  static const onboarding = '/onboarding';

  // Shell tabs.
  static const home = '/';
  static const dropoff = '/dropoff';
  static const swaps = '/swaps';
  static const impact = '/impact';

  static const history = '/history';
  static const settings = '/settings';
  static const locationRationale = '/permissions/location';
  static const cameraRationale = '/permissions/camera';

  /// City picker; pops with the chosen city id (`CityId.id`) or null.
  static const cityPicker = '/city';

  /// Component gallery, debug builds only.
  static const gallery = '/gallery';

  static String scan(ScanMode mode) => '/scan?mode=${mode.name}';

  static String results(String scanId) => '/results/$scanId';

  static String idea(String scanId, String ideaId) =>
      '/results/$scanId/idea/$ideaId';

  static String tutorial(String scanId, String ideaId) =>
      '/results/$scanId/idea/$ideaId/tutorial';

  static String completion(String projectId) => '/projects/$projectId/done';

  /// Routes reachable before onboarding is finished (onboarding may ask for
  /// location or a city).
  static bool allowedBeforeOnboarding(String location) =>
      location == onboarding ||
      location.startsWith('/permissions/') ||
      location == cityPicker ||
      location == gallery;
}

/// How the scan screen starts: viewfinder, gallery picker or text description.
enum ScanMode {
  camera,
  gallery,
  text;

  static ScanMode parse(String? value) =>
      values.where((m) => m.name == value).firstOrNull ?? camera;
}
