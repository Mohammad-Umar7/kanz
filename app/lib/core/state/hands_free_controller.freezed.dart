// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hands_free_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HandsFreeState {

 bool get enabled;/// The microphone is open for "next", "back" or "repeat".
 bool get listening;/// A step is being read aloud (listening pauses meanwhile).
 bool get speaking;/// The last command heard, for a brief on-screen confirmation.
 VoiceCommand? get lastCommand;/// Speech recognition is unavailable or the microphone was denied:
/// steps are still read aloud, navigation stays on the buttons.
 bool get voiceUnavailable;/// No text-to-speech voice for the tutorial language on this phone.
 bool get speechUnavailable;
/// Create a copy of HandsFreeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HandsFreeStateCopyWith<HandsFreeState> get copyWith => _$HandsFreeStateCopyWithImpl<HandsFreeState>(this as HandsFreeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandsFreeState&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.listening, listening) || other.listening == listening)&&(identical(other.speaking, speaking) || other.speaking == speaking)&&(identical(other.lastCommand, lastCommand) || other.lastCommand == lastCommand)&&(identical(other.voiceUnavailable, voiceUnavailable) || other.voiceUnavailable == voiceUnavailable)&&(identical(other.speechUnavailable, speechUnavailable) || other.speechUnavailable == speechUnavailable));
}


@override
int get hashCode => Object.hash(runtimeType,enabled,listening,speaking,lastCommand,voiceUnavailable,speechUnavailable);

@override
String toString() {
  return 'HandsFreeState(enabled: $enabled, listening: $listening, speaking: $speaking, lastCommand: $lastCommand, voiceUnavailable: $voiceUnavailable, speechUnavailable: $speechUnavailable)';
}


}

/// @nodoc
abstract mixin class $HandsFreeStateCopyWith<$Res>  {
  factory $HandsFreeStateCopyWith(HandsFreeState value, $Res Function(HandsFreeState) _then) = _$HandsFreeStateCopyWithImpl;
@useResult
$Res call({
 bool enabled, bool listening, bool speaking, VoiceCommand? lastCommand, bool voiceUnavailable, bool speechUnavailable
});




}
/// @nodoc
class _$HandsFreeStateCopyWithImpl<$Res>
    implements $HandsFreeStateCopyWith<$Res> {
  _$HandsFreeStateCopyWithImpl(this._self, this._then);

  final HandsFreeState _self;
  final $Res Function(HandsFreeState) _then;

/// Create a copy of HandsFreeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? listening = null,Object? speaking = null,Object? lastCommand = freezed,Object? voiceUnavailable = null,Object? speechUnavailable = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,listening: null == listening ? _self.listening : listening // ignore: cast_nullable_to_non_nullable
as bool,speaking: null == speaking ? _self.speaking : speaking // ignore: cast_nullable_to_non_nullable
as bool,lastCommand: freezed == lastCommand ? _self.lastCommand : lastCommand // ignore: cast_nullable_to_non_nullable
as VoiceCommand?,voiceUnavailable: null == voiceUnavailable ? _self.voiceUnavailable : voiceUnavailable // ignore: cast_nullable_to_non_nullable
as bool,speechUnavailable: null == speechUnavailable ? _self.speechUnavailable : speechUnavailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HandsFreeState].
extension HandsFreeStatePatterns on HandsFreeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HandsFreeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HandsFreeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HandsFreeState value)  $default,){
final _that = this;
switch (_that) {
case _HandsFreeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HandsFreeState value)?  $default,){
final _that = this;
switch (_that) {
case _HandsFreeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  bool listening,  bool speaking,  VoiceCommand? lastCommand,  bool voiceUnavailable,  bool speechUnavailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HandsFreeState() when $default != null:
return $default(_that.enabled,_that.listening,_that.speaking,_that.lastCommand,_that.voiceUnavailable,_that.speechUnavailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  bool listening,  bool speaking,  VoiceCommand? lastCommand,  bool voiceUnavailable,  bool speechUnavailable)  $default,) {final _that = this;
switch (_that) {
case _HandsFreeState():
return $default(_that.enabled,_that.listening,_that.speaking,_that.lastCommand,_that.voiceUnavailable,_that.speechUnavailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  bool listening,  bool speaking,  VoiceCommand? lastCommand,  bool voiceUnavailable,  bool speechUnavailable)?  $default,) {final _that = this;
switch (_that) {
case _HandsFreeState() when $default != null:
return $default(_that.enabled,_that.listening,_that.speaking,_that.lastCommand,_that.voiceUnavailable,_that.speechUnavailable);case _:
  return null;

}
}

}

/// @nodoc


class _HandsFreeState implements HandsFreeState {
  const _HandsFreeState({this.enabled = false, this.listening = false, this.speaking = false, this.lastCommand, this.voiceUnavailable = false, this.speechUnavailable = false});
  

@override@JsonKey() final  bool enabled;
/// The microphone is open for "next", "back" or "repeat".
@override@JsonKey() final  bool listening;
/// A step is being read aloud (listening pauses meanwhile).
@override@JsonKey() final  bool speaking;
/// The last command heard, for a brief on-screen confirmation.
@override final  VoiceCommand? lastCommand;
/// Speech recognition is unavailable or the microphone was denied:
/// steps are still read aloud, navigation stays on the buttons.
@override@JsonKey() final  bool voiceUnavailable;
/// No text-to-speech voice for the tutorial language on this phone.
@override@JsonKey() final  bool speechUnavailable;

/// Create a copy of HandsFreeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandsFreeStateCopyWith<_HandsFreeState> get copyWith => __$HandsFreeStateCopyWithImpl<_HandsFreeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandsFreeState&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.listening, listening) || other.listening == listening)&&(identical(other.speaking, speaking) || other.speaking == speaking)&&(identical(other.lastCommand, lastCommand) || other.lastCommand == lastCommand)&&(identical(other.voiceUnavailable, voiceUnavailable) || other.voiceUnavailable == voiceUnavailable)&&(identical(other.speechUnavailable, speechUnavailable) || other.speechUnavailable == speechUnavailable));
}


@override
int get hashCode => Object.hash(runtimeType,enabled,listening,speaking,lastCommand,voiceUnavailable,speechUnavailable);

@override
String toString() {
  return 'HandsFreeState(enabled: $enabled, listening: $listening, speaking: $speaking, lastCommand: $lastCommand, voiceUnavailable: $voiceUnavailable, speechUnavailable: $speechUnavailable)';
}


}

/// @nodoc
abstract mixin class _$HandsFreeStateCopyWith<$Res> implements $HandsFreeStateCopyWith<$Res> {
  factory _$HandsFreeStateCopyWith(_HandsFreeState value, $Res Function(_HandsFreeState) _then) = __$HandsFreeStateCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, bool listening, bool speaking, VoiceCommand? lastCommand, bool voiceUnavailable, bool speechUnavailable
});




}
/// @nodoc
class __$HandsFreeStateCopyWithImpl<$Res>
    implements _$HandsFreeStateCopyWith<$Res> {
  __$HandsFreeStateCopyWithImpl(this._self, this._then);

  final _HandsFreeState _self;
  final $Res Function(_HandsFreeState) _then;

/// Create a copy of HandsFreeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? listening = null,Object? speaking = null,Object? lastCommand = freezed,Object? voiceUnavailable = null,Object? speechUnavailable = null,}) {
  return _then(_HandsFreeState(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,listening: null == listening ? _self.listening : listening // ignore: cast_nullable_to_non_nullable
as bool,speaking: null == speaking ? _self.speaking : speaking // ignore: cast_nullable_to_non_nullable
as bool,lastCommand: freezed == lastCommand ? _self.lastCommand : lastCommand // ignore: cast_nullable_to_non_nullable
as VoiceCommand?,voiceUnavailable: null == voiceUnavailable ? _self.voiceUnavailable : voiceUnavailable // ignore: cast_nullable_to_non_nullable
as bool,speechUnavailable: null == speechUnavailable ? _self.speechUnavailable : speechUnavailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
