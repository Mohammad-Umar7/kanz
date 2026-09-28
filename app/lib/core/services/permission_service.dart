import 'package:permission_handler/permission_handler.dart';

/// The runtime permissions Kanz asks for, each behind a rationale screen.
enum AppPermission { camera, location, microphone }

/// Simplified permission state for the UI.
enum PermissionState {
  granted,

  /// Not granted yet; asking again shows the system dialog.
  denied,

  /// The system will not show the dialog again; only Settings can grant it.
  permanentlyDenied,

  /// Blocked by policy (parental controls); the user cannot grant it.
  restricted,
}

/// Status, request and "open Settings" for camera, location and microphone.
class PermissionService {
  Permission _of(AppPermission p) => switch (p) {
    AppPermission.camera => Permission.camera,
    AppPermission.location => Permission.locationWhenInUse,
    AppPermission.microphone => Permission.microphone,
  };

  Future<PermissionState> status(AppPermission permission) async =>
      _map(await _of(permission).status);

  /// Shows the system dialog when allowed. On Android a second denial turns
  /// into [PermissionState.permanentlyDenied]; the screen then offers Settings.
  Future<PermissionState> request(AppPermission permission) async =>
      _map(await _of(permission).request());

  /// Opens this app's page in the system Settings.
  Future<bool> openSettings() => openAppSettings();

  static PermissionState _map(PermissionStatus status) => switch (status) {
    PermissionStatus.granted ||
    PermissionStatus.limited => PermissionState.granted,
    PermissionStatus.permanentlyDenied => PermissionState.permanentlyDenied,
    PermissionStatus.restricted => PermissionState.restricted,
    PermissionStatus.denied ||
    PermissionStatus.provisional => PermissionState.denied,
  };
}
