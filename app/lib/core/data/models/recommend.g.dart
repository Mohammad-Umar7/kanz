// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecommendRequest _$RecommendRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_RecommendRequest',
      json,
      ($checkedConvert) {
        final val = _RecommendRequest(
          imageId: $checkedConvert('image_id', (v) => v as String),
          analysis: $checkedConvert(
            'analysis',
            (v) => Analysis.fromJson(v as Map<String, dynamic>),
          ),
          profile: $checkedConvert(
            'profile',
            (v) => v == null
                ? const Profile()
                : Profile.fromJson(v as Map<String, dynamic>),
          ),
          focusItemId: $checkedConvert('focus_item_id', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'imageId': 'image_id',
        'focusItemId': 'focus_item_id',
      },
    );

Map<String, dynamic> _$RecommendRequestToJson(_RecommendRequest instance) =>
    <String, dynamic>{
      'image_id': instance.imageId,
      'analysis': instance.analysis.toJson(),
      'profile': instance.profile.toJson(),
      'focus_item_id': instance.focusItemId,
    };

_UpcycleIdea _$UpcycleIdeaFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_UpcycleIdea',
  json,
  ($checkedConvert) {
    final val = _UpcycleIdea(
      id: $checkedConvert('id', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String),
      pitch: $checkedConvert('pitch', (v) => v as String),
      difficulty: $checkedConvert(
        'difficulty',
        (v) => $enumDecode(_$DifficultyEnumMap, v),
      ),
      timeMinutes: $checkedConvert('time_minutes', (v) => (v as num).toInt()),
      toolsNeeded: $checkedConvert(
        'tools_needed',
        (v) => (v as List<dynamic>)
            .map((e) => $enumDecode(_$ToolIdEnumMap, e))
            .toList(),
      ),
      toolsHave: $checkedConvert(
        'tools_have',
        (v) => (v as List<dynamic>)
            .map((e) => $enumDecode(_$ToolIdEnumMap, e))
            .toList(),
      ),
      toolsMissing: $checkedConvert(
        'tools_missing',
        (v) => (v as List<dynamic>)
            .map((e) => $enumDecode(_$ToolIdEnumMap, e))
            .toList(),
      ),
      usesItemIds: $checkedConvert(
        'uses_item_ids',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      extraMaterials: $checkedConvert(
        'extra_materials',
        (v) =>
            (v as List<dynamic>?)?.map((e) => e as String).toList() ??
            const <String>[],
      ),
      afterVisual: $checkedConvert('after_visual', (v) => v as String),
      safetyNote: $checkedConvert('safety_note', (v) => v as String?),
      sources: $checkedConvert(
        'sources',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => SourceRef.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const <SourceRef>[],
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'timeMinutes': 'time_minutes',
    'toolsNeeded': 'tools_needed',
    'toolsHave': 'tools_have',
    'toolsMissing': 'tools_missing',
    'usesItemIds': 'uses_item_ids',
    'extraMaterials': 'extra_materials',
    'afterVisual': 'after_visual',
    'safetyNote': 'safety_note',
  },
);

Map<String, dynamic> _$UpcycleIdeaToJson(
  _UpcycleIdea instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'pitch': instance.pitch,
  'difficulty': _$DifficultyEnumMap[instance.difficulty]!,
  'time_minutes': instance.timeMinutes,
  'tools_needed': instance.toolsNeeded.map((e) => _$ToolIdEnumMap[e]!).toList(),
  'tools_have': instance.toolsHave.map((e) => _$ToolIdEnumMap[e]!).toList(),
  'tools_missing': instance.toolsMissing
      .map((e) => _$ToolIdEnumMap[e]!)
      .toList(),
  'uses_item_ids': instance.usesItemIds,
  'extra_materials': instance.extraMaterials,
  'after_visual': instance.afterVisual,
  'safety_note': instance.safetyNote,
  'sources': instance.sources.map((e) => e.toJson()).toList(),
};

const _$DifficultyEnumMap = {
  Difficulty.easy: 'easy',
  Difficulty.medium: 'medium',
  Difficulty.hard: 'hard',
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

_RecycleInstruction _$RecycleInstructionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_RecycleInstruction',
      json,
      ($checkedConvert) {
        final val = _RecycleInstruction(
          itemId: $checkedConvert('item_id', (v) => v as String),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$RecyclabilityStatusEnumMap, v),
          ),
          stream: $checkedConvert('stream', (v) => v as String),
          prepSteps: $checkedConvert(
            'prep_steps',
            (v) => (v as List<dynamic>).map((e) => e as String).toList(),
          ),
          dos: $checkedConvert(
            'dos',
            (v) => (v as List<dynamic>).map((e) => e as String).toList(),
          ),
          donts: $checkedConvert(
            'donts',
            (v) => (v as List<dynamic>).map((e) => e as String).toList(),
          ),
          note: $checkedConvert('note', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {'itemId': 'item_id', 'prepSteps': 'prep_steps'},
    );

Map<String, dynamic> _$RecycleInstructionToJson(_RecycleInstruction instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'status': _$RecyclabilityStatusEnumMap[instance.status]!,
      'stream': instance.stream,
      'prep_steps': instance.prepSteps,
      'dos': instance.dos,
      'donts': instance.donts,
      'note': instance.note,
    };

const _$RecyclabilityStatusEnumMap = {
  RecyclabilityStatus.yes: 'yes',
  RecyclabilityStatus.conditional: 'conditional',
  RecyclabilityStatus.no: 'no',
};

_RecyclePath _$RecyclePathFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_RecyclePath',
  json,
  ($checkedConvert) {
    final val = _RecyclePath(
      instructions: $checkedConvert(
        'instructions',
        (v) => (v as List<dynamic>)
            .map((e) => RecycleInstruction.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      sources: $checkedConvert(
        'sources',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => SourceRef.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const <SourceRef>[],
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$RecyclePathToJson(_RecyclePath instance) =>
    <String, dynamic>{
      'instructions': instance.instructions.map((e) => e.toJson()).toList(),
      'sources': instance.sources.map((e) => e.toJson()).toList(),
    };

_DonateOption _$DonateOptionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_DonateOption',
      json,
      ($checkedConvert) {
        final val = _DonateOption(
          itemId: $checkedConvert('item_id', (v) => v as String),
          suitable: $checkedConvert('suitable', (v) => v as bool),
          reason: $checkedConvert('reason', (v) => v as String),
          where: $checkedConvert(
            'where',
            (v) =>
                (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                const <String>[],
          ),
          prepSteps: $checkedConvert(
            'prep_steps',
            (v) =>
                (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                const <String>[],
          ),
        );
        return val;
      },
      fieldKeyMap: const {'itemId': 'item_id', 'prepSteps': 'prep_steps'},
    );

Map<String, dynamic> _$DonateOptionToJson(_DonateOption instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'suitable': instance.suitable,
      'reason': instance.reason,
      'where': instance.where,
      'prep_steps': instance.prepSteps,
    };

_DonatePath _$DonatePathFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_DonatePath', json, ($checkedConvert) {
      final val = _DonatePath(
        available: $checkedConvert('available', (v) => v as bool),
        summary: $checkedConvert('summary', (v) => v as String),
        options: $checkedConvert(
          'options',
          (v) => (v as List<dynamic>)
              .map((e) => DonateOption.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DonatePathToJson(_DonatePath instance) =>
    <String, dynamic>{
      'available': instance.available,
      'summary': instance.summary,
      'options': instance.options.map((e) => e.toJson()).toList(),
    };

_DisposalGuidance _$DisposalGuidanceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_DisposalGuidance', json, ($checkedConvert) {
      final val = _DisposalGuidance(
        itemId: $checkedConvert('item_id', (v) => v as String),
        hazard: $checkedConvert(
          'hazard',
          (v) => $enumDecode(_$HazardFlagEnumMap, v),
        ),
        headline: $checkedConvert('headline', (v) => v as String),
        steps: $checkedConvert(
          'steps',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        never: $checkedConvert(
          'never',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'itemId': 'item_id'});

Map<String, dynamic> _$DisposalGuidanceToJson(_DisposalGuidance instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'hazard': _$HazardFlagEnumMap[instance.hazard]!,
      'headline': instance.headline,
      'steps': instance.steps,
      'never': instance.never,
    };

const _$HazardFlagEnumMap = {
  HazardFlag.battery: 'battery',
  HazardFlag.eWaste: 'e_waste',
  HazardFlag.chemical: 'chemical',
  HazardFlag.aerosol: 'aerosol',
  HazardFlag.medicine: 'medicine',
  HazardFlag.lightBulb: 'light_bulb',
  HazardFlag.brokenGlass: 'broken_glass',
  HazardFlag.sharpEdges: 'sharp_edges',
  HazardFlag.mold: 'mold',
};

_FacilityCategory _$FacilityCategoryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_FacilityCategory',
      json,
      ($checkedConvert) {
        final val = _FacilityCategory(
          key: $checkedConvert('key', (v) => v as String),
          label: $checkedConvert('label', (v) => v as String),
          facilityTypes: $checkedConvert(
            'facility_types',
            (v) => (v as List<dynamic>)
                .map((e) => $enumDecode(_$FacilityTypeEnumMap, e))
                .toList(),
          ),
          materialCategories: $checkedConvert(
            'material_categories',
            (v) => (v as List<dynamic>)
                .map((e) => $enumDecode(_$MaterialCategoryEnumMap, e))
                .toList(),
          ),
          itemIds: $checkedConvert(
            'item_ids',
            (v) =>
                (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                const <String>[],
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'facilityTypes': 'facility_types',
        'materialCategories': 'material_categories',
        'itemIds': 'item_ids',
      },
    );

Map<String, dynamic> _$FacilityCategoryToJson(_FacilityCategory instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'facility_types': instance.facilityTypes
          .map((e) => _$FacilityTypeEnumMap[e]!)
          .toList(),
      'material_categories': instance.materialCategories
          .map((e) => _$MaterialCategoryEnumMap[e]!)
          .toList(),
      'item_ids': instance.itemIds,
    };

const _$FacilityTypeEnumMap = {
  FacilityType.recyclingCenter: 'recycling_center',
  FacilityType.collectionPoint: 'collection_point',
  FacilityType.donation: 'donation',
  FacilityType.eWaste: 'e_waste',
  FacilityType.hazardousWaste: 'hazardous_waste',
  FacilityType.scrapMetal: 'scrap_metal',
  FacilityType.woodCollection: 'wood_collection',
};

const _$MaterialCategoryEnumMap = {
  MaterialCategory.glass: 'glass',
  MaterialCategory.plastic: 'plastic',
  MaterialCategory.paper: 'paper',
  MaterialCategory.metal: 'metal',
  MaterialCategory.textile: 'textile',
  MaterialCategory.wood: 'wood',
  MaterialCategory.electronics: 'electronics',
  MaterialCategory.hazardous: 'hazardous',
  MaterialCategory.organic: 'organic',
  MaterialCategory.other: 'other',
};

_Routing _$RoutingFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Routing', json, ($checkedConvert) {
      final val = _Routing(
        mode: $checkedConvert(
          'mode',
          (v) => $enumDecode(_$RoutingModeEnumMap, v),
        ),
        hazardousItemIds: $checkedConvert(
          'hazardous_item_ids',
          (v) =>
              (v as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
        ),
        reason: $checkedConvert('reason', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'hazardousItemIds': 'hazardous_item_ids'});

Map<String, dynamic> _$RoutingToJson(_Routing instance) => <String, dynamic>{
  'mode': _$RoutingModeEnumMap[instance.mode]!,
  'hazardous_item_ids': instance.hazardousItemIds,
  'reason': instance.reason,
};

const _$RoutingModeEnumMap = {
  RoutingMode.diy: 'diy',
  RoutingMode.mixed: 'mixed',
  RoutingMode.disposalOnly: 'disposal_only',
};

_RecommendResponse _$RecommendResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_RecommendResponse',
      json,
      ($checkedConvert) {
        final val = _RecommendResponse(
          routing: $checkedConvert(
            'routing',
            (v) => Routing.fromJson(v as Map<String, dynamic>),
          ),
          upcycle: $checkedConvert(
            'upcycle',
            (v) => (v as List<dynamic>)
                .map((e) => UpcycleIdea.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          recycle: $checkedConvert(
            'recycle',
            (v) => RecyclePath.fromJson(v as Map<String, dynamic>),
          ),
          donate: $checkedConvert(
            'donate',
            (v) => DonatePath.fromJson(v as Map<String, dynamic>),
          ),
          disposal: $checkedConvert(
            'disposal',
            (v) =>
                (v as List<dynamic>?)
                    ?.map(
                      (e) =>
                          DisposalGuidance.fromJson(e as Map<String, dynamic>),
                    )
                    .toList() ??
                const <DisposalGuidance>[],
          ),
          facilityCategories: $checkedConvert(
            'facility_categories',
            (v) => (v as List<dynamic>)
                .map(
                  (e) => FacilityCategory.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          ),
          lang: $checkedConvert('lang', (v) => $enumDecode(_$LangEnumMap, v)),
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
      },
      fieldKeyMap: const {
        'facilityCategories': 'facility_categories',
        'timingsMs': 'timings_ms',
      },
    );

Map<String, dynamic> _$RecommendResponseToJson(_RecommendResponse instance) =>
    <String, dynamic>{
      'routing': instance.routing.toJson(),
      'upcycle': instance.upcycle.map((e) => e.toJson()).toList(),
      'recycle': instance.recycle.toJson(),
      'donate': instance.donate.toJson(),
      'disposal': instance.disposal.map((e) => e.toJson()).toList(),
      'facility_categories': instance.facilityCategories
          .map((e) => e.toJson())
          .toList(),
      'lang': _$LangEnumMap[instance.lang]!,
      'timings_ms': instance.timingsMs,
    };

const _$LangEnumMap = {Lang.en: 'en', Lang.ar: 'ar'};
