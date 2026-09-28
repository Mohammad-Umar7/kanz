/// Kanz icon set: Phosphor, regular weight, everywhere.
///
/// phosphor_flutter marks every glyph as `matchTextDirection`, which would
/// mirror a camera or a leaf in Arabic. Kanz declares its own constants
/// instead: only directional glyphs (arrows, carets, lists, undo, send)
/// mirror in right-to-left layouts. The constants are `const` so release
/// builds can tree-shake the icon font.
library;

import 'package:flutter/widgets.dart';

const String _family = 'PhosphorRegular';
const String _package = 'phosphor_flutter';

/// A non-mirroring Phosphor regular glyph.
class _Icon extends IconData {
  const _Icon(super.codePoint)
    : super(fontFamily: _family, fontPackage: _package);
}

/// A Phosphor regular glyph that mirrors in right-to-left layouts.
class _DirectionalIcon extends IconData {
  const _DirectionalIcon(super.codePoint)
    : super(
        fontFamily: _family,
        fontPackage: _package,
        matchTextDirection: true,
      );
}

abstract final class KanzIcons {
  // Navigation and shell.
  static const IconData home = _Icon(0xe2c2);
  static const IconData dropOff = _Icon(0xe316);
  static const IconData map = _Icon(0xe31a);
  static const IconData swaps = _Icon(0xe0a0);
  static const IconData impact = _Icon(0xe150);
  static const IconData scan = _Icon(0xebb6);
  static const IconData history = _Icon(0xe1a0);
  static const IconData settings = _Icon(0xe272);
  static const IconData search = _Icon(0xe30c);
  static const IconData more = _Icon(0xe1fe);
  static const IconData close = _Icon(0xe4f6);
  static const IconData add = _Icon(0xe3d4);
  static const IconData remove = _Icon(0xe32a);

  // Capture.
  static const IconData camera = _Icon(0xe10e);
  static const IconData cameraSwitch = _Icon(0xe7a4);
  static const IconData gallery = _Icon(0xe2ca);
  static const IconData describe = _Icon(0xe6ee);
  static const IconData flashOn = _Icon(0xe2de);
  static const IconData flashOff = _Icon(0xe2e0);
  static const IconData frame = _Icon(0xe626);

  // Status.
  static const IconData check = _Icon(0xe182);
  static const IconData checkCircle = _Icon(0xe184);
  static const IconData circle = _Icon(0xe18a);
  static const IconData warning = _Icon(0xe4e0);
  static const IconData error = _Icon(0xe4e2);
  static const IconData info = _Icon(0xe2ce);
  static const IconData tip = _Icon(0xe2dc);
  static const IconData safety = _Icon(0xe40c);
  static const IconData prohibited = _Icon(0xe3de);
  static const IconData retry = _Icon(0xe036);
  static const IconData offline = _Icon(0xe1b6);
  static const IconData noWifi = _Icon(0xe4f2);
  static const IconData clock = _Icon(0xe19a);
  static const IconData lock = _Icon(0xe2fa);

  // Directional (mirror in RTL).
  static const IconData forward = _DirectionalIcon(0xe06c);
  static const IconData back = _DirectionalIcon(0xe058);
  static const IconData chevronForward = _DirectionalIcon(0xe13a);
  static const IconData chevronBack = _DirectionalIcon(0xe138);
  static const IconData external = _DirectionalIcon(0xe5de);
  static const IconData undo = _DirectionalIcon(0xe08a);
  static const IconData send = _DirectionalIcon(0xe398);
  static const IconData list = _DirectionalIcon(0xe2f2);
  static const IconData numberedList = _DirectionalIcon(0xe2f6);

  // Vertical carets never mirror.
  static const IconData chevronDown = _Icon(0xe136);
  static const IconData chevronUp = _Icon(0xe13c);

  // Actions and content.
  static const IconData edit = _Icon(0xe3b4);
  static const IconData delete = _Icon(0xe4a6);
  static const IconData share = _Icon(0xe408);
  static const IconData save = _Icon(0xe0ea);
  static const IconData tools = _Icon(0xeca0);
  static const IconData wrench = _Icon(0xe5d4);
  static const IconData hammer = _Icon(0xe80e);
  static const IconData paintBrush = _Icon(0xe6f0);
  static const IconData scissors = _Icon(0xeae0);
  static const IconData ruler = _Icon(0xe6b8);
  static const IconData upcycle = _Icon(0xe80e);
  static const IconData recycle = _Icon(0xe75a);
  static const IconData donate = _Icon(0xe810);
  static const IconData phone = _Icon(0xe3b8);
  static const IconData website = _Icon(0xe288);
  static const IconData directions = _Icon(0xeade);
  static const IconData locate = _Icon(0xe1d6);
  static const IconData filters = _Icon(0xe434);
  static const IconData speaker = _Icon(0xe44a);
  static const IconData speakerOff = _Icon(0xe45a);
  static const IconData microphone = _Icon(0xe326);
  static const IconData play = _Icon(0xe3d0);
  static const IconData pause = _Icon(0xe39e);
  static const IconData language = _Icon(0xe4a2);
  static const IconData darkMode = _Icon(0xe330);
  static const IconData lightMode = _Icon(0xe472);
  static const IconData leaf = _Icon(0xe2da);
  static const IconData water = _Icon(0xe210);
  static const IconData store = _Icon(0xe470);
  static const IconData tag = _Icon(0xe478);
  static const IconData calendar = _Icon(0xe108);
  static const IconData user = _Icon(0xe4c2);
  static const IconData community = _Icon(0xe68e);
  static const IconData trophy = _Icon(0xe67e);
  static const IconData trend = _Icon(0xe4ae);
  static const IconData timer = _Icon(0xe492);
  static const IconData bag = _Icon(0xe494);
  static const IconData question = _Icon(0xe3e8);
  static const IconData gloves = _Icon(0xe57c);
  static const IconData goggles = _Icon(0xecb4);
  static const IconData mask = _Icon(0xe56a);
  static const IconData dragHandle = _Icon(0xe794);
  static const IconData compare = _Icon(0xeb06);
  static const IconData source = _Icon(0xe0e6);
  static const IconData skipped = _Icon(0xe32c);

  // Hazards.
  static const IconData battery = _Icon(0xe0c8);
  static const IconData medicine = _Icon(0xe700);
  static const IconData lightBulb = _Icon(0xe63c);
  static const IconData aerosol = _Icon(0xe7e4);

  // Material categories (ids from contracts/vocab.json).
  static const IconData glass = _Icon(0xe6b2);
  static const IconData plastic = _Icon(0xe7b0);
  static const IconData paper = _Icon(0xe344);
  static const IconData metal = _Icon(0xe8fc);
  static const IconData textile = _Icon(0xe670);
  static const IconData wood = _Icon(0xe6da);
  static const IconData electronics = _Icon(0xe610);
  static const IconData hazardous = _Icon(0xe4e0);
  static const IconData organic = _Icon(0xe2da);
  static const IconData other = _Icon(0xe1da);

  /// The glyph for a material category id; unknown ids get [other].
  static IconData material(String categoryId) => switch (categoryId) {
    'glass' => glass,
    'plastic' => plastic,
    'paper' => paper,
    'metal' => metal,
    'textile' => textile,
    'wood' => wood,
    'electronics' => electronics,
    'hazardous' => hazardous,
    'organic' => organic,
    _ => other,
  };

  /// The glyph for a hazard id from the vocabulary.
  static IconData hazard(String hazardId) => switch (hazardId) {
    'battery' => battery,
    'e_waste' => electronics,
    'medicine' => medicine,
    'light_bulb' => lightBulb,
    'aerosol' => aerosol,
    'chemical' => prohibited,
    _ => warning,
  };
}
