import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/weather_codes.dart';
import '../../data/models/weather.dart';

Color weatherToneColor(WeatherTone tone) => switch (tone) {
  .sun => GlassColors.accent,
  .rain => GlassColors.rain,
  .storm => GlassColors.accent,
  .cloud || .snow => GlassColors.ink,
};

/// Weather icon in a round tinted glass well.
class WeatherGlyph extends StatelessWidget {
  const WeatherGlyph({super.key, required this.info, this.size = 56});

  /// Null renders an empty glass (loading).
  final WeatherInfo? info;
  final double size;

  @override
  Widget build(BuildContext context) {
    final info = this.info;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: GlassColors.wellFill,
        border: Border.all(color: GlassColors.wellBorder),
      ),
      child: info == null
          ? null
          : Icon(
              info.icon,
              size: size * 0.55,
              color: weatherToneColor(info.tone),
              shadows: GlassShadows.text,
            ),
    );
  }
}

/// Small icon + value pair, e.g. humidity or rain probability.
class MetricChip extends StatelessWidget {
  const MetricChip({
    super.key,
    required this.icon,
    required this.value,
    required this.semanticLabel,
    this.color = GlassColors.inkMuted,
  });

  const MetricChip.humidity(int? percent, {super.key})
    : icon = Icons.opacity,
      value = percent == null ? '–' : '$percent%',
      semanticLabel = 'Umidade',
      color = GlassColors.inkMuted;

  MetricChip.rainAmount(double? mm, {super.key})
    : icon = Icons.water_drop,
      value = formatRainAmount(mm),
      semanticLabel = 'Precipitação',
      color = GlassColors.rain;

  const MetricChip.rain(int? percent, {super.key})
    : icon = Icons.umbrella,
      value = percent == null ? '–' : '$percent%',
      semanticLabel = 'Chance de chuva',
      color = GlassColors.rain;

  final IconData icon;
  final String value;
  final String semanticLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$semanticLabel $value',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(value, style: GlassText.label.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// Horizontal strip of hourly readings: time, status, temperature, rain
/// probability and humidity. Meant to sit inside a [GlassPanel] or [GlassWell].
class HourlyStrip extends StatelessWidget {
  const HourlyStrip({super.key, required this.points, this.firstIsNow = false});

  final List<HourlyPoint> points;

  /// Labels the first point "Agora" instead of its hour.
  final bool firstIsNow;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, point) in points.indexed)
            _HourTile(point: point, isNow: firstIsNow && index == 0),
        ],
      ),
    );
  }
}

class _HourTile extends StatelessWidget {
  const _HourTile({required this.point, required this.isNow});

  final HourlyPoint point;
  final bool isNow;

  @override
  Widget build(BuildContext context) {
    final info = weatherInfo(point.weatherCode, isDay: point.isDay);
    final time = isNow ? 'Agora' : formatHour(point.time);
    return Semantics(
      label:
          '$time, ${info.label}, ${point.temperature.round()} graus, '
          'chance de chuva ${formatPercent(point.precipitationProbability)}, '
          'precipitação ${formatRainAmount(point.precipitation)}, '
          'umidade ${point.humidity}%',
      excludeSemantics: true,
      child: Tooltip(
        message: info.label,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 64),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: GlassText.label.copyWith(
                    color: isNow ? GlassColors.accent : GlassColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Icon(info.icon, size: 28, color: weatherToneColor(info.tone)),
                const SizedBox(height: 8),
                Text(
                  formatTemp(point.temperature),
                  style: GlassText.title.copyWith(
                    color: GlassColors.ink,
                    shadows: const [],
                  ),
                ),
                const SizedBox(height: 8),
                MetricChip.rain(point.precipitationProbability),
                const SizedBox(height: 4),
                MetricChip.rainAmount(point.precipitation),
                const SizedBox(height: 4),
                MetricChip.humidity(point.humidity),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
