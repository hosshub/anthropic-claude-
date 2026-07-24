import 'analysis_result.dart';
import 'body_response.dart';

/// وجبة محفوظة محلياً — تطابق Meal (SwiftData) في iOS مع إضافة imagePath.
class Meal {
  final String id;
  final DateTime capturedAt;
  /// مسار الملف على القرص (داخل documents/meals/). فارغ لو فشل الحفظ.
  final String? imagePath;
  final int overallScore;
  final String scoreLabelAr;
  final String scoreExplanationAr;
  final List<String> suggestions;
  final List<String> warnings;
  final List<FoodItem> items;
  final BodyResponse? bodyResponse;

  /// v1.2 — هل عدّل المستخدم عناصر الوجبة يدوياً بعد التحليل؟
  final bool wasEdited;

  const Meal({
    required this.id,
    required this.capturedAt,
    required this.imagePath,
    required this.overallScore,
    required this.scoreLabelAr,
    required this.scoreExplanationAr,
    required this.suggestions,
    required this.warnings,
    required this.items,
    this.bodyResponse,
    this.wasEdited = false,
  });

  Meal copyWith({BodyResponse? bodyResponse}) => Meal(
        id: id,
        capturedAt: capturedAt,
        imagePath: imagePath,
        overallScore: overallScore,
        scoreLabelAr: scoreLabelAr,
        scoreExplanationAr: scoreExplanationAr,
        suggestions: suggestions,
        warnings: warnings,
        items: items,
        bodyResponse: bodyResponse ?? this.bodyResponse,
        wasEdited: wasEdited,
      );

  /// عنوان مختصر للوجبة (اسم أول عنصر، أو "وجبة").
  String get primaryLabel =>
      items.isNotEmpty ? items.first.nameAr : 'وجبة';

  /// مجاميع التغذية مشتقة من العناصر — null لوجبات ما قبل v1.1 التي لا
  /// تحمل أرقام تغذية.
  MealNutrition? get nutrition => MealNutrition.fromItems(items);
}
