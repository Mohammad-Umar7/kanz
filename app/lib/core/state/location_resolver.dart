import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import '../data/repositories/settings_repository.dart';
import '../data/vocab/vocab.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import 'core_providers.dart';

/// How a drop-off search location was chosen (for the "Near you" / city label).
enum SearchLocationSource {
  /// A good GPS fix.
  gps,

  /// The city the user picked.
  city,

  /// The fix was weak (indoors, coarse network location), so the nearest
  /// emirate centre is used instead of a misleading point.
  nearestCity,
}

/// Where to search for drop-off points: coordinates or a city, never both.
class SearchLocation {
  const SearchLocation.gps({required double this.lat, required double this.lng})
    : city = null,
      source = SearchLocationSource.gps;

  const SearchLocation.city(
    CityId this.city, {
    this.source = SearchLocationSource.city,
  }) : lat = null,
       lng = null;

  final double? lat;
  final double? lng;
  final CityId? city;
  final SearchLocationSource source;

  FacilitiesRequest toRequest(List<String> categories, Lang lang) =>
      FacilitiesRequest(
        categories: categories,
        lat: lat,
        lng: lng,
        city: city,
        lang: lang,
      );

  @override
  bool operator ==(Object other) =>
      other is SearchLocation &&
      other.lat == lat &&
      other.lng == lng &&
      other.city == city &&
      other.source == source;

  @override
  int get hashCode => Object.hash(lat, lng, city, source);
}

/// Decides where to search, following the user's location choice:
///
/// * city mode: the chosen city;
/// * GPS permission granted: the current position, or the chosen city (else
///   the nearest city) when the fix is weak or missing;
/// * otherwise: the chosen city if any, else null, which means the screen must
///   ask (location rationale or city picker) and then resume the search.
class LocationResolver {
  LocationResolver({
    required PermissionService permissions,
    required LocationService location,
    required Vocab vocab,
  }) : _permissions = permissions,
       _location = location,
       _vocab = vocab;

  final PermissionService _permissions;
  final LocationService _location;
  final Vocab _vocab;

  Future<SearchLocation?> resolve(AppSettings settings) async {
    final chosenCity = settings.city;
    if (settings.locationMode == LocationMode.city) {
      return chosenCity == null ? null : SearchLocation.city(chosenCity);
    }

    final permission = await _permissions.status(AppPermission.location);
    if (permission != PermissionState.granted) {
      // Undecided users see the rationale first; users who chose GPS but later
      // revoked it fall back to their city when they have one.
      if (settings.locationMode == LocationMode.gps && chosenCity != null) {
        return SearchLocation.city(chosenCity);
      }
      return null;
    }

    final fix = await _location.current();
    if (fix != null && !fix.isWeak) {
      return SearchLocation.gps(lat: fix.lat, lng: fix.lng);
    }
    if (chosenCity != null) return SearchLocation.city(chosenCity);
    if (fix != null) {
      return SearchLocation.city(
        _vocab.nearestCity(fix.lat, fix.lng).id,
        source: SearchLocationSource.nearestCity,
      );
    }
    return null;
  }
}

final locationResolverProvider = Provider<LocationResolver>(
  (ref) => LocationResolver(
    permissions: ref.watch(permissionServiceProvider),
    location: ref.watch(locationServiceProvider),
    vocab: ref.watch(vocabProvider),
  ),
);
