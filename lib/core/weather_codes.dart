import 'package:material_ui/material_ui.dart';

/// Colour family used to tint a weather icon.
enum WeatherTone { sun, cloud, rain, snow, storm }

class WeatherInfo {
  const WeatherInfo(this.label, this.icon, this.tone);

  final String label;
  final IconData icon;
  final WeatherTone tone;
}

/// Maps a WMO weather code to a PT-BR description and an icon.
WeatherInfo weatherInfo(int code, {bool isDay = true}) {
  return switch (code) {
    0 => WeatherInfo(
      'Céu limpo',
      isDay ? Icons.wb_sunny : Icons.nightlight_round,
      .sun,
    ),
    1 => WeatherInfo(
      'Predominantemente limpo',
      isDay ? Icons.wb_sunny : Icons.nightlight_round,
      .sun,
    ),
    2 => WeatherInfo(
      'Parcialmente nublado',
      isDay ? Icons.cloud_queue : Icons.nights_stay,
      .cloud,
    ),
    3 => const WeatherInfo('Nublado', Icons.cloud, .cloud),
    45 || 48 => const WeatherInfo('Nevoeiro', Icons.foggy, .cloud),
    51 || 53 || 55 => const WeatherInfo('Garoa', Icons.grain, .rain),
    56 || 57 => const WeatherInfo('Garoa congelante', Icons.severe_cold, .snow),
    61 => const WeatherInfo('Chuva fraca', Icons.water_drop, .rain),
    63 => const WeatherInfo('Chuva moderada', Icons.water_drop, .rain),
    65 => const WeatherInfo('Chuva forte', Icons.water_drop, .rain),
    66 || 67 => const WeatherInfo('Chuva congelante', Icons.severe_cold, .snow),
    71 || 73 || 75 || 77 => const WeatherInfo('Neve', Icons.ac_unit, .snow),
    80 ||
    81 ||
    82 => const WeatherInfo('Pancadas de chuva', Icons.umbrella, .rain),
    85 || 86 => const WeatherInfo('Pancadas de neve', Icons.ac_unit, .snow),
    95 => const WeatherInfo('Trovoada', Icons.thunderstorm, .storm),
    96 ||
    99 => const WeatherInfo('Trovoada com granizo', Icons.thunderstorm, .storm),
    _ => const WeatherInfo('Indefinido', Icons.cloud_queue, .cloud),
  };
}
