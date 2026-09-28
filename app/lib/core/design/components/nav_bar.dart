import 'package:flutter/material.dart';

import '../context.dart';
import '../tokens.dart';
import 'buttons.dart';

/// One tab of [KanzNavBar].
@immutable
class KanzNavDestination {
  const KanzNavDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Bottom navigation: Home, Drop-off, the clay scan action, Swaps, Impact.
///
/// The scan action sits in the middle so it is always one tap away. The
/// selected tab is ink with a short clay bar at the top edge; the others
/// are secondary ink. Labels scale down rather than wrap at large text
/// sizes.
class KanzNavBar extends StatelessWidget {
  const KanzNavBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.scanLabel,
    required this.onScan,
  }) : assert(destinations.length == 4, 'Kanz has four tabs');

  final List<KanzNavDestination> destinations;

  /// Index into [destinations], or -1 when no tab is selected.
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Accessible name of the scan action, for example "Scan an item".
  final String scanLabel;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    Widget item(int i) => Expanded(
      child: _NavItem(
        destination: destinations[i],
        selected: i == selectedIndex,
        onTap: () => onSelected(i),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          // Grow with the label when the user enlarges text (capped at 130 %).
          height: 68 + _labelScaler(context).scale(16) - 16,
          child: Row(
            children: [
              item(0),
              item(1),
              Expanded(
                child: Center(
                  child: ScanActionButton(
                    semanticsLabel: scanLabel,
                    onPressed: onScan,
                    size: 52,
                  ),
                ),
              ),
              item(2),
              item(3),
            ],
          ),
        ),
      ),
    );
  }
}

TextScaler _labelScaler(BuildContext context) =>
    MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final KanzNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final color = selected ? c.ink : c.inkSecondary;
    final duration = KanzMotion.of(context, KanzMotion.fast);
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            AnimatedContainer(
              duration: duration,
              curve: KanzMotion.standard,
              width: selected ? 20 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: c.accent,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(destination.icon, size: 24, color: color),
                  const SizedBox(height: KanzSpace.s4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedDefaultTextStyle(
                      duration: duration,
                      style: context.textStyles.labelSmall!.copyWith(
                        color: color,
                        height: 16 / 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      child: Text(
                        destination.label,
                        maxLines: 1,
                        textScaler: _labelScaler(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
