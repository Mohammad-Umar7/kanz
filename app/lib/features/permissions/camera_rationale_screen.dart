import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design.dart';
import '../../l10n/l10n.dart';
import '../shell/page_chrome.dart';
import 'permission_ask.dart';

/// Why Kanz asks for the camera (`/permissions/camera`).
///
/// Pops `true` when the camera was granted, `false` when the user chose to
/// pick a photo from the gallery instead (the caller switches to its gallery
/// flow), and null when the user closes it:
///
/// ```dart
/// final granted = await context.push<bool>(AppRoutes.cameraRationale);
/// if (granted == true) startCamera();
/// if (granted == false) pickFromGallery();
/// ```
class CameraRationaleScreen extends ConsumerStatefulWidget {
  const CameraRationaleScreen({super.key});

  @override
  ConsumerState<CameraRationaleScreen> createState() =>
      _CameraRationaleScreenState();
}

class _CameraRationaleScreenState
    extends PermissionAskState<CameraRationaleScreen> {
  @override
  AppPermission get permission => AppPermission.camera;

  @override
  Future<void> onGranted() async {
    if (mounted) leavePage<bool>(context, true);
  }

  void _useGallery() => leavePage<bool>(context, false);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final outcome = this.outcome;
    final restricted = outcome == AskOutcome.restricted;
    return RationalePage(
      rationale: PermissionRationale(
        pinActions: true,
        art: PermissionArt.camera,
        title: l10n.permissionsCameraTitle,
        // Restricted by policy: the reasons no longer apply, only the
        // way around it does. The alternative is the tertiary action, so
        // no reason repeats it.
        reasons: [
          if (!restricted) ...[
            RationaleReason(
              icon: KanzIcons.scan,
              text: l10n.permissionsCameraReason1,
            ),
            RationaleReason(
              icon: KanzIcons.lock,
              text: l10n.permissionsCameraReason2,
            ),
          ],
        ],
        primaryLabel: switch (outcome) {
          AskOutcome.blocked => l10n.commonOpenSettings,
          AskOutcome.restricted => l10n.permissionsCameraGallery,
          _ => l10n.permissionsCameraAllow,
        },
        onPrimary: asking ? null : (restricted ? _useGallery : ask),
        secondaryLabel: restricted
            ? l10n.commonClose
            : l10n.permissionsCameraGallery,
        onSecondary: restricted
            ? () => leavePage<bool>(context)
            : (asking ? null : _useGallery),
        footnote: asking
            ? l10n.permissionsAsking
            : rationaleFootnote(l10n, outcome),
        notice: rationaleNotice(l10n, outcome, switch (outcome) {
          AskOutcome.fresh => null,
          AskOutcome.denied => l10n.permissionsCameraDenied,
          AskOutcome.blocked => l10n.permissionsCameraBlocked,
          AskOutcome.restricted => l10n.permissionsCameraRestricted,
        }),
      ),
    );
  }
}
