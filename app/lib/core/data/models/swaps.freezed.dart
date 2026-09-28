// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'swaps.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HistorySummary {

 int get periodDays;/// Items scanned per material.
 Map<MaterialCategory, int> get counts;/// Most frequent item names, e.g. 'plastic bottle'.
 List<String> get topItems;/// Counts aligned with [topItems].
 List<int> get topItemCounts;
/// Create a copy of HistorySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistorySummaryCopyWith<HistorySummary> get copyWith => _$HistorySummaryCopyWithImpl<HistorySummary>(this as HistorySummary, _$identity);

  /// Serializes this HistorySummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistorySummary&&(identical(other.periodDays, periodDays) || other.periodDays == periodDays)&&const DeepCollectionEquality().equals(other.counts, counts)&&const DeepCollectionEquality().equals(other.topItems, topItems)&&const DeepCollectionEquality().equals(other.topItemCounts, topItemCounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,periodDays,const DeepCollectionEquality().hash(counts),const DeepCollectionEquality().hash(topItems),const DeepCollectionEquality().hash(topItemCounts));

@override
String toString() {
  return 'HistorySummary(periodDays: $periodDays, counts: $counts, topItems: $topItems, topItemCounts: $topItemCounts)';
}


}

/// @nodoc
abstract mixin class $HistorySummaryCopyWith<$Res>  {
  factory $HistorySummaryCopyWith(HistorySummary value, $Res Function(HistorySummary) _then) = _$HistorySummaryCopyWithImpl;
@useResult
$Res call({
 int periodDays, Map<MaterialCategory, int> counts, List<String> topItems, List<int> topItemCounts
});




}
/// @nodoc
class _$HistorySummaryCopyWithImpl<$Res>
    implements $HistorySummaryCopyWith<$Res> {
  _$HistorySummaryCopyWithImpl(this._self, this._then);

  final HistorySummary _self;
  final $Res Function(HistorySummary) _then;

/// Create a copy of HistorySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? periodDays = null,Object? counts = null,Object? topItems = null,Object? topItemCounts = null,}) {
  return _then(_self.copyWith(
periodDays: null == periodDays ? _self.periodDays : periodDays // ignore: cast_nullable_to_non_nullable
as int,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as Map<MaterialCategory, int>,topItems: null == topItems ? _self.topItems : topItems // ignore: cast_nullable_to_non_nullable
as List<String>,topItemCounts: null == topItemCounts ? _self.topItemCounts : topItemCounts // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [HistorySummary].
extension HistorySummaryPatterns on HistorySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistorySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistorySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistorySummary value)  $default,){
final _that = this;
switch (_that) {
case _HistorySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistorySummary value)?  $default,){
final _that = this;
switch (_that) {
case _HistorySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int periodDays,  Map<MaterialCategory, int> counts,  List<String> topItems,  List<int> topItemCounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistorySummary() when $default != null:
return $default(_that.periodDays,_that.counts,_that.topItems,_that.topItemCounts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int periodDays,  Map<MaterialCategory, int> counts,  List<String> topItems,  List<int> topItemCounts)  $default,) {final _that = this;
switch (_that) {
case _HistorySummary():
return $default(_that.periodDays,_that.counts,_that.topItems,_that.topItemCounts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int periodDays,  Map<MaterialCategory, int> counts,  List<String> topItems,  List<int> topItemCounts)?  $default,) {final _that = this;
switch (_that) {
case _HistorySummary() when $default != null:
return $default(_that.periodDays,_that.counts,_that.topItems,_that.topItemCounts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HistorySummary extends HistorySummary {
  const _HistorySummary({this.periodDays = 30, final  Map<MaterialCategory, int> counts = const <MaterialCategory, int>{}, final  List<String> topItems = const <String>[], final  List<int> topItemCounts = const <int>[]}): _counts = counts,_topItems = topItems,_topItemCounts = topItemCounts,super._();
  factory _HistorySummary.fromJson(Map<String, dynamic> json) => _$HistorySummaryFromJson(json);

@override@JsonKey() final  int periodDays;
/// Items scanned per material.
 final  Map<MaterialCategory, int> _counts;
/// Items scanned per material.
@override@JsonKey() Map<MaterialCategory, int> get counts {
  if (_counts is EqualUnmodifiableMapView) return _counts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_counts);
}

/// Most frequent item names, e.g. 'plastic bottle'.
 final  List<String> _topItems;
/// Most frequent item names, e.g. 'plastic bottle'.
@override@JsonKey() List<String> get topItems {
  if (_topItems is EqualUnmodifiableListView) return _topItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topItems);
}

/// Counts aligned with [topItems].
 final  List<int> _topItemCounts;
/// Counts aligned with [topItems].
@override@JsonKey() List<int> get topItemCounts {
  if (_topItemCounts is EqualUnmodifiableListView) return _topItemCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topItemCounts);
}


/// Create a copy of HistorySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistorySummaryCopyWith<_HistorySummary> get copyWith => __$HistorySummaryCopyWithImpl<_HistorySummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistorySummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistorySummary&&(identical(other.periodDays, periodDays) || other.periodDays == periodDays)&&const DeepCollectionEquality().equals(other._counts, _counts)&&const DeepCollectionEquality().equals(other._topItems, _topItems)&&const DeepCollectionEquality().equals(other._topItemCounts, _topItemCounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,periodDays,const DeepCollectionEquality().hash(_counts),const DeepCollectionEquality().hash(_topItems),const DeepCollectionEquality().hash(_topItemCounts));

@override
String toString() {
  return 'HistorySummary(periodDays: $periodDays, counts: $counts, topItems: $topItems, topItemCounts: $topItemCounts)';
}


}

/// @nodoc
abstract mixin class _$HistorySummaryCopyWith<$Res> implements $HistorySummaryCopyWith<$Res> {
  factory _$HistorySummaryCopyWith(_HistorySummary value, $Res Function(_HistorySummary) _then) = __$HistorySummaryCopyWithImpl;
@override @useResult
$Res call({
 int periodDays, Map<MaterialCategory, int> counts, List<String> topItems, List<int> topItemCounts
});




}
/// @nodoc
class __$HistorySummaryCopyWithImpl<$Res>
    implements _$HistorySummaryCopyWith<$Res> {
  __$HistorySummaryCopyWithImpl(this._self, this._then);

  final _HistorySummary _self;
  final $Res Function(_HistorySummary) _then;

/// Create a copy of HistorySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? periodDays = null,Object? counts = null,Object? topItems = null,Object? topItemCounts = null,}) {
  return _then(_HistorySummary(
periodDays: null == periodDays ? _self.periodDays : periodDays // ignore: cast_nullable_to_non_nullable
as int,counts: null == counts ? _self._counts : counts // ignore: cast_nullable_to_non_nullable
as Map<MaterialCategory, int>,topItems: null == topItems ? _self._topItems : topItems // ignore: cast_nullable_to_non_nullable
as List<String>,topItemCounts: null == topItemCounts ? _self._topItemCounts : topItemCounts // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$SwapsRequest {

/// Chip ids and/or free text: 'plastic bags', 'cling film'.
 List<String> get materials; HistorySummary? get history; Lang get lang;
/// Create a copy of SwapsRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwapsRequestCopyWith<SwapsRequest> get copyWith => _$SwapsRequestCopyWithImpl<SwapsRequest>(this as SwapsRequest, _$identity);

  /// Serializes this SwapsRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwapsRequest&&const DeepCollectionEquality().equals(other.materials, materials)&&(identical(other.history, history) || other.history == history)&&(identical(other.lang, lang) || other.lang == lang));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(materials),history,lang);

@override
String toString() {
  return 'SwapsRequest(materials: $materials, history: $history, lang: $lang)';
}


}

/// @nodoc
abstract mixin class $SwapsRequestCopyWith<$Res>  {
  factory $SwapsRequestCopyWith(SwapsRequest value, $Res Function(SwapsRequest) _then) = _$SwapsRequestCopyWithImpl;
@useResult
$Res call({
 List<String> materials, HistorySummary? history, Lang lang
});


$HistorySummaryCopyWith<$Res>? get history;

}
/// @nodoc
class _$SwapsRequestCopyWithImpl<$Res>
    implements $SwapsRequestCopyWith<$Res> {
  _$SwapsRequestCopyWithImpl(this._self, this._then);

  final SwapsRequest _self;
  final $Res Function(SwapsRequest) _then;

/// Create a copy of SwapsRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? materials = null,Object? history = freezed,Object? lang = null,}) {
  return _then(_self.copyWith(
materials: null == materials ? _self.materials : materials // ignore: cast_nullable_to_non_nullable
as List<String>,history: freezed == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as HistorySummary?,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as Lang,
  ));
}
/// Create a copy of SwapsRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HistorySummaryCopyWith<$Res>? get history {
    if (_self.history == null) {
    return null;
  }

  return $HistorySummaryCopyWith<$Res>(_self.history!, (value) {
    return _then(_self.copyWith(history: value));
  });
}
}


/// Adds pattern-matching-related methods to [SwapsRequest].
extension SwapsRequestPatterns on SwapsRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwapsRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwapsRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwapsRequest value)  $default,){
final _that = this;
switch (_that) {
case _SwapsRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwapsRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SwapsRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> materials,  HistorySummary? history,  Lang lang)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwapsRequest() when $default != null:
return $default(_that.materials,_that.history,_that.lang);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> materials,  HistorySummary? history,  Lang lang)  $default,) {final _that = this;
switch (_that) {
case _SwapsRequest():
return $default(_that.materials,_that.history,_that.lang);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> materials,  HistorySummary? history,  Lang lang)?  $default,) {final _that = this;
switch (_that) {
case _SwapsRequest() when $default != null:
return $default(_that.materials,_that.history,_that.lang);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SwapsRequest implements SwapsRequest {
  const _SwapsRequest({final  List<String> materials = const <String>[], this.history, this.lang = Lang.en}): _materials = materials;
  factory _SwapsRequest.fromJson(Map<String, dynamic> json) => _$SwapsRequestFromJson(json);

/// Chip ids and/or free text: 'plastic bags', 'cling film'.
 final  List<String> _materials;
/// Chip ids and/or free text: 'plastic bags', 'cling film'.
@override@JsonKey() List<String> get materials {
  if (_materials is EqualUnmodifiableListView) return _materials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_materials);
}

@override final  HistorySummary? history;
@override@JsonKey() final  Lang lang;

/// Create a copy of SwapsRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwapsRequestCopyWith<_SwapsRequest> get copyWith => __$SwapsRequestCopyWithImpl<_SwapsRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SwapsRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwapsRequest&&const DeepCollectionEquality().equals(other._materials, _materials)&&(identical(other.history, history) || other.history == history)&&(identical(other.lang, lang) || other.lang == lang));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_materials),history,lang);

@override
String toString() {
  return 'SwapsRequest(materials: $materials, history: $history, lang: $lang)';
}


}

/// @nodoc
abstract mixin class _$SwapsRequestCopyWith<$Res> implements $SwapsRequestCopyWith<$Res> {
  factory _$SwapsRequestCopyWith(_SwapsRequest value, $Res Function(_SwapsRequest) _then) = __$SwapsRequestCopyWithImpl;
@override @useResult
$Res call({
 List<String> materials, HistorySummary? history, Lang lang
});


@override $HistorySummaryCopyWith<$Res>? get history;

}
/// @nodoc
class __$SwapsRequestCopyWithImpl<$Res>
    implements _$SwapsRequestCopyWith<$Res> {
  __$SwapsRequestCopyWithImpl(this._self, this._then);

  final _SwapsRequest _self;
  final $Res Function(_SwapsRequest) _then;

/// Create a copy of SwapsRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? materials = null,Object? history = freezed,Object? lang = null,}) {
  return _then(_SwapsRequest(
materials: null == materials ? _self._materials : materials // ignore: cast_nullable_to_non_nullable
as List<String>,history: freezed == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as HistorySummary?,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as Lang,
  ));
}

/// Create a copy of SwapsRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HistorySummaryCopyWith<$Res>? get history {
    if (_self.history == null) {
    return null;
  }

  return $HistorySummaryCopyWith<$Res>(_self.history!, (value) {
    return _then(_self.copyWith(history: value));
  });
}
}


/// @nodoc
mixin _$Swap {

 String get id;/// What it replaces, localized.
 String get fromItem;/// The alternative, localized.
 String get toItem; String get why;/// One practical tip for making the switch.
 String get tip; Level get effort; Level get cost;/// Material of the thing being replaced.
 MaterialCategory get category;/// Qualitative, unless a knowledge-base source with a number is cited.
 String? get impactNote;/// The user input this card answers.
 String? get matchedInput; bool get fromHistory; List<SourceRef> get sources;
/// Create a copy of Swap
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwapCopyWith<Swap> get copyWith => _$SwapCopyWithImpl<Swap>(this as Swap, _$identity);

  /// Serializes this Swap to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Swap&&(identical(other.id, id) || other.id == id)&&(identical(other.fromItem, fromItem) || other.fromItem == fromItem)&&(identical(other.toItem, toItem) || other.toItem == toItem)&&(identical(other.why, why) || other.why == why)&&(identical(other.tip, tip) || other.tip == tip)&&(identical(other.effort, effort) || other.effort == effort)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.category, category) || other.category == category)&&(identical(other.impactNote, impactNote) || other.impactNote == impactNote)&&(identical(other.matchedInput, matchedInput) || other.matchedInput == matchedInput)&&(identical(other.fromHistory, fromHistory) || other.fromHistory == fromHistory)&&const DeepCollectionEquality().equals(other.sources, sources));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromItem,toItem,why,tip,effort,cost,category,impactNote,matchedInput,fromHistory,const DeepCollectionEquality().hash(sources));

@override
String toString() {
  return 'Swap(id: $id, fromItem: $fromItem, toItem: $toItem, why: $why, tip: $tip, effort: $effort, cost: $cost, category: $category, impactNote: $impactNote, matchedInput: $matchedInput, fromHistory: $fromHistory, sources: $sources)';
}


}

/// @nodoc
abstract mixin class $SwapCopyWith<$Res>  {
  factory $SwapCopyWith(Swap value, $Res Function(Swap) _then) = _$SwapCopyWithImpl;
@useResult
$Res call({
 String id, String fromItem, String toItem, String why, String tip, Level effort, Level cost, MaterialCategory category, String? impactNote, String? matchedInput, bool fromHistory, List<SourceRef> sources
});




}
/// @nodoc
class _$SwapCopyWithImpl<$Res>
    implements $SwapCopyWith<$Res> {
  _$SwapCopyWithImpl(this._self, this._then);

  final Swap _self;
  final $Res Function(Swap) _then;

/// Create a copy of Swap
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromItem = null,Object? toItem = null,Object? why = null,Object? tip = null,Object? effort = null,Object? cost = null,Object? category = null,Object? impactNote = freezed,Object? matchedInput = freezed,Object? fromHistory = null,Object? sources = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromItem: null == fromItem ? _self.fromItem : fromItem // ignore: cast_nullable_to_non_nullable
as String,toItem: null == toItem ? _self.toItem : toItem // ignore: cast_nullable_to_non_nullable
as String,why: null == why ? _self.why : why // ignore: cast_nullable_to_non_nullable
as String,tip: null == tip ? _self.tip : tip // ignore: cast_nullable_to_non_nullable
as String,effort: null == effort ? _self.effort : effort // ignore: cast_nullable_to_non_nullable
as Level,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as Level,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as MaterialCategory,impactNote: freezed == impactNote ? _self.impactNote : impactNote // ignore: cast_nullable_to_non_nullable
as String?,matchedInput: freezed == matchedInput ? _self.matchedInput : matchedInput // ignore: cast_nullable_to_non_nullable
as String?,fromHistory: null == fromHistory ? _self.fromHistory : fromHistory // ignore: cast_nullable_to_non_nullable
as bool,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<SourceRef>,
  ));
}

}


/// Adds pattern-matching-related methods to [Swap].
extension SwapPatterns on Swap {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Swap value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Swap() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Swap value)  $default,){
final _that = this;
switch (_that) {
case _Swap():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Swap value)?  $default,){
final _that = this;
switch (_that) {
case _Swap() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fromItem,  String toItem,  String why,  String tip,  Level effort,  Level cost,  MaterialCategory category,  String? impactNote,  String? matchedInput,  bool fromHistory,  List<SourceRef> sources)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Swap() when $default != null:
return $default(_that.id,_that.fromItem,_that.toItem,_that.why,_that.tip,_that.effort,_that.cost,_that.category,_that.impactNote,_that.matchedInput,_that.fromHistory,_that.sources);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fromItem,  String toItem,  String why,  String tip,  Level effort,  Level cost,  MaterialCategory category,  String? impactNote,  String? matchedInput,  bool fromHistory,  List<SourceRef> sources)  $default,) {final _that = this;
switch (_that) {
case _Swap():
return $default(_that.id,_that.fromItem,_that.toItem,_that.why,_that.tip,_that.effort,_that.cost,_that.category,_that.impactNote,_that.matchedInput,_that.fromHistory,_that.sources);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fromItem,  String toItem,  String why,  String tip,  Level effort,  Level cost,  MaterialCategory category,  String? impactNote,  String? matchedInput,  bool fromHistory,  List<SourceRef> sources)?  $default,) {final _that = this;
switch (_that) {
case _Swap() when $default != null:
return $default(_that.id,_that.fromItem,_that.toItem,_that.why,_that.tip,_that.effort,_that.cost,_that.category,_that.impactNote,_that.matchedInput,_that.fromHistory,_that.sources);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Swap implements Swap {
  const _Swap({required this.id, required this.fromItem, required this.toItem, required this.why, required this.tip, required this.effort, required this.cost, required this.category, this.impactNote, this.matchedInput, this.fromHistory = false, final  List<SourceRef> sources = const <SourceRef>[]}): _sources = sources;
  factory _Swap.fromJson(Map<String, dynamic> json) => _$SwapFromJson(json);

@override final  String id;
/// What it replaces, localized.
@override final  String fromItem;
/// The alternative, localized.
@override final  String toItem;
@override final  String why;
/// One practical tip for making the switch.
@override final  String tip;
@override final  Level effort;
@override final  Level cost;
/// Material of the thing being replaced.
@override final  MaterialCategory category;
/// Qualitative, unless a knowledge-base source with a number is cited.
@override final  String? impactNote;
/// The user input this card answers.
@override final  String? matchedInput;
@override@JsonKey() final  bool fromHistory;
 final  List<SourceRef> _sources;
@override@JsonKey() List<SourceRef> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}


/// Create a copy of Swap
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwapCopyWith<_Swap> get copyWith => __$SwapCopyWithImpl<_Swap>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SwapToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Swap&&(identical(other.id, id) || other.id == id)&&(identical(other.fromItem, fromItem) || other.fromItem == fromItem)&&(identical(other.toItem, toItem) || other.toItem == toItem)&&(identical(other.why, why) || other.why == why)&&(identical(other.tip, tip) || other.tip == tip)&&(identical(other.effort, effort) || other.effort == effort)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.category, category) || other.category == category)&&(identical(other.impactNote, impactNote) || other.impactNote == impactNote)&&(identical(other.matchedInput, matchedInput) || other.matchedInput == matchedInput)&&(identical(other.fromHistory, fromHistory) || other.fromHistory == fromHistory)&&const DeepCollectionEquality().equals(other._sources, _sources));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromItem,toItem,why,tip,effort,cost,category,impactNote,matchedInput,fromHistory,const DeepCollectionEquality().hash(_sources));

@override
String toString() {
  return 'Swap(id: $id, fromItem: $fromItem, toItem: $toItem, why: $why, tip: $tip, effort: $effort, cost: $cost, category: $category, impactNote: $impactNote, matchedInput: $matchedInput, fromHistory: $fromHistory, sources: $sources)';
}


}

/// @nodoc
abstract mixin class _$SwapCopyWith<$Res> implements $SwapCopyWith<$Res> {
  factory _$SwapCopyWith(_Swap value, $Res Function(_Swap) _then) = __$SwapCopyWithImpl;
@override @useResult
$Res call({
 String id, String fromItem, String toItem, String why, String tip, Level effort, Level cost, MaterialCategory category, String? impactNote, String? matchedInput, bool fromHistory, List<SourceRef> sources
});




}
/// @nodoc
class __$SwapCopyWithImpl<$Res>
    implements _$SwapCopyWith<$Res> {
  __$SwapCopyWithImpl(this._self, this._then);

  final _Swap _self;
  final $Res Function(_Swap) _then;

/// Create a copy of Swap
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromItem = null,Object? toItem = null,Object? why = null,Object? tip = null,Object? effort = null,Object? cost = null,Object? category = null,Object? impactNote = freezed,Object? matchedInput = freezed,Object? fromHistory = null,Object? sources = null,}) {
  return _then(_Swap(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromItem: null == fromItem ? _self.fromItem : fromItem // ignore: cast_nullable_to_non_nullable
as String,toItem: null == toItem ? _self.toItem : toItem // ignore: cast_nullable_to_non_nullable
as String,why: null == why ? _self.why : why // ignore: cast_nullable_to_non_nullable
as String,tip: null == tip ? _self.tip : tip // ignore: cast_nullable_to_non_nullable
as String,effort: null == effort ? _self.effort : effort // ignore: cast_nullable_to_non_nullable
as Level,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as Level,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as MaterialCategory,impactNote: freezed == impactNote ? _self.impactNote : impactNote // ignore: cast_nullable_to_non_nullable
as String?,matchedInput: freezed == matchedInput ? _self.matchedInput : matchedInput // ignore: cast_nullable_to_non_nullable
as String?,fromHistory: null == fromHistory ? _self.fromHistory : fromHistory // ignore: cast_nullable_to_non_nullable
as bool,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<SourceRef>,
  ));
}


}


/// @nodoc
mixin _$SwapsResponse {

 List<Swap> get swaps;/// 'You scanned 6 plastic bottles this month.'
 String? get historyInsight; Lang get lang; Timings get timingsMs;
/// Create a copy of SwapsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwapsResponseCopyWith<SwapsResponse> get copyWith => _$SwapsResponseCopyWithImpl<SwapsResponse>(this as SwapsResponse, _$identity);

  /// Serializes this SwapsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwapsResponse&&const DeepCollectionEquality().equals(other.swaps, swaps)&&(identical(other.historyInsight, historyInsight) || other.historyInsight == historyInsight)&&(identical(other.lang, lang) || other.lang == lang)&&const DeepCollectionEquality().equals(other.timingsMs, timingsMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(swaps),historyInsight,lang,const DeepCollectionEquality().hash(timingsMs));

@override
String toString() {
  return 'SwapsResponse(swaps: $swaps, historyInsight: $historyInsight, lang: $lang, timingsMs: $timingsMs)';
}


}

/// @nodoc
abstract mixin class $SwapsResponseCopyWith<$Res>  {
  factory $SwapsResponseCopyWith(SwapsResponse value, $Res Function(SwapsResponse) _then) = _$SwapsResponseCopyWithImpl;
@useResult
$Res call({
 List<Swap> swaps, String? historyInsight, Lang lang, Timings timingsMs
});




}
/// @nodoc
class _$SwapsResponseCopyWithImpl<$Res>
    implements $SwapsResponseCopyWith<$Res> {
  _$SwapsResponseCopyWithImpl(this._self, this._then);

  final SwapsResponse _self;
  final $Res Function(SwapsResponse) _then;

/// Create a copy of SwapsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? swaps = null,Object? historyInsight = freezed,Object? lang = null,Object? timingsMs = null,}) {
  return _then(_self.copyWith(
swaps: null == swaps ? _self.swaps : swaps // ignore: cast_nullable_to_non_nullable
as List<Swap>,historyInsight: freezed == historyInsight ? _self.historyInsight : historyInsight // ignore: cast_nullable_to_non_nullable
as String?,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as Lang,timingsMs: null == timingsMs ? _self.timingsMs : timingsMs // ignore: cast_nullable_to_non_nullable
as Timings,
  ));
}

}


/// Adds pattern-matching-related methods to [SwapsResponse].
extension SwapsResponsePatterns on SwapsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwapsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwapsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwapsResponse value)  $default,){
final _that = this;
switch (_that) {
case _SwapsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwapsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SwapsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Swap> swaps,  String? historyInsight,  Lang lang,  Timings timingsMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwapsResponse() when $default != null:
return $default(_that.swaps,_that.historyInsight,_that.lang,_that.timingsMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Swap> swaps,  String? historyInsight,  Lang lang,  Timings timingsMs)  $default,) {final _that = this;
switch (_that) {
case _SwapsResponse():
return $default(_that.swaps,_that.historyInsight,_that.lang,_that.timingsMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Swap> swaps,  String? historyInsight,  Lang lang,  Timings timingsMs)?  $default,) {final _that = this;
switch (_that) {
case _SwapsResponse() when $default != null:
return $default(_that.swaps,_that.historyInsight,_that.lang,_that.timingsMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SwapsResponse implements SwapsResponse {
  const _SwapsResponse({required final  List<Swap> swaps, this.historyInsight, required this.lang, final  Timings timingsMs = const <String, int>{}}): _swaps = swaps,_timingsMs = timingsMs;
  factory _SwapsResponse.fromJson(Map<String, dynamic> json) => _$SwapsResponseFromJson(json);

 final  List<Swap> _swaps;
@override List<Swap> get swaps {
  if (_swaps is EqualUnmodifiableListView) return _swaps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_swaps);
}

/// 'You scanned 6 plastic bottles this month.'
@override final  String? historyInsight;
@override final  Lang lang;
 final  Timings _timingsMs;
@override@JsonKey() Timings get timingsMs {
  if (_timingsMs is EqualUnmodifiableMapView) return _timingsMs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_timingsMs);
}


/// Create a copy of SwapsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwapsResponseCopyWith<_SwapsResponse> get copyWith => __$SwapsResponseCopyWithImpl<_SwapsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SwapsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwapsResponse&&const DeepCollectionEquality().equals(other._swaps, _swaps)&&(identical(other.historyInsight, historyInsight) || other.historyInsight == historyInsight)&&(identical(other.lang, lang) || other.lang == lang)&&const DeepCollectionEquality().equals(other._timingsMs, _timingsMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_swaps),historyInsight,lang,const DeepCollectionEquality().hash(_timingsMs));

@override
String toString() {
  return 'SwapsResponse(swaps: $swaps, historyInsight: $historyInsight, lang: $lang, timingsMs: $timingsMs)';
}


}

/// @nodoc
abstract mixin class _$SwapsResponseCopyWith<$Res> implements $SwapsResponseCopyWith<$Res> {
  factory _$SwapsResponseCopyWith(_SwapsResponse value, $Res Function(_SwapsResponse) _then) = __$SwapsResponseCopyWithImpl;
@override @useResult
$Res call({
 List<Swap> swaps, String? historyInsight, Lang lang, Timings timingsMs
});




}
/// @nodoc
class __$SwapsResponseCopyWithImpl<$Res>
    implements _$SwapsResponseCopyWith<$Res> {
  __$SwapsResponseCopyWithImpl(this._self, this._then);

  final _SwapsResponse _self;
  final $Res Function(_SwapsResponse) _then;

/// Create a copy of SwapsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? swaps = null,Object? historyInsight = freezed,Object? lang = null,Object? timingsMs = null,}) {
  return _then(_SwapsResponse(
swaps: null == swaps ? _self._swaps : swaps // ignore: cast_nullable_to_non_nullable
as List<Swap>,historyInsight: freezed == historyInsight ? _self.historyInsight : historyInsight // ignore: cast_nullable_to_non_nullable
as String?,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as Lang,timingsMs: null == timingsMs ? _self._timingsMs : timingsMs // ignore: cast_nullable_to_non_nullable
as Timings,
  ));
}


}

// dart format on
