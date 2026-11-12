import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../core/theme/glass_theme.dart';
import '../../core/weather_codes.dart';
import '../../data/models/city.dart';
import '../../state/favorites_controller.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_surfaces.dart';
import '../widgets/weather_widgets.dart';

/// Home card with the current weather of one favorite municipality.
class FavoriteCard extends StatelessWidget {
  const FavoriteCard({
    super.key,
    required this.city,
    required this.state,
    required this.onTap,
    required this.onRemove,
    required this.onRetry,
  });

  final City city;
  final CityWeatherState state;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final weather = state.weather;
    final info = weather == null
        ? null
        : weatherInfo(weather.weatherCode, isDay: weather.isDay);

    final String status;
    if (info != null) {
      status = info.label;
    } else if (state.hasError) {
      status = 'Não foi possível carregar';
    } else {
      status = 'Carregando…';
    }

    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              WeatherGlyph(info: info),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GlassText.title,
                    ),
                    if (city.admin1.isNotEmpty)
                      Text(
                        city.admin1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GlassText.label,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      status,
                      style: GlassText.body.copyWith(
                        color: state.hasError
                            ? GlassColors.danger
                            : GlassColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GlassWell(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Text(
                  weather == null ? '––°' : formatTemp(weather.temperature),
                  style: GlassText.headline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: state.hasError
                      ? GlassButton(
                          label: 'Tentar novamente',
                          icon: Icons.refresh,
                          onTap: onRetry,
                        )
                      : MetricChip(
                          icon: Icons.opacity,
                          value: weather == null
                              ? 'Umidade –'
                              : 'Umidade ${weather.humidity}%',
                          semanticLabel: '',
                          color: GlassColors.ink,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              GlassIconButton(
                icon: Icons.delete_outline,
                tooltip: 'Remover ${city.name} dos favoritos',
                onTap: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
