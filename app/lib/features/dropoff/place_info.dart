/// Pure helpers that turn drop-off data into what the screen shows: labels,
/// open state, pin colors, compass directions and source attribution.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kDebugMode;
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
String placeTypeLabel(
  AppLocalizations l10n,
  Vocab vocab,
  Locale locale,
  Place place,
) => formatList(l10n, [
  for (final t in place.facilityTypes) facilityTypeLabel(vocab, locale, t),
]);

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

/// How a place is marked on the plot and the map. A filled dot means the
/// listing names what it accepts: in that material's color when it is one
/// material, in ink when it is several. A hollow ring means the materials
/// are not listed (most OpenStreetMap points); it takes the material's
/// color when the place was found for one material only, and stays
/// neutral otherwise, so filled dots always lead.
@immutable
class PinMark {
  const PinMark({required this.listed, this.materialId});

  /// The listing names the materials it accepts.
  final bool listed;

  /// The one material the pin is colored by; null for several or unknown.
  final String? materialId;

  @override
  bool operator ==(Object other) =>
      other is PinMark &&
      other.listed == listed &&
      other.materialId == materialId;

  @override
  int get hashCode => Object.hash(listed, materialId);
}

/// The [PinMark] for [place]: its accepted materials when listed, else the
/// materials of the categories it was found for.
PinMark pinMarkOf(Place place, Map<String, FacilityCategory> catalog) {
  final accepted = place.acceptedMaterials;
  if (accepted != null && accepted.isNotEmpty) {
    final ids = {for (final m in accepted) m.id};
    return PinMark(
      listed: true,
      materialId: ids.length == 1 ? ids.first : null,
    );
  }
  final materials = <String>{
    for (final key in place.categoryKeys)
      ...?catalog[key]?.materialCategories.map((m) => m.id),
    for (final key in place.categoryKeys)
      if (catalog[key] == null) ?MaterialCategory.tryFromId(key)?.id,
  };
  return PinMark(
    listed: false,
    materialId: materials.length == 1 ? materials.first : null,
  );
}

/// The color a pin is drawn in: the material color, ink for a listed place
/// that takes several materials, the strong hairline for an unlisted one.
Color pinColor(BuildContext context, PinMark? mark) {
  final c = context.kanzColors;
  return switch (mark) {
    PinMark(:final materialId?) => KanzMaterialColors.pin(context, materialId),
    PinMark(listed: true) => c.ink,
    _ => c.lineStrong,
  };
}

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
    formatList(l10n, [
      for (final m in accepted) materialLabel(vocab, locale, m),
    ], sentence: true),
  );
}

/// What support needs to find a failure: the request id, with the error
/// code as the backend spells it ("places_unavailable") in debug builds.
/// Null when there is nothing to look up.
String? supportCode(ApiException error) {
  final id = error.requestId;
  if (id == null) return null;
  return [if (kDebugMode) error.code.wireId, id].join(' · ');
}
