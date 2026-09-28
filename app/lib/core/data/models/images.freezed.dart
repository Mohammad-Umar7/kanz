// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'images.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AfterImageRequest {

 String get imageId; UpcycleIdea get idea; bool get regenerate;
/// Create a copy of AfterImageRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AfterImageRequestCopyWith<AfterImageRequest> get copyWith => _$AfterImageRequestCopyWithImpl<AfterImageRequest>(this as AfterImageRequest, _$identity);

  /// Serializes this AfterImageRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AfterImageRequest&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.idea, idea) || other.idea == idea)&&(identical(other.regenerate, regenerate) || other.regenerate == regenerate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId,idea,regenerate);

@override
String toString() {
  return 'AfterImageRequest(imageId: $imageId, idea: $idea, regenerate: $regenerate)';
}


}

/// @nodoc
abstract mixin class $AfterImageRequestCopyWith<$Res>  {
  factory $AfterImageRequestCopyWith(AfterImageRequest value, $Res Function(AfterImageRequest) _then) = _$AfterImageRequestCopyWithImpl;
@useResult
$Res call({
 String imageId, UpcycleIdea idea, bool regenerate
});


$UpcycleIdeaCopyWith<$Res> get idea;

}
/// @nodoc
class _$AfterImageRequestCopyWithImpl<$Res>
    implements $AfterImageRequestCopyWith<$Res> {
  _$AfterImageRequestCopyWithImpl(this._self, this._then);

  final AfterImageRequest _self;
  final $Res Function(AfterImageRequest) _then;

/// Create a copy of AfterImageRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imageId = null,Object? idea = null,Object? regenerate = null,}) {
  return _then(_self.copyWith(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,idea: null == idea ? _self.idea : idea // ignore: cast_nullable_to_non_nullable
as UpcycleIdea,regenerate: null == regenerate ? _self.regenerate : regenerate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AfterImageRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpcycleIdeaCopyWith<$Res> get idea {
  
  return $UpcycleIdeaCopyWith<$Res>(_self.idea, (value) {
    return _then(_self.copyWith(idea: value));
  });
}
}


/// Adds pattern-matching-related methods to [AfterImageRequest].
extension AfterImageRequestPatterns on AfterImageRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AfterImageRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AfterImageRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AfterImageRequest value)  $default,){
final _that = this;
switch (_that) {
case _AfterImageRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AfterImageRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AfterImageRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String imageId,  UpcycleIdea idea,  bool regenerate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AfterImageRequest() when $default != null:
return $default(_that.imageId,_that.idea,_that.regenerate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String imageId,  UpcycleIdea idea,  bool regenerate)  $default,) {final _that = this;
switch (_that) {
case _AfterImageRequest():
return $default(_that.imageId,_that.idea,_that.regenerate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String imageId,  UpcycleIdea idea,  bool regenerate)?  $default,) {final _that = this;
switch (_that) {
case _AfterImageRequest() when $default != null:
return $default(_that.imageId,_that.idea,_that.regenerate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AfterImageRequest implements AfterImageRequest {
  const _AfterImageRequest({required this.imageId, required this.idea, this.regenerate = false});
  factory _AfterImageRequest.fromJson(Map<String, dynamic> json) => _$AfterImageRequestFromJson(json);

@override final  String imageId;
@override final  UpcycleIdea idea;
@override@JsonKey() final  bool regenerate;

/// Create a copy of AfterImageRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AfterImageRequestCopyWith<_AfterImageRequest> get copyWith => __$AfterImageRequestCopyWithImpl<_AfterImageRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AfterImageRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AfterImageRequest&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.idea, idea) || other.idea == idea)&&(identical(other.regenerate, regenerate) || other.regenerate == regenerate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId,idea,regenerate);

@override
String toString() {
  return 'AfterImageRequest(imageId: $imageId, idea: $idea, regenerate: $regenerate)';
}


}

/// @nodoc
abstract mixin class _$AfterImageRequestCopyWith<$Res> implements $AfterImageRequestCopyWith<$Res> {
  factory _$AfterImageRequestCopyWith(_AfterImageRequest value, $Res Function(_AfterImageRequest) _then) = __$AfterImageRequestCopyWithImpl;
@override @useResult
$Res call({
 String imageId, UpcycleIdea idea, bool regenerate
});


@override $UpcycleIdeaCopyWith<$Res> get idea;

}
/// @nodoc
class __$AfterImageRequestCopyWithImpl<$Res>
    implements _$AfterImageRequestCopyWith<$Res> {
  __$AfterImageRequestCopyWithImpl(this._self, this._then);

  final _AfterImageRequest _self;
  final $Res Function(_AfterImageRequest) _then;

/// Create a copy of AfterImageRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imageId = null,Object? idea = null,Object? regenerate = null,}) {
  return _then(_AfterImageRequest(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,idea: null == idea ? _self.idea : idea // ignore: cast_nullable_to_non_nullable
as UpcycleIdea,regenerate: null == regenerate ? _self.regenerate : regenerate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AfterImageRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpcycleIdeaCopyWith<$Res> get idea {
  
  return $UpcycleIdeaCopyWith<$Res>(_self.idea, (value) {
    return _then(_self.copyWith(idea: value));
  });
}
}


/// @nodoc
mixin _$StepImageRequest {

 String get imageId; String get tutorialId;/// 1-based; earlier steps are generated first if missing.
 int get step; bool get regenerate;
/// Create a copy of StepImageRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StepImageRequestCopyWith<StepImageRequest> get copyWith => _$StepImageRequestCopyWithImpl<StepImageRequest>(this as StepImageRequest, _$identity);

  /// Serializes this StepImageRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StepImageRequest&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.tutorialId, tutorialId) || other.tutorialId == tutorialId)&&(identical(other.step, step) || other.step == step)&&(identical(other.regenerate, regenerate) || other.regenerate == regenerate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId,tutorialId,step,regenerate);

@override
String toString() {
  return 'StepImageRequest(imageId: $imageId, tutorialId: $tutorialId, step: $step, regenerate: $regenerate)';
}


}

/// @nodoc
abstract mixin class $StepImageRequestCopyWith<$Res>  {
  factory $StepImageRequestCopyWith(StepImageRequest value, $Res Function(StepImageRequest) _then) = _$StepImageRequestCopyWithImpl;
@useResult
$Res call({
 String imageId, String tutorialId, int step, bool regenerate
});




}
/// @nodoc
class _$StepImageRequestCopyWithImpl<$Res>
    implements $StepImageRequestCopyWith<$Res> {
  _$StepImageRequestCopyWithImpl(this._self, this._then);

  final StepImageRequest _self;
  final $Res Function(StepImageRequest) _then;

/// Create a copy of StepImageRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imageId = null,Object? tutorialId = null,Object? step = null,Object? regenerate = null,}) {
  return _then(_self.copyWith(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,tutorialId: null == tutorialId ? _self.tutorialId : tutorialId // ignore: cast_nullable_to_non_nullable
as String,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,regenerate: null == regenerate ? _self.regenerate : regenerate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StepImageRequest].
extension StepImageRequestPatterns on StepImageRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StepImageRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StepImageRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StepImageRequest value)  $default,){
final _that = this;
switch (_that) {
case _StepImageRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StepImageRequest value)?  $default,){
final _that = this;
switch (_that) {
case _StepImageRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String imageId,  String tutorialId,  int step,  bool regenerate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StepImageRequest() when $default != null:
return $default(_that.imageId,_that.tutorialId,_that.step,_that.regenerate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String imageId,  String tutorialId,  int step,  bool regenerate)  $default,) {final _that = this;
switch (_that) {
case _StepImageRequest():
return $default(_that.imageId,_that.tutorialId,_that.step,_that.regenerate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String imageId,  String tutorialId,  int step,  bool regenerate)?  $default,) {final _that = this;
switch (_that) {
case _StepImageRequest() when $default != null:
return $default(_that.imageId,_that.tutorialId,_that.step,_that.regenerate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StepImageRequest implements StepImageRequest {
  const _StepImageRequest({required this.imageId, required this.tutorialId, required this.step, this.regenerate = false});
  factory _StepImageRequest.fromJson(Map<String, dynamic> json) => _$StepImageRequestFromJson(json);

@override final  String imageId;
@override final  String tutorialId;
/// 1-based; earlier steps are generated first if missing.
@override final  int step;
@override@JsonKey() final  bool regenerate;

/// Create a copy of StepImageRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StepImageRequestCopyWith<_StepImageRequest> get copyWith => __$StepImageRequestCopyWithImpl<_StepImageRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StepImageRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StepImageRequest&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.tutorialId, tutorialId) || other.tutorialId == tutorialId)&&(identical(other.step, step) || other.step == step)&&(identical(other.regenerate, regenerate) || other.regenerate == regenerate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId,tutorialId,step,regenerate);

@override
String toString() {
  return 'StepImageRequest(imageId: $imageId, tutorialId: $tutorialId, step: $step, regenerate: $regenerate)';
}


}

/// @nodoc
abstract mixin class _$StepImageRequestCopyWith<$Res> implements $StepImageRequestCopyWith<$Res> {
  factory _$StepImageRequestCopyWith(_StepImageRequest value, $Res Function(_StepImageRequest) _then) = __$StepImageRequestCopyWithImpl;
@override @useResult
$Res call({
 String imageId, String tutorialId, int step, bool regenerate
});




}
/// @nodoc
class __$StepImageRequestCopyWithImpl<$Res>
    implements _$StepImageRequestCopyWith<$Res> {
  __$StepImageRequestCopyWithImpl(this._self, this._then);

  final _StepImageRequest _self;
  final $Res Function(_StepImageRequest) _then;

/// Create a copy of StepImageRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imageId = null,Object? tutorialId = null,Object? step = null,Object? regenerate = null,}) {
  return _then(_StepImageRequest(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,tutorialId: null == tutorialId ? _self.tutorialId : tutorialId // ignore: cast_nullable_to_non_nullable
as String,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,regenerate: null == regenerate ? _self.regenerate : regenerate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$BinImageRequest {

 String get imageId; Item get item; List<String> get prepSteps; bool get regenerate;
/// Create a copy of BinImageRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BinImageRequestCopyWith<BinImageRequest> get copyWith => _$BinImageRequestCopyWithImpl<BinImageRequest>(this as BinImageRequest, _$identity);

  /// Serializes this BinImageRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BinImageRequest&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.item, item) || other.item == item)&&const DeepCollectionEquality().equals(other.prepSteps, prepSteps)&&(identical(other.regenerate, regenerate) || other.regenerate == regenerate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId,item,const DeepCollectionEquality().hash(prepSteps),regenerate);

@override
String toString() {
  return 'BinImageRequest(imageId: $imageId, item: $item, prepSteps: $prepSteps, regenerate: $regenerate)';
}


}

/// @nodoc
abstract mixin class $BinImageRequestCopyWith<$Res>  {
  factory $BinImageRequestCopyWith(BinImageRequest value, $Res Function(BinImageRequest) _then) = _$BinImageRequestCopyWithImpl;
@useResult
$Res call({
 String imageId, Item item, List<String> prepSteps, bool regenerate
});


$ItemCopyWith<$Res> get item;

}
/// @nodoc
class _$BinImageRequestCopyWithImpl<$Res>
    implements $BinImageRequestCopyWith<$Res> {
  _$BinImageRequestCopyWithImpl(this._self, this._then);

  final BinImageRequest _self;
  final $Res Function(BinImageRequest) _then;

/// Create a copy of BinImageRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imageId = null,Object? item = null,Object? prepSteps = null,Object? regenerate = null,}) {
  return _then(_self.copyWith(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as Item,prepSteps: null == prepSteps ? _self.prepSteps : prepSteps // ignore: cast_nullable_to_non_nullable
as List<String>,regenerate: null == regenerate ? _self.regenerate : regenerate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of BinImageRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemCopyWith<$Res> get item {
  
  return $ItemCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}


/// Adds pattern-matching-related methods to [BinImageRequest].
extension BinImageRequestPatterns on BinImageRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BinImageRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BinImageRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BinImageRequest value)  $default,){
final _that = this;
switch (_that) {
case _BinImageRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BinImageRequest value)?  $default,){
final _that = this;
switch (_that) {
case _BinImageRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String imageId,  Item item,  List<String> prepSteps,  bool regenerate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BinImageRequest() when $default != null:
return $default(_that.imageId,_that.item,_that.prepSteps,_that.regenerate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String imageId,  Item item,  List<String> prepSteps,  bool regenerate)  $default,) {final _that = this;
switch (_that) {
case _BinImageRequest():
return $default(_that.imageId,_that.item,_that.prepSteps,_that.regenerate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String imageId,  Item item,  List<String> prepSteps,  bool regenerate)?  $default,) {final _that = this;
switch (_that) {
case _BinImageRequest() when $default != null:
return $default(_that.imageId,_that.item,_that.prepSteps,_that.regenerate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BinImageRequest implements BinImageRequest {
  const _BinImageRequest({required this.imageId, required this.item, final  List<String> prepSteps = const <String>[], this.regenerate = false}): _prepSteps = prepSteps;
  factory _BinImageRequest.fromJson(Map<String, dynamic> json) => _$BinImageRequestFromJson(json);

@override final  String imageId;
@override final  Item item;
 final  List<String> _prepSteps;
@override@JsonKey() List<String> get prepSteps {
  if (_prepSteps is EqualUnmodifiableListView) return _prepSteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_prepSteps);
}

@override@JsonKey() final  bool regenerate;

/// Create a copy of BinImageRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BinImageRequestCopyWith<_BinImageRequest> get copyWith => __$BinImageRequestCopyWithImpl<_BinImageRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BinImageRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BinImageRequest&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.item, item) || other.item == item)&&const DeepCollectionEquality().equals(other._prepSteps, _prepSteps)&&(identical(other.regenerate, regenerate) || other.regenerate == regenerate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId,item,const DeepCollectionEquality().hash(_prepSteps),regenerate);

@override
String toString() {
  return 'BinImageRequest(imageId: $imageId, item: $item, prepSteps: $prepSteps, regenerate: $regenerate)';
}


}

/// @nodoc
abstract mixin class _$BinImageRequestCopyWith<$Res> implements $BinImageRequestCopyWith<$Res> {
  factory _$BinImageRequestCopyWith(_BinImageRequest value, $Res Function(_BinImageRequest) _then) = __$BinImageRequestCopyWithImpl;
@override @useResult
$Res call({
 String imageId, Item item, List<String> prepSteps, bool regenerate
});


@override $ItemCopyWith<$Res> get item;

}
/// @nodoc
class __$BinImageRequestCopyWithImpl<$Res>
    implements _$BinImageRequestCopyWith<$Res> {
  __$BinImageRequestCopyWithImpl(this._self, this._then);

  final _BinImageRequest _self;
  final $Res Function(_BinImageRequest) _then;

/// Create a copy of BinImageRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imageId = null,Object? item = null,Object? prepSteps = null,Object? regenerate = null,}) {
  return _then(_BinImageRequest(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as Item,prepSteps: null == prepSteps ? _self._prepSteps : prepSteps // ignore: cast_nullable_to_non_nullable
as List<String>,regenerate: null == regenerate ? _self.regenerate : regenerate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of BinImageRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemCopyWith<$Res> get item {
  
  return $ItemCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}


/// @nodoc
mixin _$ReferenceImageRequest {

 String get imageId;
/// Create a copy of ReferenceImageRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReferenceImageRequestCopyWith<ReferenceImageRequest> get copyWith => _$ReferenceImageRequestCopyWithImpl<ReferenceImageRequest>(this as ReferenceImageRequest, _$identity);

  /// Serializes this ReferenceImageRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReferenceImageRequest&&(identical(other.imageId, imageId) || other.imageId == imageId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId);

@override
String toString() {
  return 'ReferenceImageRequest(imageId: $imageId)';
}


}

/// @nodoc
abstract mixin class $ReferenceImageRequestCopyWith<$Res>  {
  factory $ReferenceImageRequestCopyWith(ReferenceImageRequest value, $Res Function(ReferenceImageRequest) _then) = _$ReferenceImageRequestCopyWithImpl;
@useResult
$Res call({
 String imageId
});




}
/// @nodoc
class _$ReferenceImageRequestCopyWithImpl<$Res>
    implements $ReferenceImageRequestCopyWith<$Res> {
  _$ReferenceImageRequestCopyWithImpl(this._self, this._then);

  final ReferenceImageRequest _self;
  final $Res Function(ReferenceImageRequest) _then;

/// Create a copy of ReferenceImageRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imageId = null,}) {
  return _then(_self.copyWith(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReferenceImageRequest].
extension ReferenceImageRequestPatterns on ReferenceImageRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReferenceImageRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReferenceImageRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReferenceImageRequest value)  $default,){
final _that = this;
switch (_that) {
case _ReferenceImageRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReferenceImageRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ReferenceImageRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String imageId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReferenceImageRequest() when $default != null:
return $default(_that.imageId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String imageId)  $default,) {final _that = this;
switch (_that) {
case _ReferenceImageRequest():
return $default(_that.imageId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String imageId)?  $default,) {final _that = this;
switch (_that) {
case _ReferenceImageRequest() when $default != null:
return $default(_that.imageId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReferenceImageRequest implements ReferenceImageRequest {
  const _ReferenceImageRequest({required this.imageId});
  factory _ReferenceImageRequest.fromJson(Map<String, dynamic> json) => _$ReferenceImageRequestFromJson(json);

@override final  String imageId;

/// Create a copy of ReferenceImageRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReferenceImageRequestCopyWith<_ReferenceImageRequest> get copyWith => __$ReferenceImageRequestCopyWithImpl<_ReferenceImageRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReferenceImageRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReferenceImageRequest&&(identical(other.imageId, imageId) || other.imageId == imageId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId);

@override
String toString() {
  return 'ReferenceImageRequest(imageId: $imageId)';
}


}

/// @nodoc
abstract mixin class _$ReferenceImageRequestCopyWith<$Res> implements $ReferenceImageRequestCopyWith<$Res> {
  factory _$ReferenceImageRequestCopyWith(_ReferenceImageRequest value, $Res Function(_ReferenceImageRequest) _then) = __$ReferenceImageRequestCopyWithImpl;
@override @useResult
$Res call({
 String imageId
});




}
/// @nodoc
class __$ReferenceImageRequestCopyWithImpl<$Res>
    implements _$ReferenceImageRequestCopyWith<$Res> {
  __$ReferenceImageRequestCopyWithImpl(this._self, this._then);

  final _ReferenceImageRequest _self;
  final $Res Function(_ReferenceImageRequest) _then;

/// Create a copy of ReferenceImageRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imageId = null,}) {
  return _then(_ReferenceImageRequest(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ImageResponse {

/// Path under the API base URL: '/static/generated/img_ab12/after_idea_9f.jpg'.
 String get url; int get width; int get height; ImageKind get kind;/// Cache key: identical requests return the same image.
 String get key; bool get cached; int? get step; SkillLevel? get skill; Timings get timingsMs;
/// Create a copy of ImageResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageResponseCopyWith<ImageResponse> get copyWith => _$ImageResponseCopyWithImpl<ImageResponse>(this as ImageResponse, _$identity);

  /// Serializes this ImageResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageResponse&&(identical(other.url, url) || other.url == url)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.key, key) || other.key == key)&&(identical(other.cached, cached) || other.cached == cached)&&(identical(other.step, step) || other.step == step)&&(identical(other.skill, skill) || other.skill == skill)&&const DeepCollectionEquality().equals(other.timingsMs, timingsMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,width,height,kind,key,cached,step,skill,const DeepCollectionEquality().hash(timingsMs));

@override
String toString() {
  return 'ImageResponse(url: $url, width: $width, height: $height, kind: $kind, key: $key, cached: $cached, step: $step, skill: $skill, timingsMs: $timingsMs)';
}


}

/// @nodoc
abstract mixin class $ImageResponseCopyWith<$Res>  {
  factory $ImageResponseCopyWith(ImageResponse value, $Res Function(ImageResponse) _then) = _$ImageResponseCopyWithImpl;
@useResult
$Res call({
 String url, int width, int height, ImageKind kind, String key, bool cached, int? step, SkillLevel? skill, Timings timingsMs
});




}
/// @nodoc
class _$ImageResponseCopyWithImpl<$Res>
    implements $ImageResponseCopyWith<$Res> {
  _$ImageResponseCopyWithImpl(this._self, this._then);

  final ImageResponse _self;
  final $Res Function(ImageResponse) _then;

/// Create a copy of ImageResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? width = null,Object? height = null,Object? kind = null,Object? key = null,Object? cached = null,Object? step = freezed,Object? skill = freezed,Object? timingsMs = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ImageKind,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,cached: null == cached ? _self.cached : cached // ignore: cast_nullable_to_non_nullable
as bool,step: freezed == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int?,skill: freezed == skill ? _self.skill : skill // ignore: cast_nullable_to_non_nullable
as SkillLevel?,timingsMs: null == timingsMs ? _self.timingsMs : timingsMs // ignore: cast_nullable_to_non_nullable
as Timings,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageResponse].
extension ImageResponsePatterns on ImageResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageResponse value)  $default,){
final _that = this;
switch (_that) {
case _ImageResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ImageResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  int width,  int height,  ImageKind kind,  String key,  bool cached,  int? step,  SkillLevel? skill,  Timings timingsMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageResponse() when $default != null:
return $default(_that.url,_that.width,_that.height,_that.kind,_that.key,_that.cached,_that.step,_that.skill,_that.timingsMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  int width,  int height,  ImageKind kind,  String key,  bool cached,  int? step,  SkillLevel? skill,  Timings timingsMs)  $default,) {final _that = this;
switch (_that) {
case _ImageResponse():
return $default(_that.url,_that.width,_that.height,_that.kind,_that.key,_that.cached,_that.step,_that.skill,_that.timingsMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  int width,  int height,  ImageKind kind,  String key,  bool cached,  int? step,  SkillLevel? skill,  Timings timingsMs)?  $default,) {final _that = this;
switch (_that) {
case _ImageResponse() when $default != null:
return $default(_that.url,_that.width,_that.height,_that.kind,_that.key,_that.cached,_that.step,_that.skill,_that.timingsMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImageResponse implements ImageResponse {
  const _ImageResponse({required this.url, required this.width, required this.height, required this.kind, required this.key, required this.cached, this.step, this.skill, final  Timings timingsMs = const <String, int>{}}): _timingsMs = timingsMs;
  factory _ImageResponse.fromJson(Map<String, dynamic> json) => _$ImageResponseFromJson(json);

/// Path under the API base URL: '/static/generated/img_ab12/after_idea_9f.jpg'.
@override final  String url;
@override final  int width;
@override final  int height;
@override final  ImageKind kind;
/// Cache key: identical requests return the same image.
@override final  String key;
@override final  bool cached;
@override final  int? step;
@override final  SkillLevel? skill;
 final  Timings _timingsMs;
@override@JsonKey() Timings get timingsMs {
  if (_timingsMs is EqualUnmodifiableMapView) return _timingsMs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_timingsMs);
}


/// Create a copy of ImageResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageResponseCopyWith<_ImageResponse> get copyWith => __$ImageResponseCopyWithImpl<_ImageResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageResponse&&(identical(other.url, url) || other.url == url)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.key, key) || other.key == key)&&(identical(other.cached, cached) || other.cached == cached)&&(identical(other.step, step) || other.step == step)&&(identical(other.skill, skill) || other.skill == skill)&&const DeepCollectionEquality().equals(other._timingsMs, _timingsMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,width,height,kind,key,cached,step,skill,const DeepCollectionEquality().hash(_timingsMs));

@override
String toString() {
  return 'ImageResponse(url: $url, width: $width, height: $height, kind: $kind, key: $key, cached: $cached, step: $step, skill: $skill, timingsMs: $timingsMs)';
}


}

/// @nodoc
abstract mixin class _$ImageResponseCopyWith<$Res> implements $ImageResponseCopyWith<$Res> {
  factory _$ImageResponseCopyWith(_ImageResponse value, $Res Function(_ImageResponse) _then) = __$ImageResponseCopyWithImpl;
@override @useResult
$Res call({
 String url, int width, int height, ImageKind kind, String key, bool cached, int? step, SkillLevel? skill, Timings timingsMs
});




}
/// @nodoc
class __$ImageResponseCopyWithImpl<$Res>
    implements _$ImageResponseCopyWith<$Res> {
  __$ImageResponseCopyWithImpl(this._self, this._then);

  final _ImageResponse _self;
  final $Res Function(_ImageResponse) _then;

/// Create a copy of ImageResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? width = null,Object? height = null,Object? kind = null,Object? key = null,Object? cached = null,Object? step = freezed,Object? skill = freezed,Object? timingsMs = null,}) {
  return _then(_ImageResponse(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ImageKind,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,cached: null == cached ? _self.cached : cached // ignore: cast_nullable_to_non_nullable
as bool,step: freezed == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int?,skill: freezed == skill ? _self.skill : skill // ignore: cast_nullable_to_non_nullable
as SkillLevel?,timingsMs: null == timingsMs ? _self._timingsMs : timingsMs // ignore: cast_nullable_to_non_nullable
as Timings,
  ));
}


}

// dart format on
