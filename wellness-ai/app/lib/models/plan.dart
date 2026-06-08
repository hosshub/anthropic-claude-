/// How a plan originated.
enum PlanSource { elective, conditionInformed, providerPrescribed }

/// A diet / condition-informed plan the user follows. Framed as lifestyle
/// personalization — NOT medical therapy (see docs/BRD.md §13).
class Plan {
  final String id;
  final String titleAr;
  final String? subtitleAr;
  final PlanSource source;

  /// Optional condition/diet tags driving personalization
  /// (e.g. "diabetes", "pcos", "hypertension", "keto", "vegan", "glp1").
  final List<String> tags;

  /// Daily targets the app tracks against.
  final int? targetCalories;
  final double? targetProteinG;
  final double? targetCarbsG;
  final double? targetFatG;
  final double? targetSodiumMg;

  /// Free-text rules the AI scoring layer applies (allowed/limited foods, etc.).
  final List<String> rulesAr;

  /// Provider who prescribed it, if any.
  final String? providerId;

  const Plan({
    required this.id,
    required this.titleAr,
    this.subtitleAr,
    required this.source,
    this.tags = const [],
    this.targetCalories,
    this.targetProteinG,
    this.targetCarbsG,
    this.targetFatG,
    this.targetSodiumMg,
    this.rulesAr = const [],
    this.providerId,
  });

  factory Plan.fromJson(Map<String, dynamic> j) => Plan(
        id: j['id'] as String,
        titleAr: (j['title_ar'] as String?) ?? '',
        subtitleAr: j['subtitle_ar'] as String?,
        source: PlanSource.values.firstWhere(
          (s) => s.name == (j['source'] as String?),
          orElse: () => PlanSource.elective,
        ),
        tags: ((j['tags'] as List?) ?? const []).whereType<String>().toList(),
        targetCalories: (j['target_calories'] as num?)?.toInt(),
        targetProteinG: (j['target_protein_g'] as num?)?.toDouble(),
        targetCarbsG: (j['target_carbs_g'] as num?)?.toDouble(),
        targetFatG: (j['target_fat_g'] as num?)?.toDouble(),
        targetSodiumMg: (j['target_sodium_mg'] as num?)?.toDouble(),
        rulesAr:
            ((j['rules_ar'] as List?) ?? const []).whereType<String>().toList(),
        providerId: j['provider_id'] as String?,
      );
}
