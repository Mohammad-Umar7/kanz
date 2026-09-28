import 'package:flutter/material.dart';

import '../../core/data/models/models.dart';
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
import '../../l10n/l10n.dart';
import 'place_info.dart';

/// Everything known about one drop-off point, with Call, Website and
/// Directions. Shown in a [KanzSheet]; the source attribution is always
/// visible because OpenStreetMap and Google require it.
class PlaceDetailsSheet extends StatelessWidget {
  const PlaceDetailsSheet({
    super.key,
    required this.place,
    required this.vocab,
    required this.origin,
    required this.cityName,
    required this.onDirections,
    required this.onCall,
    required this.onWebsite,
  });

  final Place place;
  final Vocab vocab;

  /// The search centre, for the compass direction.
  final GeoPoint? origin;

  /// City searched around, or null for the user's own location.
  final String? cityName;
  final VoidCallback? onDirections;
  final VoidCallback? onCall;
  final VoidCallback? onWebsite;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final locale = Localizations.localeOf(context);
    final open = openStateOf(place);
    final openColor = switch (open) {
      OpenState.open => c.positive,
      OpenState.closed => c.danger,
      OpenState.unknown => c.inkSecondary,
    };
    final accepted = place.acceptedMaterials ?? const <MaterialCategory>[];
    final subtitle = [
      placeTypeLabel(vocab, locale, place),
      if (origin != null)
        directionLabel(l10n, origin!, place, cityName: cityName),
    ].where((s) => s.isNotEmpty).join(' · ');

    final hasCall = onCall != null;
    final hasWebsite = onWebsite != null;

    return KanzSheet(
      title: place.name,
      subtitle: subtitle.isEmpty ? null : subtitle,
      actions: [
        if (hasCall || hasWebsite)
          Row(
            spacing: KanzSpace.s8,
            children: [
              if (hasCall)
                Expanded(
                  child: KanzButton.secondary(
                    label: l10n.dropoffCall,
                    icon: KanzIcons.phone,
                    onPressed: onCall,
                    expand: true,
                  ),
                ),
              if (hasWebsite)
                Expanded(
                  child: KanzButton.secondary(
                    label: l10n.dropoffWebsite,
                    icon: KanzIcons.website,
                    onPressed: onWebsite,
                    expand: true,
                  ),
                ),
            ],
          ),
        KanzButton(
          label: l10n.dropoffDirections,
          icon: KanzIcons.directions,
          onPressed: onDirections,
          expand: true,
        ),
      ],
      child: SingleChildScrollView(
        padding: KanzSpace.page,
        child: DataGrid(
          entries: [
            DataGridEntry(
              l10n.dropoffDetailDistance,
              child: MonoLabel(
                place.distanceM == null
                    ? '–'
                    : formatDistance(l10n, place.distanceM!),
                strong: true,
              ),
            ),
            DataGridEntry(
              l10n.dropoffDetailHours,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 3),
                    child: Icon(KanzIcons.clock, size: 16, color: openColor),
                  ),
                  const SizedBox(width: KanzSpace.s4),
                  Flexible(
                    child: Text(
                      openLabel(l10n, open),
                      style: t.bodyMedium?.copyWith(color: openColor),
                    ),
                  ),
                ],
              ),
            ),
            if (place.address case final address? when address.isNotEmpty)
              DataGridEntry(
                l10n.dropoffDetailAddress,
                value: address,
                span: true,
              ),
            DataGridEntry(
              l10n.dropoffDetailAccepts,
              span: true,
              child: accepted.isEmpty
                  ? Text(
                      place.acceptedNote ?? l10n.dropoffAcceptedUnknown,
                      style: t.bodyMedium?.copyWith(color: c.inkSecondary),
                    )
                  : Wrap(
                      spacing: KanzSpace.s16,
                      runSpacing: KanzSpace.s8,
                      children: [
                        for (final m in accepted)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MaterialDot(m.id),
                              const SizedBox(width: KanzSpace.s8),
                              Text(
                                materialLabel(vocab, locale, m),
                                style: t.bodyMedium,
                              ),
                            ],
                          ),
                      ],
                    ),
            ),
            DataGridEntry(
              l10n.dropoffDetailSource,
              value: sourceAttribution(l10n, place.source),
              span: true,
            ),
          ],
        ),
      ),
    );
  }
}
