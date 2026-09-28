// Swaps test data: a fake controller and states built from the contract
// fixture (English) and its Arabic counterpart in data/.
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/core/state/swaps_controller.dart';

import '../../core/support/fixtures.dart';
import '../dropoff/tab_test_support.dart';

/// Records every action and applies the local ones like the real
/// controller; `submit` only records (tests set the outcome with [emit]).
class FakeSwapsController extends SwapsController {
  FakeSwapsController(this.initial);

  final SwapsState initial;
  final List<String> calls = [];

  @override
  SwapsState build() => initial;

  void emit(SwapsState next) => state = next;

  @override
  void toggleChip(String chip) {
    calls.add('toggleChip:$chip');
    super.toggleChip(chip);
  }

  @override
  void setFreeText(String text) {
    calls.add('setFreeText:$text');
    super.setFreeText(text);
  }

  @override
  void setUseHistory({required bool enabled}) {
    calls.add('setUseHistory:$enabled');
    super.setUseHistory(enabled: enabled);
  }

  @override
  void clear() {
    calls.add('clear');
    state = state.copyWith(
      selectedChips: const {},
      freeText: '',
      results: null,
      error: null,
      loading: false,
    );
  }

  @override
  Future<void> refreshHistory() async => calls.add('refreshHistory');

  @override
  Future<void> submit() async {
    calls.add('submit:${state.requestMaterials.join('|')}');
    state = state.copyWith(loading: true);
  }
}

/// The contract fixture (English) or its Arabic counterpart. The first swap
/// carries the impact note the knowledge base has for it, as live answers
/// do.
SwapsResponse swapsResponse({required bool ar}) {
  final response = SwapsResponse.fromJson(
    ar
        ? readJson('test/screens/swaps/data/swaps_plastic_ar.json')
        : fixture('swaps_plastic.json'),
  );
  final first = response.swaps.first;
  return response.copyWith(
    swaps: [
      first.copyWith(
        impactNote:
            first.impactNote ??
            (ar
                ? 'أكياس رقيقة أقل في التداول تعني نفايات أقل تتطاير مع الريح، '
                      'وبلاستيكًا أقل تبتلعه الحيوانات.'
                : 'Fewer thin bags in circulation means less wind-blown '
                      'litter and less plastic that animals can swallow.'),
      ),
      ...response.swaps.skip(1),
    ],
  );
}

const history = HistorySummary(
  counts: {MaterialCategory.plastic: 6, MaterialCategory.glass: 2},
  topItems: ['plastic bottle', 'jam jar'],
  topItemCounts: [6, 2],
);

/// Nothing picked yet, no scans: the button waits for a choice.
const SwapsState emptyForm = SwapsState(history: HistorySummary());

/// Two chips picked and a history to personalize with.
SwapsState filledForm() => const SwapsState(
  selectedChips: {'plastic_bags', 'cling_film'},
  history: history,
);

SwapsState loadingState() => filledForm().copyWith(loading: true);

SwapsState resultsState({required bool ar}) =>
    filledForm().copyWith(results: swapsResponse(ar: ar));

SwapsState noMatchState() => const SwapsState(
  freeText: 'old crayons',
  history: HistorySummary(),
  results: SwapsResponse(swaps: [], lang: Lang.en),
);

SwapsState errorState(ApiException error) =>
    filledForm().copyWith(error: error);

const aiUnavailable = ApiException(
  code: ApiErrorCode.aiUnavailable,
  message: 'The AI service is busy.',
  retryable: true,
  requestId: 'req_5f3c2a1b',
);
