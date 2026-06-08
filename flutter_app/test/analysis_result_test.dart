import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/models/analysis_result.dart';

/// Decode + zone-derivation tests for the analyze response model.
void main() {
  group('FoodZoneX.fromString', () {
    test('parses the three zones, case-insensitively', () {
      expect(FoodZoneX.fromString('green'), FoodZone.green);
      expect(FoodZoneX.fromString('YELLOW'), FoodZone.yellow);
      expect(FoodZoneX.fromString('Red'), FoodZone.red);
    });

    test('returns null for empty / null / unknown', () {
      expect(FoodZoneX.fromString(null), isNull);
      expect(FoodZoneX.fromString(''), isNull);
      expect(FoodZoneX.fromString('purple'), isNull);
    });
  });

  group('FoodZoneX.fromVerdict (v1 back-compat)', () {
    test('maps the legacy verdicts onto zones', () {
      expect(FoodZoneX.fromVerdict('tayyib'), FoodZone.green);
      expect(FoodZoneX.fromVerdict('khabith'), FoodZone.red);
      expect(FoodZoneX.fromVerdict('conditional'), FoodZone.yellow);
    });

    test('defaults unknown / null verdicts to yellow', () {
      expect(FoodZoneX.fromVerdict(null), FoodZone.yellow);
      expect(FoodZoneX.fromVerdict('nonsense'), FoodZone.yellow);
    });
  });

  group('FoodItem.zone', () {
    test('prefers the explicit v2 zone over the verdict', () {
      final item = FoodItem(
        nameAr: 'x',
        confidence: 0.9,
        estimatedPortion: 'متوسطة',
        verdict: 'khabith', // would be red...
        zoneRaw: 'green', // ...but explicit zone wins
        category: 'نشويات',
        reasoningAr: '',
      );
      expect(item.zone, FoodZone.green);
    });

    test('falls back to the verdict when zoneRaw is null or empty', () {
      final fromVerdict = FoodItem(
        nameAr: 'x',
        confidence: 0.9,
        estimatedPortion: 'متوسطة',
        verdict: 'khabith',
        zoneRaw: null,
        category: 'بروتين',
        reasoningAr: '',
      );
      expect(fromVerdict.zone, FoodZone.red);

      final emptyZone = FoodItem(
        nameAr: 'x',
        confidence: 0.9,
        estimatedPortion: 'متوسطة',
        verdict: 'tayyib',
        zoneRaw: '',
        category: 'بروتين',
        reasoningAr: '',
      );
      expect(emptyZone.zone, FoodZone.green);
    });
  });

  group('AnalysisResult.fromJson', () {
    test('decodes a full v2 payload', () {
      final json = {
        'identified_items': [
          {
            'name_ar': 'أرز أبيض',
            'confidence': 0.95,
            'estimated_portion': 'حصة متوسطة',
            'zone': 'green',
            'zone_reason_ar': 'نشوي بسيط',
            'verdict': 'tayyib',
            'category': 'نشويات',
            'reasoning_ar': 'أساس مقبول',
            'rule_violated': null,
          },
          {
            'name_ar': 'جبن معتق',
            'confidence': 0.8,
            'estimated_portion': 'حصة صغيرة',
            'zone': 'yellow',
            'caution_ar': 'راقب الهضم',
            'verdict': 'conditional',
            'category': 'أجبان',
            'reasoning_ar': 'باعتدال',
          },
        ],
        'overall_score': 82,
        'score_label_ar': 'جيد',
        'score_explanation_ar': 'وجبة طيبة في مجملها.',
        'improvement_suggestions_ar': ['قلّل الجبن', 'أضف خضار'],
        'warnings': ['عنصر أصفر واحد'],
      };

      final result = AnalysisResult.fromJson(json);
      expect(result.items, hasLength(2));
      expect(result.items[0].nameAr, 'أرز أبيض');
      expect(result.items[0].zone, FoodZone.green);
      expect(result.items[1].zone, FoodZone.yellow);
      expect(result.items[1].cautionAr, 'راقب الهضم');
      expect(result.overallScore, 82);
      expect(result.scoreLabelAr, 'جيد');
      expect(result.suggestions, ['قلّل الجبن', 'أضف خضار']);
      expect(result.warnings, ['عنصر أصفر واحد']);
    });

    test('fills sensible defaults for a sparse payload', () {
      final result = AnalysisResult.fromJson(const {});
      expect(result.items, isEmpty);
      expect(result.overallScore, 0);
      expect(result.scoreLabelAr, '');
      expect(result.scoreExplanationAr, '');
      expect(result.suggestions, isEmpty);
      expect(result.warnings, isEmpty);
    });

    test('skips non-object entries inside identified_items', () {
      final json = {
        'identified_items': [
          'oops-a-string',
          42,
          {'name_ar': 'بطاطس', 'zone': 'green'},
        ],
        'overall_score': 90,
      };
      final result = AnalysisResult.fromJson(json);
      expect(result.items, hasLength(1));
      expect(result.items.single.nameAr, 'بطاطس');
    });

    test('coerces numeric score from double to int', () {
      final result = AnalysisResult.fromJson({'overall_score': 87.6});
      expect(result.overallScore, 87);
    });

    test('item defaults apply when fields are missing', () {
      final result = AnalysisResult.fromJson({
        'identified_items': [<String, dynamic>{}],
      });
      final item = result.items.single;
      expect(item.nameAr, 'غير معروف');
      expect(item.confidence, 0.5);
      expect(item.verdict, 'conditional');
      expect(item.zone, FoodZone.yellow); // conditional -> yellow
    });
  });
}
