// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BBox _$BBoxFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_BBox', json, ($checkedConvert) {
      final val = _BBox(
        x: $checkedConvert('x', (v) => (v as num).toDouble()),
        y: $checkedConvert('y', (v) => (v as num).toDouble()),
        w: $checkedConvert('w', (v) => (v as num).toDouble()),
        h: $checkedConvert('h', (v) => (v as num).toDouble()),
      );
      return val;
    });

Map<String, dynamic> _$BBoxToJson(_BBox instance) => <String, dynamic>{
  'x': instance.x,
  'y': instance.y,
  'w': instance.w,
  'h': instance.h,
};

_Quantity _$QuantityFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Quantity', json, ($checkedConvert) {
      final val = _Quantity(
        value: $checkedConvert('value', (v) => (v as num).toDouble()),
        unit: $checkedConvert('unit', (v) => v as String),
        isEstimate: $checkedConvert('is_estimate', (v) => v as bool),
        display: $checkedConvert('display', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'isEstimate': 'is_estimate'});

Map<String, dynamic> _$QuantityToJson(_Quantity instance) => <String, dynamic>{
  'value': instance.value,
  'unit': instance.unit,
  'is_estimate': instance.isEstimate,
  'display': instance.display,
};

_Quality _$QualityFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Quality', json, ($checkedConvert) {
      final val = _Quality(
        score: $checkedConvert('score', (v) => (v as num).toInt()),
        label: $checkedConvert('label', (v) => v as String),
        notes: $checkedConvert('notes', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$QualityToJson(_Quality instance) => <String, dynamic>{
  'score': instance.score,
  'label': instance.label,
  'notes': instance.notes,
};

_Recyclability _$RecyclabilityFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Recyclability', json, ($checkedConvert) {
      final val = _Recyclability(
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$RecyclabilityStatusEnumMap, v),
        ),
        stream: $checkedConvert('stream', (v) => v as String),
        prepSteps: $checkedConvert(
          'prep_steps',
          (v) =>
              (v as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
        ),
        reason: $checkedConvert('reason', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'prepSteps': 'prep_steps'});

Map<String, dynamic> _$RecyclabilityToJson(_Recyclability instance) =>
    <String, dynamic>{
      'status': _$RecyclabilityStatusEnumMap[instance.status]!,
      'stream': instance.stream,
      'prep_steps': instance.prepSteps,
      'reason': instance.reason,
    };

const _$RecyclabilityStatusEnumMap = {
  RecyclabilityStatus.yes: 'yes',
  RecyclabilityStatus.conditional: 'conditional',
  RecyclabilityStatus.no: 'no',
};

_ReusePotential _$ReusePotentialFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ReusePotential', json, ($checkedConvert) {
      final val = _ReusePotential(
        level: $checkedConvert('level', (v) => $enumDecode(_$LevelEnumMap, v)),
        note: $checkedConvert('note', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ReusePotentialToJson(_ReusePotential instance) =>
    <String, dynamic>{
      'level': _$LevelEnumMap[instance.level]!,
      'note': instance.note,
    };

const _$LevelEnumMap = {
  Level.low: 'low',
  Level.medium: 'medium',
  Level.high: 'high',
};

_Item _$ItemFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_Item',
  json,
  ($checkedConvert) {
    final val = _Item(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      category: $checkedConvert(
        'category',
        (v) => $enumDecode(_$MaterialCategoryEnumMap, v),
      ),
      material: $checkedConvert('material', (v) => v as String),
      resinCode: $checkedConvert('resin_code', (v) => (v as num?)?.toInt()),
      isRawMaterial: $checkedConvert(
        'is_raw_material',
        (v) => v as bool? ?? false,
      ),
      quantity: $checkedConvert(
        'quantity',
        (v) => Quantity.fromJson(v as Map<String, dynamic>),
      ),
      quality: $checkedConvert(
        'quality',
        (v) => Quality.fromJson(v as Map<String, dynamic>),
      ),
      state: $checkedConvert(
        'state',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => $enumDecode(_$StateTagEnumMap, e))
                .toList() ??
            const <StateTag>[],
      ),
      recyclability: $checkedConvert(
        'recyclability',
        (v) => Recyclability.fromJson(v as Map<String, dynamic>),
      ),
      reuse: $checkedConvert(
        'reuse',
        (v) => ReusePotential.fromJson(v as Map<String, dynamic>),
      ),
      hazards: $checkedConvert(
        'hazards',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => $enumDecode(_$HazardFlagEnumMap, e))
                .toList() ??
            const <HazardFlag>[],
      ),
      confidence: $checkedConvert('confidence', (v) => (v as num).toDouble()),
      bbox: $checkedConvert(
        'bbox',
        (v) => v == null ? null : BBox.fromJson(v as Map<String, dynamic>),
      ),
      userCorrected: $checkedConvert(
        'user_corrected',
        (v) => v as bool? ?? false,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'resinCode': 'resin_code',
    'isRawMaterial': 'is_raw_material',
    'userCorrected': 'user_corrected',
  },
);

Map<String, dynamic> _$ItemToJson(_Item instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': _$MaterialCategoryEnumMap[instance.category]!,
  'material': instance.material,
  'resin_code': instance.resinCode,
  'is_raw_material': instance.isRawMaterial,
  'quantity': instance.quantity.toJson(),
  'quality': instance.quality.toJson(),
  'state': instance.state.map((e) => _$StateTagEnumMap[e]!).toList(),
  'recyclability': instance.recyclability.toJson(),
  'reuse': instance.reuse.toJson(),
  'hazards': instance.hazards.map((e) => _$HazardFlagEnumMap[e]!).toList(),
  'confidence': instance.confidence,
  'bbox': instance.bbox?.toJson(),
  'user_corrected': instance.userCorrected,
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

const _$StateTagEnumMap = {
  StateTag.clean: 'clean',
  StateTag.dirty: 'dirty',
  StateTag.greasy: 'greasy',
  StateTag.containsResidue: 'contains_residue',
  StateTag.empty: 'empty',
  StateTag.wet: 'wet',
  StateTag.intact: 'intact',
  StateTag.cracked: 'cracked',
  StateTag.chipped: 'chipped',
  StateTag.broken: 'broken',
  StateTag.torn: 'torn',
  StateTag.stained: 'stained',
  StateTag.faded: 'faded',
  StateTag.worn: 'worn',
  StateTag.rusted: 'rusted',
  StateTag.dented: 'dented',
  StateTag.bent: 'bent',
  StateTag.moldy: 'moldy',
  StateTag.missingParts: 'missing_parts',
  StateTag.labelOn: 'label_on',
  StateTag.labelOff: 'label_off',
  StateTag.lidOn: 'lid_on',
  StateTag.lidOff: 'lid_off',
  StateTag.capOn: 'cap_on',
  StateTag.capOff: 'cap_off',
  StateTag.flattened: 'flattened',
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

_PhotoCheck _$PhotoCheckFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_PhotoCheck', json, ($checkedConvert) {
      final val = _PhotoCheck(
        usable: $checkedConvert('usable', (v) => v as bool),
        issue: $checkedConvert(
          'issue',
          (v) => $enumDecodeNullable(_$PhotoIssueEnumMap, v) ?? PhotoIssue.ok,
        ),
        retakeTip: $checkedConvert('retake_tip', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'retakeTip': 'retake_tip'});

Map<String, dynamic> _$PhotoCheckToJson(_PhotoCheck instance) =>
    <String, dynamic>{
      'usable': instance.usable,
      'issue': _$PhotoIssueEnumMap[instance.issue]!,
      'retake_tip': instance.retakeTip,
    };

const _$PhotoIssueEnumMap = {
  PhotoIssue.ok: 'ok',
  PhotoIssue.blurry: 'blurry',
  PhotoIssue.tooDark: 'too_dark',
  PhotoIssue.tooFar: 'too_far',
  PhotoIssue.tooClose: 'too_close',
  PhotoIssue.cluttered: 'cluttered',
  PhotoIssue.noItems: 'no_items',
  PhotoIssue.glare: 'glare',
};

_Analysis _$AnalysisFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_Analysis',
  json,
  ($checkedConvert) {
    final val = _Analysis(
      items: $checkedConvert(
        'items',
        (v) => (v as List<dynamic>)
            .map((e) => Item.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      summary: $checkedConvert('summary', (v) => v as String),
      photo: $checkedConvert(
        'photo',
        (v) => PhotoCheck.fromJson(v as Map<String, dynamic>),
      ),
      primaryItemId: $checkedConvert('primary_item_id', (v) => v as String?),
      source: $checkedConvert(
        'source',
        (v) => $enumDecode(_$AnalysisSourceEnumMap, v),
      ),
      classifierHint: $checkedConvert('classifier_hint', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'primaryItemId': 'primary_item_id',
    'classifierHint': 'classifier_hint',
  },
);

Map<String, dynamic> _$AnalysisToJson(_Analysis instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'summary': instance.summary,
  'photo': instance.photo.toJson(),
  'primary_item_id': instance.primaryItemId,
  'source': _$AnalysisSourceEnumMap[instance.source]!,
  'classifier_hint': instance.classifierHint,
};

const _$AnalysisSourceEnumMap = {
  AnalysisSource.image: 'image',
  AnalysisSource.text: 'text',
};

_AnalyzeResponse _$AnalyzeResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_AnalyzeResponse',
  json,
  ($checkedConvert) {
    final val = _AnalyzeResponse(
      imageId: $checkedConvert('image_id', (v) => v as String),
      imageUrl: $checkedConvert('image_url', (v) => v as String?),
      imageWidth: $checkedConvert('image_width', (v) => (v as num?)?.toInt()),
      imageHeight: $checkedConvert('image_height', (v) => (v as num?)?.toInt()),
      analysis: $checkedConvert(
        'analysis',
        (v) => Analysis.fromJson(v as Map<String, dynamic>),
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
    'imageId': 'image_id',
    'imageUrl': 'image_url',
    'imageWidth': 'image_width',
    'imageHeight': 'image_height',
    'timingsMs': 'timings_ms',
  },
);

Map<String, dynamic> _$AnalyzeResponseToJson(_AnalyzeResponse instance) =>
    <String, dynamic>{
      'image_id': instance.imageId,
      'image_url': instance.imageUrl,
      'image_width': instance.imageWidth,
      'image_height': instance.imageHeight,
      'analysis': instance.analysis.toJson(),
      'lang': _$LangEnumMap[instance.lang]!,
      'timings_ms': instance.timingsMs,
    };

const _$LangEnumMap = {Lang.en: 'en', Lang.ar: 'ar'};
