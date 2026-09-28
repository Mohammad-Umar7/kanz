import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The four-tab shell (Home, Drop-off, Swaps, Impact) around
/// [navigationShell], which keeps each tab's navigation stack alive.
///
/// Route scaffolding from App Core; the shell itself is built in Phase 2.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(
          icon: Icon(Icons.place_outlined),
          label: 'Drop-off',
        ),
        NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Swaps'),
        NavigationDestination(icon: Icon(Icons.eco_outlined), label: 'Impact'),
      ],
    ),
  );
}
