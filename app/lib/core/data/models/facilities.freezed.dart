// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'facilities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FacilitiesRequest {

 List<String> get categories; double? get lat; double? get lng; CityId? get city; int get radiusM; int get limit; Lang get lang;
/// Create a copy of FacilitiesRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacilitiesRequestCopyWith<FacilitiesRequest> get copyWith => _$FacilitiesRequestCopyWithImpl<FacilitiesRequest>(this as FacilitiesRequest, _$identity);

  /// Serializes this FacilitiesRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FacilitiesRequest&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.city, city) || other.city == city)&&(identical(other.radiusM, radiusM) || other.radiusM == radiusM)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.lang, lang) || other.lang == lang));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(categories),lat,lng,city,radiusM,limit,lang);

@override
String toString() {
  return 'FacilitiesRequest(categories: $categories, lat: $lat, lng: $lng, city: $city, radiusM: $radiusM, limit: $limit, lang: $lang)';
}


}

/// @nodoc
abstract mixin class $FacilitiesRequestCopyWith<$Res>  {
  factory $FacilitiesRequestCopyWith(FacilitiesRequest value, $Res Function(FacilitiesRequest) _then) = _$FacilitiesRequestCopyWithImpl;
@useResult
$Res call({
 List<String> categories, double? lat, double? lng, CityId? city, int radiusM, int limit, Lang lang
});




}
/// @nodoc
class _$FacilitiesRequestCopyWithImpl<$Res>
    implements $FacilitiesRequestCopyWith<$Res> {
  _$FacilitiesRequestCopyWithImpl(this._self, this._then);

  final FacilitiesRequest _self;
  final $Res Function(FacilitiesRequest) _then;

/// Create a copy of FacilitiesRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categories = null,Object? lat = freezed,Object? lng = freezed,Object? city = freezed,Object? radiusM = null,Object? limit = null,Object? lang = null,}) {
  return _then(_self.copyWith(
categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as CityId?,radiusM: null == radiusM ? _self.radiusM : radiusM // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as Lang,
  ));
}

}


/// Adds pattern-matching-related methods to [FacilitiesRequest].
extension FacilitiesRequestPatterns on FacilitiesRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FacilitiesRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FacilitiesRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FacilitiesRequest value)  $default,){
final _that = this;
switch (_that) {
case _FacilitiesRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FacilitiesRequest value)?  $default,){
final _that = this;
switch (_that) {
case _FacilitiesRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> categories,  double? lat,  double? lng,  CityId? city,  int radiusM,  int limit,  Lang lang)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FacilitiesRequest() when $default != null:
return $default(_that.categories,_that.lat,_that.lng,_that.city,_that.radiusM,_that.limit,_that.lang);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> categories,  double? lat,  double? lng,  CityId? city,  int radiusM,  int limit,  Lang lang)  $default,) {final _that = this;
switch (_that) {
case _FacilitiesRequest():
return $default(_that.categories,_that.lat,_that.lng,_that.city,_that.radiusM,_that.limit,_that.lang);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> categories,  double? lat,  double? lng,  CityId? city,  int radiusM,  int limit,  Lang lang)?  $default,) {final _that = this;
switch (_that) {
case _FacilitiesRequest() when $default != null:
return $default(_that.categories,_that.lat,_that.lng,_that.city,_that.radiusM,_that.limit,_that.lang);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FacilitiesRequest implements FacilitiesRequest {
  const _FacilitiesRequest({required final  List<String> categories, this.lat, this.lng, this.city, this.radiusM = 15000, this.limit = 20, this.lang = Lang.en}): assert(categories.length > 0, 'At least one category key is required.'),assert((lat != null && lng != null) || city != null, 'Provide lat and lng, or a city.'),_categories = categories;
  factory _FacilitiesRequest.fromJson(Map<String, dynamic> json) => _$FacilitiesRequestFromJson(json);

 final  List<String> _categories;
@override List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override final  double? lat;
@override final  double? lng;
@override final  CityId? city;
@override@JsonKey() final  int radiusM;
@override@JsonKey() final  int limit;
@override@JsonKey() final  Lang lang;

/// Create a copy of FacilitiesRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FacilitiesRequestCopyWith<_FacilitiesRequest> get copyWith => __$FacilitiesRequestCopyWithImpl<_FacilitiesRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FacilitiesRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FacilitiesRequest&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.city, city) || other.city == city)&&(identical(other.radiusM, radiusM) || other.radiusM == radiusM)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.lang, lang) || other.lang == lang));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories),lat,lng,city,radiusM,limit,lang);

@override
String toString() {
  return 'FacilitiesRequest(categories: $categories, lat: $lat, lng: $lng, city: $city, radiusM: $radiusM, limit: $limit, lang: $lang)';
}


}

/// @nodoc
abstract mixin class _$FacilitiesRequestCopyWith<$Res> implements $FacilitiesRequestCopyWith<$Res> {
  factory _$FacilitiesRequestCopyWith(_FacilitiesRequest value, $Res Function(_FacilitiesRequest) _then) = __$FacilitiesRequestCopyWithImpl;
@override @useResult
$Res call({
 List<String> categories, double? lat, double? lng, CityId? city, int radiusM, int limit, Lang lang
});




}
/// @nodoc
class __$FacilitiesRequestCopyWithImpl<$Res>
    implements _$FacilitiesRequestCopyWith<$Res> {
  __$FacilitiesRequestCopyWithImpl(this._self, this._then);

  final _FacilitiesRequest _self;
  final $Res Function(_FacilitiesRequest) _then;

/// Create a copy of FacilitiesRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categories = null,Object? lat = freezed,Object? lng = freezed,Object? city = freezed,Object? radiusM = null,Object? limit = null,Object? lang = null,}) {
  return _then(_FacilitiesRequest(
categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as CityId?,radiusM: null == radiusM ? _self.radiusM : radiusM // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as Lang,
  ));
}


}


/// @nodoc
mixin _$Place {

/// 'g:<place id>', 'osm:<type>/<id>' or 'cur:<id>'.
 String get id; String get name; String? get address; double get lat; double get lng; int? get distanceM; bool? get openNow; String? get phone; String? get website;/// Deep link that opens this place in Google Maps.
 String? get mapsUrl; List<FacilityType> get facilityTypes;/// Which requested categories this place matched.
 List<String> get categoryKeys;/// Only when the source states it.
 List<MaterialCategory>? get acceptedMaterials; String? get acceptedNote; double? get rating; PlaceSource get source;
/// Create a copy of Place
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceCopyWith<Place> get copyWith => _$PlaceCopyWithImpl<Place>(this as Place, _$identity);

  /// Serializes this Place to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Place&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.openNow, openNow) || other.openNow == openNow)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.website, website) || other.website == website)&&(identical(other.mapsUrl, mapsUrl) || other.mapsUrl == mapsUrl)&&const DeepCollectionEquality().equals(other.facilityTypes, facilityTypes)&&const DeepCollectionEquality().equals(other.categoryKeys, categoryKeys)&&const DeepCollectionEquality().equals(other.acceptedMaterials, acceptedMaterials)&&(identical(other.acceptedNote, acceptedNote) || other.acceptedNote == acceptedNote)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,address,lat,lng,distanceM,openNow,phone,website,mapsUrl,const DeepCollectionEquality().hash(facilityTypes),const DeepCollectionEquality().hash(categoryKeys),const DeepCollectionEquality().hash(acceptedMaterials),acceptedNote,rating,source);

@override
String toString() {
  return 'Place(id: $id, name: $name, address: $address, lat: $lat, lng: $lng, distanceM: $distanceM, openNow: $openNow, phone: $phone, website: $website, mapsUrl: $mapsUrl, facilityTypes: $facilityTypes, categoryKeys: $categoryKeys, acceptedMaterials: $acceptedMaterials, acceptedNote: $acceptedNote, rating: $rating, source: $source)';
}


}

/// @nodoc
abstract mixin class $PlaceCopyWith<$Res>  {
  factory $PlaceCopyWith(Place value, $Res Function(Place) _then) = _$PlaceCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? address, double lat, double lng, int? distanceM, bool? openNow, String? phone, String? website, String? mapsUrl, List<FacilityType> facilityTypes, List<String> categoryKeys, List<MaterialCategory>? acceptedMaterials, String? acceptedNote, double? rating, PlaceSource source
});




}
/// @nodoc
class _$PlaceCopyWithImpl<$Res>
    implements $PlaceCopyWith<$Res> {
  _$PlaceCopyWithImpl(this._self, this._then);

  final Place _self;
  final $Res Function(Place) _then;

/// Create a copy of Place
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? address = freezed,Object? lat = null,Object? lng = null,Object? distanceM = freezed,Object? openNow = freezed,Object? phone = freezed,Object? website = freezed,Object? mapsUrl = freezed,Object? facilityTypes = null,Object? categoryKeys = null,Object? acceptedMaterials = freezed,Object? acceptedNote = freezed,Object? rating = freezed,Object? source = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,distanceM: freezed == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as int?,openNow: freezed == openNow ? _self.openNow : openNow // ignore: cast_nullable_to_non_nullable
as bool?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,mapsUrl: freezed == mapsUrl ? _self.mapsUrl : mapsUrl // ignore: cast_nullable_to_non_nullable
as String?,facilityTypes: null == facilityTypes ? _self.facilityTypes : facilityTypes // ignore: cast_nullable_to_non_nullable
as List<FacilityType>,categoryKeys: null == categoryKeys ? _self.categoryKeys : categoryKeys // ignore: cast_nullable_to_non_nullable
as List<String>,acceptedMaterials: freezed == acceptedMaterials ? _self.acceptedMaterials : acceptedMaterials // ignore: cast_nullable_to_non_nullable
as List<MaterialCategory>?,acceptedNote: freezed == acceptedNote ? _self.acceptedNote : acceptedNote // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PlaceSource,
  ));
}

}


/// Adds pattern-matching-related methods to [Place].
extension PlacePatterns on Place {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Place value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Place() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Place value)  $default,){
final _that = this;
switch (_that) {
case _Place():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Place value)?  $default,){
final _that = this;
switch (_that) {
case _Place() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? address,  double lat,  double lng,  int? distanceM,  bool? openNow,  String? phone,  String? website,  String? mapsUrl,  List<FacilityType> facilityTypes,  List<String> categoryKeys,  List<MaterialCategory>? acceptedMaterials,  String? acceptedNote,  double? rating,  PlaceSource source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Place() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.lat,_that.lng,_that.distanceM,_that.openNow,_that.phone,_that.website,_that.mapsUrl,_that.facilityTypes,_that.categoryKeys,_that.acceptedMaterials,_that.acceptedNote,_that.rating,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? address,  double lat,  double lng,  int? distanceM,  bool? openNow,  String? phone,  String? website,  String? mapsUrl,  List<FacilityType> facilityTypes,  List<String> categoryKeys,  List<MaterialCategory>? acceptedMaterials,  String? acceptedNote,  double? rating,  PlaceSource source)  $default,) {final _that = this;
switch (_that) {
case _Place():
return $default(_that.id,_that.name,_that.address,_that.lat,_that.lng,_that.distanceM,_that.openNow,_that.phone,_that.website,_that.mapsUrl,_that.facilityTypes,_that.categoryKeys,_that.acceptedMaterials,_that.acceptedNote,_that.rating,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? address,  double lat,  double lng,  int? distanceM,  bool? openNow,  String? phone,  String? website,  String? mapsUrl,  List<FacilityType> facilityTypes,  List<String> categoryKeys,  List<MaterialCategory>? acceptedMaterials,  String? acceptedNote,  double? rating,  PlaceSource source)?  $default,) {final _that = this;
switch (_that) {
case _Place() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.lat,_that.lng,_that.distanceM,_that.openNow,_that.phone,_that.website,_that.mapsUrl,_that.facilityTypes,_that.categoryKeys,_that.acceptedMaterials,_that.acceptedNote,_that.rating,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Place implements Place {
  const _Place({required this.id, required this.name, this.address, required this.lat, required this.lng, this.distanceM, this.openNow, this.phone, this.website, this.mapsUrl, required final  List<FacilityType> facilityTypes, required final  List<String> categoryKeys, final  List<MaterialCategory>? acceptedMaterials, this.acceptedNote, this.rating, required this.source}): _facilityTypes = facilityTypes,_categoryKeys = categoryKeys,_acceptedMaterials = acceptedMaterials;
  factory _Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);

/// 'g:<place id>', 'osm:<type>/<id>' or 'cur:<id>'.
@override final  String id;
@override final  String name;
@override final  String? address;
@override final  double lat;
@override final  double lng;
@override final  int? distanceM;
@override final  bool? openNow;
@override final  String? phone;
@override final  String? website;
/// Deep link that opens this place in Google Maps.
@override final  String? mapsUrl;
 final  List<FacilityType> _facilityTypes;
@override List<FacilityType> get facilityTypes {
  if (_facilityTypes is EqualUnmodifiableListView) return _facilityTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_facilityTypes);
}

/// Which requested categories this place matched.
 final  List<String> _categoryKeys;
/// Which requested categories this place matched.
@override List<String> get categoryKeys {
  if (_categoryKeys is EqualUnmodifiableListView) return _categoryKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryKeys);
}

/// Only when the source states it.
 final  List<MaterialCategory>? _acceptedMaterials;
/// Only when the source states it.
@override List<MaterialCategory>? get acceptedMaterials {
  final value = _acceptedMaterials;
  if (value == null) return null;
  if (_acceptedMaterials is EqualUnmodifiableListView) return _acceptedMaterials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? acceptedNote;
@override final  double? rating;
@override final  PlaceSource source;

/// Create a copy of Place
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceCopyWith<_Place> get copyWith => __$PlaceCopyWithImpl<_Place>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Place&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.openNow, openNow) || other.openNow == openNow)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.website, website) || other.website == website)&&(identical(other.mapsUrl, mapsUrl) || other.mapsUrl == mapsUrl)&&const DeepCollectionEquality().equals(other._facilityTypes, _facilityTypes)&&const DeepCollectionEquality().equals(other._categoryKeys, _categoryKeys)&&const DeepCollectionEquality().equals(other._acceptedMaterials, _acceptedMaterials)&&(identical(other.acceptedNote, acceptedNote) || other.acceptedNote == acceptedNote)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,address,lat,lng,distanceM,openNow,phone,website,mapsUrl,const DeepCollectionEquality().hash(_facilityTypes),const DeepCollectionEquality().hash(_categoryKeys),const DeepCollectionEquality().hash(_acceptedMaterials),acceptedNote,rating,source);

@override
String toString() {
  return 'Place(id: $id, name: $name, address: $address, lat: $lat, lng: $lng, distanceM: $distanceM, openNow: $openNow, phone: $phone, website: $website, mapsUrl: $mapsUrl, facilityTypes: $facilityTypes, categoryKeys: $categoryKeys, acceptedMaterials: $acceptedMaterials, acceptedNote: $acceptedNote, rating: $rating, source: $source)';
}


}

/// @nodoc
abstract mixin class _$PlaceCopyWith<$Res> implements $PlaceCopyWith<$Res> {
  factory _$PlaceCopyWith(_Place value, $Res Function(_Place) _then) = __$PlaceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? address, double lat, double lng, int? distanceM, bool? openNow, String? phone, String? website, String? mapsUrl, List<FacilityType> facilityTypes, List<String> categoryKeys, List<MaterialCategory>? acceptedMaterials, String? acceptedNote, double? rating, PlaceSource source
});




}
/// @nodoc
class __$PlaceCopyWithImpl<$Res>
    implements _$PlaceCopyWith<$Res> {
  __$PlaceCopyWithImpl(this._self, this._then);

  final _Place _self;
  final $Res Function(_Place) _then;

/// Create a copy of Place
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? address = freezed,Object? lat = null,Object? lng = null,Object? distanceM = freezed,Object? openNow = freezed,Object? phone = freezed,Object? website = freezed,Object? mapsUrl = freezed,Object? facilityTypes = null,Object? categoryKeys = null,Object? acceptedMaterials = freezed,Object? acceptedNote = freezed,Object? rating = freezed,Object? source = null,}) {
  return _then(_Place(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,distanceM: freezed == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as int?,openNow: freezed == openNow ? _self.openNow : openNow // ignore: cast_nullable_to_non_nullable
as bool?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,mapsUrl: freezed == mapsUrl ? _self.mapsUrl : mapsUrl // ignore: cast_nullable_to_non_nullable
as String?,facilityTypes: null == facilityTypes ? _self._facilityTypes : facilityTypes // ignore: cast_nullable_to_non_nullable
as List<FacilityType>,categoryKeys: null == categoryKeys ? _self._categoryKeys : categoryKeys // ignore: cast_nullable_to_non_nullable
as List<String>,acceptedMaterials: freezed == acceptedMaterials ? _self._acceptedMaterials : acceptedMaterials // ignore: cast_nullable_to_non_nullable
as List<MaterialCategory>?,acceptedNote: freezed == acceptedNote ? _self.acceptedNote : acceptedNote // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PlaceSource,
  ));
}


}


/// @nodoc
mixin _$FacilitiesResponse {

/// Sorted by distance, nearest first.
 List<Place> get places; GeoPoint get center;/// City name or 'Your location', localized.
 String get centerLabel; List<PlaceSource> get sourcesUsed;/// Localized note, e.g. when only OpenStreetMap data is available.
 String? get notice; Timings get timingsMs;
/// Create a copy of FacilitiesResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacilitiesResponseCopyWith<FacilitiesResponse> get copyWith => _$FacilitiesResponseCopyWithImpl<FacilitiesResponse>(this as FacilitiesResponse, _$identity);

  /// Serializes this FacilitiesResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FacilitiesResponse&&const DeepCollectionEquality().equals(other.places, places)&&(identical(other.center, center) || other.center == center)&&(identical(other.centerLabel, centerLabel) || other.centerLabel == centerLabel)&&const DeepCollectionEquality().equals(other.sourcesUsed, sourcesUsed)&&(identical(other.notice, notice) || other.notice == notice)&&const DeepCollectionEquality().equals(other.timingsMs, timingsMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(places),center,centerLabel,const DeepCollectionEquality().hash(sourcesUsed),notice,const DeepCollectionEquality().hash(timingsMs));

@override
String toString() {
  return 'FacilitiesResponse(places: $places, center: $center, centerLabel: $centerLabel, sourcesUsed: $sourcesUsed, notice: $notice, timingsMs: $timingsMs)';
}


}

/// @nodoc
abstract mixin class $FacilitiesResponseCopyWith<$Res>  {
  factory $FacilitiesResponseCopyWith(FacilitiesResponse value, $Res Function(FacilitiesResponse) _then) = _$FacilitiesResponseCopyWithImpl;
@useResult
$Res call({
 List<Place> places, GeoPoint center, String centerLabel, List<PlaceSource> sourcesUsed, String? notice, Timings timingsMs
});


$GeoPointCopyWith<$Res> get center;

}
/// @nodoc
class _$FacilitiesResponseCopyWithImpl<$Res>
    implements $FacilitiesResponseCopyWith<$Res> {
  _$FacilitiesResponseCopyWithImpl(this._self, this._then);

  final FacilitiesResponse _self;
  final $Res Function(FacilitiesResponse) _then;

/// Create a copy of FacilitiesResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? places = null,Object? center = null,Object? centerLabel = null,Object? sourcesUsed = null,Object? notice = freezed,Object? timingsMs = null,}) {
  return _then(_self.copyWith(
places: null == places ? _self.places : places // ignore: cast_nullable_to_non_nullable
as List<Place>,center: null == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as GeoPoint,centerLabel: null == centerLabel ? _self.centerLabel : centerLabel // ignore: cast_nullable_to_non_nullable
as String,sourcesUsed: null == sourcesUsed ? _self.sourcesUsed : sourcesUsed // ignore: cast_nullable_to_non_nullable
as List<PlaceSource>,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as String?,timingsMs: null == timingsMs ? _self.timingsMs : timingsMs // ignore: cast_nullable_to_non_nullable
as Timings,
  ));
}
/// Create a copy of FacilitiesResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoPointCopyWith<$Res> get center {
  
  return $GeoPointCopyWith<$Res>(_self.center, (value) {
    return _then(_self.copyWith(center: value));
  });
}
}


/// Adds pattern-matching-related methods to [FacilitiesResponse].
extension FacilitiesResponsePatterns on FacilitiesResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FacilitiesResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FacilitiesResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FacilitiesResponse value)  $default,){
final _that = this;
switch (_that) {
case _FacilitiesResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FacilitiesResponse value)?  $default,){
final _that = this;
switch (_that) {
case _FacilitiesResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Place> places,  GeoPoint center,  String centerLabel,  List<PlaceSource> sourcesUsed,  String? notice,  Timings timingsMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FacilitiesResponse() when $default != null:
return $default(_that.places,_that.center,_that.centerLabel,_that.sourcesUsed,_that.notice,_that.timingsMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Place> places,  GeoPoint center,  String centerLabel,  List<PlaceSource> sourcesUsed,  String? notice,  Timings timingsMs)  $default,) {final _that = this;
switch (_that) {
case _FacilitiesResponse():
return $default(_that.places,_that.center,_that.centerLabel,_that.sourcesUsed,_that.notice,_that.timingsMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Place> places,  GeoPoint center,  String centerLabel,  List<PlaceSource> sourcesUsed,  String? notice,  Timings timingsMs)?  $default,) {final _that = this;
switch (_that) {
case _FacilitiesResponse() when $default != null:
return $default(_that.places,_that.center,_that.centerLabel,_that.sourcesUsed,_that.notice,_that.timingsMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FacilitiesResponse implements FacilitiesResponse {
  const _FacilitiesResponse({required final  List<Place> places, required this.center, required this.centerLabel, required final  List<PlaceSource> sourcesUsed, this.notice, final  Timings timingsMs = const <String, int>{}}): _places = places,_sourcesUsed = sourcesUsed,_timingsMs = timingsMs;
  factory _FacilitiesResponse.fromJson(Map<String, dynamic> json) => _$FacilitiesResponseFromJson(json);

/// Sorted by distance, nearest first.
 final  List<Place> _places;
/// Sorted by distance, nearest first.
@override List<Place> get places {
  if (_places is EqualUnmodifiableListView) return _places;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_places);
}

@override final  GeoPoint center;
/// City name or 'Your location', localized.
@override final  String centerLabel;
 final  List<PlaceSource> _sourcesUsed;
@override List<PlaceSource> get sourcesUsed {
  if (_sourcesUsed is EqualUnmodifiableListView) return _sourcesUsed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sourcesUsed);
}

/// Localized note, e.g. when only OpenStreetMap data is available.
@override final  String? notice;
 final  Timings _timingsMs;
@override@JsonKey() Timings get timingsMs {
  if (_timingsMs is EqualUnmodifiableMapView) return _timingsMs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_timingsMs);
}


/// Create a copy of FacilitiesResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FacilitiesResponseCopyWith<_FacilitiesResponse> get copyWith => __$FacilitiesResponseCopyWithImpl<_FacilitiesResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FacilitiesResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FacilitiesResponse&&const DeepCollectionEquality().equals(other._places, _places)&&(identical(other.center, center) || other.center == center)&&(identical(other.centerLabel, centerLabel) || other.centerLabel == centerLabel)&&const DeepCollectionEquality().equals(other._sourcesUsed, _sourcesUsed)&&(identical(other.notice, notice) || other.notice == notice)&&const DeepCollectionEquality().equals(other._timingsMs, _timingsMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_places),center,centerLabel,const DeepCollectionEquality().hash(_sourcesUsed),notice,const DeepCollectionEquality().hash(_timingsMs));

@override
String toString() {
  return 'FacilitiesResponse(places: $places, center: $center, centerLabel: $centerLabel, sourcesUsed: $sourcesUsed, notice: $notice, timingsMs: $timingsMs)';
}


}

/// @nodoc
abstract mixin class _$FacilitiesResponseCopyWith<$Res> implements $FacilitiesResponseCopyWith<$Res> {
  factory _$FacilitiesResponseCopyWith(_FacilitiesResponse value, $Res Function(_FacilitiesResponse) _then) = __$FacilitiesResponseCopyWithImpl;
@override @useResult
$Res call({
 List<Place> places, GeoPoint center, String centerLabel, List<PlaceSource> sourcesUsed, String? notice, Timings timingsMs
});


@override $GeoPointCopyWith<$Res> get center;

}
/// @nodoc
class __$FacilitiesResponseCopyWithImpl<$Res>
    implements _$FacilitiesResponseCopyWith<$Res> {
  __$FacilitiesResponseCopyWithImpl(this._self, this._then);

  final _FacilitiesResponse _self;
  final $Res Function(_FacilitiesResponse) _then;

/// Create a copy of FacilitiesResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? places = null,Object? center = null,Object? centerLabel = null,Object? sourcesUsed = null,Object? notice = freezed,Object? timingsMs = null,}) {
  return _then(_FacilitiesResponse(
places: null == places ? _self._places : places // ignore: cast_nullable_to_non_nullable
as List<Place>,center: null == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as GeoPoint,centerLabel: null == centerLabel ? _self.centerLabel : centerLabel // ignore: cast_nullable_to_non_nullable
as String,sourcesUsed: null == sourcesUsed ? _self._sourcesUsed : sourcesUsed // ignore: cast_nullable_to_non_nullable
as List<PlaceSource>,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as String?,timingsMs: null == timingsMs ? _self._timingsMs : timingsMs // ignore: cast_nullable_to_non_nullable
as Timings,
  ));
}

/// Create a copy of FacilitiesResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoPointCopyWith<$Res> get center {
  
  return $GeoPointCopyWith<$Res>(_self.center, (value) {
    return _then(_self.copyWith(center: value));
  });
}
}


/// @nodoc
mixin _$FacilityCategoriesResponse {

 List<FacilityCategory> get categories; Lang get lang;
/// Create a copy of FacilityCategoriesResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacilityCategoriesResponseCopyWith<FacilityCategoriesResponse> get copyWith => _$FacilityCategoriesResponseCopyWithImpl<FacilityCategoriesResponse>(this as FacilityCategoriesResponse, _$identity);

  /// Serializes this FacilityCategoriesResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FacilityCategoriesResponse&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.lang, lang) || other.lang == lang));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(categories),lang);

@override
String toString() {
  return 'FacilityCategoriesResponse(categories: $categories, lang: $lang)';
}


}

/// @nodoc
abstract mixin class $FacilityCategoriesResponseCopyWith<$Res>  {
  factory $FacilityCategoriesResponseCopyWith(FacilityCategoriesResponse value, $Res Function(FacilityCategoriesResponse) _then) = _$FacilityCategoriesResponseCopyWithImpl;
@useResult
$Res call({
 List<FacilityCategory> categories, Lang lang
});




}
/// @nodoc
class _$FacilityCategoriesResponseCopyWithImpl<$Res>
    implements $FacilityCategoriesResponseCopyWith<$Res> {
  _$FacilityCategoriesResponseCopyWithImpl(this._self, this._then);

  final FacilityCategoriesResponse _self;
  final $Res Function(FacilityCategoriesResponse) _then;

/// Create a copy of FacilityCategoriesResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categories = null,Object? lang = null,}) {
  return _then(_self.copyWith(
categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<FacilityCategory>,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as Lang,
  ));
}

}


/// Adds pattern-matching-related methods to [FacilityCategoriesResponse].
extension FacilityCategoriesResponsePatterns on FacilityCategoriesResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FacilityCategoriesResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FacilityCategoriesResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FacilityCategoriesResponse value)  $default,){
final _that = this;
switch (_that) {
case _FacilityCategoriesResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FacilityCategoriesResponse value)?  $default,){
final _that = this;
switch (_that) {
case _FacilityCategoriesResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FacilityCategory> categories,  Lang lang)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FacilityCategoriesResponse() when $default != null:
return $default(_that.categories,_that.lang);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FacilityCategory> categories,  Lang lang)  $default,) {final _that = this;
switch (_that) {
case _FacilityCategoriesResponse():
return $default(_that.categories,_that.lang);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FacilityCategory> categories,  Lang lang)?  $default,) {final _that = this;
switch (_that) {
case _FacilityCategoriesResponse() when $default != null:
return $default(_that.categories,_that.lang);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FacilityCategoriesResponse implements FacilityCategoriesResponse {
  const _FacilityCategoriesResponse({required final  List<FacilityCategory> categories, required this.lang}): _categories = categories;
  factory _FacilityCategoriesResponse.fromJson(Map<String, dynamic> json) => _$FacilityCategoriesResponseFromJson(json);

 final  List<FacilityCategory> _categories;
@override List<FacilityCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override final  Lang lang;

/// Create a copy of FacilityCategoriesResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FacilityCategoriesResponseCopyWith<_FacilityCategoriesResponse> get copyWith => __$FacilityCategoriesResponseCopyWithImpl<_FacilityCategoriesResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FacilityCategoriesResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FacilityCategoriesResponse&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.lang, lang) || other.lang == lang));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories),lang);

@override
String toString() {
  return 'FacilityCategoriesResponse(categories: $categories, lang: $lang)';
}


}

/// @nodoc
abstract mixin class _$FacilityCategoriesResponseCopyWith<$Res> implements $FacilityCategoriesResponseCopyWith<$Res> {
  factory _$FacilityCategoriesResponseCopyWith(_FacilityCategoriesResponse value, $Res Function(_FacilityCategoriesResponse) _then) = __$FacilityCategoriesResponseCopyWithImpl;
@override @useResult
$Res call({
 List<FacilityCategory> categories, Lang lang
});




}
/// @nodoc
class __$FacilityCategoriesResponseCopyWithImpl<$Res>
    implements _$FacilityCategoriesResponseCopyWith<$Res> {
  __$FacilityCategoriesResponseCopyWithImpl(this._self, this._then);

  final _FacilityCategoriesResponse _self;
  final $Res Function(_FacilityCategoriesResponse) _then;

/// Create a copy of FacilityCategoriesResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categories = null,Object? lang = null,}) {
  return _then(_FacilityCategoriesResponse(
categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<FacilityCategory>,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as Lang,
  ));
}


}

// dart format on
