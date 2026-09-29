/// Pure helpers that turn drop-off data into what the screen shows: labels,
/// open state, pin colors, compass directions and source attribution.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';

import '../../core/data/models/models.dart';
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
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
/// listing names what it accepts; it takes the color of the accepted
/// material that matches the user's chips, or is split into two half-discs
/// when two or more match. A hollow ring means the materials are not listed
/// (most OpenStreetMap points); it takes the material's color when the
/// place was found for one material only, and stays neutral otherwise.
/// No mark is ever ink: the material colors lead, like the chips above.
@immutable
class PinMark {
  const PinMark({required this.listed, this.materialIds = const []});

  /// The listing names the materials it accepts.
  final bool listed;

  /// The material colors of the mark, at most two (a split dot); empty for
  /// a neutral ring.
  final List<String> materialIds;

  @override
  bool operator ==(Object other) =>
      other is PinMark &&
      other.listed == listed &&
      listEquals(other.materialIds, materialIds);

  @override
  int get hashCode => Object.hash(listed, Object.hashAll(materialIds));
}

/// The material ids behind the selected category chips. Keys the catalog
/// does not know (it failed to load) still count when they name a material.
Set<String> selectedMaterialIds(
  Iterable<String> categoryKeys,
  Map<String, FacilityCategory> catalog,
) => {
  for (final key in categoryKeys)
    ...?catalog[key]?.materialCategories.map((m) => m.id),
  for (final key in categoryKeys)
    if (catalog[key] == null) ?MaterialCategory.tryFromId(key)?.id,
};

/// The [PinMark] for [place]. Listed: the accepted materials that match
/// [selected] (material ids, see [selectedMaterialIds]), in the listing's
/// order, else its first accepted material. Unlisted: the materials of the
/// categories it was found for, when there is only one.
PinMark pinMarkOf(
  Place place,
  Map<String, FacilityCategory> catalog, {
  Set<String> selected = const {},
}) {
  final accepted = place.acceptedMaterials;
  if (accepted != null && accepted.isNotEmpty) {
    final ids = {for (final m in accepted) m.id}.toList();
    final matching = ids.where(selected.contains).toList();
    final shown = matching.isEmpty ? ids.take(1) : matching.take(2);
    return PinMark(listed: true, materialIds: shown.toList(growable: false));
  }
  final materials = selectedMaterialIds(place.categoryKeys, catalog);
  return PinMark(
    listed: false,
    materialIds: materials.length == 1 ? [materials.first] : const [],
  );
}

/// The colors a pin is drawn in: one or two material colors, or the strong
/// hairline for a ring that no single material explains.
List<Color> pinColors(BuildContext context, PinMark? mark) {
  final ids = mark?.materialIds ?? const <String>[];
  if (ids.isEmpty) return [context.kanzColors.lineStrong];
  return [for (final id in ids) KanzMaterialColors.pin(context, id)];
}

/// The mark the key shows for "takes your materials": the nearest listed
/// place's own mark, so the key matches a dot the user can see. Null when
/// no place is listed.
PinMark? keyListedMark(List<Place> places, Map<String, PinMark> marks) {
  for (final place in places) {
    final mark = marks[place.id];
    if (mark != null && mark.listed) return mark;
  }
  return null;
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
