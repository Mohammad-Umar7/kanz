/// Pure helpers that turn drop-off data into what the screen shows: labels,
/// open state, pin colors, compass directions and source attribution.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../core/data/models/models.dart';
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
import '../../core/network/api_exception.dart';
import '../../core/state/location_resolver.dart';
import '../../l10n/l10n.dart';

/// The search radius the drop-off search uses (`FacilitiesRequest.radiusM`).
const int dropoffRadiusKm = 15;

OpenState openStateOf(Place place) => switch (place.openNow) {
  true => OpenState.open,
  false => OpenState.closed,
  null => OpenState.unknown,
};

String openLabel(AppLocalizations l10n, OpenState state) => switch (state) {
  OpenState.open => l10n.dropoffOpenNow,
  OpenState.closed => l10n.dropoffClosed,
  OpenState.unknown => l10n.dropoffHoursUnknown,
};

String facilityTypeLabel(Vocab vocab, Locale locale, FacilityType type) =>
    vocab.facilityType(type).label.forLocale(locale);

/// "Collection point", or "Recycling center, E-waste" for several types.
String placeTypeLabel(Vocab vocab, Locale locale, Place place) => [
  for (final t in place.facilityTypes) facilityTypeLabel(vocab, locale, t),
].join(', ');

String materialLabel(Vocab vocab, Locale locale, MaterialCategory m) =>
    vocab.material(m).label.forLocale(locale);

/// Attribution the data source's terms require next to its places.
String sourceAttribution(AppLocalizations l10n, PlaceSource source) =>
    switch (source) {
      PlaceSource.osm => l10n.dropoffSourceOsm,
      PlaceSource.google => l10n.dropoffSourceGoogle,
      PlaceSource.curated => l10n.dropoffSourceCurated,
    };

/// Where the results were searched, for the header: "Near you", "Near Dubai".
String? searchPlaceName(
  AppLocalizations l10n,
  Vocab vocab,
  Locale locale,
  SearchLocation? location,
) {
  if (location == null) return null;
  final city = location.city;
  if (location.source == SearchLocationSource.gps || city == null) return null;
  return vocab.city(city).label.forLocale(locale);
}

/// The material a pin is colored by: the one material a place is known to
/// take, else the one material its matched categories cover. Places that
/// take several materials (or unknown ones) get a neutral ink pin, so a
/// color always means one specific stream.
String? pinMaterialOf(Place place, Map<String, FacilityCategory> catalog) {
  final accepted = place.acceptedMaterials;
  if (accepted != null && accepted.isNotEmpty) {
    return accepted.length == 1 ? accepted.first.id : null;
  }
  final materials = <String>{
    for (final key in place.categoryKeys)
      ...?catalog[key]?.materialCategories.map((m) => m.id),
    for (final key in place.categoryKeys)
      if (catalog[key] == null) ?MaterialCategory.tryFromId(key)?.id,
  };
  return materials.length == 1 ? materials.first : null;
}

/// The dot color for a pin: the material color, or ink when mixed.
Color pinColor(BuildContext context, String? materialId) => materialId == null
    ? context.kanzColors.ink
    : KanzMaterialColors.pin(context, materialId);

/// East and north offsets of [point] from [origin] in kilometres (a flat
/// projection, exact enough within a 15 km search radius).
({double east, double north}) offsetKm(
  GeoPoint origin,
  double lat,
  double lng,
) {
  const kmPerDegreeLat = 110.574;
  final kmPerDegreeLng = 111.320 * math.cos(origin.lat * math.pi / 180);
  return (
    east: (lng - origin.lng) * kmPerDegreeLng,
    north: (lat - origin.lat) * kmPerDegreeLat,
  );
}

/// The 8-point compass direction from [origin] to a place ('n', 'ne', ...),
/// or 'near' when it is practically at the centre.
String compassDirection(GeoPoint origin, double lat, double lng) {
  final o = offsetKm(origin, lat, lng);
  if (math.sqrt(o.east * o.east + o.north * o.north) < 0.2) return 'near';
  final degrees = (math.atan2(o.east, o.north) * 180 / math.pi + 360) % 360;
  const sectors = ['n', 'ne', 'e', 'se', 's', 'sw', 'w', 'nw'];
  return sectors[((degrees + 22.5) ~/ 45) % 8];
}

/// "North-east of Dubai centre" or "North-east of you".
String directionLabel(
  AppLocalizations l10n,
  GeoPoint origin,
  Place place, {
  required String? cityName,
}) {
  final direction = compassDirection(origin, place.lat, place.lng);
  return cityName == null
      ? l10n.dropoffDirectionOfYou(direction)
      : l10n.dropoffDirectionOfPlace(direction, cityName);
}

/// "Accepts glass, paper and plastic" for screen readers, when known.
String? acceptsLabel(
  AppLocalizations l10n,
  Vocab vocab,
  Locale locale,
  Place place,
) {
  final accepted = place.acceptedMaterials;
  if (accepted == null || accepted.isEmpty) return null;
  return l10n.dropoffAcceptsList(
    accepted.map((m) => materialLabel(vocab, locale, m)).join(', '),
  );
}

/// "places_unavailable · req_85b6e682": the error code as the backend names
/// it, for support.
String supportCode(ApiException error) => [
  error.code.name.replaceAllMapped(
    RegExp('[A-Z]'),
    (m) => '_${m[0]!.toLowerCase()}',
  ),
  ?error.requestId,
].join(' · ');
