import 'package:flutter/material.dart';

import '../../app/routes.dart';

/// Scan (`/scan?mode=camera|gallery|text`): viewfinder, gallery pick or a
/// text description, then `/results/:scanId`.
///
/// Route scaffolding from App Core; the screen itself is built in Phase 2.
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key, this.mode = ScanMode.camera});

  final ScanMode mode;

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(), body: const SizedBox.expand());
}
