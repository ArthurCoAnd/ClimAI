/// Value axes for the hourly chart. Every axis has [ChartAxis.intervals]
/// intervals so the three scales share the same gridlines.
library;

class ChartAxis {
  const ChartAxis(this.min, this.max);

  /// Gridline intervals shared by every axis of the chart.
  static const int intervals = 4;

  final double min;
  final double max;

  double get step => (max - min) / intervals;

  /// The [intervals] + 1 tick values, from [min] to [max].
  List<double> get ticks => [
    for (var i = 0; i <= intervals; i++) min + step * i,
  ];

  /// Position of [value] on the axis, 0 at [min] and 1 at [max] (clamped).
  double fraction(double value) {
    if (max == min) return 0;
    return ((value - min) / (max - min)).clamp(0, 1).toDouble();
  }
}

/// Temperature axis with an integer step from 1, 2, 5, 10 or 20 °C that fits
/// every value of [temperatures].
ChartAxis temperatureAxis(Iterable<double> temperatures) {
  if (temperatures.isEmpty) return const ChartAxis(0, 4);
  final low = temperatures.reduce((a, b) => a < b ? a : b);
  final high = temperatures.reduce((a, b) => a > b ? a : b);
  for (final step in const [1, 2, 5, 10, 20]) {
    final start = (low / step).floor() * step;
    final end = start + step * ChartAxis.intervals;
    if (end >= high) return ChartAxis(start.toDouble(), end.toDouble());
  }
  final start = (low / 50).floor() * 50;
  return ChartAxis(start.toDouble(), start + 50.0 * ChartAxis.intervals);
}

/// Rain probability axis: always 0–100 %.
const ChartAxis rainChanceAxis = ChartAxis(0, 100);

/// Precipitation axis from 0 to the first round maximum that fits [amounts]
/// (mm). Quarters of each maximum need at most one decimal.
ChartAxis rainAmountAxis(Iterable<double?> amounts) {
  final high = amounts.fold<double>(0, (m, v) => v != null && v > m ? v : m);
  for (final max in const [2, 4, 8, 10, 20, 40, 80, 100, 200]) {
    if (high <= max) return ChartAxis(0, max.toDouble());
  }
  return ChartAxis(0, (high / 100).ceil() * 100.0);
}
