import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_info.dart';
import '../core/design/theme.dart';
import '../core/state/connectivity_providers.dart';
import '../core/state/settings_providers.dart';
import '../l10n/l10n.dart';
import 'router.dart';

/// Root widget: theme, language (RTL follows the locale) and routing.
class KanzApp extends ConsumerStatefulWidget {
  const KanzApp({super.key});

  @override
  ConsumerState<KanzApp> createState() => _KanzAppState();
}

class _KanzAppState extends ConsumerState<KanzApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Wake the backend while the first screen renders: a cold start loads the
    // knowledge base, and the first scan should not pay for it.
    ref.read(healthProvider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// With "Phone language" selected, a change of the phone's language also
  /// switches the language of AI answers and the Arabic type system.
  @override
  void didChangeLocales(List<Locale>? locales) {
    if (locales != null) {
      ref.read(systemLocalesProvider.notifier).update(locales);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final locale = ref.watch(appLocaleProvider);
    // The theme needs the effective language to pick the Arabic type system,
    // also when the app follows the phone's language.
    final themeLocale = Locale(ref.watch(contentLangProvider).id);

    return MaterialApp.router(
      title: kAppName,
      onGenerateTitle: (context) => context.l10n.commonAppName,
      debugShowCheckedModeBanner: false,
      theme: KanzTheme.light(locale: themeLocale),
      darkTheme: KanzTheme.dark(locale: themeLocale),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
    );
  }
}
