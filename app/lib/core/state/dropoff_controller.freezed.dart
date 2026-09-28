// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dropoff_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DropoffState {

/// Filter chips from GET /v1/facilities/categories.
 List<FacilityCategory> get catalog; bool get catalogLoading; ApiException? get catalogError;/// Category keys searched for.
 Set<String> get selectedCategories;/// Facility types shown; empty shows every type. Filters locally.
 Set<FacilityType> get typeFilter; SearchLocation? get location;/// No GPS decision and no city yet: show the rationale or city picker,
/// then call `useMyLocation()` or `useCity()`.
 bool get needsLocation; bool get searching; FacilitiesResponse? get results; ApiException? get error; String? get selectedPlaceId; DropoffView get view;
/// Create a copy of DropoffState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DropoffStateCopyWith<DropoffState> get copyWith => _$DropoffStateCopyWithImpl<DropoffState>(this as DropoffState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DropoffState&&const DeepCollectionEquality().equals(other.catalog, catalog)&&(identical(other.catalogLoading, catalogLoading) || other.catalogLoading == catalogLoading)&&(identical(other.catalogError, catalogError) || other.catalogError == catalogError)&&const DeepCollectionEquality().equals(other.selectedCategories, selectedCategories)&&const DeepCollectionEquality().equals(other.typeFilter, typeFilter)&&(identical(other.location, location) || other.location == location)&&(identical(other.needsLocation, needsLocation) || other.needsLocation == needsLocation)&&(identical(other.searching, searching) || other.searching == searching)&&(identical(other.results, results) || other.results == results)&&(identical(other.error, error) || other.error == error)&&(identical(other.selectedPlaceId, selectedPlaceId) || other.selectedPlaceId == selectedPlaceId)&&(identical(other.view, view) || other.view == view));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(catalog),catalogLoading,catalogError,const DeepCollectionEquality().hash(selectedCategories),const DeepCollectionEquality().hash(typeFilter),location,needsLocation,searching,results,error,selectedPlaceId,view);

@override
String toString() {
  return 'DropoffState(catalog: $catalog, catalogLoading: $catalogLoading, catalogError: $catalogError, selectedCategories: $selectedCategories, typeFilter: $typeFilter, location: $location, needsLocation: $needsLocation, searching: $searching, results: $results, error: $error, selectedPlaceId: $selectedPlaceId, view: $view)';
}


}

/// @nodoc
abstract mixin class $DropoffStateCopyWith<$Res>  {
  factory $DropoffStateCopyWith(DropoffState value, $Res Function(DropoffState) _then) = _$DropoffStateCopyWithImpl;
@useResult
$Res call({
 List<FacilityCategory> catalog, bool catalogLoading, ApiException? catalogError, Set<String> selectedCategories, Set<FacilityType> typeFilter, SearchLocation? location, bool needsLocation, bool searching, FacilitiesResponse? results, ApiException? error, String? selectedPlaceId, DropoffView view
});


$FacilitiesResponseCopyWith<$Res>? get results;

}
/// @nodoc
class _$DropoffStateCopyWithImpl<$Res>
    implements $DropoffStateCopyWith<$Res> {
  _$DropoffStateCopyWithImpl(this._self, this._then);

  final DropoffState _self;
  final $Res Function(DropoffState) _then;

/// Create a copy of DropoffState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? catalog = null,Object? catalogLoading = null,Object? catalogError = freezed,Object? selectedCategories = null,Object? typeFilter = null,Object? location = freezed,Object? needsLocation = null,Object? searching = null,Object? results = freezed,Object? error = freezed,Object? selectedPlaceId = freezed,Object? view = null,}) {
  return _then(_self.copyWith(
catalog: null == catalog ? _self.catalog : catalog // ignore: cast_nullable_to_non_nullable
as List<FacilityCategory>,catalogLoading: null == catalogLoading ? _self.catalogLoading : catalogLoading // ignore: cast_nullable_to_non_nullable
as bool,catalogError: freezed == catalogError ? _self.catalogError : catalogError // ignore: cast_nullable_to_non_nullable
as ApiException?,selectedCategories: null == selectedCategories ? _self.selectedCategories : selectedCategories // ignore: cast_nullable_to_non_nullable
as Set<String>,typeFilter: null == typeFilter ? _self.typeFilter : typeFilter // ignore: cast_nullable_to_non_nullable
as Set<FacilityType>,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as SearchLocation?,needsLocation: null == needsLocation ? _self.needsLocation : needsLocation // ignore: cast_nullable_to_non_nullable
as bool,searching: null == searching ? _self.searching : searching // ignore: cast_nullable_to_non_nullable
as bool,results: freezed == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as FacilitiesResponse?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiException?,selectedPlaceId: freezed == selectedPlaceId ? _self.selectedPlaceId : selectedPlaceId // ignore: cast_nullable_to_non_nullable
as String?,view: null == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as DropoffView,
  ));
}
/// Create a copy of DropoffState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FacilitiesResponseCopyWith<$Res>? get results {
    if (_self.results == null) {
    return null;
  }

  return $FacilitiesResponseCopyWith<$Res>(_self.results!, (value) {
    return _then(_self.copyWith(results: value));
  });
}
}


/// Adds pattern-matching-related methods to [DropoffState].
extension DropoffStatePatterns on DropoffState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DropoffState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DropoffState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DropoffState value)  $default,){
final _that = this;
switch (_that) {
case _DropoffState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DropoffState value)?  $default,){
final _that = this;
switch (_that) {
case _DropoffState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FacilityCategory> catalog,  bool catalogLoading,  ApiException? catalogError,  Set<String> selectedCategories,  Set<FacilityType> typeFilter,  SearchLocation? location,  bool needsLocation,  bool searching,  FacilitiesResponse? results,  ApiException? error,  String? selectedPlaceId,  DropoffView view)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DropoffState() when $default != null:
return $default(_that.catalog,_that.catalogLoading,_that.catalogError,_that.selectedCategories,_that.typeFilter,_that.location,_that.needsLocation,_that.searching,_that.results,_that.error,_that.selectedPlaceId,_that.view);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FacilityCategory> catalog,  bool catalogLoading,  ApiException? catalogError,  Set<String> selectedCategories,  Set<FacilityType> typeFilter,  SearchLocation? location,  bool needsLocation,  bool searching,  FacilitiesResponse? results,  ApiException? error,  String? selectedPlaceId,  DropoffView view)  $default,) {final _that = this;
switch (_that) {
case _DropoffState():
return $default(_that.catalog,_that.catalogLoading,_that.catalogError,_that.selectedCategories,_that.typeFilter,_that.location,_that.needsLocation,_that.searching,_that.results,_that.error,_that.selectedPlaceId,_that.view);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FacilityCategory> catalog,  bool catalogLoading,  ApiException? catalogError,  Set<String> selectedCategories,  Set<FacilityType> typeFilter,  SearchLocation? location,  bool needsLocation,  bool searching,  FacilitiesResponse? results,  ApiException? error,  String? selectedPlaceId,  DropoffView view)?  $default,) {final _that = this;
switch (_that) {
case _DropoffState() when $default != null:
return $default(_that.catalog,_that.catalogLoading,_that.catalogError,_that.selectedCategories,_that.typeFilter,_that.location,_that.needsLocation,_that.searching,_that.results,_that.error,_that.selectedPlaceId,_that.view);case _:
  return null;

}
}

}

/// @nodoc


class _DropoffState extends DropoffState {
  const _DropoffState({final  List<FacilityCategory> catalog = const <FacilityCategory>[], this.catalogLoading = false, this.catalogError, final  Set<String> selectedCategories = const <String>{}, final  Set<FacilityType> typeFilter = const <FacilityType>{}, this.location, this.needsLocation = false, this.searching = false, this.results, this.error, this.selectedPlaceId, this.view = DropoffView.list}): _catalog = catalog,_selectedCategories = selectedCategories,_typeFilter = typeFilter,super._();
  

/// Filter chips from GET /v1/facilities/categories.
 final  List<FacilityCategory> _catalog;
/// Filter chips from GET /v1/facilities/categories.
@override@JsonKey() List<FacilityCategory> get catalog {
  if (_catalog is EqualUnmodifiableListView) return _catalog;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_catalog);
}

@override@JsonKey() final  bool catalogLoading;
@override final  ApiException? catalogError;
/// Category keys searched for.
 final  Set<String> _selectedCategories;
/// Category keys searched for.
@override@JsonKey() Set<String> get selectedCategories {
  if (_selectedCategories is EqualUnmodifiableSetView) return _selectedCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedCategories);
}

/// Facility types shown; empty shows every type. Filters locally.
 final  Set<FacilityType> _typeFilter;
/// Facility types shown; empty shows every type. Filters locally.
@override@JsonKey() Set<FacilityType> get typeFilter {
  if (_typeFilter is EqualUnmodifiableSetView) return _typeFilter;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_typeFilter);
}

@override final  SearchLocation? location;
/// No GPS decision and no city yet: show the rationale or city picker,
/// then call `useMyLocation()` or `useCity()`.
@override@JsonKey() final  bool needsLocation;
@override@JsonKey() final  bool searching;
@override final  FacilitiesResponse? results;
@override final  ApiException? error;
@override final  String? selectedPlaceId;
@override@JsonKey() final  DropoffView view;

/// Create a copy of DropoffState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DropoffStateCopyWith<_DropoffState> get copyWith => __$DropoffStateCopyWithImpl<_DropoffState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DropoffState&&const DeepCollectionEquality().equals(other._catalog, _catalog)&&(identical(other.catalogLoading, catalogLoading) || other.catalogLoading == catalogLoading)&&(identical(other.catalogError, catalogError) || other.catalogError == catalogError)&&const DeepCollectionEquality().equals(other._selectedCategories, _selectedCategories)&&const DeepCollectionEquality().equals(other._typeFilter, _typeFilter)&&(identical(other.location, location) || other.location == location)&&(identical(other.needsLocation, needsLocation) || other.needsLocation == needsLocation)&&(identical(other.searching, searching) || other.searching == searching)&&(identical(other.results, results) || other.results == results)&&(identical(other.error, error) || other.error == error)&&(identical(other.selectedPlaceId, selectedPlaceId) || other.selectedPlaceId == selectedPlaceId)&&(identical(other.view, view) || other.view == view));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_catalog),catalogLoading,catalogError,const DeepCollectionEquality().hash(_selectedCategories),const DeepCollectionEquality().hash(_typeFilter),location,needsLocation,searching,results,error,selectedPlaceId,view);

@override
String toString() {
  return 'DropoffState(catalog: $catalog, catalogLoading: $catalogLoading, catalogError: $catalogError, selectedCategories: $selectedCategories, typeFilter: $typeFilter, location: $location, needsLocation: $needsLocation, searching: $searching, results: $results, error: $error, selectedPlaceId: $selectedPlaceId, view: $view)';
}


}

/// @nodoc
abstract mixin class _$DropoffStateCopyWith<$Res> implements $DropoffStateCopyWith<$Res> {
  factory _$DropoffStateCopyWith(_DropoffState value, $Res Function(_DropoffState) _then) = __$DropoffStateCopyWithImpl;
@override @useResult
$Res call({
 List<FacilityCategory> catalog, bool catalogLoading, ApiException? catalogError, Set<String> selectedCategories, Set<FacilityType> typeFilter, SearchLocation? location, bool needsLocation, bool searching, FacilitiesResponse? results, ApiException? error, String? selectedPlaceId, DropoffView view
});


@override $FacilitiesResponseCopyWith<$Res>? get results;

}
/// @nodoc
class __$DropoffStateCopyWithImpl<$Res>
    implements _$DropoffStateCopyWith<$Res> {
  __$DropoffStateCopyWithImpl(this._self, this._then);

  final _DropoffState _self;
  final $Res Function(_DropoffState) _then;

/// Create a copy of DropoffState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? catalog = null,Object? catalogLoading = null,Object? catalogError = freezed,Object? selectedCategories = null,Object? typeFilter = null,Object? location = freezed,Object? needsLocation = null,Object? searching = null,Object? results = freezed,Object? error = freezed,Object? selectedPlaceId = freezed,Object? view = null,}) {
  return _then(_DropoffState(
catalog: null == catalog ? _self._catalog : catalog // ignore: cast_nullable_to_non_nullable
as List<FacilityCategory>,catalogLoading: null == catalogLoading ? _self.catalogLoading : catalogLoading // ignore: cast_nullable_to_non_nullable
as bool,catalogError: freezed == catalogError ? _self.catalogError : catalogError // ignore: cast_nullable_to_non_nullable
as ApiException?,selectedCategories: null == selectedCategories ? _self._selectedCategories : selectedCategories // ignore: cast_nullable_to_non_nullable
as Set<String>,typeFilter: null == typeFilter ? _self._typeFilter : typeFilter // ignore: cast_nullable_to_non_nullable
as Set<FacilityType>,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as SearchLocation?,needsLocation: null == needsLocation ? _self.needsLocation : needsLocation // ignore: cast_nullable_to_non_nullable
as bool,searching: null == searching ? _self.searching : searching // ignore: cast_nullable_to_non_nullable
as bool,results: freezed == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as FacilitiesResponse?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiException?,selectedPlaceId: freezed == selectedPlaceId ? _self.selectedPlaceId : selectedPlaceId // ignore: cast_nullable_to_non_nullable
as String?,view: null == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as DropoffView,
  ));
}

/// Create a copy of DropoffState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FacilitiesResponseCopyWith<$Res>? get results {
    if (_self.results == null) {
    return null;
  }

  return $FacilitiesResponseCopyWith<$Res>(_self.results!, (value) {
    return _then(_self.copyWith(results: value));
  });
}
}

// dart format on
