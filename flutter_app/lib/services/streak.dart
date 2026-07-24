/// v1.2.1 — سلسلة الأيام المتتالية التي سُجّلت فيها وجبة واحدة على الأقل.
/// السلسلة تبقى حيّة إذا سجّل المستخدم أمس ولم يسجّل اليوم بعد؛ وتنقطع
/// عند تخطّي يوم كامل.
int loggedStreak(Iterable<DateTime> mealTimes, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final today = DateTime(ref.year, ref.month, ref.day);
  final days = <DateTime>{
    for (final t in mealTimes) DateTime(t.year, t.month, t.day),
  };
  if (days.isEmpty) return 0;

  var cursor = today;
  if (!days.contains(cursor)) {
    cursor = today.subtract(const Duration(days: 1));
    if (!days.contains(cursor)) return 0;
  }

  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
