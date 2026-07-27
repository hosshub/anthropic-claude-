import '../models/analysis_result.dart';

/// مرآة منطق النقاط في الخادم — تُستخدم عند تعديل عناصر وجبة محلياً:
/// أخضر = نقاط كاملة، أصفر = 60%، أحمر = 0 مع سقف 50 للنتيجة الكلية.
int recomputeScore(List<FoodItem> items) {
  if (items.isEmpty) return 0;
  var points = 0.0;
  var hasRed = false;
  for (final item in items) {
    switch (item.zone) {
      case FoodZone.green:
        points += 1.0;
      case FoodZone.yellow:
        points += 0.6;
      case FoodZone.red:
        hasRed = true;
    }
  }
  final score = (points / items.length * 100).round();
  return hasRed && score > 50 ? 50 : score;
}

/// نطاقات التسمية الأربعة (ممتاز / جيد / متوسط / ضعيف) حسب النتيجة.
enum ScoreBand { excellent, good, average, weak }

ScoreBand scoreBand(int score) {
  if (score >= 90) return ScoreBand.excellent;
  if (score >= 70) return ScoreBand.good;
  if (score >= 50) return ScoreBand.average;
  return ScoreBand.weak;
}
