// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutorial.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TutorialRequest {

 String get imageId; UpcycleIdea get idea;/// The scan items the idea uses; their material and state shape the steps.
 List<Item> get items; Profile get profile;
/// Create a copy of TutorialRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TutorialRequestCopyWith<TutorialRequest> get copyWith => _$TutorialRequestCopyWithImpl<TutorialRequest>(this as TutorialRequest, _$identity);

  /// Serializes this TutorialRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorialRequest&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.idea, idea) || other.idea == idea)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId,idea,const DeepCollectionEquality().hash(items),profile);

@override
String toString() {
  return 'TutorialRequest(imageId: $imageId, idea: $idea, items: $items, profile: $profile)';
}


}

/// @nodoc
abstract mixin class $TutorialRequestCopyWith<$Res>  {
  factory $TutorialRequestCopyWith(TutorialRequest value, $Res Function(TutorialRequest) _then) = _$TutorialRequestCopyWithImpl;
@useResult
$Res call({
 String imageId, UpcycleIdea idea, List<Item> items, Profile profile
});


$UpcycleIdeaCopyWith<$Res> get idea;$ProfileCopyWith<$Res> get profile;

}
/// @nodoc
class _$TutorialRequestCopyWithImpl<$Res>
    implements $TutorialRequestCopyWith<$Res> {
  _$TutorialRequestCopyWithImpl(this._self, this._then);

  final TutorialRequest _self;
  final $Res Function(TutorialRequest) _then;

/// Create a copy of TutorialRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imageId = null,Object? idea = null,Object? items = null,Object? profile = null,}) {
  return _then(_self.copyWith(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,idea: null == idea ? _self.idea : idea // ignore: cast_nullable_to_non_nullable
as UpcycleIdea,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Item>,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile,
  ));
}
/// Create a copy of TutorialRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpcycleIdeaCopyWith<$Res> get idea {
  
  return $UpcycleIdeaCopyWith<$Res>(_self.idea, (value) {
    return _then(_self.copyWith(idea: value));
  });
}/// Create a copy of TutorialRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res> get profile {
  
  return $ProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [TutorialRequest].
extension TutorialRequestPatterns on TutorialRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TutorialRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TutorialRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TutorialRequest value)  $default,){
final _that = this;
switch (_that) {
case _TutorialRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TutorialRequest value)?  $default,){
final _that = this;
switch (_that) {
case _TutorialRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String imageId,  UpcycleIdea idea,  List<Item> items,  Profile profile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TutorialRequest() when $default != null:
return $default(_that.imageId,_that.idea,_that.items,_that.profile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String imageId,  UpcycleIdea idea,  List<Item> items,  Profile profile)  $default,) {final _that = this;
switch (_that) {
case _TutorialRequest():
return $default(_that.imageId,_that.idea,_that.items,_that.profile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String imageId,  UpcycleIdea idea,  List<Item> items,  Profile profile)?  $default,) {final _that = this;
switch (_that) {
case _TutorialRequest() when $default != null:
return $default(_that.imageId,_that.idea,_that.items,_that.profile);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TutorialRequest implements TutorialRequest {
  const _TutorialRequest({required this.imageId, required this.idea, required final  List<Item> items, this.profile = const Profile()}): _items = items;
  factory _TutorialRequest.fromJson(Map<String, dynamic> json) => _$TutorialRequestFromJson(json);

@override final  String imageId;
@override final  UpcycleIdea idea;
/// The scan items the idea uses; their material and state shape the steps.
 final  List<Item> _items;
/// The scan items the idea uses; their material and state shape the steps.
@override List<Item> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  Profile profile;

/// Create a copy of TutorialRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TutorialRequestCopyWith<_TutorialRequest> get copyWith => __$TutorialRequestCopyWithImpl<_TutorialRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TutorialRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TutorialRequest&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.idea, idea) || other.idea == idea)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId,idea,const DeepCollectionEquality().hash(_items),profile);

@override
String toString() {
  return 'TutorialRequest(imageId: $imageId, idea: $idea, items: $items, profile: $profile)';
}


}

/// @nodoc
abstract mixin class _$TutorialRequestCopyWith<$Res> implements $TutorialRequestCopyWith<$Res> {
  factory _$TutorialRequestCopyWith(_TutorialRequest value, $Res Function(_TutorialRequest) _then) = __$TutorialRequestCopyWithImpl;
@override @useResult
$Res call({
 String imageId, UpcycleIdea idea, List<Item> items, Profile profile
});


@override $UpcycleIdeaCopyWith<$Res> get idea;@override $ProfileCopyWith<$Res> get profile;

}
/// @nodoc
class __$TutorialRequestCopyWithImpl<$Res>
    implements _$TutorialRequestCopyWith<$Res> {
  __$TutorialRequestCopyWithImpl(this._self, this._then);

  final _TutorialRequest _self;
  final $Res Function(_TutorialRequest) _then;

/// Create a copy of TutorialRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imageId = null,Object? idea = null,Object? items = null,Object? profile = null,}) {
  return _then(_TutorialRequest(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,idea: null == idea ? _self.idea : idea // ignore: cast_nullable_to_non_nullable
as UpcycleIdea,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Item>,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile,
  ));
}

/// Create a copy of TutorialRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpcycleIdeaCopyWith<$Res> get idea {
  
  return $UpcycleIdeaCopyWith<$Res>(_self.idea, (value) {
    return _then(_self.copyWith(idea: value));
  });
}/// Create a copy of TutorialRequest
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
mixin _$TutorialMaterial {

 String get name; String? get quantity;/// True if it is (part of) a scanned item.
 bool get fromScan; String? get itemId;
/// Create a copy of TutorialMaterial
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TutorialMaterialCopyWith<TutorialMaterial> get copyWith => _$TutorialMaterialCopyWithImpl<TutorialMaterial>(this as TutorialMaterial, _$identity);

  /// Serializes this TutorialMaterial to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorialMaterial&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.fromScan, fromScan) || other.fromScan == fromScan)&&(identical(other.itemId, itemId) || other.itemId == itemId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,quantity,fromScan,itemId);

@override
String toString() {
  return 'TutorialMaterial(name: $name, quantity: $quantity, fromScan: $fromScan, itemId: $itemId)';
}


}

/// @nodoc
abstract mixin class $TutorialMaterialCopyWith<$Res>  {
  factory $TutorialMaterialCopyWith(TutorialMaterial value, $Res Function(TutorialMaterial) _then) = _$TutorialMaterialCopyWithImpl;
@useResult
$Res call({
 String name, String? quantity, bool fromScan, String? itemId
});




}
/// @nodoc
class _$TutorialMaterialCopyWithImpl<$Res>
    implements $TutorialMaterialCopyWith<$Res> {
  _$TutorialMaterialCopyWithImpl(this._self, this._then);

  final TutorialMaterial _self;
  final $Res Function(TutorialMaterial) _then;

/// Create a copy of TutorialMaterial
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? quantity = freezed,Object? fromScan = null,Object? itemId = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String?,fromScan: null == fromScan ? _self.fromScan : fromScan // ignore: cast_nullable_to_non_nullable
as bool,itemId: freezed == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TutorialMaterial].
extension TutorialMaterialPatterns on TutorialMaterial {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TutorialMaterial value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TutorialMaterial() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TutorialMaterial value)  $default,){
final _that = this;
switch (_that) {
case _TutorialMaterial():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TutorialMaterial value)?  $default,){
final _that = this;
switch (_that) {
case _TutorialMaterial() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? quantity,  bool fromScan,  String? itemId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TutorialMaterial() when $default != null:
return $default(_that.name,_that.quantity,_that.fromScan,_that.itemId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? quantity,  bool fromScan,  String? itemId)  $default,) {final _that = this;
switch (_that) {
case _TutorialMaterial():
return $default(_that.name,_that.quantity,_that.fromScan,_that.itemId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? quantity,  bool fromScan,  String? itemId)?  $default,) {final _that = this;
switch (_that) {
case _TutorialMaterial() when $default != null:
return $default(_that.name,_that.quantity,_that.fromScan,_that.itemId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TutorialMaterial implements TutorialMaterial {
  const _TutorialMaterial({required this.name, this.quantity, required this.fromScan, this.itemId});
  factory _TutorialMaterial.fromJson(Map<String, dynamic> json) => _$TutorialMaterialFromJson(json);

@override final  String name;
@override final  String? quantity;
/// True if it is (part of) a scanned item.
@override final  bool fromScan;
@override final  String? itemId;

/// Create a copy of TutorialMaterial
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TutorialMaterialCopyWith<_TutorialMaterial> get copyWith => __$TutorialMaterialCopyWithImpl<_TutorialMaterial>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TutorialMaterialToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TutorialMaterial&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.fromScan, fromScan) || other.fromScan == fromScan)&&(identical(other.itemId, itemId) || other.itemId == itemId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,quantity,fromScan,itemId);

@override
String toString() {
  return 'TutorialMaterial(name: $name, quantity: $quantity, fromScan: $fromScan, itemId: $itemId)';
}


}

/// @nodoc
abstract mixin class _$TutorialMaterialCopyWith<$Res> implements $TutorialMaterialCopyWith<$Res> {
  factory _$TutorialMaterialCopyWith(_TutorialMaterial value, $Res Function(_TutorialMaterial) _then) = __$TutorialMaterialCopyWithImpl;
@override @useResult
$Res call({
 String name, String? quantity, bool fromScan, String? itemId
});




}
/// @nodoc
class __$TutorialMaterialCopyWithImpl<$Res>
    implements _$TutorialMaterialCopyWith<$Res> {
  __$TutorialMaterialCopyWithImpl(this._self, this._then);

  final _TutorialMaterial _self;
  final $Res Function(_TutorialMaterial) _then;

/// Create a copy of TutorialMaterial
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? quantity = freezed,Object? fromScan = null,Object? itemId = freezed,}) {
  return _then(_TutorialMaterial(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String?,fromScan: null == fromScan ? _self.fromScan : fromScan // ignore: cast_nullable_to_non_nullable
as bool,itemId: freezed == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TutorialTool {

 ToolId get toolId; bool get have;/// Localized substitute when the user lacks the tool.
 String? get alternative;
/// Create a copy of TutorialTool
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TutorialToolCopyWith<TutorialTool> get copyWith => _$TutorialToolCopyWithImpl<TutorialTool>(this as TutorialTool, _$identity);

  /// Serializes this TutorialTool to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorialTool&&(identical(other.toolId, toolId) || other.toolId == toolId)&&(identical(other.have, have) || other.have == have)&&(identical(other.alternative, alternative) || other.alternative == alternative));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,toolId,have,alternative);

@override
String toString() {
  return 'TutorialTool(toolId: $toolId, have: $have, alternative: $alternative)';
}


}

/// @nodoc
abstract mixin class $TutorialToolCopyWith<$Res>  {
  factory $TutorialToolCopyWith(TutorialTool value, $Res Function(TutorialTool) _then) = _$TutorialToolCopyWithImpl;
@useResult
$Res call({
 ToolId toolId, bool have, String? alternative
});




}
/// @nodoc
class _$TutorialToolCopyWithImpl<$Res>
    implements $TutorialToolCopyWith<$Res> {
  _$TutorialToolCopyWithImpl(this._self, this._then);

  final TutorialTool _self;
  final $Res Function(TutorialTool) _then;

/// Create a copy of TutorialTool
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? toolId = null,Object? have = null,Object? alternative = freezed,}) {
  return _then(_self.copyWith(
toolId: null == toolId ? _self.toolId : toolId // ignore: cast_nullable_to_non_nullable
as ToolId,have: null == have ? _self.have : have // ignore: cast_nullable_to_non_nullable
as bool,alternative: freezed == alternative ? _self.alternative : alternative // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TutorialTool].
extension TutorialToolPatterns on TutorialTool {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TutorialTool value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TutorialTool() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TutorialTool value)  $default,){
final _that = this;
switch (_that) {
case _TutorialTool():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TutorialTool value)?  $default,){
final _that = this;
switch (_that) {
case _TutorialTool() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ToolId toolId,  bool have,  String? alternative)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TutorialTool() when $default != null:
return $default(_that.toolId,_that.have,_that.alternative);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ToolId toolId,  bool have,  String? alternative)  $default,) {final _that = this;
switch (_that) {
case _TutorialTool():
return $default(_that.toolId,_that.have,_that.alternative);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ToolId toolId,  bool have,  String? alternative)?  $default,) {final _that = this;
switch (_that) {
case _TutorialTool() when $default != null:
return $default(_that.toolId,_that.have,_that.alternative);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TutorialTool implements TutorialTool {
  const _TutorialTool({required this.toolId, required this.have, this.alternative});
  factory _TutorialTool.fromJson(Map<String, dynamic> json) => _$TutorialToolFromJson(json);

@override final  ToolId toolId;
@override final  bool have;
/// Localized substitute when the user lacks the tool.
@override final  String? alternative;

/// Create a copy of TutorialTool
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TutorialToolCopyWith<_TutorialTool> get copyWith => __$TutorialToolCopyWithImpl<_TutorialTool>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TutorialToolToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TutorialTool&&(identical(other.toolId, toolId) || other.toolId == toolId)&&(identical(other.have, have) || other.have == have)&&(identical(other.alternative, alternative) || other.alternative == alternative));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,toolId,have,alternative);

@override
String toString() {
  return 'TutorialTool(toolId: $toolId, have: $have, alternative: $alternative)';
}


}

/// @nodoc
abstract mixin class _$TutorialToolCopyWith<$Res> implements $TutorialToolCopyWith<$Res> {
  factory _$TutorialToolCopyWith(_TutorialTool value, $Res Function(_TutorialTool) _then) = __$TutorialToolCopyWithImpl;
@override @useResult
$Res call({
 ToolId toolId, bool have, String? alternative
});




}
/// @nodoc
class __$TutorialToolCopyWithImpl<$Res>
    implements _$TutorialToolCopyWith<$Res> {
  __$TutorialToolCopyWithImpl(this._self, this._then);

  final _TutorialTool _self;
  final $Res Function(_TutorialTool) _then;

/// Create a copy of TutorialTool
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? toolId = null,Object? have = null,Object? alternative = freezed,}) {
  return _then(_TutorialTool(
toolId: null == toolId ? _self.toolId : toolId // ignore: cast_nullable_to_non_nullable
as ToolId,have: null == have ? _self.have : have // ignore: cast_nullable_to_non_nullable
as bool,alternative: freezed == alternative ? _self.alternative : alternative // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TutorialStep {

/// 1-based.
 int get number; String get title; String get instruction; String? get tip; String? get warning; int get durationMinutes;/// English: what the object looks like right after this step (drives the step image).
 String get imagePrompt;
/// Create a copy of TutorialStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TutorialStepCopyWith<TutorialStep> get copyWith => _$TutorialStepCopyWithImpl<TutorialStep>(this as TutorialStep, _$identity);

  /// Serializes this TutorialStep to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorialStep&&(identical(other.number, number) || other.number == number)&&(identical(other.title, title) || other.title == title)&&(identical(other.instruction, instruction) || other.instruction == instruction)&&(identical(other.tip, tip) || other.tip == tip)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.imagePrompt, imagePrompt) || other.imagePrompt == imagePrompt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,title,instruction,tip,warning,durationMinutes,imagePrompt);

@override
String toString() {
  return 'TutorialStep(number: $number, title: $title, instruction: $instruction, tip: $tip, warning: $warning, durationMinutes: $durationMinutes, imagePrompt: $imagePrompt)';
}


}

/// @nodoc
abstract mixin class $TutorialStepCopyWith<$Res>  {
  factory $TutorialStepCopyWith(TutorialStep value, $Res Function(TutorialStep) _then) = _$TutorialStepCopyWithImpl;
@useResult
$Res call({
 int number, String title, String instruction, String? tip, String? warning, int durationMinutes, String imagePrompt
});




}
/// @nodoc
class _$TutorialStepCopyWithImpl<$Res>
    implements $TutorialStepCopyWith<$Res> {
  _$TutorialStepCopyWithImpl(this._self, this._then);

  final TutorialStep _self;
  final $Res Function(TutorialStep) _then;

/// Create a copy of TutorialStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? title = null,Object? instruction = null,Object? tip = freezed,Object? warning = freezed,Object? durationMinutes = null,Object? imagePrompt = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,instruction: null == instruction ? _self.instruction : instruction // ignore: cast_nullable_to_non_nullable
as String,tip: freezed == tip ? _self.tip : tip // ignore: cast_nullable_to_non_nullable
as String?,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,imagePrompt: null == imagePrompt ? _self.imagePrompt : imagePrompt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TutorialStep].
extension TutorialStepPatterns on TutorialStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TutorialStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TutorialStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TutorialStep value)  $default,){
final _that = this;
switch (_that) {
case _TutorialStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TutorialStep value)?  $default,){
final _that = this;
switch (_that) {
case _TutorialStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number,  String title,  String instruction,  String? tip,  String? warning,  int durationMinutes,  String imagePrompt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TutorialStep() when $default != null:
return $default(_that.number,_that.title,_that.instruction,_that.tip,_that.warning,_that.durationMinutes,_that.imagePrompt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number,  String title,  String instruction,  String? tip,  String? warning,  int durationMinutes,  String imagePrompt)  $default,) {final _that = this;
switch (_that) {
case _TutorialStep():
return $default(_that.number,_that.title,_that.instruction,_that.tip,_that.warning,_that.durationMinutes,_that.imagePrompt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number,  String title,  String instruction,  String? tip,  String? warning,  int durationMinutes,  String imagePrompt)?  $default,) {final _that = this;
switch (_that) {
case _TutorialStep() when $default != null:
return $default(_that.number,_that.title,_that.instruction,_that.tip,_that.warning,_that.durationMinutes,_that.imagePrompt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TutorialStep implements TutorialStep {
  const _TutorialStep({required this.number, required this.title, required this.instruction, this.tip, this.warning, required this.durationMinutes, required this.imagePrompt});
  factory _TutorialStep.fromJson(Map<String, dynamic> json) => _$TutorialStepFromJson(json);

/// 1-based.
@override final  int number;
@override final  String title;
@override final  String instruction;
@override final  String? tip;
@override final  String? warning;
@override final  int durationMinutes;
/// English: what the object looks like right after this step (drives the step image).
@override final  String imagePrompt;

/// Create a copy of TutorialStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TutorialStepCopyWith<_TutorialStep> get copyWith => __$TutorialStepCopyWithImpl<_TutorialStep>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TutorialStepToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TutorialStep&&(identical(other.number, number) || other.number == number)&&(identical(other.title, title) || other.title == title)&&(identical(other.instruction, instruction) || other.instruction == instruction)&&(identical(other.tip, tip) || other.tip == tip)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.imagePrompt, imagePrompt) || other.imagePrompt == imagePrompt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,title,instruction,tip,warning,durationMinutes,imagePrompt);

@override
String toString() {
  return 'TutorialStep(number: $number, title: $title, instruction: $instruction, tip: $tip, warning: $warning, durationMinutes: $durationMinutes, imagePrompt: $imagePrompt)';
}


}

/// @nodoc
abstract mixin class _$TutorialStepCopyWith<$Res> implements $TutorialStepCopyWith<$Res> {
  factory _$TutorialStepCopyWith(_TutorialStep value, $Res Function(_TutorialStep) _then) = __$TutorialStepCopyWithImpl;
@override @useResult
$Res call({
 int number, String title, String instruction, String? tip, String? warning, int durationMinutes, String imagePrompt
});




}
/// @nodoc
class __$TutorialStepCopyWithImpl<$Res>
    implements _$TutorialStepCopyWith<$Res> {
  __$TutorialStepCopyWithImpl(this._self, this._then);

  final _TutorialStep _self;
  final $Res Function(_TutorialStep) _then;

/// Create a copy of TutorialStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? title = null,Object? instruction = null,Object? tip = freezed,Object? warning = freezed,Object? durationMinutes = null,Object? imagePrompt = null,}) {
  return _then(_TutorialStep(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,instruction: null == instruction ? _self.instruction : instruction // ignore: cast_nullable_to_non_nullable
as String,tip: freezed == tip ? _self.tip : tip // ignore: cast_nullable_to_non_nullable
as String?,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,imagePrompt: null == imagePrompt ? _self.imagePrompt : imagePrompt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Tutorial {

/// 'tut_<hash>' of (image_id, idea.id, skill, tools, lang).
 String get tutorialId; String get ideaId; String get imageId; String get title;/// Localized: 'Adapted for Beginner, no drill needed'.
 String get adaptedNote; SkillLevel get skill; int get totalMinutes; List<TutorialMaterial> get materials; List<TutorialTool> get tools; List<String> get safety;/// 5 to 8 steps.
 List<TutorialStep> get steps; List<String> get finishing; List<String> get care; List<SourceRef> get sources; Lang get lang;
/// Create a copy of Tutorial
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TutorialCopyWith<Tutorial> get copyWith => _$TutorialCopyWithImpl<Tutorial>(this as Tutorial, _$identity);

  /// Serializes this Tutorial to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tutorial&&(identical(other.tutorialId, tutorialId) || other.tutorialId == tutorialId)&&(identical(other.ideaId, ideaId) || other.ideaId == ideaId)&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.title, title) || other.title == title)&&(identical(other.adaptedNote, adaptedNote) || other.adaptedNote == adaptedNote)&&(identical(other.skill, skill) || other.skill == skill)&&(identical(other.totalMinutes, totalMinutes) || other.totalMinutes == totalMinutes)&&const DeepCollectionEquality().equals(other.materials, materials)&&const DeepCollectionEquality().equals(other.tools, tools)&&const DeepCollectionEquality().equals(other.safety, safety)&&const DeepCollectionEquality().equals(other.steps, steps)&&const DeepCollectionEquality().equals(other.finishing, finishing)&&const DeepCollectionEquality().equals(other.care, care)&&const DeepCollectionEquality().equals(other.sources, sources)&&(identical(other.lang, lang) || other.lang == lang));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tutorialId,ideaId,imageId,title,adaptedNote,skill,totalMinutes,const DeepCollectionEquality().hash(materials),const DeepCollectionEquality().hash(tools),const DeepCollectionEquality().hash(safety),const DeepCollectionEquality().hash(steps),const DeepCollectionEquality().hash(finishing),const DeepCollectionEquality().hash(care),const DeepCollectionEquality().hash(sources),lang);

@override
String toString() {
  return 'Tutorial(tutorialId: $tutorialId, ideaId: $ideaId, imageId: $imageId, title: $title, adaptedNote: $adaptedNote, skill: $skill, totalMinutes: $totalMinutes, materials: $materials, tools: $tools, safety: $safety, steps: $steps, finishing: $finishing, care: $care, sources: $sources, lang: $lang)';
}


}

/// @nodoc
abstract mixin class $TutorialCopyWith<$Res>  {
  factory $TutorialCopyWith(Tutorial value, $Res Function(Tutorial) _then) = _$TutorialCopyWithImpl;
@useResult
$Res call({
 String tutorialId, String ideaId, String imageId, String title, String adaptedNote, SkillLevel skill, int totalMinutes, List<TutorialMaterial> materials, List<TutorialTool> tools, List<String> safety, List<TutorialStep> steps, List<String> finishing, List<String> care, List<SourceRef> sources, Lang lang
});




}
/// @nodoc
class _$TutorialCopyWithImpl<$Res>
    implements $TutorialCopyWith<$Res> {
  _$TutorialCopyWithImpl(this._self, this._then);

  final Tutorial _self;
  final $Res Function(Tutorial) _then;

/// Create a copy of Tutorial
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tutorialId = null,Object? ideaId = null,Object? imageId = null,Object? title = null,Object? adaptedNote = null,Object? skill = null,Object? totalMinutes = null,Object? materials = null,Object? tools = null,Object? safety = null,Object? steps = null,Object? finishing = null,Object? care = null,Object? sources = null,Object? lang = null,}) {
  return _then(_self.copyWith(
tutorialId: null == tutorialId ? _self.tutorialId : tutorialId // ignore: cast_nullable_to_non_nullable
as String,ideaId: null == ideaId ? _self.ideaId : ideaId // ignore: cast_nullable_to_non_nullable
as String,imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,adaptedNote: null == adaptedNote ? _self.adaptedNote : adaptedNote // ignore: cast_nullable_to_non_nullable
as String,skill: null == skill ? _self.skill : skill // ignore: cast_nullable_to_non_nullable
as SkillLevel,totalMinutes: null == totalMinutes ? _self.totalMinutes : totalMinutes // ignore: cast_nullable_to_non_nullable
as int,materials: null == materials ? _self.materials : materials // ignore: cast_nullable_to_non_nullable
as List<TutorialMaterial>,tools: null == tools ? _self.tools : tools // ignore: cast_nullable_to_non_nullable
as List<TutorialTool>,safety: null == safety ? _self.safety : safety // ignore: cast_nullable_to_non_nullable
as List<String>,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<TutorialStep>,finishing: null == finishing ? _self.finishing : finishing // ignore: cast_nullable_to_non_nullable
as List<String>,care: null == care ? _self.care : care // ignore: cast_nullable_to_non_nullable
as List<String>,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<SourceRef>,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as Lang,
  ));
}

}


/// Adds pattern-matching-related methods to [Tutorial].
extension TutorialPatterns on Tutorial {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tutorial value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tutorial() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tutorial value)  $default,){
final _that = this;
switch (_that) {
case _Tutorial():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tutorial value)?  $default,){
final _that = this;
switch (_that) {
case _Tutorial() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tutorialId,  String ideaId,  String imageId,  String title,  String adaptedNote,  SkillLevel skill,  int totalMinutes,  List<TutorialMaterial> materials,  List<TutorialTool> tools,  List<String> safety,  List<TutorialStep> steps,  List<String> finishing,  List<String> care,  List<SourceRef> sources,  Lang lang)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tutorial() when $default != null:
return $default(_that.tutorialId,_that.ideaId,_that.imageId,_that.title,_that.adaptedNote,_that.skill,_that.totalMinutes,_that.materials,_that.tools,_that.safety,_that.steps,_that.finishing,_that.care,_that.sources,_that.lang);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tutorialId,  String ideaId,  String imageId,  String title,  String adaptedNote,  SkillLevel skill,  int totalMinutes,  List<TutorialMaterial> materials,  List<TutorialTool> tools,  List<String> safety,  List<TutorialStep> steps,  List<String> finishing,  List<String> care,  List<SourceRef> sources,  Lang lang)  $default,) {final _that = this;
switch (_that) {
case _Tutorial():
return $default(_that.tutorialId,_that.ideaId,_that.imageId,_that.title,_that.adaptedNote,_that.skill,_that.totalMinutes,_that.materials,_that.tools,_that.safety,_that.steps,_that.finishing,_that.care,_that.sources,_that.lang);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tutorialId,  String ideaId,  String imageId,  String title,  String adaptedNote,  SkillLevel skill,  int totalMinutes,  List<TutorialMaterial> materials,  List<TutorialTool> tools,  List<String> safety,  List<TutorialStep> steps,  List<String> finishing,  List<String> care,  List<SourceRef> sources,  Lang lang)?  $default,) {final _that = this;
switch (_that) {
case _Tutorial() when $default != null:
return $default(_that.tutorialId,_that.ideaId,_that.imageId,_that.title,_that.adaptedNote,_that.skill,_that.totalMinutes,_that.materials,_that.tools,_that.safety,_that.steps,_that.finishing,_that.care,_that.sources,_that.lang);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Tutorial implements Tutorial {
  const _Tutorial({required this.tutorialId, required this.ideaId, required this.imageId, required this.title, required this.adaptedNote, required this.skill, required this.totalMinutes, required final  List<TutorialMaterial> materials, required final  List<TutorialTool> tools, required final  List<String> safety, required final  List<TutorialStep> steps, final  List<String> finishing = const <String>[], final  List<String> care = const <String>[], final  List<SourceRef> sources = const <SourceRef>[], required this.lang}): _materials = materials,_tools = tools,_safety = safety,_steps = steps,_finishing = finishing,_care = care,_sources = sources;
  factory _Tutorial.fromJson(Map<String, dynamic> json) => _$TutorialFromJson(json);

/// 'tut_<hash>' of (image_id, idea.id, skill, tools, lang).
@override final  String tutorialId;
@override final  String ideaId;
@override final  String imageId;
@override final  String title;
/// Localized: 'Adapted for Beginner, no drill needed'.
@override final  String adaptedNote;
@override final  SkillLevel skill;
@override final  int totalMinutes;
 final  List<TutorialMaterial> _materials;
@override List<TutorialMaterial> get materials {
  if (_materials is EqualUnmodifiableListView) return _materials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_materials);
}

 final  List<TutorialTool> _tools;
@override List<TutorialTool> get tools {
  if (_tools is EqualUnmodifiableListView) return _tools;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tools);
}

 final  List<String> _safety;
@override List<String> get safety {
  if (_safety is EqualUnmodifiableListView) return _safety;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_safety);
}

/// 5 to 8 steps.
 final  List<TutorialStep> _steps;
/// 5 to 8 steps.
@override List<TutorialStep> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}

 final  List<String> _finishing;
@override@JsonKey() List<String> get finishing {
  if (_finishing is EqualUnmodifiableListView) return _finishing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_finishing);
}

 final  List<String> _care;
@override@JsonKey() List<String> get care {
  if (_care is EqualUnmodifiableListView) return _care;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_care);
}

 final  List<SourceRef> _sources;
@override@JsonKey() List<SourceRef> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}

@override final  Lang lang;

/// Create a copy of Tutorial
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TutorialCopyWith<_Tutorial> get copyWith => __$TutorialCopyWithImpl<_Tutorial>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TutorialToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tutorial&&(identical(other.tutorialId, tutorialId) || other.tutorialId == tutorialId)&&(identical(other.ideaId, ideaId) || other.ideaId == ideaId)&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.title, title) || other.title == title)&&(identical(other.adaptedNote, adaptedNote) || other.adaptedNote == adaptedNote)&&(identical(other.skill, skill) || other.skill == skill)&&(identical(other.totalMinutes, totalMinutes) || other.totalMinutes == totalMinutes)&&const DeepCollectionEquality().equals(other._materials, _materials)&&const DeepCollectionEquality().equals(other._tools, _tools)&&const DeepCollectionEquality().equals(other._safety, _safety)&&const DeepCollectionEquality().equals(other._steps, _steps)&&const DeepCollectionEquality().equals(other._finishing, _finishing)&&const DeepCollectionEquality().equals(other._care, _care)&&const DeepCollectionEquality().equals(other._sources, _sources)&&(identical(other.lang, lang) || other.lang == lang));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tutorialId,ideaId,imageId,title,adaptedNote,skill,totalMinutes,const DeepCollectionEquality().hash(_materials),const DeepCollectionEquality().hash(_tools),const DeepCollectionEquality().hash(_safety),const DeepCollectionEquality().hash(_steps),const DeepCollectionEquality().hash(_finishing),const DeepCollectionEquality().hash(_care),const DeepCollectionEquality().hash(_sources),lang);

@override
String toString() {
  return 'Tutorial(tutorialId: $tutorialId, ideaId: $ideaId, imageId: $imageId, title: $title, adaptedNote: $adaptedNote, skill: $skill, totalMinutes: $totalMinutes, materials: $materials, tools: $tools, safety: $safety, steps: $steps, finishing: $finishing, care: $care, sources: $sources, lang: $lang)';
}


}

/// @nodoc
abstract mixin class _$TutorialCopyWith<$Res> implements $TutorialCopyWith<$Res> {
  factory _$TutorialCopyWith(_Tutorial value, $Res Function(_Tutorial) _then) = __$TutorialCopyWithImpl;
@override @useResult
$Res call({
 String tutorialId, String ideaId, String imageId, String title, String adaptedNote, SkillLevel skill, int totalMinutes, List<TutorialMaterial> materials, List<TutorialTool> tools, List<String> safety, List<TutorialStep> steps, List<String> finishing, List<String> care, List<SourceRef> sources, Lang lang
});




}
/// @nodoc
class __$TutorialCopyWithImpl<$Res>
    implements _$TutorialCopyWith<$Res> {
  __$TutorialCopyWithImpl(this._self, this._then);

  final _Tutorial _self;
  final $Res Function(_Tutorial) _then;

/// Create a copy of Tutorial
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tutorialId = null,Object? ideaId = null,Object? imageId = null,Object? title = null,Object? adaptedNote = null,Object? skill = null,Object? totalMinutes = null,Object? materials = null,Object? tools = null,Object? safety = null,Object? steps = null,Object? finishing = null,Object? care = null,Object? sources = null,Object? lang = null,}) {
  return _then(_Tutorial(
tutorialId: null == tutorialId ? _self.tutorialId : tutorialId // ignore: cast_nullable_to_non_nullable
as String,ideaId: null == ideaId ? _self.ideaId : ideaId // ignore: cast_nullable_to_non_nullable
as String,imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,adaptedNote: null == adaptedNote ? _self.adaptedNote : adaptedNote // ignore: cast_nullable_to_non_nullable
as String,skill: null == skill ? _self.skill : skill // ignore: cast_nullable_to_non_nullable
as SkillLevel,totalMinutes: null == totalMinutes ? _self.totalMinutes : totalMinutes // ignore: cast_nullable_to_non_nullable
as int,materials: null == materials ? _self._materials : materials // ignore: cast_nullable_to_non_nullable
as List<TutorialMaterial>,tools: null == tools ? _self._tools : tools // ignore: cast_nullable_to_non_nullable
as List<TutorialTool>,safety: null == safety ? _self._safety : safety // ignore: cast_nullable_to_non_nullable
as List<String>,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<TutorialStep>,finishing: null == finishing ? _self._finishing : finishing // ignore: cast_nullable_to_non_nullable
as List<String>,care: null == care ? _self._care : care // ignore: cast_nullable_to_non_nullable
as List<String>,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<SourceRef>,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as Lang,
  ));
}


}


/// @nodoc
mixin _$TutorialResponse {

 Tutorial get tutorial; Timings get timingsMs;
/// Create a copy of TutorialResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TutorialResponseCopyWith<TutorialResponse> get copyWith => _$TutorialResponseCopyWithImpl<TutorialResponse>(this as TutorialResponse, _$identity);

  /// Serializes this TutorialResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorialResponse&&(identical(other.tutorial, tutorial) || other.tutorial == tutorial)&&const DeepCollectionEquality().equals(other.timingsMs, timingsMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tutorial,const DeepCollectionEquality().hash(timingsMs));

@override
String toString() {
  return 'TutorialResponse(tutorial: $tutorial, timingsMs: $timingsMs)';
}


}

/// @nodoc
abstract mixin class $TutorialResponseCopyWith<$Res>  {
  factory $TutorialResponseCopyWith(TutorialResponse value, $Res Function(TutorialResponse) _then) = _$TutorialResponseCopyWithImpl;
@useResult
$Res call({
 Tutorial tutorial, Timings timingsMs
});


$TutorialCopyWith<$Res> get tutorial;

}
/// @nodoc
class _$TutorialResponseCopyWithImpl<$Res>
    implements $TutorialResponseCopyWith<$Res> {
  _$TutorialResponseCopyWithImpl(this._self, this._then);

  final TutorialResponse _self;
  final $Res Function(TutorialResponse) _then;

/// Create a copy of TutorialResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tutorial = null,Object? timingsMs = null,}) {
  return _then(_self.copyWith(
tutorial: null == tutorial ? _self.tutorial : tutorial // ignore: cast_nullable_to_non_nullable
as Tutorial,timingsMs: null == timingsMs ? _self.timingsMs : timingsMs // ignore: cast_nullable_to_non_nullable
as Timings,
  ));
}
/// Create a copy of TutorialResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TutorialCopyWith<$Res> get tutorial {
  
  return $TutorialCopyWith<$Res>(_self.tutorial, (value) {
    return _then(_self.copyWith(tutorial: value));
  });
}
}


/// Adds pattern-matching-related methods to [TutorialResponse].
extension TutorialResponsePatterns on TutorialResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TutorialResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TutorialResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TutorialResponse value)  $default,){
final _that = this;
switch (_that) {
case _TutorialResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TutorialResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TutorialResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Tutorial tutorial,  Timings timingsMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TutorialResponse() when $default != null:
return $default(_that.tutorial,_that.timingsMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Tutorial tutorial,  Timings timingsMs)  $default,) {final _that = this;
switch (_that) {
case _TutorialResponse():
return $default(_that.tutorial,_that.timingsMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Tutorial tutorial,  Timings timingsMs)?  $default,) {final _that = this;
switch (_that) {
case _TutorialResponse() when $default != null:
return $default(_that.tutorial,_that.timingsMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TutorialResponse implements TutorialResponse {
  const _TutorialResponse({required this.tutorial, final  Timings timingsMs = const <String, int>{}}): _timingsMs = timingsMs;
  factory _TutorialResponse.fromJson(Map<String, dynamic> json) => _$TutorialResponseFromJson(json);

@override final  Tutorial tutorial;
 final  Timings _timingsMs;
@override@JsonKey() Timings get timingsMs {
  if (_timingsMs is EqualUnmodifiableMapView) return _timingsMs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_timingsMs);
}


/// Create a copy of TutorialResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TutorialResponseCopyWith<_TutorialResponse> get copyWith => __$TutorialResponseCopyWithImpl<_TutorialResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TutorialResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TutorialResponse&&(identical(other.tutorial, tutorial) || other.tutorial == tutorial)&&const DeepCollectionEquality().equals(other._timingsMs, _timingsMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tutorial,const DeepCollectionEquality().hash(_timingsMs));

@override
String toString() {
  return 'TutorialResponse(tutorial: $tutorial, timingsMs: $timingsMs)';
}


}

/// @nodoc
abstract mixin class _$TutorialResponseCopyWith<$Res> implements $TutorialResponseCopyWith<$Res> {
  factory _$TutorialResponseCopyWith(_TutorialResponse value, $Res Function(_TutorialResponse) _then) = __$TutorialResponseCopyWithImpl;
@override @useResult
$Res call({
 Tutorial tutorial, Timings timingsMs
});


@override $TutorialCopyWith<$Res> get tutorial;

}
/// @nodoc
class __$TutorialResponseCopyWithImpl<$Res>
    implements _$TutorialResponseCopyWith<$Res> {
  __$TutorialResponseCopyWithImpl(this._self, this._then);

  final _TutorialResponse _self;
  final $Res Function(_TutorialResponse) _then;

/// Create a copy of TutorialResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tutorial = null,Object? timingsMs = null,}) {
  return _then(_TutorialResponse(
tutorial: null == tutorial ? _self.tutorial : tutorial // ignore: cast_nullable_to_non_nullable
as Tutorial,timingsMs: null == timingsMs ? _self._timingsMs : timingsMs // ignore: cast_nullable_to_non_nullable
as Timings,
  ));
}

/// Create a copy of TutorialResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TutorialCopyWith<$Res> get tutorial {
  
  return $TutorialCopyWith<$Res>(_self.tutorial, (value) {
    return _then(_self.copyWith(tutorial: value));
  });
}
}

// dart format on
