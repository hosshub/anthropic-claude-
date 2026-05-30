/// تأثير الوجبة على النوم (يُسأل صباح اليوم التالي عادة).
enum SleepImpact { positive, neutral, negative, unknown }

extension SleepImpactX on SleepImpact {
  String get labelAr {
    switch (this) {
      case SleepImpact.positive:
        return 'نوم مريح';
      case SleepImpact.neutral:
        return 'لم ألاحظ فرقاً';
      case SleepImpact.negative:
        return 'تأثر سلباً';
      case SleepImpact.unknown:
        return 'لا أعلم';
    }
  }

  String get raw => name;

  static SleepImpact fromRaw(String? raw) {
    for (final v in SleepImpact.values) {
      if (v.name == raw) return v;
    }
    return SleepImpact.unknown;
  }
}

/// هل تستحق هذه الوجبة التكرار؟
enum WorthRepeating { yes, maybe, no }

extension WorthRepeatingX on WorthRepeating {
  String get labelAr {
    switch (this) {
      case WorthRepeating.yes:
        return 'نعم، أحبها';
      case WorthRepeating.maybe:
        return 'ربما';
      case WorthRepeating.no:
        return 'لا، تجنّبها';
    }
  }

  String get emoji {
    switch (this) {
      case WorthRepeating.yes:
        return '👍';
      case WorthRepeating.maybe:
        return '🤷';
      case WorthRepeating.no:
        return '👎';
    }
  }

  String get raw => name;

  static WorthRepeating fromRaw(String? raw) {
    for (final v in WorthRepeating.values) {
      if (v.name == raw) return v;
    }
    return WorthRepeating.maybe;
  }
}

/// متابعة الجسم بعد الوجبة — يُخزّن في جدول body_responses.
class BodyResponse {
  final String id;
  final String mealId;
  final DateTime loggedAt;
  final int hoursAfterMeal;
  final int satisfyingFullness; // 1..5
  final int bloating; // 0..5
  final int energyLevel; // 1..5
  final SleepImpact sleepImpact;
  final WorthRepeating worthRepeating;
  final String? notes;

  const BodyResponse({
    required this.id,
    required this.mealId,
    required this.loggedAt,
    required this.hoursAfterMeal,
    required this.satisfyingFullness,
    required this.bloating,
    required this.energyLevel,
    required this.sleepImpact,
    required this.worthRepeating,
    this.notes,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'meal_id': mealId,
        'logged_at': loggedAt.millisecondsSinceEpoch,
        'hours_after_meal': hoursAfterMeal,
        'satisfying_fullness': satisfyingFullness,
        'bloating': bloating,
        'energy_level': energyLevel,
        'sleep_impact': sleepImpact.raw,
        'worth_repeating': worthRepeating.raw,
        'notes': notes,
      };

  static BodyResponse fromMap(Map<String, Object?> m) => BodyResponse(
        id: m['id'] as String,
        mealId: m['meal_id'] as String,
        loggedAt: DateTime.fromMillisecondsSinceEpoch(m['logged_at'] as int),
        hoursAfterMeal: (m['hours_after_meal'] as int?) ?? 0,
        satisfyingFullness: (m['satisfying_fullness'] as int?) ?? 3,
        bloating: (m['bloating'] as int?) ?? 0,
        energyLevel: (m['energy_level'] as int?) ?? 3,
        sleepImpact: SleepImpactX.fromRaw(m['sleep_impact'] as String?),
        worthRepeating: WorthRepeatingX.fromRaw(m['worth_repeating'] as String?),
        notes: m['notes'] as String?,
      );

  BodyResponse copyWith({
    int? satisfyingFullness,
    int? bloating,
    int? energyLevel,
    SleepImpact? sleepImpact,
    WorthRepeating? worthRepeating,
    String? notes,
    DateTime? loggedAt,
    int? hoursAfterMeal,
  }) {
    return BodyResponse(
      id: id,
      mealId: mealId,
      loggedAt: loggedAt ?? this.loggedAt,
      hoursAfterMeal: hoursAfterMeal ?? this.hoursAfterMeal,
      satisfyingFullness: satisfyingFullness ?? this.satisfyingFullness,
      bloating: bloating ?? this.bloating,
      energyLevel: energyLevel ?? this.energyLevel,
      sleepImpact: sleepImpact ?? this.sleepImpact,
      worthRepeating: worthRepeating ?? this.worthRepeating,
      notes: notes ?? this.notes,
    );
  }
}
