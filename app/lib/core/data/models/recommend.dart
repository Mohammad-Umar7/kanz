/// POST /v1/recommend: analysis + profile -> routing, upcycle ideas, recycle,
/// donate and drop-off categories (mirror of `backend/app/schemas/recommend.py`).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'analysis.dart';
import 'common.dart';
import 'vocab_enums.dart';

part 'recommend.freezed.dart';
part 'recommend.g.dart';

@freezed
abstract class RecommendRequest with _$RecommendRequest {
  const factory RecommendRequest({
    required String imageId,

    /// The analysis, possibly corrected by the user (`user_corrected: true`).
    required Analysis analysis,
    @Default(Profile()) Profile profile,

    /// Item to focus ideas on; the backend defaults to `primary_item_id`.
    String? focusItemId,
  }) = _RecommendRequest;

  factory RecommendRequest.fromJson(Map<String, dynamic> json) =>
      _$RecommendRequestFromJson(json);
}

@freezed
abstract class UpcycleIdea with _$UpcycleIdea {
  const factory UpcycleIdea({
    /// Backend-assigned stable id: 'idea_<8 hex>'.
    required String id,
    required String title,
    required String pitch,
    required Difficulty difficulty,
    required int timeMinutes,

    /// Tools (not safety gear) the project needs.
    required List<ToolId> toolsNeeded,
    required List<ToolId> toolsHave,
    required List<ToolId> toolsMissing,
    required List<String> usesItemIds,
    @Default(<String>[]) List<String> extraMaterials,

    /// English description of the finished object; drives the after image.
    required String afterVisual,
    String? safetyNote,
    @Default(<SourceRef>[]) List<SourceRef> sources,
  }) = _UpcycleIdea;

  factory UpcycleIdea.fromJson(Map<String, dynamic> json) =>
      _$UpcycleIdeaFromJson(json);
}

@freezed
abstract class RecycleInstruction with _$RecycleInstruction {
  const factory RecycleInstruction({
    required String itemId,
    required RecyclabilityStatus status,
    required String stream,
    required List<String> prepSteps,
    required List<String> dos,
    required List<String> donts,
    String? note,
  }) = _RecycleInstruction;

  factory RecycleInstruction.fromJson(Map<String, dynamic> json) =>
      _$RecycleInstructionFromJson(json);
}

@freezed
abstract class RecyclePath with _$RecyclePath {
  const factory RecyclePath({
    required List<RecycleInstruction> instructions,
    @Default(<SourceRef>[]) List<SourceRef> sources,
  }) = _RecyclePath;

  factory RecyclePath.fromJson(Map<String, dynamic> json) =>
      _$RecyclePathFromJson(json);
}

@freezed
abstract class DonateOption with _$DonateOption {
  const factory DonateOption({
    required String itemId,
    required bool suitable,

    /// Why it can (or can't) be donated, based on its condition.
    required String reason,

    /// Localized kinds of places: 'Clothing donation bins'.
    @Default(<String>[]) List<String> where,
    @Default(<String>[]) List<String> prepSteps,
  }) = _DonateOption;

  factory DonateOption.fromJson(Map<String, dynamic> json) =>
      _$DonateOptionFromJson(json);
}

@freezed
abstract class DonatePath with _$DonatePath {
  const factory DonatePath({
    /// True if at least one item is suitable for donation or reuse.
    required bool available,
    required String summary,
    required List<DonateOption> options,
  }) = _DonatePath;

  factory DonatePath.fromJson(Map<String, dynamic> json) =>
      _$DonatePathFromJson(json);
}

/// Disposal-only guidance for a hazardous item (no DIY).
@freezed
abstract class DisposalGuidance with _$DisposalGuidance {
  const factory DisposalGuidance({
    required String itemId,
    required HazardFlag hazard,
    required String headline,
    required List<String> steps,
    required List<String> never,
  }) = _DisposalGuidance;

  factory DisposalGuidance.fromJson(Map<String, dynamic> json) =>
      _$DisposalGuidanceFromJson(json);
}

/// A kind of drop-off point to search for; keys come from the backend catalog.
@freezed
abstract class FacilityCategory with _$FacilityCategory {
  const factory FacilityCategory({
    /// 'glass', 'textile_donation', 'battery', 'e_waste', ...
    required String key,
    required String label,
    required List<FacilityType> facilityTypes,
    required List<MaterialCategory> materialCategories,

    /// Scan items that need this category (empty in catalog listings).
    @Default(<String>[]) List<String> itemIds,
  }) = _FacilityCategory;

  factory FacilityCategory.fromJson(Map<String, dynamic> json) =>
      _$FacilityCategoryFromJson(json);
}

/// Safety Router decision: diy (no hazards), mixed (some hazardous items),
/// disposal_only (every item hazardous).
enum RoutingMode {
  @JsonValue('diy')
  diy,
  @JsonValue('mixed')
  mixed,
  @JsonValue('disposal_only')
  disposalOnly,
}

@freezed
abstract class Routing with _$Routing {
  const factory Routing({
    required RoutingMode mode,
    @Default(<String>[]) List<String> hazardousItemIds,

    /// Localized one-liner shown when DIY is withheld.
    String? reason,
  }) = _Routing;

  factory Routing.fromJson(Map<String, dynamic> json) =>
      _$RoutingFromJson(json);
}

@freezed
abstract class RecommendResponse with _$RecommendResponse {
  const factory RecommendResponse({
    required Routing routing,

    /// Exactly 3 ideas unless `routing.mode` is disposal_only (then empty).
    required List<UpcycleIdea> upcycle,
    required RecyclePath recycle,
    required DonatePath donate,
    @Default(<DisposalGuidance>[]) List<DisposalGuidance> disposal,
    required List<FacilityCategory> facilityCategories,
    required Lang lang,
    @Default(<String, int>{}) Timings timingsMs,
  }) = _RecommendResponse;

  const RecommendResponse._();

  factory RecommendResponse.fromJson(Map<String, dynamic> json) =>
      _$RecommendResponseFromJson(json);

  UpcycleIdea? ideaById(String id) =>
      upcycle.where((i) => i.id == id).firstOrNull;
}
