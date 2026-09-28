// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facilities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FacilitiesRequest _$FacilitiesRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_FacilitiesRequest', json, ($checkedConvert) {
      final val = _FacilitiesRequest(
        categories: $checkedConvert(
          'categories',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        lat: $checkedConvert('lat', (v) => (v as num?)?.toDouble()),
        lng: $checkedConvert('lng', (v) => (v as num?)?.toDouble()),
        city: $checkedConvert(
          'city',
          (v) => $enumDecodeNullable(_$CityIdEnumMap, v),
        ),
        radiusM: $checkedConvert(
          'radius_m',
          (v) => (v as num?)?.toInt() ?? 15000,
        ),
        limit: $checkedConvert('limit', (v) => (v as num?)?.toInt() ?? 20),
        lang: $checkedConvert(
          'lang',
          (v) => $enumDecodeNullable(_$LangEnumMap, v) ?? Lang.en,
        ),
      );
      return val;
    }, fieldKeyMap: const {'radiusM': 'radius_m'});

Map<String, dynamic> _$FacilitiesRequestToJson(_FacilitiesRequest instance) =>
    <String, dynamic>{
      'categories': instance.categories,
      'lat': instance.lat,
      'lng': instance.lng,
      'city': _$CityIdEnumMap[instance.city],
      'radius_m': instance.radiusM,
      'limit': instance.limit,
      'lang': _$LangEnumMap[instance.lang]!,
    };

const _$CityIdEnumMap = {
  CityId.abuDhabi: 'abu_dhabi',
  CityId.alAin: 'al_ain',
  CityId.dubai: 'dubai',
  CityId.sharjah: 'sharjah',
  CityId.ajman: 'ajman',
  CityId.ummAlQuwain: 'umm_al_quwain',
  CityId.rasAlKhaimah: 'ras_al_khaimah',
  CityId.fujairah: 'fujairah',
};

const _$LangEnumMap = {Lang.en: 'en', Lang.ar: 'ar'};

_Place _$PlaceFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_Place',
  json,
  ($checkedConvert) {
    final val = _Place(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      address: $checkedConvert('address', (v) => v as String?),
      lat: $checkedConvert('lat', (v) => (v as num).toDouble()),
      lng: $checkedConvert('lng', (v) => (v as num).toDouble()),
      distanceM: $checkedConvert('distance_m', (v) => (v as num?)?.toInt()),
      openNow: $checkedConvert('open_now', (v) => v as bool?),
      phone: $checkedConvert('phone', (v) => v as String?),
      website: $checkedConvert('website', (v) => v as String?),
      mapsUrl: $checkedConvert('maps_url', (v) => v as String?),
      facilityTypes: $checkedConvert(
        'facility_types',
        (v) => (v as List<dynamic>)
            .map((e) => $enumDecode(_$FacilityTypeEnumMap, e))
            .toList(),
      ),
      categoryKeys: $checkedConvert(
        'category_keys',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      acceptedMaterials: $checkedConvert(
        'accepted_materials',
        (v) => (v as List<dynamic>?)
            ?.map((e) => $enumDecode(_$MaterialCategoryEnumMap, e))
            .toList(),
      ),
      acceptedNote: $checkedConvert('accepted_note', (v) => v as String?),
      rating: $checkedConvert('rating', (v) => (v as num?)?.toDouble()),
      source: $checkedConvert(
        'source',
        (v) => $enumDecode(_$PlaceSourceEnumMap, v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'distanceM': 'distance_m',
    'openNow': 'open_now',
    'mapsUrl': 'maps_url',
    'facilityTypes': 'facility_types',
    'categoryKeys': 'category_keys',
    'acceptedMaterials': 'accepted_materials',
    'acceptedNote': 'accepted_note',
  },
);

Map<String, dynamic> _$PlaceToJson(_Place instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'lat': instance.lat,
  'lng': instance.lng,
  'distance_m': instance.distanceM,
  'open_now': instance.openNow,
  'phone': instance.phone,
  'website': instance.website,
  'maps_url': instance.mapsUrl,
  'facility_types': instance.facilityTypes
      .map((e) => _$FacilityTypeEnumMap[e]!)
      .toList(),
  'category_keys': instance.categoryKeys,
  'accepted_materials': instance.acceptedMaterials
      ?.map((e) => _$MaterialCategoryEnumMap[e]!)
      .toList(),
  'accepted_note': instance.acceptedNote,
  'rating': instance.rating,
  'source': _$PlaceSourceEnumMap[instance.source]!,
};

const _$FacilityTypeEnumMap = {
  FacilityType.recyclingCenter: 'recycling_center',
  FacilityType.collectionPoint: 'collection_point',
  FacilityType.donation: 'donation',
  FacilityType.eWaste: 'e_waste',
  FacilityType.hazardousWaste: 'hazardous_waste',
  FacilityType.scrapMetal: 'scrap_metal',
  FacilityType.woodCollection: 'wood_collection',
};

const _$MaterialCategoryEnumMap = {
  MaterialCategory.glass: 'glass',
  MaterialCategory.plastic: 'plastic',
  MaterialCategory.paper: 'paper',
  MaterialCategory.metal: 'metal',
  MaterialCategory.textile: 'textile',
  MaterialCategory.wood: 'wood',
  MaterialCategory.electronics: 'electronics',
  MaterialCategory.hazardous: 'hazardous',
  MaterialCategory.organic: 'organic',
  MaterialCategory.other: 'other',
};

const _$PlaceSourceEnumMap = {
  PlaceSource.google: 'google',
  PlaceSource.osm: 'osm',
  PlaceSource.curated: 'curated',
};

_FacilitiesResponse _$FacilitiesResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_FacilitiesResponse',
      json,
      ($checkedConvert) {
        final val = _FacilitiesResponse(
          places: $checkedConvert(
            'places',
            (v) => (v as List<dynamic>)
                .map((e) => Place.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          center: $checkedConvert(
            'center',
            (v) => GeoPoint.fromJson(v as Map<String, dynamic>),
          ),
          centerLabel: $checkedConvert('center_label', (v) => v as String),
          sourcesUsed: $checkedConvert(
            'sources_used',
            (v) => (v as List<dynamic>)
                .map((e) => $enumDecode(_$PlaceSourceEnumMap, e))
                .toList(),
          ),
          notice: $checkedConvert('notice', (v) => v as String?),
          timingsMs: $checkedConvert(
            'timings_ms',
            (v) =>
                (v as Map<String, dynamic>?)?.map(
                  (k, e) => MapEntry(k, (e as num).toInt()),
                ) ??
                const <String, int>{},
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'centerLabel': 'center_label',
        'sourcesUsed': 'sources_used',
        'timingsMs': 'timings_ms',
      },
    );

Map<String, dynamic> _$FacilitiesResponseToJson(_FacilitiesResponse instance) =>
    <String, dynamic>{
      'places': instance.places.map((e) => e.toJson()).toList(),
      'center': instance.center.toJson(),
      'center_label': instance.centerLabel,
      'sources_used': instance.sourcesUsed
          .map((e) => _$PlaceSourceEnumMap[e]!)
          .toList(),
      'notice': instance.notice,
      'timings_ms': instance.timingsMs,
    };

_FacilityCategoriesResponse _$FacilityCategoriesResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_FacilityCategoriesResponse', json, ($checkedConvert) {
  final val = _FacilityCategoriesResponse(
    categories: $checkedConvert(
      'categories',
      (v) => (v as List<dynamic>)
          .map((e) => FacilityCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    lang: $checkedConvert('lang', (v) => $enumDecode(_$LangEnumMap, v)),
  );
  return val;
});

Map<String, dynamic> _$FacilityCategoriesResponseToJson(
  _FacilityCategoriesResponse instance,
) => <String, dynamic>{
  'categories': instance.categories.map((e) => e.toJson()).toList(),
  'lang': _$LangEnumMap[instance.lang]!,
};
