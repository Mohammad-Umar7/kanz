/// Page chrome shared by the full-screen routes of the foundation screens
/// (History, Settings, the permission rationales and the city picker): a
/// quiet top bar whose glyph sits on the 20 dp gutter, and a start-aligned
/// Fraunces page title under it.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/design/design.dart';
import '../../l10n/l10n.dart';

/// Leaves the current route: pops when there is a page below, otherwise
/// (opened from a deep link) goes to Home.
void leavePage<T extends Object?>(BuildContext context, [T? result]) {
  final router = GoRouter.maybeOf(context);
  if (router == null) {
    Navigator.maybePop<T>(context, result);
  } else if (router.canPop()) {
    router.pop<T>(result);
  } else {
    router.go(AppRoutes.home);
  }
}

/// A 56 dp bar with a leading back (or close) button and optional trailing
/// actions. The leading glyph lines up with the page gutter.
class PageTopBar extends StatelessWidget {
  const PageTopBar({
    super.key,
    this.close = false,
    this.onLeading,
    this.actions = const [],
    this.showLeading = true,
  });

  /// Show a close glyph instead of the back arrow (for asks such as the
  /// permission rationales).
  final bool close;

  /// Defaults to [leavePage].
  final VoidCallback? onLeading;
  final List<Widget> actions;
  final bool showLeading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 56,
      child: Padding(
        // 48 dp buttons with 24 dp glyphs: an 8 dp inset puts the glyph
        // edge on the 20 dp gutter.
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: KanzSpace.s8,
        ),
        child: Row(
          children: [
            if (showLeading)
              KanzIconButton(
                icon: close ? KanzIcons.close : KanzIcons.back,
                semanticsLabel: close ? l10n.commonClose : l10n.commonBack,
                onPressed: onLeading ?? () => leavePage<Object?>(context),
              ),
            const Spacer(),
            ...actions,
          ],
        ),
      ),
    );
  }
}

/// The page title: Fraunces headline at the gutter, with an optional lead
/// paragraph under it.
class PageTitle extends StatelessWidget {
  const PageTitle({super.key, required this.title, this.lead});

  final String title;
  final String? lead;

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    final c = context.kanzColors;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s8,
        KanzSpace.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(header: true, child: Text(title, style: t.headlineLarge)),
          if (lead != null) ...[
            const SizedBox(height: KanzSpace.s8),
            Text(lead!, style: t.bodyLarge?.copyWith(color: c.inkSecondary)),
          ],
        ],
      ),
    );
  }
}

/// A mono section label on the gutter, with the spacing the foundation
/// screens use between sections.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.top = KanzSpace.s32});

  final String text;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        top,
        KanzSpace.gutter,
        KanzSpace.s8,
      ),
      child: Semantics(header: true, child: MonoLabel(text)),
    );
  }
}
