import 'package:flutter/material.dart';

import '../../../core/data/models/models.dart';
import '../../../core/design/design.dart';
import '../../../core/state/scan_session.dart';
import '../../../l10n/l10n.dart';
import '../results_format.dart';
import 'guide_list.dart';

/// How to recycle each item: its stream, the prep, do's and don'ts, and
/// "Mark as recycled".
class RecycleAdvice extends StatelessWidget {
  const RecycleAdvice({
    super.key,
    required this.session,
    required this.format,
    required this.recycled,
    required this.onMark,
  });

  final ScanSessionState session;
  final ResultsFormat format;

  /// Item ids already marked as recycled.
  final Set<String> recycled;
  final Future<void> Function(String itemId) onMark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final path = session.recommendation!.recycle;
    if (path.instructions.isEmpty) {
      return EmptyState(
        icon: KanzIcons.recycle,
        title: l10n.resultsTabRecycle,
        message: l10n.resultsRecycleEmpty,
      );
    }
    final sources = format.sourceTitles(path.sources);
    return Padding(
      padding: KanzSpace.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < path.instructions.length; i++) ...[
            if (i > 0) const SizedBox(height: KanzSpace.s12),
            FadeUp.staggered(
              index: i,
              child: _RecycleCard(
                instruction: path.instructions[i],
                item: session.itemById(path.instructions[i].itemId),
                format: format,
                done: recycled.contains(path.instructions[i].itemId),
                onMark: () => onMark(path.instructions[i].itemId),
              ),
            ),
          ],
          if (sources.isNotEmpty) ...[
            const SizedBox(height: KanzSpace.s24),
            SourceChips(title: l10n.resultsBasedOn, sources: sources),
          ],
        ],
      ),
    );
  }
}

class _RecycleCard extends StatelessWidget {
  const _RecycleCard({
    required this.instruction,
    required this.item,
    required this.format,
    required this.done,
    required this.onMark,
  });

  final RecycleInstruction instruction;
  final Item? item;
  final ResultsFormat format;
  final bool done;
  final Future<void> Function() onMark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final (icon, color) = switch (instruction.status) {
      RecyclabilityStatus.yes => (KanzIcons.checkCircle, c.ink),
      RecyclabilityStatus.conditional => (KanzIcons.info, c.ink),
      RecyclabilityStatus.no => (KanzIcons.prohibited, c.danger),
    };
    return KanzCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ItemHeading(
            item: item,
            format: format,
            fallback: format.ai(instruction.stream),
          ),
          const SizedBox(height: KanzSpace.s12),
          _StatusLine(
            icon: icon,
            color: color,
            text: l10n.resultsRecyclableValue(
              recyclabilityLabel(l10n, instruction.status),
              format.ai(instruction.stream),
            ),
          ),
          if (instruction.note case final note? when note.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: GuideList.textInset,
                top: KanzSpace.s4,
              ),
              child: Text(format.ai(note), style: context.textStyles.bodySmall),
            ),
          const SizedBox(height: KanzSpace.s16),
          Divider(height: 1, color: c.line),
          const SizedBox(height: KanzSpace.s16),
          ..._spaced([
            GuideList(
              title: l10n.resultsPrep,
              lines: format.aiLines(instruction.prepSteps),
              style: GuideListStyle.numbered,
            ),
            GuideList(
              title: l10n.resultsDo,
              lines: format.aiLines(instruction.dos),
              style: GuideListStyle.dos,
            ),
            GuideList(
              title: l10n.resultsDont,
              lines: format.aiLines(instruction.donts),
              style: GuideListStyle.donts,
            ),
          ]),
          if (instruction.status != RecyclabilityStatus.no) ...[
            const SizedBox(height: KanzSpace.s16),
            MarkButton(
              label: l10n.resultsMarkRecycled,
              doneLabel: l10n.resultsMarkedRecycled,
              done: done,
              onMark: onMark,
            ),
          ],
        ],
      ),
    );
  }
}

/// Whether each item can be donated, where, how to prepare it, and "Mark as
/// donated". When nothing can be donated, says so plainly.
class DonateAdvice extends StatelessWidget {
  const DonateAdvice({
    super.key,
    required this.session,
    required this.format,
    required this.donated,
    required this.onMark,
  });

  final ScanSessionState session;
  final ResultsFormat format;

  /// Item ids already marked as donated.
  final Set<String> donated;
  final Future<void> Function(String itemId) onMark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final path = session.recommendation!.donate;
    if (!path.available && path.options.every((o) => !o.suitable)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmptyState(
            icon: KanzIcons.donate,
            title: l10n.resultsDonateUnavailableTitle,
            message: format.ai(path.summary),
          ),
          for (final option in path.options) ...[
            Padding(
              padding: KanzSpace.page,
              child: _DonateCard(
                option: option,
                item: session.itemById(option.itemId),
                format: format,
                done: false,
                onMark: null,
              ),
            ),
            const SizedBox(height: KanzSpace.s12),
          ],
        ],
      );
    }
    return Padding(
      padding: KanzSpace.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (path.summary.trim().isNotEmpty) ...[
            Text(format.ai(path.summary), style: context.textStyles.bodyLarge),
            const SizedBox(height: KanzSpace.s16),
          ],
          for (var i = 0; i < path.options.length; i++) ...[
            if (i > 0) const SizedBox(height: KanzSpace.s12),
            FadeUp.staggered(
              index: i,
              child: _DonateCard(
                option: path.options[i],
                item: session.itemById(path.options[i].itemId),
                format: format,
                done: donated.contains(path.options[i].itemId),
                onMark: () => onMark(path.options[i].itemId),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DonateCard extends StatelessWidget {
  const _DonateCard({
    required this.option,
    required this.item,
    required this.format,
    required this.done,
    required this.onMark,
  });

  final DonateOption option;
  final Item? item;
  final ResultsFormat format;
  final bool done;

  /// Null hides the mark action (the item is not suitable).
  final Future<void> Function()? onMark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final onMark = this.onMark;
    return KanzCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ItemHeading(
            item: item,
            format: format,
            fallback: format.ai(option.reason),
          ),
          const SizedBox(height: KanzSpace.s12),
          _StatusLine(
            icon: option.suitable
                ? KanzIcons.checkCircle
                : KanzIcons.prohibited,
            color: option.suitable ? c.ink : c.danger,
            text: option.suitable
                ? l10n.resultsDonateSuitable
                : l10n.resultsDonateNotSuitable,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: GuideList.textInset,
              top: KanzSpace.s4,
            ),
            child: Text(
              format.ai(option.reason),
              style: context.textStyles.bodyMedium?.copyWith(
                color: c.inkSecondary,
              ),
            ),
          ),
          if (option.where.isNotEmpty || option.prepSteps.isNotEmpty) ...[
            const SizedBox(height: KanzSpace.s16),
            Divider(height: 1, color: c.line),
            const SizedBox(height: KanzSpace.s16),
            ..._spaced([
              GuideList(
                title: l10n.resultsDonateWhere,
                lines: format.aiLines(option.where),
              ),
              GuideList(
                title: l10n.resultsPrep,
                lines: format.aiLines(option.prepSteps),
                style: GuideListStyle.numbered,
              ),
            ]),
          ],
          if (option.suitable && onMark != null) ...[
            const SizedBox(height: KanzSpace.s16),
            MarkButton(
              label: l10n.resultsMarkDonated,
              doneLabel: l10n.resultsMarkedDonated,
              done: done,
              onMark: onMark,
            ),
          ],
        ],
      ),
    );
  }
}

/// The item a card is about: its material dot and category over its name.
class _ItemHeading extends StatelessWidget {
  const _ItemHeading({
    required this.item,
    required this.format,
    required this.fallback,
  });

  final Item? item;
  final ResultsFormat format;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final item = this.item;
    if (item == null) {
      return Text(fallback, style: context.textStyles.titleMedium);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MaterialDot(item.category.id),
            const SizedBox(width: KanzSpace.s8),
            Flexible(child: MonoLabel(format.category(item.category))),
          ],
        ),
        const SizedBox(height: KanzSpace.s4),
        Semantics(
          header: true,
          child: Text(
            format.ai(item.name),
            style: context.textStyles.titleMedium,
          ),
        ),
      ],
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: GuideList.markerWidth,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, size: 20, color: color),
              ),
            ),
          ),
          const SizedBox(width: KanzSpace.s12),
          Expanded(child: Text(text, style: context.textStyles.bodyLarge)),
        ],
      ),
    );
  }
}

/// Non-empty guide lists with 20 dp between them.
List<Widget> _spaced(List<GuideList> lists) {
  final shown = [
    for (final l in lists)
      if (l.lines.isNotEmpty) l,
  ];
  return [
    for (var i = 0; i < shown.length; i++) ...[
      if (i > 0) const SizedBox(height: KanzSpace.s20),
      shown[i],
    ],
  ];
}
