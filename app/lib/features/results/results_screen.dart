import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/router.dart';
import '../../core/data/db/database.dart' show ImpactKind;
import '../../core/data/models/models.dart';
import '../../core/design/design.dart' hide PipelineStage;
import '../../core/services/permission_service.dart';
import '../../core/state/connectivity_providers.dart';
import '../../core/state/core_providers.dart';
import '../../core/state/dropoff_controller.dart';
import '../../core/state/scan_session.dart';
import '../../core/state/settings_providers.dart';
import '../../l10n/l10n.dart';
import '../permissions/city_picker_screen.dart' show CityPickerScreen;
import '../scan/scan_screen.dart' show scanPhotoHeroTag;
import 'results_format.dart';
import 'scan_images.dart';
import 'stage_clock.dart';
import 'widgets/dropoff_section.dart';
import 'widgets/item_edit_sheet.dart';
import 'widgets/paths_section.dart';
import 'widgets/pipeline_section.dart';
import 'widgets/results_header.dart';
import 'widgets/retake_panel.dart';
import 'widgets/specimen_section.dart';

/// Results (`/results/:scanId`): the photo with its detected items, the live
/// pipeline, what each item is made of, what it can become (upcycle,
/// recycle, donate, or safe disposal), and drop-off points nearby.
///
/// Everything comes from `scanSessionProvider(scanId)`, which runs the
/// stages on its own; this screen only shows them and passes the user's
/// choices back (retry, corrections, focus, marks, location).
class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key, required this.scanId});

  final String scanId;

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  final StageClock _clock = StageClock();
  final StableImages _images = StableImages();
  String? _selectedItemId;
  int _tab = 0;

  /// The user declined location from this screen: offer the city picker.
  bool _locationOff = false;

  /// Specimen cards by item id, to bring one into view from its box.
  final Map<String, GlobalKey> _cardKeys = {};

  /// The item whose card the carousel last scrolled to.
  String? _shownCardId;

  /// The last connection problem, kept while a re-check runs so the banner
  /// does not flicker away and back.
  BackendStatus? _problem;

  String get _id => widget.scanId;

  ScanSession get _session => ref.read(scanSessionProvider(_id).notifier);

  @override
  void initState() {
    super.initState();
    // A stage already running when the screen opens starts counting now.
    _clock.observe(ref.read(scanSessionProvider(_id)));
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  // ------------------------------------------------------------- actions

  /// A new scan in place of these results: its results then replace the
  /// scan page in turn, so back still returns to where the user started.
  void _rescan(ScanMode mode) => context.pushReplacement(AppRoutes.scan(mode));

  /// Selects an item; from a box on the photo, also brings its card in view.
  void _select(String itemId, {bool reveal = false}) {
    setState(() => _selectedItemId = itemId);
    if (!reveal) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final card = _cardKeys[itemId]?.currentContext;
      if (card == null || !card.mounted) return;
      Scrollable.ensureVisible(
        card,
        duration: KanzMotion.of(context, KanzMotion.slow),
        curve: KanzMotion.emphasized,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  /// Scrolls the specimen row (only the row, not the page) so the selected
  /// card is in view: the ideas may be about the second item of a photo,
  /// and its card must not hide behind the first one.
  void _showSelectedCard(String? itemId) {
    if (itemId == null || itemId == _shownCardId) return;
    _shownCardId = itemId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final card = _cardKeys[itemId]?.currentContext;
      if (card == null || !card.mounted) return;
      final row = Scrollable.maybeOf(card, axis: Axis.horizontal);
      final box = card.findRenderObject();
      if (row == null || box == null) return;
      unawaited(
        row.position.ensureVisible(
          box,
          alignment: 0.5,
          duration: KanzMotion.of(context, KanzMotion.medium),
          curve: KanzMotion.emphasized,
        ),
      );
    });
  }

  Future<void> _edit(Item item, ResultsFormat format) async {
    final changes = await showItemEditSheet(
      context,
      item: item,
      format: format,
    );
    if (changes == null || !mounted) return;
    unawaited(_session.correctItem(item.id, changes));
  }

  void _seeAllPlaces(ScanSessionState session) {
    final keys = [
      for (final c
          in session.recommendation?.facilityCategories ??
              const <FacilityCategory>[])
        c.key,
    ];
    unawaited(
      ref.read(dropoffControllerProvider.notifier).showCategories(keys),
    );
    context.go(AppRoutes.dropoff);
  }

  Future<void> _directions(Place place) async {
    final url = place.mapsUrl;
    var opened = false;
    if (url != null) {
      try {
        opened = await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } on Object {
        opened = false;
      }
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.resultsDirectionsFailed)),
      );
    }
  }

  Future<void> _useMyLocation() async {
    final permissions = ref.read(permissionServiceProvider);
    final status = await permissions.status(AppPermission.location);
    if (!mounted) return;
    if (status == PermissionState.granted) {
      await ref
          .read(settingsProvider.notifier)
          .setLocationMode(LocationMode.gps);
      await _session.resumeDropoff();
      return;
    }
    // The rationale asks, and pops true once there is somewhere to search
    // from: location granted (GPS mode) or a city picked there instead. The
    // settings are already updated then.
    final ready = await context.push<bool>(AppRoutes.locationRationale);
    if (!mounted) return;
    if (ready == true) {
      await _session.resumeDropoff();
    } else {
      setState(() => _locationOff = true);
    }
  }

  Future<void> _chooseCity() async {
    // The picker pops a city id, or "gps" when the user switched to their
    // location there (settings are already in GPS mode then).
    final id = await context.push<String>(AppRoutes.cityPicker);
    if (!mounted || id == null) return;
    final city = CityId.tryFromId(id);
    if (city != null) {
      await ref.read(settingsProvider.notifier).useCity(city);
    } else if (id != CityPickerScreen.myLocation) {
      return;
    }
    await _session.resumeDropoff();
  }

  // --------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    ref.listen(scanSessionProvider(_id), (previous, next) {
      _clock.observe(next);
      // A new analysis (a retry) starts again from its main item.
      if (previous?.analysis?.imageId != next.analysis?.imageId) {
        _selectedItemId = null;
      }
    });
    final session = ref.watch(scanSessionProvider(_id));
    final l10n = context.l10n;
    final format = ResultsFormat.of(
      context,
      ref.watch(vocabProvider),
      content: session.lang,
    );
    final status = ref.watch(backendStatusProvider);
    _problem = switch (status) {
      BackendStatus.offline || BackendStatus.unreachable => status,
      BackendStatus.online => null,
      BackendStatus.checking => _problem,
    };
    final problem = _problem;
    final offline = problem != null;

    final Widget body = switch (session.origin) {
      ScanOrigin.loading => const _RestoringSkeleton(),
      ScanOrigin.missing => ListView(
        children: [
          EmptyState(
            icon: KanzIcons.scan,
            title: l10n.resultsMissingTitle,
            message: l10n.resultsMissingBody,
            actionLabel: l10n.resultsNewScan,
            actionIcon: KanzIcons.camera,
            primaryAction: true,
            onAction: () => _rescan(ScanMode.camera),
          ),
        ],
      ),
      ScanOrigin.live ||
      ScanOrigin.restored => _content(session, format, offline: offline),
    };

    return PopScope(
      // Opened on its own (a link, or "Back to ideas" from a tutorial), the
      // results are the only page: back then goes Home instead of closing
      // the app. From a scan they replace the scan page, so back pops.
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: KanzIconButton(
            icon: KanzIcons.back,
            semanticsLabel: l10n.commonBack,
            onPressed: _leave,
          ),
        ),
        body: Column(
          children: [
            if (problem != null)
              OfflineBanner(
                message: switch ((status, problem)) {
                  (BackendStatus.checking, _) => l10n.resultsChecking,
                  (_, BackendStatus.offline) => l10n.resultsOffline,
                  _ => l10n.resultsUnreachable,
                },
                checking: status == BackendStatus.checking,
                actionLabel: status == BackendStatus.checking
                    ? null
                    : l10n.resultsCheckAgain,
                onAction: () => ref.invalidate(healthProvider),
              ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  Widget _content(
    ScanSessionState session,
    ResultsFormat format, {
    required bool offline,
  }) {
    final l10n = context.l10n;
    final identifying = session.stage(PipelineStage.identifying);
    final analysis = session.analysis;
    final items = session.items;
    final textScan = session.source == AnalysisSource.text;
    final rejected = session.rejectedPhoto;
    final identifyError = identifying.isFailed && rejected == null
        ? identifying.error
        : null;
    final identified = identifying.isDone && analysis != null;
    final multi = items.length > 1;
    final selectedId = _selectedItemId ?? session.focusItem?.id;
    if (multi && identifying.isDone) _showSelectedCard(selectedId);

    final Widget header;
    if (textScan) {
      header = TextScanHeader(
        label: l10n.resultsTextScan,
        description: format.ai(session.inputText ?? ''),
      );
    } else {
      final photo = scanPhoto(session);
      header = photo == null
          ? const AspectRatio(
              aspectRatio: ResultsPhoto.placeholderAspect,
              child: Skeleton(
                height: double.infinity,
                borderRadius: KanzRadii.cardAll,
              ),
            )
          : ResultsPhoto(
              key: ValueKey(analysis?.imageId ?? 'photo'),
              image: photo,
              imageSize:
                  analysis?.imageWidth != null && analysis?.imageHeight != null
                  ? Size(
                      analysis!.imageWidth!.toDouble(),
                      analysis.imageHeight!.toDouble(),
                    )
                  : null,
              heroTag: scanPhotoHeroTag(_id),
              semanticsLabel: l10n.resultsPhotoSemantics(items.length),
              selectedId: multi ? selectedId : null,
              onSelect: multi ? (id) => _select(id, reveal: true) : null,
              boxes: [
                for (var i = 0; i < items.length; i++)
                  if (items[i].bbox case final b?)
                    DetectionBox(
                      id: items[i].id,
                      rect: Rect.fromLTWH(b.x, b.y, b.w, b.h),
                      categoryId: items[i].category.id,
                      label: format.boxLabel(
                        items[i],
                        index: i + 1,
                        count: items.length,
                      ),
                      semanticsLabel: l10n.resultsBoxSemantics(
                        items[i].name,
                        format.category(items[i].category),
                        format.confidence(items[i].confidence),
                      ),
                    ),
              ],
            );
    }

    final children = <Widget>[
      Padding(padding: KanzSpace.page, child: header),
      if (rejected != null) ...[
        const SizedBox(height: KanzSpace.s32),
        Padding(
          padding: KanzSpace.page,
          child: _retake(session, rejected, format),
        ),
      ] else if (identifyError != null && !identifyError.retryable) ...[
        const SizedBox(height: KanzSpace.s32),
        Padding(
          padding: KanzSpace.page,
          child: RetakePanel(
            eyebrow: l10n.resultsTip,
            title: l10n.resultsIdentifyErrorTitle,
            tip: apiErrorMessage(l10n, identifyError),
            actions: _retakeActions(textScan),
          ),
        ),
      ] else if (identifyError != null) ...[
        const SizedBox(height: KanzSpace.s8),
        ErrorState(
          icon: identifyError.isOffline ? KanzIcons.noWifi : KanzIcons.error,
          title: l10n.resultsIdentifyErrorTitle,
          message: apiErrorMessage(l10n, identifyError),
          retryLabel: l10n.commonRetry,
          onRetry: () => unawaited(_session.retry(PipelineStage.identifying)),
          code: supportCode(identifyError),
          codeLabel: l10n.commonSupportCode,
        ),
      ] else ...[
        if (identified)
          FadeUp(
            key: ValueKey('heading-${analysis.imageId}'),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                KanzSpace.gutter,
                KanzSpace.s24,
                KanzSpace.gutter,
                0,
              ),
              child: _Heading(
                eyebrow: textScan
                    ? l10n.resultsReadAs
                    : l10n.resultsItemsFound(items.length),
                summary: format.ai(analysis.analysis.summary),
                large: !textScan,
              ),
            ),
          ),
        const SizedBox(height: KanzSpace.s20),
        Padding(
          padding: KanzSpace.page,
          child: PipelineSection(
            key: ValueKey('pipeline-$_id'),
            session: session,
            clock: _clock,
            format: format,
            onRetry: (stage) => unawaited(_session.retry(stage)),
          ),
        ),
        const SizedBox(height: KanzSpace.s32),
        if (!identified)
          Padding(
            padding: KanzSpace.page,
            child: SpecimenSkeleton(label: l10n.resultsReadingItems),
          )
        else ...[
          FadeUp(
            key: ValueKey('specimens-${analysis.imageId}'),
            child: SpecimenSection(
              items: items,
              selectedId: selectedId,
              focusId: session.focusItem?.id,
              format: format,
              onSelect: _select,
              cardKeys: {
                for (final item in items)
                  item.id: _cardKeys.putIfAbsent(item.id, GlobalKey.new),
              },
              onEdit: (item) => unawaited(_edit(item, format)),
              onFocus: (item) => unawaited(_session.focusItem(item.id)),
            ),
          ),
          SizedBox(height: multi ? KanzSpace.s32 : KanzSpace.s48),
          _paths(session, format),
          const SizedBox(height: KanzSpace.s48),
          DropoffSection(
            session: session,
            format: format,
            locationOff: _locationOff,
            onSeeAll: () => _seeAllPlaces(session),
            onDirections: (place) => unawaited(_directions(place)),
            onUseMyLocation: () => unawaited(_useMyLocation()),
            onChooseCity: () => unawaited(_chooseCity()),
            onRetry: () => unawaited(_session.retry(PipelineStage.dropoff)),
          ),
        ],
      ],
      const SizedBox(height: KanzSpace.s48),
    ];

    return ListView(
      padding: EdgeInsets.only(top: offline ? KanzSpace.s16 : KanzSpace.s8),
      children: children,
    );
  }

  Widget _paths(ScanSessionState session, ResultsFormat format) {
    Set<String> marked(ImpactKind kind) =>
        ref.watch(markedItemsProvider((scanId: _id, kind: kind))).value ??
        const <String>{};
    return PathsSection(
      scanId: _id,
      session: session,
      images: _images,
      format: format,
      tab: _tab,
      onTab: (tab) => setState(() => _tab = tab),
      ownedTools: ref.watch(settingsProvider.select((s) => s.tools)),
      recycled: marked(ImpactKind.recycled),
      donated: marked(ImpactKind.donated),
      disposed: marked(ImpactKind.disposed),
      onOpenIdea: (idea) => context.push(AppRoutes.idea(_id, idea.id)),
      onRetryImage: (idea) => unawaited(_session.regenerateAfterImage(idea.id)),
      onRetryIdeas: () => unawaited(_session.retry(PipelineStage.ideas)),
      onMarkRecycled: (id) => _session.markRecycled([id]),
      onMarkDonated: (id) => _session.markDonated([id]),
      onMarkDisposed: (id) => _session.markDisposed([id]),
    );
  }

  List<Widget> _retakeActions(bool textScan) {
    final l10n = context.l10n;
    if (textScan) {
      return [
        KanzButton(
          label: l10n.resultsDescribeAgain,
          icon: KanzIcons.describe,
          onPressed: () => _rescan(ScanMode.text),
          expand: true,
        ),
      ];
    }
    return [
      KanzButton(
        label: l10n.resultsRetake,
        icon: KanzIcons.camera,
        onPressed: () => _rescan(ScanMode.camera),
        expand: true,
      ),
      KanzButton.secondary(
        label: l10n.resultsChooseFromGallery,
        icon: KanzIcons.gallery,
        onPressed: () => _rescan(ScanMode.gallery),
        expand: true,
      ),
    ];
  }

  Widget _retake(
    ScanSessionState session,
    PhotoCheck rejected,
    ResultsFormat format,
  ) {
    final l10n = context.l10n;
    final textScan = session.source == AnalysisSource.text;
    return RetakePanel(
      eyebrow: l10n.resultsTip,
      title: textScan
          ? l10n.resultsTextRejectedTitle
          : photoIssueLabel(l10n, rejected.issue) ??
                l10n.resultsRetakeFallbackTitle,
      // The tip is the analyst's own sentence, in the scan's language: it
      // keeps its direction if the app language changed since.
      tip: switch (rejected.retakeTip) {
        final tip? => format.ai(tip),
        null => textScan ? l10n.resultsTextRejectedBody : null,
      },
      actions: _retakeActions(textScan),
    );
  }
}

/// The analysis in one sentence under a mono count, like a caption under a
/// figure.
class _Heading extends StatelessWidget {
  const _Heading({
    required this.eyebrow,
    required this.summary,
    required this.large,
  });

  final String eyebrow;
  final String summary;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonoLabel(eyebrow),
        const SizedBox(height: KanzSpace.s8),
        Semantics(
          header: true,
          child: Text(
            summary,
            style: large
                ? t.headlineSmall
                : t.bodyLarge?.copyWith(color: context.kanzColors.inkSecondary),
          ),
        ),
      ],
    );
  }
}

/// A scan being looked up in History: the photo frame and a line, briefly.
class _RestoringSkeleton extends StatelessWidget {
  const _RestoringSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s8,
        KanzSpace.gutter,
        0,
      ),
      children: const [
        AspectRatio(
          aspectRatio: ResultsPhoto.placeholderAspect,
          child: Skeleton(
            height: double.infinity,
            borderRadius: KanzRadii.cardAll,
          ),
        ),
        SizedBox(height: KanzSpace.s24),
        Skeleton(width: 96, height: 10),
        SizedBox(height: KanzSpace.s12),
        Skeleton(height: 20),
      ],
    );
  }
}
