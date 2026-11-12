import 'package:material_ui/material_ui.dart';

import '../../core/theme/glass_theme.dart';
import 'glass_surfaces.dart';

/// Round raised button with an icon. Always at least 48×48.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.iconColor = GlassColors.ink,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: GlassPressable(
          onTap: onTap,
          builder: (context, pressed, focused) => SizedBox.square(
            dimension: GlassMetrics.minTouchTarget,
            child: GlassPanel(
              pressed: pressed,
              focused: focused,
              borderRadius: BorderRadius.circular(
                GlassMetrics.minTouchTarget / 2,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 24,
                  color: iconColor,
                  shadows: GlassShadows.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Raised pill button with a label and optional icon.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GlassPressable(
        onTap: onTap,
        builder: (context, pressed, focused) => ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: GlassMetrics.minTouchTarget,
          ),
          child: GlassPanel(
            pressed: pressed,
            focused: focused,
            borderRadius: BorderRadius.circular(GlassMetrics.minTouchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                      color: GlassColors.ink,
                      shadows: GlassShadows.text,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(child: Text(label, style: GlassText.body)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Message with an icon and an optional action on a glass panel. Used for
/// empty and error states.
class GlassNotice extends StatelessWidget {
  const GlassNotice({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.iconColor,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  /// Defaults to [GlassColors.inkMuted].
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(GlassMetrics.cardRadius),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: iconColor ?? GlassColors.inkMuted),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GlassText.body.copyWith(
                  color: GlassColors.ink,
                  shadows: const [],
                ),
              ),
              if (actionLabel != null) ...[
                const SizedBox(height: 16),
                GlassButton(
                  label: actionLabel!,
                  icon: actionIcon,
                  onTap: onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
