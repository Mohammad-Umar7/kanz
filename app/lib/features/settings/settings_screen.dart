import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/config/app_info.dart';
import '../../core/data/models/models.dart';
import '../../core/design/design.dart';
import '../../core/services/permission_service.dart';
import '../../core/state/core_providers.dart';
import '../../core/state/settings_providers.dart';
import '../../l10n/l10n.dart';
import '../onboarding/choice_card.dart';
import '../permissions/city_picker_screen.dart';
import '../shell/page_chrome.dart';
import 'server_section.dart';
import 'settings_parts.dart';

/// Whether Kanz may read the location now, re-read whenever Settings comes
/// back to the foreground.
final locationPermissionProvider = FutureProvider.autoDispose<PermissionState>(
  (ref) => ref.watch(permissionServiceProvider).status(AppPermission.location),
);

/// Settings (`/settings`): language, appearance, skill and tools, location,
/// hands-free, the backend server and about.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(locationPermissionProvider);
    }
  }

  Future<void> _useGps() async {
    final settings = ref.read(settingsProvider.notifier);
    PermissionState status;
    try {
      status = await ref
          .read(permissionServiceProvider)
          .status(AppPermission.location);
    } on Object {
      status = PermissionState.denied;
    }
    if (status == PermissionState.granted) {
      await settings.setLocationMode(LocationMode.gps);
    } else if (mounted) {
      // The rationale switches to GPS itself when location is granted.
      await context.push<bool>(AppRoutes.locationRationale);
    }
    ref.invalidate(locationPermissionProvider);
  }

  Future<void> _pickCity() async {
    final id = await context.push<String>(AppRoutes.cityPicker);
    if (id == CityPickerScreen.myLocation) {
      ref.invalidate(locationPermissionProvider);
      return;
    }
    final city = CityId.tryFromId(id);
    if (city != null) await ref.read(settingsProvider.notifier).useCity(city);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.textStyles;
    final c = context.kanzColors;
    final locale = Localizations.localeOf(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final vocab = ref.watch(vocabProvider);
    final contentLang = ref.watch(contentLangProvider);
    final permission = ref.watch(locationPermissionProvider).value;

    final systemLanguage = contentLang == Lang.ar
        ? l10n.commonLanguageArabic
        : l10n.commonLanguageEnglish;
    final cityName = settings.city == null
        ? null
        : vocab.city(settings.city!).label.forLocale(locale);
    final gpsOff =
        settings.locationMode == LocationMode.gps &&
        permission != null &&
        permission != PermissionState.granted;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PageTopBar(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + KanzSpace.s48,
                ),
                children: [
                  PageTitle(title: l10n.settingsTitle),

                  // Language.
                  SectionLabel(l10n.settingsLanguage),
                  RadioRow(
                    title: l10n.commonLanguageSystem,
                    subtitle: l10n.settingsLanguageSystemDetail(systemLanguage),
                    selected: settings.locale == LocalePref.system,
                    onTap: () => controller.setLocale(LocalePref.system),
                  ),
                  RadioRow(
                    title: l10n.commonLanguageEnglish,
                    titleDirection: TextDirection.ltr,
                    selected: settings.locale == LocalePref.en,
                    onTap: () => controller.setLocale(LocalePref.en),
                  ),
                  RadioRow(
                    title: l10n.commonLanguageArabic,
                    titleDirection: TextDirection.rtl,
                    selected: settings.locale == LocalePref.ar,
                    divider: false,
                    onTap: () => controller.setLocale(LocalePref.ar),
                  ),
                  _Note(l10n.settingsLanguageNote),

                  // Appearance.
                  SectionLabel(l10n.settingsTheme),
                  Padding(
                    padding: KanzSpace.page,
                    child: SegmentedTabs(
                      selectedIndex: switch (settings.themeMode) {
                        ThemeMode.system => 0,
                        ThemeMode.light => 1,
                        ThemeMode.dark => 2,
                      },
                      onChanged: (i) => controller.setThemeMode(
                        [ThemeMode.system, ThemeMode.light, ThemeMode.dark][i],
                      ),
                      tabs: [
                        SegmentedTab(label: l10n.commonThemeSystem),
                        SegmentedTab(label: l10n.commonThemeLight),
                        SegmentedTab(label: l10n.commonThemeDark),
                      ],
                    ),
                  ),

                  // Workshop: skill and tools.
                  SectionLabel(l10n.settingsWorkshop),
                  Padding(
                    padding: KanzSpace.page,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.settingsSkill, style: t.labelMedium),
                        const SizedBox(height: KanzSpace.s8),
                        SegmentedTabs(
                          selectedIndex: SkillLevel.values.indexOf(
                            settings.skill,
                          ),
                          onChanged: (i) =>
                              controller.setSkill(SkillLevel.values[i]),
                          tabs: [
                            for (final skill in SkillLevel.values)
                              SegmentedTab(label: skillLabel(l10n, skill)),
                          ],
                        ),
                        const SizedBox(height: KanzSpace.s12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child: LevelMeter(
                                level: skillRank(settings.skill),
                              ),
                            ),
                            const SizedBox(width: KanzSpace.s12),
                            Expanded(
                              child: Semantics(
                                liveRegion: true,
                                child: Text(
                                  skillLine(l10n, settings.skill),
                                  style: t.bodyMedium?.copyWith(
                                    color: c.inkSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: KanzSpace.s16),
                  KanzListTile(
                    leading: const Icon(KanzIcons.tools),
                    title: l10n.settingsTools,
                    subtitle: toolsSummary(l10n, vocab, locale, settings.tools),
                    showChevron: true,
                    onTap: () => showToolsSheet(context),
                  ),

                  // Location.
                  SectionLabel(l10n.settingsLocation),
                  RadioRow(
                    title: l10n.settingsLocationGps,
                    subtitle: gpsOff
                        ? (settings.city == null
                              ? l10n.settingsLocationGpsOffNoCity
                              : l10n.settingsLocationGpsOff)
                        : l10n.settingsLocationGpsDetail,
                    selected: settings.locationMode == LocationMode.gps,
                    onTap: _useGps,
                  ),
                  RadioRow(
                    title: l10n.settingsLocationCity,
                    subtitle: cityName == null
                        ? l10n.settingsLocationCityNone
                        : l10n.settingsLocationCityDetail(cityName),
                    selected: settings.locationMode == LocationMode.city,
                    divider: false,
                    trailing: Icon(
                      KanzIcons.chevronForward,
                      size: 18,
                      color: c.inkSecondary,
                    ),
                    onTap: _pickCity,
                  ),
                  if (settings.locationMode == null)
                    _Note(l10n.settingsLocationUndecided),

                  // Tutorials.
                  SectionLabel(l10n.settingsTutorials),
                  KanzSwitchTile(
                    title: l10n.settingsHandsFree,
                    subtitle: l10n.settingsHandsFreeDetail,
                    value: settings.handsFree,
                    onChanged: (on) => controller.setHandsFree(enabled: on),
                  ),

                  // Server.
                  SectionLabel(l10n.settingsServer),
                  const ServerSection(),

                  // About.
                  SectionLabel(l10n.settingsAbout, top: KanzSpace.s40),
                  const _About(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s8,
        KanzSpace.gutter,
        0,
      ),
      child: Text(text, style: context.textStyles.bodySmall),
    );
  }
}

class _About extends StatelessWidget {
  const _About();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.textStyles;
    final c = context.kanzColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: KanzSpace.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandLockup(markSize: 28),
              const SizedBox(height: KanzSpace.s16),
              Text(
                l10n.settingsAboutBody,
                style: t.bodyMedium?.copyWith(color: c.inkSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: KanzSpace.s8),
        KanzListTile(
          leading: const Icon(KanzIcons.source),
          title: l10n.settingsLicenses,
          showChevron: true,
          onTap: () => showLicensePage(
            context: context,
            applicationName: kAppName,
            applicationIcon: const Padding(
              padding: EdgeInsets.all(KanzSpace.s8),
              child: BrandMark(size: 48),
            ),
          ),
        ),
        const SizedBox(height: KanzSpace.s8),
        Padding(
          padding: KanzSpace.page,
          child: Callout(
            variant: CalloutVariant.tip,
            icon: KanzIcons.leaf,
            title: l10n.settingsEstimates,
            message: l10n.settingsCo2eNote,
          ),
        ),
      ],
    );
  }
}
