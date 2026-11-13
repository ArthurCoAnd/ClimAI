import 'package:clim_ai/core/theme/glass_theme.dart';
import 'package:clim_ai/ui/widgets/glass_surfaces.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('contentSidePadding', () {
    test('uses the screen margin on narrow screens', () {
      expect(contentSidePadding(360), GlassMetrics.screenMargin);
      expect(
        contentSidePadding(GlassMetrics.maxContentWidth),
        GlassMetrics.screenMargin,
      );
    });

    test('centers capped content on wide screens', () {
      const width = 1440.0;
      final side = contentSidePadding(width);
      expect(
        width - 2 * side,
        GlassMetrics.maxContentWidth - 2 * GlassMetrics.screenMargin,
      );
    });
  });
}
