import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/weather_codes.dart';
import '../../data/models/weather.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_surfaces.dart';
import '../widgets/hourly_chart.dart';
import '../widgets/weather_widgets.dart';
import 'city_page.dart' show MinMaxReadout;

/// Opens the hourly panel for [day], in the same format as the 24h strip.
Future<void> showDayDetailSheet(
  BuildContext context, {
  required DailySummary day,
  required DateTime today,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _DayDetailSheet(day: day, today: today),
  );
}

class _DayDetailSheet extends StatelessWidget {
  const _DayDetailSheet({required this.day, required this.today});

  final DailySummary day;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final info = weatherInfo(day.weatherCode);
    return SafeArea(
      top: false,
      // heightFactor 1 keeps the sheet sized to its content.
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: GlassMetrics.maxContentWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: GlassPanel(
              borderRadius: BorderRadius.circular(28),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: GlassColors.handle,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        WeatherGlyph(info: info, size: 48),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                header: true,
                                child: Text(
                                  formatDayLong(day.date, today),
                                  style: GlassText.title,
                                ),
                              ),
                              Text(
                                info.label,
                                style: GlassText.body.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        MinMaxReadout(max: day.tempMax, min: day.tempMin),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: [
                        MetricChip(
                          icon: Icons.umbrella,
                          value:
                              'Chuva média ${day.avgPrecipitationProbability}%',
                          semanticLabel: '',
                          color: GlassColors.ink,
                        ),
                        MetricChip(
                          icon: Icons.water_drop,
                          value:
                              'Chuva total '
                              '${formatRainAmount(day.totalPrecipitation)}',
                          semanticLabel: '',
                          color: GlassColors.ink,
                        ),
                        MetricChip(
                          icon: Icons.opacity,
                          value: 'Umidade média ${day.avgHumidity}%',
                          semanticLabel: '',
                          color: GlassColors.ink,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('HORA A HORA', style: GlassText.label),
                    const SizedBox(height: 8),
                    GlassWell(
                      padding: EdgeInsets.zero,
                      child: HourlyStrip(points: day.hours),
                    ),
                    const SizedBox(height: 12),
                    // A well, not a panel: no nested BackdropFilter.
                    GlassWell(
                      child: HourlyChart(
                        points: day.hours,
                        height: 200,
                        semanticsTitle:
                            'Gráfico hora a hora de '
                            '${formatDayLong(day.date, today)}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GlassButton(
                        label: 'Fechar',
                        icon: Icons.close,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
