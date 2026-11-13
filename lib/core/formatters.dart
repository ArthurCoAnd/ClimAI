/// PT-BR display formatting. Kept manual to avoid an `intl` dependency.
library;

const _weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
const _weekdaysLong = [
  'Segunda-feira',
  'Terça-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sábado',
  'Domingo',
];

/// "23°" — rounded, never "-0°".
String formatTemp(double celsius) => '${celsius.round()}°';

String formatPercent(int? value) => value == null ? '–' : '$value%';

/// "2,4", "12", "0": one decimal with a PT-BR comma, ",0" dropped.
String formatDecimal(double value) {
  final tenths = (value * 10).round();
  final whole = tenths ~/ 10;
  final decimal = tenths % 10;
  return decimal == 0 ? '$whole' : '$whole,$decimal';
}

/// "2,4 mm", "12 mm", "0 mm".
String formatRainAmount(double? mm) =>
    mm == null ? '– mm' : '${formatDecimal(mm)} mm';

/// "14h"
String formatHour(DateTime time) => '${time.hour.toString().padLeft(2, '0')}h';

String _dayMonth(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

int _daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// "Hoje", "Amanhã" or "Qua, 18/11". [today] is the municipality's local date.
String formatDay(DateTime date, DateTime today) {
  return switch (_daysBetween(today, date)) {
    0 => 'Hoje',
    1 => 'Amanhã',
    _ => '${_weekdays[date.weekday - 1]}, ${_dayMonth(date)}',
  };
}

/// "Quarta-feira, 18/11", prefixed with "Hoje"/"Amanhã" when it applies.
String formatDayLong(DateTime date, DateTime today) {
  final full = '${_weekdaysLong[date.weekday - 1]}, ${_dayMonth(date)}';
  return switch (_daysBetween(today, date)) {
    0 => 'Hoje · $full',
    1 => 'Amanhã · $full',
    _ => full,
  };
}
