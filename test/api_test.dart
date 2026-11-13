import 'dart:convert';

import 'package:clim_ai/data/api/api_exception.dart';
import 'package:clim_ai/data/api/archive_api.dart';
import 'package:clim_ai/data/api/forecast_api.dart';
import 'package:clim_ai/data/api/geocoding_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fixtures.dart';

http.Response _json(Object body) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  group('GeocodingApi', () {
    test('searches Brazil in Portuguese and parses cities', () async {
      late Uri requested;
      final api = GeocodingApi(
        MockClient((request) async {
          requested = request.url;
          return _json({
            'results': [
              {
                'id': 3470127,
                'name': 'Belo Horizonte',
                'latitude': -19.92083,
                'longitude': -43.93778,
                'admin1': 'Minas Gerais',
              },
              // No admin1: must not break parsing.
              {'id': 1, 'name': 'São João', 'latitude': -1, 'longitude': -2},
            ],
          });
        }),
      );

      final cities = await api.search('Belo Hor');

      expect(requested.host, 'geocoding-api.open-meteo.com');
      expect(requested.queryParameters['name'], 'Belo Hor');
      expect(requested.queryParameters['countryCode'], 'BR');
      expect(requested.queryParameters['language'], 'pt');
      expect(cities, hasLength(2));
      expect(cities.first.name, 'Belo Horizonte');
      expect(cities.first.admin1, 'Minas Gerais');
      expect(cities.last.name, 'São João');
      expect(cities.last.admin1, '');
    });

    test('returns an empty list when there are no results', () async {
      final api = GeocodingApi(
        MockClient((_) async => _json({'generationtime_ms': 0.1})),
      );
      expect(await api.search('zzzz'), isEmpty);
    });
  });

  group('ForecastApi', () {
    test('fetchCurrent requests only current conditions', () async {
      late Uri requested;
      final api = ForecastApi(
        MockClient((request) async {
          requested = request.url;
          return _json(currentJson());
        }),
      );

      final current = await api.fetchCurrent(beloHorizonte);

      expect(requested.host, 'api.open-meteo.com');
      expect(requested.path, '/v1/forecast');
      expect(requested.queryParameters['timezone'], 'auto');
      expect(requested.queryParameters.containsKey('hourly'), isFalse);
      expect(current.temperature, 27.6);
      expect(current.apparentTemperature, 29.1);
    });

    test('fetchForecast requests hourly and daily for 8 days', () async {
      late Uri requested;
      final api = ForecastApi(
        MockClient((request) async {
          requested = request.url;
          return _json(forecastJson());
        }),
      );

      final forecast = await api.fetchForecast(beloHorizonte);

      expect(requested.queryParameters['forecast_days'], '8');
      expect(
        requested.queryParameters['hourly'],
        contains('precipitation_probability'),
      );
      expect(requested.queryParameters['hourly'], contains(',precipitation,'));
      expect(requested.queryParameters['current'], contains('precipitation'));
      expect(forecast.next24Hours, hasLength(24));
      expect(forecast.daily, hasLength(7));
    });

    test('non-200 responses throw WeatherApiException', () async {
      final api = ForecastApi(
        MockClient((_) async => http.Response('oops', 500)),
      );
      expect(
        api.fetchCurrent(beloHorizonte),
        throwsA(isA<WeatherApiException>()),
      );
    });

    test('malformed payloads throw WeatherApiException', () async {
      final api = ForecastApi(MockClient((_) async => _json({'current': {}})));
      expect(
        api.fetchCurrent(beloHorizonte),
        throwsA(isA<WeatherApiException>()),
      );
    });

    test('network failures throw WeatherApiException', () async {
      final api = ForecastApi(
        MockClient((_) async => throw http.ClientException('offline')),
      );
      expect(
        api.fetchCurrent(beloHorizonte),
        throwsA(isA<WeatherApiException>()),
      );
    });
  });

  test('ArchiveApi requests a date range and parses days', () async {
    late Uri requested;
    final api = ArchiveApi(
      MockClient((request) async {
        requested = request.url;
        return _json({
          'daily': {
            'time': ['2025-11-11', '2025-11-12'],
            'temperature_2m_max': [29.5, null],
            'temperature_2m_min': [18.2, 17.0],
            'weather_code': [3, 61],
          },
        });
      }),
    );

    final days = await api.fetchDaily(
      beloHorizonte,
      start: DateTime(2025, 11, 11),
      end: DateTime(2025, 11, 12),
    );

    expect(requested.host, 'archive-api.open-meteo.com');
    expect(requested.queryParameters['start_date'], '2025-11-11');
    expect(requested.queryParameters['end_date'], '2025-11-12');
    expect(days.single.tempMax, 29.5);
  });
}
