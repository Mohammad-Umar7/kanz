// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generated_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GeneratedImageState {

 ImageStatus get status;/// Absolute URL on the backend.
 String? get url;/// Copy in the documents directory.
 String? get localPath; ApiException? get error;
/// Create a copy of GeneratedImageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneratedImageStateCopyWith<GeneratedImageState> get copyWith => _$GeneratedImageStateCopyWithImpl<GeneratedImageState>(this as GeneratedImageState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneratedImageState&&(identical(other.status, status) || other.status == status)&&(identical(other.url, url) || other.url == url)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,url,localPath,error);

@override
String toString() {
  return 'GeneratedImageState(status: $status, url: $url, localPath: $localPath, error: $error)';
}


}

/// @nodoc
abstract mixin class $GeneratedImageStateCopyWith<$Res>  {
  factory $GeneratedImageStateCopyWith(GeneratedImageState value, $Res Function(GeneratedImageState) _then) = _$GeneratedImageStateCopyWithImpl;
@useResult
$Res call({
 ImageStatus status, String? url, String? localPath, ApiException? error
});




}
/// @nodoc
class _$GeneratedImageStateCopyWithImpl<$Res>
    implements $GeneratedImageStateCopyWith<$Res> {
  _$GeneratedImageStateCopyWithImpl(this._self, this._then);

  final GeneratedImageState _self;
  final $Res Function(GeneratedImageState) _then;

/// Create a copy of GeneratedImageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? url = freezed,Object? localPath = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ImageStatus,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiException?,
  ));
}

}


/// Adds pattern-matching-related methods to [GeneratedImageState].
extension GeneratedImageStatePatterns on GeneratedImageState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeneratedImageState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeneratedImageState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeneratedImageState value)  $default,){
final _that = this;
switch (_that) {
case _GeneratedImageState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeneratedImageState value)?  $default,){
final _that = this;
switch (_that) {
case _GeneratedImageState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ImageStatus status,  String? url,  String? localPath,  ApiException? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeneratedImageState() when $default != null:
return $default(_that.status,_that.url,_that.localPath,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ImageStatus status,  String? url,  String? localPath,  ApiException? error)  $default,) {final _that = this;
switch (_that) {
case _GeneratedImageState():
return $default(_that.status,_that.url,_that.localPath,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ImageStatus status,  String? url,  String? localPath,  ApiException? error)?  $default,) {final _that = this;
switch (_that) {
case _GeneratedImageState() when $default != null:
return $default(_that.status,_that.url,_that.localPath,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GeneratedImageState extends GeneratedImageState {
  const _GeneratedImageState({this.status = ImageStatus.idle, this.url, this.localPath, this.error}): super._();
  

@override@JsonKey() final  ImageStatus status;
/// Absolute URL on the backend.
@override final  String? url;
/// Copy in the documents directory.
@override final  String? localPath;
@override final  ApiException? error;

/// Create a copy of GeneratedImageState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneratedImageStateCopyWith<_GeneratedImageState> get copyWith => __$GeneratedImageStateCopyWithImpl<_GeneratedImageState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneratedImageState&&(identical(other.status, status) || other.status == status)&&(identical(other.url, url) || other.url == url)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,url,localPath,error);

@override
String toString() {
  return 'GeneratedImageState(status: $status, url: $url, localPath: $localPath, error: $error)';
}


}

/// @nodoc
abstract mixin class _$GeneratedImageStateCopyWith<$Res> implements $GeneratedImageStateCopyWith<$Res> {
  factory _$GeneratedImageStateCopyWith(_GeneratedImageState value, $Res Function(_GeneratedImageState) _then) = __$GeneratedImageStateCopyWithImpl;
@override @useResult
$Res call({
 ImageStatus status, String? url, String? localPath, ApiException? error
});




}
/// @nodoc
class __$GeneratedImageStateCopyWithImpl<$Res>
    implements _$GeneratedImageStateCopyWith<$Res> {
  __$GeneratedImageStateCopyWithImpl(this._self, this._then);

  final _GeneratedImageState _self;
  final $Res Function(_GeneratedImageState) _then;

/// Create a copy of GeneratedImageState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? url = freezed,Object? localPath = freezed,Object? error = freezed,}) {
  return _then(_GeneratedImageState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ImageStatus,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiException?,
  ));
}


}

// dart format on
