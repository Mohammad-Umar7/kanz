import 'package:flutter/material.dart';

/// Results (`/results/:scanId`): analysis, ideas, recycle, donate, drop-off.
///
/// Route scaffolding from App Core; the screen itself is built in Phase 2.
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.scanId});

  final String scanId;

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(), body: const SizedBox.expand());
}
