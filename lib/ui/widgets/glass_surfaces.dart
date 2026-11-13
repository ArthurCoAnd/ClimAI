import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../../core/theme/glass_theme.dart';

/// Dark backdrop with glowing amber blobs for the glass to blur.
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: GlassGradients.background),
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: IgnorePointer(child: CustomPaint(painter: _BlobPainter())),
          ),
          child,
        ],
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  /// (center as a fraction of the size, radius as a fraction of the width,
  /// color, peak opacity). Opacity stays ≤ 0.4 so glass over a blob is still
  /// dark enough for light text.
  static final _blobs = [
    (const Offset(0.1, 0.08), 0.75, GlassColors.blobAmber, 0.40),
    (const Offset(0.95, 0.35), 0.7, GlassColors.blobOrange, 0.32),
    (const Offset(0.2, 0.75), 0.8, GlassColors.blobGold, 0.30),
    (const Offset(0.9, 0.98), 0.6, GlassColors.blobAmber, 0.25),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width.clamp(320.0, 900.0);
    for (final (center, radius, color, alpha) in _blobs) {
      final c = Offset(center.dx * size.width, center.dy * size.height);
      final r = radius * unit;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }
  }

  @override
  bool shouldRepaint(_BlobPainter oldDelegate) => false;
}

/// Side padding that centers content of at most
/// [GlassMetrics.maxContentWidth] inside an area [width] wide, keeping
/// [GlassMetrics.screenMargin] on each side.
double contentSidePadding(double width) {
  final extra = (width - GlassMetrics.maxContentWidth) / 2;
  return GlassMetrics.screenMargin + (extra > 0 ? extra : 0);
}

/// Full-width area whose content is centered with a capped width.
///
/// Scrollables built inside stay full width so their scrollbar sits at the
/// screen edge; [builder] receives the side padding to apply to the content.
class ContentLayout extends StatelessWidget {
  const ContentLayout({super.key, required this.builder});

  final Widget Function(BuildContext context, double sidePadding) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          builder(context, contentSidePadding(constraints.maxWidth)),
    );
  }
}

/// Press / focus handling shared by every tappable glass element.
///
/// While pressed the element shrinks slightly; [builder] also receives the
/// state so it can brighten its fill.
class GlassPressable extends StatefulWidget {
  const GlassPressable({super.key, required this.onTap, required this.builder});

  final VoidCallback? onTap;
  final Widget Function(BuildContext context, bool pressed, bool focused)
  builder;

  @override
  State<GlassPressable> createState() => _GlassPressableState();
}

class _GlassPressableState extends State<GlassPressable> {
  bool _pressed = false;
  bool _focused = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;
    if (onTap == null) return widget.builder(context, false, false);

    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : (_pressed ? GlassMetrics.pressIn : GlassMetrics.pressOut);

    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            onTap();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: duration,
          curve: Curves.easeOut,
          child: widget.builder(context, _pressed, _focused),
        ),
      ),
    );
  }
}

/// Frosted glass card. Brightens and shrinks slightly when tapped.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.radius = GlassMetrics.cardRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return GlassPressable(
      onTap: onTap,
      builder: (context, pressed, focused) => GlassPanel(
        pressed: pressed,
        focused: focused,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// The frosted surface itself, without tap handling: backdrop blur,
/// translucent fill, light sheen and a hairline border.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    required this.borderRadius,
    this.pressed = false,
    this.focused = false,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final bool pressed;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : (pressed ? GlassMetrics.pressIn : GlassMetrics.pressOut);
    // Translucency hurts legibility for some people: honor high contrast.
    final opaque = MediaQuery.highContrastOf(context);

    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: pressed ? GlassShadows.pressed : GlassShadows.panel,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: borderRadius,
        border: focused
            ? Border.all(color: GlassColors.accent, width: 3)
            : Border.all(
                color: GlassColors.glassBorder,
                width: GlassMetrics.borderWidth,
              ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          enabled: !opaque,
          filter: ImageFilter.blur(
            sigmaX: GlassMetrics.blurSigma,
            sigmaY: GlassMetrics.blurSigma,
          ),
          child: AnimatedContainer(
            duration: duration,
            color: opaque
                ? GlassColors.glassOpaque
                : (pressed
                      ? GlassColors.glassFillPressed
                      : GlassColors.glassFill),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                const Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: GlassGradients.sheen),
                    ),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Darker tinted well inside a panel, for readouts. No extra blur.
class GlassWell extends StatelessWidget {
  const GlassWell({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = GlassMetrics.wellRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: GlassColors.wellFill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: GlassColors.wellBorder),
      ),
      child: child,
    );
  }
}
