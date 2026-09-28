import 'package:flutter/material.dart';

import '../context.dart';
import '../icons.dart';
import '../tokens.dart';
import 'buttons.dart';
import 'data.dart';

/// Whether a place is open right now, when known.
enum OpenState { open, closed, unknown }

/// A drop-off point in a list: name and distance in mono, then the type and
/// address with dots for the materials it accepts at the end of that line,
/// the opening state, and a directions button.
///
/// Most OpenStreetMap places list no hours; with [hideUnknownHours] the
/// hours line is left out for them instead of repeating "Hours not listed"
/// on every row.
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
    this.hideUnknownHours = false,
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

  /// Leave the hours line out when [openState] is [OpenState.unknown].
  final bool hideUnknownHours;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    final openColor = switch (openState) {
      OpenState.open => c.positive,
      OpenState.closed => c.danger,
      OpenState.unknown => c.inkSecondary,
    };
    final hasDetail = address != null || typeLabel != null;
    final showHours = !(hideUnknownHours && openState == OpenState.unknown);
    final Widget? dots = materialIds.isEmpty
        ? null
        : Semantics(
            label: materialsLabel,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: KanzSpace.s4,
              children: [for (final id in materialIds.take(6)) MaterialDot(id)],
            ),
          );
    // The row's text and its tap action form one node, so a screen reader
    // reads the place and can open it in one step; the directions button
    // stays a separate action.
    return InkWell(
      onTap: onTap,
      excludeFromSemantics: true,
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
                child: Semantics(
                  button: onTap != null,
                  selected: selected,
                  onTap: onTap,
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
                      if (hasDetail) ...[
                        const SizedBox(height: 2),
                        // The dots follow the last word of the line, so
                        // they read as part of the place, not a status.
                        Text.rich(
                          TextSpan(
                            text: [?typeLabel, ?address].join(' · '),
                            children: [
                              if (dots != null) ...[
                                const TextSpan(text: '  '),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: dots,
                                ),
                              ],
                            ],
                          ),
                          style: t.bodySmall,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (showHours) ...[
                        const SizedBox(height: KanzSpace.s8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(KanzIcons.clock, size: 14, color: openColor),
                            const SizedBox(width: KanzSpace.s4),
                            Flexible(
                              child: Text(
                                openLabel,
                                style: t.labelSmall?.copyWith(color: openColor),
                              ),
                            ),
                            if (!hasDetail && dots != null) ...[
                              const SizedBox(width: KanzSpace.s12),
                              dots,
                            ],
                          ],
                        ),
                      ] else if (!hasDetail && dots != null) ...[
                        const SizedBox(height: KanzSpace.s8),
                        dots,
                      ],
                    ],
                  ),
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
    );
  }
}
