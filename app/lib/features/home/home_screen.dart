import 'package:flutter/material.dart';

/// Home tab (`/`): scan actions and recent scans.
///
/// Route scaffolding from App Core; the screen itself is built in Phase 2.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(), body: const SizedBox.expand());
}
