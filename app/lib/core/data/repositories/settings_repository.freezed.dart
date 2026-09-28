// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppSettings {

 LocalePref get locale; ThemeMode get themeMode; SkillLevel get skill; List<ToolId> get tools; bool get onboardingDone; LocationMode? get locationMode; CityId? get city;/// Runtime backend URL override from Settings; null uses the build default.
 String? get apiBaseUrl;/// Start tutorials in hands-free mode.
 bool get handsFree;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.skill, skill) || other.skill == skill)&&const DeepCollectionEquality().equals(other.tools, tools)&&(identical(other.onboardingDone, onboardingDone) || other.onboardingDone == onboardingDone)&&(identical(other.locationMode, locationMode) || other.locationMode == locationMode)&&(identical(other.city, city) || other.city == city)&&(identical(other.apiBaseUrl, apiBaseUrl) || other.apiBaseUrl == apiBaseUrl)&&(identical(other.handsFree, handsFree) || other.handsFree == handsFree));
}


@override
int get hashCode => Object.hash(runtimeType,locale,themeMode,skill,const DeepCollectionEquality().hash(tools),onboardingDone,locationMode,city,apiBaseUrl,handsFree);

@override
String toString() {
  return 'AppSettings(locale: $locale, themeMode: $themeMode, skill: $skill, tools: $tools, onboardingDone: $onboardingDone, locationMode: $locationMode, city: $city, apiBaseUrl: $apiBaseUrl, handsFree: $handsFree)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 LocalePref locale, ThemeMode themeMode, SkillLevel skill, List<ToolId> tools, bool onboardingDone, LocationMode? locationMode, CityId? city, String? apiBaseUrl, bool handsFree
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = null,Object? themeMode = null,Object? skill = null,Object? tools = null,Object? onboardingDone = null,Object? locationMode = freezed,Object? city = freezed,Object? apiBaseUrl = freezed,Object? handsFree = null,}) {
  return _then(_self.copyWith(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as LocalePref,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,skill: null == skill ? _self.skill : skill // ignore: cast_nullable_to_non_nullable
as SkillLevel,tools: null == tools ? _self.tools : tools // ignore: cast_nullable_to_non_nullable
as List<ToolId>,onboardingDone: null == onboardingDone ? _self.onboardingDone : onboardingDone // ignore: cast_nullable_to_non_nullable
as bool,locationMode: freezed == locationMode ? _self.locationMode : locationMode // ignore: cast_nullable_to_non_nullable
as LocationMode?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as CityId?,apiBaseUrl: freezed == apiBaseUrl ? _self.apiBaseUrl : apiBaseUrl // ignore: cast_nullable_to_non_nullable
as String?,handsFree: null == handsFree ? _self.handsFree : handsFree // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalePref locale,  ThemeMode themeMode,  SkillLevel skill,  List<ToolId> tools,  bool onboardingDone,  LocationMode? locationMode,  CityId? city,  String? apiBaseUrl,  bool handsFree)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.locale,_that.themeMode,_that.skill,_that.tools,_that.onboardingDone,_that.locationMode,_that.city,_that.apiBaseUrl,_that.handsFree);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalePref locale,  ThemeMode themeMode,  SkillLevel skill,  List<ToolId> tools,  bool onboardingDone,  LocationMode? locationMode,  CityId? city,  String? apiBaseUrl,  bool handsFree)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.locale,_that.themeMode,_that.skill,_that.tools,_that.onboardingDone,_that.locationMode,_that.city,_that.apiBaseUrl,_that.handsFree);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalePref locale,  ThemeMode themeMode,  SkillLevel skill,  List<ToolId> tools,  bool onboardingDone,  LocationMode? locationMode,  CityId? city,  String? apiBaseUrl,  bool handsFree)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.locale,_that.themeMode,_that.skill,_that.tools,_that.onboardingDone,_that.locationMode,_that.city,_that.apiBaseUrl,_that.handsFree);case _:
  return null;

}
}

}

/// @nodoc


class _AppSettings implements AppSettings {
  const _AppSettings({this.locale = LocalePref.system, this.themeMode = ThemeMode.system, this.skill = SkillLevel.beginner, final  List<ToolId> tools = const <ToolId>[], this.onboardingDone = false, this.locationMode, this.city, this.apiBaseUrl, this.handsFree = false}): _tools = tools;
  

@override@JsonKey() final  LocalePref locale;
@override@JsonKey() final  ThemeMode themeMode;
@override@JsonKey() final  SkillLevel skill;
 final  List<ToolId> _tools;
@override@JsonKey() List<ToolId> get tools {
  if (_tools is EqualUnmodifiableListView) return _tools;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tools);
}

@override@JsonKey() final  bool onboardingDone;
@override final  LocationMode? locationMode;
@override final  CityId? city;
/// Runtime backend URL override from Settings; null uses the build default.
@override final  String? apiBaseUrl;
/// Start tutorials in hands-free mode.
@override@JsonKey() final  bool handsFree;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.skill, skill) || other.skill == skill)&&const DeepCollectionEquality().equals(other._tools, _tools)&&(identical(other.onboardingDone, onboardingDone) || other.onboardingDone == onboardingDone)&&(identical(other.locationMode, locationMode) || other.locationMode == locationMode)&&(identical(other.city, city) || other.city == city)&&(identical(other.apiBaseUrl, apiBaseUrl) || other.apiBaseUrl == apiBaseUrl)&&(identical(other.handsFree, handsFree) || other.handsFree == handsFree));
}


@override
int get hashCode => Object.hash(runtimeType,locale,themeMode,skill,const DeepCollectionEquality().hash(_tools),onboardingDone,locationMode,city,apiBaseUrl,handsFree);

@override
String toString() {
  return 'AppSettings(locale: $locale, themeMode: $themeMode, skill: $skill, tools: $tools, onboardingDone: $onboardingDone, locationMode: $locationMode, city: $city, apiBaseUrl: $apiBaseUrl, handsFree: $handsFree)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 LocalePref locale, ThemeMode themeMode, SkillLevel skill, List<ToolId> tools, bool onboardingDone, LocationMode? locationMode, CityId? city, String? apiBaseUrl, bool handsFree
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = null,Object? themeMode = null,Object? skill = null,Object? tools = null,Object? onboardingDone = null,Object? locationMode = freezed,Object? city = freezed,Object? apiBaseUrl = freezed,Object? handsFree = null,}) {
  return _then(_AppSettings(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as LocalePref,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,skill: null == skill ? _self.skill : skill // ignore: cast_nullable_to_non_nullable
as SkillLevel,tools: null == tools ? _self._tools : tools // ignore: cast_nullable_to_non_nullable
as List<ToolId>,onboardingDone: null == onboardingDone ? _self.onboardingDone : onboardingDone // ignore: cast_nullable_to_non_nullable
as bool,locationMode: freezed == locationMode ? _self.locationMode : locationMode // ignore: cast_nullable_to_non_nullable
as LocationMode?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as CityId?,apiBaseUrl: freezed == apiBaseUrl ? _self.apiBaseUrl : apiBaseUrl // ignore: cast_nullable_to_non_nullable
as String?,handsFree: null == handsFree ? _self.handsFree : handsFree // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
