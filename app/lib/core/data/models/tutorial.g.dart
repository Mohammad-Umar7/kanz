// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutorial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TutorialRequest _$TutorialRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TutorialRequest', json, ($checkedConvert) {
      final val = _TutorialRequest(
        imageId: $checkedConvert('image_id', (v) => v as String),
        idea: $checkedConvert(
          'idea',
          (v) => UpcycleIdea.fromJson(v as Map<String, dynamic>),
        ),
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => Item.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        profile: $checkedConvert(
          'profile',
          (v) => v == null
              ? const Profile()
              : Profile.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'imageId': 'image_id'});

Map<String, dynamic> _$TutorialRequestToJson(_TutorialRequest instance) =>
    <String, dynamic>{
      'image_id': instance.imageId,
      'idea': instance.idea.toJson(),
      'items': instance.items.map((e) => e.toJson()).toList(),
      'profile': instance.profile.toJson(),
    };

_TutorialMaterial _$TutorialMaterialFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_TutorialMaterial',
      json,
      ($checkedConvert) {
        final val = _TutorialMaterial(
          name: $checkedConvert('name', (v) => v as String),
          quantity: $checkedConvert('quantity', (v) => v as String?),
          fromScan: $checkedConvert('from_scan', (v) => v as bool),
          itemId: $checkedConvert('item_id', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {'fromScan': 'from_scan', 'itemId': 'item_id'},
    );

Map<String, dynamic> _$TutorialMaterialToJson(_TutorialMaterial instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'from_scan': instance.fromScan,
      'item_id': instance.itemId,
    };

_TutorialTool _$TutorialToolFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TutorialTool', json, ($checkedConvert) {
      final val = _TutorialTool(
        toolId: $checkedConvert(
          'tool_id',
          (v) => $enumDecode(_$ToolIdEnumMap, v),
        ),
        have: $checkedConvert('have', (v) => v as bool),
        alternative: $checkedConvert('alternative', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'toolId': 'tool_id'});

Map<String, dynamic> _$TutorialToolToJson(_TutorialTool instance) =>
    <String, dynamic>{
      'tool_id': _$ToolIdEnumMap[instance.toolId]!,
      'have': instance.have,
      'alternative': instance.alternative,
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

_TutorialStep _$TutorialStepFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_TutorialStep',
      json,
      ($checkedConvert) {
        final val = _TutorialStep(
          number: $checkedConvert('number', (v) => (v as num).toInt()),
          title: $checkedConvert('title', (v) => v as String),
          instruction: $checkedConvert('instruction', (v) => v as String),
          tip: $checkedConvert('tip', (v) => v as String?),
          warning: $checkedConvert('warning', (v) => v as String?),
          durationMinutes: $checkedConvert(
            'duration_minutes',
            (v) => (v as num).toInt(),
          ),
          imagePrompt: $checkedConvert('image_prompt', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'durationMinutes': 'duration_minutes',
        'imagePrompt': 'image_prompt',
      },
    );

Map<String, dynamic> _$TutorialStepToJson(_TutorialStep instance) =>
    <String, dynamic>{
      'number': instance.number,
      'title': instance.title,
      'instruction': instance.instruction,
      'tip': instance.tip,
      'warning': instance.warning,
      'duration_minutes': instance.durationMinutes,
      'image_prompt': instance.imagePrompt,
    };

_Tutorial _$TutorialFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_Tutorial',
  json,
  ($checkedConvert) {
    final val = _Tutorial(
      tutorialId: $checkedConvert('tutorial_id', (v) => v as String),
      ideaId: $checkedConvert('idea_id', (v) => v as String),
      imageId: $checkedConvert('image_id', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String),
      adaptedNote: $checkedConvert('adapted_note', (v) => v as String),
      skill: $checkedConvert(
        'skill',
        (v) => $enumDecode(_$SkillLevelEnumMap, v),
      ),
      totalMinutes: $checkedConvert('total_minutes', (v) => (v as num).toInt()),
      materials: $checkedConvert(
        'materials',
        (v) => (v as List<dynamic>)
            .map((e) => TutorialMaterial.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      tools: $checkedConvert(
        'tools',
        (v) => (v as List<dynamic>)
            .map((e) => TutorialTool.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      safety: $checkedConvert(
        'safety',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      steps: $checkedConvert(
        'steps',
        (v) => (v as List<dynamic>)
            .map((e) => TutorialStep.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      finishing: $checkedConvert(
        'finishing',
        (v) =>
            (v as List<dynamic>?)?.map((e) => e as String).toList() ??
            const <String>[],
      ),
      care: $checkedConvert(
        'care',
        (v) =>
            (v as List<dynamic>?)?.map((e) => e as String).toList() ??
            const <String>[],
      ),
      sources: $checkedConvert(
        'sources',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => SourceRef.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const <SourceRef>[],
      ),
      lang: $checkedConvert('lang', (v) => $enumDecode(_$LangEnumMap, v)),
    );
    return val;
  },
  fieldKeyMap: const {
    'tutorialId': 'tutorial_id',
    'ideaId': 'idea_id',
    'imageId': 'image_id',
    'adaptedNote': 'adapted_note',
    'totalMinutes': 'total_minutes',
  },
);

Map<String, dynamic> _$TutorialToJson(_Tutorial instance) => <String, dynamic>{
  'tutorial_id': instance.tutorialId,
  'idea_id': instance.ideaId,
  'image_id': instance.imageId,
  'title': instance.title,
  'adapted_note': instance.adaptedNote,
  'skill': _$SkillLevelEnumMap[instance.skill]!,
  'total_minutes': instance.totalMinutes,
  'materials': instance.materials.map((e) => e.toJson()).toList(),
  'tools': instance.tools.map((e) => e.toJson()).toList(),
  'safety': instance.safety,
  'steps': instance.steps.map((e) => e.toJson()).toList(),
  'finishing': instance.finishing,
  'care': instance.care,
  'sources': instance.sources.map((e) => e.toJson()).toList(),
  'lang': _$LangEnumMap[instance.lang]!,
};

const _$SkillLevelEnumMap = {
  SkillLevel.beginner: 'beginner',
  SkillLevel.intermediate: 'intermediate',
  SkillLevel.advanced: 'advanced',
};

const _$LangEnumMap = {Lang.en: 'en', Lang.ar: 'ar'};

_TutorialResponse _$TutorialResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TutorialResponse', json, ($checkedConvert) {
      final val = _TutorialResponse(
        tutorial: $checkedConvert(
          'tutorial',
          (v) => Tutorial.fromJson(v as Map<String, dynamic>),
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

Map<String, dynamic> _$TutorialResponseToJson(_TutorialResponse instance) =>
    <String, dynamic>{
      'tutorial': instance.tutorial.toJson(),
      'timings_ms': instance.timingsMs,
    };
