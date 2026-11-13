import 'package:clim_ai/core/formatters.dart';
import 'package:clim_ai/data/models/weather.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  group('WeatherForecast.fromJson', () {
    final forecast = WeatherForecast.fromJson(forecastJson());

    test('parses current conditions', () {
      expect(forecast.current.temperature, 27.6);
      expect(forecast.current.humidity, 64);
      expect(forecast.current.weatherCode, 2);
      expect(forecast.current.isDay, isTrue);
      expect(forecast.current.precipitation, 0.2);
    });

    test('next24Hours has 24 points starting at the current hour', () {
      final hours = forecast.next24Hours;
      expect(hours, hasLength(24));
      expect(hours.first.time, DateTime(2026, 11, 11, 14));
      expect(hours.last.time, DateTime(2026, 11, 12, 13));
      // The "now" slot mirrors the current conditions.
      expect(hours.first.temperature, 27.6);
      expect(hours.first.weatherCode, 2);
      expect(hours.first.precipitationProbability, 0);
    });

    test('daily has 7 days starting today, each with its 24 hours', () {
      expect(forecast.daily, hasLength(7));
      expect(forecast.daily.first.date, DateTime(2026, 11, 11));
      expect(forecast.daily.last.date, DateTime(2026, 11, 17));
      for (final day in forecast.daily) {
        expect(day.hours, hasLength(24));
      }
    });

    test('daily averages and max/min', () {
      final third = forecast.daily[2];
      expect(third.tempMax, closeTo(32.4, 1e-9));
      expect(third.tempMin, closeTo(20.6, 1e-9));
      expect(third.avgPrecipitationProbability, 20);
      expect(third.avgHumidity, 52);
      // 24 hours × 0.2 mm.
      expect(third.totalPrecipitation, 4.8);
      expect(forecast.daily.first.totalPrecipitation, 0);
    });

    test('daily status is the most frequent hourly code', () {
      // Day 0 has 18 hours of code 3 and 6 hours of code 61.
      expect(forecast.daily.first.weatherCode, 3);
    });
  });

  group('dominantWeatherCode', () {
    test('picks the mode', () {
      expect(dominantWeatherCode([0, 3, 3, 61]), 3);
    });

    test('breaks ties with the most severe code', () {
      expect(dominantWeatherCode([0, 0, 95, 95, 3]), 95);
    });
  });

  test('null hourly values are skipped and null rain is ignored', () {
    final hourly = parseHourly({
      'time': ['2026-11-11T00:00', '2026-11-11T01:00', '2026-11-11T02:00'],
      'temperature_2m': [20, null, 22],
      'relative_humidity_2m': [80, 81, 90],
      'precipitation_probability': [null, 50, 40],
      'weather_code': [0, 0, 0],
      'is_day': [0, 0, 0],
    });
    expect(hourly, hasLength(2));

    final daily = buildDailySummaries({
      'time': ['2026-11-11'],
      'temperature_2m_max': [22],
      'temperature_2m_min': [20],
    }, hourly);
    expect(daily.single.avgPrecipitationProbability, 40);
    expect(daily.single.avgHumidity, 85);
  });

  group('sumPrecipitation', () {
    HourlyPoint hour(double? mm) => HourlyPoint(
      time: DateTime(2026, 11, 11),
      temperature: 20,
      humidity: 80,
      precipitationProbability: null,
      weatherCode: 61,
      isDay: true,
      precipitation: mm,
    );

    test('adds the hours, ignoring missing values', () {
      expect(sumPrecipitation([hour(0.1), hour(null), hour(0.2)]), 0.3);
    });

    test('is null when no hour has a value', () {
      expect(sumPrecipitation([hour(null)]), isNull);
    });
  });

  group('formatters', () {
    final today = DateTime(2026, 11, 11, 14, 30);

    test('formatDay', () {
      expect(formatDay(DateTime(2026, 11, 11), today), 'Hoje');
      expect(formatDay(DateTime(2026, 11, 12), today), 'Amanhã');
      expect(formatDay(DateTime(2026, 11, 13), today), 'Sex, 13/11');
    });

    test('formatRainAmount', () {
      expect(formatRainAmount(2.4), '2,4 mm');
      expect(formatRainAmount(12), '12 mm');
      expect(formatRainAmount(0.04), '0 mm');
      expect(formatRainAmount(null), '– mm');
    });

    test('formatTemp rounds and never shows -0', () {
      expect(formatTemp(27.6), '28°');
      expect(formatTemp(-0.4), '0°');
    });
  });
}
