/// Typed view of `assets/config/vocab.json`, the shared vocabulary.
///
/// The backend only ever sends English ids (`craft_knife`, `label_on`); the app
/// localizes them from this file so labels are consistent everywhere and cost no
/// model tokens. The file is an exact copy of `contracts/vocab.json`.
library;

import 'dart:ui' show Color, Locale;

import '../models/vocab_enums.dart';

/// A label in both supported languages.
class LocalizedLabel {
  const LocalizedLabel({required this.en, required this.ar});

  factory LocalizedLabel.fromJson(Map<String, dynamic> json) =>
      LocalizedLabel(en: json['en'] as String, ar: json['ar'] as String);

  final String en;
  final String ar;

  String of(Lang lang) => lang == Lang.ar ? ar : en;

  String forLocale(Locale locale) => locale.languageCode == 'ar' ? ar : en;
}

/// Whether a vocabulary tool is a real tool or protective gear.
enum ToolKind { tool, safety }

class MaterialEntry {
  const MaterialEntry({
    required this.id,
    required this.label,
    required this.colorValue,
    required this.icon,
  });

  final MaterialCategory id;
  final LocalizedLabel label;

  /// ARGB data color for chips, dots, boxes and map pins (never large fills).
  final int colorValue;

  /// Icon name hint from the vocabulary (the design system maps it to a glyph).
  final String icon;

  Color get color => Color(colorValue);
}

class ToolEntry {
  const ToolEntry({required this.id, required this.label, required this.kind});

  final ToolId id;
  final LocalizedLabel label;
  final ToolKind kind;
}

class StateTagEntry {
  const StateTagEntry({required this.id, required this.label});

  final StateTag id;
  final LocalizedLabel label;
}

class HazardEntry {
  const HazardEntry({
    required this.id,
    required this.label,
    required this.disposalOnly,
  });

  final HazardFlag id;
  final LocalizedLabel label;

  /// Items with this hazard get disposal guidance only, never DIY ideas.
  final bool disposalOnly;
}

class FacilityTypeEntry {
  const FacilityTypeEntry({required this.id, required this.label});

  final FacilityType id;
  final LocalizedLabel label;
}

class CityEntry {
  const CityEntry({
    required this.id,
    required this.label,
    required this.lat,
    required this.lng,
  });

  final CityId id;
  final LocalizedLabel label;
  final double lat;
  final double lng;
}

class QualityLabelEntry {
  const QualityLabelEntry({required this.score, required this.label});

  /// 1 poor ... 5 like new.
  final int score;
  final LocalizedLabel label;
}

/// All vocabularies with O(1) lookups by id.
class Vocab {
  Vocab({
    required this.materials,
    required this.tools,
    required this.stateTags,
    required this.hazards,
    required this.facilityTypes,
    required this.cities,
    required this.qualityLabels,
  }) : _materials = {for (final m in materials) m.id: m},
       _tools = {for (final t in tools) t.id: t},
       _states = {for (final s in stateTags) s.id: s},
       _hazards = {for (final h in hazards) h.id: h},
       _facilityTypes = {for (final f in facilityTypes) f.id: f},
       _cities = {for (final c in cities) c.id: c},
       _quality = {for (final q in qualityLabels) q.score: q};

  /// Parses the decoded vocab.json. Throws [FormatException] when an id is not
  /// one of the contract enums, so drift between the file and the models fails fast.
  factory Vocab.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list(String key) =>
        (json[key] as List<dynamic>).cast<Map<String, dynamic>>();

    T byId<T extends WireEnum>(List<T> values, String id, String key) {
      final match = enumById(values, id);
      if (match == null) throw FormatException('Unknown $key id "$id"');
      return match;
    }

    final disposalOnly = (json['disposal_only_hazards'] as List<dynamic>)
        .cast<String>()
        .toSet();

    return Vocab(
      materials: [
        for (final m in list('materials'))
          MaterialEntry(
            id: byId(MaterialCategory.values, m['id'] as String, 'material'),
            label: LocalizedLabel.fromJson(m),
            colorValue: _parseHexColor(m['color'] as String),
            icon: m['icon'] as String,
          ),
      ],
      tools: [
        for (final t in list('tools'))
          ToolEntry(
            id: byId(ToolId.values, t['id'] as String, 'tool'),
            label: LocalizedLabel.fromJson(t),
            kind: t['kind'] == 'safety' ? ToolKind.safety : ToolKind.tool,
          ),
      ],
      stateTags: [
        for (final s in list('state_tags'))
          StateTagEntry(
            id: byId(StateTag.values, s['id'] as String, 'state tag'),
            label: LocalizedLabel.fromJson(s),
          ),
      ],
      hazards: [
        for (final h in list('hazards'))
          HazardEntry(
            id: byId(HazardFlag.values, h['id'] as String, 'hazard'),
            label: LocalizedLabel.fromJson(h),
            disposalOnly: disposalOnly.contains(h['id']),
          ),
      ],
      facilityTypes: [
        for (final f in list('facility_types'))
          FacilityTypeEntry(
            id: byId(FacilityType.values, f['id'] as String, 'facility type'),
            label: LocalizedLabel.fromJson(f),
          ),
      ],
      cities: [
        for (final c in list('cities'))
          CityEntry(
            id: byId(CityId.values, c['id'] as String, 'city'),
            label: LocalizedLabel.fromJson(c),
            lat: (c['lat'] as num).toDouble(),
            lng: (c['lng'] as num).toDouble(),
          ),
      ],
      qualityLabels: [
        for (final q in list('quality_labels'))
          QualityLabelEntry(
            score: q['score'] as int,
            label: LocalizedLabel.fromJson(q),
          ),
      ],
    );
  }

  final List<MaterialEntry> materials;
  final List<ToolEntry> tools;
  final List<StateTagEntry> stateTags;
  final List<HazardEntry> hazards;
  final List<FacilityTypeEntry> facilityTypes;
  final List<CityEntry> cities;
  final List<QualityLabelEntry> qualityLabels;

  final Map<MaterialCategory, MaterialEntry> _materials;
  final Map<ToolId, ToolEntry> _tools;
  final Map<StateTag, StateTagEntry> _states;
  final Map<HazardFlag, HazardEntry> _hazards;
  final Map<FacilityType, FacilityTypeEntry> _facilityTypes;
  final Map<CityId, CityEntry> _cities;
  final Map<int, QualityLabelEntry> _quality;

  MaterialEntry material(MaterialCategory id) => _materials[id]!;
  ToolEntry tool(ToolId id) => _tools[id]!;
  StateTagEntry stateTag(StateTag id) => _states[id]!;
  HazardEntry hazard(HazardFlag id) => _hazards[id]!;
  FacilityTypeEntry facilityType(FacilityType id) => _facilityTypes[id]!;
  CityEntry city(CityId id) => _cities[id]!;

  /// Label for a 1-5 quality score (clamped).
  LocalizedLabel qualityLabel(int score) => _quality[score.clamp(1, 5)]!.label;

  /// Tools the user can pick in onboarding and settings (no protective gear).
  List<ToolEntry> get realTools =>
      tools.where((t) => t.kind == ToolKind.tool).toList(growable: false);

  /// Protective gear, always recommended in safety notes.
  List<ToolEntry> get safetyGear =>
      tools.where((t) => t.kind == ToolKind.safety).toList(growable: false);

  /// City closest to a coordinate (equirectangular distance is plenty at UAE scale).
  CityEntry nearestCity(double lat, double lng) {
    return cities.reduce((best, c) {
      double d(CityEntry e) {
        final dLat = e.lat - lat;
        final dLng = e.lng - lng;
        return dLat * dLat + dLng * dLng;
      }

      return d(c) < d(best) ? c : best;
    });
  }
}

int _parseHexColor(String hex) {
  final value = hex.replaceFirst('#', '');
  if (value.length != 6) throw FormatException('Bad color "$hex"');
  return 0xFF000000 | int.parse(value, radix: 16);
}
