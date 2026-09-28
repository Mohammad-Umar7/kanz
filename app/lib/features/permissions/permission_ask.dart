import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design.dart';
import '../../core/services/permission_service.dart';
import '../../core/state/core_providers.dart';
import '../../l10n/l10n.dart';
import '../shell/page_chrome.dart';

export '../../core/services/permission_service.dart'
    show AppPermission, PermissionState;

/// Where a rationale stands after the user's last answer.
enum AskOutcome {
  /// Nothing asked yet (or the status is still being read).
  fresh,

  /// The user said no once; asking again still shows the system dialog.
  denied,

  /// Only the phone's Settings can grant it now.
  blocked,

  /// Blocked by policy; the user cannot turn it on.
  restricted,
}

/// Shared behaviour of the camera and location rationales: reads the status
/// on open and whenever the app comes back to the foreground (the user may
/// have granted it in Settings), asks through the system dialog, and opens
/// Settings once the system will no longer ask.
abstract class PermissionAskState<T extends ConsumerStatefulWidget>
    extends ConsumerState<T>
    with WidgetsBindingObserver {
  AppPermission get permission;

  /// Called once the permission is granted.
  Future<void> onGranted();

  PermissionState? _status;
  bool _asked = false;
  bool asking = false;
  bool _handled = false;

  AskOutcome get outcome => switch (_status) {
    PermissionState.permanentlyDenied => AskOutcome.blocked,
    PermissionState.restricted => AskOutcome.restricted,
    PermissionState.denied when _asked => AskOutcome.denied,
    _ => AskOutcome.fresh,
  };

  PermissionService get _service => ref.read(permissionServiceProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from the system Settings (or the permission dialog).
    if (state == AppLifecycleState.resumed && !asking) {
      _refresh(grantOnReturn: _asked);
    }
  }

  Future<void> _refresh({bool grantOnReturn = false}) async {
    try {
      final status = await _service.status(permission);
      if (!mounted) return;
      setState(() => _status = status);
      if (grantOnReturn && status == PermissionState.granted) {
        await _granted();
      }
    } on Object {
      // A platform failure leaves the screen in its first state; the
      // buttons still work.
    }
  }

  /// The primary action: the system dialog, or Settings when it will not
  /// show again.
  Future<void> ask() async {
    if (asking) return;
    if (outcome == AskOutcome.blocked) {
      _asked = true;
      await _service.openSettings();
      return;
    }
    setState(() => asking = true);
    PermissionState status;
    try {
      status = await _service.request(permission);
    } on Object {
      status = PermissionState.denied;
    }
    if (!mounted) return;
    setState(() {
      _asked = true;
      asking = false;
      _status = status;
    });
    if (status == PermissionState.granted) await _granted();
  }

  Future<void> _granted() async {
    if (_handled) return;
    _handled = true;
    await onGranted();
  }
}

/// The scaffold both rationales share: close button, the rationale itself
/// and, when the permission is refused or blocked, a notice under the
/// buttons that says what happened.
class RationalePage extends StatelessWidget {
  const RationalePage({
    super.key,
    required this.rationale,
    this.notice,
    this.noticeTitle,
  });

  final Widget rationale;
  final String? notice;
  final String? noticeTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PageTopBar(close: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: KanzSpace.s32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: KanzSpace.s8),
                    rationale,
                    if (notice != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          KanzSpace.gutter,
                          KanzSpace.s16,
                          KanzSpace.gutter,
                          0,
                        ),
                        child: Semantics(
                          liveRegion: true,
                          child: Callout(
                            variant: CalloutVariant.warning,
                            title: noticeTitle ?? '',
                            message: notice!,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The small-print footnote, or null when a notice replaces it.
String? rationaleFootnote(AppLocalizations l10n, AskOutcome outcome) =>
    outcome == AskOutcome.fresh ? l10n.permissionsFootnote : null;

/// The mono title of the notice for [outcome].
String? rationaleNoticeTitle(AppLocalizations l10n, AskOutcome outcome) =>
    switch (outcome) {
      AskOutcome.fresh => null,
      AskOutcome.denied => l10n.permissionsNotAllowed,
      AskOutcome.blocked => l10n.permissionsTurnedOff,
      AskOutcome.restricted => l10n.permissionsUnavailable,
    };
