import 'package:clim_ai/data/models/city.dart';

const beloHorizonte = City(
  id: 3470127,
  name: 'Belo Horizonte',
  admin1: 'Minas Gerais',
  latitude: -19.92083,
  longitude: -43.93778,
);

String _two(int n) => n.toString().padLeft(2, '0');

/// A forecast payload shaped like the Open-Meteo response: 8 days of hourly
/// data starting 2026-11-11T00:00, with "now" at 14:30 on the first day.
///
/// Per hour: temperature = hour of day, humidity = 50 + day index,
/// rain probability = 10 × day index, precipitation = 0.1 mm × day index,
/// weather code 3 (61 from 18h on day 0).
Map<String, dynamic> forecastJson() {
  final start = DateTime(2026, 11, 11);
  final times = <String>[];
  final temps = <num>[];
  final humidity = <num>[];
  final rain = <num>[];
  final amount = <num>[];
  final codes = <num>[];
  final isDay = <num>[];
  for (var day = 0; day < 8; day++) {
    for (var hour = 0; hour < 24; hour++) {
      final t = start.add(Duration(days: day, hours: hour));
      times.add('${t.year}-${_two(t.month)}-${_two(t.day)}T${_two(hour)}:00');
      temps.add(hour.toDouble());
      humidity.add(50 + day);
      rain.add(10 * day);
      amount.add(0.1 * day);
      codes.add(day == 0 && hour >= 18 ? 61 : 3);
      isDay.add(hour >= 6 && hour < 18 ? 1 : 0);
    }
  }
  return {
    'current': currentJson()['current'],
    'hourly': {
      'time': times,
      'temperature_2m': temps,
      'relative_humidity_2m': humidity,
      'precipitation_probability': rain,
      'precipitation': amount,
      'weather_code': codes,
      'is_day': isDay,
    },
    'daily': {
      'time': [
        for (var day = 0; day < 8; day++)
          () {
            final t = start.add(Duration(days: day));
            return '${t.year}-${_two(t.month)}-${_two(t.day)}';
          }(),
      ],
      'temperature_2m_max': [for (var day = 0; day < 8; day++) 30.4 + day],
      'temperature_2m_min': [for (var day = 0; day < 8; day++) 18.6 + day],
    },
  };
}

Map<String, dynamic> currentJson() => {
  'current': {
    'time': '2026-11-11T14:30',
    'temperature_2m': 27.6,
    'relative_humidity_2m': 64,
    'apparent_temperature': 29.1,
    'precipitation': 0.2,
    'weather_code': 2,
    'is_day': 1,
  },
};
