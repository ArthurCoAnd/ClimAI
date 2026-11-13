import 'package:http/http.dart' as http;

import '../models/city.dart';
import '../models/weather.dart';
import 'api_exception.dart';

class ForecastApi {
  ForecastApi(this._client);

  final http.Client _client;

  static const _current =
      'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,is_day';
  static const _hourly =
      'temperature_2m,relative_humidity_2m,precipitation_probability,precipitation,weather_code,is_day';

  /// Current conditions only (home cards).
  Future<CurrentWeather> fetchCurrent(City city) async {
    final json = await getJson(_client, _uri(city, {'current': _current}));
    return parseOrThrow(() => CurrentWeather.fromJson(json));
  }

  /// Current conditions + hourly + daily for the city page.
  Future<WeatherForecast> fetchForecast(City city) async {
    final json = await getJson(
      _client,
      _uri(city, {
        'current': _current,
        'hourly': _hourly,
        'daily': 'temperature_2m_max,temperature_2m_min',
        // 8 days so the 7th day and the next 24h are always complete.
        'forecast_days': '8',
      }),
    );
    return parseOrThrow(() => WeatherForecast.fromJson(json));
  }

  Uri _uri(City city, Map<String, String> params) =>
      Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '${city.latitude}',
        'longitude': '${city.longitude}',
        'timezone': 'auto',
        ...params,
      });
}
