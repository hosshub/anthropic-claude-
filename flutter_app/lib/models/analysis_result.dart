/// إشارة المنطقة الثلاثية (تطابق FoodZone في SwiftUI).
/// Locale-aware labels live in lib/l10n/enum_labels.dart — use those.
enum FoodZone { green, yellow, red }

extension FoodZoneX on FoodZone {
  /// قراءة آمنة من نص (مثل FoodZone.from(_:) في SwiftUI).
  static FoodZone? fromString(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    switch (raw.toLowerCase()) {
      case 'green':
        return FoodZone.green;
      case 'yellow':
        return FoodZone.yellow;
      case 'red':
        return FoodZone.red;
      default:
        return null;
    }
  }

  /// اشتقاق المنطقة من الحكم القديم (طيّب / مشروط / خبيث) — للتوافق مع v1.
  static FoodZone fromVerdict(String? verdict) {
    switch ((verdict ?? '').toLowerCase()) {
      case 'tayyib':
        return FoodZone.green;
      case 'khabith':
        return FoodZone.red;
      case 'conditional':
      default:
        return FoodZone.yellow;
    }
  }
}

/// عنصر طعام كما يصل من دالة التحليل.
class FoodItem {
  final String nameAr;
  final double confidence;
  final String estimatedPortion;
  final String verdict;
  final String? zoneRaw;
  final String? cautionAr;
  final String category;
  final String reasoningAr;
  final String? ruleViolated;

  // v1.1 nutrition estimates. Null on rows analyzed before the nutrition
  // schema landed (v1.0.x meals) — the UI hides what it doesn't have.
  final int? caloriesKcal;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final List<String> micros;

  FoodItem({
    required this.nameAr,
    required this.confidence,
    required this.estimatedPortion,
    required this.verdict,
    this.zoneRaw,
    this.cautionAr,
    required this.category,
    required this.reasoningAr,
    this.ruleViolated,
    this.caloriesKcal,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.micros = const [],
  });

  /// المنطقة الفعلية: الصريحة من v2 إن وُجدت، وإلا اشتقاق من الحكم.
  FoodZone get zone =>
      FoodZoneX.fromString(zoneRaw) ?? FoodZoneX.fromVerdict(verdict);

  /// نسخة معدّلة — تُستخدم عند تصحيح المستخدم للاسم أو المنطقة (v1.2).
  /// تغيير المنطقة يزامن verdict القديم حفاظاً على اتساق البيانات.
  FoodItem copyWith({String? nameAr, FoodZone? newZone}) {
    final zoneStr = newZone == null ? zoneRaw : newZone.name;
    final verdictStr = newZone == null
        ? verdict
        : switch (newZone) {
            FoodZone.green => 'tayyib',
            FoodZone.yellow => 'conditional',
            FoodZone.red => 'khabith',
          };
    return FoodItem(
      nameAr: nameAr ?? this.nameAr,
      confidence: confidence,
      estimatedPortion: estimatedPortion,
      verdict: verdictStr,
      zoneRaw: zoneStr,
      cautionAr: cautionAr,
      category: category,
      reasoningAr: reasoningAr,
      ruleViolated: ruleViolated,
      caloriesKcal: caloriesKcal,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      micros: micros,
    );
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      nameAr: (json['name_ar'] as String?) ?? 'غير معروف',
      confidence: ((json['confidence'] as num?) ?? 0.5).toDouble(),
      estimatedPortion: (json['estimated_portion'] as String?) ?? 'متوسطة',
      verdict: (json['verdict'] as String?) ?? 'conditional',
      zoneRaw: json['zone'] as String?,
      cautionAr: json['caution_ar'] as String?,
      category: (json['category'] as String?) ?? 'عام',
      reasoningAr: (json['reasoning_ar'] as String?) ?? '',
      ruleViolated: json['rule_violated'] as String?,
      caloriesKcal: (json['calories_kcal'] as num?)?.round(),
      proteinG: (json['protein_g'] as num?)?.toDouble(),
      carbsG: (json['carbs_g'] as num?)?.toDouble(),
      fatG: (json['fat_g'] as num?)?.toDouble(),
      micros: ((json['micros_ar'] as List?) ?? const [])
          .whereType<String>()
          .where((m) => m.trim().isNotEmpty)
          .toList(),
    );
  }
}

/// مجاميع التغذية للوجبة كاملة (تقديرات بصرية من النموذج).
class MealNutrition {
  final int caloriesKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const MealNutrition({
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  static MealNutrition? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final kcal = (json['calories_kcal'] as num?)?.round();
    if (kcal == null) return null;
    return MealNutrition(
      caloriesKcal: kcal,
      proteinG: ((json['protein_g'] as num?) ?? 0).toDouble(),
      carbsG: ((json['carbs_g'] as num?) ?? 0).toDouble(),
      fatG: ((json['fat_g'] as num?) ?? 0).toDouble(),
    );
  }

  /// جمع القيم من العناصر عندما لا يرسل الخادم total_nutrition — أو عندما
  /// تُقرأ وجبة من قاعدة البيانات (المجاميع لا تُخزَّن، تُشتق دائماً).
  static MealNutrition? fromItems(List<FoodItem> items) {
    final withData = items.where((i) => i.caloriesKcal != null).toList();
    if (withData.isEmpty) return null;
    return MealNutrition(
      caloriesKcal: withData.fold(0, (a, i) => a + (i.caloriesKcal ?? 0)),
      proteinG: withData.fold(0.0, (a, i) => a + (i.proteinG ?? 0)),
      carbsG: withData.fold(0.0, (a, i) => a + (i.carbsG ?? 0)),
      fatG: withData.fold(0.0, (a, i) => a + (i.fatG ?? 0)),
    );
  }
}

/// نتيجة التحليل الكاملة (تطابق AnalysisResult في SwiftUI).
class AnalysisResult {
  final List<FoodItem> items;
  final int overallScore;
  final String scoreLabelAr;
  final String scoreExplanationAr;
  final List<String> suggestions;
  final List<String> warnings;

  /// مجاميع التغذية — من الخادم إن وُجدت، وإلا مشتقة من العناصر، وإلا null
  /// (استجابة قديمة بلا أرقام تغذية).
  final MealNutrition? nutrition;

  AnalysisResult({
    required this.items,
    required this.overallScore,
    required this.scoreLabelAr,
    required this.scoreExplanationAr,
    required this.suggestions,
    required this.warnings,
    this.nutrition,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final raw = (json['identified_items'] as List?) ?? const [];
    final items = raw
        .whereType<Map<String, dynamic>>()
        .map(FoodItem.fromJson)
        .toList();
    return AnalysisResult(
      items: items,
      overallScore: ((json['overall_score'] as num?) ?? 0).toInt(),
      scoreLabelAr: (json['score_label_ar'] as String?) ?? '',
      scoreExplanationAr: (json['score_explanation_ar'] as String?) ?? '',
      suggestions: ((json['improvement_suggestions_ar'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
      warnings: ((json['warnings'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
      nutrition: MealNutrition.fromJson(
            json['total_nutrition'] as Map<String, dynamic>?,
          ) ??
          MealNutrition.fromItems(items),
    );
  }
}
