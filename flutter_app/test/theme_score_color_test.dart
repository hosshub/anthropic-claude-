import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/theme/theme.dart';

/// Boundary tests for the score-band color used by the trend chart, calendar
/// dots, and result screen. Bands: >=90 emerald, >=70 light-green, >=50 gold,
/// else khabith.
void main() {
  const lightGreen = Color(0xFF4C9A6A);

  group('TColors.scoreColor band boundaries', () {
    test('90..100 is the emerald primary', () {
      expect(TColors.scoreColor(100), TColors.primary);
      expect(TColors.scoreColor(90), TColors.primary);
    });

    test('70..89 is the light green', () {
      expect(TColors.scoreColor(89), lightGreen);
      expect(TColors.scoreColor(70), lightGreen);
    });

    test('50..69 is gold', () {
      expect(TColors.scoreColor(69), TColors.gold);
      expect(TColors.scoreColor(50), TColors.gold);
    });

    test('below 50 is khabith red', () {
      expect(TColors.scoreColor(49), TColors.khabith);
      expect(TColors.scoreColor(0), TColors.khabith);
    });

    test('the four bands are visually distinct', () {
      final colors = {
        TColors.scoreColor(95),
        TColors.scoreColor(80),
        TColors.scoreColor(60),
        TColors.scoreColor(10),
      };
      expect(colors, hasLength(4));
    });
  });
}
