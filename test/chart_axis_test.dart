import 'package:clim_ai/core/formatters.dart';
import 'package:clim_ai/data/models/chart_axis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('temperatureAxis', () {
    test('uses 1 °C steps for a small range', () {
      final axis = temperatureAxis([20.4, 23.8]);
      expect(axis.min, 20);
      expect(axis.max, 24);
      expect(axis.ticks, [20, 21, 22, 23, 24]);
    });

    test('grows the step until every value fits', () {
      final axis = temperatureAxis([14.2, 29.6]);
      expect(axis.step, 5);
      expect(axis.min, 10);
      expect(axis.max, 30);
    });

    test('handles negative temperatures', () {
      final axis = temperatureAxis([-3.5, 2]);
      expect(axis.min, -4);
      expect(axis.max, 4);
    });
  });

  group('rainAmountAxis', () {
    test('defaults to 0–2 mm when it does not rain', () {
      final axis = rainAmountAxis([0, null, 0]);
      expect(axis.min, 0);
      expect(axis.max, 2);
      expect(
        [for (final t in axis.ticks) formatDecimal(t)],
        ['0', '0,5', '1', '1,5', '2'],
      );
    });

    test('picks the first round maximum that fits', () {
      expect(rainAmountAxis([1.2, 5.3]).max, 8);
      expect(rainAmountAxis([12]).max, 20);
      expect(rainAmountAxis([350]).max, 400);
    });
  });

  test('rain chance axis is 0–100 % with shared gridlines', () {
    expect(rainChanceAxis.ticks, [0, 25, 50, 75, 100]);
    expect(rainChanceAxis.fraction(50), 0.5);
    expect(rainChanceAxis.fraction(150), 1);
  });
}
