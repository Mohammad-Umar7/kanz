import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/models/models.dart';
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
import '../../core/network/api_exception.dart';
import '../../core/state/core_providers.dart';
import '../../core/state/swaps_controller.dart';
import '../../l10n/l10n.dart';
import 'swap_chips.dart';
import 'swap_results.dart';

/// Swaps tab (`/swaps`): pick the things that keep landing in the bin (chips
/// or free text), optionally let Kanz read the last 30 days of scans, and
/// get one lasting alternative for each, with a tip, effort and cost, and
/// the knowledge documents behind it.
class SwapsScreen extends ConsumerStatefulWidget {
  const SwapsScreen({super.key});

  @override
  ConsumerState<SwapsScreen> createState() => _SwapsScreenState();
}

class _SwapsScreenState extends ConsumerState<SwapsScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  final _resultsKey = GlobalKey(debugLabel: 'swaps-results');

  /// What the shown results answer, to offer "Update swaps" after changes.
  List<String>? _submittedFor;

  SwapsController get _controller => ref.read(swapsControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _text.text = ref.read(swapsControllerProvider).freeText;
  }

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final state = ref.read(swapsControllerProvider);
    if (!state.canSubmit || state.loading) return;
    FocusScope.of(context).unfocus();
    setState(() => _submittedFor = state.requestMaterials);
    final request = _controller.submit();
    // Bring the loading cards into view once they are laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _resultsKey.currentContext;
      if (target == null || !mounted) return;
      unawaited(
        Scrollable.ensureVisible(
          target,
          duration: KanzMotion.of(context, KanzMotion.slow),
          curve: KanzMotion.emphasized,
        ),
      );
    });
    await request;
  }

  void _startOver() {
    _controller.clear();
    _text.clear();
    setState(() => _submittedFor = null);
    if (_scroll.hasClients) {
      unawaited(
        _scroll.animateTo(
          0,
          duration: KanzMotion.of(context, KanzMotion.slow),
          curve: KanzMotion.emphasized,
        ),
      );
    }
  }

  /// "Finding swaps for plastic bags and cling film".
  String _loadingLabel(SwapsState state) {
    final l10n = context.l10n;
    final entries = state.requestMaterials;
    if (entries.isEmpty) return l10n.swapsLoadingHistory;
    return l10n.swapsLoading(
      formatList(l10n, [
        for (final e in entries) swapEntryLabel(l10n, e, inSentence: true),
      ], sentence: true),
    );
  }

  Widget _historyPreview(HistorySummary history, Vocab vocab, bool on) {
    final t = context.textStyles;
    final locale = Localizations.localeOf(context);
    final counts = history.counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return AnimatedOpacity(
      opacity: on ? 1 : 0.45,
      duration: KanzMotion.of(context, KanzMotion.fast),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          KanzSpace.gutter,
          0,
          KanzSpace.gutter,
          KanzSpace.s12,
        ),
        child: Wrap(
          spacing: KanzSpace.s16,
          runSpacing: KanzSpace.s8,
          children: [
            for (final entry in counts.take(5))
              MergeSemantics(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MaterialDot(entry.key.id),
                    const SizedBox(width: KanzSpace.s8),
                    Text(
                      vocab.material(entry.key).label.forLocale(locale),
                      style: t.bodySmall?.copyWith(
                        color: context.kanzColors.ink,
                      ),
                    ),
                    const SizedBox(width: KanzSpace.s4),
                    MonoLabel(
                      '${entry.value}',
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _results(SwapsState state, Vocab vocab) {
    final l10n = context.l10n;
    if (state.loading) return [SwapsLoading(label: _loadingLabel(state))];
    if (state.error case final error?) {
      final offline = error.code == ApiErrorCode.offline;
      return [
        ErrorState(
          icon: offline ? KanzIcons.noWifi : KanzIcons.error,
          title: offline ? l10n.swapsOfflineTitle : l10n.swapsErrorTitle,
          message: apiErrorMessage(l10n, error),
          retryLabel: l10n.commonRetry,
          onRetry: error.retryable && state.canSubmit ? _submit : null,
          code: offline ? null : _supportCode(error),
          codeLabel: l10n.commonSupportCode,
        ),
      ];
    }
    final results = state.results;
    if (results == null) {
      return [
        SwapsHowItWorks(
          title: l10n.swapsHowTitle,
          lines: [
            (KanzIcons.swaps, l10n.swapsHowSwap),
            (KanzIcons.tip, l10n.swapsHowTip),
            (KanzIcons.source, l10n.swapsHowCost),
          ],
        ),
      ];
    }
    if (results.swaps.isEmpty) {
      return [
        EmptyState(
          icon: KanzIcons.swaps,
          title: l10n.swapsEmptyTitle,
          message: l10n.swapsEmptyMessage,
        ),
      ];
    }
    final generation = identityHashCode(results);
    return [
      SectionHeader(
        eyebrow: l10n.swapsCount(results.swaps.length),
        title: l10n.swapsResultsTitle,
        large: true,
      ),
      if (results.historyInsight case final insight?
          when insight.trim().isNotEmpty) ...[
        const SizedBox(height: KanzSpace.s16),
        SwapsInsight(label: l10n.swapsInsightLabel, insight: insight),
      ],
      const SizedBox(height: KanzSpace.s20),
      for (var i = 0; i < results.swaps.length; i++) ...[
        if (i > 0) const SizedBox(height: KanzSpace.s24),
        FadeUp.staggered(
          key: ValueKey('swap-$generation-${results.swaps[i].id}'),
          index: i,
          child: Padding(
            padding: KanzSpace.page,
            child: SwapEntry(
              swap: results.swaps[i],
              vocab: vocab,
              lang: results.lang,
            ),
          ),
        ),
      ],
      const SizedBox(height: KanzSpace.s24),
      Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: KanzSpace.s8,
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: KanzButton.tertiary(
            label: l10n.swapsStartOver,
            icon: KanzIcons.undo,
            onPressed: _startOver,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final state = ref.watch(swapsControllerProvider);
    final vocab = ref.watch(vocabProvider);
    ref.listen(swapsControllerProvider.select((s) => s.freeText), (_, next) {
      if (_text.text != next) _text.text = next;
    });

    final stale =
        state.results != null &&
        _submittedFor != null &&
        !listEquals(_submittedFor, state.requestMaterials);
    final history = state.history;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          controller: _scroll,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsetsDirectional.only(bottom: KanzSpace.s48),
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                KanzSpace.gutter,
                KanzSpace.s12,
                KanzSpace.gutter,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(l10n.swapsTitle, style: t.headlineLarge),
                  ),
                  const SizedBox(height: KanzSpace.s8),
                  Text(
                    l10n.swapsIntro,
                    style: t.bodyMedium?.copyWith(color: c.inkSecondary),
                  ),
                  const SizedBox(height: KanzSpace.s24),
                  MonoLabel(l10n.swapsChipsLabel),
                  const SizedBox(height: KanzSpace.s4),
                  Wrap(
                    spacing: KanzSpace.s8,
                    children: [
                      for (final option in swapChipOptions)
                        KanzChip(
                          key: ValueKey('swap-chip-${option.id}'),
                          label: option.label(l10n),
                          materialId: option.materialId,
                          selected: state.selectedChips.contains(option.id),
                          onSelected: (_) => _controller.toggleChip(option.id),
                        ),
                    ],
                  ),
                  const SizedBox(height: KanzSpace.s16),
                  KanzTextField(
                    controller: _text,
                    label: l10n.swapsFreeTextLabel,
                    hint: l10n.swapsFreeTextHint,
                    helper: l10n.swapsFreeTextHelper,
                    prefixIcon: KanzIcons.add,
                    textInputAction: TextInputAction.done,
                    onChanged: _controller.setFreeText,
                    onSubmitted: (_) => _submit(),
                  ),
                ],
              ),
            ),
            if (state.hasHistory && history != null) ...[
              const SizedBox(height: KanzSpace.s16),
              Divider(height: 1, color: c.line),
              KanzSwitchTile(
                title: l10n.swapsHistoryTitle,
                subtitle: l10n.swapsHistorySubtitle(history.periodDays),
                value: state.useHistory,
                onChanged: (on) => _controller.setUseHistory(enabled: on),
              ),
              _historyPreview(history, vocab, state.useHistory),
              Divider(height: 1, color: c.line),
            ],
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                KanzSpace.gutter,
                KanzSpace.s24,
                KanzSpace.gutter,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KanzButton(
                    label: stale ? l10n.swapsUpdate : l10n.swapsSubmit,
                    trailingIcon: KanzIcons.forward,
                    onPressed: state.canSubmit ? _submit : null,
                    loading: state.loading,
                    loadingLabel: _loadingLabel(state),
                    expand: true,
                  ),
                  if (!state.canSubmit) ...[
                    const SizedBox(height: KanzSpace.s8),
                    Text(l10n.swapsSubmitHint, style: t.bodySmall),
                  ],
                ],
              ),
            ),
            SizedBox(key: _resultsKey, height: KanzSpace.s40),
            ..._results(state, vocab),
          ],
        ),
      ),
    );
  }
}

/// What support needs to find a failure: the request id, with the error
/// code as the backend spells it ("ai_unavailable") in debug builds. Null
/// when there is nothing to look up.
String? _supportCode(ApiException error) {
  final id = error.requestId;
  if (id == null) return null;
  return [if (kDebugMode) error.code.wireId, id].join(' · ');
}
