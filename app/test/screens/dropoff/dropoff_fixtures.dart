// Drop-off test data: a fake controller and states built from the contract
// fixtures, a mixed Google + OpenStreetMap result set with plain generic
// names, and a real OpenStreetMap response for Dubai (data/osm_dubai_*.json,
// saved from the backend) that shows how sparse real listings are.
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/core/state/dropoff_controller.dart';
import 'package:kanz/core/state/location_resolver.dart';

import '../../core/support/fixtures.dart';
import 'tab_test_support.dart';

/// Records every action and applies the local ones (filters, selection,
/// view) like the real controller; network actions are only recorded.
class FakeDropoffController extends DropoffController {
  FakeDropoffController(this.initial);

  final DropoffState initial;
  final List<String> calls = [];

  @override
  DropoffState build() => initial;

  void emit(DropoffState next) => state = next;

  @override
  Future<void> loadCatalog() async => calls.add('loadCatalog');

  @override
  Future<void> search() async => calls.add('search');

  @override
  Future<void> toggleCategory(String key) async {
    calls.add('toggleCategory:$key');
    final selected = {...state.selectedCategories};
    if (!selected.remove(key)) selected.add(key);
    // Like the real controller: nothing selected clears the results.
    state = selected.isEmpty
        ? state.copyWith(selectedCategories: selected, results: null)
        : state.copyWith(selectedCategories: selected);
  }

  @override
  Future<void> showCategories(Iterable<String> keys) async =>
      calls.add('showCategories:${keys.join(',')}');

  @override
  Future<void> useCity(CityId city) async => calls.add('useCity:${city.id}');

  @override
  Future<void> useMyLocation() async => calls.add('useMyLocation');

  @override
  void toggleType(FacilityType type) {
    calls.add('toggleType:${type.id}');
    super.toggleType(type);
  }

  @override
  void clearTypes() {
    calls.add('clearTypes');
    super.clearTypes();
  }

  @override
  void selectPlace(String? placeId) {
    calls.add('selectPlace:$placeId');
    super.selectPlace(placeId);
  }

  @override
  void setView(DropoffView view) {
    calls.add('setView:${view.name}');
    super.setView(view);
  }
}

List<FacilityCategory> catalogFor({required bool ar}) =>
    FacilityCategoriesResponse.fromJson(
      ar
          ? readJson('test/screens/dropoff/data/categories_ar.json')
          : fixture('facility_categories.json'),
    ).categories;

const _general = {'glass', 'plastic', 'paper', 'metal'};

/// Six places around Abu Dhabi from both sources, with generic names.
FacilitiesResponse mixedResults({required bool ar}) {
  Place place(
    String id,
    String en,
    String arName, {
    required double lat,
    required double lng,
    required int distance,
    required List<FacilityType> types,
    required List<String> keys,
    required PlaceSource source,
    String? addressEn,
    String? addressAr,
    List<MaterialCategory>? accepted,
    bool? openNow,
    String? phone,
    String? website,
  }) => Place(
    id: id,
    name: ar ? arName : en,
    address: ar ? addressAr : addressEn,
    lat: lat,
    lng: lng,
    distanceM: distance,
    openNow: openNow,
    phone: phone,
    website: website,
    mapsUrl:
        'https://www.google.com/maps/search/?api=1&query='
        '${lat.toStringAsFixed(4)},${lng.toStringAsFixed(4)}',
    facilityTypes: types,
    categoryKeys: keys,
    acceptedMaterials: accepted,
    source: source,
  );

  return FacilitiesResponse(
    places: [
      place(
        'osm:node/1',
        'Glass collection point',
        'نقطة تجميع الزجاج',
        lat: 24.4612,
        lng: 54.3702,
        distance: 950,
        types: const [FacilityType.collectionPoint],
        keys: const ['glass'],
        source: PlaceSource.osm,
        addressEn: 'Al Khalidiyah',
        addressAr: 'الخالدية',
        accepted: const [MaterialCategory.glass],
      ),
      place(
        'g:2',
        'Municipal recycling centre',
        'مركز إعادة التدوير البلدي',
        lat: 24.4402,
        lng: 54.3995,
        distance: 2700,
        types: const [FacilityType.recyclingCenter],
        keys: const ['glass', 'metal', 'paper', 'plastic'],
        source: PlaceSource.google,
        addressEn: 'Mussafah Industrial Area',
        addressAr: 'المصفح الصناعية',
        openNow: true,
        phone: '+971 2 000 0000',
        website: 'example.org',
      ),
      place(
        'osm:node/3',
        'Recycling point',
        'نقطة إعادة تدوير',
        lat: 24.4789,
        lng: 54.3551,
        distance: 3400,
        types: const [FacilityType.collectionPoint],
        keys: const ['glass', 'metal', 'paper', 'plastic'],
        source: PlaceSource.osm,
        accepted: const [
          MaterialCategory.glass,
          MaterialCategory.plastic,
          MaterialCategory.paper,
          MaterialCategory.metal,
        ],
      ),
      place(
        'osm:node/4',
        'Paper and cardboard bank',
        'حاوية الورق والكرتون',
        lat: 24.4215,
        lng: 54.3620,
        distance: 4100,
        types: const [FacilityType.collectionPoint],
        keys: const ['paper'],
        source: PlaceSource.osm,
        accepted: const [MaterialCategory.paper],
      ),
      place(
        'osm:node/5',
        'Can and bottle bank',
        'حاوية العلب والزجاجات',
        lat: 24.4990,
        lng: 54.4110,
        distance: 6800,
        types: const [FacilityType.collectionPoint],
        keys: const ['metal', 'plastic'],
        source: PlaceSource.osm,
        accepted: const [MaterialCategory.metal, MaterialCategory.plastic],
      ),
      place(
        'g:6',
        'Scrap metal yard',
        'ساحة خردة المعادن',
        lat: 24.3802,
        lng: 54.4905,
        distance: 9600,
        types: const [FacilityType.scrapMetal],
        keys: const ['metal'],
        source: PlaceSource.google,
        addressEn: 'Mussafah M-40',
        addressAr: 'المصفح م-40',
        openNow: false,
        phone: '+971 2 000 0001',
      ),
    ],
    center: const GeoPoint(lat: 24.4539, lng: 54.3773),
    centerLabel: ar ? 'أبوظبي' : 'Abu Dhabi',
    sourcesUsed: const [PlaceSource.google, PlaceSource.osm],
  );
}

/// The backend's real answer for Dubai (OpenStreetMap only).
FacilitiesResponse osmDubai({required bool ar}) => FacilitiesResponse.fromJson(
  readJson('test/screens/dropoff/data/osm_dubai_${ar ? 'ar' : 'en'}.json'),
);

DropoffState resultsState({
  required bool ar,
  FacilitiesResponse? results,
  SearchLocation location = const SearchLocation.city(CityId.abuDhabi),
  Set<FacilityType> typeFilter = const {},
  String? selectedPlaceId,
  DropoffView view = DropoffView.list,
  bool searching = false,
}) => DropoffState(
  catalog: catalogFor(ar: ar),
  selectedCategories: _general,
  location: location,
  results: results ?? mixedResults(ar: ar),
  typeFilter: typeFilter,
  selectedPlaceId: selectedPlaceId,
  view: view,
  searching: searching,
);

DropoffState searchingState({required bool ar}) => DropoffState(
  catalog: catalogFor(ar: ar),
  selectedCategories: _general,
  location: const SearchLocation.city(CityId.abuDhabi),
  searching: true,
);

DropoffState needsLocationState({required bool ar}) => DropoffState(
  catalog: catalogFor(ar: ar),
  selectedCategories: _general,
  needsLocation: true,
);

DropoffState emptyState({required bool ar}) => DropoffState(
  catalog: catalogFor(ar: ar),
  selectedCategories: const {'textile_donation'},
  location: const SearchLocation.city(CityId.fujairah),
  results: FacilitiesResponse(
    places: const [],
    center: const GeoPoint(lat: 25.1288, lng: 56.3265),
    centerLabel: ar ? 'الفجيرة' : 'Fujairah',
    sourcesUsed: const [PlaceSource.osm],
  ),
);

/// One category selected; the test deselects it to reach "Pick a material".
DropoffState oneCategoryState({required bool ar}) => DropoffState(
  catalog: catalogFor(ar: ar),
  selectedCategories: const {'glass'},
  location: const SearchLocation.city(CityId.abuDhabi),
  results: mixedResults(ar: ar),
);

DropoffState errorState({required bool ar, required ApiException error}) =>
    DropoffState(
      catalog: catalogFor(ar: ar),
      selectedCategories: _general,
      location: const SearchLocation.city(CityId.abuDhabi),
      error: error,
    );

/// The chips failed to load, but the default search still returned places.
DropoffState catalogErrorState({required bool ar}) => DropoffState(
  catalogError: const ApiException.offline(),
  selectedCategories: _general,
  location: const SearchLocation.gps(lat: 24.4539, lng: 54.3773),
  results: mixedResults(ar: ar),
);

const placesUnavailable = ApiException(
  code: ApiErrorCode.placesUnavailable,
  message: "We couldn't load drop-off points right now.",
  retryable: true,
  requestId: 'req_85b6e682',
);
