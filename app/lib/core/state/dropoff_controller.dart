import 'dart:async';

import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../config/env.dart';
import '../data/models/models.dart';
import '../network/api_exception.dart';
import 'core_providers.dart';
import 'location_resolver.dart';
import 'settings_providers.dart';

part 'dropoff_controller.freezed.dart';

enum DropoffView { list, map }

@freezed
abstract class DropoffState with _$DropoffState {
  const factory DropoffState({
    /// Filter chips from GET /v1/facilities/categories.
    @Default(<FacilityCategory>[]) List<FacilityCategory> catalog,
    @Default(false) bool catalogLoading,
    ApiException? catalogError,

    /// Category keys searched for.
    @Default(<String>{}) Set<String> selectedCategories,

    /// Facility types shown; empty shows every type. Filters locally.
    @Default(<FacilityType>{}) Set<FacilityType> typeFilter,
    SearchLocation? location,

    /// No GPS decision and no city yet: show the rationale or city picker,
    /// then call `useMyLocation()` or `useCity()`.
    @Default(false) bool needsLocation,
    @Default(false) bool searching,
    FacilitiesResponse? results,
    ApiException? error,
    String? selectedPlaceId,
    @Default(DropoffView.list) DropoffView view,
  }) = _DropoffState;

  const DropoffState._();

  /// Places after the facility-type filter, nearest first.
  List<Place> get visiblePlaces {
    final places = results?.places ?? const <Place>[];
    if (typeFilter.isEmpty) return places;
    return places
        .where((p) => p.facilityTypes.any(typeFilter.contains))
        .toList(growable: false);
  }

  Place? get selectedPlace =>
      visiblePlaces.where((p) => p.id == selectedPlaceId).firstOrNull;

  /// The map needs the Android Maps key (`--dart-define=KANZ_MAPS=1`).
  bool get mapAvailable => Env.mapsEnabled;
}

/// The Drop-off tab: category and type filters, location, results, the
/// selected place and list/map mode. Kept alive so the tab keeps its state.
final dropoffControllerProvider =
    NotifierProvider<DropoffController, DropoffState>(DropoffController.new);

class DropoffController extends Notifier<DropoffState> {
  /// Categories used when there is no recent scan to take them from.
  static const defaultCategories = ['glass', 'plastic', 'paper', 'metal'];

  int _search = 0;
  CancelToken? _token;

  @override
  DropoffState build() {
    ref.onDispose(() => _token?.cancel());
    scheduleMicrotask(_init);
    return const DropoffState(catalogLoading: true);
  }

  Future<void> _init() async {
    await loadCatalog();
    if (!ref.mounted || state.selectedCategories.isNotEmpty) return;
    state = state.copyWith(selectedCategories: await _initialCategories());
    await search();
  }

  /// Starts from the latest scan's categories, else general recycling.
  Future<Set<String>> _initialCategories() async {
    final latest = await ref
        .read(scanRepositoryProvider)
        .latestWithRecommendation();
    final fromScan = {
      for (final c
          in latest?.recommendation?.facilityCategories ??
              const <FacilityCategory>[])
        c.key,
    };
    if (fromScan.isNotEmpty) return fromScan;
    final available = {for (final c in state.catalog) c.key};
    final general = defaultCategories.where(available.contains).toSet();
    return general.isNotEmpty ? general : available.take(3).toSet();
  }

  Future<void> loadCatalog() async {
    state = state.copyWith(catalogLoading: true, catalogError: null);
    try {
      final response = await ref
          .read(apiClientProvider)
          .facilityCategories(lang: ref.read(contentLangProvider));
      if (!ref.mounted) return;
      state = state.copyWith(
        catalog: response.categories,
        catalogLoading: false,
      );
    } on ApiException catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(catalogLoading: false, catalogError: e);
    }
  }

  Future<void> toggleCategory(String key) {
    final selected = {...state.selectedCategories};
    if (!selected.remove(key)) selected.add(key);
    state = state.copyWith(selectedCategories: selected);
    return search();
  }

  /// Shows specific categories, e.g. from a scan's "See all drop-off points".
  Future<void> showCategories(Iterable<String> keys) {
    state = state.copyWith(selectedCategories: keys.toSet());
    return search();
  }

  void toggleType(FacilityType type) {
    final types = {...state.typeFilter};
    if (!types.remove(type)) types.add(type);
    state = state.copyWith(typeFilter: types, selectedPlaceId: null);
  }

  void clearTypes() => state = state.copyWith(typeFilter: const {});

  /// Searches around a chosen city (also saved as the user's city).
  Future<void> useCity(CityId city) async {
    await ref.read(settingsProvider.notifier).useCity(city);
    await search();
  }

  /// Switches to GPS. Call after the location permission was granted.
  Future<void> useMyLocation() async {
    await ref.read(settingsProvider.notifier).setLocationMode(LocationMode.gps);
    await search();
  }

  void selectPlace(String? placeId) =>
      state = state.copyWith(selectedPlaceId: placeId);

  void setView(DropoffView view) => state = state.copyWith(view: view);

  /// Runs the search for the selected categories at the resolved location.
  Future<void> search() async {
    final categories = state.selectedCategories.toList()..sort();
    _token?.cancel();
    final token = _token = CancelToken();
    final run = ++_search;
    bool current() => ref.mounted && run == _search;

    if (categories.isEmpty) {
      state = state.copyWith(searching: false, results: null, error: null);
      return;
    }
    state = state.copyWith(searching: true, error: null, needsLocation: false);
    final location = await ref
        .read(locationResolverProvider)
        .resolve(ref.read(settingsProvider));
    if (!current()) return;
    if (location == null) {
      state = state.copyWith(searching: false, needsLocation: true);
      return;
    }
    state = state.copyWith(location: location);
    try {
      final results = await ref
          .read(apiClientProvider)
          .facilities(
            location.toRequest(categories, ref.read(contentLangProvider)),
            cancelToken: token,
          );
      if (!current()) return;
      state = state.copyWith(
        searching: false,
        results: results,
        selectedPlaceId: null,
      );
    } on ApiException catch (e) {
      if (!current() || e.isCancelled) return;
      state = state.copyWith(searching: false, error: e);
    }
  }
}
