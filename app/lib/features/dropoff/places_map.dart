import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/data/models/models.dart';
import '../../core/design/design.dart';

/// What the map view draws: the places, the selection and how to react.
@immutable
class PlacesMapSpec {
  const PlacesMapSpec({
    required this.places,
    required this.center,
    required this.pinMaterials,
    required this.onPinTap,
    required this.semanticsLabel,
    this.selectedId,
    this.bottomPadding = 0,
    this.showMyLocation = false,
  });

  /// Nearest first.
  final List<Place> places;
  final GeoPoint center;

  /// Place id to material id (null draws a neutral ink pin).
  final Map<String, String?> pinMaterials;
  final ValueChanged<Place> onPinTap;
  final String semanticsLabel;
  final String? selectedId;

  /// Height covered by the places sheet, so the camera and the Google logo
  /// stay in the visible part.
  final double bottomPadding;
  final bool showMyLocation;
}

/// Builds the map for a [PlacesMapSpec]. The screen uses [PlacesGoogleMap];
/// tests pass a drawn stand-in (platform views do not render in tests).
typedef PlacesMapBuilder =
    Widget Function(BuildContext context, PlacesMapSpec spec);

Widget googlePlacesMap(BuildContext context, PlacesMapSpec spec) =>
    PlacesGoogleMap(spec: spec);

/// Google map in the Kanz map style with material-colored circular pins
/// drawn on a canvas; the selected pin is larger with an ink ring.
class PlacesGoogleMap extends StatefulWidget {
  const PlacesGoogleMap({super.key, required this.spec});

  final PlacesMapSpec spec;

  @override
  State<PlacesGoogleMap> createState() => _PlacesGoogleMapState();
}

class _PlacesGoogleMapState extends State<PlacesGoogleMap> {
  GoogleMapController? _controller;
  String? _style;
  Brightness? _styleBrightness;
  final Map<_PinKey, BitmapDescriptor> _icons = {};
  final Set<_PinKey> _pending = {};

  PlacesMapSpec get spec => widget.spec;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (brightness != _styleBrightness) {
      _styleBrightness = brightness;
      _icons.clear();
      unawaited(_loadStyle(brightness));
    }
  }

  Future<void> _loadStyle(Brightness brightness) async {
    final style = await DefaultAssetBundle.of(
      context,
    ).loadString(KanzMapStyles.assetFor(brightness));
    if (mounted && brightness == _styleBrightness) {
      setState(() => _style = style);
    }
  }

  @override
  void didUpdateWidget(PlacesGoogleMap old) {
    super.didUpdateWidget(old);
    if (!_samePlaces(old.spec.places, spec.places)) {
      _fitAll();
    } else if (spec.selectedId != null &&
        spec.selectedId != old.spec.selectedId) {
      final place = spec.places
          .where((p) => p.id == spec.selectedId)
          .firstOrNull;
      if (place != null) {
        _controller?.animateCamera(
          CameraUpdate.newLatLng(LatLng(place.lat, place.lng)),
        );
      }
    }
  }

  static bool _samePlaces(List<Place> a, List<Place> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  void _fitAll() {
    final controller = _controller;
    if (controller == null || spec.places.isEmpty) return;
    var south = spec.center.lat;
    var north = spec.center.lat;
    var west = spec.center.lng;
    var east = spec.center.lng;
    for (final p in spec.places) {
      south = math.min(south, p.lat);
      north = math.max(north, p.lat);
      west = math.min(west, p.lng);
      east = math.max(east, p.lng);
    }
    unawaited(
      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(south, west),
            northeast: LatLng(north, east),
          ),
          KanzSpace.s48,
        ),
      ),
    );
  }

  /// The pin for [fill], or null while it is being drawn (the marker then
  /// appears a frame later instead of flashing Google's default pin).
  BitmapDescriptor? _icon(Color fill, {required bool selected}) {
    final key = _PinKey(fill, selected);
    final cached = _icons[key];
    if (cached != null) return cached;
    if (_pending.add(key)) {
      final c = context.kanzColors;
      final ratio = MediaQuery.devicePixelRatioOf(context);
      unawaited(
        _drawPin(
          fill: fill,
          ring: c.surface,
          outline: c.ink,
          selected: selected,
          pixelRatio: ratio,
        ).then((icon) {
          _pending.remove(key);
          if (mounted) setState(() => _icons[key] = icon);
        }),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      for (final place in spec.places)
        if (_icon(
              spec.pinMaterials[place.id] == null
                  ? context.kanzColors.ink
                  : KanzMaterialColors.pin(
                      context,
                      spec.pinMaterials[place.id]!,
                    ),
              selected: place.id == spec.selectedId,
            )
            case final icon?)
          Marker(
            markerId: MarkerId(place.id),
            position: LatLng(place.lat, place.lng),
            anchor: const Offset(0.5, 0.5),
            consumeTapEvents: true,
            zIndexInt: place.id == spec.selectedId ? 2 : 1,
            icon: icon,
            onTap: () => spec.onPinTap(place),
          ),
    };
    return Semantics(
      label: spec.semanticsLabel,
      container: true,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(spec.center.lat, spec.center.lng),
          zoom: 11.5,
        ),
        style: _style,
        markers: markers,
        padding: EdgeInsets.only(bottom: spec.bottomPadding),
        myLocationEnabled: spec.showMyLocation,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        onMapCreated: (controller) {
          _controller = controller;
          _fitAll();
        },
      ),
    );
  }
}

@immutable
class _PinKey {
  const _PinKey(this.fill, this.selected);

  final Color fill;
  final bool selected;

  @override
  bool operator ==(Object other) =>
      other is _PinKey && other.fill == fill && other.selected == selected;

  @override
  int get hashCode => Object.hash(fill, selected);
}

/// A circular pin: a material-colored disc in a paper ring with a hairline
/// outline; selected pins are larger and ringed in ink.
Future<BitmapDescriptor> _drawPin({
  required Color fill,
  required Color ring,
  required Color outline,
  required bool selected,
  required double pixelRatio,
}) async {
  final size = selected ? 30.0 : 20.0;
  final px = (size * pixelRatio).ceil();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(pixelRatio);
  final center = Offset(size / 2, size / 2);
  final radius = size / 2 - 1;
  if (selected) {
    canvas.drawCircle(center, radius, Paint()..color = outline);
    canvas.drawCircle(center, radius - 2.5, Paint()..color = ring);
    canvas.drawCircle(center, radius - 4.5, Paint()..color = fill);
  } else {
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = outline.withValues(alpha: 0.28),
    );
    canvas.drawCircle(center, radius - 1, Paint()..color = ring);
    canvas.drawCircle(center, radius - 3.5, Paint()..color = fill);
  }
  final image = await recorder.endRecording().toImage(px, px);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return BitmapDescriptor.bytes(
    bytes!.buffer.asUint8List(),
    width: size,
    height: size,
  );
}
