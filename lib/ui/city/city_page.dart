import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/formatters.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/weather_codes.dart';
import '../../data/models/city.dart';
import '../../data/models/weather.dart';
import '../widgets/page_header.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_surfaces.dart';
import '../widgets/weather_widgets.dart';
import 'day_detail_sheet.dart';

/// Weather of one municipality: current, next 24 hours and next 7 days.
class CityPage extends StatefulWidget {
  const CityPage({super.key, required this.services, required this.city});

  final AppServices services;
  final City city;

  @override
  State<CityPage> createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  WeatherForecast? _forecast;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_error) setState(() => _error = false);
    WeatherForecast? forecast;
    try {
      forecast = await widget.services.forecastApi.fetchForecast(widget.city);
    } catch (_) {
      forecast = null;
    }
    if (!mounted) return;
    setState(() {
      // A failed refresh keeps the forecast already on screen.
      _forecast = forecast ?? _forecast;
      _error = forecast == null && _forecast == null;
    });
    if (forecast == null && _forecast != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar a previsão')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final city = widget.city;
    final favorites = widget.services.favorites;
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: ContentWidth(
            child: Column(
              children: [
                PageHeader(
                  title: city.name,
                  subtitle: city.admin1,
                  leading: GlassIconButton(
                    icon: Icons.arrow_back,
                    tooltip: 'Voltar',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    ListenableBuilder(
                      listenable: favorites,
                      builder: (context, _) {
                        final isFavorite = favorites.isFavorite(city);
                        return GlassIconButton(
                          icon: isFavorite ? Icons.star : Icons.star_border,
                          iconColor: isFavorite
                              ? GlassColors.accent
                              : GlassColors.ink,
                          tooltip: isFavorite
                              ? 'Remover dos favoritos'
                              : 'Adicionar aos favoritos',
                          onTap: () => favorites.toggle(city),
                        );
                      },
                    ),
                  ],
                ),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final forecast = _forecast;
    if (_error) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(GlassMetrics.screenMargin),
        child: GlassNotice(
          icon: Icons.cloud_off,
          iconColor: GlassColors.danger,
          message: 'Não foi possível carregar a previsão.',
          actionLabel: 'Tentar novamente',
          actionIcon: Icons.refresh,
          onAction: _load,
        ),
      );
    }
    if (forecast == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final today = forecast.current.time;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          GlassMetrics.screenMargin,
          4,
          GlassMetrics.screenMargin,
          32,
        ),
        children: [
          _CurrentCard(current: forecast.current),
          const SectionTitle('Próximas 24 horas'),
          GlassPanel(
            borderRadius: BorderRadius.circular(GlassMetrics.cardRadius),
            child: HourlyStrip(points: forecast.next24Hours, firstIsNow: true),
          ),
          const SectionTitle('Próximos 7 dias'),
          for (final day in forecast.daily)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DayCard(
                day: day,
                today: today,
                onTap: () =>
                    showDayDetailSheet(context, day: day, today: today),
              ),
            ),
        ],
      ),
    );
  }
}

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({required this.current});

  final CurrentWeather current;

  @override
  Widget build(BuildContext context) {
    final info = weatherInfo(current.weatherCode, isDay: current.isDay);
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AGORA', style: GlassText.label),
          const SizedBox(height: 12),
          Row(
            children: [
              WeatherGlyph(info: info, size: 88),
              const SizedBox(width: 16),
              Expanded(
                child: GlassWell(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Semantics(
                      label: 'Temperatura ${current.temperature.round()} graus',
                      excludeSemantics: true,
                      child: Text(
                        formatTemp(current.temperature),
                        style: GlassText.display,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(info.label, style: GlassText.title),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              MetricChip(
                icon: Icons.opacity,
                value: 'Umidade ${current.humidity}%',
                semanticLabel: '',
                color: GlassColors.ink,
              ),
              MetricChip(
                icon: Icons.thermostat,
                value: 'Sensação ${formatTemp(current.apparentTemperature)}',
                semanticLabel: '',
                color: GlassColors.ink,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day, required this.today, required this.onTap});

  final DailySummary day;
  final DateTime today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final info = weatherInfo(day.weatherCode);
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      child: Row(
        children: [
          WeatherGlyph(info: info, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatDay(day.date, today), style: GlassText.title),
                Text(info.label, style: GlassText.body.copyWith(fontSize: 14)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    MetricChip.rain(day.avgPrecipitationProbability),
                    MetricChip.humidity(day.avgHumidity),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          MinMaxReadout(max: day.tempMax, min: day.tempMin),
          const Icon(
            Icons.chevron_right,
            color: GlassColors.inkMuted,
            shadows: GlassShadows.text,
          ),
        ],
      ),
    );
  }
}

/// Max / min temperatures in a recessed display.
class MinMaxReadout extends StatelessWidget {
  const MinMaxReadout({super.key, required this.max, required this.min});

  final double max;
  final double min;

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, double value, Color color) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        Text(
          formatTemp(value),
          style: GlassText.title.copyWith(color: color, shadows: const []),
        ),
      ],
    );

    return Semantics(
      label: 'Máxima ${max.round()} graus, mínima ${min.round()} graus',
      excludeSemantics: true,
      child: GlassWell(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            row(Icons.keyboard_arrow_up, max, GlassColors.accent),
            row(Icons.keyboard_arrow_down, min, GlassColors.rain),
          ],
        ),
      ),
    );
  }
}
