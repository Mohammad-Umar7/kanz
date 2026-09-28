import 'dart:async';

import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/insights/history_summary.dart';
import '../data/models/models.dart';
import '../network/api_exception.dart';
import 'core_providers.dart';
import 'settings_providers.dart';

part 'swaps_controller.freezed.dart';

@freezed
abstract class SwapsState with _$SwapsState {
  const factory SwapsState({
    /// Selected chips: material category ids ('plastic') or chip phrases.
    @Default(<String>{}) Set<String> selectedChips,

    /// Free text such as "plastic bags, cling film".
    @Default('') String freeText,

    /// Send the last 30 days of scans so the advisor can personalize.
    @Default(true) bool useHistory,

    /// What the user scanned recently (null until computed).
    HistorySummary? history,
    @Default(false) bool loading,
    SwapsResponse? results,
    ApiException? error,
  }) = _SwapsState;

  const SwapsState._();

  /// Chips plus free text split on commas (Latin or Arabic) and new lines.
  List<String> get requestMaterials => [
    ...selectedChips,
    for (final part in freeText.split(RegExp('[,،\n]')))
      if (part.trim().isNotEmpty) part.trim(),
  ];

  bool get hasHistory => history != null && !history!.isEmpty;

  /// True when there is anything to ask about.
  bool get canSubmit =>
      requestMaterials.isNotEmpty || (useHistory && hasHistory);
}

/// The Swaps tab: chips, free text, history-based suggestions.
final swapsControllerProvider = NotifierProvider<SwapsController, SwapsState>(
  SwapsController.new,
);

class SwapsController extends Notifier<SwapsState> {
  static const historyDays = 30;

  CancelToken? _token;
  int _run = 0;

  @override
  SwapsState build() {
    ref.onDispose(() => _token?.cancel());
    scheduleMicrotask(refreshHistory);
    return const SwapsState();
  }

  void toggleChip(String chip) {
    final chips = {...state.selectedChips};
    if (!chips.remove(chip)) chips.add(chip);
    state = state.copyWith(selectedChips: chips);
  }

  void setFreeText(String text) => state = state.copyWith(freeText: text);

  void setUseHistory({required bool enabled}) =>
      state = state.copyWith(useHistory: enabled);

  void clear() {
    _token?.cancel();
    state = state.copyWith(
      selectedChips: const {},
      freeText: '',
      results: null,
      error: null,
      loading: false,
    );
  }

  /// Recomputes the scan summary from the local database.
  Future<void> refreshHistory() async {
    final since = DateTime.now().subtract(const Duration(days: historyDays));
    final analyses = await ref
        .read(scanRepositoryProvider)
        .analysesSince(since);
    if (!ref.mounted) return;
    state = state.copyWith(
      history: buildHistorySummary(analyses, periodDays: historyDays),
    );
  }

  /// POST /v1/swaps with the chips, free text and (optionally) the history.
  Future<void> submit() async {
    await refreshHistory();
    if (!ref.mounted || !state.canSubmit) return;
    _token?.cancel();
    final token = _token = CancelToken();
    final run = ++_run;
    state = state.copyWith(loading: true, error: null);
    try {
      final response = await ref
          .read(apiClientProvider)
          .swaps(
            SwapsRequest(
              materials: state.requestMaterials,
              history: state.useHistory && state.hasHistory
                  ? state.history
                  : null,
              lang: ref.read(contentLangProvider),
            ),
            cancelToken: token,
          );
      if (!ref.mounted || run != _run) return;
      state = state.copyWith(loading: false, results: response);
    } on ApiException catch (e) {
      if (!ref.mounted || run != _run || e.isCancelled) return;
      state = state.copyWith(loading: false, error: e);
    }
  }
}
