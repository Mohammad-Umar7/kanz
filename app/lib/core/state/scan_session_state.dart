import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/models/models.dart';
import '../data/vocab/vocab.dart';
import '../network/api_exception.dart';
import 'generated_image.dart';
import 'location_resolver.dart';

part 'scan_session_state.freezed.dart';

/// The four honest stages of a scan, one per backend call (docs/API.md).
enum PipelineStage {
  /// POST /v1/analyze: "Identifying materials".
  identifying,

  /// POST /v1/recommend: "Checking safety and finding ideas".
  ideas,

  /// POST /v1/facilities: "Locating drop-off points".
  dropoff,

  /// POST /v1/images/after x3: "Rendering makeovers".
  makeovers,
}

enum StageStatus {
  pending,
  running,
  done,

  /// See [StageState.error]. For `identifying` with
  /// [ScanSessionState.rejectedPhoto] set, show the retake tip instead.
  failed,

  /// Nothing to do: no DIY ideas (disposal only) or no drop-off categories.
  skipped,

  /// Drop-off only: the user has not chosen GPS or a city yet. Show the
  /// location rationale or city picker, then call `resumeDropoff()`.
  needsLocation,
}

@freezed
abstract class StageState with _$StageState {
  const factory StageState({
    @Default(StageStatus.pending) StageStatus status,
    ApiException? error,
  }) = _StageState;

  const StageState._();

  bool get isRunning => status == StageStatus.running;
  bool get isDone => status == StageStatus.done;
  bool get isFailed => status == StageStatus.failed;
}

/// Where the session came from.
enum ScanOrigin {
  /// Looking up the scan in local history.
  loading,

  /// Started on this run of the app.
  live,

  /// Reopened from history (works offline).
  restored,

  /// No scan with this id exists.
  missing,
}

@freezed
abstract class ScanSessionState with _$ScanSessionState {
  const factory ScanSessionState({
    required String scanId,
    @Default(ScanOrigin.loading) ScanOrigin origin,
    @Default(AnalysisSource.image) AnalysisSource source,
    @Default(Lang.en) Lang lang,

    /// The typed description, for text scans.
    String? inputText,

    /// The compressed photo on the device (hero image, offline thumbnail).
    String? localImagePath,
    @Default(<PipelineStage, StageState>{})
    Map<PipelineStage, StageState> stages,
    AnalyzeResponse? analysis,

    /// Set when the model judged the photo unusable (blurry, dark, no items):
    /// show [PhotoCheck.retakeTip] and a retake button.
    PhotoCheck? rejectedPhoto,
    RecommendResponse? recommendation,
    FacilitiesResponse? facilities,

    /// Where the drop-off search ran (GPS, chosen city or nearest city).
    SearchLocation? dropoffLocation,

    /// Idea id -> after image.
    @Default(<String, GeneratedImageState>{})
    Map<String, GeneratedImageState> afterImages,

    /// Item the ideas focus on (null: the analysis' primary item).
    String? focusItemId,
  }) = _ScanSessionState;

  const ScanSessionState._();

  StageState stage(PipelineStage s) => stages[s] ?? const StageState();

  /// True while any stage is running.
  bool get isBusy => stages.values.any((s) => s.isRunning);

  List<Item> get items => analysis?.analysis.items ?? const [];

  List<UpcycleIdea> get ideas => recommendation?.upcycle ?? const [];

  Item? itemById(String id) => analysis?.analysis.itemById(id);

  /// The item recommendations are about.
  Item? get focusItem =>
      (focusItemId == null ? null : itemById(focusItemId!)) ??
      analysis?.analysis.primaryItem;

  bool get isDisposalOnly =>
      recommendation?.routing.mode == RoutingMode.disposalOnly;

  GeneratedImageState afterImage(String ideaId) =>
      afterImages[ideaId] ?? const GeneratedImageState();
}

/// A user's edit of one analyzed item on the results screen. Null fields keep
/// the model's value.
@freezed
abstract class ItemCorrection with _$ItemCorrection {
  const factory ItemCorrection({
    String? name,
    MaterialCategory? category,
    String? material,
    double? quantityValue,
    String? quantityUnit,
    int? qualityScore,
    List<StateTag>? state,
    List<HazardFlag>? hazards,
  }) = _ItemCorrection;

  const ItemCorrection._();

  /// Applies the edit and marks the item `user_corrected` so the backend
  /// trusts it over its own reading. Display strings are rebuilt from [vocab].
  Item applyTo(Item item, {required Vocab vocab, required Lang lang}) {
    final quantity = (quantityValue != null || quantityUnit != null)
        ? Quantity(
            value: quantityValue ?? item.quantity.value,
            unit: quantityUnit ?? item.quantity.unit,
            isEstimate: false,
            display: _formatQuantity(
              quantityValue ?? item.quantity.value,
              quantityUnit ?? item.quantity.unit,
            ),
          )
        : item.quantity;
    final quality = qualityScore != null
        ? Quality(
            score: qualityScore!.clamp(1, 5),
            label: vocab.qualityLabel(qualityScore!).of(lang),
            notes: item.quality.notes,
          )
        : item.quality;
    return item.copyWith(
      name: name ?? item.name,
      category: category ?? item.category,
      material: material ?? item.material,
      quantity: quantity,
      quality: quality,
      state: state ?? item.state,
      hazards: hazards ?? item.hazards,
      userCorrected: true,
    );
  }

  static String _formatQuantity(double value, String unit) {
    final number = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    return '$number $unit';
  }
}
