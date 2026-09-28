import 'package:flutter/material.dart';

import '../../../core/data/models/models.dart';
import '../../../core/design/design.dart' hide PipelineStage;
import '../../../core/state/location_resolver.dart';
import '../../../core/state/scan_session.dart';
import '../../../l10n/l10n.dart';
import '../results_format.dart';

/// "Drop-off near you": the three nearest places for what was scanned, with
/// directions, visible without a tap. It asks where to look when no location
/// is set, and says plainly when there is nothing to find.
class DropoffSection extends StatelessWidget {
  const DropoffSection({
    super.key,
    required this.session,
    required this.format,
    required this.onSeeAll,
    required this.onDirections,
    required this.onUseMyLocation,
    required this.onChooseCity,
    required this.onRetry,
    this.locationOff = false,
  });

  /// How many places the section shows; the Drop-off tab has the rest.
  static const int shown = 3;

  final ScanSessionState session;
  final ResultsFormat format;
  final VoidCallback onSeeAll;
  final ValueChanged<Place> onDirections;
  final VoidCallback onUseMyLocation;
  final VoidCallback onChooseCity;
  final VoidCallback onRetry;

  /// The user declined location: say so on the location card.
  final bool locationOff;

  String? _where(AppLocalizations l10n) {
    final location = session.dropoffLocation;
    if (location == null) return null;
    final city = location.city;
    return switch (location.source) {
      SearchLocationSource.gps => l10n.resultsNearYou,
      SearchLocationSource.city when city != null => l10n.resultsInCity(
        format.city(city),
      ),
      SearchLocationSource.nearestCity when city != null =>
        l10n.resultsAroundCity(format.city(city)),
      _ => session.facilities?.centerLabel,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stage = session.stage(PipelineStage.dropoff);
    final places = session.facilities?.places ?? const <Place>[];
    final canSeeAll =
        session.recommendation?.facilityCategories.isNotEmpty ?? false;

    final Widget body = switch (stage.status) {
      StageStatus.pending => _Note(text: l10n.resultsDropoffWaiting),
      StageStatus.running => _PlacesSkeleton(
        label: stageLabel(l10n, PipelineStage.dropoff),
      ),
      StageStatus.needsLocation => Padding(
        padding: KanzSpace.page,
        child: _LocationCard(
          locationOff: locationOff,
          onUseMyLocation: onUseMyLocation,
          onChooseCity: onChooseCity,
        ),
      ),
      StageStatus.skipped => _Note(text: l10n.resultsStageNoDropoff),
      StageStatus.failed => ErrorState(
        icon: stage.error?.isOffline ?? false
            ? KanzIcons.noWifi
            : KanzIcons.error,
        title: l10n.resultsDropoffErrorTitle,
        message: apiErrorMessage(l10n, stage.error),
        retryLabel: l10n.commonRetry,
        onRetry: (stage.error?.retryable ?? true) ? onRetry : null,
      ),
      StageStatus.done when places.isEmpty => EmptyState(
        icon: KanzIcons.dropOff,
        title: l10n.resultsNoPlacesTitle,
        message: l10n.resultsNoPlacesBody,
        actionLabel: canSeeAll ? l10n.resultsOpenDropoff : null,
        onAction: canSeeAll ? onSeeAll : null,
      ),
      StageStatus.done => _PlaceList(
        places: places.take(shown).toList(),
        response: session.facilities!,
        format: format,
        onDirections: onDirections,
      ),
    };

    final showSeeAll = canSeeAll && stage.isDone && places.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.resultsDropoffTitle,
          subtitle: stage.isDone ? _where(l10n) : null,
          action: showSeeAll
              ? KanzButton.tertiary(
                  label: l10n.resultsSeeAll,
                  trailingIcon: KanzIcons.chevronForward,
                  onPressed: onSeeAll,
                )
              : null,
        ),
        const SizedBox(height: KanzSpace.s12),
        body,
      ],
    );
  }
}

class _PlaceList extends StatelessWidget {
  const _PlaceList({
    required this.places,
    required this.response,
    required this.format,
    required this.onDirections,
  });

  final List<Place> places;
  final FacilitiesResponse response;
  final ResultsFormat format;
  final ValueChanged<Place> onDirections;

  String _attribution(AppLocalizations l10n) {
    final names = [
      for (final s in response.sourcesUsed)
        switch (s) {
          PlaceSource.osm => l10n.resultsSourceOsm,
          PlaceSource.google => l10n.resultsSourceGoogle,
          PlaceSource.curated => l10n.resultsSourceCurated,
        },
    ];
    return l10n.resultsAttribution(format.list(names));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (response.notice case final notice? when notice.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              KanzSpace.gutter,
              0,
              KanzSpace.gutter,
              KanzSpace.s12,
            ),
            child: Callout(
              variant: CalloutVariant.tip,
              title: l10n.resultsBeforeYouGo,
              message: notice,
            ),
          ),
        Divider(height: 1, color: c.line),
        for (var i = 0; i < places.length; i++)
          FadeUp.staggered(index: i, child: _row(context, places[i])),
        if (response.sourcesUsed.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              KanzSpace.gutter,
              KanzSpace.s12,
              KanzSpace.gutter,
              0,
            ),
            child: Text(_attribution(l10n), style: t.bodySmall),
          ),
      ],
    );
  }

  Widget _row(BuildContext context, Place place) {
    final l10n = context.l10n;
    final materials = place.acceptedMaterials ?? const <MaterialCategory>[];
    final open = switch (place.openNow) {
      true => (OpenState.open, l10n.resultsOpenNow),
      false => (OpenState.closed, l10n.resultsClosedNow),
      null => (OpenState.unknown, l10n.resultsHoursUnknown),
    };
    return PlaceRow(
      name: place.name,
      distance: place.distanceM == null
          ? ''
          : formatDistance(l10n, place.distanceM!),
      openState: open.$1,
      openLabel: open.$2,
      materialIds: [for (final m in materials) m.id],
      materialsLabel: materials.isEmpty
          ? null
          : l10n.resultsAccepts(
              format.list([for (final m in materials) format.category(m)]),
            ),
      address: place.address,
      typeLabel: place.facilityTypes.isEmpty
          ? null
          : format.facilityType(place.facilityTypes.first),
      directionsLabel: l10n.resultsDirections(place.name),
      onDirections: place.mapsUrl == null ? null : () => onDirections(place),
    );
  }
}

/// Asks where to look: the phone's location or a chosen city.
class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.locationOff,
    required this.onUseMyLocation,
    required this.onChooseCity,
  });

  final bool locationOff;
  final VoidCallback onUseMyLocation;
  final VoidCallback onChooseCity;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    return KanzCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(KanzIcons.locate, size: 22, color: c.ink),
              const SizedBox(width: KanzSpace.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.resultsNeedsLocationTitle,
                        style: t.titleMedium,
                      ),
                    ),
                    const SizedBox(height: KanzSpace.s4),
                    Semantics(
                      liveRegion: locationOff,
                      child: Text(
                        locationOff
                            ? l10n.resultsLocationOff
                            : l10n.resultsNeedsLocationBody,
                        style: t.bodyMedium?.copyWith(color: c.inkSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: KanzSpace.s16),
          if (!locationOff) ...[
            KanzButton(
              label: l10n.resultsUseMyLocation,
              icon: KanzIcons.locate,
              onPressed: onUseMyLocation,
              expand: true,
            ),
            const SizedBox(height: KanzSpace.s8),
          ],
          KanzButton.secondary(
            label: l10n.resultsChooseCity,
            icon: KanzIcons.map,
            onPressed: onChooseCity,
            expand: true,
          ),
        ],
      ),
    );
  }
}

/// A quiet sentence in place of the list.
class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: KanzSpace.page,
      child: Text(
        text,
        style: context.textStyles.bodyMedium?.copyWith(
          color: context.kanzColors.inkSecondary,
        ),
      ),
    );
  }
}

/// Three place rows while the search runs, with the stage named above them.
class _PlacesSkeleton extends StatelessWidget {
  const _PlacesSkeleton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    Widget row() => Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s16,
        KanzSpace.gutter,
        KanzSpace.s16,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.line)),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 0.6,
                  child: Skeleton(height: 16),
                ),
                SizedBox(height: KanzSpace.s8),
                FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 0.8,
                  child: Skeleton(height: 12),
                ),
                SizedBox(height: KanzSpace.s12),
                Skeleton(width: 88, height: 10),
              ],
            ),
          ),
          SizedBox(width: KanzSpace.s16),
          Skeleton(width: 40, height: 12),
        ],
      ),
    );
    return Semantics(
      liveRegion: true,
      label: label,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                KanzSpace.gutter,
                0,
                KanzSpace.gutter,
                KanzSpace.s12,
              ),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 12,
                    child: context.reduceMotion
                        ? Icon(KanzIcons.clock, size: 12, color: c.inkSecondary)
                        : CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: c.inkSecondary,
                          ),
                  ),
                  const SizedBox(width: KanzSpace.s8),
                  Flexible(child: MonoLabel(label)),
                ],
              ),
            ),
            Divider(height: 1, color: c.line),
            row(),
            row(),
            row(),
          ],
        ),
      ),
    );
  }
}
