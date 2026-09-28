// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StageState {

 StageStatus get status; ApiException? get error;
/// Create a copy of StageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StageStateCopyWith<StageState> get copyWith => _$StageStateCopyWithImpl<StageState>(this as StageState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StageState&&(identical(other.status, status) || other.status == status)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,error);

@override
String toString() {
  return 'StageState(status: $status, error: $error)';
}


}

/// @nodoc
abstract mixin class $StageStateCopyWith<$Res>  {
  factory $StageStateCopyWith(StageState value, $Res Function(StageState) _then) = _$StageStateCopyWithImpl;
@useResult
$Res call({
 StageStatus status, ApiException? error
});




}
/// @nodoc
class _$StageStateCopyWithImpl<$Res>
    implements $StageStateCopyWith<$Res> {
  _$StageStateCopyWithImpl(this._self, this._then);

  final StageState _self;
  final $Res Function(StageState) _then;

/// Create a copy of StageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StageStatus,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiException?,
  ));
}

}


/// Adds pattern-matching-related methods to [StageState].
extension StageStatePatterns on StageState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StageState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StageState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StageState value)  $default,){
final _that = this;
switch (_that) {
case _StageState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StageState value)?  $default,){
final _that = this;
switch (_that) {
case _StageState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StageStatus status,  ApiException? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StageState() when $default != null:
return $default(_that.status,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StageStatus status,  ApiException? error)  $default,) {final _that = this;
switch (_that) {
case _StageState():
return $default(_that.status,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StageStatus status,  ApiException? error)?  $default,) {final _that = this;
switch (_that) {
case _StageState() when $default != null:
return $default(_that.status,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _StageState extends StageState {
  const _StageState({this.status = StageStatus.pending, this.error}): super._();
  

@override@JsonKey() final  StageStatus status;
@override final  ApiException? error;

/// Create a copy of StageState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StageStateCopyWith<_StageState> get copyWith => __$StageStateCopyWithImpl<_StageState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StageState&&(identical(other.status, status) || other.status == status)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,error);

@override
String toString() {
  return 'StageState(status: $status, error: $error)';
}


}

/// @nodoc
abstract mixin class _$StageStateCopyWith<$Res> implements $StageStateCopyWith<$Res> {
  factory _$StageStateCopyWith(_StageState value, $Res Function(_StageState) _then) = __$StageStateCopyWithImpl;
@override @useResult
$Res call({
 StageStatus status, ApiException? error
});




}
/// @nodoc
class __$StageStateCopyWithImpl<$Res>
    implements _$StageStateCopyWith<$Res> {
  __$StageStateCopyWithImpl(this._self, this._then);

  final _StageState _self;
  final $Res Function(_StageState) _then;

/// Create a copy of StageState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? error = freezed,}) {
  return _then(_StageState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StageStatus,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiException?,
  ));
}


}

/// @nodoc
mixin _$ScanSessionState {

 String get scanId; ScanOrigin get origin; AnalysisSource get source; Lang get lang;/// The typed description, for text scans.
 String? get inputText;/// The compressed photo on the device (hero image, offline thumbnail).
 String? get localImagePath; Map<PipelineStage, StageState> get stages; AnalyzeResponse? get analysis;/// Set when the model judged the photo unusable (blurry, dark, no items):
/// show [PhotoCheck.retakeTip] and a retake button.
 PhotoCheck? get rejectedPhoto; RecommendResponse? get recommendation; FacilitiesResponse? get facilities;/// Where the drop-off search ran (GPS, chosen city or nearest city).
 SearchLocation? get dropoffLocation;/// Idea id -> after image.
 Map<String, GeneratedImageState> get afterImages;/// Text scans only: a generated photo of the described item, the "before"
/// side of the before/after slider (photo scans use [localImagePath]).
 GeneratedImageState get referenceImage;/// Item the ideas focus on (null: the analysis' primary item).
 String? get focusItemId;
/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanSessionStateCopyWith<ScanSessionState> get copyWith => _$ScanSessionStateCopyWithImpl<ScanSessionState>(this as ScanSessionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanSessionState&&(identical(other.scanId, scanId) || other.scanId == scanId)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.source, source) || other.source == source)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.inputText, inputText) || other.inputText == inputText)&&(identical(other.localImagePath, localImagePath) || other.localImagePath == localImagePath)&&const DeepCollectionEquality().equals(other.stages, stages)&&(identical(other.analysis, analysis) || other.analysis == analysis)&&(identical(other.rejectedPhoto, rejectedPhoto) || other.rejectedPhoto == rejectedPhoto)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.facilities, facilities) || other.facilities == facilities)&&(identical(other.dropoffLocation, dropoffLocation) || other.dropoffLocation == dropoffLocation)&&const DeepCollectionEquality().equals(other.afterImages, afterImages)&&(identical(other.referenceImage, referenceImage) || other.referenceImage == referenceImage)&&(identical(other.focusItemId, focusItemId) || other.focusItemId == focusItemId));
}


@override
int get hashCode => Object.hash(runtimeType,scanId,origin,source,lang,inputText,localImagePath,const DeepCollectionEquality().hash(stages),analysis,rejectedPhoto,recommendation,facilities,dropoffLocation,const DeepCollectionEquality().hash(afterImages),referenceImage,focusItemId);

@override
String toString() {
  return 'ScanSessionState(scanId: $scanId, origin: $origin, source: $source, lang: $lang, inputText: $inputText, localImagePath: $localImagePath, stages: $stages, analysis: $analysis, rejectedPhoto: $rejectedPhoto, recommendation: $recommendation, facilities: $facilities, dropoffLocation: $dropoffLocation, afterImages: $afterImages, referenceImage: $referenceImage, focusItemId: $focusItemId)';
}


}

/// @nodoc
abstract mixin class $ScanSessionStateCopyWith<$Res>  {
  factory $ScanSessionStateCopyWith(ScanSessionState value, $Res Function(ScanSessionState) _then) = _$ScanSessionStateCopyWithImpl;
@useResult
$Res call({
 String scanId, ScanOrigin origin, AnalysisSource source, Lang lang, String? inputText, String? localImagePath, Map<PipelineStage, StageState> stages, AnalyzeResponse? analysis, PhotoCheck? rejectedPhoto, RecommendResponse? recommendation, FacilitiesResponse? facilities, SearchLocation? dropoffLocation, Map<String, GeneratedImageState> afterImages, GeneratedImageState referenceImage, String? focusItemId
});


$AnalyzeResponseCopyWith<$Res>? get analysis;$PhotoCheckCopyWith<$Res>? get rejectedPhoto;$RecommendResponseCopyWith<$Res>? get recommendation;$FacilitiesResponseCopyWith<$Res>? get facilities;$GeneratedImageStateCopyWith<$Res> get referenceImage;

}
/// @nodoc
class _$ScanSessionStateCopyWithImpl<$Res>
    implements $ScanSessionStateCopyWith<$Res> {
  _$ScanSessionStateCopyWithImpl(this._self, this._then);

  final ScanSessionState _self;
  final $Res Function(ScanSessionState) _then;

/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scanId = null,Object? origin = null,Object? source = null,Object? lang = null,Object? inputText = freezed,Object? localImagePath = freezed,Object? stages = null,Object? analysis = freezed,Object? rejectedPhoto = freezed,Object? recommendation = freezed,Object? facilities = freezed,Object? dropoffLocation = freezed,Object? afterImages = null,Object? referenceImage = null,Object? focusItemId = freezed,}) {
  return _then(_self.copyWith(
scanId: null == scanId ? _self.scanId : scanId // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as ScanOrigin,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AnalysisSource,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as Lang,inputText: freezed == inputText ? _self.inputText : inputText // ignore: cast_nullable_to_non_nullable
as String?,localImagePath: freezed == localImagePath ? _self.localImagePath : localImagePath // ignore: cast_nullable_to_non_nullable
as String?,stages: null == stages ? _self.stages : stages // ignore: cast_nullable_to_non_nullable
as Map<PipelineStage, StageState>,analysis: freezed == analysis ? _self.analysis : analysis // ignore: cast_nullable_to_non_nullable
as AnalyzeResponse?,rejectedPhoto: freezed == rejectedPhoto ? _self.rejectedPhoto : rejectedPhoto // ignore: cast_nullable_to_non_nullable
as PhotoCheck?,recommendation: freezed == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as RecommendResponse?,facilities: freezed == facilities ? _self.facilities : facilities // ignore: cast_nullable_to_non_nullable
as FacilitiesResponse?,dropoffLocation: freezed == dropoffLocation ? _self.dropoffLocation : dropoffLocation // ignore: cast_nullable_to_non_nullable
as SearchLocation?,afterImages: null == afterImages ? _self.afterImages : afterImages // ignore: cast_nullable_to_non_nullable
as Map<String, GeneratedImageState>,referenceImage: null == referenceImage ? _self.referenceImage : referenceImage // ignore: cast_nullable_to_non_nullable
as GeneratedImageState,focusItemId: freezed == focusItemId ? _self.focusItemId : focusItemId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyzeResponseCopyWith<$Res>? get analysis {
    if (_self.analysis == null) {
    return null;
  }

  return $AnalyzeResponseCopyWith<$Res>(_self.analysis!, (value) {
    return _then(_self.copyWith(analysis: value));
  });
}/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhotoCheckCopyWith<$Res>? get rejectedPhoto {
    if (_self.rejectedPhoto == null) {
    return null;
  }

  return $PhotoCheckCopyWith<$Res>(_self.rejectedPhoto!, (value) {
    return _then(_self.copyWith(rejectedPhoto: value));
  });
}/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecommendResponseCopyWith<$Res>? get recommendation {
    if (_self.recommendation == null) {
    return null;
  }

  return $RecommendResponseCopyWith<$Res>(_self.recommendation!, (value) {
    return _then(_self.copyWith(recommendation: value));
  });
}/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FacilitiesResponseCopyWith<$Res>? get facilities {
    if (_self.facilities == null) {
    return null;
  }

  return $FacilitiesResponseCopyWith<$Res>(_self.facilities!, (value) {
    return _then(_self.copyWith(facilities: value));
  });
}/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneratedImageStateCopyWith<$Res> get referenceImage {
  
  return $GeneratedImageStateCopyWith<$Res>(_self.referenceImage, (value) {
    return _then(_self.copyWith(referenceImage: value));
  });
}
}


/// Adds pattern-matching-related methods to [ScanSessionState].
extension ScanSessionStatePatterns on ScanSessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanSessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanSessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanSessionState value)  $default,){
final _that = this;
switch (_that) {
case _ScanSessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanSessionState value)?  $default,){
final _that = this;
switch (_that) {
case _ScanSessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String scanId,  ScanOrigin origin,  AnalysisSource source,  Lang lang,  String? inputText,  String? localImagePath,  Map<PipelineStage, StageState> stages,  AnalyzeResponse? analysis,  PhotoCheck? rejectedPhoto,  RecommendResponse? recommendation,  FacilitiesResponse? facilities,  SearchLocation? dropoffLocation,  Map<String, GeneratedImageState> afterImages,  GeneratedImageState referenceImage,  String? focusItemId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanSessionState() when $default != null:
return $default(_that.scanId,_that.origin,_that.source,_that.lang,_that.inputText,_that.localImagePath,_that.stages,_that.analysis,_that.rejectedPhoto,_that.recommendation,_that.facilities,_that.dropoffLocation,_that.afterImages,_that.referenceImage,_that.focusItemId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String scanId,  ScanOrigin origin,  AnalysisSource source,  Lang lang,  String? inputText,  String? localImagePath,  Map<PipelineStage, StageState> stages,  AnalyzeResponse? analysis,  PhotoCheck? rejectedPhoto,  RecommendResponse? recommendation,  FacilitiesResponse? facilities,  SearchLocation? dropoffLocation,  Map<String, GeneratedImageState> afterImages,  GeneratedImageState referenceImage,  String? focusItemId)  $default,) {final _that = this;
switch (_that) {
case _ScanSessionState():
return $default(_that.scanId,_that.origin,_that.source,_that.lang,_that.inputText,_that.localImagePath,_that.stages,_that.analysis,_that.rejectedPhoto,_that.recommendation,_that.facilities,_that.dropoffLocation,_that.afterImages,_that.referenceImage,_that.focusItemId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String scanId,  ScanOrigin origin,  AnalysisSource source,  Lang lang,  String? inputText,  String? localImagePath,  Map<PipelineStage, StageState> stages,  AnalyzeResponse? analysis,  PhotoCheck? rejectedPhoto,  RecommendResponse? recommendation,  FacilitiesResponse? facilities,  SearchLocation? dropoffLocation,  Map<String, GeneratedImageState> afterImages,  GeneratedImageState referenceImage,  String? focusItemId)?  $default,) {final _that = this;
switch (_that) {
case _ScanSessionState() when $default != null:
return $default(_that.scanId,_that.origin,_that.source,_that.lang,_that.inputText,_that.localImagePath,_that.stages,_that.analysis,_that.rejectedPhoto,_that.recommendation,_that.facilities,_that.dropoffLocation,_that.afterImages,_that.referenceImage,_that.focusItemId);case _:
  return null;

}
}

}

/// @nodoc


class _ScanSessionState extends ScanSessionState {
  const _ScanSessionState({required this.scanId, this.origin = ScanOrigin.loading, this.source = AnalysisSource.image, this.lang = Lang.en, this.inputText, this.localImagePath, final  Map<PipelineStage, StageState> stages = const <PipelineStage, StageState>{}, this.analysis, this.rejectedPhoto, this.recommendation, this.facilities, this.dropoffLocation, final  Map<String, GeneratedImageState> afterImages = const <String, GeneratedImageState>{}, this.referenceImage = const GeneratedImageState(), this.focusItemId}): _stages = stages,_afterImages = afterImages,super._();
  

@override final  String scanId;
@override@JsonKey() final  ScanOrigin origin;
@override@JsonKey() final  AnalysisSource source;
@override@JsonKey() final  Lang lang;
/// The typed description, for text scans.
@override final  String? inputText;
/// The compressed photo on the device (hero image, offline thumbnail).
@override final  String? localImagePath;
 final  Map<PipelineStage, StageState> _stages;
@override@JsonKey() Map<PipelineStage, StageState> get stages {
  if (_stages is EqualUnmodifiableMapView) return _stages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stages);
}

@override final  AnalyzeResponse? analysis;
/// Set when the model judged the photo unusable (blurry, dark, no items):
/// show [PhotoCheck.retakeTip] and a retake button.
@override final  PhotoCheck? rejectedPhoto;
@override final  RecommendResponse? recommendation;
@override final  FacilitiesResponse? facilities;
/// Where the drop-off search ran (GPS, chosen city or nearest city).
@override final  SearchLocation? dropoffLocation;
/// Idea id -> after image.
 final  Map<String, GeneratedImageState> _afterImages;
/// Idea id -> after image.
@override@JsonKey() Map<String, GeneratedImageState> get afterImages {
  if (_afterImages is EqualUnmodifiableMapView) return _afterImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_afterImages);
}

/// Text scans only: a generated photo of the described item, the "before"
/// side of the before/after slider (photo scans use [localImagePath]).
@override@JsonKey() final  GeneratedImageState referenceImage;
/// Item the ideas focus on (null: the analysis' primary item).
@override final  String? focusItemId;

/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanSessionStateCopyWith<_ScanSessionState> get copyWith => __$ScanSessionStateCopyWithImpl<_ScanSessionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanSessionState&&(identical(other.scanId, scanId) || other.scanId == scanId)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.source, source) || other.source == source)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.inputText, inputText) || other.inputText == inputText)&&(identical(other.localImagePath, localImagePath) || other.localImagePath == localImagePath)&&const DeepCollectionEquality().equals(other._stages, _stages)&&(identical(other.analysis, analysis) || other.analysis == analysis)&&(identical(other.rejectedPhoto, rejectedPhoto) || other.rejectedPhoto == rejectedPhoto)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.facilities, facilities) || other.facilities == facilities)&&(identical(other.dropoffLocation, dropoffLocation) || other.dropoffLocation == dropoffLocation)&&const DeepCollectionEquality().equals(other._afterImages, _afterImages)&&(identical(other.referenceImage, referenceImage) || other.referenceImage == referenceImage)&&(identical(other.focusItemId, focusItemId) || other.focusItemId == focusItemId));
}


@override
int get hashCode => Object.hash(runtimeType,scanId,origin,source,lang,inputText,localImagePath,const DeepCollectionEquality().hash(_stages),analysis,rejectedPhoto,recommendation,facilities,dropoffLocation,const DeepCollectionEquality().hash(_afterImages),referenceImage,focusItemId);

@override
String toString() {
  return 'ScanSessionState(scanId: $scanId, origin: $origin, source: $source, lang: $lang, inputText: $inputText, localImagePath: $localImagePath, stages: $stages, analysis: $analysis, rejectedPhoto: $rejectedPhoto, recommendation: $recommendation, facilities: $facilities, dropoffLocation: $dropoffLocation, afterImages: $afterImages, referenceImage: $referenceImage, focusItemId: $focusItemId)';
}


}

/// @nodoc
abstract mixin class _$ScanSessionStateCopyWith<$Res> implements $ScanSessionStateCopyWith<$Res> {
  factory _$ScanSessionStateCopyWith(_ScanSessionState value, $Res Function(_ScanSessionState) _then) = __$ScanSessionStateCopyWithImpl;
@override @useResult
$Res call({
 String scanId, ScanOrigin origin, AnalysisSource source, Lang lang, String? inputText, String? localImagePath, Map<PipelineStage, StageState> stages, AnalyzeResponse? analysis, PhotoCheck? rejectedPhoto, RecommendResponse? recommendation, FacilitiesResponse? facilities, SearchLocation? dropoffLocation, Map<String, GeneratedImageState> afterImages, GeneratedImageState referenceImage, String? focusItemId
});


@override $AnalyzeResponseCopyWith<$Res>? get analysis;@override $PhotoCheckCopyWith<$Res>? get rejectedPhoto;@override $RecommendResponseCopyWith<$Res>? get recommendation;@override $FacilitiesResponseCopyWith<$Res>? get facilities;@override $GeneratedImageStateCopyWith<$Res> get referenceImage;

}
/// @nodoc
class __$ScanSessionStateCopyWithImpl<$Res>
    implements _$ScanSessionStateCopyWith<$Res> {
  __$ScanSessionStateCopyWithImpl(this._self, this._then);

  final _ScanSessionState _self;
  final $Res Function(_ScanSessionState) _then;

/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scanId = null,Object? origin = null,Object? source = null,Object? lang = null,Object? inputText = freezed,Object? localImagePath = freezed,Object? stages = null,Object? analysis = freezed,Object? rejectedPhoto = freezed,Object? recommendation = freezed,Object? facilities = freezed,Object? dropoffLocation = freezed,Object? afterImages = null,Object? referenceImage = null,Object? focusItemId = freezed,}) {
  return _then(_ScanSessionState(
scanId: null == scanId ? _self.scanId : scanId // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as ScanOrigin,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AnalysisSource,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as Lang,inputText: freezed == inputText ? _self.inputText : inputText // ignore: cast_nullable_to_non_nullable
as String?,localImagePath: freezed == localImagePath ? _self.localImagePath : localImagePath // ignore: cast_nullable_to_non_nullable
as String?,stages: null == stages ? _self._stages : stages // ignore: cast_nullable_to_non_nullable
as Map<PipelineStage, StageState>,analysis: freezed == analysis ? _self.analysis : analysis // ignore: cast_nullable_to_non_nullable
as AnalyzeResponse?,rejectedPhoto: freezed == rejectedPhoto ? _self.rejectedPhoto : rejectedPhoto // ignore: cast_nullable_to_non_nullable
as PhotoCheck?,recommendation: freezed == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as RecommendResponse?,facilities: freezed == facilities ? _self.facilities : facilities // ignore: cast_nullable_to_non_nullable
as FacilitiesResponse?,dropoffLocation: freezed == dropoffLocation ? _self.dropoffLocation : dropoffLocation // ignore: cast_nullable_to_non_nullable
as SearchLocation?,afterImages: null == afterImages ? _self._afterImages : afterImages // ignore: cast_nullable_to_non_nullable
as Map<String, GeneratedImageState>,referenceImage: null == referenceImage ? _self.referenceImage : referenceImage // ignore: cast_nullable_to_non_nullable
as GeneratedImageState,focusItemId: freezed == focusItemId ? _self.focusItemId : focusItemId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyzeResponseCopyWith<$Res>? get analysis {
    if (_self.analysis == null) {
    return null;
  }

  return $AnalyzeResponseCopyWith<$Res>(_self.analysis!, (value) {
    return _then(_self.copyWith(analysis: value));
  });
}/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhotoCheckCopyWith<$Res>? get rejectedPhoto {
    if (_self.rejectedPhoto == null) {
    return null;
  }

  return $PhotoCheckCopyWith<$Res>(_self.rejectedPhoto!, (value) {
    return _then(_self.copyWith(rejectedPhoto: value));
  });
}/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecommendResponseCopyWith<$Res>? get recommendation {
    if (_self.recommendation == null) {
    return null;
  }

  return $RecommendResponseCopyWith<$Res>(_self.recommendation!, (value) {
    return _then(_self.copyWith(recommendation: value));
  });
}/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FacilitiesResponseCopyWith<$Res>? get facilities {
    if (_self.facilities == null) {
    return null;
  }

  return $FacilitiesResponseCopyWith<$Res>(_self.facilities!, (value) {
    return _then(_self.copyWith(facilities: value));
  });
}/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneratedImageStateCopyWith<$Res> get referenceImage {
  
  return $GeneratedImageStateCopyWith<$Res>(_self.referenceImage, (value) {
    return _then(_self.copyWith(referenceImage: value));
  });
}
}

/// @nodoc
mixin _$ItemCorrection {

 String? get name; MaterialCategory? get category; String? get material; double? get quantityValue; String? get quantityUnit; int? get qualityScore; List<StateTag>? get state; List<HazardFlag>? get hazards;
/// Create a copy of ItemCorrection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemCorrectionCopyWith<ItemCorrection> get copyWith => _$ItemCorrectionCopyWithImpl<ItemCorrection>(this as ItemCorrection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemCorrection&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.material, material) || other.material == material)&&(identical(other.quantityValue, quantityValue) || other.quantityValue == quantityValue)&&(identical(other.quantityUnit, quantityUnit) || other.quantityUnit == quantityUnit)&&(identical(other.qualityScore, qualityScore) || other.qualityScore == qualityScore)&&const DeepCollectionEquality().equals(other.state, state)&&const DeepCollectionEquality().equals(other.hazards, hazards));
}


@override
int get hashCode => Object.hash(runtimeType,name,category,material,quantityValue,quantityUnit,qualityScore,const DeepCollectionEquality().hash(state),const DeepCollectionEquality().hash(hazards));

@override
String toString() {
  return 'ItemCorrection(name: $name, category: $category, material: $material, quantityValue: $quantityValue, quantityUnit: $quantityUnit, qualityScore: $qualityScore, state: $state, hazards: $hazards)';
}


}

/// @nodoc
abstract mixin class $ItemCorrectionCopyWith<$Res>  {
  factory $ItemCorrectionCopyWith(ItemCorrection value, $Res Function(ItemCorrection) _then) = _$ItemCorrectionCopyWithImpl;
@useResult
$Res call({
 String? name, MaterialCategory? category, String? material, double? quantityValue, String? quantityUnit, int? qualityScore, List<StateTag>? state, List<HazardFlag>? hazards
});




}
/// @nodoc
class _$ItemCorrectionCopyWithImpl<$Res>
    implements $ItemCorrectionCopyWith<$Res> {
  _$ItemCorrectionCopyWithImpl(this._self, this._then);

  final ItemCorrection _self;
  final $Res Function(ItemCorrection) _then;

/// Create a copy of ItemCorrection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? category = freezed,Object? material = freezed,Object? quantityValue = freezed,Object? quantityUnit = freezed,Object? qualityScore = freezed,Object? state = freezed,Object? hazards = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as MaterialCategory?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,quantityValue: freezed == quantityValue ? _self.quantityValue : quantityValue // ignore: cast_nullable_to_non_nullable
as double?,quantityUnit: freezed == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as String?,qualityScore: freezed == qualityScore ? _self.qualityScore : qualityScore // ignore: cast_nullable_to_non_nullable
as int?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as List<StateTag>?,hazards: freezed == hazards ? _self.hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<HazardFlag>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemCorrection].
extension ItemCorrectionPatterns on ItemCorrection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemCorrection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemCorrection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemCorrection value)  $default,){
final _that = this;
switch (_that) {
case _ItemCorrection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemCorrection value)?  $default,){
final _that = this;
switch (_that) {
case _ItemCorrection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  MaterialCategory? category,  String? material,  double? quantityValue,  String? quantityUnit,  int? qualityScore,  List<StateTag>? state,  List<HazardFlag>? hazards)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemCorrection() when $default != null:
return $default(_that.name,_that.category,_that.material,_that.quantityValue,_that.quantityUnit,_that.qualityScore,_that.state,_that.hazards);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  MaterialCategory? category,  String? material,  double? quantityValue,  String? quantityUnit,  int? qualityScore,  List<StateTag>? state,  List<HazardFlag>? hazards)  $default,) {final _that = this;
switch (_that) {
case _ItemCorrection():
return $default(_that.name,_that.category,_that.material,_that.quantityValue,_that.quantityUnit,_that.qualityScore,_that.state,_that.hazards);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  MaterialCategory? category,  String? material,  double? quantityValue,  String? quantityUnit,  int? qualityScore,  List<StateTag>? state,  List<HazardFlag>? hazards)?  $default,) {final _that = this;
switch (_that) {
case _ItemCorrection() when $default != null:
return $default(_that.name,_that.category,_that.material,_that.quantityValue,_that.quantityUnit,_that.qualityScore,_that.state,_that.hazards);case _:
  return null;

}
}

}

/// @nodoc


class _ItemCorrection extends ItemCorrection {
  const _ItemCorrection({this.name, this.category, this.material, this.quantityValue, this.quantityUnit, this.qualityScore, final  List<StateTag>? state, final  List<HazardFlag>? hazards}): _state = state,_hazards = hazards,super._();
  

@override final  String? name;
@override final  MaterialCategory? category;
@override final  String? material;
@override final  double? quantityValue;
@override final  String? quantityUnit;
@override final  int? qualityScore;
 final  List<StateTag>? _state;
@override List<StateTag>? get state {
  final value = _state;
  if (value == null) return null;
  if (_state is EqualUnmodifiableListView) return _state;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<HazardFlag>? _hazards;
@override List<HazardFlag>? get hazards {
  final value = _hazards;
  if (value == null) return null;
  if (_hazards is EqualUnmodifiableListView) return _hazards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ItemCorrection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemCorrectionCopyWith<_ItemCorrection> get copyWith => __$ItemCorrectionCopyWithImpl<_ItemCorrection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemCorrection&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.material, material) || other.material == material)&&(identical(other.quantityValue, quantityValue) || other.quantityValue == quantityValue)&&(identical(other.quantityUnit, quantityUnit) || other.quantityUnit == quantityUnit)&&(identical(other.qualityScore, qualityScore) || other.qualityScore == qualityScore)&&const DeepCollectionEquality().equals(other._state, _state)&&const DeepCollectionEquality().equals(other._hazards, _hazards));
}


@override
int get hashCode => Object.hash(runtimeType,name,category,material,quantityValue,quantityUnit,qualityScore,const DeepCollectionEquality().hash(_state),const DeepCollectionEquality().hash(_hazards));

@override
String toString() {
  return 'ItemCorrection(name: $name, category: $category, material: $material, quantityValue: $quantityValue, quantityUnit: $quantityUnit, qualityScore: $qualityScore, state: $state, hazards: $hazards)';
}


}

/// @nodoc
abstract mixin class _$ItemCorrectionCopyWith<$Res> implements $ItemCorrectionCopyWith<$Res> {
  factory _$ItemCorrectionCopyWith(_ItemCorrection value, $Res Function(_ItemCorrection) _then) = __$ItemCorrectionCopyWithImpl;
@override @useResult
$Res call({
 String? name, MaterialCategory? category, String? material, double? quantityValue, String? quantityUnit, int? qualityScore, List<StateTag>? state, List<HazardFlag>? hazards
});




}
/// @nodoc
class __$ItemCorrectionCopyWithImpl<$Res>
    implements _$ItemCorrectionCopyWith<$Res> {
  __$ItemCorrectionCopyWithImpl(this._self, this._then);

  final _ItemCorrection _self;
  final $Res Function(_ItemCorrection) _then;

/// Create a copy of ItemCorrection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? category = freezed,Object? material = freezed,Object? quantityValue = freezed,Object? quantityUnit = freezed,Object? qualityScore = freezed,Object? state = freezed,Object? hazards = freezed,}) {
  return _then(_ItemCorrection(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as MaterialCategory?,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,quantityValue: freezed == quantityValue ? _self.quantityValue : quantityValue // ignore: cast_nullable_to_non_nullable
as double?,quantityUnit: freezed == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as String?,qualityScore: freezed == qualityScore ? _self.qualityScore : qualityScore // ignore: cast_nullable_to_non_nullable
as int?,state: freezed == state ? _self._state : state // ignore: cast_nullable_to_non_nullable
as List<StateTag>?,hazards: freezed == hazards ? _self._hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<HazardFlag>?,
  ));
}


}

// dart format on
