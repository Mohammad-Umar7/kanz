import 'package:flutter/material.dart';

import '../../core/data/models/models.dart';
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
import '../../l10n/l10n.dart';

/// While the Swap Advisor works: a live line naming what it is looking at
/// ("Finding swaps for plastic bags and cling film"), and two placeholder
/// cards shaped like [SwapCard]. The "Find swaps" button above already
/// spins, so the line carries no second spinner.
class SwapsLoading extends StatelessWidget {
  const SwapsLoading({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Padding(
      padding: KanzSpace.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(label, style: context.textStyles.bodySmall),
          ),
          const SizedBox(height: KanzSpace.s16),
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) const SizedBox(height: KanzSpace.s12),
            KanzCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Skeleton(width: 8, height: 8),
                      SizedBox(width: KanzSpace.s8),
                      Skeleton(width: 88, height: 10),
                    ],
                  ),
                  const SizedBox(height: KanzSpace.s16),
                  FractionallySizedBox(
                    widthFactor: i.isEven ? 0.65 : 0.5,
                    child: const Skeleton(height: 14),
                  ),
                  const SizedBox(height: KanzSpace.s16),
                  const Skeleton(width: 48, height: 10),
                  const SizedBox(height: KanzSpace.s8),
                  FractionallySizedBox(
                    widthFactor: i.isEven ? 0.8 : 0.7,
                    child: const Skeleton(height: 22),
                  ),
                  const SizedBox(height: KanzSpace.s16),
                  Skeleton.text(lines: 2),
                  const SizedBox(height: KanzSpace.s16),
                  Divider(height: 1, color: c.line),
                  const SizedBox(height: KanzSpace.s12),
                  const Skeleton(width: 150, height: 10),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The calm lead-in above the cards when the advisor read the history:
/// "You scanned 6 plastic bottles this month."
class SwapsInsight extends StatelessWidget {
  const SwapsInsight({super.key, required this.label, required this.insight});

  final String label;
  final String insight;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Padding(
      padding: KanzSpace.page,
      child: Container(
        padding: const EdgeInsetsDirectional.only(start: KanzSpace.s16),
        decoration: BoxDecoration(
          border: BorderDirectional(
            start: BorderSide(color: c.lineStrong, width: 2),
          ),
        ),
        child: MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MonoLabel(label),
              const SizedBox(height: KanzSpace.s4),
              Text(insight, style: context.textStyles.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

/// One suggested swap as a [SwapCard], with its impact note and the
/// knowledge documents it was grounded in inside the card. The advisor's
/// text keeps the direction of the language it was written in, so an
/// English answer reopened with the app in Arabic still reads left to
/// right.
class SwapEntry extends StatelessWidget {
  const SwapEntry({
    super.key,
    required this.swap,
    required this.vocab,
    required this.lang,
  });

  final Swap swap;
  final Vocab vocab;

  /// The language the advisor answered in (`SwapsResponse.lang`).
  final Lang lang;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final locale = Localizations.localeOf(context);
    String content(String text) => _inContentDirection(context, text, lang);
    final matched = swap.matchedInput?.trim();
    final badge = swap.fromHistory
        ? l10n.swapsFromScans
        : (matched != null && matched.isNotEmpty
              ? content(matched)
              : vocab.material(swap.category).label.forLocale(locale));
    final impact = swap.impactNote?.trim();
    final hasImpact = impact != null && impact.isNotEmpty;
    final tip = swap.tip.trim();
    return SwapCard(
      fromLabel: l10n.swapsInsteadOf,
      from: content(_midSentence(swap.fromItem, lang)),
      toLabel: l10n.swapsTry,
      to: content(swap.toItem),
      why: content(swap.why),
      tipLabel: l10n.swapsTip,
      tip: tip.isEmpty ? null : content(tip),
      meta: [
        l10n.swapsEffortLevel(swap.effort.id),
        l10n.swapsCostLevel(swap.cost.id),
      ],
      categoryId: swap.category.id,
      badge: badge,
      footer: !hasImpact && swap.sources.isEmpty
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasImpact)
                  MergeSemantics(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.only(top: 2),
                          child: Icon(
                            KanzIcons.leaf,
                            size: 16,
                            color: c.inkSecondary,
                          ),
                        ),
                        const SizedBox(width: KanzSpace.s8),
                        Expanded(
                          child: Text(content(impact), style: t.bodySmall),
                        ),
                      ],
                    ),
                  ),
                if (hasImpact && swap.sources.isNotEmpty)
                  const SizedBox(height: KanzSpace.s16),
                if (swap.sources.isNotEmpty)
                  SourceChips(
                    title: l10n.swapsSources,
                    sources: [for (final s in swap.sources) content(s.title)],
                  ),
              ],
            ),
    );
  }
}

/// "Single-use plastic bags" as it reads after "Instead of": English item
/// names start lower case mid-sentence, unless the first word is an
/// abbreviation ("PET bottles").
String _midSentence(String item, Lang lang) {
  final text = item.trim();
  if (lang != Lang.en || text.length < 2) return text;
  final firstWord = text.split(' ').first;
  if (firstWord.length > 1 && firstWord == firstWord.toUpperCase()) {
    return text;
  }
  return text[0].toLowerCase() + text.substring(1);
}

/// [text] wrapped in a Unicode directional isolate when the advisor wrote
/// it in the other direction than the app's, so its punctuation and
/// numbers stay where they belong inside the card's layout.
String _inContentDirection(BuildContext context, String text, Lang lang) {
  final direction = lang == Lang.ar ? TextDirection.rtl : TextDirection.ltr;
  if (Directionality.of(context) == direction) return text;
  // LRI or RLI, then PDI, from their code points (no invisible characters
  // in the source).
  final open = String.fromCharCode(
    direction == TextDirection.ltr ? 0x2066 : 0x2067,
  );
  return '$open$text${String.fromCharCode(0x2069)}';
}

/// Before the first request: what the tab will give back, so the empty
/// space under the form teaches the next step instead of sitting blank.
class SwapsHowItWorks extends StatelessWidget {
  const SwapsHowItWorks({super.key, required this.title, required this.lines});

  final String title;
  final List<(IconData, String)> lines;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Padding(
      padding: KanzSpace.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoLabel(title),
          const SizedBox(height: KanzSpace.s12),
          for (final (icon, text) in lines)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: KanzSpace.s12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 2),
                    child: Icon(icon, size: 18, color: c.inkSecondary),
                  ),
                  const SizedBox(width: KanzSpace.s12),
                  Expanded(
                    child: Text(
                      text,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: c.inkSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
