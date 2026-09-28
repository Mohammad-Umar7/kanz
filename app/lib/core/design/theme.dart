/// The Kanz Material 3 theme, built entirely from design tokens.
///
/// Every [ColorScheme] slot is set explicitly so no seed-derived purple can
/// leak into a component, and every component the app uses has a theme so
/// screens rarely need local styling.
///
/// Usage (App Core):
/// ```dart
/// MaterialApp.router(
///   theme: KanzTheme.light(locale: locale),
///   darkTheme: KanzTheme.dark(locale: locale),
/// )
/// ```
/// Pass the active locale so Arabic gets IBM Plex Sans Arabic for every
/// role; without it the theme defaults to the Latin type system (Arabic
/// text still renders through the font fallback).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';
import 'typography.dart';

abstract final class KanzTheme {
  /// Light theme: paper background, white cards, ink text.
  static ThemeData light({Locale? locale}) =>
      _cached(KanzColors.light, Brightness.light, locale);

  /// Dark theme: near-black warm background, warm off-white ink.
  static ThemeData dark({Locale? locale}) =>
      _cached(KanzColors.dark, Brightness.dark, locale);

  // One ThemeData per brightness and script. MaterialApp animates between
  // unequal themes, so building a fresh one on every rebuild of the app
  // root would start a 200 ms whole-app theme lerp each time.
  static final Map<(Brightness, bool), ThemeData> _themes = {};

  static ThemeData _cached(
    KanzColors c,
    Brightness brightness,
    Locale? locale,
  ) {
    final arabic = KanzFonts.isArabic(locale);
    return _themes.putIfAbsent((
      brightness,
      arabic,
    ), () => _build(c, brightness, arabic: arabic));
  }

  /// The [ColorScheme] for a palette. Public so tests can audit every slot.
  static ColorScheme colorScheme(KanzColors c, Brightness brightness) {
    final light = brightness == Brightness.light;
    return ColorScheme(
      brightness: brightness,
      // Primary is ink: primary buttons, focused borders, selected controls.
      primary: c.ink,
      onPrimary: c.onInverse,
      primaryContainer: c.surfaceSunken,
      onPrimaryContainer: c.ink,
      primaryFixed: c.surfaceSunken,
      primaryFixedDim: c.line,
      onPrimaryFixed: c.ink,
      onPrimaryFixedVariant: c.inkSecondary,
      // Secondary stays neutral.
      secondary: c.inkSecondary,
      onSecondary: c.surface,
      secondaryContainer: c.surfaceSunken,
      onSecondaryContainer: c.ink,
      secondaryFixed: c.surfaceSunken,
      secondaryFixedDim: c.line,
      onSecondaryFixed: c.ink,
      onSecondaryFixedVariant: c.inkSecondary,
      // Tertiary is the single accent, clay.
      tertiary: c.accent,
      onTertiary: c.onAccent,
      tertiaryContainer: c.accent,
      onTertiaryContainer: c.onAccent,
      tertiaryFixed: c.accent,
      tertiaryFixedDim: c.accent,
      onTertiaryFixed: c.onAccent,
      onTertiaryFixedVariant: c.onAccent,
      error: c.danger,
      onError: c.onDanger,
      errorContainer: c.surfaceSunken,
      onErrorContainer: c.danger,
      surface: c.background,
      onSurface: c.ink,
      surfaceDim: light ? const Color(0xFFE9E5DC) : const Color(0xFF0C0D0B),
      surfaceBright: light ? c.surface : const Color(0xFF2A2B28),
      surfaceContainerLowest: light ? c.surface : const Color(0xFF0C0D0B),
      surfaceContainerLow: light ? const Color(0xFFFAF8F4) : c.surface,
      surfaceContainer: light
          ? const Color(0xFFF0ECE4)
          : const Color(0xFF1F201D),
      surfaceContainerHigh: c.surfaceSunken,
      surfaceContainerHighest: light ? c.line : const Color(0xFF2C2D29),
      onSurfaceVariant: c.inkSecondary,
      outline: c.lineStrong,
      outlineVariant: c.line,
      shadow: c.shadow,
      scrim: c.scrim,
      inverseSurface: c.inverse,
      onInverseSurface: c.onInverse,
      inversePrimary: c.onInverse,
      // No tonal tint on elevated surfaces: surfaces stay paper and ink.
      surfaceTint: Colors.transparent,
    );
  }

  static ThemeData _build(
    KanzColors c,
    Brightness brightness, {
    required bool arabic,
  }) {
    final scheme = colorScheme(c, brightness);
    final text = KanzTypography.textTheme(c, arabic: arabic);
    final type = KanzType.build(c, arabic: arabic);
    final light = brightness == Brightness.light;

    final hairline = BorderSide(color: c.line, width: KanzElevation.hairline);
    final strong = BorderSide(
      color: c.lineStrong,
      width: KanzElevation.hairline,
    );
    const buttonShape = RoundedRectangleBorder(
      borderRadius: KanzRadii.buttonAll,
    );
    const buttonPadding = EdgeInsetsDirectional.symmetric(
      horizontal: KanzSpace.s20,
      vertical: KanzSpace.s12,
    );
    const buttonSize = Size(64, 52);

    Color pressed(Color on) => on.withValues(alpha: 0.10);
    WidgetStateProperty<Color?> overlay(Color on) =>
        WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return pressed(on);
          if (states.contains(WidgetState.focused)) {
            return on.withValues(alpha: 0.10);
          }
          if (states.contains(WidgetState.hovered)) {
            return on.withValues(alpha: 0.06);
          }
          return null;
        });

    final filledStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled) ? c.surfaceSunken : c.ink,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled) ? c.inkDisabled : c.onInverse,
      ),
      overlayColor: overlay(c.onInverse),
      elevation: const WidgetStatePropertyAll(0),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      minimumSize: const WidgetStatePropertyAll(buttonSize),
      padding: const WidgetStatePropertyAll(buttonPadding),
      shape: const WidgetStatePropertyAll(buttonShape),
      textStyle: WidgetStatePropertyAll(text.labelLarge),
      iconSize: const WidgetStatePropertyAll(20),
      tapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkRipple.splashFactory,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [c, type],
      fontFamily: arabic ? KanzFonts.arabic : KanzFonts.sans,
      fontFamilyFallback: arabic
          ? const [KanzFonts.sans]
          : const [KanzFonts.arabic],
      textTheme: text,
      primaryTextTheme: text,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      // Legacy color slots still read by some widgets; set them so no
      // Material default (blue swatch, purple seed) can leak through.
      primaryColor: c.ink,
      primaryColorLight: c.surfaceSunken,
      primaryColorDark: c.ink,
      secondaryHeaderColor: c.surfaceSunken,
      unselectedWidgetColor: c.lineStrong,
      shadowColor: c.shadow,
      cardColor: c.surface,
      dividerColor: c.line,
      disabledColor: c.inkDisabled,
      hintColor: c.inkSecondary,
      splashFactory: InkRipple.splashFactory,
      splashColor: c.ink.withValues(alpha: 0.06),
      highlightColor: c.ink.withValues(alpha: 0.04),
      hoverColor: c.ink.withValues(alpha: 0.04),
      focusColor: c.ink.withValues(alpha: 0.10),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      iconTheme: IconThemeData(color: c.ink, size: 24),
      primaryIconTheme: IconThemeData(color: c.ink, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: KanzSpace.gutter,
        toolbarHeight: 56,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: c.ink, size: 24),
        actionsIconTheme: IconThemeData(color: c.ink, size: 24),
        systemOverlayStyle: light
            ? SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: c.background,
                systemNavigationBarIconBrightness: Brightness.dark,
              )
            : SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: c.background,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: KanzRadii.cardAll,
          side: hairline,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: filledStyle),
      elevatedButtonTheme: ElevatedButtonThemeData(style: filledStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? c.inkDisabled : c.ink,
          ),
          overlayColor: overlay(c.ink),
          side: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? hairline : strong,
          ),
          elevation: const WidgetStatePropertyAll(0),
          minimumSize: const WidgetStatePropertyAll(buttonSize),
          padding: const WidgetStatePropertyAll(buttonPadding),
          shape: const WidgetStatePropertyAll(buttonShape),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          iconSize: const WidgetStatePropertyAll(20),
          splashFactory: InkRipple.splashFactory,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? c.inkDisabled : c.ink,
          ),
          overlayColor: overlay(c.ink),
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          padding: const WidgetStatePropertyAll(
            EdgeInsetsDirectional.symmetric(
              horizontal: KanzSpace.s12,
              vertical: KanzSpace.s8,
            ),
          ),
          shape: const WidgetStatePropertyAll(buttonShape),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          iconSize: const WidgetStatePropertyAll(20),
          splashFactory: InkRipple.splashFactory,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? c.inkDisabled : c.ink,
          ),
          overlayColor: overlay(c.ink),
          minimumSize: const WidgetStatePropertyAll(
            Size.square(KanzSpace.touchTarget),
          ),
          iconSize: const WidgetStatePropertyAll(24),
          shape: const WidgetStatePropertyAll(CircleBorder()),
          splashFactory: InkRipple.splashFactory,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        // The only floating action in Kanz is the scan action: clay.
        backgroundColor: c.accent,
        foregroundColor: c.onAccent,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: c.surface,
        isDense: false,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: KanzSpace.s16,
          vertical: KanzSpace.s16,
        ),
        labelStyle: text.bodyMedium?.copyWith(color: c.inkSecondary),
        floatingLabelStyle: text.bodyMedium?.copyWith(color: c.ink),
        hintStyle: text.bodyMedium?.copyWith(color: c.inkSecondary),
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall?.copyWith(color: c.danger),
        prefixIconColor: c.inkSecondary,
        suffixIconColor: c.inkSecondary,
        border: OutlineInputBorder(
          borderRadius: KanzRadii.inputAll,
          borderSide: strong,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: KanzRadii.inputAll,
          borderSide: strong,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KanzRadii.inputAll,
          borderSide: BorderSide(color: c.ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: KanzRadii.inputAll,
          borderSide: BorderSide(color: c.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: KanzRadii.inputAll,
          borderSide: BorderSide(color: c.danger, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: KanzRadii.inputAll,
          borderSide: hairline,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.inverse,
        disabledColor: c.surfaceSunken,
        checkmarkColor: c.onInverse,
        deleteIconColor: c.inkSecondary,
        labelStyle: text.labelMedium,
        secondaryLabelStyle: text.labelMedium?.copyWith(color: c.onInverse),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: KanzSpace.s4,
          vertical: KanzSpace.s4,
        ),
        labelPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: KanzSpace.s8,
        ),
        side: hairline,
        shape: const RoundedRectangleBorder(borderRadius: KanzRadii.chipAll),
        showCheckmark: false,
        elevation: 0,
        pressElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: c.ink, size: 16),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.inverse : c.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.onInverse : c.ink,
          ),
          overlayColor: overlay(c.ink),
          side: WidgetStatePropertyAll(strong),
          textStyle: WidgetStatePropertyAll(text.labelMedium),
          minimumSize: const WidgetStatePropertyAll(Size(48, 44)),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: KanzRadii.inputAll),
          ),
        ),
        selectedIcon: const SizedBox.shrink(),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        modalBackgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        modalBarrierColor: c.scrim,
        showDragHandle: true,
        dragHandleColor: c.lineStrong,
        dragHandleSize: const Size(36, 4),
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: KanzRadii.sheetTop),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        barrierColor: c.scrim,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: KanzSpace.gutter,
          vertical: KanzSpace.s24,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(KanzRadii.sheet)),
        ),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.inkSecondary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.inverse,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.onInverse),
        actionTextColor: c.onInverse,
        disabledActionTextColor: c.onInverse.withValues(alpha: 0.5),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(
          KanzSpace.gutter,
          0,
          KanzSpace.gutter,
          KanzSpace.s16,
        ),
        shape: const RoundedRectangleBorder(borderRadius: KanzRadii.inputAll),
        closeIconColor: c.onInverse,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelSmall?.copyWith(
            color: s.contains(WidgetState.selected) ? c.ink : c.inkSecondary,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 24,
            color: s.contains(WidgetState.selected) ? c.ink : c.inkSecondary,
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.ink,
        linearTrackColor: c.surfaceSunken,
        circularTrackColor: Colors.transparent,
        linearMinHeight: 4,
        borderRadius: const BorderRadius.all(Radius.circular(2)),
        refreshBackgroundColor: c.surface,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: KanzSpace.gutter,
        ),
        minVerticalPadding: KanzSpace.s12,
        minLeadingWidth: 24,
        horizontalTitleGap: KanzSpace.s16,
        iconColor: c.ink,
        textColor: c.ink,
        tileColor: Colors.transparent,
        selectedColor: c.ink,
        selectedTileColor: c.surfaceSunken,
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall,
        leadingAndTrailingTextStyle: type.data,
      ),
      dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return c.inkDisabled;
          return s.contains(WidgetState.selected) ? c.onInverse : c.lineStrong;
        }),
        trackColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return c.surfaceSunken;
          return s.contains(WidgetState.selected) ? c.ink : c.surfaceSunken;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.ink : c.lineStrong,
        ),
        trackOutlineWidth: const WidgetStatePropertyAll(1),
        overlayColor: overlay(c.ink),
        thumbIcon: const WidgetStatePropertyAll(null),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return c.surfaceSunken;
          return s.contains(WidgetState.selected) ? c.ink : Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll(c.onInverse),
        side: WidgetStateBorderSide.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? BorderSide(color: c.ink, width: 1.5)
              : BorderSide(color: c.lineStrong, width: 1.5),
        ),
        overlayColor: overlay(c.ink),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.ink : c.lineStrong,
        ),
        overlayColor: overlay(c.ink),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.ink,
        inactiveTrackColor: c.surfaceSunken,
        thumbColor: c.ink,
        overlayColor: c.ink.withValues(alpha: 0.08),
        valueIndicatorColor: c.inverse,
        valueIndicatorTextStyle: text.labelMedium?.copyWith(color: c.onInverse),
        trackHeight: 4,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.ink,
        unselectedLabelColor: c.inkSecondary,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: c.ink,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: c.line,
        overlayColor: overlay(c.ink),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.inverse,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        textStyle: text.labelSmall?.copyWith(color: c.onInverse),
        padding: const EdgeInsets.symmetric(
          horizontal: KanzSpace.s12,
          vertical: KanzSpace.s8,
        ),
        waitDuration: const Duration(milliseconds: 400),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.ink,
        selectionColor: c.ink.withValues(alpha: 0.16),
        selectionHandleColor: c.ink,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(c.lineStrong.withValues(alpha: 0.6)),
        thickness: const WidgetStatePropertyAll(3),
        radius: const Radius.circular(2),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: c.accent,
        textColor: c.onAccent,
        textStyle: text.labelSmall,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: KanzPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: KanzPageTransitionsBuilder(),
          TargetPlatform.linux: KanzPageTransitionsBuilder(),
          TargetPlatform.fuchsia: KanzPageTransitionsBuilder(),
        },
      ),
    );
  }
}

/// A calm forward transition: the incoming page fades in while rising a few
/// pixels, on the Material 3 emphasized decelerate curve (played backwards
/// on pop, so the page accelerates away). With reduced motion it becomes a
/// plain cross-fade.
class KanzPageTransitionsBuilder extends PageTransitionsBuilder {
  const KanzPageTransitionsBuilder();

  // Animatables rather than CurvedAnimations: buildTransitions runs on
  // every rebuild of the route, and each CurvedAnimation would register a
  // listener on the route's animation that is never removed.
  static final Animatable<double> _fade = CurveTween(
    curve: const Interval(0, 0.7, curve: KanzMotion.standard),
  );
  static final Animatable<Offset> _rise = Tween<Offset>(
    begin: const Offset(0, 0.03),
    end: Offset.zero,
  ).chain(CurveTween(curve: KanzMotion.enter));

  @override
  Duration get transitionDuration => KanzMotion.slow;

  @override
  Duration get reverseTransitionDuration => KanzMotion.medium;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fade = animation.drive(_fade);
    if (KanzMotion.reduced(context)) {
      return FadeTransition(opacity: fade, child: child);
    }
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: animation.drive(_rise), child: child),
    );
  }
}
