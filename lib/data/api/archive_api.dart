import 'package:http/http.dart' as http;

import '../models/city.dart';
import 'api_exception.dart';

/// One day of observed weather from the historical archive.
class ArchiveDay {
  const ArchiveDay({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.weatherCode,
  });

  final DateTime date;
  final double tempMax;
  final double tempMin;
  final int weatherCode;
}

/// Client for the Open-Meteo historical archive.
///
/// Not used by the UI yet (see `.specs/00-overview.md`).
class ArchiveApi {
  ArchiveApi(this._client);

  final http.Client _client;

  Future<List<ArchiveDay>> fetchDaily(
    City city, {
    required DateTime start,
    required DateTime end,
  }) async {
    final uri = Uri.https('archive-api.open-meteo.com', '/v1/archive', {
      'latitude': '${city.latitude}',
      'longitude': '${city.longitude}',
      'start_date': _date(start),
      'end_date': _date(end),
      'timezone': 'auto',
      'daily': 'temperature_2m_max,temperature_2m_min,weather_code',
    });
    final json = await getJson(_client, uri);
    return parseOrThrow(() {
      final daily = json['daily'] as Map<String, dynamic>;
      final times = daily['time'] as List;
      final maxes = daily['temperature_2m_max'] as List;
      final mins = daily['temperature_2m_min'] as List;
      final codes = daily['weather_code'] as List;
      return [
        for (var i = 0; i < times.length; i++)
          if (maxes[i] != null && mins[i] != null && codes[i] != null)
            ArchiveDay(
              date: DateTime.parse(times[i] as String),
              tempMax: (maxes[i] as num).toDouble(),
              tempMin: (mins[i] as num).toDouble(),
              weatherCode: (codes[i] as num).toInt(),
            ),
      ];
    });
  }

  String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
