// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_Profile',
  json,
  ($checkedConvert) {
    final val = _Profile(
      skill: $checkedConvert(
        'skill',
        (v) =>
            $enumDecodeNullable(_$SkillLevelEnumMap, v) ?? SkillLevel.beginner,
      ),
      tools: $checkedConvert(
        'tools',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => $enumDecode(_$ToolIdEnumMap, e))
                .toList() ??
            const <ToolId>[],
      ),
      lang: $checkedConvert(
        'lang',
        (v) => $enumDecodeNullable(_$LangEnumMap, v) ?? Lang.en,
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'skill': _$SkillLevelEnumMap[instance.skill]!,
  'tools': instance.tools.map((e) => _$ToolIdEnumMap[e]!).toList(),
  'lang': _$LangEnumMap[instance.lang]!,
};

const _$SkillLevelEnumMap = {
  SkillLevel.beginner: 'beginner',
  SkillLevel.intermediate: 'intermediate',
  SkillLevel.advanced: 'advanced',
};

const _$ToolIdEnumMap = {
  ToolId.scissors: 'scissors',
  ToolId.craftKnife: 'craft_knife',
  ToolId.hotGlueGun: 'hot_glue_gun',
  ToolId.strongGlue: 'strong_glue',
  ToolId.woodGlue: 'wood_glue',
  ToolId.sandpaper: 'sandpaper',
  ToolId.paintbrush: 'paintbrush',
  ToolId.acrylicPaint: 'acrylic_paint',
  ToolId.sprayPaint: 'spray_paint',
  ToolId.varnish: 'varnish',
  ToolId.drill: 'drill',
  ToolId.screwdriver: 'screwdriver',
  ToolId.hammer: 'hammer',
  ToolId.handsaw: 'handsaw',
  ToolId.pliers: 'pliers',
  ToolId.wireCutter: 'wire_cutter',
  ToolId.measuringTape: 'measuring_tape',
  ToolId.rulerPencil: 'ruler_pencil',
  ToolId.sewingKit: 'sewing_kit',
  ToolId.sewingMachine: 'sewing_machine',
  ToolId.iron: 'iron',
  ToolId.twine: 'twine',
  ToolId.craftWire: 'craft_wire',
  ToolId.maskingTape: 'masking_tape',
  ToolId.clamps: 'clamps',
  ToolId.stapleGun: 'staple_gun',
  ToolId.gloves: 'gloves',
  ToolId.safetyGlasses: 'safety_glasses',
  ToolId.dustMask: 'dust_mask',
};

const _$LangEnumMap = {Lang.en: 'en', Lang.ar: 'ar'};

_SourceRef _$SourceRefFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_SourceRef',
  json,
  ($checkedConvert) {
    final val = _SourceRef(
      id: $checkedConvert('id', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String),
      kind: $checkedConvert('kind', (v) => $enumDecode(_$SourceKindEnumMap, v)),
    );
    return val;
  },
);

Map<String, dynamic> _$SourceRefToJson(_SourceRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'kind': _$SourceKindEnumMap[instance.kind]!,
    };

const _$SourceKindEnumMap = {
  SourceKind.project: 'project',
  SourceKind.materialGuide: 'material_guide',
  SourceKind.safety: 'safety',
  SourceKind.swap: 'swap',
};

_GeoPoint _$GeoPointFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_GeoPoint', json, ($checkedConvert) {
      final val = _GeoPoint(
        lat: $checkedConvert('lat', (v) => (v as num).toDouble()),
        lng: $checkedConvert('lng', (v) => (v as num).toDouble()),
      );
      return val;
    });

Map<String, dynamic> _$GeoPointToJson(_GeoPoint instance) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
};

_ErrorBody _$ErrorBodyFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_ErrorBody',
  json,
  ($checkedConvert) {
    final val = _ErrorBody(
      code: $checkedConvert('code', (v) => $enumDecode(_$ErrorCodeEnumMap, v)),
      message: $checkedConvert('message', (v) => v as String),
      retryable: $checkedConvert('retryable', (v) => v as bool),
      requestId: $checkedConvert('request_id', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {'requestId': 'request_id'},
);

Map<String, dynamic> _$ErrorBodyToJson(_ErrorBody instance) =>
    <String, dynamic>{
      'code': _$ErrorCodeEnumMap[instance.code]!,
      'message': instance.message,
      'retryable': instance.retryable,
      'request_id': instance.requestId,
    };

const _$ErrorCodeEnumMap = {
  ErrorCode.badRequest: 'bad_request',
  ErrorCode.imageInvalid: 'image_invalid',
  ErrorCode.imageTooLarge: 'image_too_large',
  ErrorCode.notFound: 'not_found',
  ErrorCode.rateLimited: 'rate_limited',
  ErrorCode.aiUnavailable: 'ai_unavailable',
  ErrorCode.aiTimeout: 'ai_timeout',
  ErrorCode.aiInvalidOutput: 'ai_invalid_output',
  ErrorCode.aiQuotaExhausted: 'ai_quota_exhausted',
  ErrorCode.placesUnavailable: 'places_unavailable',
  ErrorCode.internal: 'internal',
};

_ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ErrorResponse', json, ($checkedConvert) {
      final val = _ErrorResponse(
        error: $checkedConvert(
          'error',
          (v) => ErrorBody.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ErrorResponseToJson(_ErrorResponse instance) =>
    <String, dynamic>{'error': instance.error.toJson()};
