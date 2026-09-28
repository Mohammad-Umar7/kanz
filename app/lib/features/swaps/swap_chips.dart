import '../../l10n/l10n.dart';

/// A common throwaway offered as a chip. [id] is what the request sends
/// (the backend normalizes these ids); [materialId] colors the chip's dot.
class SwapChipOption {
  const SwapChipOption(this.id, this.materialId);

  final String id;
  final String materialId;

  String label(AppLocalizations l10n) => switch (id) {
    'plastic_bags' => l10n.swapsChipPlasticBags,
    'cling_film' => l10n.swapsChipClingFilm,
    'takeaway_containers' => l10n.swapsChipTakeawayContainers,
    'coffee_capsules' => l10n.swapsChipCoffeeCapsules,
    'plastic_bottles' => l10n.swapsChipPlasticBottles,
    'paper_towels' => l10n.swapsChipPaperTowels,
    'wet_wipes' => l10n.swapsChipWetWipes,
    'batteries' => l10n.swapsChipBatteries,
    _ => id,
  };
}

/// The chips on the Swaps tab, most common first.
const List<SwapChipOption> swapChipOptions = [
  SwapChipOption('plastic_bags', 'plastic'),
  SwapChipOption('plastic_bottles', 'plastic'),
  SwapChipOption('cling_film', 'plastic'),
  SwapChipOption('takeaway_containers', 'plastic'),
  SwapChipOption('coffee_capsules', 'metal'),
  SwapChipOption('paper_towels', 'paper'),
  SwapChipOption('wet_wipes', 'plastic'),
  SwapChipOption('batteries', 'hazardous'),
];

/// The readable label for a request entry: a chip's label, or the typed
/// text. [inSentence] gives the chip's label as it reads mid-sentence
/// ("plastic bags"; Arabic has no case).
String swapEntryLabel(
  AppLocalizations l10n,
  String entry, {
  bool inSentence = false,
}) {
  for (final option in swapChipOptions) {
    if (option.id != entry) continue;
    final label = option.label(l10n);
    return inSentence && label.isNotEmpty
        ? label[0].toLowerCase() + label.substring(1)
        : label;
  }
  return entry;
}
