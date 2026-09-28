/// Closed vocabularies of the API contract (mirror of `backend/app/schemas/vocab.py`).
///
/// Every Python `Literal` becomes a Dart enum whose `@JsonValue` is the exact wire
/// id. The same ids key the localized labels in `assets/config/vocab.json`, so each
/// enum also exposes [id] for vocabulary lookups and query parameters.
library;

import 'package:json_annotation/json_annotation.dart';

/// An enum whose values carry their exact wire id.
abstract interface class WireEnum {
  String get id;
}

/// Finds the value of [values] whose wire id is [id], or null.
T? enumById<T extends WireEnum>(List<T> values, String? id) {
  if (id == null) return null;
  for (final v in values) {
    if (v.id == id) return v;
  }
  return null;
}

/// Content language of AI responses (`Lang`).
enum Lang implements WireEnum {
  @JsonValue('en')
  en('en'),
  @JsonValue('ar')
  ar('ar');

  const Lang(this.id);

  @override
  final String id;

  static Lang fromId(String? id) => enumById(values, id) ?? Lang.en;
}

/// Top-level material family of an item (`MaterialCategory`).
enum MaterialCategory implements WireEnum {
  @JsonValue('glass')
  glass('glass'),
  @JsonValue('plastic')
  plastic('plastic'),
  @JsonValue('paper')
  paper('paper'),
  @JsonValue('metal')
  metal('metal'),
  @JsonValue('textile')
  textile('textile'),
  @JsonValue('wood')
  wood('wood'),
  @JsonValue('electronics')
  electronics('electronics'),
  @JsonValue('hazardous')
  hazardous('hazardous'),
  @JsonValue('organic')
  organic('organic'),
  @JsonValue('other')
  other('other');

  const MaterialCategory(this.id);

  @override
  final String id;

  static MaterialCategory? tryFromId(String? id) => enumById(values, id);
}

/// Tools and protective gear the user can have at home (`ToolId`).
enum ToolId implements WireEnum {
  @JsonValue('scissors')
  scissors('scissors'),
  @JsonValue('craft_knife')
  craftKnife('craft_knife'),
  @JsonValue('hot_glue_gun')
  hotGlueGun('hot_glue_gun'),
  @JsonValue('strong_glue')
  strongGlue('strong_glue'),
  @JsonValue('wood_glue')
  woodGlue('wood_glue'),
  @JsonValue('sandpaper')
  sandpaper('sandpaper'),
  @JsonValue('paintbrush')
  paintbrush('paintbrush'),
  @JsonValue('acrylic_paint')
  acrylicPaint('acrylic_paint'),
  @JsonValue('spray_paint')
  sprayPaint('spray_paint'),
  @JsonValue('varnish')
  varnish('varnish'),
  @JsonValue('drill')
  drill('drill'),
  @JsonValue('screwdriver')
  screwdriver('screwdriver'),
  @JsonValue('hammer')
  hammer('hammer'),
  @JsonValue('handsaw')
  handsaw('handsaw'),
  @JsonValue('pliers')
  pliers('pliers'),
  @JsonValue('wire_cutter')
  wireCutter('wire_cutter'),
  @JsonValue('measuring_tape')
  measuringTape('measuring_tape'),
  @JsonValue('ruler_pencil')
  rulerPencil('ruler_pencil'),
  @JsonValue('sewing_kit')
  sewingKit('sewing_kit'),
  @JsonValue('sewing_machine')
  sewingMachine('sewing_machine'),
  @JsonValue('iron')
  iron('iron'),
  @JsonValue('twine')
  twine('twine'),
  @JsonValue('craft_wire')
  craftWire('craft_wire'),
  @JsonValue('masking_tape')
  maskingTape('masking_tape'),
  @JsonValue('clamps')
  clamps('clamps'),
  @JsonValue('staple_gun')
  stapleGun('staple_gun'),
  @JsonValue('gloves')
  gloves('gloves'),
  @JsonValue('safety_glasses')
  safetyGlasses('safety_glasses'),
  @JsonValue('dust_mask')
  dustMask('dust_mask');

  const ToolId(this.id);

  @override
  final String id;

  /// Protective gear is recommended in safety notes but never counted as a tool
  /// the project "needs" (mirrors `SAFETY_GEAR` in the backend).
  bool get isSafetyGear =>
      this == gloves || this == safetyGlasses || this == dustMask;

  static ToolId? tryFromId(String? id) => enumById(values, id);
}

/// Observable condition of an item (`StateTag`).
enum StateTag implements WireEnum {
  @JsonValue('clean')
  clean('clean'),
  @JsonValue('dirty')
  dirty('dirty'),
  @JsonValue('greasy')
  greasy('greasy'),
  @JsonValue('contains_residue')
  containsResidue('contains_residue'),
  @JsonValue('empty')
  empty('empty'),
  @JsonValue('wet')
  wet('wet'),
  @JsonValue('intact')
  intact('intact'),
  @JsonValue('cracked')
  cracked('cracked'),
  @JsonValue('chipped')
  chipped('chipped'),
  @JsonValue('broken')
  broken('broken'),
  @JsonValue('torn')
  torn('torn'),
  @JsonValue('stained')
  stained('stained'),
  @JsonValue('faded')
  faded('faded'),
  @JsonValue('worn')
  worn('worn'),
  @JsonValue('rusted')
  rusted('rusted'),
  @JsonValue('dented')
  dented('dented'),
  @JsonValue('bent')
  bent('bent'),
  @JsonValue('moldy')
  moldy('moldy'),
  @JsonValue('missing_parts')
  missingParts('missing_parts'),
  @JsonValue('label_on')
  labelOn('label_on'),
  @JsonValue('label_off')
  labelOff('label_off'),
  @JsonValue('lid_on')
  lidOn('lid_on'),
  @JsonValue('lid_off')
  lidOff('lid_off'),
  @JsonValue('cap_on')
  capOn('cap_on'),
  @JsonValue('cap_off')
  capOff('cap_off'),
  @JsonValue('flattened')
  flattened('flattened');

  const StateTag(this.id);

  @override
  final String id;
}

/// Hazards that change how an item may be handled (`HazardFlag`).
enum HazardFlag implements WireEnum {
  @JsonValue('battery')
  battery('battery'),
  @JsonValue('e_waste')
  eWaste('e_waste'),
  @JsonValue('chemical')
  chemical('chemical'),
  @JsonValue('aerosol')
  aerosol('aerosol'),
  @JsonValue('medicine')
  medicine('medicine'),
  @JsonValue('light_bulb')
  lightBulb('light_bulb'),
  @JsonValue('broken_glass')
  brokenGlass('broken_glass'),
  @JsonValue('sharp_edges')
  sharpEdges('sharp_edges'),
  @JsonValue('mold')
  mold('mold');

  const HazardFlag(this.id);

  @override
  final String id;

  /// Items with these hazards get disposal guidance only, never DIY ideas
  /// (mirrors `DISPOSAL_ONLY_HAZARDS` in the backend).
  bool get isDisposalOnly => this != sharpEdges && this != mold;
}

/// Kind of drop-off point (`FacilityType`).
enum FacilityType implements WireEnum {
  @JsonValue('recycling_center')
  recyclingCenter('recycling_center'),
  @JsonValue('collection_point')
  collectionPoint('collection_point'),
  @JsonValue('donation')
  donation('donation'),
  @JsonValue('e_waste')
  eWaste('e_waste'),
  @JsonValue('hazardous_waste')
  hazardousWaste('hazardous_waste'),
  @JsonValue('scrap_metal')
  scrapMetal('scrap_metal'),
  @JsonValue('wood_collection')
  woodCollection('wood_collection');

  const FacilityType(this.id);

  @override
  final String id;
}

/// UAE cities used when there is no GPS fix (`CityId`).
enum CityId implements WireEnum {
  @JsonValue('abu_dhabi')
  abuDhabi('abu_dhabi'),
  @JsonValue('al_ain')
  alAin('al_ain'),
  @JsonValue('dubai')
  dubai('dubai'),
  @JsonValue('sharjah')
  sharjah('sharjah'),
  @JsonValue('ajman')
  ajman('ajman'),
  @JsonValue('umm_al_quwain')
  ummAlQuwain('umm_al_quwain'),
  @JsonValue('ras_al_khaimah')
  rasAlKhaimah('ras_al_khaimah'),
  @JsonValue('fujairah')
  fujairah('fujairah');

  const CityId(this.id);

  @override
  final String id;

  static CityId? tryFromId(String? id) => enumById(values, id);
}

/// The user's DIY experience (`SkillLevel`).
enum SkillLevel implements WireEnum {
  @JsonValue('beginner')
  beginner('beginner'),
  @JsonValue('intermediate')
  intermediate('intermediate'),
  @JsonValue('advanced')
  advanced('advanced');

  const SkillLevel(this.id);

  @override
  final String id;

  static SkillLevel? tryFromId(String? id) => enumById(values, id);
}

/// Difficulty of an upcycling idea (`Difficulty`).
enum Difficulty implements WireEnum {
  @JsonValue('easy')
  easy('easy'),
  @JsonValue('medium')
  medium('medium'),
  @JsonValue('hard')
  hard('hard');

  const Difficulty(this.id);

  @override
  final String id;
}

/// Three-step scale used for reuse potential, swap effort and swap cost (`Level`).
enum Level implements WireEnum {
  @JsonValue('low')
  low('low'),
  @JsonValue('medium')
  medium('medium'),
  @JsonValue('high')
  high('high');

  const Level(this.id);

  @override
  final String id;
}

/// Whether an item is accepted by recycling (`RecyclabilityStatus`).
enum RecyclabilityStatus implements WireEnum {
  @JsonValue('yes')
  yes('yes'),
  @JsonValue('conditional')
  conditional('conditional'),
  @JsonValue('no')
  no('no');

  const RecyclabilityStatus(this.id);

  @override
  final String id;
}
