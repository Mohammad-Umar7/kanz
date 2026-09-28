/// Screenshot harness for Kanz: renders any widget on the host machine (no
/// emulator) with the real bundled fonts and icons, the Kanz theme, a phone
/// sized surface, light or dark, English or Arabic (right to left) and a
/// text scale, then writes a PNG to `test/screenshots/_out/` (git-ignored)
/// for design review. Layout overflow fails the test, so the same run also
/// checks text scale and RTL.
///
/// Usage (one file per screen under `test/screenshots/`):
///
/// ```dart
/// import 'package:flutter_test/flutter_test.dart';
///
/// import 'harness.dart';
///
/// void main() {
///   setUpAll(loadKanzFonts);
///
///   for (final config in ShotConfig.matrix()) {
///     testWidgets('results ${config.id}', (tester) async {
///       final photo = await loadFixturePhoto(tester, 'glass_jar');
///       await takeShot(
///         tester,
///         name: 'results',
///         config: config,
///         precache: [photo.image],
///         child: ResultsScreen(...),
///         // localizationsDelegates: AppLocalizations.localizationsDelegates,
///       );
///     });
///   }
/// }
/// ```
///
/// Screens that read Riverpod providers need a scope above the app; pass it
/// with `wrap`, overriding the providers with fixture data:
///
/// ```dart
/// await takeShot(
///   tester,
///   name: 'swaps',
///   config: config,
///   wrap: (app) => ProviderScope(
///     overrides: [swapsProvider.overrideWith(...)],
///     child: app,
///   ),
///   child: const SwapsScreen(),
/// );
/// ```
///
/// To render a screen at its real route, inside the shell and with working
/// `context.go`, pass `routerConfig: GoRouter(initialLocation: '/swaps', ...)`
/// instead of `child`.
///
/// Run `flutter test test/screenshots` and open the PNGs in `_out/`.
/// `ShotConfig.matrix()` covers 360x800 and 412x915, light and dark, English
/// and Arabic; pass `textScales: [1.0, 1.3]` to add large text.
///
/// Notes:
/// - Images must be decoded for real: pass every [ImageProvider] the screen
///   shows in `precache` (it runs inside `runAsync`). Use
///   [loadFixturePhoto] for the committed test photos.
/// - Spinners and skeletons animate forever, so the harness pumps a fixed
///   number of frames instead of `pumpAndSettle`.
/// - `fullPage: true` renders the child at its natural height (for long
///   component columns); screens should use the default fixed viewport.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/design/design.dart';

/// One rendering configuration.
@immutable
class ShotConfig {
  const ShotConfig({
    this.size = ShotConfig.compact,
    this.brightness = Brightness.light,
    this.locale = const Locale('en'),
    this.textScale = 1.0,
    this.reduceMotion = false,
  });

  /// A small Android phone (360 x 800 dp).
  static const Size compact = Size(360, 800);

  /// A large Android phone (412 x 915 dp, Pixel 7 class).
  static const Size large = Size(412, 915);

  final Size size;
  final Brightness brightness;
  final Locale locale;
  final double textScale;

  /// Render as if the platform asked for reduced motion.
  final bool reduceMotion;

  bool get isArabic => locale.languageCode == 'ar';

  /// File-name suffix, for example `360_dark_ar_130`.
  String get id {
    final scale = textScale == 1.0 ? '' : '_${(textScale * 100).round()}';
    final theme = brightness == Brightness.dark ? 'dark' : 'light';
    return '${size.width.round()}_${theme}_${locale.languageCode}$scale';
  }

  /// Every combination of the given sizes, themes, locales and scales.
  static List<ShotConfig> matrix({
    List<Size> sizes = const [compact, large],
    List<Brightness> brightnesses = const [Brightness.light, Brightness.dark],
    List<Locale> locales = const [Locale('en'), Locale('ar')],
    List<double> textScales = const [1.0],
  }) {
    return [
      for (final size in sizes)
        for (final brightness in brightnesses)
          for (final locale in locales)
            for (final textScale in textScales)
              ShotConfig(
                size: size,
                brightness: brightness,
                locale: locale,
                textScale: textScale,
              ),
    ];
  }

  @override
  String toString() => id;
}

/// A decoded fixture photo and its pixel size.
typedef FixturePhoto = ({ImageProvider image, Size size});

const double _pixelRatio = 2;
final GlobalKey _captureKey = GlobalKey(debugLabel: 'kanz-shot');
bool _fontsLoaded = false;

/// Loads every font family declared in pubspec.yaml, the Phosphor icon font
/// and Material Icons into the test engine. Safe to call more than once.
Future<void> loadKanzFonts() async {
  if (_fontsLoaded) return;
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final entry in _pubspecFonts().entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      loader.addFont(_fontBytes(File(path)));
    }
    await loader.load();
  }

  final phosphor = _packageRoot('phosphor_flutter');
  if (phosphor != null) {
    final file = File.fromUri(phosphor.resolve('lib/fonts/Phosphor.ttf'));
    if (file.existsSync()) {
      await (FontLoader(
        'packages/phosphor_flutter/PhosphorRegular',
      )..addFont(_fontBytes(file))).load();
    }
  }

  final materialIcons = _materialIconsFont();
  if (materialIcons != null) {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(_fontBytes(materialIcons))).load();
  }
  _fontsLoaded = true;
}

Future<ByteData> _fontBytes(File file) async =>
    ByteData.sublistView(file.readAsBytesSync());

/// Reads `family -> [asset paths]` from the fonts section of pubspec.yaml,
/// so the harness always loads exactly what the app bundles.
Map<String, List<String>> _pubspecFonts() {
  final fonts = <String, List<String>>{};
  String? family;
  for (final raw in File('pubspec.yaml').readAsLinesSync()) {
    final line = raw.trim();
    if (line.startsWith('- family:')) {
      family = line.substring('- family:'.length).trim();
      fonts[family] = [];
    } else if (family != null && line.startsWith('- asset:')) {
      final path = line.substring('- asset:'.length).trim();
      if (path.endsWith('.ttf') || path.endsWith('.otf')) {
        fonts[family]!.add(path);
      }
    }
  }
  return fonts;
}

/// The root directory of a dependency, from .dart_tool/package_config.json
/// (the test runner does not support Isolate.resolvePackageUri).
Uri? _packageRoot(String package) {
  final config = File('.dart_tool/package_config.json');
  if (!config.existsSync()) return null;
  final json = jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;
  for (final entry in json['packages'] as List<dynamic>) {
    final p = entry as Map<String, dynamic>;
    if (p['name'] == package) {
      final root = Uri.parse(p['rootUri'] as String);
      final base = config.absolute.uri;
      final resolved = base.resolveUri(root);
      return resolved.path.endsWith('/') ? resolved : Uri.parse('$resolved/');
    }
  }
  return null;
}

/// Material Icons from the Flutter SDK cache: FLUTTER_ROOT when set,
/// otherwise the SDK that contains the running flutter_tester binary.
File? _materialIconsFont() {
  const font = 'bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null) {
    final file = File('$root/$font');
    if (file.existsSync()) return file;
  }
  var dir = File(Platform.resolvedExecutable).parent;
  while (dir.parent.path != dir.path) {
    final file = File('${dir.path}/$font');
    if (file.existsSync()) return file;
    dir = dir.parent;
  }
  return null;
}

/// Loads a test photo by name from `test/screenshots/fixtures/` (committed)
/// or `../backend/eval/photos/` (local only) and decodes its size.
Future<FixturePhoto> loadFixturePhoto(WidgetTester tester, String name) async {
  final candidates = [
    File('test/screenshots/fixtures/$name.jpg'),
    File('../backend/eval/photos/$name.jpg'),
  ];
  final file = candidates.firstWhere(
    (f) => f.existsSync(),
    orElse: () => throw StateError('No fixture photo named $name'),
  );
  final bytes = file.readAsBytesSync();
  final size = await tester.runAsync(() async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final s = Size(frame.image.width.toDouble(), frame.image.height.toDouble());
    frame.image.dispose();
    codec.dispose();
    return s;
  });
  return (image: MemoryImage(bytes), size: size!);
}

/// Renders [child] (or the app at [routerConfig]'s location) with [config]
/// and writes `_out/<name>_<config.id>.png`.
///
/// - [wrap]: widgets above the app, usually a Riverpod `ProviderScope`.
/// - [precache]: images to decode before the capture.
/// - [fullPage]: capture the child at its natural height (up to
///   [maxHeight]) instead of a fixed phone viewport.
/// - [systemInsets]: simulate a status bar (24 dp) and gesture bar (16 dp).
/// - [frames]: 100 ms frames pumped before the capture, enough for entrance
///   animations and the bounding box draw-in to finish.
Future<File> takeShot(
  WidgetTester tester, {
  required String name,
  Widget? child,
  RouterConfig<Object>? routerConfig,
  Widget Function(Widget app)? wrap,
  ShotConfig config = const ShotConfig(),
  List<ImageProvider> precache = const [],
  bool fullPage = false,
  double maxHeight = 6000,
  bool systemInsets = true,
  int frames = 20,
  Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates = const [],
}) async {
  assert(
    (child == null) != (routerConfig == null),
    'Pass either child or routerConfig',
  );
  assert(!fullPage || child != null, 'fullPage needs a child');
  await loadKanzFonts();

  final logical = fullPage ? Size(config.size.width, maxHeight) : config.size;
  tester.view
    ..devicePixelRatio = _pixelRatio
    ..physicalSize = logical * _pixelRatio;
  if (systemInsets && !fullPage) {
    tester.view.padding = const FakeViewPadding(
      top: 24 * _pixelRatio,
      bottom: 16 * _pixelRatio,
    );
    tester.view.viewPadding = tester.view.padding;
  }
  addTearDown(tester.view.reset);

  final theme = config.brightness == Brightness.dark
      ? KanzTheme.dark(locale: config.locale)
      : KanzTheme.light(locale: config.locale);

  Widget? home = child;
  if (fullPage) {
    home = Material(
      color: theme.scaffoldBackgroundColor,
      child: Align(
        alignment: Alignment.topCenter,
        child: RepaintBoundary(
          key: _captureKey,
          // Unbounded height, fixed width: the child takes its natural
          // height even when it is a Column that would otherwise expand.
          child: UnconstrainedBox(
            constrainedAxis: Axis.horizontal,
            child: ColoredBox(
              color: theme.scaffoldBackgroundColor,
              child: SizedBox(width: config.size.width, child: child),
            ),
          ),
        ),
      ),
    );
  }

  final delegates = [
    ...localizationsDelegates,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  Widget builder(BuildContext context, Widget? appChild) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(config.textScale),
      disableAnimations: config.reduceMotion,
    ),
    child: appChild!,
  );
  Widget app = routerConfig == null
      ? MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          locale: config.locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: delegates,
          builder: builder,
          home: home,
        )
      : MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: theme,
          locale: config.locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: delegates,
          builder: builder,
          routerConfig: routerConfig,
        );
  if (wrap != null) app = wrap(app);

  await tester.pumpWidget(
    fullPage ? app : RepaintBoundary(key: _captureKey, child: app),
  );

  if (precache.isNotEmpty) {
    final context = tester.element(find.byType(Navigator).first);
    await tester.runAsync(
      () => Future.wait([for (final p in precache) precacheImage(p, context)]),
    );
  }
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  // Images that finished decoding during the frames above need a real
  // event-loop turn to deliver, then one more frame to paint.
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pump();

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: _pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });

  final out = File('test/screenshots/_out/${name}_${config.id}.png');
  out.parent.createSync(recursive: true);
  out.writeAsBytesSync(bytes!);
  return out;
}
