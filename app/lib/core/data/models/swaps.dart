/// POST /v1/swaps: materials the user often throws away -> eco-friendly swaps
/// (mirror of `backend/app/schemas/swaps.py`).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'common.dart';
import 'vocab_enums.dart';

part 'swaps.freezed.dart';
part 'swaps.g.dart';

/// Computed on the device from scan history so the Swap Advisor can personalize.
@freezed
abstract class HistorySummary with _$HistorySummary {
  const factory HistorySummary({
    @Default(30) int periodDays,

    /// Items scanned per material.
    @Default(<MaterialCategory, int>{}) Map<MaterialCategory, int> counts,

    /// Most frequent item names, e.g. 'plastic bottle'.
    @Default(<String>[]) List<String> topItems,

    /// Counts aligned with [topItems].
    @Default(<int>[]) List<int> topItemCounts,
  }) = _HistorySummary;

  const HistorySummary._();

  factory HistorySummary.fromJson(Map<String, dynamic> json) =>
      _$HistorySummaryFromJson(json);

  bool get isEmpty => counts.isEmpty && topItems.isEmpty;
}

@freezed
abstract class SwapsRequest with _$SwapsRequest {
  const factory SwapsRequest({
    /// Chip ids and/or free text: 'plastic bags', 'cling film'.
    @Default(<String>[]) List<String> materials,
    HistorySummary? history,
    @Default(Lang.en) Lang lang,
  }) = _SwapsRequest;

  factory SwapsRequest.fromJson(Map<String, dynamic> json) =>
      _$SwapsRequestFromJson(json);
}

@freezed
abstract class Swap with _$Swap {
  const factory Swap({
    required String id,

    /// What it replaces, localized.
    required String fromItem,

    /// The alternative, localized.
    required String toItem,
    required String why,

    /// One practical tip for making the switch.
    required String tip,
    required Level effort,
    required Level cost,

    /// Material of the thing being replaced.
    required MaterialCategory category,

    /// Qualitative, unless a knowledge-base source with a number is cited.
    String? impactNote,

    /// The user input this card answers.
    String? matchedInput,
    @Default(false) bool fromHistory,
    @Default(<SourceRef>[]) List<SourceRef> sources,
  }) = _Swap;

  factory Swap.fromJson(Map<String, dynamic> json) => _$SwapFromJson(json);
}

@freezed
abstract class SwapsResponse with _$SwapsResponse {
  const factory SwapsResponse({
    required List<Swap> swaps,

    /// 'You scanned 6 plastic bottles this month.'
    String? historyInsight,
    required Lang lang,
    @Default(<String, int>{}) Timings timingsMs,
  }) = _SwapsResponse;

  factory SwapsResponse.fromJson(Map<String, dynamic> json) =>
      _$SwapsResponseFromJson(json);
}
