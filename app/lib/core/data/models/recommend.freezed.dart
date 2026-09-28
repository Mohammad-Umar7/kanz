// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommend.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecommendRequest {

 String get imageId;/// The analysis, possibly corrected by the user (`user_corrected: true`).
 Analysis get analysis; Profile get profile;/// Item to focus ideas on; the backend defaults to `primary_item_id`.
 String? get focusItemId;
/// Create a copy of RecommendRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendRequestCopyWith<RecommendRequest> get copyWith => _$RecommendRequestCopyWithImpl<RecommendRequest>(this as RecommendRequest, _$identity);

  /// Serializes this RecommendRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendRequest&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.analysis, analysis) || other.analysis == analysis)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.focusItemId, focusItemId) || other.focusItemId == focusItemId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId,analysis,profile,focusItemId);

@override
String toString() {
  return 'RecommendRequest(imageId: $imageId, analysis: $analysis, profile: $profile, focusItemId: $focusItemId)';
}


}

/// @nodoc
abstract mixin class $RecommendRequestCopyWith<$Res>  {
  factory $RecommendRequestCopyWith(RecommendRequest value, $Res Function(RecommendRequest) _then) = _$RecommendRequestCopyWithImpl;
@useResult
$Res call({
 String imageId, Analysis analysis, Profile profile, String? focusItemId
});


$AnalysisCopyWith<$Res> get analysis;$ProfileCopyWith<$Res> get profile;

}
/// @nodoc
class _$RecommendRequestCopyWithImpl<$Res>
    implements $RecommendRequestCopyWith<$Res> {
  _$RecommendRequestCopyWithImpl(this._self, this._then);

  final RecommendRequest _self;
  final $Res Function(RecommendRequest) _then;

/// Create a copy of RecommendRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imageId = null,Object? analysis = null,Object? profile = null,Object? focusItemId = freezed,}) {
  return _then(_self.copyWith(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,analysis: null == analysis ? _self.analysis : analysis // ignore: cast_nullable_to_non_nullable
as Analysis,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile,focusItemId: freezed == focusItemId ? _self.focusItemId : focusItemId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RecommendRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalysisCopyWith<$Res> get analysis {
  
  return $AnalysisCopyWith<$Res>(_self.analysis, (value) {
    return _then(_self.copyWith(analysis: value));
  });
}/// Create a copy of RecommendRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res> get profile {
  
  return $ProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecommendRequest].
extension RecommendRequestPatterns on RecommendRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendRequest value)  $default,){
final _that = this;
switch (_that) {
case _RecommendRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendRequest value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String imageId,  Analysis analysis,  Profile profile,  String? focusItemId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendRequest() when $default != null:
return $default(_that.imageId,_that.analysis,_that.profile,_that.focusItemId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String imageId,  Analysis analysis,  Profile profile,  String? focusItemId)  $default,) {final _that = this;
switch (_that) {
case _RecommendRequest():
return $default(_that.imageId,_that.analysis,_that.profile,_that.focusItemId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String imageId,  Analysis analysis,  Profile profile,  String? focusItemId)?  $default,) {final _that = this;
switch (_that) {
case _RecommendRequest() when $default != null:
return $default(_that.imageId,_that.analysis,_that.profile,_that.focusItemId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecommendRequest implements RecommendRequest {
  const _RecommendRequest({required this.imageId, required this.analysis, this.profile = const Profile(), this.focusItemId});
  factory _RecommendRequest.fromJson(Map<String, dynamic> json) => _$RecommendRequestFromJson(json);

@override final  String imageId;
/// The analysis, possibly corrected by the user (`user_corrected: true`).
@override final  Analysis analysis;
@override@JsonKey() final  Profile profile;
/// Item to focus ideas on; the backend defaults to `primary_item_id`.
@override final  String? focusItemId;

/// Create a copy of RecommendRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendRequestCopyWith<_RecommendRequest> get copyWith => __$RecommendRequestCopyWithImpl<_RecommendRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecommendRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendRequest&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.analysis, analysis) || other.analysis == analysis)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.focusItemId, focusItemId) || other.focusItemId == focusItemId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId,analysis,profile,focusItemId);

@override
String toString() {
  return 'RecommendRequest(imageId: $imageId, analysis: $analysis, profile: $profile, focusItemId: $focusItemId)';
}


}

/// @nodoc
abstract mixin class _$RecommendRequestCopyWith<$Res> implements $RecommendRequestCopyWith<$Res> {
  factory _$RecommendRequestCopyWith(_RecommendRequest value, $Res Function(_RecommendRequest) _then) = __$RecommendRequestCopyWithImpl;
@override @useResult
$Res call({
 String imageId, Analysis analysis, Profile profile, String? focusItemId
});


@override $AnalysisCopyWith<$Res> get analysis;@override $ProfileCopyWith<$Res> get profile;

}
/// @nodoc
class __$RecommendRequestCopyWithImpl<$Res>
    implements _$RecommendRequestCopyWith<$Res> {
  __$RecommendRequestCopyWithImpl(this._self, this._then);

  final _RecommendRequest _self;
  final $Res Function(_RecommendRequest) _then;

/// Create a copy of RecommendRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imageId = null,Object? analysis = null,Object? profile = null,Object? focusItemId = freezed,}) {
  return _then(_RecommendRequest(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,analysis: null == analysis ? _self.analysis : analysis // ignore: cast_nullable_to_non_nullable
as Analysis,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile,focusItemId: freezed == focusItemId ? _self.focusItemId : focusItemId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RecommendRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalysisCopyWith<$Res> get analysis {
  
  return $AnalysisCopyWith<$Res>(_self.analysis, (value) {
    return _then(_self.copyWith(analysis: value));
  });
}/// Create a copy of RecommendRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res> get profile {
  
  return $ProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc
mixin _$UpcycleIdea {

/// Backend-assigned stable id: 'idea_<8 hex>'.
 String get id; String get title; String get pitch; Difficulty get difficulty; int get timeMinutes;/// Tools (not safety gear) the project needs.
 List<ToolId> get toolsNeeded; List<ToolId> get toolsHave; List<ToolId> get toolsMissing; List<String> get usesItemIds; List<String> get extraMaterials;/// English description of the finished object; drives the after image.
 String get afterVisual; String? get safetyNote; List<SourceRef> get sources;
/// Create a copy of UpcycleIdea
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpcycleIdeaCopyWith<UpcycleIdea> get copyWith => _$UpcycleIdeaCopyWithImpl<UpcycleIdea>(this as UpcycleIdea, _$identity);

  /// Serializes this UpcycleIdea to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpcycleIdea&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.pitch, pitch) || other.pitch == pitch)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.timeMinutes, timeMinutes) || other.timeMinutes == timeMinutes)&&const DeepCollectionEquality().equals(other.toolsNeeded, toolsNeeded)&&const DeepCollectionEquality().equals(other.toolsHave, toolsHave)&&const DeepCollectionEquality().equals(other.toolsMissing, toolsMissing)&&const DeepCollectionEquality().equals(other.usesItemIds, usesItemIds)&&const DeepCollectionEquality().equals(other.extraMaterials, extraMaterials)&&(identical(other.afterVisual, afterVisual) || other.afterVisual == afterVisual)&&(identical(other.safetyNote, safetyNote) || other.safetyNote == safetyNote)&&const DeepCollectionEquality().equals(other.sources, sources));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,pitch,difficulty,timeMinutes,const DeepCollectionEquality().hash(toolsNeeded),const DeepCollectionEquality().hash(toolsHave),const DeepCollectionEquality().hash(toolsMissing),const DeepCollectionEquality().hash(usesItemIds),const DeepCollectionEquality().hash(extraMaterials),afterVisual,safetyNote,const DeepCollectionEquality().hash(sources));

@override
String toString() {
  return 'UpcycleIdea(id: $id, title: $title, pitch: $pitch, difficulty: $difficulty, timeMinutes: $timeMinutes, toolsNeeded: $toolsNeeded, toolsHave: $toolsHave, toolsMissing: $toolsMissing, usesItemIds: $usesItemIds, extraMaterials: $extraMaterials, afterVisual: $afterVisual, safetyNote: $safetyNote, sources: $sources)';
}


}

/// @nodoc
abstract mixin class $UpcycleIdeaCopyWith<$Res>  {
  factory $UpcycleIdeaCopyWith(UpcycleIdea value, $Res Function(UpcycleIdea) _then) = _$UpcycleIdeaCopyWithImpl;
@useResult
$Res call({
 String id, String title, String pitch, Difficulty difficulty, int timeMinutes, List<ToolId> toolsNeeded, List<ToolId> toolsHave, List<ToolId> toolsMissing, List<String> usesItemIds, List<String> extraMaterials, String afterVisual, String? safetyNote, List<SourceRef> sources
});




}
/// @nodoc
class _$UpcycleIdeaCopyWithImpl<$Res>
    implements $UpcycleIdeaCopyWith<$Res> {
  _$UpcycleIdeaCopyWithImpl(this._self, this._then);

  final UpcycleIdea _self;
  final $Res Function(UpcycleIdea) _then;

/// Create a copy of UpcycleIdea
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? pitch = null,Object? difficulty = null,Object? timeMinutes = null,Object? toolsNeeded = null,Object? toolsHave = null,Object? toolsMissing = null,Object? usesItemIds = null,Object? extraMaterials = null,Object? afterVisual = null,Object? safetyNote = freezed,Object? sources = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,pitch: null == pitch ? _self.pitch : pitch // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as Difficulty,timeMinutes: null == timeMinutes ? _self.timeMinutes : timeMinutes // ignore: cast_nullable_to_non_nullable
as int,toolsNeeded: null == toolsNeeded ? _self.toolsNeeded : toolsNeeded // ignore: cast_nullable_to_non_nullable
as List<ToolId>,toolsHave: null == toolsHave ? _self.toolsHave : toolsHave // ignore: cast_nullable_to_non_nullable
as List<ToolId>,toolsMissing: null == toolsMissing ? _self.toolsMissing : toolsMissing // ignore: cast_nullable_to_non_nullable
as List<ToolId>,usesItemIds: null == usesItemIds ? _self.usesItemIds : usesItemIds // ignore: cast_nullable_to_non_nullable
as List<String>,extraMaterials: null == extraMaterials ? _self.extraMaterials : extraMaterials // ignore: cast_nullable_to_non_nullable
as List<String>,afterVisual: null == afterVisual ? _self.afterVisual : afterVisual // ignore: cast_nullable_to_non_nullable
as String,safetyNote: freezed == safetyNote ? _self.safetyNote : safetyNote // ignore: cast_nullable_to_non_nullable
as String?,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<SourceRef>,
  ));
}

}


/// Adds pattern-matching-related methods to [UpcycleIdea].
extension UpcycleIdeaPatterns on UpcycleIdea {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpcycleIdea value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpcycleIdea() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpcycleIdea value)  $default,){
final _that = this;
switch (_that) {
case _UpcycleIdea():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpcycleIdea value)?  $default,){
final _that = this;
switch (_that) {
case _UpcycleIdea() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String pitch,  Difficulty difficulty,  int timeMinutes,  List<ToolId> toolsNeeded,  List<ToolId> toolsHave,  List<ToolId> toolsMissing,  List<String> usesItemIds,  List<String> extraMaterials,  String afterVisual,  String? safetyNote,  List<SourceRef> sources)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpcycleIdea() when $default != null:
return $default(_that.id,_that.title,_that.pitch,_that.difficulty,_that.timeMinutes,_that.toolsNeeded,_that.toolsHave,_that.toolsMissing,_that.usesItemIds,_that.extraMaterials,_that.afterVisual,_that.safetyNote,_that.sources);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String pitch,  Difficulty difficulty,  int timeMinutes,  List<ToolId> toolsNeeded,  List<ToolId> toolsHave,  List<ToolId> toolsMissing,  List<String> usesItemIds,  List<String> extraMaterials,  String afterVisual,  String? safetyNote,  List<SourceRef> sources)  $default,) {final _that = this;
switch (_that) {
case _UpcycleIdea():
return $default(_that.id,_that.title,_that.pitch,_that.difficulty,_that.timeMinutes,_that.toolsNeeded,_that.toolsHave,_that.toolsMissing,_that.usesItemIds,_that.extraMaterials,_that.afterVisual,_that.safetyNote,_that.sources);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String pitch,  Difficulty difficulty,  int timeMinutes,  List<ToolId> toolsNeeded,  List<ToolId> toolsHave,  List<ToolId> toolsMissing,  List<String> usesItemIds,  List<String> extraMaterials,  String afterVisual,  String? safetyNote,  List<SourceRef> sources)?  $default,) {final _that = this;
switch (_that) {
case _UpcycleIdea() when $default != null:
return $default(_that.id,_that.title,_that.pitch,_that.difficulty,_that.timeMinutes,_that.toolsNeeded,_that.toolsHave,_that.toolsMissing,_that.usesItemIds,_that.extraMaterials,_that.afterVisual,_that.safetyNote,_that.sources);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpcycleIdea implements UpcycleIdea {
  const _UpcycleIdea({required this.id, required this.title, required this.pitch, required this.difficulty, required this.timeMinutes, required final  List<ToolId> toolsNeeded, required final  List<ToolId> toolsHave, required final  List<ToolId> toolsMissing, required final  List<String> usesItemIds, final  List<String> extraMaterials = const <String>[], required this.afterVisual, this.safetyNote, final  List<SourceRef> sources = const <SourceRef>[]}): _toolsNeeded = toolsNeeded,_toolsHave = toolsHave,_toolsMissing = toolsMissing,_usesItemIds = usesItemIds,_extraMaterials = extraMaterials,_sources = sources;
  factory _UpcycleIdea.fromJson(Map<String, dynamic> json) => _$UpcycleIdeaFromJson(json);

/// Backend-assigned stable id: 'idea_<8 hex>'.
@override final  String id;
@override final  String title;
@override final  String pitch;
@override final  Difficulty difficulty;
@override final  int timeMinutes;
/// Tools (not safety gear) the project needs.
 final  List<ToolId> _toolsNeeded;
/// Tools (not safety gear) the project needs.
@override List<ToolId> get toolsNeeded {
  if (_toolsNeeded is EqualUnmodifiableListView) return _toolsNeeded;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_toolsNeeded);
}

 final  List<ToolId> _toolsHave;
@override List<ToolId> get toolsHave {
  if (_toolsHave is EqualUnmodifiableListView) return _toolsHave;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_toolsHave);
}

 final  List<ToolId> _toolsMissing;
@override List<ToolId> get toolsMissing {
  if (_toolsMissing is EqualUnmodifiableListView) return _toolsMissing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_toolsMissing);
}

 final  List<String> _usesItemIds;
@override List<String> get usesItemIds {
  if (_usesItemIds is EqualUnmodifiableListView) return _usesItemIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_usesItemIds);
}

 final  List<String> _extraMaterials;
@override@JsonKey() List<String> get extraMaterials {
  if (_extraMaterials is EqualUnmodifiableListView) return _extraMaterials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extraMaterials);
}

/// English description of the finished object; drives the after image.
@override final  String afterVisual;
@override final  String? safetyNote;
 final  List<SourceRef> _sources;
@override@JsonKey() List<SourceRef> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}


/// Create a copy of UpcycleIdea
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpcycleIdeaCopyWith<_UpcycleIdea> get copyWith => __$UpcycleIdeaCopyWithImpl<_UpcycleIdea>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpcycleIdeaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpcycleIdea&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.pitch, pitch) || other.pitch == pitch)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.timeMinutes, timeMinutes) || other.timeMinutes == timeMinutes)&&const DeepCollectionEquality().equals(other._toolsNeeded, _toolsNeeded)&&const DeepCollectionEquality().equals(other._toolsHave, _toolsHave)&&const DeepCollectionEquality().equals(other._toolsMissing, _toolsMissing)&&const DeepCollectionEquality().equals(other._usesItemIds, _usesItemIds)&&const DeepCollectionEquality().equals(other._extraMaterials, _extraMaterials)&&(identical(other.afterVisual, afterVisual) || other.afterVisual == afterVisual)&&(identical(other.safetyNote, safetyNote) || other.safetyNote == safetyNote)&&const DeepCollectionEquality().equals(other._sources, _sources));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,pitch,difficulty,timeMinutes,const DeepCollectionEquality().hash(_toolsNeeded),const DeepCollectionEquality().hash(_toolsHave),const DeepCollectionEquality().hash(_toolsMissing),const DeepCollectionEquality().hash(_usesItemIds),const DeepCollectionEquality().hash(_extraMaterials),afterVisual,safetyNote,const DeepCollectionEquality().hash(_sources));

@override
String toString() {
  return 'UpcycleIdea(id: $id, title: $title, pitch: $pitch, difficulty: $difficulty, timeMinutes: $timeMinutes, toolsNeeded: $toolsNeeded, toolsHave: $toolsHave, toolsMissing: $toolsMissing, usesItemIds: $usesItemIds, extraMaterials: $extraMaterials, afterVisual: $afterVisual, safetyNote: $safetyNote, sources: $sources)';
}


}

/// @nodoc
abstract mixin class _$UpcycleIdeaCopyWith<$Res> implements $UpcycleIdeaCopyWith<$Res> {
  factory _$UpcycleIdeaCopyWith(_UpcycleIdea value, $Res Function(_UpcycleIdea) _then) = __$UpcycleIdeaCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String pitch, Difficulty difficulty, int timeMinutes, List<ToolId> toolsNeeded, List<ToolId> toolsHave, List<ToolId> toolsMissing, List<String> usesItemIds, List<String> extraMaterials, String afterVisual, String? safetyNote, List<SourceRef> sources
});




}
/// @nodoc
class __$UpcycleIdeaCopyWithImpl<$Res>
    implements _$UpcycleIdeaCopyWith<$Res> {
  __$UpcycleIdeaCopyWithImpl(this._self, this._then);

  final _UpcycleIdea _self;
  final $Res Function(_UpcycleIdea) _then;

/// Create a copy of UpcycleIdea
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? pitch = null,Object? difficulty = null,Object? timeMinutes = null,Object? toolsNeeded = null,Object? toolsHave = null,Object? toolsMissing = null,Object? usesItemIds = null,Object? extraMaterials = null,Object? afterVisual = null,Object? safetyNote = freezed,Object? sources = null,}) {
  return _then(_UpcycleIdea(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,pitch: null == pitch ? _self.pitch : pitch // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as Difficulty,timeMinutes: null == timeMinutes ? _self.timeMinutes : timeMinutes // ignore: cast_nullable_to_non_nullable
as int,toolsNeeded: null == toolsNeeded ? _self._toolsNeeded : toolsNeeded // ignore: cast_nullable_to_non_nullable
as List<ToolId>,toolsHave: null == toolsHave ? _self._toolsHave : toolsHave // ignore: cast_nullable_to_non_nullable
as List<ToolId>,toolsMissing: null == toolsMissing ? _self._toolsMissing : toolsMissing // ignore: cast_nullable_to_non_nullable
as List<ToolId>,usesItemIds: null == usesItemIds ? _self._usesItemIds : usesItemIds // ignore: cast_nullable_to_non_nullable
as List<String>,extraMaterials: null == extraMaterials ? _self._extraMaterials : extraMaterials // ignore: cast_nullable_to_non_nullable
as List<String>,afterVisual: null == afterVisual ? _self.afterVisual : afterVisual // ignore: cast_nullable_to_non_nullable
as String,safetyNote: freezed == safetyNote ? _self.safetyNote : safetyNote // ignore: cast_nullable_to_non_nullable
as String?,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<SourceRef>,
  ));
}


}


/// @nodoc
mixin _$RecycleInstruction {

 String get itemId; RecyclabilityStatus get status; String get stream; List<String> get prepSteps; List<String> get dos; List<String> get donts; String? get note;
/// Create a copy of RecycleInstruction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecycleInstructionCopyWith<RecycleInstruction> get copyWith => _$RecycleInstructionCopyWithImpl<RecycleInstruction>(this as RecycleInstruction, _$identity);

  /// Serializes this RecycleInstruction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecycleInstruction&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.status, status) || other.status == status)&&(identical(other.stream, stream) || other.stream == stream)&&const DeepCollectionEquality().equals(other.prepSteps, prepSteps)&&const DeepCollectionEquality().equals(other.dos, dos)&&const DeepCollectionEquality().equals(other.donts, donts)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemId,status,stream,const DeepCollectionEquality().hash(prepSteps),const DeepCollectionEquality().hash(dos),const DeepCollectionEquality().hash(donts),note);

@override
String toString() {
  return 'RecycleInstruction(itemId: $itemId, status: $status, stream: $stream, prepSteps: $prepSteps, dos: $dos, donts: $donts, note: $note)';
}


}

/// @nodoc
abstract mixin class $RecycleInstructionCopyWith<$Res>  {
  factory $RecycleInstructionCopyWith(RecycleInstruction value, $Res Function(RecycleInstruction) _then) = _$RecycleInstructionCopyWithImpl;
@useResult
$Res call({
 String itemId, RecyclabilityStatus status, String stream, List<String> prepSteps, List<String> dos, List<String> donts, String? note
});




}
/// @nodoc
class _$RecycleInstructionCopyWithImpl<$Res>
    implements $RecycleInstructionCopyWith<$Res> {
  _$RecycleInstructionCopyWithImpl(this._self, this._then);

  final RecycleInstruction _self;
  final $Res Function(RecycleInstruction) _then;

/// Create a copy of RecycleInstruction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemId = null,Object? status = null,Object? stream = null,Object? prepSteps = null,Object? dos = null,Object? donts = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecyclabilityStatus,stream: null == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as String,prepSteps: null == prepSteps ? _self.prepSteps : prepSteps // ignore: cast_nullable_to_non_nullable
as List<String>,dos: null == dos ? _self.dos : dos // ignore: cast_nullable_to_non_nullable
as List<String>,donts: null == donts ? _self.donts : donts // ignore: cast_nullable_to_non_nullable
as List<String>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecycleInstruction].
extension RecycleInstructionPatterns on RecycleInstruction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecycleInstruction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecycleInstruction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecycleInstruction value)  $default,){
final _that = this;
switch (_that) {
case _RecycleInstruction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecycleInstruction value)?  $default,){
final _that = this;
switch (_that) {
case _RecycleInstruction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String itemId,  RecyclabilityStatus status,  String stream,  List<String> prepSteps,  List<String> dos,  List<String> donts,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecycleInstruction() when $default != null:
return $default(_that.itemId,_that.status,_that.stream,_that.prepSteps,_that.dos,_that.donts,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String itemId,  RecyclabilityStatus status,  String stream,  List<String> prepSteps,  List<String> dos,  List<String> donts,  String? note)  $default,) {final _that = this;
switch (_that) {
case _RecycleInstruction():
return $default(_that.itemId,_that.status,_that.stream,_that.prepSteps,_that.dos,_that.donts,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String itemId,  RecyclabilityStatus status,  String stream,  List<String> prepSteps,  List<String> dos,  List<String> donts,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _RecycleInstruction() when $default != null:
return $default(_that.itemId,_that.status,_that.stream,_that.prepSteps,_that.dos,_that.donts,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecycleInstruction implements RecycleInstruction {
  const _RecycleInstruction({required this.itemId, required this.status, required this.stream, required final  List<String> prepSteps, required final  List<String> dos, required final  List<String> donts, this.note}): _prepSteps = prepSteps,_dos = dos,_donts = donts;
  factory _RecycleInstruction.fromJson(Map<String, dynamic> json) => _$RecycleInstructionFromJson(json);

@override final  String itemId;
@override final  RecyclabilityStatus status;
@override final  String stream;
 final  List<String> _prepSteps;
@override List<String> get prepSteps {
  if (_prepSteps is EqualUnmodifiableListView) return _prepSteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_prepSteps);
}

 final  List<String> _dos;
@override List<String> get dos {
  if (_dos is EqualUnmodifiableListView) return _dos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dos);
}

 final  List<String> _donts;
@override List<String> get donts {
  if (_donts is EqualUnmodifiableListView) return _donts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_donts);
}

@override final  String? note;

/// Create a copy of RecycleInstruction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecycleInstructionCopyWith<_RecycleInstruction> get copyWith => __$RecycleInstructionCopyWithImpl<_RecycleInstruction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecycleInstructionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecycleInstruction&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.status, status) || other.status == status)&&(identical(other.stream, stream) || other.stream == stream)&&const DeepCollectionEquality().equals(other._prepSteps, _prepSteps)&&const DeepCollectionEquality().equals(other._dos, _dos)&&const DeepCollectionEquality().equals(other._donts, _donts)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemId,status,stream,const DeepCollectionEquality().hash(_prepSteps),const DeepCollectionEquality().hash(_dos),const DeepCollectionEquality().hash(_donts),note);

@override
String toString() {
  return 'RecycleInstruction(itemId: $itemId, status: $status, stream: $stream, prepSteps: $prepSteps, dos: $dos, donts: $donts, note: $note)';
}


}

/// @nodoc
abstract mixin class _$RecycleInstructionCopyWith<$Res> implements $RecycleInstructionCopyWith<$Res> {
  factory _$RecycleInstructionCopyWith(_RecycleInstruction value, $Res Function(_RecycleInstruction) _then) = __$RecycleInstructionCopyWithImpl;
@override @useResult
$Res call({
 String itemId, RecyclabilityStatus status, String stream, List<String> prepSteps, List<String> dos, List<String> donts, String? note
});




}
/// @nodoc
class __$RecycleInstructionCopyWithImpl<$Res>
    implements _$RecycleInstructionCopyWith<$Res> {
  __$RecycleInstructionCopyWithImpl(this._self, this._then);

  final _RecycleInstruction _self;
  final $Res Function(_RecycleInstruction) _then;

/// Create a copy of RecycleInstruction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemId = null,Object? status = null,Object? stream = null,Object? prepSteps = null,Object? dos = null,Object? donts = null,Object? note = freezed,}) {
  return _then(_RecycleInstruction(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecyclabilityStatus,stream: null == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as String,prepSteps: null == prepSteps ? _self._prepSteps : prepSteps // ignore: cast_nullable_to_non_nullable
as List<String>,dos: null == dos ? _self._dos : dos // ignore: cast_nullable_to_non_nullable
as List<String>,donts: null == donts ? _self._donts : donts // ignore: cast_nullable_to_non_nullable
as List<String>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RecyclePath {

 List<RecycleInstruction> get instructions; List<SourceRef> get sources;
/// Create a copy of RecyclePath
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecyclePathCopyWith<RecyclePath> get copyWith => _$RecyclePathCopyWithImpl<RecyclePath>(this as RecyclePath, _$identity);

  /// Serializes this RecyclePath to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecyclePath&&const DeepCollectionEquality().equals(other.instructions, instructions)&&const DeepCollectionEquality().equals(other.sources, sources));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(instructions),const DeepCollectionEquality().hash(sources));

@override
String toString() {
  return 'RecyclePath(instructions: $instructions, sources: $sources)';
}


}

/// @nodoc
abstract mixin class $RecyclePathCopyWith<$Res>  {
  factory $RecyclePathCopyWith(RecyclePath value, $Res Function(RecyclePath) _then) = _$RecyclePathCopyWithImpl;
@useResult
$Res call({
 List<RecycleInstruction> instructions, List<SourceRef> sources
});




}
/// @nodoc
class _$RecyclePathCopyWithImpl<$Res>
    implements $RecyclePathCopyWith<$Res> {
  _$RecyclePathCopyWithImpl(this._self, this._then);

  final RecyclePath _self;
  final $Res Function(RecyclePath) _then;

/// Create a copy of RecyclePath
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? instructions = null,Object? sources = null,}) {
  return _then(_self.copyWith(
instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as List<RecycleInstruction>,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<SourceRef>,
  ));
}

}


/// Adds pattern-matching-related methods to [RecyclePath].
extension RecyclePathPatterns on RecyclePath {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecyclePath value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecyclePath() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecyclePath value)  $default,){
final _that = this;
switch (_that) {
case _RecyclePath():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecyclePath value)?  $default,){
final _that = this;
switch (_that) {
case _RecyclePath() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RecycleInstruction> instructions,  List<SourceRef> sources)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecyclePath() when $default != null:
return $default(_that.instructions,_that.sources);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RecycleInstruction> instructions,  List<SourceRef> sources)  $default,) {final _that = this;
switch (_that) {
case _RecyclePath():
return $default(_that.instructions,_that.sources);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RecycleInstruction> instructions,  List<SourceRef> sources)?  $default,) {final _that = this;
switch (_that) {
case _RecyclePath() when $default != null:
return $default(_that.instructions,_that.sources);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecyclePath implements RecyclePath {
  const _RecyclePath({required final  List<RecycleInstruction> instructions, final  List<SourceRef> sources = const <SourceRef>[]}): _instructions = instructions,_sources = sources;
  factory _RecyclePath.fromJson(Map<String, dynamic> json) => _$RecyclePathFromJson(json);

 final  List<RecycleInstruction> _instructions;
@override List<RecycleInstruction> get instructions {
  if (_instructions is EqualUnmodifiableListView) return _instructions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_instructions);
}

 final  List<SourceRef> _sources;
@override@JsonKey() List<SourceRef> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}


/// Create a copy of RecyclePath
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecyclePathCopyWith<_RecyclePath> get copyWith => __$RecyclePathCopyWithImpl<_RecyclePath>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecyclePathToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecyclePath&&const DeepCollectionEquality().equals(other._instructions, _instructions)&&const DeepCollectionEquality().equals(other._sources, _sources));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_instructions),const DeepCollectionEquality().hash(_sources));

@override
String toString() {
  return 'RecyclePath(instructions: $instructions, sources: $sources)';
}


}

/// @nodoc
abstract mixin class _$RecyclePathCopyWith<$Res> implements $RecyclePathCopyWith<$Res> {
  factory _$RecyclePathCopyWith(_RecyclePath value, $Res Function(_RecyclePath) _then) = __$RecyclePathCopyWithImpl;
@override @useResult
$Res call({
 List<RecycleInstruction> instructions, List<SourceRef> sources
});




}
/// @nodoc
class __$RecyclePathCopyWithImpl<$Res>
    implements _$RecyclePathCopyWith<$Res> {
  __$RecyclePathCopyWithImpl(this._self, this._then);

  final _RecyclePath _self;
  final $Res Function(_RecyclePath) _then;

/// Create a copy of RecyclePath
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? instructions = null,Object? sources = null,}) {
  return _then(_RecyclePath(
instructions: null == instructions ? _self._instructions : instructions // ignore: cast_nullable_to_non_nullable
as List<RecycleInstruction>,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<SourceRef>,
  ));
}


}


/// @nodoc
mixin _$DonateOption {

 String get itemId; bool get suitable;/// Why it can (or can't) be donated, based on its condition.
 String get reason;/// Localized kinds of places: 'Clothing donation bins'.
 List<String> get where; List<String> get prepSteps;
/// Create a copy of DonateOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DonateOptionCopyWith<DonateOption> get copyWith => _$DonateOptionCopyWithImpl<DonateOption>(this as DonateOption, _$identity);

  /// Serializes this DonateOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DonateOption&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.suitable, suitable) || other.suitable == suitable)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other.where, where)&&const DeepCollectionEquality().equals(other.prepSteps, prepSteps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemId,suitable,reason,const DeepCollectionEquality().hash(where),const DeepCollectionEquality().hash(prepSteps));

@override
String toString() {
  return 'DonateOption(itemId: $itemId, suitable: $suitable, reason: $reason, where: $where, prepSteps: $prepSteps)';
}


}

/// @nodoc
abstract mixin class $DonateOptionCopyWith<$Res>  {
  factory $DonateOptionCopyWith(DonateOption value, $Res Function(DonateOption) _then) = _$DonateOptionCopyWithImpl;
@useResult
$Res call({
 String itemId, bool suitable, String reason, List<String> where, List<String> prepSteps
});




}
/// @nodoc
class _$DonateOptionCopyWithImpl<$Res>
    implements $DonateOptionCopyWith<$Res> {
  _$DonateOptionCopyWithImpl(this._self, this._then);

  final DonateOption _self;
  final $Res Function(DonateOption) _then;

/// Create a copy of DonateOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemId = null,Object? suitable = null,Object? reason = null,Object? where = null,Object? prepSteps = null,}) {
  return _then(_self.copyWith(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,suitable: null == suitable ? _self.suitable : suitable // ignore: cast_nullable_to_non_nullable
as bool,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,where: null == where ? _self.where : where // ignore: cast_nullable_to_non_nullable
as List<String>,prepSteps: null == prepSteps ? _self.prepSteps : prepSteps // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DonateOption].
extension DonateOptionPatterns on DonateOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DonateOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DonateOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DonateOption value)  $default,){
final _that = this;
switch (_that) {
case _DonateOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DonateOption value)?  $default,){
final _that = this;
switch (_that) {
case _DonateOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String itemId,  bool suitable,  String reason,  List<String> where,  List<String> prepSteps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DonateOption() when $default != null:
return $default(_that.itemId,_that.suitable,_that.reason,_that.where,_that.prepSteps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String itemId,  bool suitable,  String reason,  List<String> where,  List<String> prepSteps)  $default,) {final _that = this;
switch (_that) {
case _DonateOption():
return $default(_that.itemId,_that.suitable,_that.reason,_that.where,_that.prepSteps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String itemId,  bool suitable,  String reason,  List<String> where,  List<String> prepSteps)?  $default,) {final _that = this;
switch (_that) {
case _DonateOption() when $default != null:
return $default(_that.itemId,_that.suitable,_that.reason,_that.where,_that.prepSteps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DonateOption implements DonateOption {
  const _DonateOption({required this.itemId, required this.suitable, required this.reason, final  List<String> where = const <String>[], final  List<String> prepSteps = const <String>[]}): _where = where,_prepSteps = prepSteps;
  factory _DonateOption.fromJson(Map<String, dynamic> json) => _$DonateOptionFromJson(json);

@override final  String itemId;
@override final  bool suitable;
/// Why it can (or can't) be donated, based on its condition.
@override final  String reason;
/// Localized kinds of places: 'Clothing donation bins'.
 final  List<String> _where;
/// Localized kinds of places: 'Clothing donation bins'.
@override@JsonKey() List<String> get where {
  if (_where is EqualUnmodifiableListView) return _where;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_where);
}

 final  List<String> _prepSteps;
@override@JsonKey() List<String> get prepSteps {
  if (_prepSteps is EqualUnmodifiableListView) return _prepSteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_prepSteps);
}


/// Create a copy of DonateOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DonateOptionCopyWith<_DonateOption> get copyWith => __$DonateOptionCopyWithImpl<_DonateOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DonateOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DonateOption&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.suitable, suitable) || other.suitable == suitable)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other._where, _where)&&const DeepCollectionEquality().equals(other._prepSteps, _prepSteps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemId,suitable,reason,const DeepCollectionEquality().hash(_where),const DeepCollectionEquality().hash(_prepSteps));

@override
String toString() {
  return 'DonateOption(itemId: $itemId, suitable: $suitable, reason: $reason, where: $where, prepSteps: $prepSteps)';
}


}

/// @nodoc
abstract mixin class _$DonateOptionCopyWith<$Res> implements $DonateOptionCopyWith<$Res> {
  factory _$DonateOptionCopyWith(_DonateOption value, $Res Function(_DonateOption) _then) = __$DonateOptionCopyWithImpl;
@override @useResult
$Res call({
 String itemId, bool suitable, String reason, List<String> where, List<String> prepSteps
});




}
/// @nodoc
class __$DonateOptionCopyWithImpl<$Res>
    implements _$DonateOptionCopyWith<$Res> {
  __$DonateOptionCopyWithImpl(this._self, this._then);

  final _DonateOption _self;
  final $Res Function(_DonateOption) _then;

/// Create a copy of DonateOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemId = null,Object? suitable = null,Object? reason = null,Object? where = null,Object? prepSteps = null,}) {
  return _then(_DonateOption(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,suitable: null == suitable ? _self.suitable : suitable // ignore: cast_nullable_to_non_nullable
as bool,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,where: null == where ? _self._where : where // ignore: cast_nullable_to_non_nullable
as List<String>,prepSteps: null == prepSteps ? _self._prepSteps : prepSteps // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$DonatePath {

/// True if at least one item is suitable for donation or reuse.
 bool get available; String get summary; List<DonateOption> get options;
/// Create a copy of DonatePath
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DonatePathCopyWith<DonatePath> get copyWith => _$DonatePathCopyWithImpl<DonatePath>(this as DonatePath, _$identity);

  /// Serializes this DonatePath to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DonatePath&&(identical(other.available, available) || other.available == available)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.options, options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,available,summary,const DeepCollectionEquality().hash(options));

@override
String toString() {
  return 'DonatePath(available: $available, summary: $summary, options: $options)';
}


}

/// @nodoc
abstract mixin class $DonatePathCopyWith<$Res>  {
  factory $DonatePathCopyWith(DonatePath value, $Res Function(DonatePath) _then) = _$DonatePathCopyWithImpl;
@useResult
$Res call({
 bool available, String summary, List<DonateOption> options
});




}
/// @nodoc
class _$DonatePathCopyWithImpl<$Res>
    implements $DonatePathCopyWith<$Res> {
  _$DonatePathCopyWithImpl(this._self, this._then);

  final DonatePath _self;
  final $Res Function(DonatePath) _then;

/// Create a copy of DonatePath
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? available = null,Object? summary = null,Object? options = null,}) {
  return _then(_self.copyWith(
available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<DonateOption>,
  ));
}

}


/// Adds pattern-matching-related methods to [DonatePath].
extension DonatePathPatterns on DonatePath {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DonatePath value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DonatePath() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DonatePath value)  $default,){
final _that = this;
switch (_that) {
case _DonatePath():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DonatePath value)?  $default,){
final _that = this;
switch (_that) {
case _DonatePath() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool available,  String summary,  List<DonateOption> options)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DonatePath() when $default != null:
return $default(_that.available,_that.summary,_that.options);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool available,  String summary,  List<DonateOption> options)  $default,) {final _that = this;
switch (_that) {
case _DonatePath():
return $default(_that.available,_that.summary,_that.options);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool available,  String summary,  List<DonateOption> options)?  $default,) {final _that = this;
switch (_that) {
case _DonatePath() when $default != null:
return $default(_that.available,_that.summary,_that.options);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DonatePath implements DonatePath {
  const _DonatePath({required this.available, required this.summary, required final  List<DonateOption> options}): _options = options;
  factory _DonatePath.fromJson(Map<String, dynamic> json) => _$DonatePathFromJson(json);

/// True if at least one item is suitable for donation or reuse.
@override final  bool available;
@override final  String summary;
 final  List<DonateOption> _options;
@override List<DonateOption> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}


/// Create a copy of DonatePath
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DonatePathCopyWith<_DonatePath> get copyWith => __$DonatePathCopyWithImpl<_DonatePath>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DonatePathToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DonatePath&&(identical(other.available, available) || other.available == available)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._options, _options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,available,summary,const DeepCollectionEquality().hash(_options));

@override
String toString() {
  return 'DonatePath(available: $available, summary: $summary, options: $options)';
}


}

/// @nodoc
abstract mixin class _$DonatePathCopyWith<$Res> implements $DonatePathCopyWith<$Res> {
  factory _$DonatePathCopyWith(_DonatePath value, $Res Function(_DonatePath) _then) = __$DonatePathCopyWithImpl;
@override @useResult
$Res call({
 bool available, String summary, List<DonateOption> options
});




}
/// @nodoc
class __$DonatePathCopyWithImpl<$Res>
    implements _$DonatePathCopyWith<$Res> {
  __$DonatePathCopyWithImpl(this._self, this._then);

  final _DonatePath _self;
  final $Res Function(_DonatePath) _then;

/// Create a copy of DonatePath
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? available = null,Object? summary = null,Object? options = null,}) {
  return _then(_DonatePath(
available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<DonateOption>,
  ));
}


}


/// @nodoc
mixin _$DisposalGuidance {

 String get itemId; HazardFlag get hazard; String get headline; List<String> get steps; List<String> get never;
/// Create a copy of DisposalGuidance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisposalGuidanceCopyWith<DisposalGuidance> get copyWith => _$DisposalGuidanceCopyWithImpl<DisposalGuidance>(this as DisposalGuidance, _$identity);

  /// Serializes this DisposalGuidance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisposalGuidance&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.hazard, hazard) || other.hazard == hazard)&&(identical(other.headline, headline) || other.headline == headline)&&const DeepCollectionEquality().equals(other.steps, steps)&&const DeepCollectionEquality().equals(other.never, never));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemId,hazard,headline,const DeepCollectionEquality().hash(steps),const DeepCollectionEquality().hash(never));

@override
String toString() {
  return 'DisposalGuidance(itemId: $itemId, hazard: $hazard, headline: $headline, steps: $steps, never: $never)';
}


}

/// @nodoc
abstract mixin class $DisposalGuidanceCopyWith<$Res>  {
  factory $DisposalGuidanceCopyWith(DisposalGuidance value, $Res Function(DisposalGuidance) _then) = _$DisposalGuidanceCopyWithImpl;
@useResult
$Res call({
 String itemId, HazardFlag hazard, String headline, List<String> steps, List<String> never
});




}
/// @nodoc
class _$DisposalGuidanceCopyWithImpl<$Res>
    implements $DisposalGuidanceCopyWith<$Res> {
  _$DisposalGuidanceCopyWithImpl(this._self, this._then);

  final DisposalGuidance _self;
  final $Res Function(DisposalGuidance) _then;

/// Create a copy of DisposalGuidance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemId = null,Object? hazard = null,Object? headline = null,Object? steps = null,Object? never = null,}) {
  return _then(_self.copyWith(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,hazard: null == hazard ? _self.hazard : hazard // ignore: cast_nullable_to_non_nullable
as HazardFlag,headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<String>,never: null == never ? _self.never : never // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DisposalGuidance].
extension DisposalGuidancePatterns on DisposalGuidance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisposalGuidance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisposalGuidance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisposalGuidance value)  $default,){
final _that = this;
switch (_that) {
case _DisposalGuidance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisposalGuidance value)?  $default,){
final _that = this;
switch (_that) {
case _DisposalGuidance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String itemId,  HazardFlag hazard,  String headline,  List<String> steps,  List<String> never)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisposalGuidance() when $default != null:
return $default(_that.itemId,_that.hazard,_that.headline,_that.steps,_that.never);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String itemId,  HazardFlag hazard,  String headline,  List<String> steps,  List<String> never)  $default,) {final _that = this;
switch (_that) {
case _DisposalGuidance():
return $default(_that.itemId,_that.hazard,_that.headline,_that.steps,_that.never);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String itemId,  HazardFlag hazard,  String headline,  List<String> steps,  List<String> never)?  $default,) {final _that = this;
switch (_that) {
case _DisposalGuidance() when $default != null:
return $default(_that.itemId,_that.hazard,_that.headline,_that.steps,_that.never);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DisposalGuidance implements DisposalGuidance {
  const _DisposalGuidance({required this.itemId, required this.hazard, required this.headline, required final  List<String> steps, required final  List<String> never}): _steps = steps,_never = never;
  factory _DisposalGuidance.fromJson(Map<String, dynamic> json) => _$DisposalGuidanceFromJson(json);

@override final  String itemId;
@override final  HazardFlag hazard;
@override final  String headline;
 final  List<String> _steps;
@override List<String> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}

 final  List<String> _never;
@override List<String> get never {
  if (_never is EqualUnmodifiableListView) return _never;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_never);
}


/// Create a copy of DisposalGuidance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisposalGuidanceCopyWith<_DisposalGuidance> get copyWith => __$DisposalGuidanceCopyWithImpl<_DisposalGuidance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisposalGuidanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisposalGuidance&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.hazard, hazard) || other.hazard == hazard)&&(identical(other.headline, headline) || other.headline == headline)&&const DeepCollectionEquality().equals(other._steps, _steps)&&const DeepCollectionEquality().equals(other._never, _never));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemId,hazard,headline,const DeepCollectionEquality().hash(_steps),const DeepCollectionEquality().hash(_never));

@override
String toString() {
  return 'DisposalGuidance(itemId: $itemId, hazard: $hazard, headline: $headline, steps: $steps, never: $never)';
}


}

/// @nodoc
abstract mixin class _$DisposalGuidanceCopyWith<$Res> implements $DisposalGuidanceCopyWith<$Res> {
  factory _$DisposalGuidanceCopyWith(_DisposalGuidance value, $Res Function(_DisposalGuidance) _then) = __$DisposalGuidanceCopyWithImpl;
@override @useResult
$Res call({
 String itemId, HazardFlag hazard, String headline, List<String> steps, List<String> never
});




}
/// @nodoc
class __$DisposalGuidanceCopyWithImpl<$Res>
    implements _$DisposalGuidanceCopyWith<$Res> {
  __$DisposalGuidanceCopyWithImpl(this._self, this._then);

  final _DisposalGuidance _self;
  final $Res Function(_DisposalGuidance) _then;

/// Create a copy of DisposalGuidance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemId = null,Object? hazard = null,Object? headline = null,Object? steps = null,Object? never = null,}) {
  return _then(_DisposalGuidance(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,hazard: null == hazard ? _self.hazard : hazard // ignore: cast_nullable_to_non_nullable
as HazardFlag,headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<String>,never: null == never ? _self._never : never // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$FacilityCategory {

/// 'glass', 'textile_donation', 'battery', 'e_waste', ...
 String get key; String get label; List<FacilityType> get facilityTypes; List<MaterialCategory> get materialCategories;/// Scan items that need this category (empty in catalog listings).
 List<String> get itemIds;
/// Create a copy of FacilityCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacilityCategoryCopyWith<FacilityCategory> get copyWith => _$FacilityCategoryCopyWithImpl<FacilityCategory>(this as FacilityCategory, _$identity);

  /// Serializes this FacilityCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FacilityCategory&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other.facilityTypes, facilityTypes)&&const DeepCollectionEquality().equals(other.materialCategories, materialCategories)&&const DeepCollectionEquality().equals(other.itemIds, itemIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,const DeepCollectionEquality().hash(facilityTypes),const DeepCollectionEquality().hash(materialCategories),const DeepCollectionEquality().hash(itemIds));

@override
String toString() {
  return 'FacilityCategory(key: $key, label: $label, facilityTypes: $facilityTypes, materialCategories: $materialCategories, itemIds: $itemIds)';
}


}

/// @nodoc
abstract mixin class $FacilityCategoryCopyWith<$Res>  {
  factory $FacilityCategoryCopyWith(FacilityCategory value, $Res Function(FacilityCategory) _then) = _$FacilityCategoryCopyWithImpl;
@useResult
$Res call({
 String key, String label, List<FacilityType> facilityTypes, List<MaterialCategory> materialCategories, List<String> itemIds
});




}
/// @nodoc
class _$FacilityCategoryCopyWithImpl<$Res>
    implements $FacilityCategoryCopyWith<$Res> {
  _$FacilityCategoryCopyWithImpl(this._self, this._then);

  final FacilityCategory _self;
  final $Res Function(FacilityCategory) _then;

/// Create a copy of FacilityCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? facilityTypes = null,Object? materialCategories = null,Object? itemIds = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,facilityTypes: null == facilityTypes ? _self.facilityTypes : facilityTypes // ignore: cast_nullable_to_non_nullable
as List<FacilityType>,materialCategories: null == materialCategories ? _self.materialCategories : materialCategories // ignore: cast_nullable_to_non_nullable
as List<MaterialCategory>,itemIds: null == itemIds ? _self.itemIds : itemIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [FacilityCategory].
extension FacilityCategoryPatterns on FacilityCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FacilityCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FacilityCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FacilityCategory value)  $default,){
final _that = this;
switch (_that) {
case _FacilityCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FacilityCategory value)?  $default,){
final _that = this;
switch (_that) {
case _FacilityCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label,  List<FacilityType> facilityTypes,  List<MaterialCategory> materialCategories,  List<String> itemIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FacilityCategory() when $default != null:
return $default(_that.key,_that.label,_that.facilityTypes,_that.materialCategories,_that.itemIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label,  List<FacilityType> facilityTypes,  List<MaterialCategory> materialCategories,  List<String> itemIds)  $default,) {final _that = this;
switch (_that) {
case _FacilityCategory():
return $default(_that.key,_that.label,_that.facilityTypes,_that.materialCategories,_that.itemIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label,  List<FacilityType> facilityTypes,  List<MaterialCategory> materialCategories,  List<String> itemIds)?  $default,) {final _that = this;
switch (_that) {
case _FacilityCategory() when $default != null:
return $default(_that.key,_that.label,_that.facilityTypes,_that.materialCategories,_that.itemIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FacilityCategory implements FacilityCategory {
  const _FacilityCategory({required this.key, required this.label, required final  List<FacilityType> facilityTypes, required final  List<MaterialCategory> materialCategories, final  List<String> itemIds = const <String>[]}): _facilityTypes = facilityTypes,_materialCategories = materialCategories,_itemIds = itemIds;
  factory _FacilityCategory.fromJson(Map<String, dynamic> json) => _$FacilityCategoryFromJson(json);

/// 'glass', 'textile_donation', 'battery', 'e_waste', ...
@override final  String key;
@override final  String label;
 final  List<FacilityType> _facilityTypes;
@override List<FacilityType> get facilityTypes {
  if (_facilityTypes is EqualUnmodifiableListView) return _facilityTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_facilityTypes);
}

 final  List<MaterialCategory> _materialCategories;
@override List<MaterialCategory> get materialCategories {
  if (_materialCategories is EqualUnmodifiableListView) return _materialCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_materialCategories);
}

/// Scan items that need this category (empty in catalog listings).
 final  List<String> _itemIds;
/// Scan items that need this category (empty in catalog listings).
@override@JsonKey() List<String> get itemIds {
  if (_itemIds is EqualUnmodifiableListView) return _itemIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_itemIds);
}


/// Create a copy of FacilityCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FacilityCategoryCopyWith<_FacilityCategory> get copyWith => __$FacilityCategoryCopyWithImpl<_FacilityCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FacilityCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FacilityCategory&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other._facilityTypes, _facilityTypes)&&const DeepCollectionEquality().equals(other._materialCategories, _materialCategories)&&const DeepCollectionEquality().equals(other._itemIds, _itemIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,const DeepCollectionEquality().hash(_facilityTypes),const DeepCollectionEquality().hash(_materialCategories),const DeepCollectionEquality().hash(_itemIds));

@override
String toString() {
  return 'FacilityCategory(key: $key, label: $label, facilityTypes: $facilityTypes, materialCategories: $materialCategories, itemIds: $itemIds)';
}


}

/// @nodoc
abstract mixin class _$FacilityCategoryCopyWith<$Res> implements $FacilityCategoryCopyWith<$Res> {
  factory _$FacilityCategoryCopyWith(_FacilityCategory value, $Res Function(_FacilityCategory) _then) = __$FacilityCategoryCopyWithImpl;
@override @useResult
$Res call({
 String key, String label, List<FacilityType> facilityTypes, List<MaterialCategory> materialCategories, List<String> itemIds
});




}
/// @nodoc
class __$FacilityCategoryCopyWithImpl<$Res>
    implements _$FacilityCategoryCopyWith<$Res> {
  __$FacilityCategoryCopyWithImpl(this._self, this._then);

  final _FacilityCategory _self;
  final $Res Function(_FacilityCategory) _then;

/// Create a copy of FacilityCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? facilityTypes = null,Object? materialCategories = null,Object? itemIds = null,}) {
  return _then(_FacilityCategory(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,facilityTypes: null == facilityTypes ? _self._facilityTypes : facilityTypes // ignore: cast_nullable_to_non_nullable
as List<FacilityType>,materialCategories: null == materialCategories ? _self._materialCategories : materialCategories // ignore: cast_nullable_to_non_nullable
as List<MaterialCategory>,itemIds: null == itemIds ? _self._itemIds : itemIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$Routing {

 RoutingMode get mode; List<String> get hazardousItemIds;/// Localized one-liner shown when DIY is withheld.
 String? get reason;
/// Create a copy of Routing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutingCopyWith<Routing> get copyWith => _$RoutingCopyWithImpl<Routing>(this as Routing, _$identity);

  /// Serializes this Routing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Routing&&(identical(other.mode, mode) || other.mode == mode)&&const DeepCollectionEquality().equals(other.hazardousItemIds, hazardousItemIds)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,const DeepCollectionEquality().hash(hazardousItemIds),reason);

@override
String toString() {
  return 'Routing(mode: $mode, hazardousItemIds: $hazardousItemIds, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $RoutingCopyWith<$Res>  {
  factory $RoutingCopyWith(Routing value, $Res Function(Routing) _then) = _$RoutingCopyWithImpl;
@useResult
$Res call({
 RoutingMode mode, List<String> hazardousItemIds, String? reason
});




}
/// @nodoc
class _$RoutingCopyWithImpl<$Res>
    implements $RoutingCopyWith<$Res> {
  _$RoutingCopyWithImpl(this._self, this._then);

  final Routing _self;
  final $Res Function(Routing) _then;

/// Create a copy of Routing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? hazardousItemIds = null,Object? reason = freezed,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as RoutingMode,hazardousItemIds: null == hazardousItemIds ? _self.hazardousItemIds : hazardousItemIds // ignore: cast_nullable_to_non_nullable
as List<String>,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Routing].
extension RoutingPatterns on Routing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Routing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Routing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Routing value)  $default,){
final _that = this;
switch (_that) {
case _Routing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Routing value)?  $default,){
final _that = this;
switch (_that) {
case _Routing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RoutingMode mode,  List<String> hazardousItemIds,  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Routing() when $default != null:
return $default(_that.mode,_that.hazardousItemIds,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RoutingMode mode,  List<String> hazardousItemIds,  String? reason)  $default,) {final _that = this;
switch (_that) {
case _Routing():
return $default(_that.mode,_that.hazardousItemIds,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RoutingMode mode,  List<String> hazardousItemIds,  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _Routing() when $default != null:
return $default(_that.mode,_that.hazardousItemIds,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Routing implements Routing {
  const _Routing({required this.mode, final  List<String> hazardousItemIds = const <String>[], this.reason}): _hazardousItemIds = hazardousItemIds;
  factory _Routing.fromJson(Map<String, dynamic> json) => _$RoutingFromJson(json);

@override final  RoutingMode mode;
 final  List<String> _hazardousItemIds;
@override@JsonKey() List<String> get hazardousItemIds {
  if (_hazardousItemIds is EqualUnmodifiableListView) return _hazardousItemIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hazardousItemIds);
}

/// Localized one-liner shown when DIY is withheld.
@override final  String? reason;

/// Create a copy of Routing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutingCopyWith<_Routing> get copyWith => __$RoutingCopyWithImpl<_Routing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Routing&&(identical(other.mode, mode) || other.mode == mode)&&const DeepCollectionEquality().equals(other._hazardousItemIds, _hazardousItemIds)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,const DeepCollectionEquality().hash(_hazardousItemIds),reason);

@override
String toString() {
  return 'Routing(mode: $mode, hazardousItemIds: $hazardousItemIds, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$RoutingCopyWith<$Res> implements $RoutingCopyWith<$Res> {
  factory _$RoutingCopyWith(_Routing value, $Res Function(_Routing) _then) = __$RoutingCopyWithImpl;
@override @useResult
$Res call({
 RoutingMode mode, List<String> hazardousItemIds, String? reason
});




}
/// @nodoc
class __$RoutingCopyWithImpl<$Res>
    implements _$RoutingCopyWith<$Res> {
  __$RoutingCopyWithImpl(this._self, this._then);

  final _Routing _self;
  final $Res Function(_Routing) _then;

/// Create a copy of Routing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? hazardousItemIds = null,Object? reason = freezed,}) {
  return _then(_Routing(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as RoutingMode,hazardousItemIds: null == hazardousItemIds ? _self._hazardousItemIds : hazardousItemIds // ignore: cast_nullable_to_non_nullable
as List<String>,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RecommendResponse {

 Routing get routing;/// Exactly 3 ideas unless `routing.mode` is disposal_only (then empty).
 List<UpcycleIdea> get upcycle; RecyclePath get recycle; DonatePath get donate; List<DisposalGuidance> get disposal; List<FacilityCategory> get facilityCategories; Lang get lang; Timings get timingsMs;
/// Create a copy of RecommendResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendResponseCopyWith<RecommendResponse> get copyWith => _$RecommendResponseCopyWithImpl<RecommendResponse>(this as RecommendResponse, _$identity);

  /// Serializes this RecommendResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendResponse&&(identical(other.routing, routing) || other.routing == routing)&&const DeepCollectionEquality().equals(other.upcycle, upcycle)&&(identical(other.recycle, recycle) || other.recycle == recycle)&&(identical(other.donate, donate) || other.donate == donate)&&const DeepCollectionEquality().equals(other.disposal, disposal)&&const DeepCollectionEquality().equals(other.facilityCategories, facilityCategories)&&(identical(other.lang, lang) || other.lang == lang)&&const DeepCollectionEquality().equals(other.timingsMs, timingsMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routing,const DeepCollectionEquality().hash(upcycle),recycle,donate,const DeepCollectionEquality().hash(disposal),const DeepCollectionEquality().hash(facilityCategories),lang,const DeepCollectionEquality().hash(timingsMs));

@override
String toString() {
  return 'RecommendResponse(routing: $routing, upcycle: $upcycle, recycle: $recycle, donate: $donate, disposal: $disposal, facilityCategories: $facilityCategories, lang: $lang, timingsMs: $timingsMs)';
}


}

/// @nodoc
abstract mixin class $RecommendResponseCopyWith<$Res>  {
  factory $RecommendResponseCopyWith(RecommendResponse value, $Res Function(RecommendResponse) _then) = _$RecommendResponseCopyWithImpl;
@useResult
$Res call({
 Routing routing, List<UpcycleIdea> upcycle, RecyclePath recycle, DonatePath donate, List<DisposalGuidance> disposal, List<FacilityCategory> facilityCategories, Lang lang, Timings timingsMs
});


$RoutingCopyWith<$Res> get routing;$RecyclePathCopyWith<$Res> get recycle;$DonatePathCopyWith<$Res> get donate;

}
/// @nodoc
class _$RecommendResponseCopyWithImpl<$Res>
    implements $RecommendResponseCopyWith<$Res> {
  _$RecommendResponseCopyWithImpl(this._self, this._then);

  final RecommendResponse _self;
  final $Res Function(RecommendResponse) _then;

/// Create a copy of RecommendResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? routing = null,Object? upcycle = null,Object? recycle = null,Object? donate = null,Object? disposal = null,Object? facilityCategories = null,Object? lang = null,Object? timingsMs = null,}) {
  return _then(_self.copyWith(
routing: null == routing ? _self.routing : routing // ignore: cast_nullable_to_non_nullable
as Routing,upcycle: null == upcycle ? _self.upcycle : upcycle // ignore: cast_nullable_to_non_nullable
as List<UpcycleIdea>,recycle: null == recycle ? _self.recycle : recycle // ignore: cast_nullable_to_non_nullable
as RecyclePath,donate: null == donate ? _self.donate : donate // ignore: cast_nullable_to_non_nullable
as DonatePath,disposal: null == disposal ? _self.disposal : disposal // ignore: cast_nullable_to_non_nullable
as List<DisposalGuidance>,facilityCategories: null == facilityCategories ? _self.facilityCategories : facilityCategories // ignore: cast_nullable_to_non_nullable
as List<FacilityCategory>,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as Lang,timingsMs: null == timingsMs ? _self.timingsMs : timingsMs // ignore: cast_nullable_to_non_nullable
as Timings,
  ));
}
/// Create a copy of RecommendResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutingCopyWith<$Res> get routing {
  
  return $RoutingCopyWith<$Res>(_self.routing, (value) {
    return _then(_self.copyWith(routing: value));
  });
}/// Create a copy of RecommendResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecyclePathCopyWith<$Res> get recycle {
  
  return $RecyclePathCopyWith<$Res>(_self.recycle, (value) {
    return _then(_self.copyWith(recycle: value));
  });
}/// Create a copy of RecommendResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DonatePathCopyWith<$Res> get donate {
  
  return $DonatePathCopyWith<$Res>(_self.donate, (value) {
    return _then(_self.copyWith(donate: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecommendResponse].
extension RecommendResponsePatterns on RecommendResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendResponse value)  $default,){
final _that = this;
switch (_that) {
case _RecommendResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendResponse value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Routing routing,  List<UpcycleIdea> upcycle,  RecyclePath recycle,  DonatePath donate,  List<DisposalGuidance> disposal,  List<FacilityCategory> facilityCategories,  Lang lang,  Timings timingsMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendResponse() when $default != null:
return $default(_that.routing,_that.upcycle,_that.recycle,_that.donate,_that.disposal,_that.facilityCategories,_that.lang,_that.timingsMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Routing routing,  List<UpcycleIdea> upcycle,  RecyclePath recycle,  DonatePath donate,  List<DisposalGuidance> disposal,  List<FacilityCategory> facilityCategories,  Lang lang,  Timings timingsMs)  $default,) {final _that = this;
switch (_that) {
case _RecommendResponse():
return $default(_that.routing,_that.upcycle,_that.recycle,_that.donate,_that.disposal,_that.facilityCategories,_that.lang,_that.timingsMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Routing routing,  List<UpcycleIdea> upcycle,  RecyclePath recycle,  DonatePath donate,  List<DisposalGuidance> disposal,  List<FacilityCategory> facilityCategories,  Lang lang,  Timings timingsMs)?  $default,) {final _that = this;
switch (_that) {
case _RecommendResponse() when $default != null:
return $default(_that.routing,_that.upcycle,_that.recycle,_that.donate,_that.disposal,_that.facilityCategories,_that.lang,_that.timingsMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecommendResponse extends RecommendResponse {
  const _RecommendResponse({required this.routing, required final  List<UpcycleIdea> upcycle, required this.recycle, required this.donate, final  List<DisposalGuidance> disposal = const <DisposalGuidance>[], required final  List<FacilityCategory> facilityCategories, required this.lang, final  Timings timingsMs = const <String, int>{}}): _upcycle = upcycle,_disposal = disposal,_facilityCategories = facilityCategories,_timingsMs = timingsMs,super._();
  factory _RecommendResponse.fromJson(Map<String, dynamic> json) => _$RecommendResponseFromJson(json);

@override final  Routing routing;
/// Exactly 3 ideas unless `routing.mode` is disposal_only (then empty).
 final  List<UpcycleIdea> _upcycle;
/// Exactly 3 ideas unless `routing.mode` is disposal_only (then empty).
@override List<UpcycleIdea> get upcycle {
  if (_upcycle is EqualUnmodifiableListView) return _upcycle;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_upcycle);
}

@override final  RecyclePath recycle;
@override final  DonatePath donate;
 final  List<DisposalGuidance> _disposal;
@override@JsonKey() List<DisposalGuidance> get disposal {
  if (_disposal is EqualUnmodifiableListView) return _disposal;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_disposal);
}

 final  List<FacilityCategory> _facilityCategories;
@override List<FacilityCategory> get facilityCategories {
  if (_facilityCategories is EqualUnmodifiableListView) return _facilityCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_facilityCategories);
}

@override final  Lang lang;
 final  Timings _timingsMs;
@override@JsonKey() Timings get timingsMs {
  if (_timingsMs is EqualUnmodifiableMapView) return _timingsMs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_timingsMs);
}


/// Create a copy of RecommendResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendResponseCopyWith<_RecommendResponse> get copyWith => __$RecommendResponseCopyWithImpl<_RecommendResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecommendResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendResponse&&(identical(other.routing, routing) || other.routing == routing)&&const DeepCollectionEquality().equals(other._upcycle, _upcycle)&&(identical(other.recycle, recycle) || other.recycle == recycle)&&(identical(other.donate, donate) || other.donate == donate)&&const DeepCollectionEquality().equals(other._disposal, _disposal)&&const DeepCollectionEquality().equals(other._facilityCategories, _facilityCategories)&&(identical(other.lang, lang) || other.lang == lang)&&const DeepCollectionEquality().equals(other._timingsMs, _timingsMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routing,const DeepCollectionEquality().hash(_upcycle),recycle,donate,const DeepCollectionEquality().hash(_disposal),const DeepCollectionEquality().hash(_facilityCategories),lang,const DeepCollectionEquality().hash(_timingsMs));

@override
String toString() {
  return 'RecommendResponse(routing: $routing, upcycle: $upcycle, recycle: $recycle, donate: $donate, disposal: $disposal, facilityCategories: $facilityCategories, lang: $lang, timingsMs: $timingsMs)';
}


}

/// @nodoc
abstract mixin class _$RecommendResponseCopyWith<$Res> implements $RecommendResponseCopyWith<$Res> {
  factory _$RecommendResponseCopyWith(_RecommendResponse value, $Res Function(_RecommendResponse) _then) = __$RecommendResponseCopyWithImpl;
@override @useResult
$Res call({
 Routing routing, List<UpcycleIdea> upcycle, RecyclePath recycle, DonatePath donate, List<DisposalGuidance> disposal, List<FacilityCategory> facilityCategories, Lang lang, Timings timingsMs
});


@override $RoutingCopyWith<$Res> get routing;@override $RecyclePathCopyWith<$Res> get recycle;@override $DonatePathCopyWith<$Res> get donate;

}
/// @nodoc
class __$RecommendResponseCopyWithImpl<$Res>
    implements _$RecommendResponseCopyWith<$Res> {
  __$RecommendResponseCopyWithImpl(this._self, this._then);

  final _RecommendResponse _self;
  final $Res Function(_RecommendResponse) _then;

/// Create a copy of RecommendResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? routing = null,Object? upcycle = null,Object? recycle = null,Object? donate = null,Object? disposal = null,Object? facilityCategories = null,Object? lang = null,Object? timingsMs = null,}) {
  return _then(_RecommendResponse(
routing: null == routing ? _self.routing : routing // ignore: cast_nullable_to_non_nullable
as Routing,upcycle: null == upcycle ? _self._upcycle : upcycle // ignore: cast_nullable_to_non_nullable
as List<UpcycleIdea>,recycle: null == recycle ? _self.recycle : recycle // ignore: cast_nullable_to_non_nullable
as RecyclePath,donate: null == donate ? _self.donate : donate // ignore: cast_nullable_to_non_nullable
as DonatePath,disposal: null == disposal ? _self._disposal : disposal // ignore: cast_nullable_to_non_nullable
as List<DisposalGuidance>,facilityCategories: null == facilityCategories ? _self._facilityCategories : facilityCategories // ignore: cast_nullable_to_non_nullable
as List<FacilityCategory>,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as Lang,timingsMs: null == timingsMs ? _self._timingsMs : timingsMs // ignore: cast_nullable_to_non_nullable
as Timings,
  ));
}

/// Create a copy of RecommendResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutingCopyWith<$Res> get routing {
  
  return $RoutingCopyWith<$Res>(_self.routing, (value) {
    return _then(_self.copyWith(routing: value));
  });
}/// Create a copy of RecommendResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecyclePathCopyWith<$Res> get recycle {
  
  return $RecyclePathCopyWith<$Res>(_self.recycle, (value) {
    return _then(_self.copyWith(recycle: value));
  });
}/// Create a copy of RecommendResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DonatePathCopyWith<$Res> get donate {
  
  return $DonatePathCopyWith<$Res>(_self.donate, (value) {
    return _then(_self.copyWith(donate: value));
  });
}
}

// dart format on
