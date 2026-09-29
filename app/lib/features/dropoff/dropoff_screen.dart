import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/models/models.dart';
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/permission_service.dart';
import '../../core/state/core_providers.dart';
import '../../core/state/dropoff_controller.dart';
import '../../core/state/location_resolver.dart';
import '../../l10n/l10n.dart';
import 'external_links.dart';
import 'place_details_sheet.dart';
import 'place_info.dart';
import 'places_list.dart';
import 'places_map.dart';
import 'places_plot.dart';
import 'search_location.dart';

/// Drop-off tab (`/dropoff`): drop-off points near the user for the chosen
/// materials, as a list with a drawn plot of where they are, or on a map
/// when the Maps key is configured.
///
/// Every state is designed: asking where to search (with the location
/// rationale inline, and Settings when location is blocked), searching,
/// results, no places within the radius, a type filter that hides
/// everything, errors with a retry, and filter chips that failed to load
/// while the results still did.
class DropoffScreen extends ConsumerStatefulWidget {
  const DropoffScreen({
    super.key,
    this.mapAvailable,
    this.mapBuilder = googlePlacesMap,
  });

  /// Overrides [DropoffState.mapAvailable], a build flag (tests).
  final bool? mapAvailable;

  /// Draws the map view; tests pass a stand-in for the platform view.
  final PlacesMapBuilder mapBuilder;

  @override
  ConsumerState<DropoffScreen> createState() => _DropoffScreenState();
}

class _DropoffScreenState extends ConsumerState<DropoffScreen>
    with WidgetsBindingObserver {
  static const double _sheetMin = 0.24;
  static const double _sheetInitial = 0.44;

  /// The location permission, checked while a search location is needed so
  /// the panel can offer Settings once the system stops asking.
  PermissionState? _permission;
  ProviderSubscription<bool>? _needsLocation;

  /// Chip order: selected categories first, fixed until the selection
  /// changes from outside this screen (so chips do not jump under a tap).
  List<String> _chipOrder = const [];
  List<String> _orderedCatalog = const [];
  Set<String> _orderedSelection = const {};
  bool _selfToggled = false;

  /// The user deselected every category (as opposed to the controller not
  /// having picked the starting ones yet, which shows the loading rows).
  bool _clearedAll = false;

  /// How much of the map the places sheet covers, so the map keeps the
  /// camera and the Google logo in the part that is still visible.
  double _sheetExtent = _sheetInitial;

  DropoffController get _controller =>
      ref.read(dropoffControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _needsLocation = ref.listenManual(
      dropoffControllerProvider.select((s) => s.needsLocation),
      (previous, next) {
        if (next) unawaited(_checkPermission());
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _needsLocation?.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from the system Settings: search if location is now allowed.
    if (state == AppLifecycleState.resumed &&
        ref.read(dropoffControllerProvider).needsLocation) {
      unawaited(_checkPermission(searchIfGranted: true));
    }
  }

  Future<void> _checkPermission({bool searchIfGranted = false}) async {
    final PermissionState status;
    try {
      status = await ref
          .read(permissionServiceProvider)
          .status(AppPermission.location);
    } on Object {
      return;
    }
    if (!mounted) return;
    setState(() => _permission = status);
    if (searchIfGranted && status == PermissionState.granted) {
      await _controller.useMyLocation();
    }
  }

  bool get _locationBlocked =>
      _permission == PermissionState.permanentlyDenied ||
      _permission == PermissionState.restricted;

  // ------------------------------------------------------------ actions

  void _snack(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  /// Asks for location (the system dialog; this screen's panel or the
  /// "Search near" sheet is the rationale), then searches around the user.
  Future<void> _useMyLocation() async {
    final l10n = context.l10n;
    final permissions = ref.read(permissionServiceProvider);
    PermissionState status;
    try {
      status = await permissions.status(AppPermission.location);
      if (status == PermissionState.denied) {
        status = await permissions.request(AppPermission.location);
      }
    } on Object {
      status = PermissionState.denied;
    }
    if (!mounted) return;
    setState(() => _permission = status);
    switch (status) {
      case PermissionState.granted:
        await _controller.useMyLocation();
      case PermissionState.denied:
        _snack(l10n.dropoffLocationDenied);
      case PermissionState.permanentlyDenied || PermissionState.restricted:
        // The panel offers Settings itself; elsewhere, a snackbar does.
        if (!ref.read(dropoffControllerProvider).needsLocation) {
          _snack(
            l10n.dropoffLocationBlockedSnack,
            action: SnackBarAction(
              label: l10n.commonOpenSettings,
              onPressed: _openSettings,
            ),
          );
        }
    }
  }

  void _openSettings() =>
      unawaited(ref.read(permissionServiceProvider).openSettings());

  Future<void> _chooseLocation() async {
    final choice = await showSearchLocationSheet(
      context,
      vocab: ref.read(vocabProvider),
      current: ref.read(dropoffControllerProvider).location,
    );
    if (choice == null || !mounted) return;
    if (choice.city case final city?) {
      await _controller.useCity(city);
    } else {
      await _useMyLocation();
    }
  }

  void _toggleCategory(String key) {
    _selfToggled = true;
    final selected = ref.read(dropoffControllerProvider).selectedCategories;
    _clearedAll = selected.length == 1 && selected.contains(key);
    unawaited(_controller.toggleCategory(key));
  }

  Future<void> _openLink(Uri? uri) async {
    if (uri == null) return;
    final opened = await ref.read(externalLinkOpenerProvider)(uri);
    if (!opened && mounted) _snack(context.l10n.dropoffOpenFailed);
  }

  Future<void> _openPlace(Place place, _SearchContext where) async {
    _controller.selectPlace(place.id);
    final vocab = ref.read(vocabProvider);
    await showKanzSheet<void>(
      context: context,
      builder: (context) => PlaceDetailsSheet(
        place: place,
        vocab: vocab,
        origin: where.origin,
        cityName: where.cityName,
        onDirections: place.mapsUrl == null
            ? null
            : () => _openLink(Uri.tryParse(place.mapsUrl!)),
        onCall: place.phone == null || place.phone!.isEmpty
            ? null
            : () => _openLink(phoneUri(place.phone!)),
        onWebsite: place.website == null
            ? null
            : switch (websiteUri(place.website!)) {
                final uri? => () => _openLink(uri),
                null => null,
              },
      ),
    );
    if (mounted) _controller.selectPlace(null);
  }

  Future<void> _openTypeFilter() => showKanzSheet<void>(
    context: context,
    builder: (context) => FacilityTypeSheet(vocab: ref.read(vocabProvider)),
  );

  // ------------------------------------------------------------- pieces

  List<FacilityCategory> _orderedChips(DropoffState state) {
    final catalogKeys = [for (final c in state.catalog) c.key];
    final selection = state.selectedCategories;
    final catalogChanged = !listEquals(catalogKeys, _orderedCatalog);
    final selectionChanged = !setEquals(selection, _orderedSelection);
    if (catalogChanged || (selectionChanged && !_selfToggled)) {
      _chipOrder = [
        ...catalogKeys.where(selection.contains),
        ...catalogKeys.where((k) => !selection.contains(k)),
      ];
      _orderedCatalog = catalogKeys;
    }
    _orderedSelection = selection;
    _selfToggled = false;
    final byKey = {for (final c in state.catalog) c.key: c};
    return [for (final k in _chipOrder) ?byKey[k]];
  }

  _SearchContext _searchContext(DropoffState state, Vocab vocab) {
    final locale = Localizations.localeOf(context);
    final location = state.location;
    final city = location?.city;
    final cityName =
        location?.source == SearchLocationSource.gps || city == null
        ? null
        : vocab.city(city).label.forLocale(locale);
    return _SearchContext(
      origin: state.results?.center,
      cityName: cityName,
      gps: location?.source == SearchLocationSource.gps,
    );
  }

  /// Width of the list and map toggle: two equal segments, each fitting the
  /// wider label with its glyph and 10 dp on both sides, in the sunken
  /// track. Sized to the words rather than fixed, so the short Arabic
  /// labels sit beside the title on a 360 dp phone too.
  double _toggleWidth(List<String> labels) {
    const glyph = 18.0 + 6.0;
    const side = KanzSpace.s8 + KanzSpace.s2;
    final style = context.textStyles.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );
    var widest = 0.0;
    for (final label in labels) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      if (painter.width > widest) widest = painter.width;
      painter.dispose();
    }
    final segment = (widest + glyph + 2 * side).ceilToDouble();
    return labels.length * segment + 2 * KanzSpace.s4;
  }

  /// The title, and the list and map toggle at the end of its line; with
  /// large text the toggle moves under the title rather than squeezing it
  /// onto two lines.
  Widget _header(DropoffState state, bool mapAvailable) {
    final l10n = context.l10n;
    final toggleLabels = [l10n.dropoffViewList, l10n.dropoffViewMap];
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s12,
        KanzSpace.gutter,
        KanzSpace.s8,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: KanzSpace.s12,
        runSpacing: KanzSpace.s12,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.dropoffTitle,
              style: context.textStyles.headlineLarge,
            ),
          ),
          if (mapAvailable)
            SizedBox(
              width: _toggleWidth(toggleLabels),
              child: SegmentedTabs(
                tabs: [
                  SegmentedTab(label: toggleLabels[0], icon: KanzIcons.list),
                  SegmentedTab(label: toggleLabels[1], icon: KanzIcons.map),
                ],
                selectedIndex: state.view.index,
                onChanged: (i) => _controller.setView(DropoffView.values[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _locationBar(DropoffState state, _SearchContext where) {
    final l10n = context.l10n;
    final location = state.location;
    final label = switch (location) {
      null => l10n.dropoffLocating,
      _ when where.gps => l10n.dropoffNearYou,
      _ => l10n.dropoffNearCity(where.cityName ?? ''),
    };
    return SearchLocationBar(
      label: label,
      gps: where.gps,
      note: location?.source == SearchLocationSource.nearestCity
          ? l10n.dropoffApproximate(where.cityName ?? '')
          : null,
      changeLabel: l10n.dropoffChangeLocation,
      changeHint: l10n.dropoffChangeLocationHint,
      onChange: _chooseLocation,
    );
  }

  Widget _chips(DropoffState state) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    if (state.catalog.isEmpty) {
      if (state.catalogError != null) {
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            KanzSpace.gutter,
            0,
            KanzSpace.s8,
            0,
          ),
          child: Semantics(
            liveRegion: true,
            child: Row(
              children: [
                Icon(KanzIcons.warning, size: 16, color: c.caution),
                const SizedBox(width: KanzSpace.s8),
                Expanded(
                  child: Text(
                    l10n.dropoffCatalogError,
                    style: context.textStyles.bodySmall,
                  ),
                ),
                KanzButton.tertiary(
                  label: l10n.commonRetry,
                  icon: KanzIcons.retry,
                  onPressed: state.catalogLoading
                      ? null
                      : () => unawaited(_controller.loadCatalog()),
                ),
              ],
            ),
          ),
        );
      }
      return const Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          KanzSpace.gutter,
          KanzSpace.s8,
          KanzSpace.gutter,
          KanzSpace.s8,
        ),
        child: Row(
          spacing: KanzSpace.s8,
          children: [
            Skeleton(width: 120, height: 32, borderRadius: KanzRadii.chipAll),
            Skeleton(width: 132, height: 32, borderRadius: KanzRadii.chipAll),
            Expanded(
              child: Skeleton(height: 32, borderRadius: KanzRadii.chipAll),
            ),
          ],
        ),
      );
    }
    return Semantics(
      container: true,
      label: l10n.dropoffCategoriesLabel,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: KanzSpace.page,
        child: Row(
          spacing: KanzSpace.s8,
          children: [
            for (final category in _orderedChips(state))
              KanzChip(
                key: ValueKey('category-${category.key}'),
                label: category.label,
                materialId: category.materialCategories.length == 1
                    ? category.materialCategories.first.id
                    : null,
                icon: category.materialCategories.length == 1
                    ? null
                    : KanzIcons.recycle,
                selected: state.selectedCategories.contains(category.key),
                onSelected: (_) => _toggleCategory(category.key),
              ),
          ],
        ),
      ),
    );
  }

  String? _filterLabel(DropoffState state, Vocab vocab) {
    final l10n = context.l10n;
    final types = facilityTypeCounts(state.results?.places ?? const []);
    if (types.length < 2 && state.typeFilter.isEmpty) return null;
    return switch (state.typeFilter.length) {
      0 => l10n.dropoffTypeAll,
      1 => facilityTypeLabel(
        vocab,
        Localizations.localeOf(context),
        state.typeFilter.first,
      ),
      final n => l10n.dropoffTypeCount(n),
    };
  }

  String _searchingLabel(_SearchContext where) {
    final l10n = context.l10n;
    if (where.gps) return l10n.dropoffSearchingNearYou;
    if (where.cityName case final city?) return l10n.dropoffSearchingNear(city);
    return l10n.dropoffSearching;
  }

  ResultsBar _resultsBar(
    DropoffState state,
    Vocab vocab,
    _SearchContext where,
  ) {
    final l10n = context.l10n;
    return ResultsBar(
      summary: [
        l10n.dropoffPlaceCount(state.visiblePlaces.length),
        l10n.dropoffWithinKm(dropoffRadiusKm),
      ],
      searching: state.searching,
      searchingLabel: _searchingLabel(where),
      filterLabel: _filterLabel(state, vocab),
      filterHint: l10n.dropoffTypeFilterHint,
      onFilter: _openTypeFilter,
    );
  }

  /// Each place's mark, colored by the accepted materials that match the
  /// selected chips.
  Map<String, PinMark> _pinMarks(DropoffState state) {
    final catalog = {for (final c in state.catalog) c.key: c};
    final selected = selectedMaterialIds(state.selectedCategories, catalog);
    return {
      for (final p in state.visiblePlaces)
        p.id: pinMarkOf(p, catalog, selected: selected),
    };
  }

  String _ringLabel(double km) => context.l10n.commonDistanceKm(
    km == km.roundToDouble() ? '${km.round()}' : km.toStringAsFixed(1),
  );

  Widget _plot(DropoffState state, _SearchContext where) {
    final l10n = context.l10n;
    final results = state.results!;
    final places = state.visiblePlaces;
    final nearest = places.first.distanceM;
    final centreName = where.gps
        ? l10n.dropoffPlotYou
        : l10n.dropoffPlotCentreOf(where.cityName ?? results.centerLabel);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s8,
        KanzSpace.gutter,
        KanzSpace.s8,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.kanzColors.surface,
          borderRadius: KanzRadii.cardAll,
          border: Border.all(color: context.kanzColors.line),
        ),
        child: ClipRRect(
          borderRadius: KanzRadii.cardAll,
          child: PlacesPlot(
            center: results.center,
            places: places,
            pinMarks: _pinMarks(state),
            selectedId: state.selectedPlaceId,
            centerLabel: centreName,
            northLabel: l10n.dropoffPlotNorth,
            ringsLabel: (km) => l10n.dropoffPlotRings(_ringLabel(km)),
            listedLabel: l10n.dropoffPlotListed,
            unlistedLabel: l10n.dropoffPlotUnlisted,
            semanticsLabel: l10n.dropoffPlotLabel(
              places.length,
              results.centerLabel,
              nearest == null ? '' : formatDistance(l10n, nearest),
            ),
            onPinTap: (place) => _openPlace(place, where),
          ),
        ),
      ),
    );
  }

  Widget _row(
    DropoffState state,
    Vocab vocab,
    _SearchContext where,
    int index,
  ) {
    final places = state.visiblePlaces;
    final place = places[index];
    return FadeUp.staggered(
      key: ValueKey('place-${identityHashCode(state.results)}-${place.id}'),
      index: index,
      child: PlaceListRow(
        place: place,
        vocab: vocab,
        origin: where.origin,
        cityName: where.cityName,
        selected: place.id == state.selectedPlaceId,
        divider: index < places.length - 1,
        onTap: () => _openPlace(place, where),
        onDirections: place.mapsUrl == null
            ? null
            : () => _openLink(Uri.tryParse(place.mapsUrl!)),
      ),
    );
  }

  /// Everything below the chips in the list layout, as slivers.
  List<Widget> _body(
    DropoffState state,
    Vocab vocab,
    _SearchContext where,
    bool mapAvailable,
  ) {
    final l10n = context.l10n;
    final results = state.results;
    Widget box(Widget child) => SliverToBoxAdapter(child: child);

    if (state.needsLocation) {
      final blocked = _locationBlocked;
      return [
        box(
          Padding(
            padding: const EdgeInsetsDirectional.only(
              top: KanzSpace.s8,
              bottom: KanzSpace.s32,
            ),
            child: PermissionRationale(
              art: PermissionArt.location,
              title: blocked
                  ? l10n.dropoffLocationBlockedTitle
                  : l10n.dropoffLocationTitle,
              reasons: blocked
                  ? [
                      RationaleReason(
                        icon: KanzIcons.settings,
                        text: l10n.dropoffLocationBlockedReason,
                      ),
                      RationaleReason(
                        icon: KanzIcons.map,
                        text: l10n.dropoffLocationBlockedCity,
                      ),
                    ]
                  : [
                      RationaleReason(
                        icon: KanzIcons.dropOff,
                        text: l10n.dropoffLocationReasonDistance,
                      ),
                      RationaleReason(
                        icon: KanzIcons.safety,
                        text: l10n.dropoffLocationReasonHazard,
                      ),
                    ],
              primaryLabel: blocked
                  ? l10n.commonOpenSettings
                  : l10n.dropoffLocationAllow,
              onPrimary: blocked ? _openSettings : _useMyLocation,
              secondaryLabel: l10n.dropoffLocationPickCity,
              onSecondary: _chooseLocation,
              footnote: l10n.dropoffLocationFootnote,
            ),
          ),
        ),
      ];
    }

    if (state.selectedCategories.isEmpty && !state.searching && _clearedAll) {
      return [
        box(
          EmptyState(
            icon: KanzIcons.filters,
            title: l10n.dropoffNoCategoryTitle,
            message: l10n.dropoffNoCategoryMessage,
          ),
        ),
      ];
    }

    if (state.error case final error?) {
      final offline = error.code == ApiErrorCode.offline;
      return [
        box(
          ErrorState(
            icon: offline ? KanzIcons.noWifi : KanzIcons.error,
            title: offline ? l10n.dropoffOfflineTitle : l10n.dropoffErrorTitle,
            message: apiErrorMessage(l10n, error),
            retryLabel: l10n.commonRetry,
            onRetry: error.retryable && !state.searching
                ? () => unawaited(_controller.search())
                : null,
            code: offline ? null : errorSupportCode(error),
            codeLabel: l10n.commonSupportCode,
          ),
        ),
      ];
    }

    if (results == null) {
      return [
        box(
          PlaceSkeletonList(
            label: _searchingLabel(where),
            withPlot: !mapAvailable,
          ),
        ),
      ];
    }

    if (results.places.isEmpty) {
      return [
        box(
          EmptyState(
            icon: KanzIcons.dropOff,
            title: l10n.dropoffEmptyTitle(dropoffRadiusKm),
            message: l10n.dropoffEmptyMessage(
              where.cityName ?? results.centerLabel,
            ),
            actionLabel: l10n.dropoffEmptyAction,
            actionIcon: KanzIcons.map,
            onAction: _chooseLocation,
          ),
        ),
      ];
    }

    final places = state.visiblePlaces;
    return [
      if (!mapAvailable && places.isNotEmpty) box(_plot(state, where)),
      box(_resultsBar(state, vocab, where)),
      if (places.isEmpty)
        box(
          EmptyState(
            icon: KanzIcons.filters,
            title: l10n.dropoffTypeEmptyTitle,
            message: l10n.dropoffTypeEmptyMessage,
            actionLabel: l10n.dropoffTypeShowAll,
            actionIcon: KanzIcons.filters,
            onAction: _controller.clearTypes,
          ),
        )
      else ...[
        SliverToBoxAdapter(
          child: Divider(height: 1, color: context.kanzColors.line),
        ),
        SliverOpacity(
          opacity: state.searching ? 0.45 : 1,
          sliver: SliverList.builder(
            itemCount: places.length,
            itemBuilder: (context, i) => _row(state, vocab, where, i),
          ),
        ),
        SliverToBoxAdapter(
          child: Divider(height: 1, color: context.kanzColors.line),
        ),
      ],
      box(PlacesSourcesFooter(results: results)),
    ];
  }

  Widget _listLayout(
    DropoffState state,
    Vocab vocab,
    _SearchContext where,
    bool mapAvailable,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _header(state, mapAvailable)),
        if (!state.needsLocation) ...[
          SliverToBoxAdapter(child: _locationBar(state, where)),
          SliverToBoxAdapter(child: _chips(state)),
          const SliverToBoxAdapter(child: SizedBox(height: KanzSpace.s8)),
        ],
        ..._body(state, vocab, where, mapAvailable),
      ],
    );
  }

  Widget _mapLayout(DropoffState state, Vocab vocab, _SearchContext where) {
    final c = context.kanzColors;
    final l10n = context.l10n;
    final results = state.results!;
    final places = state.visiblePlaces;
    final pinMarks = _pinMarks(state);
    // What the marks on the map mean, under the sheet's handle.
    final key = placeMarkKeyEntries(
      context,
      places: places,
      pinMarks: pinMarks,
      listedLabel: l10n.dropoffPlotListed,
      unlistedLabel: l10n.dropoffPlotUnlisted,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(state, true),
        _locationBar(state, where),
        _chips(state),
        const SizedBox(height: KanzSpace.s8),
        Divider(height: 1, color: c.line),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) => Stack(
              children: [
                Positioned.fill(
                  child: widget.mapBuilder(
                    context,
                    PlacesMapSpec(
                      places: places,
                      center: results.center,
                      pinMarks: pinMarks,
                      selectedId: state.selectedPlaceId,
                      bottomPadding:
                          box.maxHeight * _sheetExtent.clamp(_sheetMin, 0.6),
                      showMyLocation: where.gps,
                      semanticsLabel: l10n.dropoffPlotLabel(
                        places.length,
                        results.centerLabel,
                        places.first.distanceM == null
                            ? ''
                            : formatDistance(l10n, places.first.distanceM!),
                      ),
                      onPinTap: (place) => _openPlace(place, where),
                    ),
                  ),
                ),
                NotificationListener<DraggableScrollableNotification>(
                  onNotification: (n) {
                    // Coarse steps: the map re-lays out on each change.
                    if ((n.extent - _sheetExtent).abs() > 0.04) {
                      setState(() => _sheetExtent = n.extent);
                    }
                    return false;
                  },
                  child: DraggableScrollableSheet(
                    initialChildSize: _sheetInitial,
                    minChildSize: _sheetMin,
                    snap: true,
                    snapSizes: const [_sheetInitial],
                    builder: (context, scroll) => DecoratedBox(
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: KanzRadii.sheetTop,
                        boxShadow: KanzElevation.floating(c),
                      ),
                      child: ClipRRect(
                        borderRadius: KanzRadii.sheetTop,
                        child: CustomScrollView(
                          controller: scroll,
                          slivers: [
                            SliverToBoxAdapter(
                              child: Center(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    top: KanzSpace.s12,
                                    bottom: KanzSpace.s4,
                                  ),
                                  width: 36,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: c.lineStrong,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (key.isNotEmpty)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                    KanzSpace.gutter,
                                    KanzSpace.s8,
                                    KanzSpace.gutter,
                                    0,
                                  ),
                                  child: Wrap(
                                    spacing: KanzSpace.s16,
                                    runSpacing: KanzSpace.s4,
                                    children: key,
                                  ),
                                ),
                              ),
                            SliverToBoxAdapter(
                              child: _resultsBar(state, vocab, where),
                            ),
                            SliverToBoxAdapter(
                              child: Divider(height: 1, color: c.line),
                            ),
                            SliverOpacity(
                              opacity: state.searching ? 0.45 : 1,
                              sliver: SliverList.builder(
                                itemCount: places.length,
                                itemBuilder: (context, i) =>
                                    _row(state, vocab, where, i),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: PlacesSourcesFooter(results: results),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dropoffControllerProvider);
    final vocab = ref.watch(vocabProvider);
    final mapAvailable = widget.mapAvailable ?? state.mapAvailable;
    final where = _searchContext(state, vocab);
    final showMap =
        mapAvailable &&
        state.view == DropoffView.map &&
        !state.needsLocation &&
        state.error == null &&
        state.results != null &&
        state.visiblePlaces.isNotEmpty;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: showMap
            ? _mapLayout(state, vocab, where)
            : _listLayout(state, vocab, where, mapAvailable),
      ),
    );
  }
}

/// Where the current results were searched, resolved for display.
@immutable
class _SearchContext {
  const _SearchContext({
    required this.origin,
    required this.cityName,
    required this.gps,
  });

  /// The search centre, for compass directions.
  final GeoPoint? origin;

  /// The city searched around, or null for the user's own location.
  final String? cityName;
  final bool gps;
}
