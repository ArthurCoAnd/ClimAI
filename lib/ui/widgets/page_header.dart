import 'package:material_ui/material_ui.dart';

import '../../core/theme/glass_theme.dart';

/// Top bar shared by the screens: optional leading button, title/subtitle and
/// trailing actions.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GlassMetrics.screenMargin,
        12,
        GlassMetrics.screenMargin,
        12,
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Semantics(
              header: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GlassText.title.copyWith(fontSize: 24),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GlassText.label,
                    ),
                ],
              ),
            ),
          ),
          for (final action in actions) ...[const SizedBox(width: 12), action],
        ],
      ),
    );
  }
}

/// Engraved section heading.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
      child: Semantics(header: true, child: Text(text, style: GlassText.title)),
    );
  }
}
