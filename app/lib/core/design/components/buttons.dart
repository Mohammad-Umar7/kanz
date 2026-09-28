import 'package:flutter/material.dart';

import '../context.dart';
import '../haptics.dart';
import '../icons.dart';
import '../tokens.dart';

enum KanzButtonVariant {
  /// Ink fill. One per screen: the thing to do next.
  primary,

  /// Outlined. Alternatives to the primary action.
  secondary,

  /// Text only. Low-emphasis actions ("Skip", "See all").
  tertiary,

  /// Danger fill. Irreversible actions ("Delete history").
  destructive,
}

/// The Kanz button. Primary buttons are ink, never clay: clay belongs to
/// the scan action alone.
///
/// [icon] leads the label; [trailingIcon] follows it, for actions that
/// move forward ("See the tutorial" with [KanzIcons.forward], which also
/// mirrors in Arabic). While [loading], the button keeps its size and
/// color, shows a small spinner in place of the icons and ignores taps.
class KanzButton extends StatelessWidget {
  const KanzButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = KanzButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.loadingLabel,
  });

  const KanzButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.loadingLabel,
  }) : variant = KanzButtonVariant.secondary;

  const KanzButton.tertiary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.loadingLabel,
  }) : variant = KanzButtonVariant.tertiary;

  const KanzButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.loadingLabel,
  }) : variant = KanzButtonVariant.destructive;

  final String label;
  final VoidCallback? onPressed;
  final KanzButtonVariant variant;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;

  /// Stretch to the available width.
  final bool expand;

  /// Announced while [loading], for example "Saving".
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final foreground = switch (variant) {
      KanzButtonVariant.primary => c.onInverse,
      KanzButtonVariant.destructive => c.onDanger,
      _ => c.ink,
    };
    final Widget? leading = loading
        ? SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(
              strokeWidth: 1.75,
              color: foreground,
            ),
          )
        : (icon == null ? null : Icon(icon, size: 20));
    final trailing = loading || trailingIcon == null ? null : trailingIcon;

    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading, const SizedBox(width: KanzSpace.s8)],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: KanzSpace.s8),
          Icon(trailing, size: 20),
        ],
      ],
    );

    final Widget button = switch (variant) {
      KanzButtonVariant.primary => FilledButton(
        onPressed: onPressed,
        child: child,
      ),
      KanzButtonVariant.secondary => OutlinedButton(
        onPressed: onPressed,
        child: child,
      ),
      KanzButtonVariant.tertiary => TextButton(
        onPressed: onPressed,
        child: child,
      ),
      KanzButtonVariant.destructive => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: c.danger,
          foregroundColor: c.onDanger,
        ),
        child: child,
      ),
    };

    final Widget sized = expand
        ? SizedBox(width: double.infinity, child: button)
        : button;
    if (!loading) return sized;
    // While loading, one disabled node announces the progress ("Saving")
    // in place of the label, and taps are absorbed.
    return Semantics(
      button: true,
      enabled: false,
      liveRegion: true,
      label: loadingLabel ?? label,
      excludeSemantics: true,
      child: AbsorbPointer(child: sized),
    );
  }
}

enum KanzIconButtonStyle {
  /// Bare glyph in ink.
  plain,

  /// Glyph in a hairline circle.
  outlined,

  /// Glyph on a dark disc (80 % ink), for controls laid over photos and
  /// the camera preview. A plain tint, never a blur or glass effect.
  onPhoto,
}

/// A 48 dp icon button. [semanticsLabel] is required and doubles as the
/// tooltip.
class KanzIconButton extends StatelessWidget {
  const KanzIconButton({
    super.key,
    required this.icon,
    required this.semanticsLabel,
    required this.onPressed,
    this.style = KanzIconButtonStyle.plain,
    this.selected,
  });

  final IconData icon;
  final String semanticsLabel;
  final VoidCallback? onPressed;
  final KanzIconButtonStyle style;

  /// Toggle state (flash on, speaker on), shown with the clay accent and
  /// announced as selected or not. Leave null for plain actions (share,
  /// close) so they are not announced as toggles.
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final selected = this.selected ?? false;
    final (Color fg, Color? bg, BorderSide? side) = switch (style) {
      KanzIconButtonStyle.plain => (selected ? c.accent : c.ink, null, null),
      KanzIconButtonStyle.outlined => (
        selected ? c.accent : c.ink,
        null,
        // 3:1 against paper and surface, like the secondary button.
        BorderSide(color: selected ? c.accent : c.lineStrong),
      ),
      KanzIconButtonStyle.onPhoto => (
        selected ? KanzPhotoColors.accent : KanzPhotoColors.ink,
        KanzPhotoColors.control,
        null,
      ),
    };
    // The icon's label is the button's accessible name. IconButton.tooltip
    // would add the same text again as a semantic tooltip, which Android
    // and iOS read after the label, so the tooltip here is visual only.
    return Tooltip(
      message: semanticsLabel,
      excludeFromSemantics: true,
      child: IconButton(
        onPressed: onPressed,
        isSelected: this.selected,
        icon: Icon(icon, semanticLabel: semanticsLabel),
        style: IconButton.styleFrom(
          foregroundColor: fg,
          backgroundColor: bg,
          side: side,
          fixedSize: const Size.square(KanzSpace.touchTarget),
        ),
      ),
    );
  }
}

/// The clay scan action. Round in the navigation bar; with [label] it
/// becomes the wide call to action on Home.
class ScanActionButton extends StatefulWidget {
  const ScanActionButton({
    super.key,
    required this.semanticsLabel,
    required this.onPressed,
    this.label,
    this.icon = KanzIcons.scan,
    this.size = 56,
    this.elevated = false,
  });

  final String semanticsLabel;
  final VoidCallback? onPressed;
  final String? label;
  final IconData icon;
  final double size;

  /// Soft shadow, only when the button floats over content (never inside
  /// the navigation bar).
  final bool elevated;

  @override
  State<ScanActionButton> createState() => _ScanActionButtonState();
}

class _ScanActionButtonState extends State<ScanActionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final extended = widget.label != null;
    final radius = extended
        ? KanzRadii.buttonAll
        : BorderRadius.circular(widget.size / 2);
    final content = extended
        ? Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: KanzSpace.s20,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: c.onAccent, size: 22),
                const SizedBox(width: KanzSpace.s12),
                Flexible(
                  child: Text(
                    widget.label!,
                    style: context.textStyles.labelLarge?.copyWith(
                      color: c.onAccent,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        : Icon(widget.icon, color: c.onAccent, size: 26);

    // excludeSemantics drops the InkWell's own tap action, so the node
    // declares it itself; without it a screen reader cannot activate scan.
    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      label: widget.semanticsLabel,
      onTap: widget.onPressed,
      excludeSemantics: true,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: KanzMotion.of(context, KanzMotion.fast),
        curve: KanzMotion.standard,
        child: Container(
          constraints: BoxConstraints(
            minWidth: widget.size,
            minHeight: widget.size,
          ),
          decoration: BoxDecoration(
            color: widget.onPressed == null ? c.inkDisabled : c.accent,
            borderRadius: radius,
            boxShadow: widget.elevated ? KanzElevation.floating(c) : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onPressed,
              onHighlightChanged: _setPressed,
              splashColor: c.onAccent.withValues(alpha: 0.12),
              highlightColor: c.onAccent.withValues(alpha: 0.06),
              child: SizedBox(
                height: widget.size,
                width: extended ? null : widget.size,
                child: Center(widthFactor: 1, child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The camera shutter: a clay disc inside a thin ring. The disc sinks on
/// press and a medium haptic fires on capture.
class ShutterButton extends StatefulWidget {
  const ShutterButton({
    super.key,
    required this.semanticsLabel,
    required this.onPressed,
    this.busy = false,
    this.haptics = true,
    this.size = 76,
  });

  final String semanticsLabel;
  final VoidCallback? onPressed;

  /// A capture is in progress: the ring turns into a slow spinner.
  final bool busy;

  /// Fire [KanzHaptics.capture] on press.
  final bool haptics;
  final double size;

  @override
  State<ShutterButton> createState() => _ShutterButtonState();
}

class _ShutterButtonState extends State<ShutterButton> {
  bool _pressed = false;

  void _handleTap() {
    if (widget.busy || widget.onPressed == null) return;
    if (widget.haptics) KanzHaptics.capture();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    const ringColor = KanzPhotoColors.ink;
    final accent = context.kanzColors.accent;
    final enabled = widget.onPressed != null && !widget.busy;
    final size = widget.size;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticsLabel,
      onTap: enabled ? _handleTap : null,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: enabled ? _handleTap : null,
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.busy)
                SizedBox.square(
                  dimension: size - 2,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ringColor,
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ringColor, width: 2),
                  ),
                ),
              AnimatedScale(
                scale: _pressed ? 0.88 : 1,
                duration: KanzMotion.of(context, KanzMotion.fast),
                curve: KanzMotion.standard,
                child: Container(
                  width: size - 16,
                  height: size - 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: enabled ? accent : accent.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
