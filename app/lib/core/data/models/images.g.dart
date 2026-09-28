// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'images.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AfterImageRequest _$AfterImageRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AfterImageRequest', json, ($checkedConvert) {
      final val = _AfterImageRequest(
        imageId: $checkedConvert('image_id', (v) => v as String),
        idea: $checkedConvert(
          'idea',
          (v) => UpcycleIdea.fromJson(v as Map<String, dynamic>),
        ),
        regenerate: $checkedConvert('regenerate', (v) => v as bool? ?? false),
      );
      return val;
    }, fieldKeyMap: const {'imageId': 'image_id'});

Map<String, dynamic> _$AfterImageRequestToJson(_AfterImageRequest instance) =>
    <String, dynamic>{
      'image_id': instance.imageId,
      'idea': instance.idea.toJson(),
      'regenerate': instance.regenerate,
    };

_StepImageRequest _$StepImageRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_StepImageRequest',
      json,
      ($checkedConvert) {
        final val = _StepImageRequest(
          imageId: $checkedConvert('image_id', (v) => v as String),
          tutorialId: $checkedConvert('tutorial_id', (v) => v as String),
          step: $checkedConvert('step', (v) => (v as num).toInt()),
          regenerate: $checkedConvert('regenerate', (v) => v as bool? ?? false),
        );
        return val;
      },
      fieldKeyMap: const {'imageId': 'image_id', 'tutorialId': 'tutorial_id'},
    );

Map<String, dynamic> _$StepImageRequestToJson(_StepImageRequest instance) =>
    <String, dynamic>{
      'image_id': instance.imageId,
      'tutorial_id': instance.tutorialId,
      'step': instance.step,
      'regenerate': instance.regenerate,
    };

_BinImageRequest _$BinImageRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_BinImageRequest',
      json,
      ($checkedConvert) {
        final val = _BinImageRequest(
          imageId: $checkedConvert('image_id', (v) => v as String),
          item: $checkedConvert(
            'item',
            (v) => Item.fromJson(v as Map<String, dynamic>),
          ),
          prepSteps: $checkedConvert(
            'prep_steps',
            (v) =>
                (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                const <String>[],
          ),
          regenerate: $checkedConvert('regenerate', (v) => v as bool? ?? false),
        );
        return val;
      },
      fieldKeyMap: const {'imageId': 'image_id', 'prepSteps': 'prep_steps'},
    );

Map<String, dynamic> _$BinImageRequestToJson(_BinImageRequest instance) =>
    <String, dynamic>{
      'image_id': instance.imageId,
      'item': instance.item.toJson(),
      'prep_steps': instance.prepSteps,
      'regenerate': instance.regenerate,
    };

_ReferenceImageRequest _$ReferenceImageRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ReferenceImageRequest', json, ($checkedConvert) {
  final val = _ReferenceImageRequest(
    imageId: $checkedConvert('image_id', (v) => v as String),
  );
  return val;
}, fieldKeyMap: const {'imageId': 'image_id'});

Map<String, dynamic> _$ReferenceImageRequestToJson(
  _ReferenceImageRequest instance,
) => <String, dynamic>{'image_id': instance.imageId};

_ImageResponse _$ImageResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ImageResponse', json, ($checkedConvert) {
      final val = _ImageResponse(
        url: $checkedConvert('url', (v) => v as String),
        width: $checkedConvert('width', (v) => (v as num).toInt()),
        height: $checkedConvert('height', (v) => (v as num).toInt()),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$ImageKindEnumMap, v),
        ),
        key: $checkedConvert('key', (v) => v as String),
        cached: $checkedConvert('cached', (v) => v as bool),
        step: $checkedConvert('step', (v) => (v as num?)?.toInt()),
        skill: $checkedConvert(
          'skill',
          (v) => $enumDecodeNullable(_$SkillLevelEnumMap, v),
        ),
        timingsMs: $checkedConvert(
          'timings_ms',
          (v) =>
              (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const <String, int>{},
        ),
      );
      return val;
    }, fieldKeyMap: const {'timingsMs': 'timings_ms'});

Map<String, dynamic> _$ImageResponseToJson(_ImageResponse instance) =>
    <String, dynamic>{
      'url': instance.url,
      'width': instance.width,
      'height': instance.height,
      'kind': _$ImageKindEnumMap[instance.kind]!,
      'key': instance.key,
      'cached': instance.cached,
      'step': instance.step,
      'skill': _$SkillLevelEnumMap[instance.skill],
      'timings_ms': instance.timingsMs,
    };

const _$ImageKindEnumMap = {
  ImageKind.after: 'after',
  ImageKind.step: 'step',
  ImageKind.bin: 'bin',
  ImageKind.reference: 'reference',
};

const _$SkillLevelEnumMap = {
  SkillLevel.beginner: 'beginner',
  SkillLevel.intermediate: 'intermediate',
  SkillLevel.advanced: 'advanced',
};
