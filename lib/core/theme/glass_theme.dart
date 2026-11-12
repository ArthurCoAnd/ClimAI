import 'package:material_ui/material_ui.dart';

/// Design tokens for the Glassmorphism style described in `DESIGN.md`.
///
/// Frosted panels float over a dark, vibrant amber backdrop. Every surface
/// stays dark enough that the light [ink] keeps a 4.5:1 contrast.
abstract final class GlassColors {
  // Backdrop: near-black warm brown with glowing amber blobs.
  static const Color bgTop = Color(0xFF1F1100);
  static const Color bgBottom = Color(0xFF0D0700);
  static const Color blobAmber = Colors.amber;
  static final Color blobOrange = Colors.deepOrange.shade400;
  static final Color blobGold = Colors.amber.shade700;

  // Frosted glass.
  static const Color glassFill = Color(0x1FFFFFFF); // white 12%
  static const Color glassFillPressed = Color(0x33FFFFFF); // white 20%
  static const Color glassHighlight = Color(0x26FFFFFF); // top sheen
  static const Color glassBorder = Color(0x40FFFFFF); // white 25%
  static const Color glassBorderSoft = Color(0x14FFFFFF); // white 8%

  /// Solid fallback when the platform asks for high contrast.
  static const Color glassOpaque = Color(0xFF3A2406);

  // Inner wells (readouts inside a panel): darker tint, no extra blur.
  static const Color wellFill = Color(0x38000000); // black 22%
  static const Color wellBorder = Color(0x1FFFFFFF);

  /// Text and icons on every surface.
  static const Color ink = Color(0xFFFFF8EC);
  static const Color inkMuted = Color(0xFFFFF0CF);

  /// Amber accent: favorite star, sun, "Agora", max temperature, focus ring.
  static final Color accent = Colors.amber.shade300;

  static const Color rain = Color(0xFFB3E5FF);
  static const Color danger = Color(0xFFFFCDC4);

  static const Color handle = Color(0x66FFFFFF);
}

abstract final class GlassGradients {
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [GlassColors.bgTop, GlassColors.bgBottom],
  );

  /// Light reflection across the top-left of a panel.
  static const LinearGradient sheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment(0.2, 0.6),
    colors: [GlassColors.glassHighlight, Color(0x00FFFFFF)],
  );

  /// Border that catches the light on the top-left edge.
  static const LinearGradient border = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [GlassColors.glassBorder, GlassColors.glassBorderSoft],
  );
}

abstract final class GlassShadows {
  /// Soft depth under floating panels.
  static const List<BoxShadow> panel = [
    BoxShadow(color: Color(0x40000000), offset: Offset(0, 12), blurRadius: 32),
  ];

  static const List<BoxShadow> pressed = [
    BoxShadow(color: Color(0x33000000), offset: Offset(0, 4), blurRadius: 12),
  ];

  /// Keeps light text crisp over the blurred backdrop.
  static const List<Shadow> text = [
    Shadow(color: Color(0x59000000), offset: Offset(0, 1), blurRadius: 4),
  ];
}

abstract final class GlassMetrics {
  static const double cardRadius = 24;
  static const double wellRadius = 16;
  static const double borderWidth = 1;
  static const double blurSigma = 18;
  static const double screenMargin = 16;
  static const double maxContentWidth = 640;
  static const double minTouchTarget = 48;

  static const Duration pressIn = Duration(milliseconds: 120);
  static const Duration pressOut = Duration(milliseconds: 250);
}

abstract final class GlassText {
  static const _tabular = [FontFeature.tabularFigures()];

  static const TextStyle display = TextStyle(
    fontSize: 72,
    height: 1,
    fontWeight: FontWeight.w200,
    color: GlassColors.ink,
    fontFeatures: _tabular,
    shadows: GlassShadows.text,
  );
  static const TextStyle headline = TextStyle(
    fontSize: 40,
    height: 1,
    fontWeight: FontWeight.w300,
    color: GlassColors.ink,
    fontFeatures: _tabular,
    shadows: GlassShadows.text,
  );
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: GlassColors.ink,
    shadows: GlassShadows.text,
  );
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: GlassColors.ink,
    shadows: GlassShadows.text,
  );
  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: GlassColors.inkMuted,
    fontFeatures: _tabular,
    shadows: GlassShadows.text,
  );
}

ThemeData buildGlassTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Colors.amber,
    brightness: .dark,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: GlassColors.bgBottom,
    snackBarTheme: SnackBarThemeData(
      behavior: .floating,
      backgroundColor: GlassColors.glassOpaque,
      contentTextStyle: const TextStyle(color: GlassColors.ink, fontSize: 15),
      actionTextColor: GlassColors.accent,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: GlassColors.accent,
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: GlassColors.accent),
  );
}
