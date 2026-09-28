/// Google Maps styles that match the Kanz palette: muted paper (or warm
/// near-black) land, quiet roads, water in a desaturated glass tone, and no
/// points of interest, so material-colored drop-off pins are the loudest
/// thing on the map.
library;

import 'package:flutter/material.dart';

abstract final class KanzMapStyles {
  static const String lightAsset = 'assets/map_styles/light.json';
  static const String darkAsset = 'assets/map_styles/dark.json';

  /// The style asset for the ambient theme. Load it with
  /// `DefaultAssetBundle.of(context).loadString(...)` and pass the string
  /// to `GoogleMap(style: ...)`.
  static String assetFor(Brightness brightness) =>
      brightness == Brightness.dark ? darkAsset : lightAsset;
}
