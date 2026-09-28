import 'package:flutter/material.dart';

/// Idea detail (`/results/:scanId/idea/:ideaId`): before/after and materials.
///
/// Route scaffolding from App Core; the screen itself is built in Phase 2.
class IdeaScreen extends StatelessWidget {
  const IdeaScreen({super.key, required this.scanId, required this.ideaId});

  final String scanId;
  final String ideaId;

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(), body: const SizedBox.expand());
}
