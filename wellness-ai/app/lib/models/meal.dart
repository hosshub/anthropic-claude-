/// Plan-fit zone — the shared green/amber/red scoring language.
enum FitZone { green, amber, red }

FitZone fitZoneFromString(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'green':
      return FitZone.green;
    case 'red':
      return FitZone.red;
    default:
      return FitZone.amber;
  }
}

/// A single recognized food item from the AI analysis.
class FoodItem {
  final String nameAr;
  final String? nameEn;
  final String estimatedPortion;
  final double confidence;
  final FitZone zone;
  final String? reasoningAr;
  // Nutrition (per item; nullable until estimated)
  final int? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? sodiumMg;

  const FoodItem({
    required this.nameAr,
    this.nameEn,
    required this.estimatedPortion,
    required this.confidence,
    required this.zone,
    this.reasoningAr,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.sodiumMg,
  });

  factory FoodItem.fromJson(Map<String, dynamic> j) => FoodItem(
        nameAr: (j['name_ar'] as String?) ?? 'غير معروف',
        nameEn: j['name_en'] as String?,
        estimatedPortion: (j['estimated_portion'] as String?) ?? 'متوسطة',
        confidence: ((j['confidence'] as num?) ?? 0.5).toDouble(),
        zone: fitZoneFromString(j['zone'] as String?),
        reasoningAr: j['reasoning_ar'] as String?,
        calories: (j['calories'] as num?)?.toInt(),
        proteinG: (j['protein_g'] as num?)?.toDouble(),
        carbsG: (j['carbs_g'] as num?)?.toDouble(),
        fatG: (j['fat_g'] as num?)?.toDouble(),
        sodiumMg: (j['sodium_mg'] as num?)?.toDouble(),
      );
}

/// Full analysis result for one captured meal, scored against the active plan.
class MealAnalysis {
  final List<FoodItem> items;
  final int overallScore; // 0–100 plan-fit
  final String scoreLabelAr;
  final String reasoningAr;
  final List<String> suggestionsAr;

  const MealAnalysis({
    required this.items,
    required this.overallScore,
    required this.scoreLabelAr,
    required this.reasoningAr,
    required this.suggestionsAr,
  });

  factory MealAnalysis.fromJson(Map<String, dynamic> j) {
    final rawItems = (j['identified_items'] as List?) ?? const [];
    return MealAnalysis(
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(FoodItem.fromJson)
          .toList(),
      overallScore: ((j['overall_score'] as num?) ?? 0).toInt(),
      scoreLabelAr: (j['score_label_ar'] as String?) ?? '',
      reasoningAr: (j['reasoning_ar'] as String?) ?? '',
      suggestionsAr: ((j['suggestions_ar'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}
