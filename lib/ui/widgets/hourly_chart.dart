import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../core/theme/glass_theme.dart';
import '../../data/models/chart_axis.dart';
import '../../data/models/weather.dart';

/// Hourly chart: temperature as an amber area (left axis), precipitation in
/// mm as blue bars and rain probability as a dashed gray line (right axes).
///
/// Hovering, tapping or dragging over the plot shows the readings of an hour.
/// Meant to sit inside a [GlassPanel].
class HourlyChart extends StatefulWidget {
  const HourlyChart({
    super.key,
    required this.points,
    this.firstIsNow = false,
    this.height = 220,
    this.semanticsTitle,
  });

  /// Start of the screen reader summary; defaults to
  /// "Gráfico das próximas N horas".
  final String? semanticsTitle;

  final List<HourlyPoint> points;

  /// Labels the first point "Agora" instead of its hour.
  final bool firstIsNow;
  final double height;

  @override
  State<HourlyChart> createState() => _HourlyChartState();
}

class _HourlyChartState extends State<HourlyChart> {
  int? _selected;

  void _select(Offset position, Size size) {
    final index = _ChartGeometry(size, widget.points.length).indexAt(position);
    if (index != _selected) setState(() => _selected = index);
  }

  void _clear() {
    if (_selected != null) setState(() => _selected = null);
  }

  String _summary() {
    final points = widget.points;
    if (points.isEmpty) return 'Gráfico sem dados';
    final temps = points.map((p) => p.temperature);
    final low = temps.reduce(math.min).round();
    final high = temps.reduce(math.max).round();
    final chance = points
        .map((p) => p.precipitationProbability ?? 0)
        .reduce(math.max);
    final title =
        widget.semanticsTitle ?? 'Gráfico das próximas ${points.length} horas';
    return '$title: temperatura de '
        '$low a $high graus, chance de chuva máxima de $chance%, '
        'precipitação total de ${formatRainAmount(sumPrecipitation(points))}';
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _LegendItem(
              swatch: _Swatch.area,
              color: GlassColors.chartTemperature,
              label: 'Temperatura (°C)',
            ),
            _LegendItem(
              swatch: _Swatch.dashed,
              color: GlassColors.chartRainChance,
              label: 'Chance de chuva (%)',
            ),
            _LegendItem(
              swatch: _Swatch.bar,
              color: GlassColors.chartRainAmount,
              label: 'Chuva (mm)',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(
          label: _summary(),
          excludeSemantics: true,
          child: SizedBox(
            height: widget.height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;
                return MouseRegion(
                  onHover: (e) => _select(e.localPosition, size),
                  onExit: (_) => _clear(),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => _select(d.localPosition, size),
                    onHorizontalDragStart: (d) =>
                        _select(d.localPosition, size),
                    onHorizontalDragUpdate: (d) =>
                        _select(d.localPosition, size),
                    child: CustomPaint(
                      size: size,
                      painter: _HourlyChartPainter(
                        points: points,
                        firstIsNow: widget.firstIsNow,
                        selected: _selected,
                        textScaler: MediaQuery.textScalerOf(context),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

enum _Swatch { area, bar, dashed }

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.swatch,
    required this.color,
    required this.label,
  });

  final _Swatch swatch;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Widget mark = switch (swatch) {
      .area => Container(
        width: 16,
        height: 12,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.35),
          border: Border(top: BorderSide(color: color, width: 2)),
        ),
      ),
      .bar => Container(
        width: 8,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
      ),
      .dashed => SizedBox(
        width: 16,
        height: 12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < 2; i++)
              Container(width: 6, height: 2, color: color),
          ],
        ),
      ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 6),
        Text(label, style: GlassText.label),
      ],
    );
  }
}

/// Plot area inside the chart and the x position of each hour.
class _ChartGeometry {
  _ChartGeometry(this.size, this.count)
    : plot = Rect.fromLTRB(
        _leftAxis,
        _top,
        math.max(_leftAxis + 1, size.width - _rightAxes),
        math.max(_top + 1, size.height - _bottom),
      );

  static const double _leftAxis = 36;
  static const double _chanceAxis = 38;
  static const double _amountAxis = 34;
  static const double _rightAxes = _chanceAxis + _amountAxis;
  static const double _top = 22;
  static const double _bottom = 24;

  final Size size;
  final int count;
  final Rect plot;

  double get slot => count == 0 ? plot.width : plot.width / count;

  double xOf(int index) => plot.left + slot * (index + 0.5);

  double chanceAxisX() => plot.right + 6;
  double amountAxisX() => plot.right + _chanceAxis + 4;

  int? indexAt(Offset position) {
    if (count == 0) return null;
    final i = ((position.dx - plot.left) / slot).floor();
    return i.clamp(0, count - 1);
  }
}

class _HourlyChartPainter extends CustomPainter {
  _HourlyChartPainter({
    required this.points,
    required this.firstIsNow,
    required this.selected,
    required this.textScaler,
  });

  final List<HourlyPoint> points;
  final bool firstIsNow;
  final int? selected;
  final TextScaler textScaler;

  static const _axisStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: GlassColors.inkMuted,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final g = _ChartGeometry(size, points.length);
    final plot = g.plot;

    final tempAxis = temperatureAxis(points.map((p) => p.temperature));
    final amountAxis = rainAmountAxis(points.map((p) => p.precipitation));
    const chanceAxis = rainChanceAxis;

    double y(ChartAxis axis, double v) =>
        plot.bottom - axis.fraction(v) * plot.height;

    _paintGridAndAxes(canvas, g, tempAxis, chanceAxis, amountAxis);

    // Temperature area (under everything else).
    final tempPoints = [
      for (final (i, p) in points.indexed)
        Offset(g.xOf(i), y(tempAxis, p.temperature)),
    ];
    final line = Path()..addPolygon(tempPoints, false);
    final area = Path.from(line)
      ..lineTo(tempPoints.last.dx, plot.bottom)
      ..lineTo(tempPoints.first.dx, plot.bottom)
      ..close();
    final temp = GlassColors.chartTemperature;
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [temp.withValues(alpha: 0.38), temp.withValues(alpha: 0.04)],
        ).createShader(plot),
    );

    // Precipitation bars, anchored to the baseline with rounded tops.
    final barWidth = math.min(12.0, math.max(2.0, g.slot - 3));
    final barPaint = Paint()..color = GlassColors.chartRainAmount;
    for (final (i, p) in points.indexed) {
      final mm = p.precipitation;
      if (mm == null || mm <= 0) continue;
      final top = math.min(y(amountAxis, mm), plot.bottom - 2);
      final radius = Radius.circular(math.min(4, barWidth / 2));
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTRB(
            g.xOf(i) - barWidth / 2,
            top,
            g.xOf(i) + barWidth / 2,
            plot.bottom,
          ),
          topLeft: radius,
          topRight: radius,
        ),
        barPaint,
      );
    }

    // Temperature line on top of the bars.
    canvas.drawPath(
      line,
      Paint()
        ..color = temp
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Rain probability: dashed line, broken where the value is missing.
    final chance = Path();
    var drawing = false;
    for (final (i, p) in points.indexed) {
      final v = p.precipitationProbability;
      if (v == null) {
        drawing = false;
        continue;
      }
      final point = Offset(g.xOf(i), y(chanceAxis, v.toDouble()));
      drawing
          ? chance.lineTo(point.dx, point.dy)
          : chance.moveTo(point.dx, point.dy);
      drawing = true;
    }
    _drawDashed(
      canvas,
      chance,
      Paint()
        ..color = GlassColors.chartRainChance
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    final index = selected;
    if (index != null && index < points.length) {
      _paintSelection(
        canvas,
        size,
        g,
        index,
        tempPoints[index],
        (v) => y(chanceAxis, v),
      );
    }
  }

  void _paintGridAndAxes(
    Canvas canvas,
    _ChartGeometry g,
    ChartAxis temp,
    ChartAxis chance,
    ChartAxis amount,
  ) {
    final plot = g.plot;
    final grid = Paint()
      ..color = GlassColors.chartGrid
      ..strokeWidth = 1;

    // Unit headers above each axis.
    _text(canvas, '°C', Offset(plot.left - 6, 0), const Alignment(1, -1));
    _text(canvas, '%', Offset(g.chanceAxisX(), 0), const Alignment(-1, -1));
    _text(canvas, 'mm', Offset(g.amountAxisX(), 0), const Alignment(-1, -1));

    for (var i = 0; i <= ChartAxis.intervals; i++) {
      final dy = plot.bottom - plot.height * i / ChartAxis.intervals;
      canvas.drawLine(Offset(plot.left, dy), Offset(plot.right, dy), grid);
      _text(
        canvas,
        '${temp.ticks[i].round()}°',
        Offset(plot.left - 6, dy),
        Alignment.centerRight,
      );
      _text(
        canvas,
        '${chance.ticks[i].round()}',
        Offset(g.chanceAxisX(), dy),
        Alignment.centerLeft,
      );
      _text(
        canvas,
        formatDecimal(amount.ticks[i]),
        Offset(g.amountAxisX(), dy),
        Alignment.centerLeft,
      );
    }

    // Hour labels: every 3 hours, or 6 when the plot is narrow.
    final every = plot.width < 320 ? 6 : 3;
    for (var i = 0; i < points.length; i += every) {
      final label = firstIsNow && i == 0 ? 'Agora' : formatHour(points[i].time);
      canvas.drawLine(
        Offset(g.xOf(i), plot.bottom),
        Offset(g.xOf(i), plot.bottom + 4),
        grid,
      );
      _text(
        canvas,
        label,
        Offset(g.xOf(i), plot.bottom + 6),
        Alignment.topCenter,
        minX: 0,
      );
    }
  }

  void _paintSelection(
    Canvas canvas,
    Size size,
    _ChartGeometry g,
    int index,
    Offset tempPoint,
    double Function(double) chanceY,
  ) {
    final plot = g.plot;
    final point = points[index];
    final x = g.xOf(index);
    canvas.drawLine(
      Offset(x, plot.top),
      Offset(x, plot.bottom),
      Paint()
        ..color = GlassColors.ink.withValues(alpha: 0.5)
        ..strokeWidth = 1,
    );

    void dot(Offset c, Color color) {
      canvas.drawCircle(c, 6, Paint()..color = GlassColors.glassOpaque);
      canvas.drawCircle(c, 4, Paint()..color = color);
    }

    dot(tempPoint, GlassColors.chartTemperature);
    final chance = point.precipitationProbability;
    if (chance != null) {
      dot(Offset(x, chanceY(chance.toDouble())), GlassColors.chartRainChance);
    }

    // Tooltip next to the crosshair, flipped to the left near the right edge.
    final time = firstIsNow && index == 0 ? 'Agora' : formatHour(point.time);
    final rows = [
      (
        GlassColors.chartTemperature,
        'Temperatura ${formatTemp(point.temperature)}',
      ),
      (GlassColors.chartRainChance, 'Chance de chuva ${formatPercent(chance)}'),
      (
        GlassColors.chartRainAmount,
        'Chuva ${formatRainAmount(point.precipitation)}',
      ),
    ];
    final title = _layout(
      time,
      GlassText.label.copyWith(color: GlassColors.ink, shadows: const []),
    );
    final lines = [
      for (final (_, text) in rows)
        _layout(
          text,
          GlassText.label.copyWith(color: GlassColors.ink, shadows: const []),
        ),
    ];
    const pad = 10.0, swatch = 8.0, gap = 6.0, rowGap = 4.0;
    final width =
        pad * 2 +
        math.max(
          title.width,
          lines.map((l) => l.width + swatch + gap).reduce(math.max),
        );
    final height =
        pad * 2 +
        title.height +
        lines.fold<double>(0, (h, l) => h + l.height + rowGap);
    var left = x + 12;
    if (left + width > size.width) left = x - 12 - width;
    left = left.clamp(0, math.max(0, size.width - width)).toDouble();
    final box = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, plot.top, width, height),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      box,
      Paint()..color = GlassColors.glassOpaque.withValues(alpha: 0.95),
    );
    canvas.drawRRect(
      box,
      Paint()
        ..color = GlassColors.glassBorder
        ..style = PaintingStyle.stroke,
    );
    var dy = plot.top + pad;
    title.paint(canvas, Offset(left + pad, dy));
    dy += title.height + rowGap;
    for (final (i, line) in lines.indexed) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            left + pad,
            dy + (line.height - swatch) / 2,
            swatch,
            swatch,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = rows[i].$1,
      );
      line.paint(canvas, Offset(left + pad + swatch + gap, dy));
      dy += line.height + rowGap;
    }
  }

  TextPainter _layout(String text, TextStyle style) => TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
  )..layout();

  /// Paints [text] so that [anchor] of its box lands on [at].
  void _text(
    Canvas canvas,
    String text,
    Offset at,
    Alignment anchor, {
    double? minX,
  }) {
    final tp = _layout(text, _axisStyle);
    var dx = at.dx - tp.width * (anchor.x + 1) / 2;
    if (minX != null) dx = math.max(minX, dx);
    final dy = at.dy - tp.height * (anchor.y + 1) / 2;
    tp.paint(canvas, Offset(dx, dy));
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dash = 6.0, gap = 4.0;
    for (final PathMetric metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_HourlyChartPainter old) =>
      old.points != points ||
      old.selected != selected ||
      old.firstIsNow != firstIsNow ||
      old.textScaler != textScaler;
}
