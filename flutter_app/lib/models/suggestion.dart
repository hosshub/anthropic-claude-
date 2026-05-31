/// اقتراح وجبة طيبة قادم من Gemini (عبر الوسيط).
class MealSuggestion {
  final String nameAr;
  final List<String> componentsAr;
  final String reasoningAr;
  final String bestTimeAr;

  const MealSuggestion({
    required this.nameAr,
    required this.componentsAr,
    required this.reasoningAr,
    required this.bestTimeAr,
  });

  factory MealSuggestion.fromJson(Map<String, dynamic> json) => MealSuggestion(
        nameAr: (json['name_ar'] as String?) ?? '',
        componentsAr: ((json['components_ar'] as List?) ?? const [])
            .whereType<String>()
            .toList(),
        reasoningAr: (json['reasoning_ar'] as String?) ?? '',
        bestTimeAr: (json['best_time_ar'] as String?) ?? '',
      );
}

/// خطة وجبات أسبوعية (٧ أيام).
class WeeklyPlan {
  final String introAr;
  final List<DayPlan> days;

  const WeeklyPlan({required this.introAr, required this.days});

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) => WeeklyPlan(
        introAr: (json['intro_ar'] as String?) ?? '',
        days: ((json['days'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(DayPlan.fromJson)
            .toList(),
      );
}

class DayPlan {
  final String dayAr;
  final List<String> mealsAr;
  final String noteAr;

  const DayPlan({
    required this.dayAr,
    required this.mealsAr,
    required this.noteAr,
  });

  factory DayPlan.fromJson(Map<String, dynamic> json) => DayPlan(
        dayAr: (json['day_ar'] as String?) ?? '',
        mealsAr: ((json['meals_ar'] as List?) ?? const [])
            .whereType<String>()
            .toList(),
        noteAr: (json['note_ar'] as String?) ?? '',
      );
}
