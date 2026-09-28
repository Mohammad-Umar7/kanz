import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/state/settings_providers.dart';
import '../features/completion/completion_screen.dart';
import '../features/dropoff/dropoff_screen.dart';
import '../features/gallery/gallery_screen.dart';
import '../features/history/history_screen.dart';
import '../features/home/home_screen.dart';
import '../features/idea/idea_screen.dart';
import '../features/impact/impact_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/permissions/camera_rationale_screen.dart';
import '../features/permissions/city_picker_screen.dart';
import '../features/permissions/location_rationale_screen.dart';
import '../features/results/results_screen.dart';
import '../features/scan/scan_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/swaps/swaps_screen.dart';
import '../features/tutorial/tutorial_screen.dart';
import 'routes.dart';

export 'routes.dart';

/// The app's single [GoRouter].
///
/// Until onboarding is finished every route except onboarding, the
/// permission rationales and the city picker redirects to `/onboarding`.
/// The router is created once; onboarding changes reach it through
/// `refreshListenable`, so navigation state survives settings changes.
final routerProvider = Provider<GoRouter>((ref) {
  final onboardingDone = ValueNotifier<bool>(
    ref.read(settingsProvider).onboardingDone,
  );
  ref.listen(
    settingsProvider.select((s) => s.onboardingDone),
    (_, done) => onboardingDone.value = done,
  );

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: onboardingDone,
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (!onboardingDone.value &&
          !AppRoutes.allowedBeforeOnboarding(location)) {
        return AppRoutes.onboarding;
      }
      if (onboardingDone.value && location == AppRoutes.onboarding) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dropoff,
                builder: (context, state) => const DropoffScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.swaps,
                builder: (context, state) => const SwapsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.impact,
                builder: (context, state) => const ImpactScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.locationRationale,
        builder: (context, state) => const LocationRationaleScreen(),
      ),
      GoRoute(
        path: AppRoutes.cameraRationale,
        builder: (context, state) => const CameraRationaleScreen(),
      ),
      GoRoute(
        path: AppRoutes.cityPicker,
        builder: (context, state) => const CityPickerScreen(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) =>
            ScanScreen(mode: ScanMode.parse(state.uri.queryParameters['mode'])),
      ),
      GoRoute(
        path: '/results/:scanId',
        builder: (context, state) =>
            ResultsScreen(scanId: state.pathParameters['scanId']!),
        routes: [
          GoRoute(
            path: 'idea/:ideaId',
            builder: (context, state) => IdeaScreen(
              scanId: state.pathParameters['scanId']!,
              ideaId: state.pathParameters['ideaId']!,
            ),
            routes: [
              GoRoute(
                path: 'tutorial',
                builder: (context, state) => TutorialScreen(
                  scanId: state.pathParameters['scanId']!,
                  ideaId: state.pathParameters['ideaId']!,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/projects/:projectId/done',
        builder: (context, state) =>
            CompletionScreen(projectId: state.pathParameters['projectId']!),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.gallery,
          builder: (context, state) => const DesignGalleryScreen(),
        ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    onboardingDone.dispose();
  });
  return router;
});
