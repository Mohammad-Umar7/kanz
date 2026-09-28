import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../core/data/models/models.dart';
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
import '../../core/network/api_exception.dart';
import '../../l10n/l10n.dart';

/// Turns analysis and recommendation data into the words the results and
/// idea screens show: vocabulary labels in the UI language, percentages,
/// durations, lists and tool matches. Numbers keep Western digits in both
/// languages (see lib/l10n/l10n.dart).
class ResultsFormat {
  ResultsFormat(this.l10n, this.vocab, this.locale, {this.contentLang});

  /// [content] is the language the AI wrote the scan's text in.
  factory ResultsFormat.of(
    BuildContext context,
    Vocab vocab, {
    Lang? content,
  }) => ResultsFormat(
    context.l10n,
    vocab,
    Localizations.localeOf(context),
    contentLang: content,
  );

  final AppLocalizations l10n;
  final Vocab vocab;
  final Locale locale;

  /// The language of the scan's AI text (item names, pitches, advice). It
  /// differs from the UI's when a scan made in one language is reopened
  /// after switching to the other.
  final Lang? contentLang;

  /// The direction of the AI's text when it differs from the UI's, else
  /// null.
  TextDirection? get contentDirection {
    final lang = contentLang;
    if (lang == null) return null;
    final contentArabic = lang == Lang.ar;
    if (contentArabic == (locale.languageCode == 'ar')) return null;
    return contentArabic ? TextDirection.rtl : TextDirection.ltr;
  }

  /// [text] written by the AI, isolated in its own direction when that
  /// differs from the UI's. The label around it keeps the UI's alignment,
  /// while its punctuation and numbers stay where its language puts them:
  /// "Four used AA batteries." in an Arabic layout, never
  /// ".Four used AA batteries". Each line is isolated on its own, since an
  /// isolate ends at a line break.
  String ai(String text) {
    final direction = contentDirection;
    if (direction == null) return text;
    final open = direction == TextDirection.ltr ? '\u2066' : '\u2067';
    return text.split('\n').map((line) => '$open$line\u2069').join('\n');
  }

  /// [lines] from the AI, each isolated like [ai].
  List<String> aiLines(List<String> lines) => [for (final l in lines) ai(l)];

  String category(MaterialCategory id) =>
      vocab.material(id).label.forLocale(locale);

  String stateTag(StateTag id) => vocab.stateTag(id).label.forLocale(locale);

  String hazard(HazardFlag id) => vocab.hazard(id).label.forLocale(locale);

  String tool(ToolId id) => vocab.tool(id).label.forLocale(locale);

  String facilityType(FacilityType id) =>
      vocab.facilityType(id).label.forLocale(locale);

  String city(CityId id) => vocab.city(id).label.forLocale(locale);

  String qualityLabel(int score) => vocab.qualityLabel(score).forLocale(locale);

  /// "93%".
  String confidence(double value) => '${(value * 100).round()}%';

  /// "4.2" (seconds, one decimal).
  String seconds(Duration duration) =>
      (duration.inMilliseconds / 1000).toStringAsFixed(1);

  /// "01", the position of an item or idea (always Western digits).
  String index(int oneBased) => oneBased.toString().padLeft(2, '0');

  /// "Glass, paper and plastic" / "زجاج، ورق وبلاستيك".
  String list(List<String> items) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items.single;
    final separator = locale.languageCode == 'ar' ? '، ' : ', ';
    return l10n.resultsListAnd(
      items.sublist(0, items.length - 1).join(separator),
      items.last,
    );
  }

  /// The short tag on an item's bounding box: "Glass · 93%" for a single
  /// item, "01 · Glass" when several share the photo, so each box points to
  /// its numbered card.
  String boxLabel(Item item, {required int index, required int count}) =>
      count > 1
      ? '${this.index(index)} · ${category(item.category)}'
      : '${category(item.category)} · ${confidence(item.confidence)}';

  String unit(String unit) => switch (unit) {
    'pcs' => l10n.resultsUnitPcs,
    'kg' => l10n.resultsUnitKg,
    'g' => l10n.resultsUnitG,
    'm' => l10n.resultsUnitM,
    'm2' => l10n.resultsUnitM2,
    'L' => l10n.resultsUnitL,
    'handful' => l10n.resultsUnitHandful,
    'bag' => l10n.resultsUnitBag,
    _ => unit,
  };

  /// Which of an idea's tools the user owns right now (protective gear is
  /// never counted: it is always recommended, never owned).
  ToolMatch toolMatch(UpcycleIdea idea, List<ToolId> owned) {
    final needed = [
      for (final t in idea.toolsNeeded)
        if (!t.isSafetyGear) t,
    ];
    final have = [
      for (final t in needed)
        if (owned.contains(t)) t,
    ];
    final missing = [
      for (final t in needed)
        if (!owned.contains(t)) t,
    ];
    final label = needed.isEmpty
        ? l10n.resultsToolsNone
        : missing.isEmpty
        ? l10n.resultsToolsAll
        : have.isEmpty
        ? l10n.resultsToolsNeeded(needed.length)
        : l10n.resultsToolsSome(have.length, needed.length);
    return ToolMatch(have: have, missing: missing, label: label);
  }

  /// The quiet source tags under ideas and advice, without duplicates.
  List<String> sourceTitles(Iterable<SourceRef> sources) {
    final seen = <String>{};
    return [
      for (final s in sources)
        if (seen.add(s.id)) ai(s.title),
    ];
  }

  /// Everything a specimen card shows for [item].
  SpecimenCard specimenCard(
    Item item, {
    String? index,
    bool compact = false,
    bool selected = false,
    VoidCallback? onTap,
    VoidCallback? onEdit,
  }) {
    final disposal = [
      for (final h in item.hazards)
        if (h.isDisposalOnly) hazard(h),
    ];
    final notes = [
      if (item.userCorrected) l10n.resultsCorrectedNote,
      if (item.quality.notes case final note? when note.trim().isNotEmpty)
        ai(note.trim()),
    ];
    return SpecimenCard(
      labels: SpecimenLabels(
        material: l10n.resultsLabelMaterial,
        type: l10n.resultsLabelType,
        quantity: l10n.resultsLabelQuantity,
        quality: l10n.resultsLabelQuality,
        state: l10n.resultsLabelState,
        recyclable: l10n.resultsLabelRecyclable,
        confidence: l10n.resultsLabelConfidence,
        edit: l10n.resultsEditItem,
      ),
      categoryId: item.category.id,
      categoryLabel: category(item.category),
      name: ai(item.name),
      material: ai(item.material),
      quantity: ai(item.quantity.display),
      qualityScore: item.quality.score.clamp(0, 5),
      qualityLabel: ai(item.quality.label),
      qualitySemantics: l10n.resultsQualitySemantics(
        item.quality.score,
        item.quality.label,
      ),
      stateLabels: [for (final s in item.state) stateTag(s)],
      recyclable: switch (item.recyclability.status) {
        RecyclabilityStatus.yes => SpecimenRecyclable.yes,
        RecyclabilityStatus.conditional => SpecimenRecyclable.conditional,
        RecyclabilityStatus.no => SpecimenRecyclable.no,
      },
      recyclableLabel: item.recyclability.stream.trim().isEmpty
          ? recyclabilityLabel(l10n, item.recyclability.status)
          : l10n.resultsRecyclableValue(
              recyclabilityLabel(l10n, item.recyclability.status),
              ai(item.recyclability.stream),
            ),
      confidence: confidence(item.confidence),
      hazardLabel: disposal.isEmpty
          ? null
          : l10n.resultsHazardLabel(list(disposal)),
      note: compact || notes.isEmpty ? null : notes.join(' '),
      index: index,
      compact: compact,
      selected: selected,
      onTap: onTap,
      onEdit: onEdit,
    );
  }
}

/// An idea's tools split by what the user owns, with the badge sentence.
class ToolMatch {
  const ToolMatch({
    required this.have,
    required this.missing,
    required this.label,
  });

  final List<ToolId> have;
  final List<ToolId> missing;
  final String label;

  int get total => have.length + missing.length;

  ToolMatchBadge badge() =>
      ToolMatchBadge(label: label, have: have.length, total: total);
}

/// What support needs to find a failure: the request id, with the error
/// code as the backend spells it ("ai_unavailable") in debug builds. Null
/// when there is nothing to look up (an offline failure never reached the
/// server).
String? supportCode(ApiException? error) {
  final id = error?.requestId;
  if (error == null || id == null) return null;
  return [if (kDebugMode) error.code.wireId, id].join(' · ');
}
