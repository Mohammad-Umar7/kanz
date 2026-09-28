// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analysis.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BBox {

 double get x; double get y; double get w; double get h;
/// Create a copy of BBox
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BBoxCopyWith<BBox> get copyWith => _$BBoxCopyWithImpl<BBox>(this as BBox, _$identity);

  /// Serializes this BBox to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BBox&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.w, w) || other.w == w)&&(identical(other.h, h) || other.h == h));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y,w,h);

@override
String toString() {
  return 'BBox(x: $x, y: $y, w: $w, h: $h)';
}


}

/// @nodoc
abstract mixin class $BBoxCopyWith<$Res>  {
  factory $BBoxCopyWith(BBox value, $Res Function(BBox) _then) = _$BBoxCopyWithImpl;
@useResult
$Res call({
 double x, double y, double w, double h
});




}
/// @nodoc
class _$BBoxCopyWithImpl<$Res>
    implements $BBoxCopyWith<$Res> {
  _$BBoxCopyWithImpl(this._self, this._then);

  final BBox _self;
  final $Res Function(BBox) _then;

/// Create a copy of BBox
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? y = null,Object? w = null,Object? h = null,}) {
  return _then(_self.copyWith(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,w: null == w ? _self.w : w // ignore: cast_nullable_to_non_nullable
as double,h: null == h ? _self.h : h // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BBox].
extension BBoxPatterns on BBox {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BBox value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BBox() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BBox value)  $default,){
final _that = this;
switch (_that) {
case _BBox():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BBox value)?  $default,){
final _that = this;
switch (_that) {
case _BBox() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double x,  double y,  double w,  double h)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BBox() when $default != null:
return $default(_that.x,_that.y,_that.w,_that.h);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double x,  double y,  double w,  double h)  $default,) {final _that = this;
switch (_that) {
case _BBox():
return $default(_that.x,_that.y,_that.w,_that.h);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double x,  double y,  double w,  double h)?  $default,) {final _that = this;
switch (_that) {
case _BBox() when $default != null:
return $default(_that.x,_that.y,_that.w,_that.h);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BBox implements BBox {
  const _BBox({required this.x, required this.y, required this.w, required this.h});
  factory _BBox.fromJson(Map<String, dynamic> json) => _$BBoxFromJson(json);

@override final  double x;
@override final  double y;
@override final  double w;
@override final  double h;

/// Create a copy of BBox
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BBoxCopyWith<_BBox> get copyWith => __$BBoxCopyWithImpl<_BBox>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BBoxToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BBox&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.w, w) || other.w == w)&&(identical(other.h, h) || other.h == h));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y,w,h);

@override
String toString() {
  return 'BBox(x: $x, y: $y, w: $w, h: $h)';
}


}

/// @nodoc
abstract mixin class _$BBoxCopyWith<$Res> implements $BBoxCopyWith<$Res> {
  factory _$BBoxCopyWith(_BBox value, $Res Function(_BBox) _then) = __$BBoxCopyWithImpl;
@override @useResult
$Res call({
 double x, double y, double w, double h
});




}
/// @nodoc
class __$BBoxCopyWithImpl<$Res>
    implements _$BBoxCopyWith<$Res> {
  __$BBoxCopyWithImpl(this._self, this._then);

  final _BBox _self;
  final $Res Function(_BBox) _then;

/// Create a copy of BBox
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,Object? w = null,Object? h = null,}) {
  return _then(_BBox(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,w: null == w ? _self.w : w // ignore: cast_nullable_to_non_nullable
as double,h: null == h ? _self.h : h // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$Quantity {

 double get value;/// 'pcs', 'kg', 'g', 'm', 'm2', 'L', 'handful', 'bag'.
 String get unit; bool get isEstimate;/// Ready to show, localized: '3 pcs', '~0.5 kg'.
 String get display;
/// Create a copy of Quantity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuantityCopyWith<Quantity> get copyWith => _$QuantityCopyWithImpl<Quantity>(this as Quantity, _$identity);

  /// Serializes this Quantity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Quantity&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.isEstimate, isEstimate) || other.isEstimate == isEstimate)&&(identical(other.display, display) || other.display == display));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,unit,isEstimate,display);

@override
String toString() {
  return 'Quantity(value: $value, unit: $unit, isEstimate: $isEstimate, display: $display)';
}


}

/// @nodoc
abstract mixin class $QuantityCopyWith<$Res>  {
  factory $QuantityCopyWith(Quantity value, $Res Function(Quantity) _then) = _$QuantityCopyWithImpl;
@useResult
$Res call({
 double value, String unit, bool isEstimate, String display
});




}
/// @nodoc
class _$QuantityCopyWithImpl<$Res>
    implements $QuantityCopyWith<$Res> {
  _$QuantityCopyWithImpl(this._self, this._then);

  final Quantity _self;
  final $Res Function(Quantity) _then;

/// Create a copy of Quantity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? unit = null,Object? isEstimate = null,Object? display = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,isEstimate: null == isEstimate ? _self.isEstimate : isEstimate // ignore: cast_nullable_to_non_nullable
as bool,display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Quantity].
extension QuantityPatterns on Quantity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Quantity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Quantity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Quantity value)  $default,){
final _that = this;
switch (_that) {
case _Quantity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Quantity value)?  $default,){
final _that = this;
switch (_that) {
case _Quantity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double value,  String unit,  bool isEstimate,  String display)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Quantity() when $default != null:
return $default(_that.value,_that.unit,_that.isEstimate,_that.display);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double value,  String unit,  bool isEstimate,  String display)  $default,) {final _that = this;
switch (_that) {
case _Quantity():
return $default(_that.value,_that.unit,_that.isEstimate,_that.display);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double value,  String unit,  bool isEstimate,  String display)?  $default,) {final _that = this;
switch (_that) {
case _Quantity() when $default != null:
return $default(_that.value,_that.unit,_that.isEstimate,_that.display);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Quantity implements Quantity {
  const _Quantity({required this.value, required this.unit, required this.isEstimate, required this.display});
  factory _Quantity.fromJson(Map<String, dynamic> json) => _$QuantityFromJson(json);

@override final  double value;
/// 'pcs', 'kg', 'g', 'm', 'm2', 'L', 'handful', 'bag'.
@override final  String unit;
@override final  bool isEstimate;
/// Ready to show, localized: '3 pcs', '~0.5 kg'.
@override final  String display;

/// Create a copy of Quantity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuantityCopyWith<_Quantity> get copyWith => __$QuantityCopyWithImpl<_Quantity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuantityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Quantity&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.isEstimate, isEstimate) || other.isEstimate == isEstimate)&&(identical(other.display, display) || other.display == display));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,unit,isEstimate,display);

@override
String toString() {
  return 'Quantity(value: $value, unit: $unit, isEstimate: $isEstimate, display: $display)';
}


}

/// @nodoc
abstract mixin class _$QuantityCopyWith<$Res> implements $QuantityCopyWith<$Res> {
  factory _$QuantityCopyWith(_Quantity value, $Res Function(_Quantity) _then) = __$QuantityCopyWithImpl;
@override @useResult
$Res call({
 double value, String unit, bool isEstimate, String display
});




}
/// @nodoc
class __$QuantityCopyWithImpl<$Res>
    implements _$QuantityCopyWith<$Res> {
  __$QuantityCopyWithImpl(this._self, this._then);

  final _Quantity _self;
  final $Res Function(_Quantity) _then;

/// Create a copy of Quantity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? unit = null,Object? isEstimate = null,Object? display = null,}) {
  return _then(_Quantity(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,isEstimate: null == isEstimate ? _self.isEstimate : isEstimate // ignore: cast_nullable_to_non_nullable
as bool,display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Quality {

 int get score; String get label; String? get notes;
/// Create a copy of Quality
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QualityCopyWith<Quality> get copyWith => _$QualityCopyWithImpl<Quality>(this as Quality, _$identity);

  /// Serializes this Quality to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Quality&&(identical(other.score, score) || other.score == score)&&(identical(other.label, label) || other.label == label)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,score,label,notes);

@override
String toString() {
  return 'Quality(score: $score, label: $label, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $QualityCopyWith<$Res>  {
  factory $QualityCopyWith(Quality value, $Res Function(Quality) _then) = _$QualityCopyWithImpl;
@useResult
$Res call({
 int score, String label, String? notes
});




}
/// @nodoc
class _$QualityCopyWithImpl<$Res>
    implements $QualityCopyWith<$Res> {
  _$QualityCopyWithImpl(this._self, this._then);

  final Quality _self;
  final $Res Function(Quality) _then;

/// Create a copy of Quality
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? score = null,Object? label = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Quality].
extension QualityPatterns on Quality {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Quality value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Quality() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Quality value)  $default,){
final _that = this;
switch (_that) {
case _Quality():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Quality value)?  $default,){
final _that = this;
switch (_that) {
case _Quality() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int score,  String label,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Quality() when $default != null:
return $default(_that.score,_that.label,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int score,  String label,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _Quality():
return $default(_that.score,_that.label,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int score,  String label,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _Quality() when $default != null:
return $default(_that.score,_that.label,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Quality implements Quality {
  const _Quality({required this.score, required this.label, this.notes});
  factory _Quality.fromJson(Map<String, dynamic> json) => _$QualityFromJson(json);

@override final  int score;
@override final  String label;
@override final  String? notes;

/// Create a copy of Quality
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QualityCopyWith<_Quality> get copyWith => __$QualityCopyWithImpl<_Quality>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QualityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Quality&&(identical(other.score, score) || other.score == score)&&(identical(other.label, label) || other.label == label)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,score,label,notes);

@override
String toString() {
  return 'Quality(score: $score, label: $label, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$QualityCopyWith<$Res> implements $QualityCopyWith<$Res> {
  factory _$QualityCopyWith(_Quality value, $Res Function(_Quality) _then) = __$QualityCopyWithImpl;
@override @useResult
$Res call({
 int score, String label, String? notes
});




}
/// @nodoc
class __$QualityCopyWithImpl<$Res>
    implements _$QualityCopyWith<$Res> {
  __$QualityCopyWithImpl(this._self, this._then);

  final _Quality _self;
  final $Res Function(_Quality) _then;

/// Create a copy of Quality
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? score = null,Object? label = null,Object? notes = freezed,}) {
  return _then(_Quality(
score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Recyclability {

 RecyclabilityStatus get status;/// Where it goes, localized: 'Glass bottle bank'.
 String get stream; List<String> get prepSteps;/// Why it is conditional or not recyclable.
 String? get reason;
/// Create a copy of Recyclability
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecyclabilityCopyWith<Recyclability> get copyWith => _$RecyclabilityCopyWithImpl<Recyclability>(this as Recyclability, _$identity);

  /// Serializes this Recyclability to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recyclability&&(identical(other.status, status) || other.status == status)&&(identical(other.stream, stream) || other.stream == stream)&&const DeepCollectionEquality().equals(other.prepSteps, prepSteps)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,stream,const DeepCollectionEquality().hash(prepSteps),reason);

@override
String toString() {
  return 'Recyclability(status: $status, stream: $stream, prepSteps: $prepSteps, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $RecyclabilityCopyWith<$Res>  {
  factory $RecyclabilityCopyWith(Recyclability value, $Res Function(Recyclability) _then) = _$RecyclabilityCopyWithImpl;
@useResult
$Res call({
 RecyclabilityStatus status, String stream, List<String> prepSteps, String? reason
});




}
/// @nodoc
class _$RecyclabilityCopyWithImpl<$Res>
    implements $RecyclabilityCopyWith<$Res> {
  _$RecyclabilityCopyWithImpl(this._self, this._then);

  final Recyclability _self;
  final $Res Function(Recyclability) _then;

/// Create a copy of Recyclability
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? stream = null,Object? prepSteps = null,Object? reason = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecyclabilityStatus,stream: null == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as String,prepSteps: null == prepSteps ? _self.prepSteps : prepSteps // ignore: cast_nullable_to_non_nullable
as List<String>,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Recyclability].
extension RecyclabilityPatterns on Recyclability {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recyclability value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recyclability() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recyclability value)  $default,){
final _that = this;
switch (_that) {
case _Recyclability():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recyclability value)?  $default,){
final _that = this;
switch (_that) {
case _Recyclability() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecyclabilityStatus status,  String stream,  List<String> prepSteps,  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recyclability() when $default != null:
return $default(_that.status,_that.stream,_that.prepSteps,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecyclabilityStatus status,  String stream,  List<String> prepSteps,  String? reason)  $default,) {final _that = this;
switch (_that) {
case _Recyclability():
return $default(_that.status,_that.stream,_that.prepSteps,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecyclabilityStatus status,  String stream,  List<String> prepSteps,  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _Recyclability() when $default != null:
return $default(_that.status,_that.stream,_that.prepSteps,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Recyclability implements Recyclability {
  const _Recyclability({required this.status, required this.stream, final  List<String> prepSteps = const <String>[], this.reason}): _prepSteps = prepSteps;
  factory _Recyclability.fromJson(Map<String, dynamic> json) => _$RecyclabilityFromJson(json);

@override final  RecyclabilityStatus status;
/// Where it goes, localized: 'Glass bottle bank'.
@override final  String stream;
 final  List<String> _prepSteps;
@override@JsonKey() List<String> get prepSteps {
  if (_prepSteps is EqualUnmodifiableListView) return _prepSteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_prepSteps);
}

/// Why it is conditional or not recyclable.
@override final  String? reason;

/// Create a copy of Recyclability
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecyclabilityCopyWith<_Recyclability> get copyWith => __$RecyclabilityCopyWithImpl<_Recyclability>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecyclabilityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recyclability&&(identical(other.status, status) || other.status == status)&&(identical(other.stream, stream) || other.stream == stream)&&const DeepCollectionEquality().equals(other._prepSteps, _prepSteps)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,stream,const DeepCollectionEquality().hash(_prepSteps),reason);

@override
String toString() {
  return 'Recyclability(status: $status, stream: $stream, prepSteps: $prepSteps, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$RecyclabilityCopyWith<$Res> implements $RecyclabilityCopyWith<$Res> {
  factory _$RecyclabilityCopyWith(_Recyclability value, $Res Function(_Recyclability) _then) = __$RecyclabilityCopyWithImpl;
@override @useResult
$Res call({
 RecyclabilityStatus status, String stream, List<String> prepSteps, String? reason
});




}
/// @nodoc
class __$RecyclabilityCopyWithImpl<$Res>
    implements _$RecyclabilityCopyWith<$Res> {
  __$RecyclabilityCopyWithImpl(this._self, this._then);

  final _Recyclability _self;
  final $Res Function(_Recyclability) _then;

/// Create a copy of Recyclability
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? stream = null,Object? prepSteps = null,Object? reason = freezed,}) {
  return _then(_Recyclability(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecyclabilityStatus,stream: null == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as String,prepSteps: null == prepSteps ? _self._prepSteps : prepSteps // ignore: cast_nullable_to_non_nullable
as List<String>,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ReusePotential {

 Level get level; String get note;
/// Create a copy of ReusePotential
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReusePotentialCopyWith<ReusePotential> get copyWith => _$ReusePotentialCopyWithImpl<ReusePotential>(this as ReusePotential, _$identity);

  /// Serializes this ReusePotential to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReusePotential&&(identical(other.level, level) || other.level == level)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,level,note);

@override
String toString() {
  return 'ReusePotential(level: $level, note: $note)';
}


}

/// @nodoc
abstract mixin class $ReusePotentialCopyWith<$Res>  {
  factory $ReusePotentialCopyWith(ReusePotential value, $Res Function(ReusePotential) _then) = _$ReusePotentialCopyWithImpl;
@useResult
$Res call({
 Level level, String note
});




}
/// @nodoc
class _$ReusePotentialCopyWithImpl<$Res>
    implements $ReusePotentialCopyWith<$Res> {
  _$ReusePotentialCopyWithImpl(this._self, this._then);

  final ReusePotential _self;
  final $Res Function(ReusePotential) _then;

/// Create a copy of ReusePotential
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? note = null,}) {
  return _then(_self.copyWith(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as Level,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReusePotential].
extension ReusePotentialPatterns on ReusePotential {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReusePotential value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReusePotential() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReusePotential value)  $default,){
final _that = this;
switch (_that) {
case _ReusePotential():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReusePotential value)?  $default,){
final _that = this;
switch (_that) {
case _ReusePotential() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Level level,  String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReusePotential() when $default != null:
return $default(_that.level,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Level level,  String note)  $default,) {final _that = this;
switch (_that) {
case _ReusePotential():
return $default(_that.level,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Level level,  String note)?  $default,) {final _that = this;
switch (_that) {
case _ReusePotential() when $default != null:
return $default(_that.level,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReusePotential implements ReusePotential {
  const _ReusePotential({required this.level, required this.note});
  factory _ReusePotential.fromJson(Map<String, dynamic> json) => _$ReusePotentialFromJson(json);

@override final  Level level;
@override final  String note;

/// Create a copy of ReusePotential
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReusePotentialCopyWith<_ReusePotential> get copyWith => __$ReusePotentialCopyWithImpl<_ReusePotential>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReusePotentialToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReusePotential&&(identical(other.level, level) || other.level == level)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,level,note);

@override
String toString() {
  return 'ReusePotential(level: $level, note: $note)';
}


}

/// @nodoc
abstract mixin class _$ReusePotentialCopyWith<$Res> implements $ReusePotentialCopyWith<$Res> {
  factory _$ReusePotentialCopyWith(_ReusePotential value, $Res Function(_ReusePotential) _then) = __$ReusePotentialCopyWithImpl;
@override @useResult
$Res call({
 Level level, String note
});




}
/// @nodoc
class __$ReusePotentialCopyWithImpl<$Res>
    implements _$ReusePotentialCopyWith<$Res> {
  __$ReusePotentialCopyWithImpl(this._self, this._then);

  final _ReusePotential _self;
  final $Res Function(_ReusePotential) _then;

/// Create a copy of ReusePotential
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? note = null,}) {
  return _then(_ReusePotential(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as Level,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Item {

/// Stable within a scan: 'item_1', 'item_2'...
 String get id; String get name; MaterialCategory get category;/// Specific material, localized: 'Clear soda-lime glass', 'PET #1'.
 String get material; int? get resinCode; bool get isRawMaterial; Quantity get quantity; Quality get quality; List<StateTag> get state; Recyclability get recyclability; ReusePotential get reuse; List<HazardFlag> get hazards; double get confidence; BBox? get bbox;/// Set by the app when the user edited this item on the results screen.
 bool get userCorrected;
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemCopyWith<Item> get copyWith => _$ItemCopyWithImpl<Item>(this as Item, _$identity);

  /// Serializes this Item to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Item&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.material, material) || other.material == material)&&(identical(other.resinCode, resinCode) || other.resinCode == resinCode)&&(identical(other.isRawMaterial, isRawMaterial) || other.isRawMaterial == isRawMaterial)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quality, quality) || other.quality == quality)&&const DeepCollectionEquality().equals(other.state, state)&&(identical(other.recyclability, recyclability) || other.recyclability == recyclability)&&(identical(other.reuse, reuse) || other.reuse == reuse)&&const DeepCollectionEquality().equals(other.hazards, hazards)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.bbox, bbox) || other.bbox == bbox)&&(identical(other.userCorrected, userCorrected) || other.userCorrected == userCorrected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,material,resinCode,isRawMaterial,quantity,quality,const DeepCollectionEquality().hash(state),recyclability,reuse,const DeepCollectionEquality().hash(hazards),confidence,bbox,userCorrected);

@override
String toString() {
  return 'Item(id: $id, name: $name, category: $category, material: $material, resinCode: $resinCode, isRawMaterial: $isRawMaterial, quantity: $quantity, quality: $quality, state: $state, recyclability: $recyclability, reuse: $reuse, hazards: $hazards, confidence: $confidence, bbox: $bbox, userCorrected: $userCorrected)';
}


}

/// @nodoc
abstract mixin class $ItemCopyWith<$Res>  {
  factory $ItemCopyWith(Item value, $Res Function(Item) _then) = _$ItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, MaterialCategory category, String material, int? resinCode, bool isRawMaterial, Quantity quantity, Quality quality, List<StateTag> state, Recyclability recyclability, ReusePotential reuse, List<HazardFlag> hazards, double confidence, BBox? bbox, bool userCorrected
});


$QuantityCopyWith<$Res> get quantity;$QualityCopyWith<$Res> get quality;$RecyclabilityCopyWith<$Res> get recyclability;$ReusePotentialCopyWith<$Res> get reuse;$BBoxCopyWith<$Res>? get bbox;

}
/// @nodoc
class _$ItemCopyWithImpl<$Res>
    implements $ItemCopyWith<$Res> {
  _$ItemCopyWithImpl(this._self, this._then);

  final Item _self;
  final $Res Function(Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? category = null,Object? material = null,Object? resinCode = freezed,Object? isRawMaterial = null,Object? quantity = null,Object? quality = null,Object? state = null,Object? recyclability = null,Object? reuse = null,Object? hazards = null,Object? confidence = null,Object? bbox = freezed,Object? userCorrected = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as MaterialCategory,material: null == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String,resinCode: freezed == resinCode ? _self.resinCode : resinCode // ignore: cast_nullable_to_non_nullable
as int?,isRawMaterial: null == isRawMaterial ? _self.isRawMaterial : isRawMaterial // ignore: cast_nullable_to_non_nullable
as bool,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as Quality,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as List<StateTag>,recyclability: null == recyclability ? _self.recyclability : recyclability // ignore: cast_nullable_to_non_nullable
as Recyclability,reuse: null == reuse ? _self.reuse : reuse // ignore: cast_nullable_to_non_nullable
as ReusePotential,hazards: null == hazards ? _self.hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<HazardFlag>,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,bbox: freezed == bbox ? _self.bbox : bbox // ignore: cast_nullable_to_non_nullable
as BBox?,userCorrected: null == userCorrected ? _self.userCorrected : userCorrected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuantityCopyWith<$Res> get quantity {
  
  return $QuantityCopyWith<$Res>(_self.quantity, (value) {
    return _then(_self.copyWith(quantity: value));
  });
}/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QualityCopyWith<$Res> get quality {
  
  return $QualityCopyWith<$Res>(_self.quality, (value) {
    return _then(_self.copyWith(quality: value));
  });
}/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecyclabilityCopyWith<$Res> get recyclability {
  
  return $RecyclabilityCopyWith<$Res>(_self.recyclability, (value) {
    return _then(_self.copyWith(recyclability: value));
  });
}/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReusePotentialCopyWith<$Res> get reuse {
  
  return $ReusePotentialCopyWith<$Res>(_self.reuse, (value) {
    return _then(_self.copyWith(reuse: value));
  });
}/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BBoxCopyWith<$Res>? get bbox {
    if (_self.bbox == null) {
    return null;
  }

  return $BBoxCopyWith<$Res>(_self.bbox!, (value) {
    return _then(_self.copyWith(bbox: value));
  });
}
}


/// Adds pattern-matching-related methods to [Item].
extension ItemPatterns on Item {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Item value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Item() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Item value)  $default,){
final _that = this;
switch (_that) {
case _Item():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Item value)?  $default,){
final _that = this;
switch (_that) {
case _Item() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  MaterialCategory category,  String material,  int? resinCode,  bool isRawMaterial,  Quantity quantity,  Quality quality,  List<StateTag> state,  Recyclability recyclability,  ReusePotential reuse,  List<HazardFlag> hazards,  double confidence,  BBox? bbox,  bool userCorrected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.material,_that.resinCode,_that.isRawMaterial,_that.quantity,_that.quality,_that.state,_that.recyclability,_that.reuse,_that.hazards,_that.confidence,_that.bbox,_that.userCorrected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  MaterialCategory category,  String material,  int? resinCode,  bool isRawMaterial,  Quantity quantity,  Quality quality,  List<StateTag> state,  Recyclability recyclability,  ReusePotential reuse,  List<HazardFlag> hazards,  double confidence,  BBox? bbox,  bool userCorrected)  $default,) {final _that = this;
switch (_that) {
case _Item():
return $default(_that.id,_that.name,_that.category,_that.material,_that.resinCode,_that.isRawMaterial,_that.quantity,_that.quality,_that.state,_that.recyclability,_that.reuse,_that.hazards,_that.confidence,_that.bbox,_that.userCorrected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  MaterialCategory category,  String material,  int? resinCode,  bool isRawMaterial,  Quantity quantity,  Quality quality,  List<StateTag> state,  Recyclability recyclability,  ReusePotential reuse,  List<HazardFlag> hazards,  double confidence,  BBox? bbox,  bool userCorrected)?  $default,) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.material,_that.resinCode,_that.isRawMaterial,_that.quantity,_that.quality,_that.state,_that.recyclability,_that.reuse,_that.hazards,_that.confidence,_that.bbox,_that.userCorrected);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Item extends Item {
  const _Item({required this.id, required this.name, required this.category, required this.material, this.resinCode, this.isRawMaterial = false, required this.quantity, required this.quality, final  List<StateTag> state = const <StateTag>[], required this.recyclability, required this.reuse, final  List<HazardFlag> hazards = const <HazardFlag>[], required this.confidence, this.bbox, this.userCorrected = false}): _state = state,_hazards = hazards,super._();
  factory _Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

/// Stable within a scan: 'item_1', 'item_2'...
@override final  String id;
@override final  String name;
@override final  MaterialCategory category;
/// Specific material, localized: 'Clear soda-lime glass', 'PET #1'.
@override final  String material;
@override final  int? resinCode;
@override@JsonKey() final  bool isRawMaterial;
@override final  Quantity quantity;
@override final  Quality quality;
 final  List<StateTag> _state;
@override@JsonKey() List<StateTag> get state {
  if (_state is EqualUnmodifiableListView) return _state;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_state);
}

@override final  Recyclability recyclability;
@override final  ReusePotential reuse;
 final  List<HazardFlag> _hazards;
@override@JsonKey() List<HazardFlag> get hazards {
  if (_hazards is EqualUnmodifiableListView) return _hazards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hazards);
}

@override final  double confidence;
@override final  BBox? bbox;
/// Set by the app when the user edited this item on the results screen.
@override@JsonKey() final  bool userCorrected;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemCopyWith<_Item> get copyWith => __$ItemCopyWithImpl<_Item>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Item&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.material, material) || other.material == material)&&(identical(other.resinCode, resinCode) || other.resinCode == resinCode)&&(identical(other.isRawMaterial, isRawMaterial) || other.isRawMaterial == isRawMaterial)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quality, quality) || other.quality == quality)&&const DeepCollectionEquality().equals(other._state, _state)&&(identical(other.recyclability, recyclability) || other.recyclability == recyclability)&&(identical(other.reuse, reuse) || other.reuse == reuse)&&const DeepCollectionEquality().equals(other._hazards, _hazards)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.bbox, bbox) || other.bbox == bbox)&&(identical(other.userCorrected, userCorrected) || other.userCorrected == userCorrected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,material,resinCode,isRawMaterial,quantity,quality,const DeepCollectionEquality().hash(_state),recyclability,reuse,const DeepCollectionEquality().hash(_hazards),confidence,bbox,userCorrected);

@override
String toString() {
  return 'Item(id: $id, name: $name, category: $category, material: $material, resinCode: $resinCode, isRawMaterial: $isRawMaterial, quantity: $quantity, quality: $quality, state: $state, recyclability: $recyclability, reuse: $reuse, hazards: $hazards, confidence: $confidence, bbox: $bbox, userCorrected: $userCorrected)';
}


}

/// @nodoc
abstract mixin class _$ItemCopyWith<$Res> implements $ItemCopyWith<$Res> {
  factory _$ItemCopyWith(_Item value, $Res Function(_Item) _then) = __$ItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, MaterialCategory category, String material, int? resinCode, bool isRawMaterial, Quantity quantity, Quality quality, List<StateTag> state, Recyclability recyclability, ReusePotential reuse, List<HazardFlag> hazards, double confidence, BBox? bbox, bool userCorrected
});


@override $QuantityCopyWith<$Res> get quantity;@override $QualityCopyWith<$Res> get quality;@override $RecyclabilityCopyWith<$Res> get recyclability;@override $ReusePotentialCopyWith<$Res> get reuse;@override $BBoxCopyWith<$Res>? get bbox;

}
/// @nodoc
class __$ItemCopyWithImpl<$Res>
    implements _$ItemCopyWith<$Res> {
  __$ItemCopyWithImpl(this._self, this._then);

  final _Item _self;
  final $Res Function(_Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? category = null,Object? material = null,Object? resinCode = freezed,Object? isRawMaterial = null,Object? quantity = null,Object? quality = null,Object? state = null,Object? recyclability = null,Object? reuse = null,Object? hazards = null,Object? confidence = null,Object? bbox = freezed,Object? userCorrected = null,}) {
  return _then(_Item(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as MaterialCategory,material: null == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String,resinCode: freezed == resinCode ? _self.resinCode : resinCode // ignore: cast_nullable_to_non_nullable
as int?,isRawMaterial: null == isRawMaterial ? _self.isRawMaterial : isRawMaterial // ignore: cast_nullable_to_non_nullable
as bool,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as Quality,state: null == state ? _self._state : state // ignore: cast_nullable_to_non_nullable
as List<StateTag>,recyclability: null == recyclability ? _self.recyclability : recyclability // ignore: cast_nullable_to_non_nullable
as Recyclability,reuse: null == reuse ? _self.reuse : reuse // ignore: cast_nullable_to_non_nullable
as ReusePotential,hazards: null == hazards ? _self._hazards : hazards // ignore: cast_nullable_to_non_nullable
as List<HazardFlag>,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,bbox: freezed == bbox ? _self.bbox : bbox // ignore: cast_nullable_to_non_nullable
as BBox?,userCorrected: null == userCorrected ? _self.userCorrected : userCorrected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuantityCopyWith<$Res> get quantity {
  
  return $QuantityCopyWith<$Res>(_self.quantity, (value) {
    return _then(_self.copyWith(quantity: value));
  });
}/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QualityCopyWith<$Res> get quality {
  
  return $QualityCopyWith<$Res>(_self.quality, (value) {
    return _then(_self.copyWith(quality: value));
  });
}/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecyclabilityCopyWith<$Res> get recyclability {
  
  return $RecyclabilityCopyWith<$Res>(_self.recyclability, (value) {
    return _then(_self.copyWith(recyclability: value));
  });
}/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReusePotentialCopyWith<$Res> get reuse {
  
  return $ReusePotentialCopyWith<$Res>(_self.reuse, (value) {
    return _then(_self.copyWith(reuse: value));
  });
}/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BBoxCopyWith<$Res>? get bbox {
    if (_self.bbox == null) {
    return null;
  }

  return $BBoxCopyWith<$Res>(_self.bbox!, (value) {
    return _then(_self.copyWith(bbox: value));
  });
}
}


/// @nodoc
mixin _$PhotoCheck {

 bool get usable; PhotoIssue get issue;/// One specific, localized tip when the photo is not usable.
 String? get retakeTip;
/// Create a copy of PhotoCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoCheckCopyWith<PhotoCheck> get copyWith => _$PhotoCheckCopyWithImpl<PhotoCheck>(this as PhotoCheck, _$identity);

  /// Serializes this PhotoCheck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoCheck&&(identical(other.usable, usable) || other.usable == usable)&&(identical(other.issue, issue) || other.issue == issue)&&(identical(other.retakeTip, retakeTip) || other.retakeTip == retakeTip));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,usable,issue,retakeTip);

@override
String toString() {
  return 'PhotoCheck(usable: $usable, issue: $issue, retakeTip: $retakeTip)';
}


}

/// @nodoc
abstract mixin class $PhotoCheckCopyWith<$Res>  {
  factory $PhotoCheckCopyWith(PhotoCheck value, $Res Function(PhotoCheck) _then) = _$PhotoCheckCopyWithImpl;
@useResult
$Res call({
 bool usable, PhotoIssue issue, String? retakeTip
});




}
/// @nodoc
class _$PhotoCheckCopyWithImpl<$Res>
    implements $PhotoCheckCopyWith<$Res> {
  _$PhotoCheckCopyWithImpl(this._self, this._then);

  final PhotoCheck _self;
  final $Res Function(PhotoCheck) _then;

/// Create a copy of PhotoCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? usable = null,Object? issue = null,Object? retakeTip = freezed,}) {
  return _then(_self.copyWith(
usable: null == usable ? _self.usable : usable // ignore: cast_nullable_to_non_nullable
as bool,issue: null == issue ? _self.issue : issue // ignore: cast_nullable_to_non_nullable
as PhotoIssue,retakeTip: freezed == retakeTip ? _self.retakeTip : retakeTip // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoCheck].
extension PhotoCheckPatterns on PhotoCheck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoCheck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoCheck value)  $default,){
final _that = this;
switch (_that) {
case _PhotoCheck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoCheck value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoCheck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool usable,  PhotoIssue issue,  String? retakeTip)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoCheck() when $default != null:
return $default(_that.usable,_that.issue,_that.retakeTip);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool usable,  PhotoIssue issue,  String? retakeTip)  $default,) {final _that = this;
switch (_that) {
case _PhotoCheck():
return $default(_that.usable,_that.issue,_that.retakeTip);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool usable,  PhotoIssue issue,  String? retakeTip)?  $default,) {final _that = this;
switch (_that) {
case _PhotoCheck() when $default != null:
return $default(_that.usable,_that.issue,_that.retakeTip);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhotoCheck implements PhotoCheck {
  const _PhotoCheck({required this.usable, this.issue = PhotoIssue.ok, this.retakeTip});
  factory _PhotoCheck.fromJson(Map<String, dynamic> json) => _$PhotoCheckFromJson(json);

@override final  bool usable;
@override@JsonKey() final  PhotoIssue issue;
/// One specific, localized tip when the photo is not usable.
@override final  String? retakeTip;

/// Create a copy of PhotoCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoCheckCopyWith<_PhotoCheck> get copyWith => __$PhotoCheckCopyWithImpl<_PhotoCheck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoCheckToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoCheck&&(identical(other.usable, usable) || other.usable == usable)&&(identical(other.issue, issue) || other.issue == issue)&&(identical(other.retakeTip, retakeTip) || other.retakeTip == retakeTip));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,usable,issue,retakeTip);

@override
String toString() {
  return 'PhotoCheck(usable: $usable, issue: $issue, retakeTip: $retakeTip)';
}


}

/// @nodoc
abstract mixin class _$PhotoCheckCopyWith<$Res> implements $PhotoCheckCopyWith<$Res> {
  factory _$PhotoCheckCopyWith(_PhotoCheck value, $Res Function(_PhotoCheck) _then) = __$PhotoCheckCopyWithImpl;
@override @useResult
$Res call({
 bool usable, PhotoIssue issue, String? retakeTip
});




}
/// @nodoc
class __$PhotoCheckCopyWithImpl<$Res>
    implements _$PhotoCheckCopyWith<$Res> {
  __$PhotoCheckCopyWithImpl(this._self, this._then);

  final _PhotoCheck _self;
  final $Res Function(_PhotoCheck) _then;

/// Create a copy of PhotoCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? usable = null,Object? issue = null,Object? retakeTip = freezed,}) {
  return _then(_PhotoCheck(
usable: null == usable ? _self.usable : usable // ignore: cast_nullable_to_non_nullable
as bool,issue: null == issue ? _self.issue : issue // ignore: cast_nullable_to_non_nullable
as PhotoIssue,retakeTip: freezed == retakeTip ? _self.retakeTip : retakeTip // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Analysis {

 List<Item> get items; String get summary; PhotoCheck get photo; String? get primaryItemId; AnalysisSource get source;/// Label from the pluggable MaterialClassifier, when one is installed.
 String? get classifierHint;
/// Create a copy of Analysis
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalysisCopyWith<Analysis> get copyWith => _$AnalysisCopyWithImpl<Analysis>(this as Analysis, _$identity);

  /// Serializes this Analysis to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Analysis&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.primaryItemId, primaryItemId) || other.primaryItemId == primaryItemId)&&(identical(other.source, source) || other.source == source)&&(identical(other.classifierHint, classifierHint) || other.classifierHint == classifierHint));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),summary,photo,primaryItemId,source,classifierHint);

@override
String toString() {
  return 'Analysis(items: $items, summary: $summary, photo: $photo, primaryItemId: $primaryItemId, source: $source, classifierHint: $classifierHint)';
}


}

/// @nodoc
abstract mixin class $AnalysisCopyWith<$Res>  {
  factory $AnalysisCopyWith(Analysis value, $Res Function(Analysis) _then) = _$AnalysisCopyWithImpl;
@useResult
$Res call({
 List<Item> items, String summary, PhotoCheck photo, String? primaryItemId, AnalysisSource source, String? classifierHint
});


$PhotoCheckCopyWith<$Res> get photo;

}
/// @nodoc
class _$AnalysisCopyWithImpl<$Res>
    implements $AnalysisCopyWith<$Res> {
  _$AnalysisCopyWithImpl(this._self, this._then);

  final Analysis _self;
  final $Res Function(Analysis) _then;

/// Create a copy of Analysis
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? summary = null,Object? photo = null,Object? primaryItemId = freezed,Object? source = null,Object? classifierHint = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Item>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,photo: null == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as PhotoCheck,primaryItemId: freezed == primaryItemId ? _self.primaryItemId : primaryItemId // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AnalysisSource,classifierHint: freezed == classifierHint ? _self.classifierHint : classifierHint // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Analysis
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhotoCheckCopyWith<$Res> get photo {
  
  return $PhotoCheckCopyWith<$Res>(_self.photo, (value) {
    return _then(_self.copyWith(photo: value));
  });
}
}


/// Adds pattern-matching-related methods to [Analysis].
extension AnalysisPatterns on Analysis {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Analysis value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Analysis() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Analysis value)  $default,){
final _that = this;
switch (_that) {
case _Analysis():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Analysis value)?  $default,){
final _that = this;
switch (_that) {
case _Analysis() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Item> items,  String summary,  PhotoCheck photo,  String? primaryItemId,  AnalysisSource source,  String? classifierHint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Analysis() when $default != null:
return $default(_that.items,_that.summary,_that.photo,_that.primaryItemId,_that.source,_that.classifierHint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Item> items,  String summary,  PhotoCheck photo,  String? primaryItemId,  AnalysisSource source,  String? classifierHint)  $default,) {final _that = this;
switch (_that) {
case _Analysis():
return $default(_that.items,_that.summary,_that.photo,_that.primaryItemId,_that.source,_that.classifierHint);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Item> items,  String summary,  PhotoCheck photo,  String? primaryItemId,  AnalysisSource source,  String? classifierHint)?  $default,) {final _that = this;
switch (_that) {
case _Analysis() when $default != null:
return $default(_that.items,_that.summary,_that.photo,_that.primaryItemId,_that.source,_that.classifierHint);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Analysis extends Analysis {
  const _Analysis({required final  List<Item> items, required this.summary, required this.photo, this.primaryItemId, required this.source, this.classifierHint}): _items = items,super._();
  factory _Analysis.fromJson(Map<String, dynamic> json) => _$AnalysisFromJson(json);

 final  List<Item> _items;
@override List<Item> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String summary;
@override final  PhotoCheck photo;
@override final  String? primaryItemId;
@override final  AnalysisSource source;
/// Label from the pluggable MaterialClassifier, when one is installed.
@override final  String? classifierHint;

/// Create a copy of Analysis
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalysisCopyWith<_Analysis> get copyWith => __$AnalysisCopyWithImpl<_Analysis>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalysisToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Analysis&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.primaryItemId, primaryItemId) || other.primaryItemId == primaryItemId)&&(identical(other.source, source) || other.source == source)&&(identical(other.classifierHint, classifierHint) || other.classifierHint == classifierHint));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),summary,photo,primaryItemId,source,classifierHint);

@override
String toString() {
  return 'Analysis(items: $items, summary: $summary, photo: $photo, primaryItemId: $primaryItemId, source: $source, classifierHint: $classifierHint)';
}


}

/// @nodoc
abstract mixin class _$AnalysisCopyWith<$Res> implements $AnalysisCopyWith<$Res> {
  factory _$AnalysisCopyWith(_Analysis value, $Res Function(_Analysis) _then) = __$AnalysisCopyWithImpl;
@override @useResult
$Res call({
 List<Item> items, String summary, PhotoCheck photo, String? primaryItemId, AnalysisSource source, String? classifierHint
});


@override $PhotoCheckCopyWith<$Res> get photo;

}
/// @nodoc
class __$AnalysisCopyWithImpl<$Res>
    implements _$AnalysisCopyWith<$Res> {
  __$AnalysisCopyWithImpl(this._self, this._then);

  final _Analysis _self;
  final $Res Function(_Analysis) _then;

/// Create a copy of Analysis
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? summary = null,Object? photo = null,Object? primaryItemId = freezed,Object? source = null,Object? classifierHint = freezed,}) {
  return _then(_Analysis(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Item>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,photo: null == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as PhotoCheck,primaryItemId: freezed == primaryItemId ? _self.primaryItemId : primaryItemId // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AnalysisSource,classifierHint: freezed == classifierHint ? _self.classifierHint : classifierHint // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Analysis
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhotoCheckCopyWith<$Res> get photo {
  
  return $PhotoCheckCopyWith<$Res>(_self.photo, (value) {
    return _then(_self.copyWith(photo: value));
  });
}
}


/// @nodoc
mixin _$AnalyzeResponse {

/// 'img_...' for photos, 'txt_...' for text input.
 String get imageId;/// Path of the stored upload ('/static/uploads/...'); null for text input.
 String? get imageUrl; int? get imageWidth; int? get imageHeight; Analysis get analysis; Lang get lang; Timings get timingsMs;
/// Create a copy of AnalyzeResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyzeResponseCopyWith<AnalyzeResponse> get copyWith => _$AnalyzeResponseCopyWithImpl<AnalyzeResponse>(this as AnalyzeResponse, _$identity);

  /// Serializes this AnalyzeResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyzeResponse&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.imageWidth, imageWidth) || other.imageWidth == imageWidth)&&(identical(other.imageHeight, imageHeight) || other.imageHeight == imageHeight)&&(identical(other.analysis, analysis) || other.analysis == analysis)&&(identical(other.lang, lang) || other.lang == lang)&&const DeepCollectionEquality().equals(other.timingsMs, timingsMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId,imageUrl,imageWidth,imageHeight,analysis,lang,const DeepCollectionEquality().hash(timingsMs));

@override
String toString() {
  return 'AnalyzeResponse(imageId: $imageId, imageUrl: $imageUrl, imageWidth: $imageWidth, imageHeight: $imageHeight, analysis: $analysis, lang: $lang, timingsMs: $timingsMs)';
}


}

/// @nodoc
abstract mixin class $AnalyzeResponseCopyWith<$Res>  {
  factory $AnalyzeResponseCopyWith(AnalyzeResponse value, $Res Function(AnalyzeResponse) _then) = _$AnalyzeResponseCopyWithImpl;
@useResult
$Res call({
 String imageId, String? imageUrl, int? imageWidth, int? imageHeight, Analysis analysis, Lang lang, Timings timingsMs
});


$AnalysisCopyWith<$Res> get analysis;

}
/// @nodoc
class _$AnalyzeResponseCopyWithImpl<$Res>
    implements $AnalyzeResponseCopyWith<$Res> {
  _$AnalyzeResponseCopyWithImpl(this._self, this._then);

  final AnalyzeResponse _self;
  final $Res Function(AnalyzeResponse) _then;

/// Create a copy of AnalyzeResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imageId = null,Object? imageUrl = freezed,Object? imageWidth = freezed,Object? imageHeight = freezed,Object? analysis = null,Object? lang = null,Object? timingsMs = null,}) {
  return _then(_self.copyWith(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,imageWidth: freezed == imageWidth ? _self.imageWidth : imageWidth // ignore: cast_nullable_to_non_nullable
as int?,imageHeight: freezed == imageHeight ? _self.imageHeight : imageHeight // ignore: cast_nullable_to_non_nullable
as int?,analysis: null == analysis ? _self.analysis : analysis // ignore: cast_nullable_to_non_nullable
as Analysis,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as Lang,timingsMs: null == timingsMs ? _self.timingsMs : timingsMs // ignore: cast_nullable_to_non_nullable
as Timings,
  ));
}
/// Create a copy of AnalyzeResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalysisCopyWith<$Res> get analysis {
  
  return $AnalysisCopyWith<$Res>(_self.analysis, (value) {
    return _then(_self.copyWith(analysis: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalyzeResponse].
extension AnalyzeResponsePatterns on AnalyzeResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyzeResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyzeResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyzeResponse value)  $default,){
final _that = this;
switch (_that) {
case _AnalyzeResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyzeResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyzeResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String imageId,  String? imageUrl,  int? imageWidth,  int? imageHeight,  Analysis analysis,  Lang lang,  Timings timingsMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyzeResponse() when $default != null:
return $default(_that.imageId,_that.imageUrl,_that.imageWidth,_that.imageHeight,_that.analysis,_that.lang,_that.timingsMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String imageId,  String? imageUrl,  int? imageWidth,  int? imageHeight,  Analysis analysis,  Lang lang,  Timings timingsMs)  $default,) {final _that = this;
switch (_that) {
case _AnalyzeResponse():
return $default(_that.imageId,_that.imageUrl,_that.imageWidth,_that.imageHeight,_that.analysis,_that.lang,_that.timingsMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String imageId,  String? imageUrl,  int? imageWidth,  int? imageHeight,  Analysis analysis,  Lang lang,  Timings timingsMs)?  $default,) {final _that = this;
switch (_that) {
case _AnalyzeResponse() when $default != null:
return $default(_that.imageId,_that.imageUrl,_that.imageWidth,_that.imageHeight,_that.analysis,_that.lang,_that.timingsMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyzeResponse implements AnalyzeResponse {
  const _AnalyzeResponse({required this.imageId, required this.imageUrl, this.imageWidth, this.imageHeight, required this.analysis, required this.lang, final  Timings timingsMs = const <String, int>{}}): _timingsMs = timingsMs;
  factory _AnalyzeResponse.fromJson(Map<String, dynamic> json) => _$AnalyzeResponseFromJson(json);

/// 'img_...' for photos, 'txt_...' for text input.
@override final  String imageId;
/// Path of the stored upload ('/static/uploads/...'); null for text input.
@override final  String? imageUrl;
@override final  int? imageWidth;
@override final  int? imageHeight;
@override final  Analysis analysis;
@override final  Lang lang;
 final  Timings _timingsMs;
@override@JsonKey() Timings get timingsMs {
  if (_timingsMs is EqualUnmodifiableMapView) return _timingsMs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_timingsMs);
}


/// Create a copy of AnalyzeResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyzeResponseCopyWith<_AnalyzeResponse> get copyWith => __$AnalyzeResponseCopyWithImpl<_AnalyzeResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyzeResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyzeResponse&&(identical(other.imageId, imageId) || other.imageId == imageId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.imageWidth, imageWidth) || other.imageWidth == imageWidth)&&(identical(other.imageHeight, imageHeight) || other.imageHeight == imageHeight)&&(identical(other.analysis, analysis) || other.analysis == analysis)&&(identical(other.lang, lang) || other.lang == lang)&&const DeepCollectionEquality().equals(other._timingsMs, _timingsMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageId,imageUrl,imageWidth,imageHeight,analysis,lang,const DeepCollectionEquality().hash(_timingsMs));

@override
String toString() {
  return 'AnalyzeResponse(imageId: $imageId, imageUrl: $imageUrl, imageWidth: $imageWidth, imageHeight: $imageHeight, analysis: $analysis, lang: $lang, timingsMs: $timingsMs)';
}


}

/// @nodoc
abstract mixin class _$AnalyzeResponseCopyWith<$Res> implements $AnalyzeResponseCopyWith<$Res> {
  factory _$AnalyzeResponseCopyWith(_AnalyzeResponse value, $Res Function(_AnalyzeResponse) _then) = __$AnalyzeResponseCopyWithImpl;
@override @useResult
$Res call({
 String imageId, String? imageUrl, int? imageWidth, int? imageHeight, Analysis analysis, Lang lang, Timings timingsMs
});


@override $AnalysisCopyWith<$Res> get analysis;

}
/// @nodoc
class __$AnalyzeResponseCopyWithImpl<$Res>
    implements _$AnalyzeResponseCopyWith<$Res> {
  __$AnalyzeResponseCopyWithImpl(this._self, this._then);

  final _AnalyzeResponse _self;
  final $Res Function(_AnalyzeResponse) _then;

/// Create a copy of AnalyzeResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imageId = null,Object? imageUrl = freezed,Object? imageWidth = freezed,Object? imageHeight = freezed,Object? analysis = null,Object? lang = null,Object? timingsMs = null,}) {
  return _then(_AnalyzeResponse(
imageId: null == imageId ? _self.imageId : imageId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,imageWidth: freezed == imageWidth ? _self.imageWidth : imageWidth // ignore: cast_nullable_to_non_nullable
as int?,imageHeight: freezed == imageHeight ? _self.imageHeight : imageHeight // ignore: cast_nullable_to_non_nullable
as int?,analysis: null == analysis ? _self.analysis : analysis // ignore: cast_nullable_to_non_nullable
as Analysis,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as Lang,timingsMs: null == timingsMs ? _self._timingsMs : timingsMs // ignore: cast_nullable_to_non_nullable
as Timings,
  ));
}

/// Create a copy of AnalyzeResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalysisCopyWith<$Res> get analysis {
  
  return $AnalysisCopyWith<$Res>(_self.analysis, (value) {
    return _then(_self.copyWith(analysis: value));
  });
}
}

// dart format on
