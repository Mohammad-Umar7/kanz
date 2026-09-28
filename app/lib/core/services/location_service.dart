import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// A position and how much it can be trusted.
class LocationFix {
  const LocationFix({
    required this.lat,
    required this.lng,
    required this.accuracyM,
    required this.timestamp,
    required this.isWeak,
  });

  final double lat;
  final double lng;
  final double accuracyM;
  final DateTime timestamp;

  /// Coarse (network or indoor) or stale fix. Callers search by the nearest
  /// city instead, which gives better drop-off results than a wrong point.
  final bool isWeak;
}

/// Current position for the drop-off search.
///
/// Waits at most [timeout] for a fresh fix, then falls back to the last known
/// position. Never asks for permission itself: the rationale screen does that.
class LocationService {
  static const timeout = Duration(seconds: 8);

  /// Beyond this accuracy radius the fix is treated as weak.
  static const weakAccuracyM = 2000.0;

  /// A last-known position older than this is treated as weak.
  static const staleAfter = Duration(minutes: 30);

  /// Null when location services are off, permission is missing or no fix is
  /// available at all.
  Future<LocationFix?> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return null;
      }
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: timeout,
          ),
        );
        return _toFix(position);
      } on TimeoutException {
        return _lastKnown();
      } on LocationServiceDisabledException {
        // Location is on, but the phone asked to also turn on Google Location
        // Accuracy and the user said no: the last known position still gives
        // a search nearby (or the nearest city) instead of asking again.
        return _lastKnown();
      }
    } on Exception {
      // Services toggled mid-request, platform errors: the caller uses a city.
      return null;
    }
  }

  static Future<LocationFix?> _lastKnown() async {
    final last = await Geolocator.getLastKnownPosition();
    return last == null ? null : _toFix(last);
  }

  static LocationFix _toFix(Position p) {
    final age = DateTime.now().difference(p.timestamp);
    return LocationFix(
      lat: p.latitude,
      lng: p.longitude,
      accuracyM: p.accuracy,
      timestamp: p.timestamp,
      isWeak: p.accuracy > weakAccuracyM || age > staleAfter,
    );
  }
}
