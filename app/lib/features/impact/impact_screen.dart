import 'package:flutter/material.dart';

/// Impact tab (`/impact`): items diverted, projects, streak and CO2e estimate.
///
/// Route scaffolding from App Core; the screen itself is built in Phase 2.
class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(), body: const SizedBox.expand());
}
