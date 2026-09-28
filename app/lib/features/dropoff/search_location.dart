import 'package:flutter/material.dart';

import '../../core/data/models/models.dart';
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
import '../../core/state/location_resolver.dart';
import '../../l10n/l10n.dart';
import 'place_info.dart';

/// Where the user wants to search: their own location (null [city]) or a
/// city centre.
@immutable
class LocationChoice {
  const LocationChoice.myLocation() : city = null;
  const LocationChoice.city(CityId this.city);

  final CityId? city;
}

/// "Near Dubai · Change": where the results come from, and the way to
/// change it. A weak GPS fix adds a note that the city centre is used.
class SearchLocationBar extends StatelessWidget {
  const SearchLocationBar({
    super.key,
    required this.label,
    required this.changeLabel,
    required this.onChange,
    this.note,
    this.gps = false,
  });

  final String label;
  final String changeLabel;
  final VoidCallback? onChange;
  final String? note;

  /// Searching around the phone's position (locate glyph) or a city.
  final bool gps;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        0,
        KanzSpace.s8,
        0,
      ),
      child: Row(
        children: [
          Icon(
            gps ? KanzIcons.locate : KanzIcons.dropOff,
            size: 18,
            color: c.inkSecondary,
          ),
          const SizedBox(width: KanzSpace.s8),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: t.titleMedium),
                  if (note != null) ...[
                    const SizedBox(height: KanzSpace.s2),
                    Text(note!, style: t.bodySmall),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: KanzSpace.s4),
          KanzButton.tertiary(label: changeLabel, onPressed: onChange),
        ],
      ),
    );
  }
}

/// Opens the "Search near" sheet and returns the user's choice.
Future<LocationChoice?> showSearchLocationSheet(
  BuildContext context, {
  required Vocab vocab,
  required SearchLocation? current,
}) {
  return showKanzSheet<LocationChoice>(
    context: context,
    builder: (context) => _SearchLocationSheet(vocab: vocab, current: current),
  );
}

class _SearchLocationSheet extends StatelessWidget {
  const _SearchLocationSheet({required this.vocab, required this.current});

  final Vocab vocab;
  final SearchLocation? current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final usingGps = current?.source == SearchLocationSource.gps;
    return KanzSheet(
      title: l10n.dropoffLocationSheetTitle,
      subtitle: l10n.dropoffLocationSheetSubtitle(dropoffRadiusKm),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsetsDirectional.only(bottom: KanzSpace.s16),
        children: [
          _ChoiceTile(
            icon: KanzIcons.locate,
            title: l10n.dropoffUseMyLocation,
            subtitle: l10n.dropoffUseMyLocationDetail,
            selected: usingGps,
            onTap: () =>
                Navigator.of(context).pop(const LocationChoice.myLocation()),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              KanzSpace.gutter,
              KanzSpace.s16,
              KanzSpace.gutter,
              KanzSpace.s4,
            ),
            child: MonoLabel(l10n.dropoffCities),
          ),
          for (final city in vocab.cities)
            _ChoiceTile(
              title: city.label.forLocale(locale),
              selected: !usingGps && current?.city == city.id,
              onTap: () =>
                  Navigator.of(context).pop(LocationChoice.city(city.id)),
            ),
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: KanzListTile(
        title: title,
        subtitle: subtitle,
        leading: icon == null ? null : Icon(icon),
        trailing: selected
            ? Icon(KanzIcons.check, size: 20, color: c.ink)
            : null,
        onTap: onTap,
      ),
    );
  }
}
