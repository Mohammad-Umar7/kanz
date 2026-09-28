import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../app/router.dart';
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
import '../../core/services/permission_service.dart';
import '../../core/state/core_providers.dart';
import '../../core/state/settings_providers.dart';
import '../../l10n/l10n.dart';
import '../shell/page_chrome.dart';
import 'location_rationale_screen.dart';

/// City picker (`/city`): pops with the chosen city's id (`CityId.id`), or
/// with [CityPickerScreen.myLocation] when the user switched to their
/// location instead (settings are already in GPS mode then), or null.
///
/// ```dart
/// final id = await context.push<String>(AppRoutes.cityPicker);
/// if (id == CityPickerScreen.myLocation) return controller.useMyLocation();
/// final city = CityId.tryFromId(id);
/// if (city != null) controller.useCity(city);
/// ```
class CityPickerScreen extends ConsumerWidget {
  const CityPickerScreen({super.key, this.offerMyLocation});

  /// Result when the user chose "Use my location instead".
  static const myLocation = 'gps';

  /// Overrides the `?from=location` query parameter (tests). When false the
  /// "Use my location instead" entry is hidden.
  final bool? offerMyLocation;

  bool _offerMyLocation(BuildContext context) {
    if (offerMyLocation != null) return offerMyLocation!;
    if (GoRouter.maybeOf(context) == null) return true;
    return GoRouterState.of(context).uri.queryParameters['from'] !=
        CityPickerQuery.fromLocation;
  }

  Future<void> _useMyLocation(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider.notifier);
    PermissionState status;
    try {
      status = await ref
          .read(permissionServiceProvider)
          .status(AppPermission.location);
    } on Object {
      status = PermissionState.denied;
    }
    if (!context.mounted) return;
    if (status == PermissionState.granted) {
      await settings.setLocationMode(LocationMode.gps);
      if (context.mounted) leavePage<String>(context, myLocation);
      return;
    }
    final granted = await context.push<bool>(
      '${AppRoutes.locationRationale}?from=${LocationRationaleScreen.fromCity}',
    );
    if (granted == true && context.mounted) {
      leavePage<String>(context, myLocation);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final cities = ref.watch(vocabProvider).cities;
    final selected = ref.watch(settingsProvider.select((s) => s.city));
    final offerLocation = _offerMyLocation(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PageTopBar(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + KanzSpace.s32,
                ),
                children: [
                  PageTitle(
                    title: l10n.permissionsCityTitle,
                    lead: l10n.permissionsCityBody,
                  ),
                  if (offerLocation) ...[
                    const SizedBox(height: KanzSpace.s24),
                    KanzListTile(
                      leading: const Icon(KanzIcons.locate),
                      title: l10n.permissionsCityUseLocation,
                      subtitle: l10n.permissionsCityUseLocationDetail,
                      showChevron: true,
                      onTap: () => _useMyLocation(context, ref),
                    ),
                  ],
                  SectionLabel(
                    l10n.permissionsCityEyebrow,
                    top: offerLocation ? KanzSpace.s24 : KanzSpace.s32,
                  ),
                  for (final (i, city) in cities.indexed)
                    _CityRow(
                      city: city,
                      locale: locale,
                      selected: city.id == selected,
                      selectedLabel: l10n.permissionsCitySelected,
                      divider: i < cities.length - 1,
                      onTap: () => leavePage<String>(context, city.id.id),
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

final NumberFormat _coordinate = NumberFormat('0.00', 'en');

/// "25.20° N · 55.27° E": the point Kanz searches around.
String cityCoordinates(CityEntry city) {
  final lat =
      '${_coordinate.format(city.lat.abs())}° ${city.lat >= 0 ? 'N' : 'S'}';
  final lng =
      '${_coordinate.format(city.lng.abs())}° ${city.lng >= 0 ? 'E' : 'W'}';
  return '$lat · $lng';
}

class _CityRow extends StatelessWidget {
  const _CityRow({
    required this.city,
    required this.locale,
    required this.selected,
    required this.selectedLabel,
    required this.divider,
    required this.onTap,
  });

  final CityEntry city;
  final Locale locale;
  final bool selected;
  final String selectedLabel;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    final arabic = locale.languageCode == 'ar';
    final name = city.label.forLocale(locale);
    final other = arabic ? city.label.en : city.label.ar;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: selected ? '$name, $selectedLabel' : name,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          margin: const EdgeInsetsDirectional.only(start: KanzSpace.gutter),
          padding: const EdgeInsetsDirectional.fromSTEB(
            0,
            KanzSpace.s12,
            KanzSpace.gutter,
            KanzSpace.s12,
          ),
          // The hairline starts at the gutter so the rows read as one list.
          decoration: BoxDecoration(
            border: divider ? Border(bottom: BorderSide(color: c.line)) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: KanzSpace.s8,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        Text(name, style: t.titleMedium),
                        Text(
                          other,
                          style: t.bodyMedium?.copyWith(color: c.inkSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: KanzSpace.s4),
                    MonoLabel(
                      cityCoordinates(city),
                      uppercase: false,
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KanzSpace.s16),
              SizedBox.square(
                dimension: 24,
                child: selected
                    ? Icon(KanzIcons.check, size: 22, color: c.ink)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
