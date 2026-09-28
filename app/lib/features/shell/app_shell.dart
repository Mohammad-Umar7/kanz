import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/design/design.dart';
import '../../core/state/connectivity_providers.dart';
import '../../l10n/l10n.dart';
import 'connection_banner.dart';

/// The four-tab shell (Home, Drop-off, Swaps, Impact) around
/// [navigationShell], which keeps each tab's navigation stack and scroll
/// position alive. The clay scan action in the middle of the bar opens the
/// camera from any tab. A banner at the top says when the phone is offline
/// or the server cannot be reached.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  /// The last connection problem, kept while a re-check runs.
  BackendStatus? _problem;

  void _selectTab(int index) {
    final shell = widget.navigationShell;
    // Tapping the current tab again returns it to its first page.
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = ref.watch(backendStatusProvider);
    _problem = switch (status) {
      BackendStatus.offline || BackendStatus.unreachable => status,
      BackendStatus.online => null,
      BackendStatus.checking => _problem,
    };
    final problem = _problem;

    return Scaffold(
      body: Column(
        children: [
          // Shown in one frame rather than grown: the banner takes over the
          // status bar inset, so an animated height would first slide the
          // page under the status bar.
          if (problem != null)
            ConnectionBanner(
              problem: problem,
              checking: status == BackendStatus.checking,
              onRetry: () => ref.invalidate(healthProvider),
            ),
          Expanded(
            // Keyed so the tabs keep their state when the banner comes and
            // goes above them.
            key: const ValueKey('shell-body'),
            // The banner already covers the status bar.
            child: MediaQuery.removePadding(
              context: context,
              removeTop: problem != null,
              child: widget.navigationShell,
            ),
          ),
        ],
      ),
      bottomNavigationBar: KanzNavBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onSelected: _selectTab,
        scanLabel: l10n.shellScan,
        onScan: () => context.push(AppRoutes.scan(ScanMode.camera)),
        destinations: [
          KanzNavDestination(icon: KanzIcons.home, label: l10n.shellTabHome),
          KanzNavDestination(
            icon: KanzIcons.dropOff,
            label: l10n.shellTabDropoff,
          ),
          KanzNavDestination(icon: KanzIcons.swaps, label: l10n.shellTabSwaps),
          KanzNavDestination(
            icon: KanzIcons.impact,
            label: l10n.shellTabImpact,
          ),
        ],
      ),
    );
  }
}
