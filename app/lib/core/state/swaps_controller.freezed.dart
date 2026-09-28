// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'swaps_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SwapsState {

/// Selected chips: material category ids ('plastic') or chip phrases.
 Set<String> get selectedChips;/// Free text such as "plastic bags, cling film".
 String get freeText;/// Send the last 30 days of scans so the advisor can personalize.
 bool get useHistory;/// What the user scanned recently (null until computed).
 HistorySummary? get history; bool get loading; SwapsResponse? get results; ApiException? get error;
/// Create a copy of SwapsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwapsStateCopyWith<SwapsState> get copyWith => _$SwapsStateCopyWithImpl<SwapsState>(this as SwapsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwapsState&&const DeepCollectionEquality().equals(other.selectedChips, selectedChips)&&(identical(other.freeText, freeText) || other.freeText == freeText)&&(identical(other.useHistory, useHistory) || other.useHistory == useHistory)&&(identical(other.history, history) || other.history == history)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.results, results) || other.results == results)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(selectedChips),freeText,useHistory,history,loading,results,error);

@override
String toString() {
  return 'SwapsState(selectedChips: $selectedChips, freeText: $freeText, useHistory: $useHistory, history: $history, loading: $loading, results: $results, error: $error)';
}


}

/// @nodoc
abstract mixin class $SwapsStateCopyWith<$Res>  {
  factory $SwapsStateCopyWith(SwapsState value, $Res Function(SwapsState) _then) = _$SwapsStateCopyWithImpl;
@useResult
$Res call({
 Set<String> selectedChips, String freeText, bool useHistory, HistorySummary? history, bool loading, SwapsResponse? results, ApiException? error
});


$HistorySummaryCopyWith<$Res>? get history;$SwapsResponseCopyWith<$Res>? get results;

}
/// @nodoc
class _$SwapsStateCopyWithImpl<$Res>
    implements $SwapsStateCopyWith<$Res> {
  _$SwapsStateCopyWithImpl(this._self, this._then);

  final SwapsState _self;
  final $Res Function(SwapsState) _then;

/// Create a copy of SwapsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedChips = null,Object? freeText = null,Object? useHistory = null,Object? history = freezed,Object? loading = null,Object? results = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
selectedChips: null == selectedChips ? _self.selectedChips : selectedChips // ignore: cast_nullable_to_non_nullable
as Set<String>,freeText: null == freeText ? _self.freeText : freeText // ignore: cast_nullable_to_non_nullable
as String,useHistory: null == useHistory ? _self.useHistory : useHistory // ignore: cast_nullable_to_non_nullable
as bool,history: freezed == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as HistorySummary?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,results: freezed == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as SwapsResponse?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiException?,
  ));
}
/// Create a copy of SwapsState
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
}/// Create a copy of SwapsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwapsResponseCopyWith<$Res>? get results {
    if (_self.results == null) {
    return null;
  }

  return $SwapsResponseCopyWith<$Res>(_self.results!, (value) {
    return _then(_self.copyWith(results: value));
  });
}
}


/// Adds pattern-matching-related methods to [SwapsState].
extension SwapsStatePatterns on SwapsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwapsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwapsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwapsState value)  $default,){
final _that = this;
switch (_that) {
case _SwapsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwapsState value)?  $default,){
final _that = this;
switch (_that) {
case _SwapsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Set<String> selectedChips,  String freeText,  bool useHistory,  HistorySummary? history,  bool loading,  SwapsResponse? results,  ApiException? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwapsState() when $default != null:
return $default(_that.selectedChips,_that.freeText,_that.useHistory,_that.history,_that.loading,_that.results,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Set<String> selectedChips,  String freeText,  bool useHistory,  HistorySummary? history,  bool loading,  SwapsResponse? results,  ApiException? error)  $default,) {final _that = this;
switch (_that) {
case _SwapsState():
return $default(_that.selectedChips,_that.freeText,_that.useHistory,_that.history,_that.loading,_that.results,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Set<String> selectedChips,  String freeText,  bool useHistory,  HistorySummary? history,  bool loading,  SwapsResponse? results,  ApiException? error)?  $default,) {final _that = this;
switch (_that) {
case _SwapsState() when $default != null:
return $default(_that.selectedChips,_that.freeText,_that.useHistory,_that.history,_that.loading,_that.results,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _SwapsState extends SwapsState {
  const _SwapsState({final  Set<String> selectedChips = const <String>{}, this.freeText = '', this.useHistory = true, this.history, this.loading = false, this.results, this.error}): _selectedChips = selectedChips,super._();
  

/// Selected chips: material category ids ('plastic') or chip phrases.
 final  Set<String> _selectedChips;
/// Selected chips: material category ids ('plastic') or chip phrases.
@override@JsonKey() Set<String> get selectedChips {
  if (_selectedChips is EqualUnmodifiableSetView) return _selectedChips;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedChips);
}

/// Free text such as "plastic bags, cling film".
@override@JsonKey() final  String freeText;
/// Send the last 30 days of scans so the advisor can personalize.
@override@JsonKey() final  bool useHistory;
/// What the user scanned recently (null until computed).
@override final  HistorySummary? history;
@override@JsonKey() final  bool loading;
@override final  SwapsResponse? results;
@override final  ApiException? error;

/// Create a copy of SwapsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwapsStateCopyWith<_SwapsState> get copyWith => __$SwapsStateCopyWithImpl<_SwapsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwapsState&&const DeepCollectionEquality().equals(other._selectedChips, _selectedChips)&&(identical(other.freeText, freeText) || other.freeText == freeText)&&(identical(other.useHistory, useHistory) || other.useHistory == useHistory)&&(identical(other.history, history) || other.history == history)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.results, results) || other.results == results)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_selectedChips),freeText,useHistory,history,loading,results,error);

@override
String toString() {
  return 'SwapsState(selectedChips: $selectedChips, freeText: $freeText, useHistory: $useHistory, history: $history, loading: $loading, results: $results, error: $error)';
}


}

/// @nodoc
abstract mixin class _$SwapsStateCopyWith<$Res> implements $SwapsStateCopyWith<$Res> {
  factory _$SwapsStateCopyWith(_SwapsState value, $Res Function(_SwapsState) _then) = __$SwapsStateCopyWithImpl;
@override @useResult
$Res call({
 Set<String> selectedChips, String freeText, bool useHistory, HistorySummary? history, bool loading, SwapsResponse? results, ApiException? error
});


@override $HistorySummaryCopyWith<$Res>? get history;@override $SwapsResponseCopyWith<$Res>? get results;

}
/// @nodoc
class __$SwapsStateCopyWithImpl<$Res>
    implements _$SwapsStateCopyWith<$Res> {
  __$SwapsStateCopyWithImpl(this._self, this._then);

  final _SwapsState _self;
  final $Res Function(_SwapsState) _then;

/// Create a copy of SwapsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedChips = null,Object? freeText = null,Object? useHistory = null,Object? history = freezed,Object? loading = null,Object? results = freezed,Object? error = freezed,}) {
  return _then(_SwapsState(
selectedChips: null == selectedChips ? _self._selectedChips : selectedChips // ignore: cast_nullable_to_non_nullable
as Set<String>,freeText: null == freeText ? _self.freeText : freeText // ignore: cast_nullable_to_non_nullable
as String,useHistory: null == useHistory ? _self.useHistory : useHistory // ignore: cast_nullable_to_non_nullable
as bool,history: freezed == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as HistorySummary?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,results: freezed == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as SwapsResponse?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiException?,
  ));
}

/// Create a copy of SwapsState
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
}/// Create a copy of SwapsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwapsResponseCopyWith<$Res>? get results {
    if (_self.results == null) {
    return null;
  }

  return $SwapsResponseCopyWith<$Res>(_self.results!, (value) {
    return _then(_self.copyWith(results: value));
  });
}
}

// dart format on
