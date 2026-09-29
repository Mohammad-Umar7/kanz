/// The sections of the design gallery. Each section is its own widget so
/// the screenshot harness can render them one at a time.
library;

import 'package:flutter/material.dart';

import '../../core/design/design.dart';
import 'gallery_samples.dart';

/// Images the gallery shows: the user's photo, its pixel size, the
/// photo's detected boxes and an image standing in for a generated
/// makeover.
@immutable
class GalleryImages {
  const GalleryImages({
    required this.photo,
    required this.photoSize,
    required this.jarBox,
    required this.lidBox,
    required this.after,
  });

  final ImageProvider photo;
  final Size photoSize;

  /// Normalized boxes of the jar and its lid within [photo].
  final Rect jarBox;
  final Rect lidBox;
  final ImageProvider after;
}

/// Builds section [index] of the gallery.
typedef GallerySectionBuilder =
    Widget Function(GallerySamples s, GalleryImages images);

/// Every section, in order. Titles come from [GallerySamples.sections].
const List<GallerySectionBuilder> gallerySections = [
  _foundations,
  _controls,
  _recognition,
  _recommendations,
  _tutorial,
  _dropOffAndSwaps,
  _states,
  _navigationAndBrand,
];

Widget _foundations(GallerySamples s, GalleryImages i) =>
    FoundationsSection(s: s);
Widget _controls(GallerySamples s, GalleryImages i) => ControlsSection(s: s);
Widget _recognition(GallerySamples s, GalleryImages i) =>
    RecognitionSection(s: s, images: i);
Widget _recommendations(GallerySamples s, GalleryImages i) =>
    RecommendationsSection(s: s, images: i);
Widget _tutorial(GallerySamples s, GalleryImages i) => TutorialSection(s: s);
Widget _dropOffAndSwaps(GallerySamples s, GalleryImages i) =>
    DropOffSection(s: s);
Widget _states(GallerySamples s, GalleryImages i) => StatesSection(s: s);
Widget _navigationAndBrand(GallerySamples s, GalleryImages i) =>
    NavigationSection(s: s, images: i);

/// A section: numbered mono eyebrow, a Fraunces title, then demos.
class GallerySection extends StatelessWidget {
  const GallerySection({
    super.key,
    required this.number,
    required this.title,
    required this.child,
  });

  final int number;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: KanzSpace.s32, bottom: KanzSpace.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            eyebrow: number.toString().padLeft(2, '0'),
            title: title,
            large: true,
          ),
          const SizedBox(height: KanzSpace.s24),
          child,
        ],
      ),
    );
  }
}

/// One demo inside a section: a mono caption naming the component, then
/// the component. [bleed] demos span the full width (lists, bars).
class _Demo extends StatelessWidget {
  const _Demo(this.caption, {required this.child, this.bleed = false});

  final String caption;
  final Widget child;
  final bool bleed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KanzSpace.s32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: KanzSpace.page,
            child: Text(
              caption,
              style: context.kanzType.data,
              textDirection: TextDirection.ltr,
              textAlign: context.isRtl ? TextAlign.right : TextAlign.left,
            ),
          ),
          const SizedBox(height: KanzSpace.s12),
          if (bleed) child else Padding(padding: KanzSpace.page, child: child),
        ],
      ),
    );
  }
}

class FoundationsSection extends StatelessWidget {
  const FoundationsSection({super.key, required this.s});

  final GallerySamples s;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    final type = context.kanzType;
    final arabic = context.isRtl;
    final tokens = <(String, Color)>[
      ('background', c.background),
      ('surface', c.surface),
      ('surfaceSunken', c.surfaceSunken),
      ('ink', c.ink),
      ('inkSecondary', c.inkSecondary),
      ('line', c.line),
      ('lineStrong', c.lineStrong),
      ('accent', c.accent),
      ('danger', c.danger),
      ('caution', c.caution),
      ('positive', c.positive),
      ('inverse', c.inverse),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Demo(
          'COLOR TOKENS',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = (constraints.maxWidth - KanzSpace.s12) / 2;
              return Wrap(
                spacing: KanzSpace.s12,
                runSpacing: KanzSpace.s12,
                children: [
                  for (final (name, color) in tokens)
                    SizedBox(
                      width: w,
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: KanzRadii.tagAll,
                              border: Border.all(color: c.line),
                            ),
                          ),
                          const SizedBox(width: KanzSpace.s8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    name,
                                    style: t.labelMedium,
                                    textDirection: TextDirection.ltr,
                                  ),
                                ),
                                Text(
                                  _hex(color),
                                  style: type.data,
                                  textDirection: TextDirection.ltr,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        _Demo(
          'MATERIAL COLORS',
          child: Wrap(
            spacing: KanzSpace.s16,
            runSpacing: KanzSpace.s12,
            children: [
              for (final swatch in KanzMaterialColors.all)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MaterialDot(swatch.id, size: 10),
                    const SizedBox(width: KanzSpace.s8),
                    Text(s.materials[swatch.id]!, style: t.bodyMedium),
                  ],
                ),
            ],
          ),
        ),
        _Demo(
          'TYPE',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                arabic ? 'كنز في الأشياء اليومية' : 'Treasure in the everyday',
                style: t.displaySmall,
              ),
              const SizedBox(height: KanzSpace.s12),
              Text(s.ideas.first.title, style: t.headlineMedium),
              const SizedBox(height: KanzSpace.s8),
              Text(s.stages[1], style: t.titleLarge),
              const SizedBox(height: KanzSpace.s8),
              Text(s.ideas.first.pitch, style: t.bodyLarge),
              const SizedBox(height: KanzSpace.s8),
              Text(s.jar.note, style: t.bodySmall),
              const SizedBox(height: KanzSpace.s12),
              const MonoLabel('PET · #1 · 3 pcs'),
              const SizedBox(height: KanzSpace.s12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('03', style: type.numeral),
                  const SizedBox(width: KanzSpace.s16),
                  Text('12', style: type.numeralLarge),
                ],
              ),
            ],
          ),
        ),
        _Demo(
          'ICONS · PHOSPHOR REGULAR',
          child: Wrap(
            spacing: KanzSpace.s16,
            runSpacing: KanzSpace.s16,
            children: [
              for (final icon in const [
                KanzIcons.scan,
                KanzIcons.camera,
                KanzIcons.gallery,
                KanzIcons.dropOff,
                KanzIcons.swaps,
                KanzIcons.impact,
                KanzIcons.recycle,
                KanzIcons.donate,
                KanzIcons.upcycle,
                KanzIcons.tools,
                KanzIcons.safety,
                KanzIcons.forward,
              ])
                Icon(icon, size: 24, color: c.ink),
            ],
          ),
        ),
      ],
    );
  }

  static String _hex(Color color) {
    final v = color.toARGB32() & 0xFFFFFF;
    return '#${v.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}

class ControlsSection extends StatefulWidget {
  const ControlsSection({super.key, required this.s});

  final GallerySamples s;

  @override
  State<ControlsSection> createState() => _ControlsSectionState();
}

class _ControlsSectionState extends State<ControlsSection> {
  int _tab = 0;
  final Set<String> _filters = {'glass'};
  bool _handsFree = true;

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final c = context.kanzColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Demo(
          'KANZBUTTON',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: KanzSpace.s12,
            children: [
              KanzButton(
                label: s.seeTutorial,
                trailingIcon: KanzIcons.forward,
                onPressed: () {},
                expand: true,
              ),
              Row(
                spacing: KanzSpace.s12,
                children: [
                  Expanded(
                    child: KanzButton.secondary(
                      label: s.retake,
                      onPressed: () {},
                      expand: true,
                    ),
                  ),
                  Expanded(
                    child: KanzButton(
                      label: s.saving,
                      onPressed: () {},
                      loading: true,
                      loadingLabel: s.saving,
                      expand: true,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: KanzSpace.s12,
                runSpacing: KanzSpace.s12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  KanzButton.tertiary(label: s.skip, onPressed: () {}),
                  KanzButton.destructive(
                    label: s.deleteHistory,
                    icon: KanzIcons.delete,
                    onPressed: () {},
                  ),
                  KanzButton(label: s.seeTutorial, onPressed: null),
                ],
              ),
            ],
          ),
        ),
        _Demo(
          'SCAN ACTION · ICON BUTTONS',
          child: Wrap(
            spacing: KanzSpace.s16,
            runSpacing: KanzSpace.s16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ScanActionButton(
                semanticsLabel: s.scan,
                label: s.scan,
                icon: KanzIcons.camera,
                onPressed: () {},
              ),
              ScanActionButton(semanticsLabel: s.scan, onPressed: () {}),
              KanzIconButton(
                icon: KanzIcons.share,
                semanticsLabel: s.share,
                onPressed: () {},
              ),
              KanzIconButton(
                icon: KanzIcons.speaker,
                semanticsLabel: s.readAloud,
                style: KanzIconButtonStyle.outlined,
                selected: true,
                onPressed: () {},
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: c.photoBackdrop,
                  borderRadius: KanzRadii.buttonAll,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(KanzSpace.s8),
                  child: KanzIconButton(
                    icon: KanzIcons.flashOff,
                    semanticsLabel: s.flash,
                    style: KanzIconButtonStyle.onPhoto,
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
        _Demo(
          'KANZCHIP · FILTER',
          child: Wrap(
            spacing: KanzSpace.s8,
            children: [
              for (final id in const ['glass', 'plastic', 'paper', 'metal'])
                KanzChip(
                  label: s.materials[id]!,
                  materialId: id,
                  selected: _filters.contains(id),
                  count: id == 'glass' ? '2' : null,
                  onSelected: (on) => setState(
                    () => on ? _filters.add(id) : _filters.remove(id),
                  ),
                ),
            ],
          ),
        ),
        _Demo(
          'SEGMENTEDTABS',
          child: SegmentedTabs(
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
            tabs: [
              SegmentedTab(label: s.tabs[0], count: '3'),
              SegmentedTab(label: s.tabs[1], count: '2'),
              SegmentedTab(label: s.tabs[2], count: '1'),
            ],
          ),
        ),
        _Demo(
          'KANZTEXTFIELD',
          child: KanzTextField(
            label: s.fieldLabel,
            hint: s.fieldHint,
            helper: s.fieldHelper,
            prefixIcon: KanzIcons.describe,
          ),
        ),
        _Demo(
          'KANZLISTTILE',
          bleed: true,
          child: Column(
            children: [
              KanzListTile(
                leading: const Icon(KanzIcons.language),
                title: s.languageSetting,
                value: s.languageValue,
                showChevron: true,
                divider: true,
                onTap: () {},
              ),
              KanzListTile(
                leading: const Icon(KanzIcons.tools),
                title: s.toolsSetting,
                subtitle: s.toolsDetail,
                showChevron: true,
                onTap: () {},
              ),
            ],
          ),
        ),
        _Demo(
          'KANZSWITCHTILE',
          bleed: true,
          child: KanzSwitchTile(
            title: s.handsFree,
            subtitle: s.handsFreeDetail,
            value: _handsFree,
            onChanged: (v) => setState(() => _handsFree = v),
          ),
        ),
        _Demo(
          'KANZSHEET',
          bleed: true,
          child: KanzSheet(
            title: s.sheetTitle,
            subtitle: s.sheetSubtitle,
            actions: [KanzButton(label: s.seeTutorial, onPressed: () {})],
            child: Padding(
              padding: KanzSpace.page,
              child: Wrap(
                spacing: KanzSpace.s8,
                children: [
                  for (final id in const ['glass', 'plastic', 'metal'])
                    KanzChip(
                      label: s.materials[id]!,
                      materialId: id,
                      selected: id == 'glass',
                      onSelected: (_) {},
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RecognitionSection extends StatefulWidget {
  const RecognitionSection({super.key, required this.s, required this.images});

  final GallerySamples s;
  final GalleryImages images;

  @override
  State<RecognitionSection> createState() => _RecognitionSectionState();
}

class _RecognitionSectionState extends State<RecognitionSection> {
  String _selected = 'item_1';

  SpecimenLabels get _labels => SpecimenLabels(
    material: widget.s.material,
    type: widget.s.type,
    quantity: widget.s.quantity,
    quality: widget.s.quality,
    state: widget.s.state,
    recyclable: widget.s.recyclable,
    confidence: widget.s.confidence,
    edit: widget.s.correctItem,
  );

  SpecimenCard _card(
    GallerySpecimen x,
    String id,
    String category, {
    required bool compact,
    required String index,
    int quality = 4,
    SpecimenRecyclable recyclable = SpecimenRecyclable.yes,
    String? hazard,
  }) {
    return SpecimenCard(
      labels: _labels,
      categoryId: category,
      categoryLabel: widget.s.materials[category]!,
      name: x.name,
      material: x.material,
      quantity: x.quantity,
      qualityScore: quality,
      qualityLabel: x.quality,
      qualitySemantics: x.qualitySemantics,
      stateLabels: x.states,
      recyclable: recyclable,
      recyclableLabel: x.recyclable,
      recyclableDetail: x.recyclableDetail,
      confidence: x.confidence,
      hazardLabel: hazard,
      note: compact ? null : x.note,
      index: index,
      compact: compact,
      selected: compact && _selected == id,
      onTap: () => setState(() => _selected = id),
      onEdit: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final images = widget.images;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Demo(
          'BOUNDINGBOXOVERLAY',
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: BoundingBoxOverlay(
              image: images.photo,
              imageSize: images.photoSize,
              semanticsLabel: s.photoSemantics,
              selectedId: _selected,
              onSelect: (id) => setState(() => _selected = id),
              boxes: [
                DetectionBox(
                  id: 'item_1',
                  rect: images.jarBox,
                  categoryId: 'glass',
                  label: s.jar.boxLabel,
                ),
                DetectionBox(
                  id: 'item_2',
                  rect: images.lidBox,
                  categoryId: 'metal',
                  label: s.lid.boxLabel,
                ),
              ],
            ),
          ),
        ),
        _Demo(
          'SPECIMENCARD · COMPACT CAROUSEL',
          bleed: true,
          child: SpecimenCarousel(
            children: [
              _card(s.jar, 'item_1', 'glass', compact: true, index: '01'),
              _card(s.lid, 'item_2', 'metal', compact: true, index: '02'),
            ],
          ),
        ),
        _Demo(
          'SPECIMENCARD',
          child: _card(
            s.jar,
            'item_1',
            'glass',
            compact: false,
            index: '01 / 02',
          ),
        ),
        _Demo(
          'SPECIMENCARD · HAZARDOUS',
          child: _card(
            s.battery,
            'item_3',
            'hazardous',
            compact: false,
            index: '01 / 01',
            quality: 2,
            recyclable: SpecimenRecyclable.conditional,
            hazard: s.batteryHazard,
          ),
        ),
        _Demo(
          'PIPELINETIMELINE · RUNNING',
          child: PipelineTimeline(
            summary: s.pipelineSummary,
            expandLabel: s.showSteps,
            collapseLabel: s.hideSteps,
            stages: [
              PipelineStage(
                label: s.stages[0],
                status: PipelineStatus.done,
                detail: s.stageTimes[0],
              ),
              PipelineStage(label: s.stages[1], status: PipelineStatus.active),
              PipelineStage(label: s.stages[2], status: PipelineStatus.pending),
              PipelineStage(label: s.stages[3], status: PipelineStatus.pending),
            ],
          ),
        ),
        _Demo(
          'PIPELINETIMELINE · FAILED STAGE',
          child: PipelineTimeline(
            summary: s.pipelineSummary,
            expandLabel: s.showSteps,
            collapseLabel: s.hideSteps,
            retryLabel: s.tryAgain,
            onRetry: (_) {},
            stages: [
              PipelineStage(
                label: s.stages[0],
                status: PipelineStatus.done,
                detail: s.stageTimes[0],
              ),
              PipelineStage(
                label: s.stages[1],
                status: PipelineStatus.done,
                detail: s.stageTimes[1],
              ),
              PipelineStage(
                label: s.stages[2],
                status: PipelineStatus.done,
                detail: s.stageTimes[2],
              ),
              PipelineStage(
                label: s.stages[3],
                status: PipelineStatus.failed,
                message: s.imagesPaused,
              ),
            ],
          ),
        ),
        _Demo(
          'PIPELINETIMELINE · HAZARDOUS ITEM',
          child: PipelineTimeline(
            summary: s.pipelineSummary,
            expandLabel: s.showSteps,
            collapseLabel: s.hideSteps,
            stages: [
              PipelineStage(
                label: s.stages[0],
                status: PipelineStatus.done,
                detail: s.stageTimes[0],
              ),
              PipelineStage(
                label: s.stages[1],
                status: PipelineStatus.skipped,
                message: s.noDiyIdeas,
              ),
              PipelineStage(label: s.stages[2], status: PipelineStatus.active),
              PipelineStage(
                label: s.stages[3],
                status: PipelineStatus.skipped,
                message: s.noMakeovers,
              ),
            ],
          ),
        ),
        _Demo(
          'PIPELINETIMELINE · COMPLETE',
          child: PipelineTimeline(
            summary: s.pipelineSummary,
            expandLabel: s.showSteps,
            collapseLabel: s.hideSteps,
            stages: [
              for (var i = 0; i < 4; i++)
                PipelineStage(label: s.stages[i], status: PipelineStatus.done),
            ],
          ),
        ),
      ],
    );
  }
}

class RecommendationsSection extends StatefulWidget {
  const RecommendationsSection({
    super.key,
    required this.s,
    required this.images,
  });

  final GallerySamples s;
  final GalleryImages images;

  @override
  State<RecommendationsSection> createState() => _RecommendationsState();
}

class _RecommendationsState extends State<RecommendationsSection> {
  int _tab = 0;

  IdeaCard _idea(int index, {required ImageProvider? after}) {
    final s = widget.s;
    final idea = s.ideas[index];
    return IdeaCard(
      title: idea.title,
      pitch: idea.pitch,
      original: widget.images.photo,
      after: after,
      pendingLabel: s.rendering,
      errorLabel: s.previewUnavailable,
      beforeLabel: s.before,
      meta: idea.meta,
      toolMatch: ToolMatchBadge(
        label: idea.toolMatch,
        have: idea.have,
        total: idea.total,
      ),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Demo(
          'SEGMENTEDTABS · PATHS',
          child: SegmentedTabs(
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
            tabs: [
              SegmentedTab(label: s.tabs[0], icon: KanzIcons.upcycle),
              SegmentedTab(label: s.tabs[1], icon: KanzIcons.recycle),
              SegmentedTab(label: s.tabs[2], icon: KanzIcons.donate),
            ],
          ),
        ),
        _Demo('IDEACARD · READY', child: _idea(0, after: widget.images.after)),
        _Demo('IDEACARD · RENDERING', child: _idea(1, after: null)),
        _Demo(
          'IDEACARD · IMAGE FAILED',
          child: _idea(2, after: const _FailingImage()),
        ),
        _Demo(
          'BEFOREAFTERSLIDER',
          child: BeforeAfterSlider(
            before: widget.images.photo,
            after: widget.images.after,
            beforeLabel: s.before,
            afterLabel: s.after,
            semanticsLabel: s.compare,
            initialValue: 0.42,
          ),
        ),
        _Demo(
          'SOURCECHIPS',
          child: SourceChips(title: s.sourcesTitle, sources: s.sources),
        ),
      ],
    );
  }
}

/// An image provider that always fails, to show the error fallback.
class _FailingImage extends ImageProvider<_FailingImage> {
  const _FailingImage();

  @override
  Future<_FailingImage> obtainKey(ImageConfiguration configuration) =>
      Future.value(this);

  @override
  ImageStreamCompleter loadImage(
    _FailingImage key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(
      Future.error(StateError('Image generation unavailable')),
    );
  }
}

class TutorialSection extends StatelessWidget {
  const TutorialSection({super.key, required this.s});

  final GallerySamples s;

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Demo(
          'STEPPROGRESSBAR · STEPNUMERAL',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepProgressBar(total: 5, current: 1, semanticsLabel: s.stepOf),
              const SizedBox(height: KanzSpace.s24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StepNumeral(current: 2, total: 5, semanticsLabel: s.stepOf),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: MonoLabel(s.stepTime),
                  ),
                ],
              ),
              const SizedBox(height: KanzSpace.s12),
              Text(s.stepTitle, style: t.headlineMedium),
              const SizedBox(height: KanzSpace.s8),
              Text(s.stepInstruction, style: t.bodyLarge),
            ],
          ),
        ),
        _Demo(
          'CALLOUT',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: KanzSpace.s12,
            children: [
              Callout(
                variant: CalloutVariant.tip,
                title: s.tipTitle,
                message: s.tip,
              ),
              Callout(
                variant: CalloutVariant.warning,
                title: s.carefulTitle,
                message: s.careful,
              ),
              Callout(
                variant: CalloutVariant.safety,
                title: s.safetyTitle,
                message: s.safety,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DropOffSection extends StatelessWidget {
  const DropOffSection({super.key, required this.s});

  final GallerySamples s;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Demo(
          'PLACEROW',
          bleed: true,
          child: Column(
            children: [
              for (var i = 0; i < s.places.length; i++)
                PlaceRow(
                  name: s.places[i].name,
                  address: s.places[i].address,
                  typeLabel: s.places[i].type,
                  distance: s.places[i].distance,
                  openLabel: s.places[i].openLabel,
                  openState: switch (s.places[i].open) {
                    true => OpenState.open,
                    false => OpenState.closed,
                    null => OpenState.unknown,
                  },
                  materialIds: s.places[i].materials,
                  directionsLabel: s.directions,
                  selected: i == 1,
                  // Unknown hours are left out, as the Drop-off list does
                  // for places OpenStreetMap lists without them.
                  hideUnknownHours: true,
                  divider: i < s.places.length - 1,
                  onTap: () {},
                  onDirections: () {},
                ),
            ],
          ),
        ),
        _Demo(
          'SWAPCARD · STAGGERED ENTRANCE',
          child: StaggeredColumn(
            children: [
              for (final swap in s.swaps)
                SwapCard(
                  fromLabel: s.insteadOf,
                  from: swap.from,
                  toLabel: s.tryThis,
                  to: swap.to,
                  why: swap.why,
                  tipLabel: s.tipLabel,
                  tip: swap.tip,
                  meta: swap.meta,
                  categoryId: 'plastic',
                  badge: swap.badge ?? s.materials['plastic'],
                  footer: SourceChips(
                    title: s.sourcesTitle,
                    sources: s.sources.take(1).toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class StatesSection extends StatelessWidget {
  const StatesSection({super.key, required this.s});

  final GallerySamples s;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Demo(
          'SKELETON',
          child: KanzCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Skeleton(
                    height: double.infinity,
                    borderRadius: KanzRadii.inputAll,
                  ),
                ),
                const SizedBox(height: KanzSpace.s16),
                const Skeleton(width: 180, height: 20),
                const SizedBox(height: KanzSpace.s12),
                Skeleton.text(lines: 2),
              ],
            ),
          ),
        ),
        _Demo(
          'OFFLINEBANNER',
          bleed: true,
          child: OfflineBanner(message: s.offline),
        ),
        _Demo(
          'EMPTYSTATE',
          bleed: true,
          child: EmptyState(
            icon: KanzIcons.history,
            title: s.emptyTitle,
            message: s.emptyMessage,
            actionLabel: s.scan,
            onAction: () {},
          ),
        ),
        _Demo(
          'ERRORSTATE',
          bleed: true,
          child: ErrorState(
            title: s.errorTitle,
            message: s.errorMessage,
            retryLabel: s.tryAgain,
            onRetry: () {},
            code: s.errorCode,
            codeLabel: s.supportCode,
          ),
        ),
        _Demo(
          'STATNUMERAL · MATERIALBARS',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: StatNumeral(
                      value: s.itemsSaved,
                      label: s.itemsSavedLabel,
                    ),
                  ),
                  const SizedBox(width: KanzSpace.s16),
                  Expanded(
                    child: StatNumeral(
                      value: s.projectsDone,
                      label: s.projectsDoneLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KanzSpace.s24),
              MaterialBars(
                shares: [
                  for (final (id, value) in const [
                    ('glass', 7.0),
                    ('plastic', 4.0),
                    ('paper', 3.0),
                    ('metal', 2.0),
                    ('textile', 1.0),
                  ])
                    MaterialShare(
                      categoryId: id,
                      label: s.materials[id]!,
                      value: value,
                      valueLabel: s.materialCounts[id]!,
                    ),
                ],
              ),
            ],
          ),
        ),
        _Demo(
          'PERMISSIONRATIONALE · CAMERA',
          bleed: true,
          child: _rationale(s.camera, PermissionArt.camera, const [
            KanzIcons.camera,
            KanzIcons.frame,
          ]),
        ),
        _Demo(
          'PERMISSIONRATIONALE · LOCATION',
          bleed: true,
          child: _rationale(s.location, PermissionArt.location, const [
            KanzIcons.dropOff,
            KanzIcons.safety,
          ]),
        ),
      ],
    );
  }

  Widget _rationale(
    GalleryRationale r,
    PermissionArt art,
    List<IconData> icons,
  ) {
    return PermissionRationale(
      art: art,
      title: r.title,
      reasons: [
        for (var i = 0; i < r.reasons.length; i++)
          RationaleReason(icon: icons[i], text: r.reasons[i]),
      ],
      primaryLabel: r.allow,
      onPrimary: () {},
      secondaryLabel: r.alternative,
      onSecondary: () {},
      footnote: r.footnote,
    );
  }
}

class NavigationSection extends StatefulWidget {
  const NavigationSection({super.key, required this.s, required this.images});

  final GallerySamples s;
  final GalleryImages images;

  @override
  State<NavigationSection> createState() => _NavigationSectionState();
}

class _NavigationSectionState extends State<NavigationSection> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final c = context.kanzColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Demo(
          'KANZNAVBAR',
          bleed: true,
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: KanzNavBar(
              selectedIndex: _tab,
              onSelected: (i) => setState(() => _tab = i),
              scanLabel: s.scan,
              onScan: () {},
              destinations: [
                KanzNavDestination(icon: KanzIcons.home, label: s.nav[0]),
                KanzNavDestination(icon: KanzIcons.dropOff, label: s.nav[1]),
                KanzNavDestination(icon: KanzIcons.swaps, label: s.nav[2]),
                KanzNavDestination(icon: KanzIcons.impact, label: s.nav[3]),
              ],
            ),
          ),
        ),
        _Demo(
          'BRANDMARK',
          child: Row(
            children: [
              const BrandLockup(),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(KanzSpace.s12),
                decoration: BoxDecoration(
                  color: c.inverse,
                  borderRadius: KanzRadii.buttonAll,
                ),
                child: BrandMark(size: 32, inkColor: c.onInverse),
              ),
            ],
          ),
        ),
        _Demo(
          'VIEWFINDER · SHUTTER',
          child: ClipRRect(
            borderRadius: KanzRadii.cardAll,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: c.photoBackdrop),
                  Image(image: widget.images.photo, fit: BoxFit.cover),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(40, 56, 40, 132),
                    child: CornerBrackets(active: true),
                  ),
                  PositionedDirectional(
                    top: KanzSpace.s8,
                    start: KanzSpace.s8,
                    child: KanzIconButton(
                      icon: KanzIcons.close,
                      semanticsLabel: s.close,
                      style: KanzIconButtonStyle.onPhoto,
                      onPressed: () {},
                    ),
                  ),
                  PositionedDirectional(
                    top: KanzSpace.s8,
                    end: KanzSpace.s8,
                    child: KanzIconButton(
                      icon: KanzIcons.flashOff,
                      semanticsLabel: s.flash,
                      style: KanzIconButtonStyle.onPhoto,
                      onPressed: () {},
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: KanzSpace.s24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        KanzIconButton(
                          icon: KanzIcons.gallery,
                          semanticsLabel: s.chooseFromGallery,
                          style: KanzIconButtonStyle.onPhoto,
                          onPressed: () {},
                        ),
                        ShutterButton(
                          semanticsLabel: s.scan,
                          onPressed: () {},
                          haptics: false,
                        ),
                        KanzIconButton(
                          icon: KanzIcons.describe,
                          semanticsLabel: s.fieldLabel,
                          style: KanzIconButtonStyle.onPhoto,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
