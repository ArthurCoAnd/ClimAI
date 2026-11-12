/// Weather models and the pure derivations described in
/// `.specs/04-dados-api.md`.
///
/// All times are the municipality's local wall-clock time (the API is called
/// with `timezone=auto`), parsed without any timezone conversion.
library;

class CurrentWeather {
  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.weatherCode,
    required this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final temperature = (current['temperature_2m'] as num).toDouble();
    return CurrentWeather(
      time: DateTime.parse(current['time'] as String),
      temperature: temperature,
      apparentTemperature:
          (current['apparent_temperature'] as num?)?.toDouble() ?? temperature,
      humidity: (current['relative_humidity_2m'] as num).round(),
      weatherCode: (current['weather_code'] as num).toInt(),
      isDay: (current['is_day'] as num?) != 0,
    );
  }

  final DateTime time;
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final int weatherCode;
  final bool isDay;
}

class HourlyPoint {
  const HourlyPoint({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.precipitationProbability,
    required this.weatherCode,
    required this.isDay,
  });

  final DateTime time;
  final double temperature;
  final int humidity;

  /// Null when the API has no probability for this hour.
  final int? precipitationProbability;
  final int weatherCode;
  final bool isDay;
}

class DailySummary {
  const DailySummary({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.avgPrecipitationProbability,
    required this.avgHumidity,
    required this.weatherCode,
    required this.hours,
  });

  final DateTime date;
  final double tempMax;
  final double tempMin;
  final int avgPrecipitationProbability;
  final int avgHumidity;

  /// Most frequent WMO code among the day's hours.
  final int weatherCode;
  final List<HourlyPoint> hours;
}

class WeatherForecast {
  const WeatherForecast({
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    final hourly = parseHourly(json['hourly'] as Map<String, dynamic>);
    return WeatherForecast(
      current: CurrentWeather.fromJson(json),
      hourly: hourly,
      daily: buildDailySummaries(json['daily'] as Map<String, dynamic>, hourly),
    );
  }

  final CurrentWeather current;
  final List<HourlyPoint> hourly;

  /// Up to 7 days, starting today.
  final List<DailySummary> daily;

  /// The 24 hourly points starting at the current hour.
  ///
  /// The first point ("Agora") shows the current conditions so it matches the
  /// current-weather card; only its rain probability comes from the forecast.
  List<HourlyPoint> get next24Hours {
    final hours = sliceNext24Hours(hourly, current.time);
    if (hours.isEmpty) return hours;
    final first = hours.first;
    return [
      HourlyPoint(
        time: first.time,
        temperature: current.temperature,
        humidity: current.humidity,
        precipitationProbability: first.precipitationProbability,
        weatherCode: current.weatherCode,
        isDay: current.isDay,
      ),
      ...hours.skip(1),
    ];
  }
}

List<HourlyPoint> parseHourly(Map<String, dynamic> hourly) {
  final times = hourly['time'] as List;
  final temps = hourly['temperature_2m'] as List;
  final humidity = hourly['relative_humidity_2m'] as List;
  final rain = hourly['precipitation_probability'] as List?;
  final codes = hourly['weather_code'] as List;
  final isDay = hourly['is_day'] as List?;

  final points = <HourlyPoint>[];
  for (var i = 0; i < times.length; i++) {
    // The API can return nulls at the far end of the forecast window.
    if (temps[i] == null || humidity[i] == null || codes[i] == null) continue;
    points.add(
      HourlyPoint(
        time: DateTime.parse(times[i] as String),
        temperature: (temps[i] as num).toDouble(),
        humidity: (humidity[i] as num).round(),
        precipitationProbability: (rain?[i] as num?)?.round(),
        weatherCode: (codes[i] as num).toInt(),
        isDay: (isDay?[i] as num?) != 0,
      ),
    );
  }
  return points;
}

List<HourlyPoint> sliceNext24Hours(List<HourlyPoint> hourly, DateTime now) {
  final start = DateTime(now.year, now.month, now.day, now.hour);
  return hourly.where((p) => !p.time.isBefore(start)).take(24).toList();
}

List<DailySummary> buildDailySummaries(
  Map<String, dynamic> daily,
  List<HourlyPoint> hourly, {
  int days = 7,
}) {
  final dates = daily['time'] as List;
  final maxes = daily['temperature_2m_max'] as List;
  final mins = daily['temperature_2m_min'] as List;

  final summaries = <DailySummary>[];
  for (var i = 0; i < dates.length && summaries.length < days; i++) {
    final date = DateTime.parse(dates[i] as String);
    final hours = hourly
        .where(
          (p) =>
              p.time.year == date.year &&
              p.time.month == date.month &&
              p.time.day == date.day,
        )
        .toList();
    if (hours.isEmpty || maxes[i] == null || mins[i] == null) continue;

    summaries.add(
      DailySummary(
        date: date,
        tempMax: (maxes[i] as num).toDouble(),
        tempMin: (mins[i] as num).toDouble(),
        avgPrecipitationProbability: _mean([
          for (final h in hours) ?h.precipitationProbability,
        ]),
        avgHumidity: _mean([for (final h in hours) h.humidity]),
        weatherCode: dominantWeatherCode([
          for (final h in hours) h.weatherCode,
        ]),
        hours: hours,
      ),
    );
  }
  return summaries;
}

/// Most frequent code; ties go to the highest (most severe) code.
int dominantWeatherCode(List<int> codes) {
  final counts = <int, int>{};
  for (final code in codes) {
    counts[code] = (counts[code] ?? 0) + 1;
  }
  var best = codes.first;
  var bestCount = 0;
  counts.forEach((code, count) {
    if (count > bestCount || (count == bestCount && code > best)) {
      best = code;
      bestCount = count;
    }
  });
  return best;
}

int _mean(List<int> values) {
  if (values.isEmpty) return 0;
  return (values.reduce((a, b) => a + b) / values.length).round();
}
