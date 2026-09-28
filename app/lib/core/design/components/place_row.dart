import 'package:flutter/material.dart';

import '../context.dart';
import '../icons.dart';
import '../tokens.dart';
import 'buttons.dart';
import 'data.dart';

/// Whether a place is open right now, when known.
enum OpenState { open, closed, unknown }

/// A drop-off point in a list: name, address, distance in mono, opening
/// state and dots for the materials it accepts, with a directions button.
class PlaceRow extends StatelessWidget {
  const PlaceRow({
    super.key,
    required this.name,
    required this.distance,
    required this.openState,
    required this.openLabel,
    required this.materialIds,
    required this.directionsLabel,
    this.materialsLabel,
    this.address,
    this.typeLabel,
    this.onTap,
    this.onDirections,
    this.divider = true,
    this.selected = false,
  });

  final String name;

  /// Formatted distance, for example "950 m" or "2.7 km".
  final String distance;
  final OpenState openState;

  /// For example "Open now", "Closed" or "Hours not listed".
  final String openLabel;

  /// Accepted material category ids, drawn as dots.
  final List<String> materialIds;
  final String directionsLabel;

  /// Spoken version of the dots, for example "Accepts glass and metal".
  final String? materialsLabel;
  final String? address;

  /// Facility type, for example "Recycling center".
  final String? typeLabel;
  final VoidCallback? onTap;
  final VoidCallback? onDirections;
  final bool divider;

  /// Highlighted (for example the pin selected on the map).
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    final openColor = switch (openState) {
      OpenState.open => c.positive,
      OpenState.closed => c.danger,
      OpenState.unknown => c.inkSecondary,
    };
    return Semantics(
      button: onTap != null,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(
            KanzSpace.gutter,
            KanzSpace.s16,
            KanzSpace.s8,
            KanzSpace.s16,
          ),
          decoration: BoxDecoration(
            color: selected ? c.surfaceSunken : null,
            border: divider ? Border(bottom: BorderSide(color: c.line)) : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: MergeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(name, style: t.titleMedium)),
                          const SizedBox(width: KanzSpace.s12),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: MonoLabel(distance, color: c.ink),
                          ),
                        ],
                      ),
                      if (address != null || typeLabel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          [?typeLabel, ?address].join(' · '),
                          style: t.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: KanzSpace.s8),
                      Wrap(
                        spacing: KanzSpace.s12,
                        runSpacing: KanzSpace.s4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(KanzIcons.clock, size: 14, color: openColor),
                              const SizedBox(width: KanzSpace.s4),
                              Text(
                                openLabel,
                                style: t.labelSmall?.copyWith(color: openColor),
                              ),
                            ],
                          ),
                          if (materialIds.isNotEmpty)
                            Semantics(
                              label: materialsLabel,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: KanzSpace.s4,
                                children: [
                                  for (final id in materialIds.take(6))
                                    MaterialDot(id),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: KanzSpace.s4),
              KanzIconButton(
                icon: KanzIcons.directions,
                semanticsLabel: directionsLabel,
                onPressed: onDirections,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
