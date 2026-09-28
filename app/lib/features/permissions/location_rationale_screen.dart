import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/data/models/models.dart';
import '../../core/design/design.dart';
import '../../core/state/settings_providers.dart';
import '../../l10n/l10n.dart';
import '../shell/page_chrome.dart';
import 'permission_ask.dart';

/// Why Kanz asks for location (`/permissions/location`).
///
/// Pops `true` once Kanz has somewhere to search from: location was granted
/// (settings switch to [LocationMode.gps]) or a city was chosen instead
/// (settings switch to that city). Pops null when the user closes it. The
/// caller then resumes its search, for example
/// `scanSessionProvider(id).notifier.resumeDropoff()`.
///
/// Opened from the city picker (`?from=city`), "Choose a city instead" just
/// goes back to the picker (pops `false`).
class LocationRationaleScreen extends ConsumerStatefulWidget {
  const LocationRationaleScreen({super.key, this.fromCityPicker});

  /// Overrides the `?from=city` query parameter (tests).
  final bool? fromCityPicker;

  /// Query value used by the city picker when it opens this screen.
  static const fromCity = 'city';

  @override
  ConsumerState<LocationRationaleScreen> createState() =>
      _LocationRationaleScreenState();
}

class _LocationRationaleScreenState
    extends PermissionAskState<LocationRationaleScreen> {
  @override
  AppPermission get permission => AppPermission.location;

  bool get _fromCityPicker {
    if (widget.fromCityPicker != null) return widget.fromCityPicker!;
    if (GoRouter.maybeOf(context) == null) return false;
    return GoRouterState.of(context).uri.queryParameters['from'] ==
        LocationRationaleScreen.fromCity;
  }

  @override
  Future<void> onGranted() async {
    await ref.read(settingsProvider.notifier).setLocationMode(LocationMode.gps);
    if (mounted) leavePage<bool>(context, true);
  }

  Future<void> _chooseCity() async {
    if (_fromCityPicker) {
      leavePage<bool>(context, false);
      return;
    }
    final id = await context.push<String>(
      '${AppRoutes.cityPicker}?from=${CityPickerQuery.fromLocation}',
    );
    final city = CityId.tryFromId(id);
    if (city == null || !mounted) return;
    await ref.read(settingsProvider.notifier).useCity(city);
    if (mounted) leavePage<bool>(context, true);
  }

  @override
  Widget build(BuildContext context) {
    // Watched so the settings controller stays active while this screen
    // writes to it.
    ref.watch(settingsProvider.select((s) => s.locationMode));
    final l10n = context.l10n;
    final outcome = this.outcome;
    final restricted = outcome == AskOutcome.restricted;
    return RationalePage(
      rationale: PermissionRationale(
        art: PermissionArt.location,
        title: l10n.permissionsLocationTitle,
        // Restricted by policy: the reasons no longer apply, only the
        // way around it does.
        reasons: [
          if (!restricted) ...[
            RationaleReason(
              icon: KanzIcons.directions,
              text: l10n.permissionsLocationReason1,
            ),
            RationaleReason(
              icon: KanzIcons.locate,
              text: l10n.permissionsLocationReason2,
            ),
            RationaleReason(
              icon: KanzIcons.map,
              text: l10n.permissionsLocationReason3,
            ),
          ],
        ],
        primaryLabel: switch (outcome) {
          AskOutcome.blocked => l10n.commonOpenSettings,
          AskOutcome.restricted => l10n.permissionsLocationCity,
          _ => l10n.permissionsLocationAllow,
        },
        onPrimary: asking ? null : (restricted ? _chooseCity : ask),
        secondaryLabel: restricted
            ? l10n.commonClose
            : l10n.permissionsLocationCity,
        onSecondary: restricted
            ? () => leavePage<bool>(context)
            : (asking ? null : _chooseCity),
        footnote: asking
            ? l10n.permissionsAsking
            : rationaleFootnote(l10n, outcome),
        notice: rationaleNotice(l10n, outcome, switch (outcome) {
          AskOutcome.fresh => null,
          AskOutcome.denied => l10n.permissionsLocationDenied,
          AskOutcome.blocked => l10n.permissionsLocationBlocked,
          AskOutcome.restricted => l10n.permissionsLocationRestricted,
        }),
      ),
    );
  }
}

/// Query values the city picker understands.
abstract final class CityPickerQuery {
  /// Opened from the location rationale: the picker hides its own "Use my
  /// location instead" entry, since the user just came from that choice.
  static const fromLocation = 'location';
}
