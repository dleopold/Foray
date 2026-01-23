import 'package:flutter_test/flutter_test.dart';
import 'package:foray/core/utils/gps_utils.dart';

void main() {
  group('GpsUtils', () {
    group('calculateDistance', () {
      test('returns 0 for identical points', () {
        final distance = GpsUtils.calculateDistance(
          40.7128,
          -74.0060,
          40.7128,
          -74.0060,
        );
        expect(distance, equals(0));
      });

      test('calculates correct distance between NYC and LA', () {
        // NYC: 40.7128° N, 74.0060° W
        // LA: 34.0522° N, 118.2437° W
        // Expected: ~3,944 km
        final distance = GpsUtils.calculateDistance(
          40.7128,
          -74.0060,
          34.0522,
          -118.2437,
        );
        // Allow 1% tolerance for Haversine approximation
        expect(distance, closeTo(3944000, 40000));
      });

      test('calculates correct distance for short distances', () {
        // Two points ~1km apart
        // 0.01 degrees latitude ≈ 1.11 km
        final distance = GpsUtils.calculateDistance(
          40.0000,
          -74.0000,
          40.0090,
          -74.0000,
        );
        expect(distance, closeTo(1000, 50));
      });

      test('handles crossing the equator', () {
        final distance = GpsUtils.calculateDistance(
          1.0,
          0.0,
          -1.0,
          0.0,
        );
        // ~222 km for 2 degrees of latitude
        expect(distance, closeTo(222000, 5000));
      });

      test('handles crossing the prime meridian', () {
        final distance = GpsUtils.calculateDistance(
          0.0,
          1.0,
          0.0,
          -1.0,
        );
        // ~222 km for 2 degrees of longitude at equator
        expect(distance, closeTo(222000, 5000));
      });
    });

    group('calculateBearing', () {
      test('returns 0 for due north', () {
        final bearing = GpsUtils.calculateBearing(
          40.0,
          -74.0,
          41.0,
          -74.0,
        );
        expect(bearing, closeTo(0, 0.5));
      });

      test('returns 90 for due east', () {
        final bearing = GpsUtils.calculateBearing(
          0.0,
          0.0,
          0.0,
          1.0,
        );
        expect(bearing, closeTo(90, 0.5));
      });

      test('returns 180 for due south', () {
        final bearing = GpsUtils.calculateBearing(
          41.0,
          -74.0,
          40.0,
          -74.0,
        );
        expect(bearing, closeTo(180, 0.5));
      });

      test('returns 270 for due west', () {
        final bearing = GpsUtils.calculateBearing(
          0.0,
          1.0,
          0.0,
          0.0,
        );
        expect(bearing, closeTo(270, 0.5));
      });

      test('returns bearing between 0 and 360', () {
        final bearing = GpsUtils.calculateBearing(
          40.7128,
          -74.0060,
          34.0522,
          -118.2437,
        );
        expect(bearing, greaterThanOrEqualTo(0));
        expect(bearing, lessThan(360));
      });
    });

    group('calculateRelativeBearing', () {
      test('returns 0 when aligned', () {
        final relative = GpsUtils.calculateRelativeBearing(90, 90);
        expect(relative, equals(0));
      });

      test('returns positive for turn right', () {
        final relative = GpsUtils.calculateRelativeBearing(0, 45);
        expect(relative, equals(45));
      });

      test('returns negative for turn left', () {
        final relative = GpsUtils.calculateRelativeBearing(45, 0);
        expect(relative, equals(-45));
      });

      test('handles 0/360 boundary - turn right', () {
        final relative = GpsUtils.calculateRelativeBearing(350, 10);
        expect(relative, equals(20));
      });

      test('handles 0/360 boundary - turn left', () {
        final relative = GpsUtils.calculateRelativeBearing(10, 350);
        expect(relative, equals(-20));
      });

      test('returns value between -180 and 180', () {
        // Turn right by 170
        final relative1 = GpsUtils.calculateRelativeBearing(0, 170);
        expect(relative1, equals(170));

        // Turn right by 190 should normalize to -170 (left)
        final relative2 = GpsUtils.calculateRelativeBearing(0, 190);
        expect(relative2, equals(-170));
      });
    });

    group('isAligned', () {
      test('returns true when exactly aligned', () {
        expect(GpsUtils.isAligned(90, 90), isTrue);
      });

      test('returns true within default tolerance', () {
        expect(GpsUtils.isAligned(90, 95), isTrue);
        expect(GpsUtils.isAligned(90, 85), isTrue);
      });

      test('returns false outside default tolerance', () {
        expect(GpsUtils.isAligned(90, 101), isFalse);
        expect(GpsUtils.isAligned(90, 79), isFalse);
      });

      test('respects custom tolerance', () {
        expect(GpsUtils.isAligned(90, 110, tolerance: 20), isTrue);
        expect(GpsUtils.isAligned(90, 110, tolerance: 15), isFalse);
      });

      test('handles 0/360 boundary', () {
        expect(GpsUtils.isAligned(5, 355), isTrue);
        expect(GpsUtils.isAligned(355, 5), isTrue);
      });
    });

    group('bearingToCardinal', () {
      test('returns N for 0 degrees', () {
        expect(GpsUtils.bearingToCardinal(0), equals('N'));
      });

      test('returns N for 359 degrees', () {
        expect(GpsUtils.bearingToCardinal(359), equals('N'));
      });

      test('returns NE for 45 degrees', () {
        expect(GpsUtils.bearingToCardinal(45), equals('NE'));
      });

      test('returns E for 90 degrees', () {
        expect(GpsUtils.bearingToCardinal(90), equals('E'));
      });

      test('returns S for 180 degrees', () {
        expect(GpsUtils.bearingToCardinal(180), equals('S'));
      });

      test('returns W for 270 degrees', () {
        expect(GpsUtils.bearingToCardinal(270), equals('W'));
      });

      test('handles boundary values correctly', () {
        // N is 337.5 to 22.5
        expect(GpsUtils.bearingToCardinal(22), equals('N'));
        expect(GpsUtils.bearingToCardinal(23), equals('NE'));
      });
    });

    group('formatBearing', () {
      test('formats with cardinal and degrees', () {
        expect(GpsUtils.formatBearing(0), equals('N (0°)'));
        expect(GpsUtils.formatBearing(90), equals('E (90°)'));
        expect(GpsUtils.formatBearing(180), equals('S (180°)'));
        expect(GpsUtils.formatBearing(270), equals('W (270°)'));
      });

      test('rounds degrees', () {
        expect(GpsUtils.formatBearing(45.6), equals('NE (46°)'));
      });
    });

    group('formatDistance', () {
      group('metric', () {
        test('formats meters under 1km', () {
          expect(GpsUtils.formatDistance(500), equals('500 m'));
          expect(GpsUtils.formatDistance(999), equals('999 m'));
        });

        test('formats kilometers over 1km', () {
          expect(GpsUtils.formatDistance(1000), equals('1.0 km'));
          expect(GpsUtils.formatDistance(5500), equals('5.5 km'));
        });
      });

      group('imperial', () {
        test('formats feet under 1 mile', () {
          final result = GpsUtils.formatDistance(100, useMetric: false);
          expect(result, contains('ft'));
        });

        test('formats miles over 1 mile', () {
          final result = GpsUtils.formatDistance(3000, useMetric: false);
          expect(result, contains('mi'));
        });
      });
    });

    group('formatDistanceSmart', () {
      test('shows more precision for close distances', () {
        expect(GpsUtils.formatDistanceSmart(5.5), equals('5.5 m'));
        expect(GpsUtils.formatDistanceSmart(50), equals('50 m'));
      });

      test('shows two decimals for km between 1-10', () {
        expect(GpsUtils.formatDistanceSmart(2500), equals('2.50 km'));
      });

      test('shows one decimal for km over 10', () {
        expect(GpsUtils.formatDistanceSmart(15000), equals('15.0 km'));
      });
    });
  });
}
