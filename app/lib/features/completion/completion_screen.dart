import 'package:flutter/material.dart';

/// Completion (`/projects/:projectId/done`): finished project and share.
///
/// Route scaffolding from App Core; the screen itself is built in Phase 2.
class CompletionScreen extends StatelessWidget {
  const CompletionScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(), body: const SizedBox.expand());
}
