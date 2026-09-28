import 'package:flutter/material.dart';

/// Tutorial pager (`/results/:scanId/idea/:ideaId/tutorial`), hands-free.
///
/// Route scaffolding from App Core; the screen itself is built in Phase 2.
class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key, required this.scanId, required this.ideaId});

  final String scanId;
  final String ideaId;

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(), body: const SizedBox.expand());
}
