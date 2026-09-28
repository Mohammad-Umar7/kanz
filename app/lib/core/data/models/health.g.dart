// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HealthResponse _$HealthResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_HealthResponse',
      json,
      ($checkedConvert) {
        final val = _HealthResponse(
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$HealthStatusEnumMap, v),
          ),
          appName: $checkedConvert('app_name', (v) => v as String),
          version: $checkedConvert('version', (v) => v as String),
          models: $checkedConvert(
            'models',
            (v) => Map<String, String>.from(v as Map),
          ),
          aiConfigured: $checkedConvert('ai_configured', (v) => v as bool),
          knowledgeDocs: $checkedConvert(
            'knowledge_docs',
            (v) => (v as num).toInt(),
          ),
          ragReady: $checkedConvert('rag_ready', (v) => v as bool),
          placesGoogle: $checkedConvert('places_google', (v) => v as bool),
          placesOsm: $checkedConvert('places_osm', (v) => v as bool),
          uptimeS: $checkedConvert('uptime_s', (v) => (v as num).toInt()),
        );
        return val;
      },
      fieldKeyMap: const {
        'appName': 'app_name',
        'aiConfigured': 'ai_configured',
        'knowledgeDocs': 'knowledge_docs',
        'ragReady': 'rag_ready',
        'placesGoogle': 'places_google',
        'placesOsm': 'places_osm',
        'uptimeS': 'uptime_s',
      },
    );

Map<String, dynamic> _$HealthResponseToJson(_HealthResponse instance) =>
    <String, dynamic>{
      'status': _$HealthStatusEnumMap[instance.status]!,
      'app_name': instance.appName,
      'version': instance.version,
      'models': instance.models,
      'ai_configured': instance.aiConfigured,
      'knowledge_docs': instance.knowledgeDocs,
      'rag_ready': instance.ragReady,
      'places_google': instance.placesGoogle,
      'places_osm': instance.placesOsm,
      'uptime_s': instance.uptimeS,
    };

const _$HealthStatusEnumMap = {
  HealthStatus.ok: 'ok',
  HealthStatus.degraded: 'degraded',
};
