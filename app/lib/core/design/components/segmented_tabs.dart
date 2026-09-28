import 'package:flutter/material.dart';

import '../context.dart';
import '../tokens.dart';

/// One segment of [SegmentedTabs].
@immutable
class SegmentedTab {
  const SegmentedTab({
    required this.label,
    this.icon,
    this.count,
    this.enabled = true,
  });

  final String label;
  final IconData? icon;

  /// Optional count ("3"), set after the label.
  final String? count;
  final bool enabled;
}

/// Equal-width segments on a sunken track with a sliding surface thumb:
/// the Upcycle / Recycle / Donate switch on the results screen.
///
/// The thumb slides with the emphasized curve and follows the reading
/// direction. Each segment is a 48 dp target announced as a selected or
/// unselected tab.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<SegmentedTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final n = tabs.length;
    final x = n <= 1 ? 0.0 : -1 + 2 * selectedIndex / (n - 1);
    return Container(
      padding: const EdgeInsets.all(KanzSpace.s4),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: KanzRadii.buttonAll,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedAlign(
              alignment: AlignmentDirectional(x, 0),
              duration: KanzMotion.of(context, KanzMotion.medium),
              curve: KanzMotion.emphasized,
              child: FractionallySizedBox(
                widthFactor: 1 / n,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: c.raised,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Theme.of(context).brightness == Brightness.light
                        ? Border.all(color: c.line)
                        : null,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < n; i++)
                Expanded(
                  child: _Segment(
                    tab: tabs[i],
                    selected: i == selectedIndex,
                    onTap: tabs[i].enabled ? () => onChanged(i) : null,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.tab, required this.selected, this.onTap});

  final SegmentedTab tab;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final color = onTap == null
        ? c.inkDisabled
        : (selected ? c.ink : c.inkSecondary);
    final style = context.textStyles.labelLarge?.copyWith(
      color: color,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
    );
    return Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      inMutuallyExclusiveGroup: true,
      label: tab.count == null ? tab.label : '${tab.label}, ${tab.count}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: KanzSpace.touchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: KanzSpace.s4),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tab.icon != null) ...[
                      Icon(tab.icon, size: 18, color: color),
                      const SizedBox(width: 6),
                    ],
                    Text.rich(
                      TextSpan(
                        text: tab.label,
                        children: [
                          if (tab.count != null)
                            TextSpan(
                              text: '  ${tab.count}',
                              style: context.kanzType.data.copyWith(
                                color: selected ? c.ink : c.inkSecondary,
                              ),
                            ),
                        ],
                      ),
                      style: style,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
