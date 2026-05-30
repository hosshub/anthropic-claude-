/// إشارة المنطقة الثلاثية (تطابق FoodZone في SwiftUI).
enum FoodZone { green, yellow, red }

extension FoodZoneX on FoodZone {
  String get labelAr {
    switch (this) {
      case FoodZone.green:
        return 'أخضر';
      case FoodZone.yellow:
        return 'أصفر';
      case FoodZone.red:
        return 'أحمر';
    }
  }

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
  });

  /// المنطقة الفعلية: الصريحة من v2 إن وُجدت، وإلا اشتقاق من الحكم.
  FoodZone get zone =>
      FoodZoneX.fromString(zoneRaw) ?? FoodZoneX.fromVerdict(verdict);

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

  AnalysisResult({
    required this.items,
    required this.overallScore,
    required this.scoreLabelAr,
    required this.scoreExplanationAr,
    required this.suggestions,
    required this.warnings,
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
    );
  }
}
