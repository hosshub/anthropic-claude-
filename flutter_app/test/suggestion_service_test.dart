import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:tayyibat/services/suggestion_service.dart';

/// v1.3.0 — suggestMeals sends the optional meal_type filter and returns the
/// 5-suggestion envelope.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('threads meal_type into the request and parses 5 suggestions',
      () async {
    Map<String, dynamic>? sentBody;
    final client = MockClient((req) async {
      sentBody = jsonDecode(req.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          'suggestions': List.generate(
            5,
            (i) => {
              'name_ar': 'وجبة $i',
              'components_ar': ['مكوّن'],
              'reasoning_ar': 'سبب',
              'best_time_ar': 'غداء',
            },
          ),
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final svc = SuggestionService(client: client);
    final result = await svc.suggestMeals(mealType: 'lunch');

    expect(result, hasLength(5));
    expect(sentBody!['task'], 'suggest');
    expect(sentBody!['meal_type'], 'lunch');
  });

  test('omits meal_type when none is given', () async {
    Map<String, dynamic>? sentBody;
    final client = MockClient((req) async {
      sentBody = jsonDecode(req.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          'suggestions': [
            {'name_ar': 'وجبة', 'components_ar': [], 'reasoning_ar': '', 'best_time_ar': ''}
          ]
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final svc = SuggestionService(client: client);
    await svc.suggestMeals();
    expect(sentBody!.containsKey('meal_type'), isFalse);
  });
}
