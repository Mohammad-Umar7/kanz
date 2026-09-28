import 'package:flutter/material.dart';

/// Settings (`/settings`): language, theme, skill, tools, location, backend.
///
/// Route scaffolding from App Core; the screen itself is built in Phase 2.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(), body: const SizedBox.expand());
}
