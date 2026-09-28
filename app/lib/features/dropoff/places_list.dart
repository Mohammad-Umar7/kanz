import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/models/models.dart';
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
import '../../core/state/dropoff_controller.dart';
import '../../l10n/l10n.dart';
import 'place_info.dart';

/// The line above the list: how many places and how far, a live progress
/// note while a new search runs, and the facility-type filter.
class ResultsBar extends StatelessWidget {
  const ResultsBar({
    super.key,
    required this.summary,
    required this.searching,
    required this.searchingLabel,
    this.filterLabel,
    this.filterHint,
    this.onFilter,
  });

  /// "12 places", "within 15 km": one line "12 PLACES · WITHIN 15 KM"
  /// when it fits, else one part per line, never broken mid-phrase.
  final List<String> summary;
  final bool searching;
  final String searchingLabel;

  /// "All types", "Recycling center" or "2 types"; null hides the filter.
  final String? filterLabel;
  final String? filterHint;
  final VoidCallback? onFilter;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s4,
        KanzSpace.s8,
        KanzSpace.s4,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: KanzSpace.touchTarget),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: AnimatedSwitcher(
                  duration: KanzMotion.of(context, KanzMotion.fast),
                  child: searching
                      ? Row(
                          key: const ValueKey('searching'),
                          children: [
                            SizedBox.square(
                              dimension: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: c.inkSecondary,
                              ),
                            ),
                            const SizedBox(width: KanzSpace.s8),
                            Flexible(child: MonoLabel(searchingLabel)),
                          ],
                        )
                      : Align(
                          key: const ValueKey('summary'),
                          alignment: AlignmentDirectional.centerStart,
                          child: _Summary(parts: summary),
                        ),
                ),
              ),
            ),
            if (filterLabel != null) ...[
              const SizedBox(width: KanzSpace.s8),
              Semantics(
                hint: filterHint,
                child: KanzButton.tertiary(
                  label: filterLabel!,
                  icon: KanzIcons.filters,
                  onPressed: onFilter,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The results summary: the parts joined with " · " on one line when they
/// fit, else stacked one per line without separators, so no line starts
/// or ends on a dot (large text, a long filter label).
class _Summary extends StatelessWidget {
  const _Summary({required this.parts});

  final List<String> parts;

  @override
  Widget build(BuildContext context) {
    final line = parts.join(' · ');
    return LayoutBuilder(
      builder: (context, constraints) {
        final type = context.kanzType;
        final painter = TextPainter(
          text: TextSpan(
            text: type.uppercaseData ? line.toUpperCase() : line,
            style: type.data,
          ),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        final fits = painter.width <= constraints.maxWidth;
        painter.dispose();
        if (fits) return MonoLabel(line);
        return MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [for (final part in parts) MonoLabel(part)],
          ),
        );
      },
    );
  }
}

/// A [PlaceRow] for a [Place]: type and address (or its compass direction
/// from the search centre when the listing has no address), distance, the
/// materials it is known to accept and, when the listing has them, its
/// opening hours (most OpenStreetMap points have none, and "Hours not
/// listed" on every row would only repeat itself; the details say it).
class PlaceListRow extends StatelessWidget {
  const PlaceListRow({
    super.key,
    required this.place,
    required this.vocab,
    required this.origin,
    required this.cityName,
    required this.selected,
    required this.divider,
    required this.onTap,
    required this.onDirections,
  });

  final Place place;
  final Vocab vocab;
  final GeoPoint? origin;
  final String? cityName;
  final bool selected;
  final bool divider;
  final VoidCallback onTap;
  final VoidCallback? onDirections;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final open = openStateOf(place);
    final address = place.address;
    return PlaceRow(
      name: place.name,
      distance: place.distanceM == null
          ? ''
          : formatDistance(l10n, place.distanceM!),
      openState: open,
      openLabel: openLabel(l10n, open),
      materialIds: [
        for (final m in place.acceptedMaterials ?? const <MaterialCategory>[])
          m.id,
      ],
      materialsLabel: acceptsLabel(l10n, vocab, locale, place),
      typeLabel: placeTypeLabel(l10n, vocab, locale, place),
      address: address != null && address.isNotEmpty
          ? address
          : (origin == null
                ? null
                : directionLabel(l10n, origin!, place, cityName: cityName)),
      directionsLabel: l10n.dropoffDirectionsTo(place.name),
      hideUnknownHours: true,
      selected: selected,
      divider: divider,
      onTap: onTap,
      onDirections: onDirections,
    );
  }
}

/// Placeholder rows shaped like [PlaceRow], under a live line that says
/// where Kanz is searching.
class PlaceSkeletonList extends StatelessWidget {
  const PlaceSkeletonList({
    super.key,
    required this.label,
    this.rows = 4,
    this.withPlot = false,
  });

  final String label;
  final int rows;

  /// Also stand in for the places plot.
  final bool withPlot;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (withPlot)
          const Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              KanzSpace.gutter,
              KanzSpace.s8,
              KanzSpace.gutter,
              KanzSpace.s8,
            ),
            child: Skeleton(height: 188, borderRadius: KanzRadii.cardAll),
          ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            KanzSpace.gutter,
            KanzSpace.s4,
            KanzSpace.gutter,
            KanzSpace.s4,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: KanzSpace.touchTarget),
            child: Semantics(
              liveRegion: true,
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: c.inkSecondary,
                    ),
                  ),
                  const SizedBox(width: KanzSpace.s8),
                  Flexible(child: MonoLabel(label)),
                ],
              ),
            ),
          ),
        ),
        for (var i = 0; i < rows; i++)
          Container(
            padding: const EdgeInsetsDirectional.fromSTEB(
              KanzSpace.gutter,
              KanzSpace.s20,
              KanzSpace.gutter,
              KanzSpace.s20,
            ),
            decoration: BoxDecoration(
              border: i < rows - 1
                  ? Border(bottom: BorderSide(color: c.line))
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: FractionallySizedBox(
                                widthFactor: i.isEven ? 0.7 : 0.55,
                                child: const Skeleton(height: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: KanzSpace.s24),
                          const Skeleton(width: 40, height: 12),
                        ],
                      ),
                      const SizedBox(height: KanzSpace.s8),
                      const FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Skeleton(height: 12),
                      ),
                      const SizedBox(height: KanzSpace.s12),
                      const Skeleton(width: 96, height: 10),
                    ],
                  ),
                ),
                const SizedBox(width: KanzSpace.s24),
                const Skeleton(
                  width: 24,
                  height: 24,
                  borderRadius: KanzRadii.chipAll,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Where the places came from (their terms require attribution) and the
/// backend's note about data quality, if any.
class PlacesSourcesFooter extends StatelessWidget {
  const PlacesSourcesFooter({super.key, required this.results});

  final FacilitiesResponse results;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.textStyles;
    final sources = {
      for (final s in results.sourcesUsed) sourceAttribution(l10n, s),
    };
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s24,
        KanzSpace.gutter,
        KanzSpace.s32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoLabel(l10n.dropoffSourcesLabel),
          const SizedBox(height: KanzSpace.s4),
          if (sources.isNotEmpty) Text(sources.join(' · '), style: t.bodySmall),
          if (results.notice case final notice? when notice.isNotEmpty) ...[
            const SizedBox(height: KanzSpace.s8),
            Text(notice, style: t.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// The facility types present in [places] with how many places have each,
/// in vocabulary order.
List<({FacilityType type, int count})> facilityTypeCounts(List<Place> places) {
  final counts = <FacilityType, int>{};
  for (final p in places) {
    for (final t in p.facilityTypes.toSet()) {
      counts[t] = (counts[t] ?? 0) + 1;
    }
  }
  return [
    for (final t in FacilityType.values)
      if (counts[t] case final n?) (type: t, count: n),
  ];
}

/// "Type of place" sheet: one chip per facility type in the results, plus
/// "All types". Changes apply immediately (the list filters locally).
class FacilityTypeSheet extends ConsumerWidget {
  const FacilityTypeSheet({super.key, required this.vocab});

  final Vocab vocab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final state = ref.watch(dropoffControllerProvider);
    final controller = ref.read(dropoffControllerProvider.notifier);
    final types = facilityTypeCounts(state.results?.places ?? const []);
    return KanzSheet(
      title: l10n.dropoffTypeSheetTitle,
      subtitle: l10n.dropoffTypeSheetSubtitle,
      actions: [
        KanzButton(
          label: l10n.commonDone,
          onPressed: () => Navigator.of(context).pop(),
          expand: true,
        ),
      ],
      child: SingleChildScrollView(
        padding: KanzSpace.page,
        child: Wrap(
          spacing: KanzSpace.s8,
          children: [
            KanzChip(
              label: l10n.dropoffTypeAll,
              selected: state.typeFilter.isEmpty,
              onSelected: (_) => controller.clearTypes(),
            ),
            for (final entry in types)
              KanzChip(
                label: facilityTypeLabel(vocab, locale, entry.type),
                count: '${entry.count}',
                selected: state.typeFilter.contains(entry.type),
                onSelected: (_) => controller.toggleType(entry.type),
              ),
          ],
        ),
      ),
    );
  }
}
