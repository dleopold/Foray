import 'package:flutter_test/flutter_test.dart';
import 'package:foray/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    group('date', () {
      test('formats date as YYYY-MM-DD', () {
        final date = DateTime(2026, 1, 22);
        expect(Formatters.date(date), equals('2026-01-22'));
      });

      test('pads single-digit months', () {
        final date = DateTime(2026, 3, 15);
        expect(Formatters.date(date), equals('2026-03-15'));
      });

      test('pads single-digit days', () {
        final date = DateTime(2026, 12, 5);
        expect(Formatters.date(date), equals('2026-12-05'));
      });
    });

    group('dateTime', () {
      test('formats date and time', () {
        final dateTime = DateTime(2026, 1, 22, 14, 30);
        expect(Formatters.dateTime(dateTime), equals('2026-01-22 14:30'));
      });

      test('pads single-digit hours', () {
        final dateTime = DateTime(2026, 1, 22, 9, 5);
        expect(Formatters.dateTime(dateTime), equals('2026-01-22 09:05'));
      });
    });

    group('distance', () {
      group('metric', () {
        test('formats meters under 1km', () {
          expect(Formatters.distance(500), equals('500 m'));
          expect(Formatters.distance(999), equals('999 m'));
        });

        test('formats kilometers over 1km', () {
          expect(Formatters.distance(1000), equals('1.0 km'));
          expect(Formatters.distance(5500), equals('5.5 km'));
        });

        test('rounds meters', () {
          expect(Formatters.distance(500.7), equals('501 m'));
        });
      });

      group('imperial', () {
        test('formats feet under 1 mile', () {
          final result = Formatters.distance(100, useMetric: false);
          expect(result, equals('328 ft'));
        });

        test('formats miles over 1 mile', () {
          final result = Formatters.distance(2000, useMetric: false);
          expect(result, equals('1.2 mi'));
        });
      });
    });

    group('bearing', () {
      test('formats with cardinal and degrees', () {
        expect(Formatters.bearing(0), equals('N (0°)'));
        expect(Formatters.bearing(90), equals('E (90°)'));
        expect(Formatters.bearing(180), equals('S (180°)'));
        expect(Formatters.bearing(270), equals('W (270°)'));
      });

      test('returns intermediate directions', () {
        expect(Formatters.bearing(45), equals('NE (45°)'));
        expect(Formatters.bearing(135), equals('SE (135°)'));
        expect(Formatters.bearing(225), equals('SW (225°)'));
        expect(Formatters.bearing(315), equals('NW (315°)'));
      });
    });

    group('coordinates', () {
      test('formats positive coordinates', () {
        final result = Formatters.coordinates(40.71280, -74.00600);
        expect(result, equals('40.71280° N, 74.00600° W'));
      });

      test('formats negative latitude as S', () {
        final result = Formatters.coordinates(-33.86880, 151.20930);
        expect(result, equals('33.86880° S, 151.20930° E'));
      });

      test('respects decimals parameter', () {
        final result = Formatters.coordinates(40.7128, -74.006, decimals: 2);
        expect(result, equals('40.71° N, 74.01° W'));
      });
    });
  });
}
