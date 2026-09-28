// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutorial_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TutorialState implements DiagnosticableTreeMixin {

 TutorialPhase get phase; ApiException? get error; ProjectRecord? get project; UpcycleIdea? get idea; Tutorial? get tutorial;/// Skill and tools the current tutorial was written for.
 SkillLevel get skill; List<ToolId> get tools;/// True while `adapt()` fetches a tutorial for a new skill or tool set; the
/// previous tutorial stays on screen until the new one arrives.
 bool get adapting; ApiException? get adaptError;/// Step number (1-based) -> step image.
 Map<int, GeneratedImageState> get stepImages;/// 1-based step on screen.
 int get currentStep; Set<int> get completedSteps; bool get completed;
/// Create a copy of TutorialState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TutorialStateCopyWith<TutorialState> get copyWith => _$TutorialStateCopyWithImpl<TutorialState>(this as TutorialState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'TutorialState'))
    ..add(DiagnosticsProperty('phase', phase))..add(DiagnosticsProperty('error', error))..add(DiagnosticsProperty('project', project))..add(DiagnosticsProperty('idea', idea))..add(DiagnosticsProperty('tutorial', tutorial))..add(DiagnosticsProperty('skill', skill))..add(DiagnosticsProperty('tools', tools))..add(DiagnosticsProperty('adapting', adapting))..add(DiagnosticsProperty('adaptError', adaptError))..add(DiagnosticsProperty('stepImages', stepImages))..add(DiagnosticsProperty('currentStep', currentStep))..add(DiagnosticsProperty('completedSteps', completedSteps))..add(DiagnosticsProperty('completed', completed));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorialState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.error, error) || other.error == error)&&(identical(other.project, project) || other.project == project)&&(identical(other.idea, idea) || other.idea == idea)&&(identical(other.tutorial, tutorial) || other.tutorial == tutorial)&&(identical(other.skill, skill) || other.skill == skill)&&const DeepCollectionEquality().equals(other.tools, tools)&&(identical(other.adapting, adapting) || other.adapting == adapting)&&(identical(other.adaptError, adaptError) || other.adaptError == adaptError)&&const DeepCollectionEquality().equals(other.stepImages, stepImages)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&const DeepCollectionEquality().equals(other.completedSteps, completedSteps)&&(identical(other.completed, completed) || other.completed == completed));
}


@override
int get hashCode => Object.hash(runtimeType,phase,error,project,idea,tutorial,skill,const DeepCollectionEquality().hash(tools),adapting,adaptError,const DeepCollectionEquality().hash(stepImages),currentStep,const DeepCollectionEquality().hash(completedSteps),completed);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'TutorialState(phase: $phase, error: $error, project: $project, idea: $idea, tutorial: $tutorial, skill: $skill, tools: $tools, adapting: $adapting, adaptError: $adaptError, stepImages: $stepImages, currentStep: $currentStep, completedSteps: $completedSteps, completed: $completed)';
}


}

/// @nodoc
abstract mixin class $TutorialStateCopyWith<$Res>  {
  factory $TutorialStateCopyWith(TutorialState value, $Res Function(TutorialState) _then) = _$TutorialStateCopyWithImpl;
@useResult
$Res call({
 TutorialPhase phase, ApiException? error, ProjectRecord? project, UpcycleIdea? idea, Tutorial? tutorial, SkillLevel skill, List<ToolId> tools, bool adapting, ApiException? adaptError, Map<int, GeneratedImageState> stepImages, int currentStep, Set<int> completedSteps, bool completed
});


$UpcycleIdeaCopyWith<$Res>? get idea;$TutorialCopyWith<$Res>? get tutorial;

}
/// @nodoc
class _$TutorialStateCopyWithImpl<$Res>
    implements $TutorialStateCopyWith<$Res> {
  _$TutorialStateCopyWithImpl(this._self, this._then);

  final TutorialState _self;
  final $Res Function(TutorialState) _then;

/// Create a copy of TutorialState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? error = freezed,Object? project = freezed,Object? idea = freezed,Object? tutorial = freezed,Object? skill = null,Object? tools = null,Object? adapting = null,Object? adaptError = freezed,Object? stepImages = null,Object? currentStep = null,Object? completedSteps = null,Object? completed = null,}) {
  return _then(_self.copyWith(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as TutorialPhase,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiException?,project: freezed == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as ProjectRecord?,idea: freezed == idea ? _self.idea : idea // ignore: cast_nullable_to_non_nullable
as UpcycleIdea?,tutorial: freezed == tutorial ? _self.tutorial : tutorial // ignore: cast_nullable_to_non_nullable
as Tutorial?,skill: null == skill ? _self.skill : skill // ignore: cast_nullable_to_non_nullable
as SkillLevel,tools: null == tools ? _self.tools : tools // ignore: cast_nullable_to_non_nullable
as List<ToolId>,adapting: null == adapting ? _self.adapting : adapting // ignore: cast_nullable_to_non_nullable
as bool,adaptError: freezed == adaptError ? _self.adaptError : adaptError // ignore: cast_nullable_to_non_nullable
as ApiException?,stepImages: null == stepImages ? _self.stepImages : stepImages // ignore: cast_nullable_to_non_nullable
as Map<int, GeneratedImageState>,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,completedSteps: null == completedSteps ? _self.completedSteps : completedSteps // ignore: cast_nullable_to_non_nullable
as Set<int>,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of TutorialState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpcycleIdeaCopyWith<$Res>? get idea {
    if (_self.idea == null) {
    return null;
  }

  return $UpcycleIdeaCopyWith<$Res>(_self.idea!, (value) {
    return _then(_self.copyWith(idea: value));
  });
}/// Create a copy of TutorialState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TutorialCopyWith<$Res>? get tutorial {
    if (_self.tutorial == null) {
    return null;
  }

  return $TutorialCopyWith<$Res>(_self.tutorial!, (value) {
    return _then(_self.copyWith(tutorial: value));
  });
}
}


/// Adds pattern-matching-related methods to [TutorialState].
extension TutorialStatePatterns on TutorialState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TutorialState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TutorialState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TutorialState value)  $default,){
final _that = this;
switch (_that) {
case _TutorialState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TutorialState value)?  $default,){
final _that = this;
switch (_that) {
case _TutorialState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TutorialPhase phase,  ApiException? error,  ProjectRecord? project,  UpcycleIdea? idea,  Tutorial? tutorial,  SkillLevel skill,  List<ToolId> tools,  bool adapting,  ApiException? adaptError,  Map<int, GeneratedImageState> stepImages,  int currentStep,  Set<int> completedSteps,  bool completed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TutorialState() when $default != null:
return $default(_that.phase,_that.error,_that.project,_that.idea,_that.tutorial,_that.skill,_that.tools,_that.adapting,_that.adaptError,_that.stepImages,_that.currentStep,_that.completedSteps,_that.completed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TutorialPhase phase,  ApiException? error,  ProjectRecord? project,  UpcycleIdea? idea,  Tutorial? tutorial,  SkillLevel skill,  List<ToolId> tools,  bool adapting,  ApiException? adaptError,  Map<int, GeneratedImageState> stepImages,  int currentStep,  Set<int> completedSteps,  bool completed)  $default,) {final _that = this;
switch (_that) {
case _TutorialState():
return $default(_that.phase,_that.error,_that.project,_that.idea,_that.tutorial,_that.skill,_that.tools,_that.adapting,_that.adaptError,_that.stepImages,_that.currentStep,_that.completedSteps,_that.completed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TutorialPhase phase,  ApiException? error,  ProjectRecord? project,  UpcycleIdea? idea,  Tutorial? tutorial,  SkillLevel skill,  List<ToolId> tools,  bool adapting,  ApiException? adaptError,  Map<int, GeneratedImageState> stepImages,  int currentStep,  Set<int> completedSteps,  bool completed)?  $default,) {final _that = this;
switch (_that) {
case _TutorialState() when $default != null:
return $default(_that.phase,_that.error,_that.project,_that.idea,_that.tutorial,_that.skill,_that.tools,_that.adapting,_that.adaptError,_that.stepImages,_that.currentStep,_that.completedSteps,_that.completed);case _:
  return null;

}
}

}

/// @nodoc


class _TutorialState extends TutorialState with DiagnosticableTreeMixin {
  const _TutorialState({this.phase = TutorialPhase.loading, this.error, this.project, this.idea, this.tutorial, this.skill = SkillLevel.beginner, final  List<ToolId> tools = const <ToolId>[], this.adapting = false, this.adaptError, final  Map<int, GeneratedImageState> stepImages = const <int, GeneratedImageState>{}, this.currentStep = 1, final  Set<int> completedSteps = const <int>{}, this.completed = false}): _tools = tools,_stepImages = stepImages,_completedSteps = completedSteps,super._();
  

@override@JsonKey() final  TutorialPhase phase;
@override final  ApiException? error;
@override final  ProjectRecord? project;
@override final  UpcycleIdea? idea;
@override final  Tutorial? tutorial;
/// Skill and tools the current tutorial was written for.
@override@JsonKey() final  SkillLevel skill;
 final  List<ToolId> _tools;
@override@JsonKey() List<ToolId> get tools {
  if (_tools is EqualUnmodifiableListView) return _tools;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tools);
}

/// True while `adapt()` fetches a tutorial for a new skill or tool set; the
/// previous tutorial stays on screen until the new one arrives.
@override@JsonKey() final  bool adapting;
@override final  ApiException? adaptError;
/// Step number (1-based) -> step image.
 final  Map<int, GeneratedImageState> _stepImages;
/// Step number (1-based) -> step image.
@override@JsonKey() Map<int, GeneratedImageState> get stepImages {
  if (_stepImages is EqualUnmodifiableMapView) return _stepImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stepImages);
}

/// 1-based step on screen.
@override@JsonKey() final  int currentStep;
 final  Set<int> _completedSteps;
@override@JsonKey() Set<int> get completedSteps {
  if (_completedSteps is EqualUnmodifiableSetView) return _completedSteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_completedSteps);
}

@override@JsonKey() final  bool completed;

/// Create a copy of TutorialState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TutorialStateCopyWith<_TutorialState> get copyWith => __$TutorialStateCopyWithImpl<_TutorialState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'TutorialState'))
    ..add(DiagnosticsProperty('phase', phase))..add(DiagnosticsProperty('error', error))..add(DiagnosticsProperty('project', project))..add(DiagnosticsProperty('idea', idea))..add(DiagnosticsProperty('tutorial', tutorial))..add(DiagnosticsProperty('skill', skill))..add(DiagnosticsProperty('tools', tools))..add(DiagnosticsProperty('adapting', adapting))..add(DiagnosticsProperty('adaptError', adaptError))..add(DiagnosticsProperty('stepImages', stepImages))..add(DiagnosticsProperty('currentStep', currentStep))..add(DiagnosticsProperty('completedSteps', completedSteps))..add(DiagnosticsProperty('completed', completed));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TutorialState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.error, error) || other.error == error)&&(identical(other.project, project) || other.project == project)&&(identical(other.idea, idea) || other.idea == idea)&&(identical(other.tutorial, tutorial) || other.tutorial == tutorial)&&(identical(other.skill, skill) || other.skill == skill)&&const DeepCollectionEquality().equals(other._tools, _tools)&&(identical(other.adapting, adapting) || other.adapting == adapting)&&(identical(other.adaptError, adaptError) || other.adaptError == adaptError)&&const DeepCollectionEquality().equals(other._stepImages, _stepImages)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&const DeepCollectionEquality().equals(other._completedSteps, _completedSteps)&&(identical(other.completed, completed) || other.completed == completed));
}


@override
int get hashCode => Object.hash(runtimeType,phase,error,project,idea,tutorial,skill,const DeepCollectionEquality().hash(_tools),adapting,adaptError,const DeepCollectionEquality().hash(_stepImages),currentStep,const DeepCollectionEquality().hash(_completedSteps),completed);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'TutorialState(phase: $phase, error: $error, project: $project, idea: $idea, tutorial: $tutorial, skill: $skill, tools: $tools, adapting: $adapting, adaptError: $adaptError, stepImages: $stepImages, currentStep: $currentStep, completedSteps: $completedSteps, completed: $completed)';
}


}

/// @nodoc
abstract mixin class _$TutorialStateCopyWith<$Res> implements $TutorialStateCopyWith<$Res> {
  factory _$TutorialStateCopyWith(_TutorialState value, $Res Function(_TutorialState) _then) = __$TutorialStateCopyWithImpl;
@override @useResult
$Res call({
 TutorialPhase phase, ApiException? error, ProjectRecord? project, UpcycleIdea? idea, Tutorial? tutorial, SkillLevel skill, List<ToolId> tools, bool adapting, ApiException? adaptError, Map<int, GeneratedImageState> stepImages, int currentStep, Set<int> completedSteps, bool completed
});


@override $UpcycleIdeaCopyWith<$Res>? get idea;@override $TutorialCopyWith<$Res>? get tutorial;

}
/// @nodoc
class __$TutorialStateCopyWithImpl<$Res>
    implements _$TutorialStateCopyWith<$Res> {
  __$TutorialStateCopyWithImpl(this._self, this._then);

  final _TutorialState _self;
  final $Res Function(_TutorialState) _then;

/// Create a copy of TutorialState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? error = freezed,Object? project = freezed,Object? idea = freezed,Object? tutorial = freezed,Object? skill = null,Object? tools = null,Object? adapting = null,Object? adaptError = freezed,Object? stepImages = null,Object? currentStep = null,Object? completedSteps = null,Object? completed = null,}) {
  return _then(_TutorialState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as TutorialPhase,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiException?,project: freezed == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as ProjectRecord?,idea: freezed == idea ? _self.idea : idea // ignore: cast_nullable_to_non_nullable
as UpcycleIdea?,tutorial: freezed == tutorial ? _self.tutorial : tutorial // ignore: cast_nullable_to_non_nullable
as Tutorial?,skill: null == skill ? _self.skill : skill // ignore: cast_nullable_to_non_nullable
as SkillLevel,tools: null == tools ? _self._tools : tools // ignore: cast_nullable_to_non_nullable
as List<ToolId>,adapting: null == adapting ? _self.adapting : adapting // ignore: cast_nullable_to_non_nullable
as bool,adaptError: freezed == adaptError ? _self.adaptError : adaptError // ignore: cast_nullable_to_non_nullable
as ApiException?,stepImages: null == stepImages ? _self._stepImages : stepImages // ignore: cast_nullable_to_non_nullable
as Map<int, GeneratedImageState>,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,completedSteps: null == completedSteps ? _self._completedSteps : completedSteps // ignore: cast_nullable_to_non_nullable
as Set<int>,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of TutorialState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpcycleIdeaCopyWith<$Res>? get idea {
    if (_self.idea == null) {
    return null;
  }

  return $UpcycleIdeaCopyWith<$Res>(_self.idea!, (value) {
    return _then(_self.copyWith(idea: value));
  });
}/// Create a copy of TutorialState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TutorialCopyWith<$Res>? get tutorial {
    if (_self.tutorial == null) {
    return null;
  }

  return $TutorialCopyWith<$Res>(_self.tutorial!, (value) {
    return _then(_self.copyWith(tutorial: value));
  });
}
}

// dart format on
