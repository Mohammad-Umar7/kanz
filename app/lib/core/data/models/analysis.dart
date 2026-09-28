/// POST /v1/analyze: photo or text -> structured material analysis
/// (mirror of `backend/app/schemas/analysis.py`).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'common.dart';
import 'vocab_enums.dart';

part 'analysis.freezed.dart';
part 'analysis.g.dart';

/// Bounding box normalized to 0..1 of the uploaded image, top-left origin.
///
/// Gemini returns `box_2d` as [ymin, xmin, ymax, xmax] on a 0..1000 grid; the
/// backend converts it, so the app only scales these by the rendered image size.
@freezed
abstract class BBox with _$BBox {
  const factory BBox({
    required double x,
    required double y,
    required double w,
    required double h,
  }) = _BBox;

  factory BBox.fromJson(Map<String, dynamic> json) => _$BBoxFromJson(json);
}

@freezed
abstract class Quantity with _$Quantity {
  const factory Quantity({
    required double value,

    /// 'pcs', 'kg', 'g', 'm', 'm2', 'L', 'handful', 'bag'.
    required String unit,
    required bool isEstimate,

    /// Ready to show, localized: '3 pcs', '~0.5 kg'.
    required String display,
  }) = _Quantity;

  factory Quantity.fromJson(Map<String, dynamic> json) =>
      _$QuantityFromJson(json);
}

/// Condition score: 1 poor, 2 worn, 3 fair, 4 good, 5 like new.
@freezed
abstract class Quality with _$Quality {
  const factory Quality({
    required int score,
    required String label,
    String? notes,
  }) = _Quality;

  factory Quality.fromJson(Map<String, dynamic> json) =>
      _$QualityFromJson(json);
}

@freezed
abstract class Recyclability with _$Recyclability {
  const factory Recyclability({
    required RecyclabilityStatus status,

    /// Where it goes, localized: 'Glass bottle bank'.
    required String stream,
    @Default(<String>[]) List<String> prepSteps,

    /// Why it is conditional or not recyclable.
    String? reason,
  }) = _Recyclability;

  factory Recyclability.fromJson(Map<String, dynamic> json) =>
      _$RecyclabilityFromJson(json);
}

@freezed
abstract class ReusePotential with _$ReusePotential {
  const factory ReusePotential({required Level level, required String note}) =
      _ReusePotential;

  factory ReusePotential.fromJson(Map<String, dynamic> json) =>
      _$ReusePotentialFromJson(json);
}

/// One item or raw material detected in the photo.
@freezed
abstract class Item with _$Item {
  const factory Item({
    /// Stable within a scan: 'item_1', 'item_2'...
    required String id,
    required String name,
    required MaterialCategory category,

    /// Specific material, localized: 'Clear soda-lime glass', 'PET #1'.
    required String material,
    int? resinCode,
    @Default(false) bool isRawMaterial,
    required Quantity quantity,
    required Quality quality,
    @Default(<StateTag>[]) List<StateTag> state,
    required Recyclability recyclability,
    required ReusePotential reuse,
    @Default(<HazardFlag>[]) List<HazardFlag> hazards,
    required double confidence,
    BBox? bbox,

    /// Set by the app when the user edited this item on the results screen.
    @Default(false) bool userCorrected,
  }) = _Item;

  const Item._();

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  /// True when any hazard routes the item to disposal-only guidance.
  bool get isDisposalOnly => hazards.any((h) => h.isDisposalOnly);
}

/// Why a photo cannot be analyzed.
enum PhotoIssue {
  @JsonValue('ok')
  ok,
  @JsonValue('blurry')
  blurry,
  @JsonValue('too_dark')
  tooDark,
  @JsonValue('too_far')
  tooFar,
  @JsonValue('too_close')
  tooClose,
  @JsonValue('cluttered')
  cluttered,
  @JsonValue('no_items')
  noItems,
  @JsonValue('glare')
  glare,
}

@freezed
abstract class PhotoCheck with _$PhotoCheck {
  const factory PhotoCheck({
    required bool usable,
    @Default(PhotoIssue.ok) PhotoIssue issue,

    /// One specific, localized tip when the photo is not usable.
    String? retakeTip,
  }) = _PhotoCheck;

  factory PhotoCheck.fromJson(Map<String, dynamic> json) =>
      _$PhotoCheckFromJson(json);
}

/// Whether the analysis came from a photo or from a text description.
enum AnalysisSource {
  @JsonValue('image')
  image,
  @JsonValue('text')
  text,
}

@freezed
abstract class Analysis with _$Analysis {
  const factory Analysis({
    required List<Item> items,
    required String summary,
    required PhotoCheck photo,
    String? primaryItemId,
    required AnalysisSource source,

    /// Label from the pluggable MaterialClassifier, when one is installed.
    String? classifierHint,
  }) = _Analysis;

  const Analysis._();

  factory Analysis.fromJson(Map<String, dynamic> json) =>
      _$AnalysisFromJson(json);

  Item? itemById(String id) => items.where((i) => i.id == id).firstOrNull;

  /// The item recommendations focus on by default.
  Item? get primaryItem =>
      (primaryItemId == null ? null : itemById(primaryItemId!)) ??
      items.firstOrNull;
}

@freezed
abstract class AnalyzeResponse with _$AnalyzeResponse {
  const factory AnalyzeResponse({
    /// 'img_...' for photos, 'txt_...' for text input.
    required String imageId,

    /// Path of the stored upload ('/static/uploads/...'); null for text input.
    required String? imageUrl,
    int? imageWidth,
    int? imageHeight,
    required Analysis analysis,
    required Lang lang,
    @Default(<String, int>{}) Timings timingsMs,
  }) = _AnalyzeResponse;

  factory AnalyzeResponse.fromJson(Map<String, dynamic> json) =>
      _$AnalyzeResponseFromJson(json);
}
