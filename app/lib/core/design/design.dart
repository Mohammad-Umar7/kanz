/// The Kanz design system. Screens import this one file:
///
/// ```dart
/// import 'package:kanz/core/design/design.dart';
/// ```
///
/// Tokens and the theme come first; components are pure widgets (no
/// Riverpod, no localization lookups: every string is passed in).
/// See DESIGN.md at the repository root for the rules behind them.
library;

export 'context.dart';
export 'contrast.dart';
export 'haptics.dart';
export 'icons.dart';
export 'material_colors.dart';
export 'theme.dart';
export 'tokens.dart';
export 'typography.dart';

export 'components/before_after_slider.dart';
export 'components/bounding_box_overlay.dart';
export 'components/brand_mark.dart';
export 'components/buttons.dart';
export 'components/callout.dart';
export 'components/card.dart';
export 'components/chips.dart';
export 'components/data.dart';
export 'components/idea_card.dart';
export 'components/inputs.dart';
export 'components/layout.dart';
export 'components/motion.dart';
export 'components/nav_bar.dart';
export 'components/permission_rationale.dart';
export 'components/pipeline_timeline.dart';
export 'components/place_row.dart';
export 'components/segmented_tabs.dart';
export 'components/specimen_card.dart';
export 'components/states.dart';
export 'components/steps.dart';
export 'components/swap_card.dart';
export 'components/viewfinder.dart';
