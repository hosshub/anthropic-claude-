/// v1.3.0 — نسبة الالتزام بالخطة (المخطط مقابل الفعلي).
///
/// تمزج إشارتين لكل يوم مضى منذ بداية الخطة:
///  - يدوي: نسبة وجبات اليوم التي أشّر المستخدم على إنجازها.
///  - تلقائي: هل سجّل المستخدم وجبة واحدة على الأقل في ذلك التاريخ.
/// درجة اليوم = الأكبر بين الاثنتين (أي إشارة تُحتسب لصالح اليوم). النتيجة
/// متوسط أيام الخطة المنقضية حتى [today] فقط، من 0 إلى 100.
int planAdherenceScore({
  required DateTime startedAt,
  required List<double> dayManualFractions,
  required Set<DateTime> loggedDates,
  required DateTime today,
}) {
  final start = _dateOnly(startedAt);
  final t = _dateOnly(today);
  var sum = 0.0;
  var count = 0;
  for (var d = 0; d < dayManualFractions.length; d++) {
    final date = DateTime(start.year, start.month, start.day + d);
    if (date.isAfter(t)) break; // الأيام المستقبلية لا تُحتسب بعد
    final auto = loggedDates.contains(date) ? 1.0 : 0.0;
    final manual = dayManualFractions[d].clamp(0.0, 1.0);
    sum += manual > auto ? manual : auto;
    count++;
  }
  if (count == 0) return 0;
  return (sum / count * 100).round();
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
