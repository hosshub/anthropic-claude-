import 'package:flutter_test/flutter_test.dart';
import 'package:tayyibat/models/suggestion.dart';

/// v1.2: the suggest task returns 3 meals at once as
/// {"suggestions": [ {...}, {...}, {...} ]}. Older deployed functions still
/// return a single bare object — parsing must accept both.
void main() {
  group('MealSuggestion.listFromJson', () {
    test('parses the v1.2 three-suggestion envelope', () {
      final list = MealSuggestion.listFromJson(const {
        'suggestions': [
          {
            'name_ar': 'أرز بلحم',
            'components_ar': ['أرز', 'لحم'],
            'reasoning_ar': 'وجبة خضراء',
            'best_time_ar': 'غداء',
          },
          {
            'name_ar': 'سمك مشوي وبطاطس',
            'components_ar': ['سمك', 'بطاطس'],
            'reasoning_ar': 'بروتين خفيف',
            'best_time_ar': 'عشاء',
          },
          {
            'name_ar': 'كبدة بالسمن',
            'components_ar': ['كبدة', 'سمن بلدي'],
            'reasoning_ar': 'بروتين قوي',
            'best_time_ar': 'فطور',
          },
        ],
      });
      expect(list, hasLength(3));
      expect(list.first.nameAr, 'أرز بلحم');
      expect(list.last.bestTimeAr, 'فطور');
    });

    test('falls back to a single legacy bare object', () {
      final list = MealSuggestion.listFromJson(const {
        'name_ar': 'أرز بلحم',
        'components_ar': ['أرز', 'لحم'],
        'reasoning_ar': 'وجبة خضراء',
        'best_time_ar': 'غداء',
      });
      expect(list, hasLength(1));
      expect(list.single.nameAr, 'أرز بلحم');
    });

    test('skips malformed entries and empty names inside the envelope', () {
      final list = MealSuggestion.listFromJson(const {
        'suggestions': [
          {'name_ar': 'وجبة صالحة', 'components_ar': ['أرز']},
          {'components_ar': ['بلا اسم']},
          'garbage',
        ],
      });
      expect(list, hasLength(1));
      expect(list.single.nameAr, 'وجبة صالحة');
    });

    test('returns empty list when nothing is parsable', () {
      expect(MealSuggestion.listFromJson(const {'error': 'x'}), isEmpty);
    });
  });
}
