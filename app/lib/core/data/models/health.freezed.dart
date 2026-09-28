// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HealthResponse {

 HealthStatus get status; String get appName; String get version;/// Role -> model id, e.g. {'vision': 'gemini-3.6-flash'}.
 Map<String, String> get models; bool get aiConfigured; int get knowledgeDocs; bool get ragReady; bool get placesGoogle; bool get placesOsm; int get uptimeS;
/// Create a copy of HealthResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthResponseCopyWith<HealthResponse> get copyWith => _$HealthResponseCopyWithImpl<HealthResponse>(this as HealthResponse, _$identity);

  /// Serializes this HealthResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthResponse&&(identical(other.status, status) || other.status == status)&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.models, models)&&(identical(other.aiConfigured, aiConfigured) || other.aiConfigured == aiConfigured)&&(identical(other.knowledgeDocs, knowledgeDocs) || other.knowledgeDocs == knowledgeDocs)&&(identical(other.ragReady, ragReady) || other.ragReady == ragReady)&&(identical(other.placesGoogle, placesGoogle) || other.placesGoogle == placesGoogle)&&(identical(other.placesOsm, placesOsm) || other.placesOsm == placesOsm)&&(identical(other.uptimeS, uptimeS) || other.uptimeS == uptimeS));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,appName,version,const DeepCollectionEquality().hash(models),aiConfigured,knowledgeDocs,ragReady,placesGoogle,placesOsm,uptimeS);

@override
String toString() {
  return 'HealthResponse(status: $status, appName: $appName, version: $version, models: $models, aiConfigured: $aiConfigured, knowledgeDocs: $knowledgeDocs, ragReady: $ragReady, placesGoogle: $placesGoogle, placesOsm: $placesOsm, uptimeS: $uptimeS)';
}


}

/// @nodoc
abstract mixin class $HealthResponseCopyWith<$Res>  {
  factory $HealthResponseCopyWith(HealthResponse value, $Res Function(HealthResponse) _then) = _$HealthResponseCopyWithImpl;
@useResult
$Res call({
 HealthStatus status, String appName, String version, Map<String, String> models, bool aiConfigured, int knowledgeDocs, bool ragReady, bool placesGoogle, bool placesOsm, int uptimeS
});




}
/// @nodoc
class _$HealthResponseCopyWithImpl<$Res>
    implements $HealthResponseCopyWith<$Res> {
  _$HealthResponseCopyWithImpl(this._self, this._then);

  final HealthResponse _self;
  final $Res Function(HealthResponse) _then;

/// Create a copy of HealthResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? appName = null,Object? version = null,Object? models = null,Object? aiConfigured = null,Object? knowledgeDocs = null,Object? ragReady = null,Object? placesGoogle = null,Object? placesOsm = null,Object? uptimeS = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HealthStatus,appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as Map<String, String>,aiConfigured: null == aiConfigured ? _self.aiConfigured : aiConfigured // ignore: cast_nullable_to_non_nullable
as bool,knowledgeDocs: null == knowledgeDocs ? _self.knowledgeDocs : knowledgeDocs // ignore: cast_nullable_to_non_nullable
as int,ragReady: null == ragReady ? _self.ragReady : ragReady // ignore: cast_nullable_to_non_nullable
as bool,placesGoogle: null == placesGoogle ? _self.placesGoogle : placesGoogle // ignore: cast_nullable_to_non_nullable
as bool,placesOsm: null == placesOsm ? _self.placesOsm : placesOsm // ignore: cast_nullable_to_non_nullable
as bool,uptimeS: null == uptimeS ? _self.uptimeS : uptimeS // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthResponse].
extension HealthResponsePatterns on HealthResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthResponse value)  $default,){
final _that = this;
switch (_that) {
case _HealthResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthResponse value)?  $default,){
final _that = this;
switch (_that) {
case _HealthResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HealthStatus status,  String appName,  String version,  Map<String, String> models,  bool aiConfigured,  int knowledgeDocs,  bool ragReady,  bool placesGoogle,  bool placesOsm,  int uptimeS)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthResponse() when $default != null:
return $default(_that.status,_that.appName,_that.version,_that.models,_that.aiConfigured,_that.knowledgeDocs,_that.ragReady,_that.placesGoogle,_that.placesOsm,_that.uptimeS);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HealthStatus status,  String appName,  String version,  Map<String, String> models,  bool aiConfigured,  int knowledgeDocs,  bool ragReady,  bool placesGoogle,  bool placesOsm,  int uptimeS)  $default,) {final _that = this;
switch (_that) {
case _HealthResponse():
return $default(_that.status,_that.appName,_that.version,_that.models,_that.aiConfigured,_that.knowledgeDocs,_that.ragReady,_that.placesGoogle,_that.placesOsm,_that.uptimeS);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HealthStatus status,  String appName,  String version,  Map<String, String> models,  bool aiConfigured,  int knowledgeDocs,  bool ragReady,  bool placesGoogle,  bool placesOsm,  int uptimeS)?  $default,) {final _that = this;
switch (_that) {
case _HealthResponse() when $default != null:
return $default(_that.status,_that.appName,_that.version,_that.models,_that.aiConfigured,_that.knowledgeDocs,_that.ragReady,_that.placesGoogle,_that.placesOsm,_that.uptimeS);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthResponse implements HealthResponse {
  const _HealthResponse({required this.status, required this.appName, required this.version, required final  Map<String, String> models, required this.aiConfigured, required this.knowledgeDocs, required this.ragReady, required this.placesGoogle, required this.placesOsm, required this.uptimeS}): _models = models;
  factory _HealthResponse.fromJson(Map<String, dynamic> json) => _$HealthResponseFromJson(json);

@override final  HealthStatus status;
@override final  String appName;
@override final  String version;
/// Role -> model id, e.g. {'vision': 'gemini-3.6-flash'}.
 final  Map<String, String> _models;
/// Role -> model id, e.g. {'vision': 'gemini-3.6-flash'}.
@override Map<String, String> get models {
  if (_models is EqualUnmodifiableMapView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_models);
}

@override final  bool aiConfigured;
@override final  int knowledgeDocs;
@override final  bool ragReady;
@override final  bool placesGoogle;
@override final  bool placesOsm;
@override final  int uptimeS;

/// Create a copy of HealthResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthResponseCopyWith<_HealthResponse> get copyWith => __$HealthResponseCopyWithImpl<_HealthResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthResponse&&(identical(other.status, status) || other.status == status)&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other._models, _models)&&(identical(other.aiConfigured, aiConfigured) || other.aiConfigured == aiConfigured)&&(identical(other.knowledgeDocs, knowledgeDocs) || other.knowledgeDocs == knowledgeDocs)&&(identical(other.ragReady, ragReady) || other.ragReady == ragReady)&&(identical(other.placesGoogle, placesGoogle) || other.placesGoogle == placesGoogle)&&(identical(other.placesOsm, placesOsm) || other.placesOsm == placesOsm)&&(identical(other.uptimeS, uptimeS) || other.uptimeS == uptimeS));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,appName,version,const DeepCollectionEquality().hash(_models),aiConfigured,knowledgeDocs,ragReady,placesGoogle,placesOsm,uptimeS);

@override
String toString() {
  return 'HealthResponse(status: $status, appName: $appName, version: $version, models: $models, aiConfigured: $aiConfigured, knowledgeDocs: $knowledgeDocs, ragReady: $ragReady, placesGoogle: $placesGoogle, placesOsm: $placesOsm, uptimeS: $uptimeS)';
}


}

/// @nodoc
abstract mixin class _$HealthResponseCopyWith<$Res> implements $HealthResponseCopyWith<$Res> {
  factory _$HealthResponseCopyWith(_HealthResponse value, $Res Function(_HealthResponse) _then) = __$HealthResponseCopyWithImpl;
@override @useResult
$Res call({
 HealthStatus status, String appName, String version, Map<String, String> models, bool aiConfigured, int knowledgeDocs, bool ragReady, bool placesGoogle, bool placesOsm, int uptimeS
});




}
/// @nodoc
class __$HealthResponseCopyWithImpl<$Res>
    implements _$HealthResponseCopyWith<$Res> {
  __$HealthResponseCopyWithImpl(this._self, this._then);

  final _HealthResponse _self;
  final $Res Function(_HealthResponse) _then;

/// Create a copy of HealthResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? appName = null,Object? version = null,Object? models = null,Object? aiConfigured = null,Object? knowledgeDocs = null,Object? ragReady = null,Object? placesGoogle = null,Object? placesOsm = null,Object? uptimeS = null,}) {
  return _then(_HealthResponse(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HealthStatus,appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as Map<String, String>,aiConfigured: null == aiConfigured ? _self.aiConfigured : aiConfigured // ignore: cast_nullable_to_non_nullable
as bool,knowledgeDocs: null == knowledgeDocs ? _self.knowledgeDocs : knowledgeDocs // ignore: cast_nullable_to_non_nullable
as int,ragReady: null == ragReady ? _self.ragReady : ragReady // ignore: cast_nullable_to_non_nullable
as bool,placesGoogle: null == placesGoogle ? _self.placesGoogle : placesGoogle // ignore: cast_nullable_to_non_nullable
as bool,placesOsm: null == placesOsm ? _self.placesOsm : placesOsm // ignore: cast_nullable_to_non_nullable
as bool,uptimeS: null == uptimeS ? _self.uptimeS : uptimeS // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
