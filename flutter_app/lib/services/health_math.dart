// v1.3 — حسابات Apple Health خالصة (بلا HealthKit) حتى تكون قابلة للاختبار.

/// مجموع دقائق النوم من فترات قد تتداخل.
///
/// ساعة Apple والهاتف قد يسجّلان الليلة نفسها، فالجمع المباشر يضاعف المدة.
/// ندمج الفترات المتداخلة أولاً ثم نجمع، ونتجاهل الفترات الصفرية أو المقلوبة.
int sleepMinutesFromIntervals(
  Iterable<({DateTime start, DateTime end})> intervals,
) {
  final valid = [
    for (final i in intervals)
      if (i.end.isAfter(i.start)) i,
  ]..sort((a, b) => a.start.compareTo(b.start));
  if (valid.isEmpty) return 0;

  var total = Duration.zero;
  var windowStart = valid.first.start;
  var windowEnd = valid.first.end;
  for (final i in valid.skip(1)) {
    if (i.start.isAfter(windowEnd)) {
      total += windowEnd.difference(windowStart);
      windowStart = i.start;
      windowEnd = i.end;
    } else if (i.end.isAfter(windowEnd)) {
      windowEnd = i.end; // امتداد للفترة الحالية
    }
    // الفترة المُحتواة بالكامل لا تضيف شيئاً
  }
  total += windowEnd.difference(windowStart);
  return total.inMinutes;
}

/// أحدث قياس زمنياً (لا الأكبر قيمةً) — يُستخدم للوزن.
double? latestSampleValue(
  Iterable<({DateTime at, double value})> samples,
) {
  ({DateTime at, double value})? newest;
  for (final s in samples) {
    if (newest == null || s.at.isAfter(newest.at)) newest = s;
  }
  return newest?.value;
}

/// هل نكتب سعرات هذه الوجبة في تطبيق الصحة؟ الكتابة اختيارية صراحةً.
bool shouldWriteMealEnergy({
  required bool connected,
  required bool writeEnabled,
  required int kcal,
}) =>
    connected && writeEnabled && kcal > 0;
