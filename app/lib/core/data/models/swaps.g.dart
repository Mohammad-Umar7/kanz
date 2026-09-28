// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swaps.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HistorySummary _$HistorySummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_HistorySummary',
      json,
      ($checkedConvert) {
        final val = _HistorySummary(
          periodDays: $checkedConvert(
            'period_days',
            (v) => (v as num?)?.toInt() ?? 30,
          ),
          counts: $checkedConvert(
            'counts',
            (v) =>
                (v as Map<String, dynamic>?)?.map(
                  (k, e) => MapEntry(
                    $enumDecode(_$MaterialCategoryEnumMap, k),
                    (e as num).toInt(),
                  ),
                ) ??
                const <MaterialCategory, int>{},
          ),
          topItems: $checkedConvert(
            'top_items',
            (v) =>
                (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                const <String>[],
          ),
          topItemCounts: $checkedConvert(
            'top_item_counts',
            (v) =>
                (v as List<dynamic>?)
                    ?.map((e) => (e as num).toInt())
                    .toList() ??
                const <int>[],
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'periodDays': 'period_days',
        'topItems': 'top_items',
        'topItemCounts': 'top_item_counts',
      },
    );

Map<String, dynamic> _$HistorySummaryToJson(_HistorySummary instance) =>
    <String, dynamic>{
      'period_days': instance.periodDays,
      'counts': instance.counts.map(
        (k, e) => MapEntry(_$MaterialCategoryEnumMap[k]!, e),
      ),
      'top_items': instance.topItems,
      'top_item_counts': instance.topItemCounts,
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

_SwapsRequest _$SwapsRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SwapsRequest', json, ($checkedConvert) {
      final val = _SwapsRequest(
        materials: $checkedConvert(
          'materials',
          (v) =>
              (v as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
        ),
        history: $checkedConvert(
          'history',
          (v) => v == null
              ? null
              : HistorySummary.fromJson(v as Map<String, dynamic>),
        ),
        lang: $checkedConvert(
          'lang',
          (v) => $enumDecodeNullable(_$LangEnumMap, v) ?? Lang.en,
        ),
      );
      return val;
    });

Map<String, dynamic> _$SwapsRequestToJson(_SwapsRequest instance) =>
    <String, dynamic>{
      'materials': instance.materials,
      'history': instance.history?.toJson(),
      'lang': _$LangEnumMap[instance.lang]!,
    };

const _$LangEnumMap = {Lang.en: 'en', Lang.ar: 'ar'};

_Swap _$SwapFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_Swap',
  json,
  ($checkedConvert) {
    final val = _Swap(
      id: $checkedConvert('id', (v) => v as String),
      fromItem: $checkedConvert('from_item', (v) => v as String),
      toItem: $checkedConvert('to_item', (v) => v as String),
      why: $checkedConvert('why', (v) => v as String),
      tip: $checkedConvert('tip', (v) => v as String),
      effort: $checkedConvert('effort', (v) => $enumDecode(_$LevelEnumMap, v)),
      cost: $checkedConvert('cost', (v) => $enumDecode(_$LevelEnumMap, v)),
      category: $checkedConvert(
        'category',
        (v) => $enumDecode(_$MaterialCategoryEnumMap, v),
      ),
      impactNote: $checkedConvert('impact_note', (v) => v as String?),
      matchedInput: $checkedConvert('matched_input', (v) => v as String?),
      fromHistory: $checkedConvert('from_history', (v) => v as bool? ?? false),
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
    'fromItem': 'from_item',
    'toItem': 'to_item',
    'impactNote': 'impact_note',
    'matchedInput': 'matched_input',
    'fromHistory': 'from_history',
  },
);

Map<String, dynamic> _$SwapToJson(_Swap instance) => <String, dynamic>{
  'id': instance.id,
  'from_item': instance.fromItem,
  'to_item': instance.toItem,
  'why': instance.why,
  'tip': instance.tip,
  'effort': _$LevelEnumMap[instance.effort]!,
  'cost': _$LevelEnumMap[instance.cost]!,
  'category': _$MaterialCategoryEnumMap[instance.category]!,
  'impact_note': instance.impactNote,
  'matched_input': instance.matchedInput,
  'from_history': instance.fromHistory,
  'sources': instance.sources.map((e) => e.toJson()).toList(),
};

const _$LevelEnumMap = {
  Level.low: 'low',
  Level.medium: 'medium',
  Level.high: 'high',
};

_SwapsResponse _$SwapsResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_SwapsResponse',
      json,
      ($checkedConvert) {
        final val = _SwapsResponse(
          swaps: $checkedConvert(
            'swaps',
            (v) => (v as List<dynamic>)
                .map((e) => Swap.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          historyInsight: $checkedConvert(
            'history_insight',
            (v) => v as String?,
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
        'historyInsight': 'history_insight',
        'timingsMs': 'timings_ms',
      },
    );

Map<String, dynamic> _$SwapsResponseToJson(_SwapsResponse instance) =>
    <String, dynamic>{
      'swaps': instance.swaps.map((e) => e.toJson()).toList(),
      'history_insight': instance.historyInsight,
      'lang': _$LangEnumMap[instance.lang]!,
      'timings_ms': instance.timingsMs,
    };
