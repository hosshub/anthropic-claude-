import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/models/analysis_result.dart';
import 'package:tayyibat/services/score_engine.dart';

FoodItem _item(String zone) => FoodItem.fromJson({
      'name_ar': 'عنصر',
      'zone': zone,
      'verdict': zone == 'green'
          ? 'tayyib'
          : zone == 'red'
              ? 'khabith'
              : 'conditional',
    });

/// Client-side mirror of the server scoring so edited meals get a fresh
/// score: green = full points, yellow = 60%, red = 0, and any red item
/// caps the overall score at 50.
void main() {
  group('recomputeScore', () {
    test('all green scores 100', () {
      expect(recomputeScore([_item('green'), _item('green')]), 100);
    });

    test('all yellow scores 60', () {
      expect(recomputeScore([_item('yellow'), _item('yellow')]), 60);
    });

    test('green + yellow averages full and 60%', () {
      // (1.0 + 0.6) / 2 = 80
      expect(recomputeScore([_item('green'), _item('yellow')]), 80);
    });

    test('red item contributes zero and caps score at 50', () {
      // (1.0 + 1.0 + 0.0) / 3 = 67 → capped to 50 by the red item
      expect(
        recomputeScore([_item('green'), _item('green'), _item('red')]),
        50,
      );
    });

    test('red cap only lowers, never raises', () {
      // (0.6 + 0.0) / 2 = 30 → stays 30 (cap is a maximum, not a floor)
      expect(recomputeScore([_item('yellow'), _item('red')]), 30);
    });

    test('empty list scores 0', () {
      expect(recomputeScore(const []), 0);
    });

    test('zone falls back to verdict when zone string is missing', () {
      final legacy = FoodItem.fromJson(const {
        'name_ar': 'فراخ',
        'verdict': 'khabith',
      });
      expect(recomputeScore([legacy]), 0);
    });
  });

  group('scoreBand', () {
    test('maps score ranges to the four label bands', () {
      expect(scoreBand(95), ScoreBand.excellent);
      expect(scoreBand(90), ScoreBand.excellent);
      expect(scoreBand(89), ScoreBand.good);
      expect(scoreBand(70), ScoreBand.good);
      expect(scoreBand(69), ScoreBand.average);
      expect(scoreBand(50), ScoreBand.average);
      expect(scoreBand(49), ScoreBand.weak);
      expect(scoreBand(0), ScoreBand.weak);
    });
  });
}
